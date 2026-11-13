{ ... }:
{
  programs.awscli = {
    enable = true;

    settings = {
      "sso-session axr" = {
        sso_start_url = "https://axr.awsapps.com/start";
        sso_region = "us-west-2";
        sso_registration_scopes = "sso:account:access";
      };

      default = {
        sso_session = "axr";
        sso_account_id = "088966585880";
        sso_role_name = "AdministratorAccess";
        region = "us-west-2";
        output = "json";
      };
    };
  };
}
