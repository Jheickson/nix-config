{ config, pkgs, ... }:

{
  services.polybar = {
    enable = true;

    package = pkgs.polybar.override {
      i3Support = true;
      alsaSupport = true;
    };

    script = "polybar -q -r momiji & polybar -q -r momiji-secondary &";

    config = ./momiji/polybar.ini;
  };
}