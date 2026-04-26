{ ... }:

{
  system.defaults = {
    dock = {
      autohide = true;
      orientation = "bottom";
      tilesize = 48;
      magnification = false;
      mineffect = "scale";
      show-recents = false;
      static-only = true;
      mru-spaces = false;
      expose-group-apps = true;
      wvous-br-corner = 14;
    };

    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      ShowPathbar = true;
      ShowStatusBar = true;
      FXPreferredViewStyle = "clmv";
      FXEnableExtensionChangeWarning = false;
      _FXShowPosixPathInTitle = true;
      CreateDesktop = false;
      QuitMenuItem = true;
      FXDefaultSearchScope = "SCcf";
      NewWindowTarget = "Home";
    };

    NSGlobalDomain = {
      ApplePressAndHoldEnabled = false;
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
      AppleInterfaceStyle = "Dark";
      AppleInterfaceStyleSwitchesAutomatically = false;
      AppleShowAllExtensions = true;
      AppleKeyboardUIMode = 3;
      AppleICUForce24HourTime = true;
      AppleTemperatureUnit = "Celsius";
      AppleMeasurementUnits = "Centimeters";
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSNavPanelExpandedStateForSaveMode = true;
      "com.apple.swipescrolldirection" = false;
      "com.apple.keyboard.fnState" = true;
    };

    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
      Dragging = false;
    };

    screencapture = {
      location = "~/Pictures/Screenshots";
      type = "png";
      disable-shadow = true;
      show-thumbnail = false;
    };

    LaunchServices.LSQuarantine = false;
    loginwindow = {
      GuestEnabled = false;
      SHOWFULLNAME = true;
    };
  };

  time.timeZone = "Asia/Tokyo";

  # Caps Lock → Control の OS レベル remap。
  # Karabiner-Elements を併用しているため、二重 remap や衝突の懸念がある。
  # 必要なら後段で有効化する。
  # system.keyboard = {
  #   enableKeyMapping = true;
  #   remapCapsLockToControl = true;
  # };
}
