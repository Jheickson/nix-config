# /etc/nixos/postgresql.nix
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # 1) Enable Postgres
  services.postgresql = {
    enable = true;

    # (optional) force a specific major version; otherwise uses the default
    # package = pkgs.postgresql_14;

    # 2) Override its config to listen on port 5030
    settings = {
      port = 5030;
      # you can add more settings here, e.g.:
      # listen_addresses = "'*'";
    };
  };

  # 3) If you run the NixOS firewall, allow incoming TCP on 5030
  networking.firewall.allowedTCPPorts = lib.mkForce [ 5030 ];
}
