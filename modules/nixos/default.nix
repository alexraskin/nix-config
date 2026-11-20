{
  inputs,
  pkgs,
  primaryUser,
  hostname,
  ...
}:
{
  imports = [
    ./auto-upgrade.nix
    ./home-manager.nix
    inputs.figurine-shell.nixosModules.default
  ];

  programs.figurine.enable = true;

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
