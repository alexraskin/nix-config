{ ... }:
{
  system = {
    startup.chime = false;

    defaults = {
      NSGlobalDomain = {
        # No window open/close animations.
        NSAutomaticWindowAnimationsEnabled = false;

        # Show extensions everywhere, not just in Finder.
        AppleShowAllExtensions = true;

        # Scrollbars only while actually scrolling.
        AppleShowScrollBars = "WhenScrolling";

        # Save and print panels open in their expanded form.
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        PMPrintingExpandedStateForPrint = true;
        PMPrintingExpandedStateForPrint2 = true;

        # New documents save to disk, not iCloud.
        NSDocumentSaveNewDocumentsToCloud = false;

        # Tab, not just ⇥-to-text-field, moves between every control.
        AppleKeyboardUIMode = 3;
      };

      # Stage Manager / desktop behaviour. These already match what the machine
      # was set to by hand; declaring them keeps it that way after a migration.
      WindowManager = {
        # Hide desktop icons and widgets — AeroSpace owns the screen.
        StandardHideDesktopIcons = true;
        HideDesktop = true;
        StandardHideWidgets = true;
        StageManagerHideWidgets = true;

        # Clicking the wallpaper should not shove every window aside.
        EnableStandardClickToShowDesktop = false;

        # No margin between tiled windows.
        EnableTiledWindowMargins = false;
      };

      menuExtraClock = {
        Show24Hour = false;
        ShowAMPM = true;
        ShowDate = 1; # 1 = always show the date
        ShowDayOfWeek = false;
        ShowSeconds = false;
      };

      universalaccess = {
        reduceMotion = true;
        reduceTransparency = false;
      };

      CustomUserPreferences = {
        "com.apple.controlcenter" = {
          "NSStatusItem Visible NowPlaying" = false;
        };

        NSGlobalDomain = {
          # ISO dates in Finder columns and elsewhere.
          AppleICUDateFormatStrings = {
            "1" = "yyyy-MM-dd";
            "2" = "yyyy-MM-dd";
            "3" = "yyyy-MM-dd";
            "4" = "yyyy-MM-dd";
          };

          # No screen flash as a substitute for the alert sound.
          "com.apple.sound.beep.flash" = 0;
        };
      };
    };
  };
}
