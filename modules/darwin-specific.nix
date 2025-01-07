{
  config,
  userName,
  pkgs,
  variables,
  ...
}:

{
  users.users."${userName}" = {
    home = "/Users/${userName}";
  };

  environment.systemPackages =
    with pkgs;
    if variables.isHeadless then
      [ ]
    else
      [
        mas
        rectangle
        maccy
        colima
        whatsapp-for-mac
        libreoffice-bin

      ];

  system.activationScripts.preActivation = {
    enable = true;
    text = ''
      # Set the settings for Rectangle
      defaults write com.knollsoft.Rectangle SUEnableAutomaticChecks -bool false
      defaults write com.knollsoft.Rectangle SUHasLaunchedBefore -bool true
      defaults write com.knollsoft.Rectangle SULastCheckTime -string "2024-12-17 19:35:05 +0000"
      defaults write com.knollsoft.Rectangle SUUpdateGroupIdentifier -int 3905483831
      defaults write com.knollsoft.Rectangle allowAnyShortcut -bool true
      defaults write com.knollsoft.Rectangle alternateDefaultShortcuts -bool false
      defaults write com.knollsoft.Rectangle hideMenubarIcon -bool true
      defaults write com.knollsoft.Rectangle internalTilingNotified -bool true
      defaults write com.knollsoft.Rectangle lastVersion -int 91
      defaults write com.knollsoft.Rectangle subsequentExecutionMode -int 0

      defaults write com.knollsoft.Rectangle bottomHalf -dict keyCode -int 125 modifierFlags -int 786432
      defaults write com.knollsoft.Rectangle leftHalf -dict keyCode -int 123 modifierFlags -int 786432
      defaults write com.knollsoft.Rectangle maximize -dict keyCode -int 36 modifierFlags -int 786432
      defaults write com.knollsoft.Rectangle nextDisplay -dict keyCode -int 124 modifierFlags -int 1572864
      defaults write com.knollsoft.Rectangle previousDisplay -dict keyCode -int 123 modifierFlags -int 1572864
      defaults write com.knollsoft.Rectangle reflowTodo -dict keyCode -int 45 modifierFlags -int 786432
      defaults write com.knollsoft.Rectangle rightHalf -dict keyCode -int 124 modifierFlags -int 786432
      defaults write com.knollsoft.Rectangle toggleTodo -dict keyCode -int 11 modifierFlags -int 786432
      defaults write com.knollsoft.Rectangle topHalf -dict keyCode -int 126 modifierFlags -int 786432


      # Set the settings for Maccy
      defaults write org.p0deje.Maccy "NSStatusItem Visible Item-0" -bool false
      defaults write org.p0deje.Maccy "NSWindow Frame com.sindresorhus.Settings.FrameAutosaveName" -string "514 394 500 388 0 0 1470 919"
      defaults write org.p0deje.Maccy enabledPasteboardTypes -array \
        "public.png" \
        "public.html" \
        "public.utf8-plain-text" \
        "public.file-url" \
        "public.rtf" \
        "public.tiff"
      defaults write org.p0deje.Maccy hideTitle -bool true
      defaults write org.p0deje.Maccy ignoreAllAppsExceptListed -bool false
      defaults write org.p0deje.Maccy ignoredPasteboardTypes -array
      defaults write org.p0deje.Maccy imageMaxHeight -int 40
      defaults write org.p0deje.Maccy maxMenuItemLength -int 50
      defaults write org.p0deje.Maccy maxMenuItems -int 0
      defaults write org.p0deje.Maccy popupPosition -string "center"
      defaults write org.p0deje.Maccy popupScreen -int 0
      defaults write org.p0deje.Maccy removeFormattingByDefault -bool true
      defaults write org.p0deje.Maccy searchMode -string "fuzzy"
      defaults write org.p0deje.Maccy showInStatusBar -bool false
    '';
  };

  # Try to install apps from the app store after the user has been activated
  system.activationScripts.postUserActivation = {
    enable = true;
    text = ''
      #!${pkgs.bash}/bin/bash
      set -e

      install_app_if_missing() {
        local app_id=$1
        local app_name=$2

        if ! mas list | grep -q "^''${app_id} "; then
          echo "Mas: Installing ''${app_name}..."
          mas install "''${app_id}"
        else
          echo "Mas: ''${app_name} is already installed."
        fi
      }

      # Install apps
      install_app_if_missing 1195676848 "Grocery"
      install_app_if_missing 6445813049 "Spark Desktop"
      install_app_if_missing 904280696 "Things"
      install_app_if_missing 1352778147 "Bitwarden"
    '';
  };

  # Need to use this custom user preferences to set the Downloads and Documents folder in the dock
  # in order to save display settings for those folders in the dock. There is an open issue for this:
  # https://github.com/LnL7/nix-darwin/pull/1004
  system.defaults.CustomUserPreferences = {
    "com.apple.dock" = {
      persistent-others = [
        {
          "tile-data" = {
            "file-data" = {
              "_CFURLString" = "/Users/${userName}/Documents";
              "_CFURLStringType" = 0;
            };
            "arrangement" = 2; # Sort by: Date Added
            "displayas" = 2; # Stack View
            "showas" = 1; # Fan
          };
          "tile-type" = "directory-tile";
        }

        {
          "tile-data" = {
            "file-data" = {
              "_CFURLString" = "/Users/${userName}/Downloads";
              "_CFURLStringType" = 0;
            };
            "arrangement" = 1; # Sort by: Name
            "displayas" = 2; # Stack View
            "showas" = 1; # Fan
          };
          "tile-type" = "directory-tile";
        }

      ];
    };
  };

  system.stateVersion = 5;

  # Enable sudo touch id authentication for easier password entry
  security.pam.enableSudoTouchIdAuth = true;

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
      persistent-apps = with pkgs; [
        # Browsers
        "/System/Cryptexes/App/System/Applications/Safari.app"
        "${brave}/Applications/Brave Browser.app"
        "${google-chrome}/Applications/Google Chrome.app"

        # Communication Apps
        "/System/Applications/FaceTime.app"
        "/System/Applications/Messages.app"
        "${signal-desktop}/Applications/Signal.app"
        "${whatsapp-for-mac}/Applications/WhatsApp.app"
        "/Applications/Spark Desktop.app"
        "/Applications/ChatGPT.app"

        # Productivity Tools
        "${vscode}/Applications/Visual Studio Code.app"
        "${kitty}/Applications/kitty.app"
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

    screencapture.location = "~/Pictures/screenshots";
    screensaver.askForPasswordDelay = 0;
  };

  launchd.daemons.colima = {
    script = ''
      ${pkgs.colima}/bin/colima start --auto-start
    '';
    serviceConfig = {
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/tmp/colima-start.log";
      StandardErrorPath = "/tmp/colima-error.log";
    };
  };
}
