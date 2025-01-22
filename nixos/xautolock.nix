{ config, pkgs, ... }:


{

  services.xserver.xautolock = {

    enable = true;
    time = 10; # In minutes
    enableNotifier = true;

    notify = 10; #Time (in seconds) before the actual lock when the notification about the pending lock should be published.
    notifier = "${pkgs.libnotify}/bin/notify-send 'Locking in 10 seconds'";

  };

}
