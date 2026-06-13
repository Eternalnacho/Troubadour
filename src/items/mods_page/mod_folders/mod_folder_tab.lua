local m = assert(SMODS.load_file("src/items/mods_page/modpage_helper.lua"))()
local Row, Col, Text = Troubadour.UI.create_row, Troubadour.UI.create_column, Troubadour.UI.create_text_node

function Troubadour.UIDEF.statModFolderPage()
  local scale = 0.75
  local currentPage, pageOptions, showingList, _, _, dminh, dminw = m.recalculateModFoldersList()
  return Row { minh = dminh + 1, minw = 5.75 * dminw + 1, r = 0.1, padding = 0.05, colour = G.C.BLACK, nodes = {
    -- row container
    Col { padding = 0.05, nodes = {
      -- column container
      Col { minw = 5, padding = 0.05, r = 0.1, colour = G.C.CLEAR, nodes = {
        -- title row
        Row { padding = 0.05, nodes = {
          Col { nodes = {
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
          Col { nodes = {
            Troubadour.UIDEF.modlist_header_icon('tro_list', {x = 0, y = 0}, 'Troubadour_modlist_button', 'TRO_mod_list')
          }},
          Col { nodes = {
            Troubadour.UIDEF.modlist_header_icon('tro_folder', {x = 0, y = 0}, 'Troubadour_mod_folder_button', 'TRO_mod_folder_page')
          }},
          Col { nodes = {
            Troubadour.UIDEF.modlist_header_icon('mod_tags', {x = 2, y = 0}, 'Troubadour_modlist_config', 'TRO_config')
          }},
        }},
        -- add some empty rows for spacing
        Row { padding = 0.05 },
        Row { padding = 0.05 },
        -- dynamic content rendered in this row container
        -- list of 4 x 4 mods on the current page
        Row { padding = 0.05, minh = dminh + 1, minw = dminw + 1,
          nodes = {
            { n = G.UIT.O, config = { align = "cm", id = 'modFolderList', object = Moveable() } },
          }
        },
        -- another empty row for spacing
        Row { padding = 0.8 },
        -- page selector
        -- does not appear when list of mods is empty
        Row { padding = 0.5, nodes = {
          -- Spacer Column
          Col { padding = 0, minw = 3 },
          -- Page Selector
          showingList and Col { nodes = {
            SMODS.GUI.createOptionSelector({
              scale = 0.8,
              options = pageOptions,
              opt_callback = 'Troubadour_update_mod_folder_list',
              no_pips = true,
              current_option = ( currentPage )
            })
          }} or nil,
          -- Create Folder Button
          Col { nodes = {
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
    table.insert(modNodes, Row { padding = 0,
      nodes = { Text { text = localize('b_no_mod_folders'), shadow = true, scale = scale * 0.5, colour = G.C.UI.TEXT_DARK } }
    })
  else
    local folderCount = 0
    local id = 0
    local current_row = {}
    for _, folder in ipairs(Troubadour.folders) do
      if folderCount >= foldersRowPerPage * foldersColPerRow then break end
      id = id + 1
      if id >= startIndex and id <= endIndex then
        table.insert(current_row, Troubadour.UIDEF.create_folder_box(folder, scale * 0.5))
        folderCount = folderCount + 1
        if math.fmod(folderCount, foldersColPerRow) == 0 then
          table.insert(modNodes, Row { padding = 0, align = "lc", nodes = current_row })
          current_row = {}
        end
      end
    end
    if #current_row > 0 then
      table.insert(modNodes, Row { padding = 0, align = "lc", nodes = current_row })
    end
  end

  return Col { r = 0.1, align = "cm", padding = 0, nodes = modNodes }
end

function Troubadour.UIDEF.create_folder_box(folder, scale)
  local colour, bg_colour, text_colour = Troubadour.ICONS.get_mod_popup_colours({ can_load = true })
  local label_nodes = {}
  table.insert(label_nodes, Row {
    nodes = {{
      n = G.UIT.O,
      config = {
        object = SMODS.UIScrollBox({
          content = DynaText({
            string = folder.name,
            colours = { text_colour or G.C.UI.TEXT_LIGHT },
            shadow = true,
            scale = scale,
          }),
          container = { config = { can_collide = false } },
          overflow = {
            node_config = { no_overflow = "h", w = 3 },
            config = { can_collide = false }
          },
          sync_mode = "progress",
          scroll_move = function(self, dt)
            self.real_progress = ((self.real_progress or 0) + G.real_dt / 8) % 1
            if self.real_progress < 0.25 then
              self.scroll_progress.x = 0
            elseif self.real_progress > 0.75 then
              self.scroll_progress.x = 1
            else
              self.scroll_progress.x = (self.real_progress - 0.25) / 0.5
            end
          end,
        })
      }
    }}
  })

  return Col { align = "cm", padding = 0.05, nodes = {
      Col { padding = 0.05, align = "cm", colour = bg_colour, emboss = 0.1, r = 0.1, minw = 1.5, minh = 1, nodes = {
        Col { padding = 0.1, align = "lc", minw = 5.5, minh = 1, maxh = 1.4, emboss = 0.05, r = 0.1,
          colour = colour, shadow = true, shadow_height = 0.5, hover = true,
          -- button = "Troubadour_open_folder_" .. folder.name,
          nodes = {
            Col {
              align = "cm",
              --nodes = { PUT FOLDER ICON HERE }
            },
            Col {
              align = "lc",
              nodes = label_nodes
            },
          }},
        Col { padding = 0.05, align = "cm", nodes = {
          Row { nodes = {
            -- create_toggle({
            --   label = '',
            --   ref_table = folder,
            --   ref_value = 'should_enable',
            --   col = true, hide_label = true,
            --   w = 0, h = 0.2, scale = 1,
            --   callback = (function(_set_toggle)
            --     -- THIS IS WHAT WILL MASS ENABLE/DISABLE MODS IN FOLDER
            --   end)
            -- })
          }},
        }}
      }}
    }}
end
