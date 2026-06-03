local Tile = assert(SMODS.load_file("src/settings/tile.lua"))()
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

function Troubadour.ICONS.buildClickableTag(sprite, size, draw_steps, popup, click_func)
  if not size then size = 1 end
  if not draw_steps then draw_steps = {} end
  sprite.T.scale = size
  sprite:define_draw_steps({
    { shader = 'dissolve', shadow_height = 0.05 },
    { shader = 'dissolve' },
    type(draw_steps) == 'table' and next(draw_steps) and table.unpack(draw_steps)
  })
  sprite.float = true
  sprite.states.hover.can = true
  sprite.states.click.can = true
  sprite.states.collide.can = true
  sprite.states.drag.can = false

  sprite.hover = function(_self)
    if not G.CONTROLLER.dragging.target or G.CONTROLLER.using_touch then
      if not _self.hovering and _self.states.visible then
        _self.hovering = true
        if _self == sprite then
          _self.hover_tilt = 3
          _self:juice_up(0.05, 0.02)
          play_sound('paper1', math.random() * 0.1 + 0.55, 0.42)
          play_sound('tarot2', math.random() * 0.1 + 0.55, 0.09)
        end
        _self.config.h_popup = popup
        if _self.config.h_popup then _self.config.h_popup_config = { align = 'tm', offset = { x = 0, y = -0.3 }, parent = _self } end
        Node.hover(_self)
        if _self.children.alert then
          _self.children.alert:remove()
          _self.children.alert = nil
          G:save_progress()
        end
      end
    end
  end

  sprite.stop_hover = function(_self)
    _self.hovering = false
    _self.hover_tilt = 0
    Node.stop_hover(_self)
  end

  sprite.click = click_func

  sprite:juice_up()
end

function Troubadour.ICONS.buildModtag(mod)
  local tag_atlas, tag_pos = Troubadour.ICONS.getModtagInfo(mod)
  local tag_sprite = SMODS.create_sprite(0, 0, 0.8 * 1, 0.8 * 1, SMODS.get_atlas(tag_atlas) or SMODS.get_atlas('tags'), tag_pos)
  tag_sprite.T.scale = 1
  tag_sprite:define_draw_steps({
    { shader = 'dissolve', shadow_height = 0.05 },
    { shader = 'dissolve' },
    mod.icon_path and mod.disabled and {shader = 'dissolve', shadow_height = 0, tilt_shadow = 1} or nil,
  })
  tag_sprite.float = true
  tag_sprite.states.hover.can = true
  tag_sprite.states.click.can = true
  tag_sprite.states.collide.can = true
  tag_sprite.states.drag.can = false

  tag_sprite.hover = function(_self)
    if not G.CONTROLLER.dragging.target or G.CONTROLLER.using_touch then
      if not _self.hovering and _self.states.visible then
        _self.hovering = true
        if _self == tag_sprite then
          _self.hover_tilt = 3
          _self:juice_up(0.05, 0.02)
          play_sound('paper1', math.random() * 0.1 + 0.55, 0.42)
          play_sound('tarot2', math.random() * 0.1 + 0.55, 0.09)
        end
        _self.config.h_popup = Troubadour.UIDEF.mod_icon_popup(mod, 0.75)
        _self.config.h_popup_config = { align = 'tm', offset = { x = 0, y = -0.3 }, parent = _self }
        Node.hover(_self)
        if _self.children.alert then
          _self.children.alert:remove()
          _self.children.alert = nil
          G:save_progress()
        end
      end
    end
  end

  tag_sprite.click = function(self)
    if tro_config.invert_tile_controls then
      if (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then G.FUNCS.TRO_open_mod(self.parent.parent.parent)
      else self.parent.parent.parent:click() end
    else
      if (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then self.parent.parent.parent:click()
      else G.FUNCS.TRO_open_mod(self.parent.parent.parent) end
    end
  end
  
  tag_sprite.stop_hover = function(_self)
    _self.hovering = false
    _self.hover_tilt = 0
    Node.stop_hover(_self)
  end

  tag_sprite.TRO_mods_sprite = true
  tag_sprite:juice_up()
  return tag_sprite
end

function Troubadour.ICONS.createModBoxTile(modInfo)
  local units, mod_tile
  if modInfo.should_enable == nil then
    modInfo.should_enable = not modInfo.disabled
  end
  if SMODS.full_restart == nil then
    SMODS.full_restart = 0
  end

  units = SMODS.pixels_to_unit(34) * 2

  mod_tile = Tile({
    ref_table = modInfo,
    ref_value = 'should_enable',
    object = Troubadour.ICONS.buildModtag(modInfo),
    object_args = {w = units, h = units, colour = G.C.BLUE},
    TRO_mods_tile = true,
    no_outline = true,
    button_func = 'TRO_check_tile_ctrls',
    callback = function(_set_toggle)
      if not modInfo.should_enable then
        NFS.write(modInfo.path .. '.lovelyignore', '')
      else
        NFS.remove(modInfo.path .. '.lovelyignore')
      end
      local toChange = 1
      if modInfo.should_enable == not modInfo.disabled then
        toChange = -1
      end
      SMODS.full_restart = SMODS.full_restart + toChange
    end,
  })

  local tile_node = mod_tile:render()

  return Col { padding = 0.05, nodes = { Col { padding = 0.0, minw = 1, minh = 1, nodes = { tile_node } } } }
end