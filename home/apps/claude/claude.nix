{ ... }:
{
  programs.claude-code = {
    enable = true;

    # Pulls servers from programs.mcp.servers into Claude Code's MCP config.
    # Inert until that option actually has servers declared.
    enableMcpIntegration = true;

    # Written to ~/.claude/settings.json, read-only in the store. Changes made
    # from inside Claude Code (theme, model, plugin toggles) will not stick —
    # they belong here now.
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
