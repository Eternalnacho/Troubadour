-- MOD LIST CONFIG TAB UI
local troC = Troubadour.UI.mod_colours
local Row, Col, Text = Troubadour.UI.create_row, Troubadour.UI.create_column, Troubadour.UI.create_text_node
local TroUIBox = Troubadour.UI.create_UIBox_generic_options_custom

Troubadour.UI.mod_list_tab = function()
  return TroUIBox({
    minw = 7, padding = 0.15, emboss = 0.05, bg_colour = G.C.BLACK,
    contents = {
      Col { padding = 0.2, colour = G.C.CLEAR, nodes = {
        Row { padding = 0.1, r = 0.1, outline = 1, outline_colour = troC.outline_colour,
          nodes = { Text({ align = "tm", text = "Condense Mods Page", scale = 0.7 }) } },
        Row { nodes = {
          Col { r = 0.2, padding = 0.1, colour = troC.colour, nodes = {
            Row { minh = 0.65, align = 'cr',
              TRO_dark_tooltip = 'TRO_icons_only',
              nodes = { create_toggle({
                align = 'cr',
                active_colour = troC.buttons,
                label = 'Use Shortened Mods Page?',
                callback = Troubadour.UI.update_config,
                ref_table = tro_config,
                ref_value = 'mod_icons_only'
              })}
            },
            Row { minh = 0.65, align = 'cr',
              TRO_dark_tooltip = 'TRO_ctrls_extra' .. (tro_config.invert_tile_controls and '_i' or ''),
              nodes = { create_toggle({
                align = 'cr',
                active_colour = troC.buttons,
                label = 'Switch Click Controls?',
                callback = Troubadour.UI.update_config,
                ref_table = tro_config,
                ref_value = 'invert_tile_controls'
              })}
            },
            Row { nodes = {
              Col { r = 0.1, colour = G.C.GREY, emboss = 0.05, nodes = {
                create_slider({label = 'Mod List Height', label_scale = 0.45, w = 4, h = 0.3,
                  colour = tro_config.mod_icons_only and troC.active or darken(copy_table(G.C.GREY), 0.5),
                  ref_table = tro_config, ref_value = 'mod_page_height',
                  min = 4, max = 6
                }),
                create_slider({label = 'Mod List Width', label_scale = 0.45, w = 4, h = 0.3,
                  colour = tro_config.mod_icons_only and troC.active or darken(copy_table(G.C.GREY), 0.5),
                  ref_table = tro_config, ref_value = 'mod_page_width',
                  min = 7, max = 13
                }),
              }}
            }}
          }}
        }}
      }}
    }
  })
end