-- UI FUNCTIONS
TRO.UI = {}

function TRO.UI.get_type_collection_UIBox_func(set)
  local func
  if SMODS.ConsumableTypes[set] then
    func = SMODS.ConsumableTypes[set].create_UIBox_your_collection
  elseif set == 'Joker' then
    func = create_UIBox_your_collection_jokers
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

function TRO.UI.config_from_coll()
  return create_UIBox_generic_options({
    colour = G.C.BLACK,
    back_func = 'your_collection',
    contents = SMODS.Mods["Troubadour"].config_tab().nodes})
end

function TRO.UI.reset_ui_states()
  TRO.in_collection = false
  TRO.config_from_coll = nil
  TRO.UI.targets.added_target = ''
  TRO.UI.get_page_num = true
end

-- Stole these from Handy
function TRO.UI.rerender(def, silent, set)
  local result = set and { definition = def(SMODS.ConsumableTypes[set]) } or { definition = def() }
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
  TRO.UI.cleanup_dead_elements(G, "MOVEABLES")
end

function TRO.UI.cleanup_dead_elements(ref_table, ref_key)
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

-- UIElement args
function TRO.UI.UIE_config_args(args)
  return {
    align = args.align or "bm",
    padding = args.padding or 0.05,
    colour = args.colour or G.C.CLEAR,
    emboss = args.emboss,
    minh = args.minh,
    maxh = args.maxh,
    minw = args.minw,
    maxw = args.maxw,
    h = args.h,
    w = args.w,
    r = args.r,
    id = args.id,
    detailed_tooltip = args.detailed_tooltip,
    on_demand_tooltip = args.on_demand_tooltip,
    TRO_dark_tooltip = args.TRO_dark_tooltip,
    h_popup = args.h_popup,
    h_popup_config = args.h_popup_config,
  }
end

function TRO.UI.create_column(args)
  return {
    n = G.UIT.C,
    config = TRO.UI.UIE_config_args(args),
    nodes = args.nodes or {}
  }
end

function TRO.UI.create_row(args)
  return {
    n = G.UIT.R,
    config = TRO.UI.UIE_config_args(args),
    nodes = args.nodes or {}
  }
end

function TRO.UI.create_text_node(args)
  return {
    n = G.UIT.T,
    config = {
      text = args.text,
      ref_table = args.ref_table,
      ref_value = args.ref_value,
      scale = args.scale or 1,
      colour = args.colour or G.C.WHITE,
      shadow = args.shadow,
      vert = args.vert
    }
  }
end

function TRO.UI.create_num_input_node(args)
  return create_text_input({
    colour = args.colour,
    hooked_colour = args.hooked_colour,
    w = 3, h = 1,
    prompt_text = "",
    ref_table = tro_config,
    ref_value = args.ref_value,
    extended_corpus = true,
    keyboard_offset = 1,
    callback = function()
      tro_config[args.ref_value] = string.gsub(tro_config[args.ref_value], "O", "0")
      tro_config[args.ref_value] = tonumber(tro_config[args.ref_value]) or tonumber(args.default)
      TRO.UI.update_TRO_config()
    end
  })
end

-- BUTTON FUNCTIONS
function G.FUNCS.TRO_your_collection(e)
  TRO.coll_from_button = true
  G.FUNCS.your_collection()
end

function G.FUNCS.exit_search_collection()
  if G.SETTINGS.paused then
    TRO.coll_from_button = nil
    G.FUNCS.exit_overlay_menu()
  end
end

function G.FUNCS.TRO_clear_targets(e)
  if next(TRO.collection_targets) then
    TRO.FUNCS.clear_targets(true)
  end
end

function G.FUNCS.TRO_view_options(e)
  G.SETTINGS.paused = true
  TRO.config_from_coll = true
  TRO.in_collection = false
  G.FUNCS.overlay_menu{ definition = TRO.UI.config_from_coll() }
  G.OVERLAY_MENU:recalculate()
end