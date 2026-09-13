{ pkgs, lib, ... }:
{
  programs.mise = {
    enable = true;
    enableZshIntegration = true;

    globalConfig = {
      settings = {
        experimental = true;
        verbose = false;
        auto_install = true;
      };

      tools.node = "lts";
      tools.uv = "latest";
    };
  };

  home.activation.setupMise = lib.hm.dag.entryAfter [ "writeBoundary" ] "";
}
