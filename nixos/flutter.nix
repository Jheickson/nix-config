{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    android-studio
    clang
    cmake
    flutter
    ninja
    pkg-config
    libsecret
  ];

  programs = {
    adb.enable = true;
  };

  users.users.felipe = {
    extraGroups = [
      "adbusers"
    ];
  };

  system.userActivationScripts = {
    stdio = {
      text = ''
        rm -f ~/Android/Sdk/platform-tools/adb
        ln -s /run/current-system/sw/bin/adb ~/Android/Sdk/platform-tools/adb
      '';
      deps = [
      ];
    };
  };
}
