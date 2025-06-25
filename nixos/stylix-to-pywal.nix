{ config, pkgs, lib, ... }:

let
  # Import your Stylix theme
  stylix = import ./stylix.nix { inherit pkgs lib; };

  # Build the Pywal-style JSON
  walJson = builtins.toJSON {
    special = {
      background = stylix.colors.bg0;
      foreground = stylix.colors.fg0;
      cursor     = stylix.colors.fg0;
    };
    colors = lib.listToAttrs (mapAttrs (_: col: {
      name  = toString _;
      value = col;
    }) stylix.colors.palette);
  };
in
{
  # Write out colors.json
  home.file.".cache/wal/colors.json" = {
    text = walJson;
    mode = "0644";
  };

  # (Optionally) export a shell‐sourceable colors.sh
  home.file.".cache/wal/colors.sh" = {
    text = lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: val:
        "export " + name + "=\"" + val + "\""
      ) stylix.colors.palette
    );
    mode = "0755";
  };
}
