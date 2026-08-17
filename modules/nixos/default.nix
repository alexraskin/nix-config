{
  pkgs,
  primaryUser,
  hostname,
  ...
}:
{
  imports = [
    ./home-manager.nix
  ];

  networking.hostName = hostname;

  programs.zsh.enable = true;

  users.users.${primaryUser} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

  # Pin this per host if a machine is installed from an older release.
  system.stateVersion = "25.05";
}
