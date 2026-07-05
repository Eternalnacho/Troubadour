local T = Troubadour.UI

-- Folder Window UI Definitions
local window_funcs = {
  mainWindow = function(Folder)
    local scale = 0.75
    local currentPage, pageOptions, showingList, _, _, dminh, dminw = Folder.UI.recalculateList(Folder)
    Troubadour.defer(function() G.FUNCS.Troubadour_update_folder_items({cycle_config = {}}) end)

    return create_UIBox_generic_options({
      colour = G.C.BLACK,
      outline_colour = T.C.outline_colour,
      back_func = "Troubadour_close_folder_" .. Folder.name,
      contents = {
        T.Row { minh = 1.5 * dminh + 1, minw = 1.5 * dminw + 1, r = 0.1, colour = G.C.BLACK, nodes = {
          T.Col { nodes = {
            T.Col { r = 0.1, nodes = {
              -- title row
              T.Row ({ padding = 0 }, {
                T.Col ({ padding = 0.1, minw = dminw, outline = 1, r = 0.1}, {
                  T.Text { text = Folder.name, shadow = true, scale = scale, colour = G.C.UI.TEXT_LIGHT },
                })
              }),
              -- dynamic content rendered in this row container
              T.Row { minh = dminh + 1, minw = dminw + 1,
                nodes = {
                  { n = G.UIT.O, config = { align = "cm", id = 'TroubadourFolderItems', object = Moveable() } },
                }
              },
              -- empty row for spacing
              T.Row { padding = 0.8 },
              -- folder controls
              T.Row { padding = 0.5, nodes = {
                -- Remove Mod button (only appears if mods found)
                showingList and Folder.UI.button('b_tro_remove_item', darken(G.C.MULT, 0.1), "Troubadour_delete_mod_folder_window")
                  or nil,
                -- Page Selector (only appears if mods found)
                showingList and T.Col { nodes = {
                  SMODS.GUI.createOptionSelector({
                    colour = T.C.active,
                    scale = 0.8,
                    options = pageOptions,
                    opt_callback = 'Troubadour_update_folder_items',
                    no_pips = true,
                    current_option = ( currentPage )
                  })
                }} or nil,
                -- Add Mod Button
                Folder.UI.button('b_tro_add_item', G.C.BOOSTER, "Troubadour_add_item_to_blargle"),
              }},
            }}
          }}
        }}
      }
    })
  end,

  modList = function(Folder, page)
    local scale = 0.75
    local _, __, showingList, startIndex, endIndex, modsRowPerPage, modsColPerRow = Folder.UI.recalculateList(Folder, page)

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
  end,

  addItemWindow = function(Folder)
    local result_ui

    return create_UIBox_generic_options({
      colour = G.C.BLACK,
      back_func = Folder and "Troubadour_open_folder_" .. Folder.name or 'mods_button',
      contents = {result_ui}
    })
  end
}

return window_funcs