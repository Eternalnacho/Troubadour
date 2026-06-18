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

function G.FUNCS.Troubadour_create_mod_folder_window(e)
  G.FUNCS.overlay_menu{ definition = Troubadour.UIDEF.createModFolderWindow() }
  G.OVERLAY_MENU:recalculate()
end

function G.FUNCS.Troubadour_delete_mod_folder_window(e)
  G.FUNCS.overlay_menu{ definition = Troubadour.UIDEF.deleteModFolderWindow() }
  G.OVERLAY_MENU:recalculate()
end