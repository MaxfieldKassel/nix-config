{
  config,
  userName,
  pkgs,
  ...
}:

{
  users.users."${userName}" = {
    home = "/Users/${userName}";
  };

  environment.systemPackages = with pkgs; [
    rectangle
    maccy
    colima
    whatsapp-for-mac
    libreoffice-bin
  ];

  system.activationScripts.rectangleDefaults = ''
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
  '';

  system.activationScripts.maccyDefaults = ''
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
        "${firefox-unwrapped}/Applications/Firefox.app"
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

      # Shows these folders in the tool bar.
      persistent-others = [
        "/Users/${userName}/Documents"
        "/Users/${userName}/Downloads"
      ];
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
