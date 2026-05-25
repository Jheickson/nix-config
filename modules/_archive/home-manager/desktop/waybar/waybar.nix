{
  config,
  pkgs,
  lib,
  ...
}:

let
  # CHANGE THIS to switch between configs
  # Options: "top_mine" or "yagnikpt"
  selectedConfig = "yagnikpt";
  
  # Import the selected config's module
  configModule = import ./configs/${selectedConfig};
in
configModule { inherit config pkgs lib; }
