{ ... }:
# Per-app settings for the built-in apps, plus screenshots.
{
  system.defaults = {
    screencapture = {
      location = "~/Documents/Screencaps";
      type = "png";

      # No fake drop shadow baked into window captures.
      disable-shadow = true;
    };

    ActivityMonitor = {
      OpenMainWindow = true;

      # Dock icon shows live CPU usage.
      IconType = 5;

      # All processes, sorted by CPU descending.
      ShowCategory = 100;
      SortColumn = "CPUUsage";
      SortDirection = 0;
    };

    CustomUserPreferences = {
      "com.apple.TimeMachine".DoNotOfferNewDisksForBackup = true;

      "com.apple.TextEdit" = {
        # Plain text, UTF-8, always.
        RichText = 0;
        PlainTextEncoding = 4;
        PlainTextEncodingForWrite = 4;
      };

      # Plugging in a phone or camera shouldn't launch Photos.
      "com.apple.ImageCapture".disableHotPlug = true;

      # Crash dialogs offer "Report..." with the full backtrace.
      "com.apple.CrashReporter".DialogType = "developer";
    };
  };
}
