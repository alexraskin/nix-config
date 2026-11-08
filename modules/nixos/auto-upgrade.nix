{ currentSystemName, ... }:
{
  # flake.lock is bumped weekly by .github/workflows/update-flake.yml, after CI builds it
  system.autoUpgrade = {
    enable = true;
    flake = "github:alexraskin/nix-config#${currentSystemName}";
    dates = "Mon 04:00";
    randomizedDelaySec = "45min";
    allowReboot = true;
    rebootWindow = {
      lower = "03:00";
      upper = "06:00";
    };
  };
}
