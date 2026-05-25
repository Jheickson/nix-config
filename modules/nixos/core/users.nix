{ pkgs, ... }:

{
  users = {
    defaultUserShell = pkgs.zsh;
    users.felipe = {
      isNormalUser = true;
      description = "felipe";
      extraGroups = [
        "networkmanager"
        "wheel"
        "docker"
        "audio"
        "video"
      ];
      packages = [ ];
    };
  };
}
