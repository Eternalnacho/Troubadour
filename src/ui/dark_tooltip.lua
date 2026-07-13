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

  return T.UIBox (
    { -- Config
      minw = 0,
      minh = 0,
      r = 0.2,
      padding = 0.05,
      emboss = 0.1,
      outline = 0.8,
      outline_colour = mix_colours({0.6, 0.6, 0.6, 1}, T.C.colour, 0.5),
      bg_colour = T.C.colour,
    },
    { -- Contents
      T.Col ({ r = 0.2, emboss = 0.05, colour = T.C.colour }, { --[[contents]]
        T.Row (
          { padding = 0 },
          { T.Col ({ r = 0.2 }, nodes) }
        )
      })
    }
  )
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