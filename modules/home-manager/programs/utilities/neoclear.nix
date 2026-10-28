{
  config,
  pkgs,
  lib,
  ...
}:

let
  colors = config.lib.stylix.colors;

  # Not in nixpkgs (upstream is a day old), so build the Codeberg source.
  # Zero dependencies (pure stdlib Rust), plain cargo build, no vendoring.
  neoclear = pkgs.stdenv.mkDerivation {
    pname = "neoclear";
    version = "0.1.0-unstable-2026-10-27";

    src = pkgs.fetchzip {
      url = "https://codeberg.org/ftranschel/neoclear/archive/7c5cb7d164e9113e31d43c87589e1d847e31815b42e21f4c750e1da7bc746186.tar.gz";
      hash = "sha256-lQMpG5Vt/3+xP2YpshntRlhA8EkFYNS1GQeYborCm70=";
    };

    nativeBuildInputs = with pkgs; [
      rustc
      cargo
    ];

    # No Cargo.lock upstream: build from a writable copy so cargo can emit
    # target/ + Cargo.lock (the unpacked source is read-only).
    buildPhase = ''
      runHook preBuild

      cp -a "$PWD" "$TMPDIR/build-src"
      chmod -R u+w "$TMPDIR/build-src"
      cd "$TMPDIR/build-src"

      export CARGO_HOME="$TMPDIR/cargo-home"
      mkdir -p "$CARGO_HOME"

      cargo build --release --offline --target-dir "$TMPDIR/build-target"

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      install -Dm755 "$TMPDIR/build-target/release/neoclear" -t $out/bin
      runHook postInstall
    '';

    meta = with lib; {
      description = "clear replacement that pours in braille-glyph streams, converges, fades and vanishes";
      homepage = "https://codeberg.org/ftranschel/neoclear";
      license = licenses.gpl3Plus;
      mainProgram = "neoclear";
      platforms = platforms.linux;
    };
  };
in
{
  home.packages = [ neoclear ];

  # Colorscheme-driven defaults; CLI flags still override per invocation.
  # `random` picks a different sweep direction every run.
  xdg.configFile."neoclear/config.toml".text = ''
    directions = "random"
    color = "#${colors.base0B}"
  '';

  programs.zsh = {
    shellAliases = {
      clear = "neoclear";
    };

    # Ctrl+L runs neoclear instead of the builtin clear-screen.
    # Ghostty passes ^L through to the shell, so no Ghostty keybind needed.
    initContent = lib.mkAfter ''
      custom_clear_widget() {
        neoclear
        zle redisplay
      }
      zle -N custom_clear_widget
      bindkey '^L' custom_clear_widget
    '';
  };
}
