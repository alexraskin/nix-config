{ ... }:
{
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

  system.defaults.NSGlobalDomain = {
    # Fast repeat, short delay. Units are 16.67 ms ticks: 2 ≈ 30 ms repeat,
    # 15 ≈ 225 ms before repeating starts.
    KeyRepeat = 2;
    InitialKeyRepeat = 15;

    # Hold a key to repeat it instead of opening the accent picker.
    ApplePressAndHoldEnabled = false;

    # Every flavour of "helpful" text mangling, off.
    NSAutomaticSpellingCorrectionEnabled = false;
    NSAutomaticCapitalizationEnabled = false;
    NSAutomaticPeriodSubstitutionEnabled = false;
    NSAutomaticDashSubstitutionEnabled = false;
    NSAutomaticQuoteSubstitutionEnabled = false;
    NSAutomaticInlinePredictionEnabled = false;
  };
}
