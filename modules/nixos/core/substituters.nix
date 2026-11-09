{
  nix.settings = {
    substituters = [
      # high priority since it's almost always used
      "https://cache.nixos.org?priority=10"

      # "https://anyrun.cachix.org"
      # "https://chaotic-nyx.cachix.org/"
      # "https://fufexan.cachix.org"
      # "https://linuxmobile.cachix.org"
      "https://niri.cachix.org"
      "https://noctalia.cachix.org"
      "https://umbriel.cachix.org"
      "https://nix-community.cachix.org"
      # "https://nix-gaming.cachix.org"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="

      # "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
      # "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
      # "fufexan.cachix.org-1:LwCDjCJNJQf5XD2BV+yamQIMZfc9K53s7w8HPhURjq="
      # "linuxmobile.cachix.org-1:2K7KEjzbd3U+qMQRte/DGqttosw8EGgGVu8vKu8D6A="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOpNFQsBRglJzxWPp3dkU4="
      "umbriel.cachix.org-1:JfNq/2yg2S6D6z4Z2dVSZrZlDPQTKtexB6GAVLD98nw="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      # "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8CU54="
    ];
  };
}
