-- UI DEFINITIONS FOR AUTO-REROLLER
local troC = TRO.UI.mod_colours
local Row, Col = TRO.UI.create_row, TRO.UI.create_column
local Text = TRO.UI.create_text_node
local TroUIBox = TRO.UI.create_UIBox_generic_options_custom

function TRO.UIDEF.auto_reroll_menu_UI()
  local display_menu = UIBox({ definition = TRO.UIDEF.reroll_targets_list("Current Targets:"), config = {type = "cm"}})
  return
    Col { align = "cm", padding = 0.15, minw = 5, nodes = {
      Row { align = "cm", padding = 0.1, r = 0.2, nodes = {
        Col { align = "cm", padding = 0.15, r = 0.2, minw = 5, colour = troC.inactive, emboss = 0.05, nodes = {
          Row { align = "cm", padding = 0.1, r = 0.2, nodes = {{ n = G.UIT.O, config = { id = 'TRO_targetsList', object = display_menu } }} },
          UIBox_button({button = 'TRO_clear_targets', label = {"Clear Targets"}, colour = G.C.FILTER, minw = 3, minh = 0.7, id = 'TRO_clear_targets_button'}),
          Row { align = "cm", padding = 0.1, r = 0.2, nodes = { Text{text = "Select cards to reroll for\n\tby clicking on them", scale = 0.3} } },
        }},
      }},
      Row { align = "cm", padding = 0.15, r = 0.2, nodes = {
        Col { align = "cm", padding = 0.15, r = 0.2, minw = 5, colour = darken(copy_table(G.C.GREY), 0.5), emboss = 0.05, nodes = {
          UIBox_button({button = 'TRO_view_options', label = {"Reroll Options"}, colour = G.C.FILTER, minw = 3, minh = 0.7, id = 'TRO_view_options_button'}),
          Row { nodes = { Text{text = "\t Start auto-reroll with\nShift+Right-Click on reroll button", scale = 0.28} } },
        }},
      }},
    }}
end

function TRO.UIDEF.reroll_targets_list(header)
  local display_list = TRO.UIDEF.get_display_list()
  table.insert(display_list.nodes, 1, Row { minh = 0.7, nodes = { Text { text = header, colour = G.C.UI.TEXT_LIGHT, scale = 0.5 } } })
  return TroUIBox{ minh = 0.0, minw = 0.0, bg_colour = troC.inactive, contents = { Row { r = 0.2, padding = 0.15, nodes = display_list.nodes } } }
end

function TRO.UIDEF.get_display_list()
  local display_list = Col { colour = G.C.GREY, nodes = { Row { nodes = { Col { colour = G.C.GREY, padding = 0.05, r = 0.2, nodes = {} } }} }}
  local default = Row { padding = 0.05, r = 0.2, minw = 3, nodes = { Text { padding = 0.05, text = '', colour = G.C.WHITE, scale = 0.4 } } }
  for i = 1, #TRO.collection_targets do
    local target = G.P_CENTERS[TRO.collection_targets[i]].name or G.P_CENTERS[TRO.collection_targets[i]].original_key
    target = string.gsub(target, '^%w', function(l) return l:upper() end)
    target = string.gsub(target, '_%w', function(l) return l:upper() end)
    table.insert(display_list.nodes[1].nodes[1].nodes, Row { padding = 0.05, r = 0.2, minw = 3,
      nodes = { Text { padding = 0.05, text = target, colour = G.C.WHITE, scale = 0.4 } } })
  end
  if not next(display_list.nodes[1].nodes[1].nodes) then table.insert(display_list.nodes[1].nodes[1].nodes, default) end
  return display_list
end

function TRO.UIDEF.added_key_UI()
  local target_textnode = Text { ref_table = TRO.UI.targets, ref_value = 'added_target', scale = 0.3 }
  local nodes = Row { padding = 0.15, r = 0.2, minh = 0.8, minw = 4, colour = troC.inactive, emboss = 0.05,
    nodes = {
      Text { text = "Search target added: ", align = "cm", colour = G.C.WHITE, shadow = true, scale = 0.3 },
      target_textnode
    }
  }
  local added_key_UI = Col { align = "cm", minw = 4.5, nodes = {nodes} }
  return added_key_UI
end

function TRO.FUNCS.get_type_collection_UIBox_func(set)
  local func
  if SMODS.ConsumableTypes[set] then
    func = SMODS.ConsumableTypes[set].create_UIBox_your_collection
  elseif set == 'Joker' then
    func = create_UIBox_your_collection_jokers
  end
  return func
end