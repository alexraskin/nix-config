{ ... }:
let
  # rift is not in nixpkgs, so it comes from the author's tap. The formula
  # installs plain binaries (rift + rift-cli) into the Homebrew prefix.
  riftBin = "/opt/homebrew/bin/rift";
in
{
  # Merged with the lists in homebrew.nix. Kept here so the whole window
  # manager is one file, the way services.aerospace used to be.
  homebrew = {
    # Homebrew 6 refuses to load formulae from non-official taps unless they
    # are trusted; `trusted: true` puts that in the Brewfile so activation on a
    # fresh machine does not need a manual `brew trust`.
    taps = [
      {
        name = "acsandmann/tap";
        trusted = true;
      }
    ];
    brews = [ "rift" ];
  };

  # Equivalent of `rift service install`, but declarative. Mirrors the service
  # block in the formula: keep it alive, run it interactively so macOS does not
  # throttle a window manager.
  launchd.user.agents.rift = {
    command = riftBin;
    serviceConfig = {
      KeepAlive = true;
      RunAtLoad = true;
      ProcessType = "Interactive";
      StandardOutPath = "/tmp/rift.out.log";
      StandardErrorPath = "/tmp/rift.err.log";
      EnvironmentVariables = {
        PATH = "/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin";
        LANG = "en_US.UTF-8";
      };
    };
  };
}
