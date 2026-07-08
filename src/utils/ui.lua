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
  return type(new_args) == 'table' and new_args or args
end

-- Column node wrapper
---@param config table
---@param nodes table?
function Troubadour.UI.create_column(config, nodes)
  return {
    n = G.UIT.C,
    config = Troubadour.UI.UIE_config_args(config),
    nodes = nodes or config.nodes or {}
  }
end

-- Row node wrapper
---@param config table
---@param nodes table?
function Troubadour.UI.create_row(config, nodes)
  return {
    n = G.UIT.R,
    config = Troubadour.UI.UIE_config_args(config),
    nodes = nodes or config.nodes or {}
  }
end

-- Root node wrapper
---@param config table
---@param nodes table?
function Troubadour.UI.create_root_node(config, nodes)
  return {
    n = G.UIT.ROOT,
    config = Troubadour.UI.UIE_config_args(config),
    nodes = nodes or config.nodes or {}
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
local T = Troubadour.UI
T.Row = Troubadour.UI.create_row
T.Col = Troubadour.UI.create_column
T.Text = Troubadour.UI.create_text_node
T.Root = Troubadour.UI.create_root_node
T.UIBox = Troubadour.UI.create_UIBox_generic_options_custom
T.C = Troubadour.UI.mod_colours

-- UIBox refresh function
---@param id string
Troubadour.UI.updateObject = function(id, definition)
  local object = G.OVERLAY_MENU:get_UIE_by_ID(id)
  if object and definition then
    object.config.object:remove()
    object.config.object = UIBox({
      definition = definition,
      config = {type = "cm", parent = object}
    })
    object.UIBox:recalculate()
  end
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

-- Stole this from Handy
function Troubadour.UI.cleanup_dead_elements(ref_table, ref_key)
	local new_values = {}
	local target = ref_table[ref_key]
	if not target then return end
	for _, v in pairs(target) do
		if not v.REMOVED and not v.removed then
			new_values[#new_values + 1] = v
		end
	end
	ref_table[ref_key] = new_values
	return new_values
end