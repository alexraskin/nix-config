{
  inputs,
  self,
  primaryUser,
  currentSystemName,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-bak";
    users.${primaryUser}.imports = [ ../../home/headless.nix ];
    extraSpecialArgs = {
      inherit
        inputs
        self
        primaryUser
        currentSystemName
        ;
    };
  };
}
