{ ... }:

{
  networking.networkmanager.enable = true;
  # Calibre wireless device connection (Kindle sync)
  networking.firewall.allowedTCPPorts = [ 9090 ];
}
