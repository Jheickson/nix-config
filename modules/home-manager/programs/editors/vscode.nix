{ config, lib, pkgs, ... }:

let
  # Non-sensitive settings only.
  # Secrets (sshfs passwords, n8n API key) are excluded — restore them manually in
  # ~/.config/Code/User/settings.json after each rebuild, or add a local import.
in
{
  programs.vscode.enable = true;

  stylix.targets.vscode.enable = true;

  # Font settings are managed by Stylix (stylix.targets.vscode) — don't set
  # editor.fontFamily / editor.fontSize / terminal.integrated.fontFamily here
  # to avoid conflicts with Stylix's theme module.
  programs.vscode.profiles.default.userSettings = {
    "editor.guides.bracketPairs" = true;
    "editor.linkedEditing" = true;
    "editor.tabSize" = 2;
    "editor.formatOnSave" = true;
    "editor.formatOnSaveMode" = "modificationsIfAvailable";
    "editor.defaultFormatter" = "esbenp.prettier-vscode";
    "editor.wordWrap" = "on";
    "editor.renderWhitespace" = "none";
    "editor.autoClosingComments" = "always";
    "editor.minimap.renderCharacters" = false;
    "editor.minimap.size" = "fill";

    # colorTheme is managed by Stylix; make it the default for auto-switch too
    "workbench.preferredDarkColorTheme" = "Stylix";
    "workbench.preferredLightColorTheme" = "Stylix";
    "workbench.preferredHighContrastLightColorTheme" = "Stylix";
    "workbench.editorAssociations" = {
      "*.copilotmd" = "vscode.markdown.preview.editor";
      "*.pdf" = "latex-workshop-pdf-hook";
      "*.wrl" = "default";
    };
    "workbench.tree.expandMode" = "doubleClick";
    "workbench.tree.indent" = 12;
    "workbench.editor.highlightModifiedTabs" = true;
    "workbench.editor.titleScrollbarSizing" = "large";
    "workbench.activityBar.location" = "bottom";
    "workbench.sideBar.location" = "right";
    "workbench.editor.showTabs" = "none";
    "workbench.editor.editorActionsLocation" = "hidden";
    "workbench.statusBar.visible" = false;
    "workbench.startupEditor" = "none";
    "workbench.iconTheme" = "eq-material-theme-icons";
    "workbench.layoutControl.enabled" = false;
    "window.density.editorTabHeight" = "compact";
    "window.commandCenter" = false;
    "window.autoDetectColorScheme" = true;
    "window.menuBarVisibility" = "compact";

    "security.workspace.trust.untrustedFiles" = "open";

    "git.ignoreMissingGitWarning" = true;
    "git.autofetch" = true;
    "git.confirmSync" = false;
    "git.enableSmartCommit" = true;

    "terminal.integrated.fontFamily" = "monospace";
    "terminal.integrated.defaultProfile.linux" = "zsh";
    "terminal.integrated.env.linux" = {};
    "terminal.integrated.profiles.linux" = {
      "bash" = {
        "path" = "/run/current-system/sw/bin/bash";
        "icon" = "terminal-bash";
      };
      "zsh" = {
        "path" = "/home/felipe/.nix-profile/bin/zsh";
      };
      "fish" = {
        "path" = "fish";
      };
      "tmux" = {
        "path" = "tmux";
        "icon" = "terminal-tmux";
      };
      "pwsh" = {
        "path" = "pwsh";
        "icon" = "terminal-powershell";
      };
    };

    "files.exclude" = {
      "node_modules" = false;
      "out" = false;
      "LICENSE" = false;
      "code-workspace" = false;
    };

    "explorer.confirmDragAndDrop" = false;

    "settingsSync.ignoredSettings" = ["workbench.colorTheme"];

    "extensions.experimental.affinity" = {
      "asvetliakov.vscode-neovim" = 0;
    };

    "github.copilot.enable" = {
      "*" = true;
      "plaintext" = false;
      "markdown" = false;
      "scminput" = false;
    };
    "github.copilot.nextEditSuggestions.enabled" = true;
    "githubPullRequests.createOnPublishBranch" = "never";

    "gitlens.ai.experimental.provider" = "openai";
    "gitlens.ai.experimental.openai.model" = "gpt-3.5-turbo-1106";
    "gitlens.ai.model" = "openai:gpt-4o";
    "gitlens.views.contributors.showStatistics" = true;

    "chat.instructionsFilesLocations" = {
      ".github/instructions" = true;
      "/tmp/postman-collections-post-response.instructions.md" = true;
      "/tmp/postman-collections-pre-request.instructions.md" = true;
      "/tmp/postman-folder-post-response.instructions.md" = true;
      "/tmp/postman-folder-pre-request.instructions.md" = true;
      "/tmp/postman-http-request-post-response.instructions.md" = true;
      "/tmp/postman-http-request-pre-request.instructions.md" = true;
    };
    "chat.agent.maxRequests" = 50;
    "chat.mcp.autostart" = "newAndOutdated";
    "chat.mcp.gallery.enabled" = true;
    "chat.checkpoints.showFileChanges" = true;
    "chat.viewSessions.orientation" = "stacked";
    "chat.tools.terminal.autoApprove" = {
      "npm run build" = true;
      "npx tsc --noEmit" = {
        "approve" = true;
        "matchCommandLine" = true;
      };
      "sed" = true;
      "npm run lint 2>&1 | head -50" = {
        "approve" = true;
        "matchCommandLine" = true;
      };
      "sudo systemctl status jellyfin" = {
        "approve" = true;
        "matchCommandLine" = true;
      };
      "cd client && npm run lint" = {
        "approve" = true;
        "matchCommandLine" = true;
      };
      "npm run lint" = true;
      "bash -lc 'cd /home/felipe/UFOPA/amazonibus-web && npm run build'" = {
        "approve" = true;
        "matchCommandLine" = true;
      };
      "bash -lc \"cd /home/felipe/UFOPA/amazonibus-web && npm run build\"" = {
        "approve" = true;
        "matchCommandLine" = true;
      };
      "bash -lc \"cd /home/felipe/UFOPA/amazonibus-web && npm run build --silent\"" = {
        "approve" = true;
        "matchCommandLine" = true;
      };
      "bash -lc 'cd /home/felipe/UFOPA/amazonibus-web && npm run build --silent'" = {
        "approve" = true;
        "matchCommandLine" = true;
      };
      "/^php artisan test --compact --filter=BIFinanceiroControllerTest$/" = {
        "approve" = true;
        "matchCommandLine" = true;
      };
      "vendor/bin/pint" = true;
      "/^php artisan test --compact tests/Feature/CaixaAbertoTest\\.php$/" = {
        "approve" = true;
        "matchCommandLine" = true;
      };
      "/^php artisan test --compact tests/Feature/BIFinanceiroControllerTest\\.php$/" = {
        "approve" = true;
        "matchCommandLine" = true;
      };
      "/^php artisan test --compact --filter=\"additional textual categories\"$/" = {
        "approve" = true;
        "matchCommandLine" = true;
      };
      "/^php artisan test --compact tests/Feature/CaixaAbertoTest\\.php tests/Feature/BIFinanceiroControllerTest\\.php$/" = {
        "approve" = true;
        "matchCommandLine" = true;
      };
      "/^php artisan test --compact$/" = {
        "approve" = true;
        "matchCommandLine" = true;
      };
      "/^php artisan test --compact tests/Feature/Auth tests/Feature/Settings tests/Feature/ExampleTest\\.php$/" = {
        "approve" = true;
        "matchCommandLine" = true;
      };
      "/^php artisan test --compact tests/Feature/BIFinanceiroControllerTest\\.php tests/Feature/PactoControllerTest\\.php$/" = {
        "approve" = true;
        "matchCommandLine" = true;
      };
      "/^php artisan test --compact tests/Feature/PactoControllerTest\\.php$/" = {
        "approve" = true;
        "matchCommandLine" = true;
      };
      "npx prettier" = true;
      "/^php artisan test --compact tests/Feature/ContasPagarTest\\.php tests/Feature/ContasReceberTest\\.php tests/Feature/CaixaAbertoTest\\.php$/" = {
        "approve" = true;
        "matchCommandLine" = true;
      };
      "/^make validate$/" = {
        "approve" = true;
        "matchCommandLine" = true;
      };
      "/^make frontend-build$/" = {
        "approve" = true;
        "matchCommandLine" = true;
      };
    };
    "chat.tools.terminal.terminalProfile.linux" = {};
    "chat.tools.urls.autoApprove" = {
      "https://code.visualstudio.com" = true;
      "https://github.com/microsoft/vscode/wiki/*" = true;
      "https://github.com" = {
        "approveRequest" = false;
        "approveResponse" = true;
      };
      "https://raw.githubusercontent.com" = {
        "approveRequest" = false;
        "approveResponse" = true;
      };
      "https://docs.asaas.com" = true;
      "https://doc.evolution-api.com" = {
        "approveRequest" = true;
        "approveResponse" = false;
      };
    };
    "chat.emptyState.history.enabled" = true;

    "nix.serverPath" = "nixd";
    "nix.enableLanguageServer" = true;
    "nix.formatterPath" = "nixfmt";
    "nix.serverSettings" = {
      "nixd" = {
        "nixpkgs" = {
          "expr" = "let flake = builtins.getFlake \"/home/felipe/nix-config\"; in flake.inputs.nixpkgs.legacyPackages.x86_64-linux";
        };
        "options" = {
          "nixos" = {
            "expr" = "let flake = builtins.getFlake \"/home/felipe/nix-config\"; in flake.nixosConfigurations.nixos.options";
          };
          "home-manager" = {
            "expr" = "let flake = builtins.getFlake \"/home/felipe/nix-config\"; in flake.homeConfigurations.felipe.options";
          };
        };
        "formatting" = {
          "command" = ["nixfmt"];
        };
        "diagnostic" = {
          "suppress" = ["sema-escaping-with"];
        };
      };
    };

    "redhat.telemetry.enabled" = true;
    "sonarlint.rules" = {
      "php:S103" = {
        "level" = "off";
      };
      "java:S106" = {
        "level" = "off";
      };
    };
    "lldb.suppressUpdateNotifications" = true;
    "docker.extension.enableComposeLanguageServer" = false;
    "sqltools.useNodeRuntime" = true;
    "database-client.autoSync" = true;

    "zenMode.centerLayout" = false;
    "zenMode.fullScreen" = false;

    "diffEditor.ignoreTrimWhitespace" = false;

    "livePreview.notifyOnOpenLooseFile" = false;

    "bookmarks.sideBar.expanded" = true;

    # Language-specific formatters
    "[json]" = {
      "editor.defaultFormatter" = "vscode.json-language-features";
    };
    "[html]" = {
      "editor.defaultFormatter" = "vscode.html-language-features";
    };
    "[css]" = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
    };
    "[python]" = {
      "editor.formatOnType" = true;
    };
    "[javascript]" = {
      "editor.defaultFormatter" = "vscode.typescript-language-features";
    };
    "[javascriptreact]" = {
      "editor.defaultFormatter" = "vscode.typescript-language-features";
    };
    "[typescriptreact]" = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
    };
    "[typescript]" = {
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
    };
    "[nix]" = {
      "editor.defaultFormatter" = "jnoortheen.nix-ide";
    };
    "[php]" = {
      "editor.defaultFormatter" = "valeryanm.vscode-phpsab";
    };
    "[dockercompose]" = {
      "editor.insertSpaces" = true;
      "editor.tabSize" = 2;
      "editor.autoIndent" = "advanced";
      "editor.quickSuggestions" = {
        "other" = true;
        "comments" = false;
        "strings" = true;
      };
      "editor.defaultFormatter" = "redhat.vscode-yaml";
    };
    "[github-actions-workflow]" = {
      "editor.defaultFormatter" = "redhat.vscode-yaml";
    };
  };
}
