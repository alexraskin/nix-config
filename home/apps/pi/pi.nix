{ inputs, pkgs, ... }:
{
  home.packages = [ inputs.pi.packages.${pkgs.system}.coding-agent ];
}
