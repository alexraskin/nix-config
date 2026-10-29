{ lib, ... }:
{
  # Rex prepends REX_BIN_DIR to PATH, but nix-darwin's startup files rebuild
  # PATH afterwards, so put it back at the front once everything else has run.
  programs.zsh.initContent = lib.mkAfter ''
    if [[ -n $REX_BIN_DIR ]]; then
      path=("$REX_BIN_DIR" ''${path:#$REX_BIN_DIR})
    fi
  '';
}
