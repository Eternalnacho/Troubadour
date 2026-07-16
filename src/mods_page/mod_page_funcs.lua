-- FUNCTIONS FOR TAB POINTERS

Troubadour.Hook('before', SMODS.GUI, 'dynamicModListContent', function(page)
  if Troubadour.config.mod_icons_only then
    return Troubadour.UIDEF.dynaModList(SMODS.mod_list, page)
  end
end)

Troubadour.Hook('before', G.FUNCS, 'exit_mods', function()
  Troubadour.mod_folder_view = nil
end)

G.FUNCS.Troubadour_update_mod_list = function(e)
  if not e or not e.cycle_config then return end
  local list = Troubadour.ACTIVE_SEARCH and Troubadour.ACTIVE_SEARCH:get_list() or SMODS.mod_list
  Troubadour.UI.updateObject('modsList', Troubadour.UIDEF.dynaModList(list, e.cycle_config.current_option))
end

-- CONTROL SCHEME FUNCS FOR MOD TILES

function G.FUNCS.TRO_open_mod(e)
  play_sound('button', 1, 0.3)
  G.ROOM.jiggle = G.ROOM.jiggle + 0.5
  G.FUNCS["openModUI_" .. e.config.ref_table.id](e)
end

Troubadour.input_manager:add_listener({ 'right_click', 'right_stick', 'x' }, function(target)
  if target and target.config and target.config.TRO_mod_tile then
    Troubadour.config.invert_tile_controls = not Troubadour.config.invert_tile_controls -- we do this essentially to treat a right-click like a left-click temporarily
    target:click() -- calling the click function rather than just the button function so we get that sweet VFX + SFX
    Troubadour.config.invert_tile_controls = not Troubadour.config.invert_tile_controls
  end
end)

function G.FUNCS.TRO_check_tile_ctrls(e)
  if (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then
    if Troubadour.config.invert_tile_controls then G.FUNCS.TRO_open_mod(e)
    else G.FUNCS.TRO_toggle_tile(e) end
  else
    if Troubadour.config.invert_tile_controls then G.FUNCS.TRO_toggle_tile(e)
    else G.FUNCS.TRO_open_mod(e) end
  end
end


-- BUTTON FUNCS FOR PAGE HEADER BUTTONS

G.FUNCS.Troubadour_modlist_button = function(e)
  Troubadour.mod_folder_view = nil
  Troubadour.UI.rerender(create_UIBox_mods_button, true)
end

G.FUNCS.Troubadour_mod_folder_button = function(e)
  Troubadour.mod_folder_view = true
  Troubadour.UI.rerender(create_UIBox_mods_button, true)
  SMODS.GUI.DynamicUIManager.updateDynamicAreas({
    ["modFolderList"] = Troubadour.UIDEF.modFolderList(1)
  })
end

function G.FUNCS.Troubadour_update_mod_folder_list(args)
  if not args or not args.cycle_config then return end
  SMODS.GUI.DynamicUIManager.updateDynamicAreas({
    ["modFolderList"] = Troubadour.UIDEF.modFolderList(args.cycle_config.current_option)
  })
end


-- SEPARATE DEFINITION FOR SPECIFICALLY THE MOD LIST CONFIG

G.FUNCS.Troubadour_modlist_config = function(e)
  G.SETTINGS.paused = true
  local function def()
    G.ACTIVE_MOD_UI = SMODS.Mods["Troubadour"]
    SMODS.LAST_SELECTED_MOD_TAB = 'Troubadour_2'
    return create_UIBox_mods()
  end
  G.FUNCS.overlay_menu { definition = def() }
  G.OVERLAY_MENU:recalculate()
end