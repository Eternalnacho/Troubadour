-- UI FUNCTIONS
Troubadour.UI.mod_colours = {
  buttons = mix_colours(G.C.GREEN, G.C.GREY, 0.8),
  active = mix_colours(G.C.FILTER, G.C.RED, 0.5),
  inactive = darken(copy_table(G.C.GREY), 0.5),
  colour = mix_colours(G.C.UI.BACKGROUND_INACTIVE, {0, 0.1, 0.2, 1}, 0.8),
}
Troubadour.UI.mod_colours.bg_colour = mix_colours({0.5, 0.5, 0.5, 1}, Troubadour.UI.mod_colours.colour, 0.5)
Troubadour.UI.mod_colours.outline_colour = mix_colours(Troubadour.UI.mod_colours.colour, G.C.WHITE, 0.7)

-- UIElement args
function Troubadour.UI.UIE_config_args(args)
  return {
    align = args.align or "cm",
    padding = args.padding or 0.05,
    outline = args.outline,
    outline_colour = args.outline_colour,
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
    focus_args = args.focus_args,
  }
end

function Troubadour.UI.create_column(args)
  return {
    n = G.UIT.C,
    config = Troubadour.UI.UIE_config_args(args),
    nodes = args.nodes or {}
  }
end

function Troubadour.UI.create_row(args)
  return {
    n = G.UIT.R,
    config = Troubadour.UI.UIE_config_args(args),
    nodes = args.nodes or {}
  }
end

function Troubadour.UI.create_root_node(args)
  return {
    n = G.UIT.ROOT,
    config = Troubadour.UI.UIE_config_args(args),
    nodes = args.nodes or {}
  }
end

function Troubadour.UI.create_text_node(args)
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

function Troubadour.UI.create_num_input_node(args)
  return create_num_input({
    id = args.id,
    colour = args.colour,
    hooked_colour = args.hooked_colour,
    w = 2, h = 1,
    prompt_text = "",
    ref_table = tro_config,
    ref_value = args.ref_value,
    extended_corpus = true,
    keyboard_offset = 1,
    callback = args.callback
  })
end

-- I am VERY BLATANTLY ripping these straight from Cartomancer
function Troubadour.UI.create_UIBox_generic_options_custom(args)
  args = args or {}
  local translucent_grey = copy_table(G.C.GREY); translucent_grey[4] = 0.7
  return {
    n = G.UIT.ROOT,
    config = {
      align = "cm",
      minw = args.minw or G.ROOM.T.w * 0.6,
      emboss = args.emboss,
      padding = args.padding or 0.0,
      outline = args.outline,
      outline_colour = args.outline and args.outline_colour,
      r = 0.1,
      colour = args.bg_colour or translucent_grey
    },
    nodes = { Troubadour.UI.create_column({ padding = 0.0, minh = args.minh or 3, nodes = args.contents }) }
  }
end

function Troubadour.UI.create_column_tabs(args)
  args = args or {}
  args.colour = args.colour or G.C.CLEAR
  args.tab_alignment = args.tab_alignment or 'cl'
  args.opt_callback = args.opt_callback or nil
  args.scale = args.scale or 1
  args.tab_w = args.tab_w or 0
  args.tab_h = args.tab_h or 0
  args.text_scale = (args.text_scale or 0.5)

  local tab_buttons = {}

  for k, v in ipairs(args.tabs) do
    if v.chosen then args.current = {k = k, v = v} end
    local id = 'tab_but_'..(v.label or '')
    tab_buttons[#tab_buttons+1] = { n = G.UIT.R, config = { align = "tm" }, nodes={
      UIBox_button({
        id = id, ref_table = v, button = 'TRO_settings_change_tab', label = {v.label}, colour = darken(Troubadour.UI.mod_colours.buttons, 0.2),
        minh = 0.8 * args.scale, minw = 2.5 * args.scale, col = true, choice = true, scale = args.text_scale,
        chosen = v.chosen and 'vert', func = v.func, focus_args = { snap_to = args.snap_to_nav, nav = 'wide' },
      })
    }}
  end

  -- Tabs + Contents
  return {
    n = G.UIT.R,
    config = { padding = 0.0, align = "cl", colour = args.colour },
    nodes = {
      -- Tabs
      Troubadour.UI.create_column({ align = "cl", padding = 0.15, colour = G.C.CLEAR, focus_args = { button = 'x', type = 'none' }, nodes = tab_buttons }),
      -- Tab contents
      {
        n = G.UIT.C, config = { align = args.tab_alignment, padding = args.padding or 0.1, no_fill = true, minh = args.tab_h, minw = args.tab_w },
        nodes = {
          {
            n = G.UIT.O,
            config = {
              id = 'TRO_settings_tab_contents',
              old_chosen = tab_buttons[1].nodes[1].nodes[1],
              object = UIBox{
                definition = args.current.v.tab_definition_function(args.current.v.tab_definition_function_args),
                config = { offset = { x = 0, y = 0 } }
              }
            }
          }
        }
      },
    }
  }
end

-- Stole these from Handy
function Troubadour.UI.rerender(def, silent, set)
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
  Troubadour.UI.cleanup_dead_elements(G, "MOVEABLES")
end

function Troubadour.UI.cleanup_dead_elements(ref_table, ref_key)
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

-- BUTTON FUNCTIONS
function G.FUNCS.TRO_your_collection(e)
  Troubadour.coll_from_button = true
  G.FUNCS.your_collection()
end

function G.FUNCS.TRO_exit_coll_config(e)
  SMODS.save_mod_config(Troubadour)
  G.FUNCS.your_collection()
end

function G.FUNCS.exit_search_collection()
  if G.SETTINGS.paused then
    Troubadour.coll_from_button = nil
    G.FUNCS.exit_overlay_menu()
  end
end

function G.FUNCS.TRO_clear_targets(e)
  if next(Troubadour.collection_targets) then
    Troubadour.FUNCS.clear_targets(true)
  end
end

function G.FUNCS.TRO_view_options(e)
  G.SETTINGS.paused = true
  Troubadour.config_from_coll = true
  Troubadour.in_collection = false
  G.FUNCS.overlay_menu{ definition = Troubadour.UI.config_from_coll() }
  G.OVERLAY_MENU:recalculate()
end

function Troubadour.UI.rerender_collection(set)
  Troubadour.defer(function()
    Troubadour.UI.get_page_num, Troubadour.UI.rerendering = false, true
    Troubadour.UI.rerender(Troubadour.FUNCS.get_type_collection_UIBox_func(set), true, set)
    Troubadour.UI.get_page_num, Troubadour.UI.rerendering = true, false
  end)
end

function Troubadour.UI.config_from_coll()
  return create_UIBox_generic_options({
    colour = G.C.BLACK,
    back_func = 'TRO_exit_coll_config',
    contents = SMODS.Mods["Troubadour"].extra_tabs()[2].tab_definition_function().nodes})
end

function Troubadour.UI.reset_ui_states()
  Troubadour.in_collection = false
  Troubadour.config_from_coll = nil
  Troubadour.UI.targets.added_target = ''
  Troubadour.UI.get_page_num = true
end