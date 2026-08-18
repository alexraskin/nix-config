{
  config,
  pkgs,
  primaryUser,
  ...
}:
let
  keep = 14;

  nix-env = "${config.nix.package}/bin/nix-env";

  trim = pkgs.writeShellScript "nix-trim-generations" ''
    set -euo pipefail

    ${nix-env} --profile /nix/var/nix/profiles/system --delete-generations +${toString keep}

    hm=/Users/${primaryUser}/.local/state/nix/profiles/home-manager
    if [ -e "$hm" ]; then
      ${nix-env} --profile "$hm" --delete-generations +${toString keep}
    fi

    ${config.nix.package}/bin/nix-collect-garbage
  '';
in
{
  launchd.daemons.nix-trim-generations = {
    command = "${trim}";
    serviceConfig = {
      RunAtLoad = false;
      StartCalendarInterval = [
        {
          Weekday = 0;
          Hour = 3;
          Minute = 0;
        }
      ];
      StandardOutPath = "/var/log/nix-trim-generations.log";
      StandardErrorPath = "/var/log/nix-trim-generations.log";
    };
  };
}
