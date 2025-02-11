{ pkgs, ... }:

{
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;

  };
  services = {

    httpd.enable = true;
    # httpd.adminAddr = "webmaster@example.org";
    httpd.enablePHP = true; # oof... not a great idea in my opinion
    httpd.adminAddr = "admin@admin.com"; # Set your admin email
    # httpd.documentRoot = "/var/www/html";  # Set your document root
    httpd.virtualHosts = { 
      "bar.example.com" = {
        # addSSL = true;
        documentRoot = "/var/www/bar.example.com";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    php
    phpactor
    php84Packages.composer
  ];

  networking.firewall.allowedTCPPorts = [ 80 ];
}
