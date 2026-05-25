{
  config,
  pkgs,
  lib,
  ...
}:

let
  colors = config.lib.stylix.colors;

  # Quickshell bar configuration adapted for Niri - Simplified and inspired by caelestia-dots
  barConfig = pkgs.writeText "shell.qml" ''
    import Quickshell
    import Quickshell.Wayland
    import Quickshell.Io
    import Quickshell.Services.Pipewire
    import Quickshell.Services.SystemTray
    import QtQuick
    import QtQuick.Layouts

    ShellRoot {
        id: shell

        PanelWindow {
            id: bar

            // Theme - using Stylix colors
            property color colBg: "#${colors.base00}"
            property color colFg: "#${colors.base05}"
            property color colMuted: "#${colors.base03}"
            property color colCyan: "#${colors.base0C}"
            property color colBlue: "#${colors.base0D}"
            property color colYellow: "#${colors.base0A}"
            property color colGreen: "#${colors.base0B}"
            property color colRed: "#${colors.base08}"
            property color colOrange: "#${colors.base09}"
            property color colMagenta: "#${colors.base0E}"
            property string fontFamily: "Hack Nerd Font Mono"
            property int fontSize: 14

            // System data properties
            property int cpuUsage: 0
            property int memUsage: 0
            property var lastCpuIdle: 0
            property var lastCpuTotal: 0
            property int batteryLevel: 0
            property string batteryStatus: ""
            property int temperature: 0
            property int brightnessLevel: 0
            property string networkStatus: "󰤭"
            property string networkName: "Disconnected"

            // Audio from Pipewire
            property var sink: Pipewire.defaultAudioSink
            property real volume: sink?.audio?.volume ?? 0
            property bool muted: sink?.audio?.muted ?? false

            // Panel configuration
            anchors.top: true
            anchors.left: true
            anchors.right: true
            implicitHeight: 32
            color: bar.colBg

            // CPU monitoring
            Process {
                id: cpuProc
                command: ["sh", "-c", "head -1 /proc/stat"]
                stdout: SplitParser {
                    onRead: data => {
                        if (!data) return
                        var p = data.trim().split(/\s+/)
                        var idle = parseInt(p[4]) + parseInt(p[5])
                        var total = p.slice(1, 8).reduce((a, b) => a + parseInt(b), 0)
                        if (bar.lastCpuTotal > 0) {
                            bar.cpuUsage = Math.round(100 * (1 - (idle - bar.lastCpuIdle) / (total - bar.lastCpuTotal)))
                        }
                        bar.lastCpuTotal = total
                        bar.lastCpuIdle = idle
                    }
                }
                Component.onCompleted: running = true
            }

            // Memory monitoring
            Process {
                id: memProc
                command: ["sh", "-c", "free | grep Mem"]
                stdout: SplitParser {
                    onRead: data => {
                        if (!data) return
                        var parts = data.trim().split(/\s+/)
                        var total = parseInt(parts[1]) || 1
                        var used = parseInt(parts[2]) || 0
                        bar.memUsage = Math.round(100 * used / total)
                    }
                }
                Component.onCompleted: running = true
            }

            // Battery monitoring
            Process {
                id: batteryProc
                command: ["sh", "-c", "cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo 0"]
                stdout: SplitParser {
                    onRead: data => {
                        if (!data) return
                        bar.batteryLevel = parseInt(data.trim()) || 0
                    }
                }
                Component.onCompleted: running = true
            }

            Process {
                id: batteryStatusProc
                command: ["sh", "-c", "cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo Unknown"]
                stdout: SplitParser {
                    onRead: data => {
                        if (!data) return
                        bar.batteryStatus = data.trim()
                    }
                }
                Component.onCompleted: running = true
            }

            // Temperature monitoring
            Process {
                id: tempProc
                command: ["sh", "-c", "cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null || echo 0"]
                stdout: SplitParser {
                    onRead: data => {
                        if (!data) return
                        bar.temperature = Math.round(parseInt(data.trim()) / 1000) || 0
                    }
                }
                Component.onCompleted: running = true
            }

            // Brightness monitoring
            Process {
                id: brightnessProc
                command: ["sh", "-c", "echo $(${pkgs.brightnessctl}/bin/brightnessctl get) $(${pkgs.brightnessctl}/bin/brightnessctl max)"]
                stdout: SplitParser {
                    onRead: data => {
                        if (!data) return
                        var parts = data.trim().split(/\s+/)
                        if (parts.length >= 2) {
                            var current = parseInt(parts[0]) || 0
                            var max = parseInt(parts[1]) || 1
                            bar.brightnessLevel = Math.round(100 * current / max)
                        }
                    }
                }
                Component.onCompleted: running = true
            }

            // Network monitoring
            Process {
                id: networkProc
                command: ["sh", "-c", "${pkgs.networkmanager}/bin/nmcli -t -f TYPE,STATE,CONNECTION device status | grep -E '^(wifi|ethernet):connected' | head -1"]
                stdout: SplitParser {
                    onRead: data => {
                        if (!data || data.trim() === "") {
                            bar.networkStatus = "󰤭"
                            bar.networkName = "Disconnected"
                            return
                        }
                        var parts = data.trim().split(':')
                        if (parts.length >= 3) {
                            var type = parts[0]
                            bar.networkName = parts[2]
                            bar.networkStatus = type === "wifi" ? "󰤨" : "󰈀"
                        }
                    }
                }
                Component.onCompleted: running = true
            }

            // Update timer for system stats
            Timer {
                interval: 2000
                running: true
                repeat: true
                onTriggered: {
                    cpuProc.running = true
                    memProc.running = true
                    batteryProc.running = true
                    batteryStatusProc.running = true
                    tempProc.running = true
                    brightnessProc.running = true
                    networkProc.running = true
                }
            }

            // Clock timer
            SystemClock {
                id: clock
                precision: SystemClock.Seconds
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 16

                // === LEFT SECTION ===

                // Launcher button
                Text {
                    text: "󱄅"
                    color: bar.colBlue
                    font { family: bar.fontFamily; pixelSize: 18; bold: true }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: launcher.running = true
                    }
                    Process {
                        id: launcher
                        command: ["${pkgs.fuzzel}/bin/fuzzel"]
                    }
                }

                Item { Layout.fillWidth: true }

                // === CENTER SECTION - Clock ===
                Text {
                    Layout.alignment: Qt.AlignCenter
                    text: Qt.formatDateTime(clock.date, "ddd, MMM dd  󰥔  HH:mm")
                    color: bar.colFg
                    font { family: bar.fontFamily; pixelSize: bar.fontSize }
                }

                Item { Layout.fillWidth: true }

                // === RIGHT SECTION ===

                // Network
                Row {
                    spacing: 6
                    Text {
                        text: bar.networkStatus
                        color: bar.networkStatus === "󰤭" ? bar.colRed : bar.colGreen
                        font { family: bar.fontFamily; pixelSize: bar.fontSize }
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: bar.networkName
                        color: bar.colFg
                        font { family: bar.fontFamily; pixelSize: bar.fontSize }
                        visible: bar.networkName !== "Disconnected"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: networkEditor.running = true
                    }
                    Process {
                        id: networkEditor
                        command: ["${pkgs.networkmanagerapplet}/bin/nm-connection-editor"]
                    }
                }

                // Divider
                Rectangle { width: 1; height: 16; color: bar.colMuted; Layout.alignment: Qt.AlignVCenter }

                // Volume (using Pipewire)
                Row {
                    spacing: 6
                    Text {
                        text: bar.muted ? "󰝟" : 
                              bar.volume > 0.5 ? "󰕾" :
                              bar.volume > 0 ? "󰖀" : "󰕿"
                        color: bar.muted ? bar.colRed : bar.colBlue
                        font { family: bar.fontFamily; pixelSize: bar.fontSize }
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: Math.round(bar.volume * 100) + "%"
                        color: bar.colFg
                        font { family: bar.fontFamily; pixelSize: bar.fontSize }
                        visible: !bar.muted
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                        onClicked: mouse => {
                            if (mouse.button === Qt.MiddleButton && bar.sink?.audio) {
                                bar.sink.audio.muted = !bar.sink.audio.muted
                            } else {
                                volumeControl.running = true
                            }
                        }
                        onWheel: wheel => {
                            if (bar.sink?.audio) {
                                var newVol = bar.volume + (wheel.angleDelta.y > 0 ? 0.05 : -0.05)
                                bar.sink.audio.volume = Math.max(0, Math.min(1.5, newVol))
                            }
                        }
                    }
                    Process {
                        id: volumeControl
                        command: ["${pkgs.pavucontrol}/bin/pavucontrol"]
                    }
                }

                // Divider
                Rectangle { width: 1; height: 16; color: bar.colMuted; Layout.alignment: Qt.AlignVCenter }

                // Brightness
                Row {
                    spacing: 6
                    Text {
                        text: "󰃞"
                        color: bar.colYellow
                        font { family: bar.fontFamily; pixelSize: bar.fontSize }
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: bar.brightnessLevel + "%"
                        color: bar.colFg
                        font { family: bar.fontFamily; pixelSize: bar.fontSize }
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onWheel: wheel => {
                            if (wheel.angleDelta.y > 0)
                                brightnessUp.running = true
                            else
                                brightnessDown.running = true
                            brightnessUpdateTimer.restart()
                        }
                    }
                    Process {
                        id: brightnessUp
                        command: ["${pkgs.brightnessctl}/bin/brightnessctl", "set", "+5%"]
                    }
                    Process {
                        id: brightnessDown
                        command: ["${pkgs.brightnessctl}/bin/brightnessctl", "set", "5%-"]
                    }
                    Timer {
                        id: brightnessUpdateTimer
                        interval: 100
                        onTriggered: brightnessProc.running = true
                    }
                }

                // Divider
                Rectangle { width: 1; height: 16; color: bar.colMuted; Layout.alignment: Qt.AlignVCenter }

                // CPU
                Row {
                    spacing: 6
                    Text {
                        text: "󰍛"
                        color: bar.colYellow
                        font { family: bar.fontFamily; pixelSize: bar.fontSize }
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: bar.cpuUsage + "%"
                        color: bar.colFg
                        font { family: bar.fontFamily; pixelSize: bar.fontSize }
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // Divider
                Rectangle { width: 1; height: 16; color: bar.colMuted; Layout.alignment: Qt.AlignVCenter }

                // Memory
                Row {
                    spacing: 6
                    Text {
                        text: "󰘚"
                        color: bar.colCyan
                        font { family: bar.fontFamily; pixelSize: bar.fontSize }
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: bar.memUsage + "%"
                        color: bar.colFg
                        font { family: bar.fontFamily; pixelSize: bar.fontSize }
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // Divider
                Rectangle { width: 1; height: 16; color: bar.colMuted; Layout.alignment: Qt.AlignVCenter }

                // Temperature
                Row {
                    spacing: 6
                    visible: bar.temperature > 0
                    Text {
                        text: "󰔏"
                        color: bar.temperature > 80 ? bar.colRed : bar.temperature > 60 ? bar.colOrange : bar.colGreen
                        font { family: bar.fontFamily; pixelSize: bar.fontSize }
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: bar.temperature + "°C"
                        color: bar.colFg
                        font { family: bar.fontFamily; pixelSize: bar.fontSize }
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // Divider (only if temperature visible)
                Rectangle { 
                    width: 1
                    height: 16
                    color: bar.colMuted
                    Layout.alignment: Qt.AlignVCenter
                    visible: bar.temperature > 0
                }

                // Battery
                Row {
                    spacing: 6
                    visible: bar.batteryLevel > 0 || bar.batteryStatus !== "Unknown"
                    Text {
                        text: bar.batteryStatus === "Charging" ? "󰂄" : 
                              bar.batteryLevel > 80 ? "󰁹" :
                              bar.batteryLevel > 60 ? "󰂀" :
                              bar.batteryLevel > 40 ? "󰁾" :
                              bar.batteryLevel > 20 ? "󰁼" : "󰁺"
                        color: bar.batteryLevel < 20 && bar.batteryStatus !== "Charging" ? bar.colRed : bar.colGreen
                        font { family: bar.fontFamily; pixelSize: bar.fontSize }
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: bar.batteryLevel + "%"
                        color: bar.colFg
                        font { family: bar.fontFamily; pixelSize: bar.fontSize }
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // Divider (only if battery visible)
                Rectangle { 
                    width: 1
                    height: 16
                    color: bar.colMuted
                    Layout.alignment: Qt.AlignVCenter
                    visible: bar.batteryLevel > 0 || bar.batteryStatus !== "Unknown"
                }

                // System Tray
                Row {
                    spacing: 8
                    Repeater {
                        model: SystemTray.items
                        
                        Image {
                            required property SystemTrayItem modelData
                            
                            width: 18
                            height: 18
                            source: modelData.icon
                            sourceSize: Qt.size(18, 18)
                            
                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                cursorShape: Qt.PointingHandCursor
                                onClicked: mouse => {
                                    if (mouse.button === Qt.LeftButton)
                                        modelData.activate()
                                    else
                                        modelData.secondaryActivate()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
  '';

  # Quickshell service configuration script
  quickshellConfig = pkgs.writeTextDir "quickshell/shell.qml" (builtins.readFile barConfig);

in
{
  home.packages = with pkgs; [
    quickshell
    pamixer
    brightnessctl
    networkmanagerapplet
    pavucontrol
  ];

  # Create the quickshell configuration directory
  xdg.configFile."quickshell/shell.qml".source = "${quickshellConfig}/quickshell/shell.qml";

  # Autostart quickshell with Niri
  systemd.user.services.quickshell = {
    Unit = {
      Description = "Quickshell status bar";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.quickshell}/bin/quickshell";
      Restart = "on-failure";
      RestartSec = 3;
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
