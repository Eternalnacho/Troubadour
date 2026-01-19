-- DARK TOOLTIP UI DEFINITION
local troC = TRO.UI.mod_colours
local Row, Col = TRO.UI.create_row, TRO.UI.create_column
local TroUIBox = TRO.UI.create_UIBox_generic_options_custom

-- DO I SERIOUSLY HAVE TO HOOK *UIE FUNCTIONS* ?!
local uieSV = UIElement.set_values
function UIElement:set_values(...)
  uieSV(self, ...)
  if self.config.TRO_dark_tooltip or self.config.TRO_mods_tile then
    self.states.collide.can = true
  end
end

local uiehover = UIElement.hover
function UIElement:hover()
  if self.config and self.config.TRO_mods_tile then
    self.hovering = true
    local tag_sprite = self.children[1] and self.children[1].children and self.children[1].children[1].config.object
    if tag_sprite then
      tag_sprite:hover()
    end
  end
  if self.config and self.config.TRO_dark_tooltip then
    self.config.h_popup = TRO.UIDEF.dark_tooltip(self.config.TRO_dark_tooltip)
    self.config.h_popup_config = { align = "tm", offset = { x = 0, y = -0.1 }, parent = self }
  end
  uiehover(self)
end

local uiestophover = UIElement.stop_hover
function UIElement:stop_hover()
  uiestophover(self)
  if self.config and self.config.TRO_mods_tile then
    self.hovering = false
    local tag_sprite = self.children[1] and self.children[1].children and self.children[1].children[1].config.object
    if tag_sprite and tag_sprite.hovering and not tag_sprite.states.hover.is then
      self.children[1].children[1].config.object:stop_hover()
    end
  end
end

function TRO.UIDEF.dark_tooltip(tooltip)
  local nodes = {}
  local version_col = copy_table(G.C.WHITE); version_col[4] = 0.7

  local tooltip_text = {}
  if tooltip then
    localize{type = 'descriptions', set = 'Other', key = tooltip, nodes = tooltip_text, text_colour = version_col}
  end
  for _, v in ipairs(tooltip_text) do
    table.insert(nodes, { n = G.UIT.R, config = {align = 'cm'}, nodes = v })
  end

  return TroUIBox{
    r = 0.2, padding = 0.1, emboss = 0.1, minw = 0, minh = 0,
    outline = 1, outline_colour = troC.outline_colour,
    bg_colour = mix_colours({0.5, 0.5, 0.5, 1}, troC.colour, 0.5),
    contents =
    {
      Col { padding = 0.05, colour = G.C.CLEAR, nodes = {
        Row { r = 0.2, padding = 0.05, emboss = 0.05, colour = troC.colour, nodes = {
          Col { r = 0.2, padding = 0.05, nodes = nodes }
        }}
      }}
    }
  }
end