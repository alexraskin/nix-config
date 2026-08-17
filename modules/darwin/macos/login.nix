{ ... }:
{
  system.defaults = {
    loginwindow = {
      GuestEnabled = false;

      # No ">console" escape hatch at the login window.
      DisableConsoleAccess = true;

      # Name and password fields rather than a list of user icons.
      SHOWFULLNAME = true;
    };

    screensaver = {
      askForPassword = true;
      askForPasswordDelay = 300;
    };
  };
}
