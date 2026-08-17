{ ... }:
{
  system.defaults.CustomUserPreferences = {
    "com.apple.SoftwareUpdate" = {
      AutomaticCheckEnabled = true;

      # Check daily rather than weekly.
      ScheduleFrequency = 1;

      # Download in the background, but don't install macOS itself unattended.
      AutomaticDownload = 1;

      # Security responses and XProtect definitions do install on their own.
      CriticalUpdateInstall = 1;
    };

    # App Store apps update themselves.
    "com.apple.commerce".AutoUpdate = true;
  };
}
