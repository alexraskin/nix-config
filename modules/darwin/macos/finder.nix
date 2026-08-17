{ ... }:
{
  system.defaults = {
    finder = {
      AppleShowAllFiles = true;
      AppleShowAllExtensions = true;
      _FXShowPosixPathInTitle = true;
      ShowPathbar = true;
      ShowStatusBar = true;
      FXPreferredViewStyle = "Nlsv"; # list view

      # Search the folder you're standing in, not the whole Mac.
      FXDefaultSearchScope = "SCcf";

      # Renaming a .txt to .md shouldn't need a confirmation sheet.
      FXEnableExtensionChangeWarning = false;

      # Folders before files when sorting by name.
      _FXSortFoldersFirst = true;
      _FXSortFoldersFirstOnDesktop = true;

      # Column view sizes itself to the longest filename.
      _FXEnableColumnAutoSizing = true;

      # New windows open at $HOME.
      NewWindowTarget = "Home";

      # Desktop clutter: internal drives stay hidden, removable ones show up
      # so you notice a mounted volume before ejecting it.
      ShowHardDrivesOnDesktop = false;
      ShowExternalHardDrivesOnDesktop = true;
      ShowRemovableMediaOnDesktop = true;
      ShowMountedServersOnDesktop = false;
    };

    CustomUserPreferences = {
      "com.apple.finder" = {
        WarnOnEmptyTrash = false;
        DisableAllAnimations = true;

        # Text is selectable in Quick Look previews.
        QLEnableTextSelection = true;

        # ⌘-double-click opens a new window rather than a tab.
        FinderSpawnTab = false;
      };

      "com.apple.desktopservices" = {
        # Don't litter .DS_Store on network shares or USB sticks.
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };

      NSGlobalDomain = {
        # Spring-loaded folders: hover a folder while dragging to open it.
        "com.apple.springing.enabled" = 1;
        "com.apple.springing.delay" = "0.5";
      };
    };
  };
}
