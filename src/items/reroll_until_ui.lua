-- -- UI FEATURES FOR AUTO-REROLL
function TRO.UI.auto_reroll_UI()
  local display_menu = UIBox({ definition = TRO.UI.display_targets_list("Current Targets:"), config = {type = "cm"}})
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
            }}),
        }}),
    }})
end

function TRO.UI.get_display_list()
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

function TRO.UI.display_targets_list(header)
  local display_list = TRO.UI.get_display_list()
  table.insert(display_list.nodes, 1, { n = G.UIT.R, config = { align = "cm", minh = 0.7 }, nodes = {
    { n = G.UIT.T, config = { text = header, colour = G.C.UI.TEXT_LIGHT, scale = 0.5 } }
  }})
  return { n = G.UIT.ROOT, config = { align = "cm", colour = darken(copy_table(G.C.GREY), 0.5) } , nodes = {
     -- Use a Row node to arrange the contents in rows:
     { n = G.UIT.R, config = { align = "cm", r = 0.2, padding = 0.15 }, nodes = display_list.nodes }
  }}
end

function TRO.UI.added_key_UI()
  local target_textnode = TRO.UI.create_text_node({ align = 'cm', ref_table = TRO.UI.targets, ref_value = 'added_target', scale = 0.3 })
  local nodes = TRO.UI.create_row({ align = "cm", padding = 0.15, r = 0.2, minh = 0.8, minw = 4, colour = darken(copy_table(G.C.GREY), 0.5), emboss = 0.05,
    nodes = { TRO.UI.create_text_node({ text = "Search target added: ", align = "cm", colour = G.C.WHITE, shadow = true, scale = 0.3 }), target_textnode } })
  local added_key_UI = TRO.UI.create_column({ align = "cm", minw = 4.5, nodes = {nodes} })
  return added_key_UI
end

function TRO.UI.get_type_collection_UIBox_func(set)
  local func
  if SMODS.ConsumableTypes[set] then
    func = SMODS.ConsumableTypes[set].create_UIBox_your_collection
  elseif set == 'Joker' then
    func = TRO.UI.create_UIBox_your_collection_jokers
  end
  return func
end

function TRO.UI.rerender_collection(set)
  G.E_MANAGER:add_event(Event({
    func = function()
      TRO.UI.get_page_num, TRO.UI.rerendering = false, true
      TRO.UI.rerender(TRO.UI.get_type_collection_UIBox_func(set), true, set)
      TRO.UI.get_page_num, TRO.UI.rerendering = true, false
      return true
    end,
  }))
end

function G.FUNCS.TRO_view_options(e)
  G.SETTINGS.paused = true
  TRO.config_from_coll = true
  TRO.in_collection = false
  G.FUNCS.overlay_menu{ definition = TRO.UI.config_from_coll() }
  G.OVERLAY_MENU:recalculate()
end

function TRO.UI.config_from_coll()
  return create_UIBox_generic_options({
    colour = G.C.BLACK,
    back_func = 'your_collection',
    contents = SMODS.Mods["Troubadour"].config_tab().nodes})
end

-- This one is for the auto-reroller
function TRO.UI.create_UIBox_your_collection_jokers()
  local w = tro_config.gallery_width * 10 % 10 < 5 and math.floor(tro_config.gallery_width) or math.ceil(tro_config.gallery_width)
  local h = tro_config.gallery_height * 10 % 10 < 5 and math.floor(tro_config.gallery_height) or math.ceil(tro_config.gallery_height)
  local area = {}; for _ = 1, h do area[#area+1] = w end
  return SMODS.card_collection_UIBox(G.P_CENTER_POOLS.Joker, area, {
      no_materialize = true,
      modify_card = function(card, center) card.sticker = get_joker_win_sticker(center) end,
      h_mod = 0.95 * (3 / h),
      card_scale = 1 - (h / 100),
  })
end


function TRO.UI.reset_ui_states()
  TRO.in_collection = false
  TRO.config_from_coll = nil
  TRO.UI.targets.added_target = ''
  TRO.UI.get_page_num = true
end