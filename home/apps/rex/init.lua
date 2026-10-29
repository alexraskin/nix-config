-- Rex config. Docs: https://www.superlogical.com/rex/docs/customize/config
-- Apply changes with: rex config reload   (Rex does not watch this file)
-- Validate with:      rex config check ~/.config/rex/init.lua

-- Splits, matching Ghostty's defaults.
rex.bind("cmd+d", "pane.split", { direction = "right" })
rex.bind("shift+cmd+d", "pane.split", { direction = "down" })

-- Zoom the focused pane.
rex.bind("shift+cmd+enter", "pane.zoom")
