{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    nicotine-plus
  ];

  # Open ports for Nicotine+ file sharing
  # Default listening port: 2234 (TCP/UDP)
  # Distributed network port: 2235 (TCP/UDP)
  networking.firewall.allowedTCPPorts = [ 2234 2235 ];
  networking.firewall.allowedUDPPorts = [ 2234 2235 ];
}