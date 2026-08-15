# omp — AI coding agent for the terminal (fork of Pi with IDE/harness batteries)
# Mirrors the noctalia pattern: the upstream flake's homeManagerModule provides
# the `programs.omp` options, wired in here so everything stays declarative.
{
  inputs,
  ...
}:
{
  imports = [
    inputs.omp.homeManagerModules.default
  ];

  programs.omp = {
    enable = true;
    # settings.startup.quiet = true;
  };
}