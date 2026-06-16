local T = Troubadour.UI

function G.FUNCS.Troubadour_new_mod_folder()

end

function G.FUNCS.Troubadour_create_mod_folder_window(e)
  G.FUNCS.overlay_menu{ definition = Troubadour.UIDEF.createModFolderWindow() }
  G.OVERLAY_MENU:recalculate()
end

Troubadour.UIDEF.createModFolderWindow = function()
  Troubadour.UI.folder_name = ''
  local result_ui = T.Row(
		{
      padding = 0.15,
      r = 0.2,
      colour = T.C.inactive,
      minw = 10,
    },
    {
      T.Row ({}, {
        T.Col ({padding = 0, miw = 6},
          {
            create_text_input({
              w = 4,
              max_length = 32,
              ref_table = Troubadour.UI,
              ref_value = "folder_name",
              extended_corpus = true,
              id = "Troubadour_folder_name_input",
              prompt_text = localize("b_tro_enter_mod_folder_name"),
              callback = function()
                -- do stuff
              end,
            }),
          }
        ),
        T.Col{},
        UIBox_button({
          label = { localize("b_tro_create_folder") },
          col = true,
          colour = T.C.active,
          scale = 0.4,
          minh = 0.6,
          maxh = 0.6,
          minw = 3,
          maxw = 2,
          button = "Troubadour_new_mod_folder",
        }),
      })
    }
	)
	return create_UIBox_generic_options({
    colour = G.C.BLACK,
    back_func = 'mods_button',
    contents = {result_ui}
  })
end