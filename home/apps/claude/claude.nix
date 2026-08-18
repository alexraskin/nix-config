{ ... }:
{
  programs.claude-code = {
    enable = true;

    # Pulls servers from programs.mcp.servers into Claude Code's MCP config.
    # Inert until that option actually has servers declared.
    enableMcpIntegration = true;

    settings = {
      model = "opus";
      theme = "dark-daltonized";
      tui = "fullscreen";

      includeCoAuthoredBy = false;
      attribution = {
        commit = "false";
        pr = "false";
        sessionUrl = false;
      };

      extraKnownMarketplaces = {
        unifi-plugins.source = {
          source = "github";
          repo = "sirkirby/unifi-mcp";
        };
      };

      enabledPlugins = {
        "unifi-network@unifi-plugins" = true;
      };
    };
  };
}
