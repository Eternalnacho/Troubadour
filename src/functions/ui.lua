-- UI FUNCTIONS
TRO.UI = {}
TRO.UI.mod_colours = {
  buttons = mix_colours(G.C.GREEN, G.C.GREY, 0.8),
  active = mix_colours(G.C.FILTER, G.C.RED, 0.5),
  inactive = darken(copy_table(G.C.GREY), 0.5),
  colour = mix_colours(G.C.UI.BACKGROUND_INACTIVE, {0, 0.1, 0.2, 1}, 0.8),
}
TRO.UI.mod_colours.bg_colour = mix_colours({0.5, 0.5, 0.5, 1}, TRO.UI.mod_colours.colour, 0.5)
TRO.UI.mod_colours.outline_colour = mix_colours(TRO.UI.mod_colours.colour, G.C.WHITE, 0.7)

-- UIElement args
function TRO.UI.UIE_config_args(args)
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

function TRO.UI.create_root_node(args)
  return {
    n = G.UIT.ROOT,
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

-- This is functionally the same as a normal text input but with a different text input func
function create_num_input(args)
  args = args or {}
  args.prompt_text = args.prompt_text or localize('k_enter_text')
  args.current_prompt_text = ''
  args.id = args.id or "num_input"

  local ret = create_text_input(args)
  ret.nodes[1].nodes[1].nodes[1].config.func = 'TRO_num_input'
  return ret
end

-- I am VERY BLATANTLY ripping these straight from Cartomancer
function TRO.UI.create_UIBox_generic_options_custom(args)
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
    nodes = { TRO.UI.create_column({ padding = 0.0, minh = args.minh or 3, nodes = args.contents }) }
  }
end

function TRO.UI.create_column_tabs(args)
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
        id = id, ref_table = v, button = 'TRO_settings_change_tab', label = {v.label}, colour = darken(TRO.UI.mod_colours.buttons, 0.2),
        minh = 0.8 * args.scale, minw = 2.5 * args.scale, col = true, choice = true, scale = args.text_scale,
        chosen = v.chosen and 'vert', func = v.func, focus_args = {type = 'none'}
      })
    }}
  end

  -- Tabs + Contents
  return {
    n = G.UIT.R,
    config = { padding = 0.0, align = "cl", colour = args.colour },
    nodes = {
      -- Tabs
      TRO.UI.create_column({ align = "cl", padding = 0.15, colour = G.C.CLEAR, nodes = tab_buttons }),
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

-- BUTTON FUNCTIONS
function G.FUNCS.TRO_your_collection(e)
  TRO.coll_from_button = true
  G.FUNCS.your_collection()
end

function G.FUNCS.TRO_exit_coll_config(e)
  SMODS.save_mod_config(TRO)
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

G.FUNCS.TRO_settings_change_tab = function(e)
  if not e then return end
  local tab_contents = e.UIBox:get_UIE_by_ID('TRO_settings_tab_contents')
  if not tab_contents then return end
  -- Same tab, don't rebuild it.
  if tab_contents.config.oid == e.config.id then return end
  if tab_contents.config.old_chosen then tab_contents.config.old_chosen.config.chosen = nil end

  tab_contents.config.old_chosen = e
  e.config.chosen = 'vert'

  tab_contents.config.oid = e.config.id
  tab_contents.config.object:remove()
  tab_contents.config.object = UIBox{
      definition = e.config.ref_table.tab_definition_function(e.config.ref_table.tab_definition_function_args),
      config = {offset = {x=0,y=0}, parent = tab_contents, type = 'cm'}
    }
  tab_contents.UIBox:recalculate()
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

function TRO.UI.rerender_collection(set)
  G.E_MANAGER:add_event(Event({
    func = function()
      TRO.UI.get_page_num, TRO.UI.rerendering = false, true
      TRO.UI.rerender(TRO.FUNCS.get_type_collection_UIBox_func(set), true, set)
      TRO.UI.get_page_num, TRO.UI.rerendering = true, false
      return true
    end,
  }))
end

function TRO.UI.config_from_coll()
  return create_UIBox_generic_options({
    colour = G.C.BLACK,
    back_func = 'TRO_exit_coll_config',
    contents = SMODS.Mods["Troubadour"].extra_tabs()[2].tab_definition_function().nodes})
end

function TRO.UI.reset_ui_states()
  TRO.in_collection = false
  TRO.config_from_coll = nil
  TRO.UI.targets.added_target = ''
  TRO.UI.get_page_num = true
end