{
  config,
  pkgs,
  lib,
  ...
}:

let
  colors = config.lib.stylix.colors;
  fonts = config.stylix.fonts;

  # Quickshell bar configuration adapted for Niri
  barConfig = pkgs.writeText "bar.qml" ''
    import Quickshell
    import Quickshell.Wayland
    import Quickshell.Io
    import QtQuick
    import QtQuick.Layouts

    PanelWindow {
        id: root

        // Theme - using Stylix colors
        property color colBg: "#${colors.base00}"
        property color colFg: "#${colors.base05}"
        property color colMuted: "#${colors.base03}"
        property color colCyan: "#${colors.base0C}"
        property color colBlue: "#${colors.base0D}"
        property color colYellow: "#${colors.base0A}"
        property color colGreen: "#${colors.base0B}"
        property color colRed: "#${colors.base08}"
        property string fontFamily: "${fonts.monospace.name}"
        property int fontSize: 14

        // System data
        property int cpuUsage: 0
        property int memUsage: 0
        property var lastCpuIdle: 0
        property var lastCpuTotal: 0
        property int batteryLevel: 0
        property string batteryStatus: ""

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
                    if (root.lastCpuTotal > 0) {
                        root.cpuUsage = Math.round(100 * (1 - (idle - root.lastCpuIdle) / (total - root.lastCpuTotal)))
                    }
                    root.lastCpuTotal = total
                    root.lastCpuIdle = idle
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
                    root.memUsage = Math.round(100 * used / total)
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
                    root.batteryLevel = parseInt(data.trim()) || 0
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
                    root.batteryStatus = data.trim()
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
            }
        }

        // Panel configuration
        anchors.top: true
        anchors.left: true
        anchors.right: true
        implicitHeight: 30
        color: root.colBg

        RowLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 12

            // Launcher button
            Text {
                text: "󱄅"
                color: root.colBlue
                font { family: root.fontFamily; pixelSize: 18; bold: true }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        launcher.running = true
                    }
                }
                Process {
                    id: launcher
                    command: ["${pkgs.fuzzel}/bin/fuzzel"]
                }
            }

            Rectangle { width: 1; height: 16; color: root.colMuted }

            // Workspaces (Niri)
            // Note: Niri doesn't have direct Quickshell integration like Hyprland,
            // so we use niri msg to get workspace info
            Row {
                spacing: 8
                Repeater {
                    id: workspaceRepeater
                    model: ListModel {
                        id: workspaceModel
                        // Initialize with workspaces 1-9
                        Component.onCompleted: {
                            for (var i = 1; i <= 9; i++) {
                                append({"id": i, "active": false, "windows": 0})
                            }
                        }
                    }
                    delegate: Text {
                        text: model.id
                        color: model.active ? root.colCyan : (model.windows > 0 ? root.colBlue : root.colMuted)
                        font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                switchWorkspace.command = ["${pkgs.niri}/bin/niri", "msg", "action", "focus-workspace", model.id.toString()]
                                switchWorkspace.running = true
                            }
                        }
                    }
                }
                Process {
                    id: switchWorkspace
                    command: []
                }
            }

            Item { Layout.fillWidth: true }

            // System stats section

            // CPU
            Row {
                spacing: 4
                Text {
                    text: ""
                    color: root.colYellow
                    font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
                }
                Text {
                    text: root.cpuUsage + "%"
                    color: root.colFg
                    font { family: root.fontFamily; pixelSize: root.fontSize }
                }
            }

            Rectangle { width: 1; height: 16; color: root.colMuted }

            // Memory
            Row {
                spacing: 4
                Text {
                    text: ""
                    color: root.colCyan
                    font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
                }
                Text {
                    text: root.memUsage + "%"
                    color: root.colFg
                    font { family: root.fontFamily; pixelSize: root.fontSize }
                }
            }

            Rectangle { width: 1; height: 16; color: root.colMuted }

            // Battery (only shown if battery exists)
            Row {
                spacing: 4
                visible: root.batteryLevel > 0 || root.batteryStatus !== "Unknown"
                Text {
                    text: root.batteryStatus === "Charging" ? "󰂄" : 
                          root.batteryLevel > 80 ? "󰁹" :
                          root.batteryLevel > 60 ? "󰂀" :
                          root.batteryLevel > 40 ? "󰁾" :
                          root.batteryLevel > 20 ? "󰁼" : "󰁺"
                    color: root.batteryLevel < 20 && root.batteryStatus !== "Charging" ? root.colRed : root.colGreen
                    font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
                }
                Text {
                    text: root.batteryLevel + "%"
                    color: root.colFg
                    font { family: root.fontFamily; pixelSize: root.fontSize }
                }
            }

            Rectangle { 
                width: 1
                height: 16
                color: root.colMuted
                visible: root.batteryLevel > 0 || root.batteryStatus !== "Unknown"
            }

            // Clock
            Text {
                id: clock
                color: root.colBlue
                font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
                text: Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")
                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: clock.text = Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")
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
  ];

  # Create the quickshell configuration directory
  xdg.configFile."quickshell/shell.qml".source = "${quickshellConfig}/quickshell/shell.qml";

  # Autostart quickshell with Niri
  # You can also add this to your Niri config spawn-at-startup
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
