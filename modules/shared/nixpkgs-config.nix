{ inputs, pkgs, ... }:

{
  nixpkgs = {
    config = {
      allowUnfreePredicate = _: true;
      permittedInsecurePackages = [
        "googleearth-pro-7.3.6.10201"
        "xpdf-4.05"
        "python-2.7.18.12"
      ];
    };
    overlays = [
      (final: prev: {
        nvchad = inputs.nix4nvchad.packages.${pkgs.stdenv.hostPlatform.system}.nvchad;
      })
      # WORKAROUND: pyopenjtalk-plus 0.4.1-post9 asserts a pydantic v1
      # TypeError message ("must be str"); nixpkgs now ships pydantic v2,
      # which emits "Expected str, got int". The test fails and breaks
      # calibre → piper-tts → pyopenjtalk-plus. Deselect only that
      # message-assertion test; drop once fixed upstream.
      # Failing test: tests/test_frontend.py::test_run_njd_from_mecab_invalid_input_should_not_break_next_call
      (final: prev: {
        pythonPackagesExtensions =
          prev.pythonPackagesExtensions
          ++ [
            (python-final: python-prev: {
              pyopenjtalk-plus = python-prev.pyopenjtalk-plus.overridePythonAttrs (old: {
                disabledTests = (old.disabledTests or [ ]) ++ [
                  "test_run_njd_from_mecab_invalid_input_should_not_break_next_call"
                ];
              });
            })
          ];
        # WORKAROUND: calibre 9.16.0's test_speech_dispatcher does
        # `from speechd.client import SSIPClient`, but speechd-minimal
        # (libsOnly) ships no python client — only C libs. The test runs
        # whenever speechSupport=true yet its import can never succeed in
        # this packaging. Disable speech support (TTS via piper-tts stays;
        # only speech-dispatcher integration is dropped). nixpkgs itself
        # skips this test when speechSupport=false. Drop once fixed upstream.
        calibre = prev.calibre.override { speechSupport = false; };
      })
    ];
  };
}
