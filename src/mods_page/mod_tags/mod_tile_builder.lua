local T = Troubadour.UI
local ModTile = Troubadour.ModTile

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

function Troubadour.ICONS.buildModtag(mod)
  local tag_atlas, tag_pos = Troubadour.ICONS.getModtagInfo(mod)
  local tag_sprite = SMODS.create_sprite(0, 0, 0.8, 0.8, SMODS.get_atlas(tag_atlas) or SMODS.get_atlas('tags'), tag_pos)

  tag_sprite.T.scale = 1
  tag_sprite:define_draw_steps({
    { shader = 'dissolve', shadow_height = 0.05 },
    { shader = 'dissolve' },
    mod.disabled and {shader = 'dissolve', shadow_height = 0, tilt_shadow = 1}
  })
  tag_sprite.float = true

  tag_sprite.TRO_mods_sprite = true
  tag_sprite:juice_up(0.2)
  return tag_sprite
end

function Troubadour.ICONS.buildModTile(modInfo)
  if modInfo.should_enable == nil then modInfo.should_enable = not modInfo.disabled end
  if SMODS.full_restart == nil then SMODS.full_restart = 0 end
  return T.Col { padding = 0.05, nodes = { T.Col { padding = 0.0, minw = 1, minh = 1, nodes = { ModTile({mod = modInfo}):render() } } } }
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