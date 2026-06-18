-- MOD LIST CONFIG TAB UI
local T = Troubadour.UI

Troubadour.UIDEF.mod_list_tab = function()
  return T.UIBox({ minw = 0, padding = 0.2, emboss = 0.05, bg_colour = G.C.BLACK,
    contents = {
      T.Col ({ padding = 0 }, {
        T.Row ({ minw = 8, padding = 0.1, r = 0.1, outline = 1, outline_colour = T.C.outline_colour}, {
          T.Text { align = "tm", text = "Condense Mods Page", scale = 0.7 }
        }),
        T.Row { padding = 0.2 },
        T.Row { nodes = {
          T.Col ({ r = 0.2, padding = 0.1, colour = T.C.colour }, {
            T.Row ({ minh = 0.65, align = 'cr', TRO_dark_tooltip = 'TRO_icons_only' }, {
              create_toggle({
                align = 'cr',
                active_colour = T.C.buttons,
                label = 'Use Shortened Mods Page?',
                callback = Troubadour.UI.update_config,
                ref_table = Troubadour.config,
                ref_value = 'mod_icons_only'
              })
            }),
            T.Row ({ minh = 0.65, align = 'cr', TRO_dark_tooltip = 'TRO_ctrls_extra' .. (Troubadour.config.invert_tile_controls and '_i' or '') }, {
              create_toggle({
                align = 'cr',
                active_colour = T.C.buttons,
                label = 'Switch Click Controls?',
                callback = Troubadour.UI.update_config,
                ref_table = Troubadour.config,
                ref_value = 'invert_tile_controls'
              })
            }),
            T.Row { nodes = {
              T.Col ({ r = 0.1, colour = G.C.GREY, emboss = 0.05 }, {
                create_slider({label = 'Mod List Height', label_scale = 0.45, w = 4, h = 0.3,
                  colour = Troubadour.config.mod_icons_only and T.C.active or darken(copy_table(G.C.GREY), 0.5),
                  ref_table = Troubadour.config, ref_value = 'mod_page_height',
                  min = 4, max = 6
                }),
                create_slider({label = 'Mod List Width', label_scale = 0.45, w = 4, h = 0.3,
                  colour = Troubadour.config.mod_icons_only and T.C.active or darken(copy_table(G.C.GREY), 0.5),
                  ref_table = Troubadour.config, ref_value = 'mod_page_width',
                  min = 7, max = 13
                }),
              })
            }}
          })
        }}
      })
    }
  })
end