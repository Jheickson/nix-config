{ config, pkgs, ... }:

{
  services.upower = {
    enable = true;

    percentageLow = 20;
    percentageCritical = 10;
    percentageAction = 5;
    criticalPowerAction = "HybridSleep"; # Options: PowerOff, Hibernate, HybridSleep, None

  };

  environment.systemPackages = with pkgs; [
    # Optional: Install tools for interacting with upower
    upower
  ];
}
