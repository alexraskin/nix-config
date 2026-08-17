{ pkgs, ... }:
let
  # 1Password ships the SSH signing helper at a different path per platform.
  opSshSign =
    if pkgs.stdenv.isDarwin then
      "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
    else
      "/opt/1Password/op-ssh-sign";
in
{
  programs.git = {
    enable = true;

    lfs.enable = true;

    ignores = [
      ".DS_Store"
      "*.aux"
      "*.log"
      "*.out"
      "*.dvi"
      "*.fdb_latexmk"
      "*.fls"
      "**/auto/*.el"
      "*.bbl"
      "*.blg"
      "\\#*\\#"
      ".\\#*"
      "node_modules"
      "venv"
      ".vscode"
      "**/.claude/settings.local.json"
    ];

    attributes = [
      "* text=auto"
      "*.json diff=json"
      "*.md   diff=markdown"
      "*.png  binary"
      "*.jpg  binary"
      "*.pdf  binary"
    ];

    settings = {
      user = {
        name = "Alex Raskin";
        email = "alexraskin@fastmail.fm";
        signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFZ/ZjjWTINdBcOkNfdsnwMJxBsCpcgNvM4wxcBEXG/a";
      };
      alias = {
        co = "checkout";
        cleanup = "remote update --prune";
        ds = "diff --staged";
      };
      init = {
        defaultBranch = "main";
        templateDir = "~/.git-templates";
      };
      gpg = {
        format = "ssh";
        ssh.program = opSshSign;
      };
      commit.gpgsign = true;
      pull.rebase = true;
      github.user = "alexraskin";
    };
  };
}
