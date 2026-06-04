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

G.FUNCS.Troubadour_mod_folder_button = function(e)
  return
end

G.FUNCS.Troubadour_mod_list_config = function(e)
  G.SETTINGS.paused = true
  Troubadour.config_from_modslist = true
  G.FUNCS.overlay_menu{ definition = Troubadour.UI.config_from_modlist() }
  G.OVERLAY_MENU:recalculate()
end

function Troubadour.UI.config_from_modlist()
  return create_UIBox_generic_options({
    colour = G.C.BLACK,
    back_func = "Troubadour_exit_modlist_config",
    contents = SMODS.Mods["Troubadour"].extra_tabs()[1].tab_definition_function().nodes})
end

function G.FUNCS.Troubadour_exit_modlist_config(e)
  Troubadour.config_from_modslist = nil
  SMODS.save_mod_config(Troubadour)
  G.FUNCS.mods_button()
end