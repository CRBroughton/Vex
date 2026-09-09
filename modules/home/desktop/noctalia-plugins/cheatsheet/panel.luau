--!nonstrict
-- Vex keybind cheatsheet — a static, scrollable reference panel.
-- Content mirrors modules/home/desktop/niri.nix's `binds` block; keep them
-- in sync when binds change.

local sections = {
  {
    title = "Apps",
    binds = {
      { key = "Mod+Return / Mod+T", action = "Open a terminal (foot)" },
      { key = "Mod+D", action = "Open the app launcher (rofi)" },
      { key = "Mod+Slash", action = "Open this cheatsheet" },
    },
  },
  {
    title = "Focus",
    binds = {
      { key = "Mod+Left / Mod+H", action = "Focus column left" },
      { key = "Mod+Right / Mod+L", action = "Focus column right" },
      { key = "Mod+Down / Mod+J", action = "Focus window down" },
      { key = "Mod+Up / Mod+K", action = "Focus window up" },
      { key = "Mod+Page_Down", action = "Focus workspace below" },
      { key = "Mod+Page_Up", action = "Focus workspace above" },
    },
  },
  {
    title = "Move",
    binds = {
      { key = "Mod+Ctrl+Left / Right", action = "Move column left / right" },
      { key = "Mod+Ctrl+Down / Up", action = "Move window down / up" },
      { key = "Mod+Ctrl+Page_Down / Up", action = "Move column to workspace below / above" },
    },
  },
  {
    title = "Sizing",
    binds = {
      { key = "Mod+R", action = "Cycle preset column widths" },
      { key = "Mod+Ctrl+Shift+R", action = "Cycle preset window heights" },
      { key = "Mod+Minus / Equal", action = "Shrink / grow column width 10%" },
      { key = "Mod+Shift+Minus / Equal", action = "Shrink / grow window height 10%" },
    },
  },
  {
    title = "Window state",
    binds = {
      { key = "Mod+V", action = "Toggle floating" },
      { key = "Mod+Shift+V", action = "Switch focus between floating and tiling" },
      { key = "Mod+F", action = "Maximize column" },
      { key = "Mod+Shift+F", action = "Fullscreen window" },
      { key = "Mod+O", action = "Toggle overview" },
    },
  },
  {
    title = "Screenshots",
    binds = {
      { key = "Print", action = "Screenshot (area picker)" },
      { key = "Ctrl+Print", action = "Screenshot screen" },
      { key = "Alt+Print", action = "Screenshot window" },
    },
  },
  {
    title = "Session",
    binds = {
      { key = "Mod+Q", action = "Close window" },
      { key = "Mod+Shift+E", action = "Quit niri" },
    },
  },
}

local function bindRow(bind)
  return ui.row({ key = bind.key, justify = "space_between", align = "center" }, {
    ui.label({ text = bind.action, color = "on_surface", flexGrow = 1 }),
    ui.label({ text = bind.key, color = "primary", fontWeight = "medium" }),
  })
end

local function section(entry)
  local rows = { ui.label({ text = entry.title, fontWeight = "bold", color = "on_surface_variant" }) }
  for _, bind in ipairs(entry.binds) do
    table.insert(rows, bindRow(bind))
  end
  return ui.column({ key = entry.title, gap = 8 }, rows)
end

local function render()
  local body = {}
  for _, entry in ipairs(sections) do
    table.insert(body, section(entry))
  end

  panel.render(ui.column({ flexGrow = 1, gap = 16 }, {
    ui.row({ align = "center", justify = "space_between", gap = 8 }, {
      ui.label({ text = "Vex Cheatsheet", fontSize = 16, fontWeight = "bold", color = "on_surface", flexGrow = 1 }),
      ui.button({ glyph = "close", onClick = "onCloseClicked" }),
    }),
    ui.scroll({ flexGrow = 1, gap = 20 }, body),
  }))
end

function onOpen(_context)
  render()
end

function onCloseClicked()
  panel.close()
end
