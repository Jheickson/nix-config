{ config, pkgs, ... }:

{
  nixpkgs.config = {
    android_sdk.accept_license = true;
  };

  environment.systemPackages = with pkgs; [
    android-studio
    clang
    cmake
    flutter
    ninja
    pkg-config
    libsecret.dev
    openjdk17
    androidenv.androidPkgs.androidsdk
  ];

  environment.variables = {
    JAVA_HOME = "${pkgs.openjdk17}";
    ANDROID_HOME = "${pkgs.androidenv.androidPkgs.androidsdk}/libexec/android-sdk";
  };

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
