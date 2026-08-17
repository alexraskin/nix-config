{
  pkgs,
  primaryUser,
  hostname,
  ...
}:
{
  system.stateVersion = 6;

  networking = {
    computerName = hostname;
    hostName = hostname;
  };

  system.primaryUser = primaryUser;

  security.pam.services.sudo_local.touchIdAuth = true;

  programs.zsh.enable = true;

  users.users.${primaryUser} = {
    home = "/Users/${primaryUser}";
    shell = pkgs.zsh;
  };

  environment = {
    systemPath = [
      "/opt/homebrew/bin"
    ];
    pathsToLink = [ "/Applications" ];
  };
}
