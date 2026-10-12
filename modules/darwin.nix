# macOS-only system config (nix-darwin): users, Homebrew apps, system defaults, Dock, Colima.
{
  pkgs,
  lib,
  user,
  ...
}: let
  # Maccy is sandboxed, so its settings live in ~/Library/Containers/org.p0deje.Maccy, which
  # macOS only lets processes with Full Disk Access write to. They are applied best-effort in
  # postActivation below instead of CustomUserPreferences, where a refused write aborts the switch.
  maccySettings = {
    "NSStatusItem Visible Item-0" = false;
    "NSWindow Frame com.sindresorhus.Settings.FrameAutosaveName" = "514 394 500 388 0 0 1470 919";
    enabledPasteboardTypes = [
      "public.png"
      "public.html"
      "public.utf8-plain-text"
      "public.file-url"
      "public.rtf"
      "public.tiff"
    ];
    hideTitle = true;
    ignoreAllAppsExceptListed = false;
    ignoredPasteboardTypes = [];
    imageMaxHeight = 40;
    maxMenuItemLength = 50;
    maxMenuItems = 0;
    popupPosition = "center";
    popupScreen = 0;
    removeFormattingByDefault = true;
    searchMode = "fuzzy";
    showInStatusBar = false;
  };

  asUser = cmd: ''launchctl asuser "$(id -u -- ${user.name})" sudo --user=${user.name} -- ${cmd}'';
  writeMaccySetting = key: value:
    asUser "defaults write org.p0deje.Maccy ${lib.escapeShellArg key} ${lib.escapeShellArg (lib.generators.toPlist {escape = true;} value)}";
in {
  users.users.${user.name} = {
    home = "/Users/${user.name}";
  };

  environment.systemPackages = with pkgs; [
    mas
    colima
  ];

  # GUI apps come from Homebrew casks: macOS apps behave better installed in /Applications
  # than from the read-only Nix store. Homebrew itself must already be installed (https://brew.sh).
  homebrew = {
    enable = true;
    casks = [
      "google-chrome"
      "vlc"
      "libreoffice"
      "rectangle"
      "maccy"
    ];
    # masApps = {
    #   "Grocery" = 1195676848;
    #   "Spark Desktop" = 6445813049;
    #   "Things" = 904280696;
    #   "Bitwarden" = 1352778147;
    #   "AutoMounter" = 1160435653;
    #   "WireGuard" = 1451685025;
    # };
  };

  # App settings are written as the primary user (activation scripts run as root, so
  # `defaults write` there would only change root's preferences).
  # The Dock entries below need custom user preferences to set the Downloads and Documents folder
  # in order to save display settings for those folders in the dock. There is an open issue for this:
  # https://github.com/LnL7/nix-darwin/pull/1004
  system.defaults.CustomUserPreferences = {
    # Rectangle settings
    "com.knollsoft.Rectangle" = {
      SUEnableAutomaticChecks = false;
      SUHasLaunchedBefore = true;
      SULastCheckTime = "2024-12-17 19:35:05 +0000";
      SUUpdateGroupIdentifier = 3905483831;
      allowAnyShortcut = true;
      alternateDefaultShortcuts = false;
      hideMenubarIcon = true;
      internalTilingNotified = true;
      lastVersion = 91;
      subsequentExecutionMode = 0;

      bottomHalf = {
        keyCode = 125;
        modifierFlags = 786432;
      };
      leftHalf = {
        keyCode = 123;
        modifierFlags = 786432;
      };
      maximize = {
        keyCode = 36;
        modifierFlags = 786432;
      };
      nextDisplay = {
        keyCode = 124;
        modifierFlags = 1572864;
      };
      previousDisplay = {
        keyCode = 123;
        modifierFlags = 1572864;
      };
      reflowTodo = {
        keyCode = 45;
        modifierFlags = 786432;
      };
      rightHalf = {
        keyCode = 124;
        modifierFlags = 786432;
      };
      toggleTodo = {
        keyCode = 11;
        modifierFlags = 786432;
      };
      topHalf = {
        keyCode = 126;
        modifierFlags = 786432;
      };
    };

    "com.apple.dock" = {
      persistent-others = [
        {
          "tile-data" = {
            "file-data" = {
              "_CFURLString" = "/Users/${user.name}/Documents";
              "_CFURLStringType" = 0;
            };
            "arrangement" = 1; # Sort by: Name
            "displayas" = 2; # Stack View
            "showas" = 1; # Fan
          };
          "tile-type" = "directory-tile";
        }

        {
          "tile-data" = {
            "file-data" = {
              "_CFURLString" = "/Users/${user.name}/Downloads";
              "_CFURLStringType" = 0;
            };
            "arrangement" = 2; # Sort by: Date Added
            "displayas" = 2; # Stack View
            "showas" = 1; # Fan
          };
          "tile-type" = "directory-tile";
        }
      ];
    };
  };

  # Enable sudo touch id authentication for easier password entry
  security.pam.services.sudo_local.touchIdAuth = true;
  system.primaryUser = user.name;
  # macOS defaults and services
  system.defaults = {
    controlcenter = {
      BatteryShowPercentage = true;
      Sound = true;
    };

    finder = {
      AppleShowAllExtensions = true;
      FXPreferredViewStyle = "clmv";
      FXEnableExtensionChangeWarning = false;
      FXRemoveOldTrashItems = true;
      ShowHardDrivesOnDesktop = false;
      ShowExternalHardDrivesOnDesktop = false;
      ShowMountedServersOnDesktop = false;
      ShowPathbar = true;
    };

    dock = {
      persistent-apps = [
        # Browsers
        "/System/Cryptexes/App/System/Applications/Safari.app"
        # "${brave}/Applications/Brave Browser.app"
        "/Applications/Google Chrome.app"

        # Communication Apps
        "/System/Applications/FaceTime.app"
        "/System/Applications/Messages.app"
        "/Applications/Spark Desktop.app"
        "/Applications/Claude.app"

        # Productivity Tools
        "${pkgs.vscode}/Applications/Visual Studio Code.app"
        "${pkgs.kitty}/Applications/kitty.app"
        "/System/Applications/Calendar.app"
        "/Applications/Things3.app"

        # Media and Entertainment
        "/System/Applications/Music.app"
        "/System/Applications/Photos.app"
        "/System/Applications/TV.app"

        # Settings
        "/System/Applications/System Settings.app"
      ];
      show-recents = false;
    };

    screencapture.target = "clipboard";
    screensaver.askForPasswordDelay = 0;
  };

  # nix.settings.trusted-users = [
  #   "root"
  #   "${user.name}"
  # ];
  # Disable management since I am using determinate nix
  nix.enable = false;

  system.activationScripts.postActivation.text = ''
    echo >&2 "applying Maccy settings..."
    if ! { ${lib.concatStringsSep " && " (lib.mapAttrsToList writeMaccySetting maccySettings)}; } 2>/dev/null; then
      echo >&2 "warning: macOS refused to write Maccy's settings (it is a sandboxed app). Give your"
      echo >&2 "terminal Full Disk Access in System Settings > Privacy & Security, then rebuild."
    fi
  '';

  launchd.agents.colima = {
    # Run in the foreground so launchd supervises the VM; a plain `colima start`
    # exits once the VM is up, which made KeepAlive relaunch it every ~10s.
    script = ''
      exec ${pkgs.colima}/bin/colima start --foreground
    '';
    serviceConfig = {
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/tmp/colima-start.log";
      StandardErrorPath = "/tmp/colima-error.log";
    };
  };
}
