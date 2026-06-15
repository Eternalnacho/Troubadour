local ModTile = assert(SMODS.load_file("src/objects/modtile.lua"))()
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

function Troubadour.ICONS.createModBoxTile(modInfo)
  if modInfo.should_enable == nil then modInfo.should_enable = not modInfo.disabled end
  if SMODS.full_restart == nil then SMODS.full_restart = 0 end
  return Col { padding = 0.05, nodes = { Col { padding = 0.0, minw = 1, minh = 1, nodes = { ModTile({mod = modInfo}):render() } } } }
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



-- UI ELEMENT HOOKS FOR MOD TILE
local uieSV = UIElement.set_values
function UIElement:set_values(...)
  uieSV(self, ...)
  if self.config.TRO_mod_tile then
    self.states.collide.can = true
  end
end

local uiehover = UIElement.hover
function UIElement:hover()
  if self.config and self.config.TRO_mod_tile then
    local tag_sprite = self.children[1] and self.children[1].children and self.children[1].children[1].config.object
    if tag_sprite then
      tag_sprite.hover_tilt = 3
      tag_sprite:juice_up(0.05, 0.02)
      play_sound('paper1', math.random() * 0.1 + 0.55, 0.42)
      play_sound('tarot2', math.random() * 0.1 + 0.55, 0.09)
    end
  end
  uiehover(self)
end

local uiestophover = UIElement.stop_hover
function UIElement:stop_hover()
  uiestophover(self)
  if self.config and self.config.TRO_mod_tile then
    local tag_sprite = self.children[1] and self.children[1].children and self.children[1].children[1].config.object
    if tag_sprite then
      tag_sprite.hover_tilt = 0
    end
  end
end