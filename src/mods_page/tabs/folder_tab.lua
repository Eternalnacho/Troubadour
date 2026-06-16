local m = assert(SMODS.load_file("src/mods_page/helper.lua"))()
local T = Troubadour.UI

function Troubadour.UIDEF.statModFolderPage()
  local scale = 0.75
  local currentPage, pageOptions, showingList, _, _, dminh, dminw = m.recalculateModFoldersList()
  return T.Row { minh = dminh + 1, minw = 5.75 * dminw + 1, r = 0.1, padding = 0.05, colour = G.C.BLACK, nodes = {
    -- row container
    T.Col { padding = 0.05, nodes = {
      -- column container
      T.Col { minw = 5, padding = 0.05, r = 0.1, colour = G.C.CLEAR, nodes = {
        -- title row
        T.Row { padding = 0.05, nodes = {
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
            Troubadour.UIDEF.modlist_header_icon('tro_list', {x = 0, y = 0}, 'Troubadour_modlist_button', 'TRO_mod_list')
          }},
          T.Col { nodes = {
            Troubadour.UIDEF.modlist_header_icon('tro_folder', {x = 0, y = 0}, 'Troubadour_mod_folder_button', 'TRO_mod_folder_page')
          }},
          T.Col { nodes = {
            Troubadour.UIDEF.modlist_header_icon('mod_tags', {x = 2, y = 0}, 'Troubadour_modlist_config', 'Troubadour.config')
          }},
        }},
        -- add some empty rows for spacing
        T.Row { padding = 0.05 },
        T.Row { padding = 0.05 },
        -- dynamic content rendered in this row container
        -- list of 4 x 4 mods on the current page
        T.Row { padding = 0.05, minh = dminh + 1, minw = dminw + 1,
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
          T.Col { padding = 0, minw = 3 },
          -- Page Selector
          showingList and T.Col { nodes = {
            SMODS.GUI.createOptionSelector({
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
              label = { localize('b_create_mod_folder') },
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
  local _, __, showingList, startIndex, endIndex, foldersRowPerPage, foldersColPerRow = m.recalculateModFoldersList(page)
  local modNodes = {}

  -- If no mod folders exist, show a default message
  if showingList == false then
    table.insert(modNodes, T.Row { padding = 0,
      nodes = { T.Text { text = localize('b_no_mod_folders'), shadow = true, scale = scale * 0.5, colour = G.C.UI.TEXT_DARK } }
    })
  else
    local folderCount = 0
    local id = 0
    local current_row = {}
    for _, Folder in ipairs(Troubadour.FolderIndex) do
      if folderCount >= foldersRowPerPage * foldersColPerRow then break end
      id = id + 1
      if id >= startIndex and id <= endIndex then
        table.insert(current_row, Folder:render())
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
