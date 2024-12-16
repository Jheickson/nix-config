{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    # Add Yazi to your Home Manager managed packages
    yazi
    
    # Optional: Dependencies for Yazi plugins
    ueberzugpp     # For image preview (alternative to ueberzug)
    zsh            # For Zsh integration
    bat            # For syntax-highlighted file previews
    ripgrep        # For file search functionality
    fd             # For efficient file listing
  ];

  # Configuration for Zsh integration (optional, required for Zsh plugin)
  # programs.zsh = {
  #   enable = true;
  #   interactiveShellInit = ''
  #     # Initialize Yazi zsh integration
  #     [ -f "$HOME/.config/yazi/shell/zsh.sh" ] && source "$HOME/.config/yazi/shell/zsh.sh"
  #   '';
  # };

  # Yazi configuration file setup
  home.file.".config/yazi/config.yml".text = ''
    # Yazi basic configuration
    plugins:
      - name: image-preview
        enable: true

      - name: zsh-integration
        enable: true

      - name: bat-preview
        enable: true
        config:
          command: "bat --color=always --style=numbers,grid"

      - name: ripgrep-integration
        enable: true
        config:
          command: "rg --files"

      - name: fd-integration
        enable: true
        config:
          command: "fd --type f"
  '';
}
