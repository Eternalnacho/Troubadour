local T = Troubadour.UI

function G.FUNCS.Troubadour_new_mod_folder()
  Troubadour.Folder({
    name = Troubadour.new_folder_name
  })
  G.FUNCS.mods_button()
end

function G.FUNCS.Troubadour_delete_folders()
  for _, Folder in pairs(Troubadour.Folders) do
    if Folder.delete_pending then Folder:delete() end
  end
  G.FUNCS.mods_button()
end

function G.FUNCS.Troubadour_update_folder_items(args)
  if not args or not args.cycle_config then return end
  SMODS.GUI.DynamicUIManager.updateDynamicAreas({
      ["TroubadourFolderItems"] = Troubadour.UIDEF.modFolderDynamicList(Troubadour.ACTIVE_FOLDER, args.cycle_config.current_option)
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