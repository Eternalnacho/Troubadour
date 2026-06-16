-- HOOKS FOR TAB POINTERS

local statModList_ref = SMODS.GUI.staticModListContent
SMODS.GUI.staticModListContent = function()
  if Troubadour.mod_folder_view then
    return Troubadour.UIDEF.statModFolderPage()
  elseif Troubadour.config.mod_icons_only then
    return Troubadour.UIDEF.statModList()
  else
    return statModList_ref()
  end
end

local dynaModList_ref = SMODS.GUI.dynamicModListContent
SMODS.GUI.dynamicModListContent = function(page, ...)
  if Troubadour.config.mod_icons_only then
    return Troubadour.UIDEF.dynaModList(page)
  else
    return dynaModList_ref(page, ...)
  end
end



-- CONTROL SCHEME FUNCS FOR MOD TILES

function G.FUNCS.TRO_open_mod(e)
  play_sound('button', 1, 0.3)
  G.ROOM.jiggle = G.ROOM.jiggle + 0.5
  G.FUNCS["openModUI_" .. e.config.ref_table.id](e)
end

tro_input_manager:add_listener({ 'right_click', 'right_stick', 'x' }, function(target)
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
  SMODS.GUI.DynamicUIManager.updateDynamicAreas({
    ["modsList"] = SMODS.GUI.dynamicModListContent(1)
  })
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
  Troubadour.config_from_modslist = true
  G.FUNCS.overlay_menu{ definition = Troubadour.UI.config_from_modlist() }
  G.OVERLAY_MENU:recalculate()
end

function Troubadour.UI.config_from_modlist()
  return create_UIBox_generic_options({
    colour = G.C.BLACK,
    back_func = "Troubadour_exit_modlist_config",
    contents = SMODS.Mods["Troubadour"].extra_tabs()[2].tab_definition_function().nodes})
end

function G.FUNCS.Troubadour_exit_modlist_config(e)
  Troubadour.config_from_modslist = nil
  SMODS.save_mod_config(Troubadour)
  G.FUNCS.mods_button()
end