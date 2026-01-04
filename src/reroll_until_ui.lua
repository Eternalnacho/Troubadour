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

-- and I'm stealing *this* from Too Many Jokers
local oldcuib = create_UIBox_generic_options
create_UIBox_generic_options = function(arg1, ...) --inserts the text into most collection pages without needing to hook each individual function
    if arg1 and arg1.back_func == "your_collection" or arg1.back_func == 'your_collection_consumables'
        and arg1.contents and arg1.contents[1] and arg1.contents[1].n == 4 and TRO.adding_key then
      local new_target = TRO.adding_key and next(TRO.collection_targets) and TRO.collection_targets[#TRO.collection_targets]
      if new_target then
        table.insert(arg1.contents, {
          n = G.UIT.R,
          config = { align = "cm", minh = 0.5 },
          nodes = {
              { n = G.UIT.C, config = { align = "cm", padding = 0.15, r = 0.2, minw = 5, colour = darken(copy_table(G.C.GREY), 0.5), emboss = 0.05 },
                nodes = { { n = G.UIT.T, config = { text = "Added key: " .. new_target, colour = G.C.WHITE, shadow = true, scale = 0.3 } } } }
          }
        })
        TRO.adding_key = nil
      end
    end
    return oldcuib(arg1, ...)
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

TRO.UI.get_page_num = true
local smodsccb = SMODS.card_collection_UIBox
SMODS.card_collection_UIBox = function(_pool, rows, args)
  args.no_materialize = TRO.adding_key and true or args.no_materialize
  if TRO.UI.rerendering then args.TRO_curr_option = TRO.UI.curr_page end
  return smodsccb(_pool, rows, args)
end