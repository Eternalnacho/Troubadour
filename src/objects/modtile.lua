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
  self.TRO_dark_tooltip = function() return Troubadour.UIDEF.mod_icon_popup(args.mod, 0.75) end
  self.button_func = args.button_func or 'TRO_check_tile_ctrls'
  self.callback = function(_set_toggle) Troubadour.toggleMod(args.mod) end
end

function ModTile:render()
  self.no_outline = true
  local tile_node = Tile.render(self)
  tile_node.config.TRO_mod_tile = self.TRO_mod_tile
  return tile_node
end

return ModTile