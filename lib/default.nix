{ inputs, self, ... }:
let
  root = ../.;

  mkSpecialArgs =
    name:
    {
      user,
      hostname,
      ...
    }:
    {
      inherit inputs self hostname;
      currentSystemName = name;
      primaryUser = user;
    };

  hostModule = name: root + "/hosts/${name}";
in
{
  mkDarwin =
    name:
    args@{
      system,
      user,
      hostname,
    }:
    inputs.darwin.lib.darwinSystem {
      inherit system;
      specialArgs = mkSpecialArgs name args;
      modules = [
        ../modules/shared
        ../modules/darwin
        (hostModule name)
      ];
    };

  mkNixos =
    name:
    args@{
      system,
      user,
      hostname,
    }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = mkSpecialArgs name args;
      modules = [
        ../modules/shared
        ../modules/nixos
        (hostModule name)
      ];
    };
}
