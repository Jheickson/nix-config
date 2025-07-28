{ inputs, pkgs, ... }: let
  zenWithAudio = pkgs.symlinkJoin {
    name = "zen-browser-audio";
    paths = [inputs.zen-browser.packages."${pkgs.system}".default];
    buildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/zen \
        --set MOZ_ENABLE_WAYLAND 1 \
        --set XDG_RUNTIME_DIR "/run/user/$(id -u)" \
        --set PIPEWIRE_RUNTIME_DIR "/run/user/$(id -u)/pipewire-0" \
        --set PULSE_RUNTIME_PATH "/run/user/$(id -u)/pulse" \
        --set GST_PLUGIN_SYSTEM_PATH_1_0 "${pkgs.gst_all_1.gst-plugins-base}/lib/gstreamer-1.0:${pkgs.gst_all_1.gst-plugins-good}/lib/gstreamer-1.0" \
        --prefix PATH : ${pkgs.lib.makeBinPath [pkgs.pulseaudio pkgs.pipewire]} \
        --add-flags "--enable-features=WebRTCPipeWireCapturer" \
        --add-flags "--use-gl=egl" \
        --add-flags "--enable-webrtc-pipewire-capturer" \
        --add-flags "--enable-features=WebRTCPipeWireCapturer" \
        --add-flags "--enable-gpu-rasterization" \
        --add-flags "--enable-accelerated-video-decode" \
        --add-flags "--enable-accelerated-video-encode"
    '';
  };
in {
  home.packages = [zenWithAudio];
}
