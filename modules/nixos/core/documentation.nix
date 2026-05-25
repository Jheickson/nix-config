{ ... }:

{
  # Skip building NixOS option docs (options.json) — avoids the upstream
  # "builtins.derivation ... without a proper context" eval warning.
  documentation.enable = false;
  documentation.nixos.enable = false;
}
