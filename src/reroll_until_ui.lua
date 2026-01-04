-- -- UI FEATURES FOR AUTO-REROLL
function TRO.UI.auto_reroll_UI()
  return TRO.UI.create_column({ align = "cm", padding = 0.15, minw = 5,
    nodes = {
      TRO.UI.create_row({ align = "cm", padding = 0.1, r = 0.2,
        nodes = {
          TRO.UI.create_column({ align = "cm", padding = 0.15, r = 0.2, minw = 5, colour = darken(copy_table(G.C.GREY), 0.5), emboss = 0.05,
            nodes = {
              TRO.UI.create_row({ align = "cm", padding = 0.1, r = 0.2,
                nodes = { TRO.UI.create_text_node({ align = 'cm', text = "Current Targets:", scale = 0.4}) }
              }),
              TRO.UI.create_row({ align = 'cm',
                nodes = {
                  TRO.UI.create_column({
                    r = 0.1,
                    align = "cm",
                    colour = G.C.GREY,
                    emboss = 0.05,
                    nodes = TRO.UI.display_list(),
                  })
                }
              }),
              UIBox_button({button = 'TRO_clear_targets', label = {"Clear Targets"}, colour = G.C.FILTER, minw = 3, minh = 0.7, id = 'TRO_clear_targets_button'}),
              TRO.UI.create_row({ align = "cm", padding = 0.1, r = 0.2,
                nodes = { TRO.UI.create_text_node({ text = "Select cards to reroll for\n\tby clicking on them", scale = 0.3 }) }
              }),
            }}),
        }}),
    }})
end

function TRO.UI.display_list()
  local display_list = {}
  for i = 1, #TRO.collection_targets do
    local target = G.P_CENTERS[TRO.collection_targets[i]].name or G.P_CENTERS[TRO.collection_targets[i]].original_key
    target = string.gsub(target, '^%w', function(l) return l:upper() end)
    display_list[#display_list+1] = TRO.UI.create_row({ align = "cm", padding = 0.1, r = 0.2, minw = 3,
      nodes = { TRO.UI.create_text_node({align = 'cm', padding = 0.1, text = target, scale = 0.4}) }})
  end
  return next(display_list) and display_list or {TRO.UI.create_row({align = "cm", padding = 0.1, r = 0.2, minw = 3})}
end

-- Stole these from Handy
function TRO.UI.rerender(def, set, silent)
  local result
  if set then
    result = { definition = def(SMODS.ConsumableTypes[set]) }
  else
    result = { definition = def() }
  end
  if silent then
    G.ROOM.jiggle = G.ROOM.jiggle - 1
    result.config = {
      offset = {
        x = 0,
        y = 0,
      },
    }
  end
  G.FUNCS.overlay_menu(result)
  G.OVERLAY_MENU:recalculate()
  TRO.utils.cleanup_dead_elements(G, "MOVEABLES")
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
      TRO.UI.get_page_num = false
      TRO.UI.rerendering = true
      TRO.UI.rerender(TRO.UI.get_type_collection_UIBox_func(set), set, true)
      return true
    end,
  }))

  G.E_MANAGER:add_event(Event({
    func = function()
      G.FUNCS.SMODS_card_collection_page{ cycle_config = { current_option = TRO.UI.curr_page } }
      TRO.UI.get_page_num = true
      TRO.UI.rerendering = false
      return true
    end,
  }))
end

function TRO.utils.cleanup_dead_elements(ref_table, ref_key)
	local new_values = {}
	local target = ref_table[ref_key]
	if not target then
		return
	end
	for _, v in pairs(target) do
		if not v.REMOVED and not v.removed then
			new_values[#new_values + 1] = v
		end
	end
	ref_table[ref_key] = new_values
	return new_values
end