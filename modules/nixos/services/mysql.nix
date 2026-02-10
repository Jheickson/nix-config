{ config, pkgs, ... }:

{
  # 1) Enable MariaDB (MySQL) service
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    # Automatically run this SQL script when the database is first initialized:
    initialScript = "/etc/nixos/aluga_banco.sql";
    # (only runs if the data directory is empty)
  };

  # 2) Your existing HTTPD/PHP config, now using flat attribute paths
  services.httpd = {
    enable = true;
    enablePHP = true;
    adminAddr = "admin@admin.com";
    virtualHosts = {
      "bar.example.com" = {
        documentRoot = "/var/www/bar.example.com";
      };
    };
  };

  # 3) Add your PHP tooling to the system path
  environment.systemPackages = with pkgs; [
    php
    phpactor
    php84Packages.composer
  ];

  # 4) Open port 80 in the firewall
  networking.firewall.allowedTCPPorts = [
    80
    3306
  ];
}
