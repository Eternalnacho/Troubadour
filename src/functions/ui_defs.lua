-- UI DEFINITIONS
TRO.UIDEF = {}

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
  local colour = mix_colours(G.C.UI.BACKGROUND_INACTIVE, {0, 0.1, 0.2, 1}, 0.8)
  local backdrop_colour = mix_colours({0.5, 0.5, 0.5, 1}, colour, 0.5)
  local outline_colour = mix_colours(colour, G.C.WHITE, 0.7)
  local version_col = copy_table(G.C.WHITE); version_col[4] = 0.7

  local tooltip_text = {}
  if tooltip then
    localize{type = 'descriptions', set = 'Other', key = tooltip, nodes = tooltip_text, text_colour = version_col}
  end
  for _, v in ipairs(tooltip_text) do
    table.insert(nodes, { n = G.UIT.R, config = {align = 'cm'}, nodes = v })
  end

  return {
    n = G.UIT.ROOT,
    config = {
      r = 0.2,
      padding = 0.1,
      emboss = 0.1,
      outline = 1,
      outline_colour = outline_colour,
      colour = backdrop_colour
    },
    nodes =
    {{
      n = G.UIT.C,
      config = { align = "bm", padding = 0.05, colour = G.C.CLEAR },
      nodes =
      {{
        n = G.UIT.R,
        config = { align = "cm", r = 0.2, padding = 0.05, emboss = 0.05, colour = colour },
        nodes = {{ n = G.UIT.C, config = { align = "cm", r = 0.2, padding = 0.05 }, nodes = nodes }}
      }}
    }}
  }
end

-- UI DEFINITIONS FOR AUTO-REROLLER
function TRO.UIDEF.auto_reroll_UI()
  local display_menu = UIBox({ definition = TRO.UIDEF.display_targets_list("Current Targets:"), config = {type = "cm"}})
  return TRO.UI.create_column({ align = "cm", padding = 0.15, minw = 5,
    nodes = {
      TRO.UI.create_row({ align = "cm", padding = 0.1, r = 0.2,
        nodes = {
          TRO.UI.create_column({ align = "cm", padding = 0.15, r = 0.2, minw = 5, colour = darken(copy_table(G.C.GREY), 0.5), emboss = 0.05,
            nodes = {
              TRO.UI.create_row({ align = "cm", padding = 0.1, r = 0.2,
                nodes = { { n = G.UIT.O, config = { id = 'TRO_targetsList', object = display_menu } } }
              }),
              UIBox_button({button = 'TRO_clear_targets', label = {"Clear Targets"}, colour = G.C.FILTER, minw = 3, minh = 0.7, id = 'TRO_clear_targets_button'}),
              TRO.UI.create_row({ align = "cm", padding = 0.1, r = 0.2,
                nodes = { TRO.UI.create_text_node({ text = "Select cards to reroll for\n\tby clicking on them", scale = 0.3 }) }
              }),
            }}),
        }}),
      TRO.UI.create_row({ align = "cm", padding = 0.15, r = 0.2,
        nodes = {
          TRO.UI.create_column({ align = "cm", padding = 0.15, r = 0.2, minw = 5, colour = darken(copy_table(G.C.GREY), 0.5), emboss = 0.05,
            nodes = {
              UIBox_button({button = 'TRO_view_options', label = {"Reroll Options"}, colour = G.C.FILTER, minw = 3, minh = 0.7, id = 'TRO_view_options_button'}),
              TRO.UI.create_row({ nodes = { TRO.UI.create_text_node({ text = "\t Start auto-reroll with\nShift+Right-Click on reroll button", scale = 0.28 }) } }),
            }}),
        }}),
    }})
end

function TRO.UIDEF.get_display_list()
  local display_list = { n = G.UIT.C, config = { align = "cm", colour = G.C.GREY }, nodes = {
    { n = G.UIT.R, config = { align = 'cm' }, nodes = {
      { n = G.UIT.C, config = { align = "cm", colour = G.C.GREY, padding = 0.05, r = 0.2 }, nodes = {}}
    } }
  } }
  local default = { n = G.UIT.R, config = { align = "cm", padding = 0.05, r = 0.2, minw = 3 }, nodes = {
      { n = G.UIT.T, config = { align = 'cm', padding = 0.05, text = '', colour = G.C.WHITE, scale = 0.4 } }
    } }
  for i = 1, #TRO.collection_targets do
    local target = G.P_CENTERS[TRO.collection_targets[i]].name or G.P_CENTERS[TRO.collection_targets[i]].original_key
    target = string.gsub(target, '^%w', function(l) return l:upper() end)
    target = string.gsub(target, '_%w', function(l) return l:upper() end)
    table.insert(display_list.nodes[1].nodes[1].nodes, TRO.UI.create_row({ align = "cm", padding = 0.05, r = 0.2, minw = 3,
      nodes = { TRO.UI.create_text_node({ align = 'cm', padding = 0.05, text = target, colour = G.C.WHITE, scale = 0.4 }) } }))
  end
  if not next(display_list.nodes[1].nodes[1].nodes) then table.insert(display_list.nodes[1].nodes[1].nodes, default) end
  return display_list
end

function TRO.UIDEF.display_targets_list(header)
  local display_list = TRO.UIDEF.get_display_list()
  table.insert(display_list.nodes, 1, { n = G.UIT.R, config = { align = "cm", minh = 0.7 }, nodes = {
    { n = G.UIT.T, config = { text = header, colour = G.C.UI.TEXT_LIGHT, scale = 0.5 } }
  }})
  return { n = G.UIT.ROOT, config = { align = "cm", colour = darken(copy_table(G.C.GREY), 0.5) } , nodes = {
     -- Use a Row node to arrange the contents in rows:
     { n = G.UIT.R, config = { align = "cm", r = 0.2, padding = 0.15 }, nodes = display_list.nodes }
  }}
end

function TRO.UIDEF.added_key_UI()
  local target_textnode = TRO.UI.create_text_node({ align = 'cm', ref_table = TRO.UI.targets, ref_value = 'added_target', scale = 0.3 })
  local nodes = TRO.UI.create_row({ align = "cm", padding = 0.15, r = 0.2, minh = 0.8, minw = 4, colour = darken(copy_table(G.C.GREY), 0.5), emboss = 0.05,
    nodes = { TRO.UI.create_text_node({ text = "Search target added: ", align = "cm", colour = G.C.WHITE, shadow = true, scale = 0.3 }), target_textnode } })
  local added_key_UI = TRO.UI.create_column({ align = "cm", minw = 4.5, nodes = {nodes} })
  return added_key_UI
end