local F = Troubadour.FUNCS
local T = Troubadour.UI

--

function Troubadour.UIDEF.statModFolderPage()
  local scale = 0.75
  local currentPage, pageOptions, showingList, _, _, dminh, dminw = F.recalculateModFoldersList()
  return T.Row { minh = dminh + 1, minw = 5.75 * dminw + 1, r = 0.1, padding = 0.05, colour = G.C.BLACK, nodes = {
    -- row container
    T.Col { nodes = {
      -- column container
      T.Col { minw = 5, r = 0.1, colour = G.C.CLEAR, nodes = {
        -- title row
        T.Row { nodes = {
          T.Col { nodes = {
            UIBox_button({
              label = { localize('b_mod_list') },
              shadow = true,
              scale = scale * 0.85,
              colour = G.C.BOOSTER,
              button = "openModsDirectory",
              minh = scale,
              minw = 4.5
            }),
          }},
          T.Col { nodes = {
            Troubadour.UIDEF.modHeaderIcon('tro_list', {x = 0, y = 0}, 'Troubadour_modlist_button', 'TRO_mod_list')
          }},
          T.Col { nodes = {
            Troubadour.UIDEF.modHeaderIcon('tro_folder', {x = 0, y = 0}, 'Troubadour_mod_folder_button', 'TRO_mod_folder_page')
          }},
          T.Col { nodes = {
            Troubadour.UIDEF.modHeaderIcon('mod_tags', {x = 2, y = 0}, 'Troubadour_modlist_config', 'TRO_mod_page_config')
          }},
        }},
        -- add an empty row for spacing
        T.Row { padding = 0.1 },
        -- dynamic content rendered in this row container
        -- list of 4 x 4 mods on the current page
        T.Row { minh = dminh + 1, minw = dminw + 1,
          nodes = {
            { n = G.UIT.O, config = { align = "cm", id = 'modFolderList', object = Moveable() } },
          }
        },
        -- another empty row for spacing
        T.Row { padding = 0.8 },
        -- page selector
        -- does not appear when list of mods is empty
        T.Row { padding = 0.5, nodes = {
          -- Spacer Column
          T.Col ({ padding = 0, minw = 3 },
            {
              UIBox_button({
                label = { localize('b_tro_delete_mod_folder') },
                shadow = true,
                scale = 0.4,
                colour = darken(G.C.MULT, 0.1),
                button = "Troubadour_delete_mod_folder_window",
                minh = 0.7,
                minw = 3,
              })
            }
          ),
          -- Page Selector
          showingList and T.Col { nodes = {
            SMODS.GUI.createOptionSelector({
              colour = T.C.active,
              scale = 0.8,
              options = pageOptions,
              opt_callback = 'Troubadour_update_mod_folder_list',
              no_pips = true,
              current_option = ( currentPage )
            })
          }} or nil,
          -- Create Folder Button
          T.Col { nodes = {
            UIBox_button({
              label = { localize('b_tro_create_mod_folder') },
              shadow = true,
              scale = 0.4,
              colour = G.C.BOOSTER,
              button = "Troubadour_create_mod_folder_window",
              minh = 0.7,
              minw = 3,
            })
          }},
        }},
      }}
    }}
  }}
end

function Troubadour.UIDEF.modFolderList(page)
  local scale = 0.75
  local _, __, showingList, startIndex, endIndex, foldersRowPerPage, foldersColPerRow = F.recalculateModFoldersList(page)
  local modNodes = {}

  -- If no mod folders exist, show a default message
  if showingList == false then
    table.insert(modNodes, T.Row { padding = 0,
      nodes = { T.Text { text = localize('b_tro_no_mod_folders'), shadow = true, scale = scale * 0.5, colour = G.C.UI.TEXT_DARK } }
    })
  else
    local folderCount = 0
    local id = 0
    local current_row = {}
    for _, Folder in ipairs(Troubadour.FolderIndex) do
      if folderCount >= foldersRowPerPage * foldersColPerRow then break end
      id = id + 1
      if id >= startIndex and id <= endIndex then
        table.insert(current_row, Folder.UI.render(Folder))
        folderCount = folderCount + 1
        if math.fmod(folderCount, foldersColPerRow) == 0 then
          table.insert(modNodes, T.Row { padding = 0, align = "lc", nodes = current_row })
          current_row = {}
        end
      end
    end
    if #current_row > 0 then
      table.insert(modNodes, T.Row { padding = 0, align = "lc", nodes = current_row })
    end
  end

  return T.Col { r = 0.1, align = "cm", padding = 0, nodes = modNodes }
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
        T.Col ({ padding = 0, minw = 6 },
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
          minh = 0.6, maxh = 0.6, minw = 3, maxw = 2,
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
          object = Folder.UI.label(Folder.name, 1.5).config.object,
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