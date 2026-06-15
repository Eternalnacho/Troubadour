local T = Troubadour.UI
local Tile = assert(SMODS.load_file("src/objects/tile.lua"))()

-- SUBCLASS OF TILE
local ModTile = Tile:extend()

function ModTile:init(args)
  Tile.init(self, args)
  self.TRO_mod_tile = true
  self.ref_table = args.mod
  self.ref_value = 'should_enable'
  self.object = Troubadour.ICONS.buildModtag(args.mod)
  self.object_args = {
    w = SMODS.pixels_to_unit(34) * 2,
    h = SMODS.pixels_to_unit(34) * 2,
    colour = G.C.CLEAR
  }
  self.TRO_dark_tooltip = function() return self:get_popup(args.mod, 0.75) end
  self.button_func = args.button_func or 'TRO_check_tile_ctrls'
  self.callback = function(_set_toggle) Troubadour.toggleMod(args.mod) end
end

function ModTile:render()
  self.no_outline = true
  local tile_node = Tile.render(self)
  tile_node.config.TRO_mod_tile = self.TRO_mod_tile
  return tile_node
end

function ModTile:get_popup(mod, scale)
  local col, bg_col, text_col = Troubadour.ICONS.get_mod_popup_colours(mod)
  local version_col = copy_table(G.C.WHITE); version_col[4] = 0.6
  local the_colour = mix_colours(G.C.BLACK, G.C.WHITE, 0.2); the_colour[4] = 0.8
  local label_nodes = {}
  -- Get Mod Name Node
  Troubadour.ICONS.get_modName_node(mod, label_nodes, {scale = scale * 0.65, colour = text_col})
  -- Get "Lovely Only" Node
  Troubadour.ICONS.get_lovely_node(mod, label_nodes, {scale = scale * 0.6, colour = version_col})
  -- Get Version Node
  Troubadour.ICONS.get_version_node(mod, label_nodes, {scale = scale * 0.6, colour = version_col})
  -- Get Author DynaText Node
  Troubadour.ICONS.get_authorDyna_node(mod, label_nodes, {scale = scale * 0.4, colour = the_colour})
  -- Priority Node ???
  Troubadour.ICONS.get_priority_node(mod, label_nodes, {scale = scale * 0.5, colour = version_col})
  -- Get Load State Node
  Troubadour.ICONS.get_loadState_nodes(mod, label_nodes, {scale = scale * 0.4, colour = version_col})

  -- Controls at bottom of UIBox
  Troubadour.ICONS.get_controls(label_nodes, {scale = scale * 0.3, colour = version_col})

  return T.Col { r = 0.2, padding = 0.1, emboss = 0.1, colour = bg_col,
    outline = 1, outline_colour = mix_colours(col, G.C.WHITE, 0.7),
    nodes = {
      T.Row { r = 0.2, emboss = 0.05, colour = col, nodes = {
        T.Col { r = 0.2, nodes = label_nodes }
      }}
    }}
end

return ModTile