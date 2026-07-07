local T = Troubadour.UI

-- Folder Window UI Definitions
local window_funcs = {
  mainWindow = function(Folder)
    local scale = 0.75
    local currentPage, pageOptions, showingList, _, _, dminh, dminw = Folder.UI.recalculateList(Folder.items)
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
                Folder.UI.button('b_tro_add_item', G.C.BOOSTER, 'Troubadour_add_item_to_folder'),
              }},
            }}
          }}
        }}
      }
    })
  end,

  addItemWindow = function(Folder)
    local Searcher = Troubadour.Searcher()
    local addQueue = UIBox({ definition = Searcher:to_add(), config = {type = "cm"} })
    local currentPage, pageOptions, showingList, _, _, _, _ = Folder.UI.recalculateList(Searcher:get_list(), 1)
    Troubadour.defer(function() Searcher:update_list() end)
    return create_UIBox_generic_options({
      colour = G.C.BLACK,
      back_func = Folder and "Troubadour_open_folder_" .. Folder.name or 'mods_button',
      contents = {
        T.Row ({}, {
          -- Search Field
          T.Col ({ padding = 0.2, minh = 7.5, minw = 14 }, {
            T.Col ({}, {
              T.Row ({ padding = 0.1 }, {
                T.Col ({} , { Searcher:get_text_input() })
              }),
              T.Row ({ padding = 0.1 }),
              T.Row ({ minh = 5, minw = 9 }, {
                T.Col ({} , { { n = G.UIT.O, config = { align = "cm", id = 'TroubadourSearchResult', object = Moveable() } } })
              }),
              -- empty row for spacing
              T.Row ({ padding = 0.6 }),
              -- folder controls
              T.Row ({}, {
                -- Page Selector (only appears if mods found)
                showingList and T.Col { nodes = {
                  SMODS.GUI.createOptionSelector({
                    colour = T.C.active,
                    scale = 0.8,
                    options = pageOptions,
                    opt_callback = 'Troubadour_update_search',
                    no_pips = true,
                    id = 'Troubadour_search_page_opts',
                    current_option = ( currentPage )
                  })
                }} or nil
              })
            }),
            -- Spacer Column
            T.Col ({ padding = 0.2 }),
            -- "To-Add" queue
            T.Col ({}, {
              T.Row ({ padding = 0.1, r = 0.2}, { { n = G.UIT.O, config = { id = 'Troubadour_addQueue', object = addQueue } } }),
              T.Row ({ padding = 0.1 }),
              UIBox_button({ button = 'Troubadour_add_items', label = {"Add Items"}, colour = G.C.FILTER, minw = 3, minh = 0.7 }),
            }),
          }),
        })
      }
    })
  end,
}

return window_funcs