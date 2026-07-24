{ pkgs, ... }:

{
  programs.chromium = {
    enable = true;

    # Wayland-native flags
    commandLineArgs = [
      "--enable-features=WebRTCPipeWireCapturer"
      "--ozone-platform-hint=auto"
      "--enable-gpu-rasterization"
      "--enable-accelerated-video-decode"
      "--enable-accelerated-video-encode"
    ];

    extensions = [];
  };
}
