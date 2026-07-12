local T = Troubadour.UI

-- Folder Window UI Definitions

local window_funcs = {
  mainWindow = function(Folder)
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
                  T.Text { text = Folder.name, shadow = true, scale = 0.75, colour = G.C.UI.TEXT_LIGHT },
                })
              }),
              -- Spacer Row
              T.Row { padding = 0.2 },
              -- dynamic content rendered in this row container
              T.Row { minh = dminh + 1, minw = dminw + 1,
                nodes = {
                  { n = G.UIT.O, config = { align = "cm", id = 'TroubadourFolderItems', object = Moveable() } },
                }
              },
              -- Spacer Row
              T.Row { padding = 0.8 },
              -- folder controls
              T.Row { nodes = {
                -- Remove Mod button (only appears if mods found)
                showingList and Folder.UI.button('b_tro_remove_item', darken(G.C.MULT, 0.1), "Troubadour_delete_item_from_folder")
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
    local Searcher = Troubadour.Searcher({
      list = SMODS.mod_list,
      search_funcs = Folder.UI.search_funcs,
      exclude_funcs = Folder.UI.exclude_funcs,
    })
    Searcher.render_list = Folder.UI.addList
    local addQueue = UIBox({ definition = Folder.UI.addQueueUIBox(Folder), config = {type = "cm"} })
    local currentPage, pageOptions, showingList, _, _, _, _ = Folder.UI.recalculateList(Searcher:get_list(), 1)
    Troubadour.defer(function() Searcher:update_list() end)

    return create_UIBox_generic_options({
      colour = G.C.BLACK,
      back_func = Folder and "Troubadour_open_folder_" .. Folder.name or 'mods_button',
      contents = {
        T.Row ({ minh = 7.5, minw = 14 }, {
          T.Col ({}, {
            T.Col ({ r = 0.1 }, {
              -- Search Field
              T.Row { nodes = {
                T.Col ({}, {
                  T.Row ({}, { Searcher:get_text_input() })
                }),
              }},
              -- Spacer Row
              T.Row {},
              -- Search Result List
              T.Row ({ minh = 4.5, minw = 9 }, { { n = G.UIT.O, config = { id = 'TroubadourSearchResult', object = Moveable() } } }),
              -- Spacer Row
              T.Row {},
              -- Page Selector (only appears if mods found)
              showingList and SMODS.GUI.createOptionSelector({
                colour = T.C.active,
                scale = 0.8,
                options = pageOptions,
                opt_callback = 'Troubadour_update_search',
                no_pips = true,
                id = 'Troubadour_search_page_opts',
                current_option = ( currentPage )
              }) or nil
            }),
            -- Spacer Column
            T.Col ({ padding = 0.2 }),
            -- "To-Add" queue
            T.Col ({}, {
              T.Row ({ padding = 0.1, r = 0.2}, { { n = G.UIT.O, config = { id = 'Troubadour_addQueue', object = addQueue } } }),
              T.Row ({ padding = 0.1 }),
              UIBox_button({ button = 'Troubadour_add_folder_items', label = {"Add Items"}, colour = G.C.FILTER, minw = 3, minh = 0.7 }),
            }),
          })
        })
      }
    })
  end,

  removeItemWindow = function(Folder)
    Folder.to_remove = Folder.to_remove or {}
    local currentPage, pageOptions, _, _, _, dminh, dminw = Folder.UI.recalculateList(Folder.items)
    Troubadour.defer(function() G.FUNCS.Troubadour_update_folder_delete_queue({cycle_config = {}}) end)

    return create_UIBox_generic_options({
      colour = G.C.BLACK,
      outline_colour = T.C.outline_colour,
      back_func = "Troubadour_open_folder_" .. Folder.name,
      contents = {
        T.Row { minh = 1.5 * dminh + 1, minw = 1.5 * dminw + 1, r = 0.1, colour = G.C.BLACK, nodes = {
          T.Col { nodes = {
            T.Col { r = 0.1, nodes = {
              -- title row
              T.Row ({ padding = 0 }, {
                T.Col ({ padding = 0.1, minw = dminw, outline = 1, r = 0.1}, {
                  T.Text {
                    text = localize('b_tro_remove_placeholder') .. Folder.name,
                    shadow = true,
                    scale = 0.75,
                    colour = G.C.UI.TEXT_LIGHT
                  },
                })
              }),
              -- dynamic content rendered in this row container
              T.Row { minh = dminh + 1, minw = dminw + 1,
                nodes = {
                  { n = G.UIT.O, config = { align = "cm", id = 'TroubadourFolderDeleteQueue', object = Moveable() } },
                }
              },
              -- empty row for spacing
              T.Row { padding = 0.8 },
              -- folder controls
              T.Row { nodes = {
                -- Page Selector (only appears if mods found)
                T.Col { nodes = {
                  SMODS.GUI.createOptionSelector({
                    id = 'Troubadour_option_selector',
                    colour = T.C.active,
                    scale = 0.8,
                    options = pageOptions,
                    opt_callback = 'Troubadour_update_folder_items',
                    no_pips = true,
                    current_option = ( currentPage )
                  })
                }},
              }},
              -- Remove Mod button
              T.Row { nodes = { Folder.UI.button('b_tro_remove_item', darken(G.C.MULT, 0.1), "Troubadour_delete_folder_items"),}}
            }}
          }}
        }}
      }
    })
  end
}

return window_funcs