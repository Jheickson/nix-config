{ config, pkgs, ... }:

{
  # O kernel bootado nao tem ip_tables legacy; o modo nft do waydroid-net
  # exige firewall nftables, que seleciona o pacote waydroid-nftables.
  networking.nftables.enable = true;
  virtualisation.waydroid.enable = true;

  environment.systemPackages = with pkgs; [
    waydroid
  ];

}
