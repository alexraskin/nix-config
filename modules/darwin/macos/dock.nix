{ ... }:
# Dock behaviour only. The actual list of pinned apps is per-machine and lives
# in hosts/<host>/dock.nix.
{
  system.defaults.dock = {
    autohide = true;
    show-recents = false;

    # No bounce-on-launch animation.
    launchanim = false;

    # Group a Mission Control by app rather than scattering windows.
    expose-group-apps = true;

    # Don't reorder spaces behind AeroSpace's back.
    mru-spaces = false;

    # Minimize into the app icon instead of a separate Dock slot.
    minimize-to-application = true;

    # Dim the icons of hidden apps.
    showhidden = true;
  };
}
