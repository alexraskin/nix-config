{ ... }:
# These mirror what the trackpad is already set to; declaring them means a
# rebuilt machine comes up feeling the same.
{
  system.defaults = {
    trackpad = {
      # Tap to click.
      Clicking = true;

      # Two-finger tap is the secondary click; no bottom-corner click zone.
      TrackpadRightClick = true;
      TrackpadCornerSecondaryClick = 0;

      # Lightest click pressure, no force-click detents.
      FirstClickThreshold = 1;
      SecondClickThreshold = 1;

      # Scrolling keeps its momentum after you lift off.
      TrackpadMomentumScroll = true;

      # Two-finger double-tap smart zoom.
      TrackpadTwoFingerDoubleTapGesture = true;

      # Two-finger swipe in from the right edge opens Notification Centre.
      TrackpadTwoFingerFromRightEdgeSwipeGesture = 3;
    };

    NSGlobalDomain = {
      # Tap to click, again, for the login screen and non-Multitouch paths.
      "com.apple.mouse.tapBehavior" = 1;
      "com.apple.trackpad.enableSecondaryClick" = true;
    };
  };
}
