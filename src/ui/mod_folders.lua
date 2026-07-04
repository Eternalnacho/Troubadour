local m = assert(SMODS.load_file("src/mods_page/helper.lua"))()
local T = Troubadour.UI

-- MOD FOLDER POPUP WINDOWS

function Troubadour.UIDEF.modFolderDynamicList(Folder, page)
  local scale = 0.75
  local _, __, showingList, startIndex, endIndex, modsRowPerPage, modsColPerRow = m.recalculateModFolder(Folder, page)

  local modNodes = {}
  -- If no mods are loaded, show a default message
  if showingList == false then
    table.insert(modNodes, T.Row { padding = 0, nodes = {
        T.Text { text = localize('b_no_mods'), shadow = true, scale = scale * 0.5, colour = G.C.UI.TEXT_DARK }
      }})
  else
    local modCount = 0
    local id = 0
    local current_row = {}

    for _, condition in ipairs({
      function(mod) return not mod.can_load and not mod.disabled end,
      function(mod) return mod.can_load and mod.config_tab end,
      function(mod) return mod.can_load and not mod.config_tab end,
      function(mod) return mod.disabled end,
    }) do
      for _, item in ipairs(Folder.items) do
        if modCount >= modsRowPerPage * modsColPerRow then break end
        if condition(SMODS.Mods[item.id]) then
          id = id + 1
          if id >= startIndex and id <= endIndex then
            table.insert(current_row, Troubadour.UIDEF.modListIcon(SMODS.Mods[item.id]))
            modCount = modCount + 1
            if math.fmod(modCount, modsColPerRow) == 0 then
              table.insert(modNodes, T.Row { padding = 0, align = "lc", nodes = current_row })
              current_row = {}
            end
          end
        end
      end
    end
    if #current_row > 0 then
      table.insert(modNodes, T.Row { padding = 0, align = "lc", nodes = current_row })
    end
  end

  return T.Col { nodes = {
    T.Row { nodes = {
      T.Col { r = 0.1, padding = 0, minw = 1.4 * modsColPerRow, nodes = modNodes },
    }}
  }}
end

Troubadour.UIDEF.addItemWindow = function(Folder)
  local result_ui

  return create_UIBox_generic_options({
    colour = G.C.BLACK,
    back_func = Folder and "Troubadour_open_folder_" .. Folder.name or 'mods_button',
    contents = {result_ui}
  })
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
  local get_folder_node = function(Folder)
    Troubadour.defer(function() Folder.delete_pending = false end)
    return T.Col({},
      {
        Troubadour.Tile({
          ref_table = Folder,
          ref_value = 'delete_pending',
          object = Folder.UI.label(Folder, 1.5).config.object,
          object_args = { w = 1.5, h = nil, colour = G.C.BLUE },
          colour_override = {
            enabled = darken(G.C.MULT, 0.5)
          },
        }):render(),
      }
    )
  end
  local get_row = function(row)
    local ret = T.Row({align = 'cl', minw = 1, padding = 0.1}, {})
    for i = 1, 4 do
      if Troubadour.FolderIndex[i + 4 * (row - 1)] then
        table.insert(ret.nodes, get_folder_node(Troubadour.FolderIndex[i + 4 * (row - 1)]))
      end
    end
    return ret
  end
  
  local folderRows = {}
  for i = 1, 4 do
    table.insert(folderRows, get_row(i))
  end

  local result_ui = T.Col(
    {
      padding = 0.15, r = 0.2, colour = T.C.inactive, minw = 10
    },
    {
      T.Row ({}, folderRows),
      T.Row ({}, {
        UIBox_button({
          label = { localize("b_tro_delete_mod_folder") },
          shadow = true,
          scale = 0.4,
          colour = darken(G.C.MULT, 0.1),
          button = "Troubadour_delete_folders",
          minh = 0.7,
          minw = 3,
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