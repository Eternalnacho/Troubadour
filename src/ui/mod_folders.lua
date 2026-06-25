local T = Troubadour.UI

-- MOD FOLDER POPUP WINDOWS

Troubadour.UIDEF.modFolderWindow = function(Folder)
  return T.UIBox({})
end


Troubadour.UIDEF.createModFolderWindow = function()
  Troubadour.new_folder_name = ''
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
              ref_table = Troubadour,
              ref_value = "new_folder_name",
              extended_corpus = true,
              id = "Troubadour_folder_name_input",
              prompt_text = localize("b_tro_enter_mod_folder_name"),
              callback = function()
                G.FUNCS.Troubadour_new_mod_folder()
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

Troubadour.UIDEF.deleteModFolderWindow = function()
  local get_folder_row = function(Folder)
    Troubadour.defer(function() Folder.delete_pending = false end)
    return T.Row({}, {
      T.Col({ align = "cl" }, { T.Text({ ref_table = Folder, ref_value = 'name', scale = 0.4 }) }),
      T.Col({ minw = 3 }),
      T.Col({ align = "cr" }, {
        create_toggle({
          label = '',
          ref_table = Folder,
          ref_value = 'delete_pending',
          col = true, hide_label = true,
          w = 0, h = 0.2, scale = 1,
          callback = (function(_set_toggle)
            if not Folder.delete_pending then
              Folder.delete_pending = nil
            end
          end)
        })
      }),
    })
  end

  local result_ui = T.Col ({ padding = 0.15, r = 0.2, colour = T.C.inactive, minw = 10 }, {})

  for _, Folder in ipairs(Troubadour.FolderIndex) do
    table.insert(result_ui.nodes, get_folder_row(Folder))
  end

  table.insert(result_ui.nodes,
    T.Row ({}, {
      UIBox_button({
        label = { localize("b_tro_delete_mod_folder") },
        col = true,
        colour = T.C.active,
        scale = 0.4,
        minh = 0.6,
        maxh = 0.6,
        minw = 3,
        maxw = 2,
        button = "Troubadour_delete_folders",
      }),
    }
  ))

	return create_UIBox_generic_options({
    colour = G.C.BLACK,
    back_func = 'mods_button',
    contents = {result_ui}
  })
end