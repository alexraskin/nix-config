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

  system.stateVersion = "25.05";
}
