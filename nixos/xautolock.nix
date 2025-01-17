{ config, pkgs, ... }:


{

  services.xserver.xautolock = {

    enable = true;
    time = 10; # In minutes
    enableNotifier = true;
    notifier = true;

  }

}
