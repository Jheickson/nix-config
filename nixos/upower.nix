{ config, pkgs, ... }:


{
  services.upower = {
    enable = true;

    percentageLow = 25;
    percentageCritical = 15;
    percentageAction = 5;
    criticalPowerAction = "HybridSleep";  # Options: PowerOff, Hibernate, HybridSleep, None

  };

  environment.systemPackages = with pkgs; [
    # Optional: Install tools for interacting with upower
    upower
  ];
}
