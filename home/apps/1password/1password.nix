{
  pkgs,
  config,
  ...
}:
let
  inherit (pkgs.stdenv) isDarwin;

  opSshSign =
    if isDarwin then
      "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
    else
      "/opt/1Password/op-ssh-sign";
in
{
  # Point ssh at the 1Password agent instead of ssh-agent, so keys never
  # leave the vault. Requires Settings > Developer > "Use the SSH agent".
  home.sessionVariables.SSH_AUTH_SOCK =
    if isDarwin then
      "${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    else
      "${config.home.homeDirectory}/.1password/agent.sock";

  programs.git.settings = {
    gpg = {
      format = "ssh";
      ssh.program = opSshSign;
    };
    commit.gpgsign = true;
  };
}
