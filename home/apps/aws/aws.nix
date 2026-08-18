{ ... }:
{
  programs.awscli = {
    enable = true;

    settings.default = {
      region = "us-west-2";
      output = "json";
    };
  };
}
