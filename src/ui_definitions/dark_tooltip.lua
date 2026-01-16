-- DARK TOOLTIP UI DEFINITION
local troC = TRO.UI.mod_colours
local Row, Col = TRO.UI.create_row, TRO.UI.create_column
local TroUIBox = TRO.UI.create_UIBox_generic_options_custom

-- DO I SERIOUSLY HAVE TO HOOK *UIE FUNCTIONS* ?!
local uieSV = UIElement.set_values
function UIElement:set_values(...)
  uieSV(self, ...)
  if self.config.TRO_dark_tooltip then
    self.states.collide.can = true
  end
end
local uiehover = UIElement.hover
function UIElement:hover()
  if self.config and self.config.TRO_dark_tooltip then
    self.config.h_popup = TRO.UIDEF.dark_tooltip(self.config.TRO_dark_tooltip)
    self.config.h_popup_config = { align = "tm", offset = { x = 0, y = -0.1 }, parent = self }
  end
  uiehover(self)
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