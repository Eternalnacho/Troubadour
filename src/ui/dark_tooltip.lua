local T = Troubadour.UI

-- DARK TOOLTIP UI DEFINITION
function Troubadour.UIDEF.dark_tooltip(tooltip)
  if type(tooltip) == 'function' then
    return T.Root{ nodes = {tooltip()} }
  end

  local nodes = {}
  local version_col = copy_table(G.C.WHITE); version_col[4] = 0.7

  local tooltip_text = {}
  if tooltip then
    localize{type = 'descriptions', set = 'Other', key = tooltip, nodes = tooltip_text, text_colour = version_col}
  end
  for _, v in ipairs(tooltip_text) do
    table.insert(nodes, { n = G.UIT.R, config = {align = 'cm'}, nodes = v })
  end

  return T.UIBox{
    r = 0.2, padding = 0.1, emboss = 0.1, minw = 0, minh = 0,
    outline = 1, outline_colour = T.C.outline_colour,
    bg_colour = mix_colours({0.5, 0.5, 0.5, 1}, T.C.colour, 0.5),
    contents =
    {
      T.Col { padding = 0.05, colour = G.C.CLEAR, nodes = {
        T.Row { r = 0.2, padding = 0.05, emboss = 0.05, colour = T.C.colour, nodes = {
          T.Col { r = 0.2, padding = 0.05, nodes = nodes }
        }}
      }}
    }
  }
end


-- UI ELEMENT HOOKS FOR DARK TOOLTIP
Troubadour.Hook('after', UIElement, 'set_values', function(self)
  if self.config.TRO_dark_tooltip then
    self.states.collide.can = true
  end
end)

Troubadour.Hook('before', UIElement, 'hover', function(self)
  if self.config and self.config.TRO_dark_tooltip then
    self.config.h_popup = Troubadour.UIDEF.dark_tooltip(self.config.TRO_dark_tooltip)
    self.config.h_popup_config = { align = "tm", offset = { x = 0, y = -0.1 }, parent = self }
  end
end)

Troubadour.Hook('before', UIElement, 'stop_hover', function(self)
  if self.config and self.config.TRO_dark_tooltip then
    self.config.h_popup = nil
  end
end)