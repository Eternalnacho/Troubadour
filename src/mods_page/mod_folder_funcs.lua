function G.FUNCS.Troubadour_new_mod_folder()
  Troubadour.Folder({ name = Troubadour.new_folder_name })
  G.FUNCS.mods_button()
end

function G.FUNCS.Troubadour_delete_folders()
  Troubadour.utils.for_each(Troubadour.Folders, function(Folder) if Folder.delete_pending then Folder:delete() end end)
  G.FUNCS.mods_button()
end

function G.FUNCS.Troubadour_update_folder_items(args)
  local Folder = Troubadour.ACTIVE_FOLDER
  if not args or not args.cycle_config or not Folder then return end
  SMODS.GUI.DynamicUIManager.updateDynamicAreas({
      ["TroubadourFolderItems"] = Folder.UI.modList(Folder, args.cycle_config.current_option)
  })
end

function G.FUNCS.Troubadour_update_folder_delete_queue(args)
  local Folder = Troubadour.ACTIVE_FOLDER
  if not args or not args.cycle_config or not Folder then return end
  SMODS.GUI.DynamicUIManager.updateDynamicAreas({
      ["TroubadourFolderDeleteQueue"] = Folder.UI.deleteList(Folder, args.cycle_config.current_option)
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
  local Folder = Troubadour.ACTIVE_FOLDER
  if not Folder then return end
  Folder.to_add = Folder.to_add or {}
  G.FUNCS.overlay_menu{ definition = Folder.UI.addItemWindow(Folder) }
  G.OVERLAY_MENU:recalculate()
end

function G.FUNCS.Troubadour_delete_item_from_folder(e)
  local Folder = Troubadour.ACTIVE_FOLDER
  if not Folder then return end
  Folder.to_remove = Folder.to_remove or {}
  G.FUNCS.overlay_menu{ definition = Folder.UI.removeItemWindow(Folder) }
  G.OVERLAY_MENU:recalculate()
end

function G.FUNCS.Troubadour_add_folder_items(e)
  if not Troubadour.ACTIVE_SEARCH or not Troubadour.ACTIVE_FOLDER then return end
  local Folder = Troubadour.ACTIVE_FOLDER
  for id, to_add in pairs(Folder.to_add) do
    if to_add then Folder:add_item(SMODS.Mods[id]) end
  end
  Troubadour.ACTIVE_SEARCH = nil
  Folder:open()
end

function G.FUNCS.Troubadour_delete_folder_items(e)
  if not Troubadour.ACTIVE_FOLDER or not Troubadour.ACTIVE_FOLDER.to_remove then return end
  local Folder = Troubadour.ACTIVE_FOLDER
  for id, to_remove in pairs(Folder.to_remove) do
    if to_remove then Folder:remove_item(SMODS.Mods[id]) end
  end
  Folder:open()
end