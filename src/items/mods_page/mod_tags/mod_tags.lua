local Tile = assert(SMODS.load_file("src/objects/tile.lua"))()
local Col = Troubadour.UI.create_column

-- MOD TAG + ICON BUILDING

function Troubadour.ICONS.getModtagInfo(mod)
  local tag_pos = { x = 0, y = 0 }
  local tag_atlas = mod.prefix and mod.prefix .. '_modicon' or 'modicon'

  if not mod.can_load then
    if mod.disabled and not mod.icon_path then
      tag_atlas = 'TRO_' .. mod.id .. '_modicon'
    end
  end

  return tag_atlas, tag_pos
end

function Troubadour.ICONS.drawTag(sprite, size, draw_steps)
  if not size then size = 1 end
  if not draw_steps then draw_steps = {} end

  sprite.T.scale = size
  sprite:define_draw_steps({
    { shader = 'dissolve', shadow_height = 0.05 },
    { shader = 'dissolve' },
    type(draw_steps) == 'table' and next(draw_steps) and table.unpack(draw_steps)
  })
  sprite.float = true
end

function Troubadour.ICONS.buildModtag(mod)
  local tag_atlas, tag_pos = Troubadour.ICONS.getModtagInfo(mod)
  local tag_sprite = SMODS.create_sprite(0, 0, 0.8, 0.8, SMODS.get_atlas(tag_atlas) or SMODS.get_atlas('tags'), tag_pos)
  local disabled_shadow = mod.disabled and {shader = 'dissolve', shadow_height = 0, tilt_shadow = 1}
  Troubadour.ICONS.drawTag(tag_sprite, 1, {disabled_shadow})

  tag_sprite.TRO_mods_sprite = true
  tag_sprite:juice_up(0.2)
  return tag_sprite
end

function Troubadour.ICONS.createModBoxTile(modInfo)
  if modInfo.should_enable == nil then modInfo.should_enable = not modInfo.disabled end
  if SMODS.full_restart == nil then SMODS.full_restart = 0 end

  local mod_tile = Tile({
    ref_table = modInfo,
    ref_value = 'should_enable',
    object = Troubadour.ICONS.buildModtag(modInfo),
    object_args = {w = SMODS.pixels_to_unit(34) * 2, h = SMODS.pixels_to_unit(34) * 2, colour = G.C.BLUE},
    TRO_mods_tile = true,
    TRO_dark_tooltip = function() return Troubadour.UIDEF.mod_icon_popup(modInfo, 0.75) end,
    no_outline = true,
    button_func = 'TRO_check_tile_ctrls',
    callback = function(_set_toggle) Troubadour.toggleMod(modInfo) end,
  })

  local tile_node = mod_tile:render()
  return Col { padding = 0.05, nodes = { Col { padding = 0.0, minw = 1, minh = 1, nodes = { tile_node } } } }
end

function Troubadour.toggleMod(mod)
  if not mod.should_enable then
    NFS.write(mod.path .. '.lovelyignore', '')
  else
    NFS.remove(mod.path .. '.lovelyignore')
  end
  local toChange = 1
  if mod.should_enable == not mod.disabled then
    toChange = -1
  end
  SMODS.full_restart = SMODS.full_restart + toChange
end