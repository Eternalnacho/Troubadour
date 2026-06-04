-- CONTROL SCHEME FUNCTIONS

function G.FUNCS.TRO_open_mod(e)
  play_sound('button', 1, 0.3)
  G.ROOM.jiggle = G.ROOM.jiggle + 0.5
  G.FUNCS["openModUI_" .. e.config.ref_table.id](e)
end

tro_input_manager:add_listener({ 'right_click', 'right_stick', 'x' }, function(target)
  if tro_config.invert_tile_controls then
    if target and target.TRO_mods_sprite then
      G.FUNCS.TRO_open_mod(target.parent.parent.parent)
    elseif target.config.TRO_mods_tile then
      G.FUNCS.TRO_open_mod(target)
    end
  else
    if target and target.TRO_mods_sprite then
      G.FUNCS.TRO_toggle_tile(target.parent.parent.parent)
    elseif target.config.TRO_mods_tile then
      G.FUNCS.TRO_toggle_tile(target)
    end
  end
end)

function G.FUNCS.TRO_check_tile_ctrls(e)
  if tro_config.invert_tile_controls then
    if (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then G.FUNCS.TRO_open_mod(e)
    else G.FUNCS.TRO_toggle_tile(e) end
  else
    if (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then G.FUNCS.TRO_toggle_tile(e)
    else G.FUNCS.TRO_open_mod(e) end
  end
end