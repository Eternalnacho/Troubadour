local T = Troubadour.UI

function G.FUNCS.Troubadour_new_mod_folder()
  Troubadour.Folder({ name = Troubadour.new_folder_name })
  G.FUNCS.mods_button()
end

function G.FUNCS.Troubadour_delete_folders()
  Troubadour.utils.for_each(Troubadour.Folders, function(Folder) if Folder.delete_pending then Folder:delete() end end)
  G.FUNCS.mods_button()
end

function G.FUNCS.Troubadour_update_folder_items(args)
  if not args or not args.cycle_config then return end
  if not Troubadour.ACTIVE_FOLDER then return end
  local Folder = Troubadour.ACTIVE_FOLDER
  SMODS.GUI.DynamicUIManager.updateDynamicAreas({
      ["TroubadourFolderItems"] = Folder.UI.modList(Folder, args.cycle_config.current_option)
  })
end

function G.FUNCS.Troubadour_create_mod_folder_window(e)
  G.FUNCS.overlay_menu{ definition = Troubadour.UIDEF.createModFolderWindow() }
  G.OVERLAY_MENU:recalculate()
end

function G.FUNCS.Troubadour_delete_mod_folder_window(e)
  G.FUNCS.overlay_menu{ definition = Troubadour.UIDEF.deleteModFolderWindow() }
  G.OVERLAY_MENU:recalculate()
end

function G.FUNCS.Troubadour_add_item_to_folder(e)
  if not Troubadour.ACTIVE_FOLDER then return end
  local Folder = Troubadour.ACTIVE_FOLDER
  G.FUNCS.overlay_menu{ definition = Folder.UI.addItemWindow(Folder) }
  G.OVERLAY_MENU:recalculate()
end

function G.FUNCS.Troubadour_add_items(e)
  if not Troubadour.ACTIVE_SEARCH or not Troubadour.ACTIVE_FOLDER then return end
  local Folder = Troubadour.ACTIVE_FOLDER
  for id, to_add in pairs(Troubadour.ACTIVE_SEARCH.targets) do
    if to_add then Folder:add_item(SMODS.Mods[id]) end
  end
  Troubadour.ACTIVE_SEARCH = nil
  Folder:open()
end