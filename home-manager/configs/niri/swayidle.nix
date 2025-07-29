{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    swayidle
    wlopm # Wayland output power manager
  ];

  # Configure swayidle service
  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 300; # 5 minutes (300 seconds)
        command = "${pkgs.brightnessctl}/bin/brightnessctl -d \"*backlight*\" set 10%";
      }
      {
        timeout = 600; # 10 minutes (600 seconds)
        command = "${pkgs.wlopm}/bin/wlopm --off \"*\"";
        resumeCommand = "${pkgs.wlopm}/bin/wlopm --on \"*\"";
      }
    ];
    events = [
      {
        event = "before-sleep";
        command = "${pkgs.hyprlock}/bin/hyprlock";
      }
      {
        event = "lock";
        command = "${pkgs.hyprlock}/bin/hyprlock";
      }
    ];
  };
}
