-- UI HELPER FUNCTIONS
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
  local default_values = {
    ['align'] = "cm",
    ['padding'] = 0.05,
    ['colour'] = G.C.CLEAR,
  }
  local new_args = SMODS.merge_defaults(args, default_values)
  return new_args
end

-- Column node wrapper
function Troubadour.UI.create_column(args, nodes)
  return {
    n = G.UIT.C,
    config = Troubadour.UI.UIE_config_args(args),
    nodes = nodes or args.nodes or {}
  }
end

-- Row node wrapper
function Troubadour.UI.create_row(args, nodes)
  return {
    n = G.UIT.R,
    config = Troubadour.UI.UIE_config_args(args),
    nodes = nodes or args.nodes or {}
  }
end

-- Root node wrapper
function Troubadour.UI.create_root_node(args, nodes)
  return {
    n = G.UIT.ROOT,
    config = Troubadour.UI.UIE_config_args(args),
    nodes = nodes or args.nodes or {}
  }
end

-- Text node wrapper
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

-- I am VERY BLATANTLY ripping this straight from Cartomancer
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

-- Create shorthands for UI Helper Functions
SMODS.merge_defaults(Troubadour.UI, {
  ['Row'] = Troubadour.UI.create_row,
  ['Col'] = Troubadour.UI.create_column,
  ['Text'] = Troubadour.UI.create_text_node,
  ['Root'] = Troubadour.UI.create_root_node,
  ['UIBox'] = Troubadour.UI.create_UIBox_generic_options_custom,
  ['C'] = Troubadour.UI.mod_colours,
})

-- I am VERY BLATANTLY ripping this straight from Cartomancer
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

-- Stole this from Handy
function Troubadour.UI.rerender(def, silent)
  local result = { definition = def() }
  if silent then
    G.ROOM.jiggle = G.ROOM.jiggle - 1
    result.config = { offset = { x = 0, y = 0 } }
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