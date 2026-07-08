local T = Troubadour.UI
local Tile = Troubadour.Tile

-- TILE SUBCLASS FOR MODS

Troubadour.ModTile = Tile:extend()

function Troubadour.ModTile:init(args)
  Tile.init(self, args)
  self.TRO_mod_tile = true
  self.ref_table = args.ref_table or args.mod
  self.ref_value = args.ref_value or 'should_enable'
  self.object = Troubadour.UIDEF.modTagSprite(args.mod)
  self.object_args = {
    w = SMODS.pixels_to_unit(34) * 2,
    h = SMODS.pixels_to_unit(34) * 2,
    colour = G.C.CLEAR
  }
  self.TRO_dark_tooltip = function() return self:get_popup(args.mod, 0.75) end
  self.button_func = args.button_func or 'TRO_check_tile_ctrls'
  self.callback = args.callback or function(_set_toggle) Troubadour.toggleMod(args.mod) end
end

function Troubadour.ModTile:render()
  self.no_outline = true
  local tile_node = Tile.render(self)
  tile_node.config.TRO_mod_tile = self.TRO_mod_tile
  return tile_node
end

function Troubadour.ModTile:get_popup(mod, scale)
  local col, bg_col, text_col = Troubadour.UIDEF.get_mod_popup_colours(mod)
  local version_col = copy_table(G.C.WHITE); version_col[4] = 0.6
  local the_colour = mix_colours(G.C.BLACK, G.C.WHITE, 0.2); the_colour[4] = 0.8

  local label_nodes = {}
  -- Get Mod Name Node
  Troubadour.UIDEF.modNodes.name(mod, label_nodes, {scale = scale * 0.65, colour = text_col})
  -- Get "Lovely Only" Node
  Troubadour.UIDEF.modNodes.lovely(mod, label_nodes, {scale = scale * 0.6, colour = version_col})
  -- Get Version Node
  Troubadour.UIDEF.modNodes.version(mod, label_nodes, {scale = scale * 0.6, colour = version_col})
  -- Get Author DynaText Node
  Troubadour.UIDEF.modNodes.authors(mod, label_nodes, {scale = scale * 0.4, colour = the_colour})
  -- Priority Node
  Troubadour.UIDEF.modNodes.priority(mod, label_nodes, {scale = scale * 0.5, colour = version_col})
  -- Get Load State Node
  Troubadour.UIDEF.modNodes.loadState(mod, label_nodes, {scale = scale * 0.4, colour = version_col})
  -- Controls at bottom of UIBox
  Troubadour.UIDEF.modNodes.controls(label_nodes, {scale = scale * 0.3, colour = version_col})

  return T.Col { r = 0.2, padding = 0.1, emboss = 0.1, colour = bg_col,
    outline = 1, outline_colour = mix_colours(col, G.C.WHITE, 0.7),
    nodes = {
      T.Row { r = 0.2, emboss = 0.05, colour = col, nodes = {
        T.Col { r = 0.2, nodes = label_nodes }
      }}
    }}
end


-- UI ELEMENT HOOKS FOR MOD TILE

Troubadour.Hook('after', UIElement, 'set_values', function(self)
  if self.config.TRO_mod_tile then
    self.states.collide.can = true
  end
end)

Troubadour.Hook('before', UIElement, 'hover', function(self)
  if self.config and self.config.TRO_mod_tile then
    local tag_sprite = self.children[1] and self.children[1].children and self.children[1].children[1].config.object
    if tag_sprite then
      tag_sprite.hover_tilt = 3
      tag_sprite:juice_up(0.05, 0.02)
      play_sound('paper1', math.random() * 0.1 + 0.55, 0.42)
      play_sound('tarot2', math.random() * 0.1 + 0.55, 0.09)
    end
  end
end)

Troubadour.Hook('before', UIElement, 'stop_hover', function(self)
  if self.config and self.config.TRO_mod_tile then
    local tag_sprite = self.children[1] and self.children[1].children and self.children[1].children[1].config.object
    if tag_sprite then
      tag_sprite.hover_tilt = 0
    end
  end
end)