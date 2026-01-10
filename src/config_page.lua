-- CONFIG TAG UI
function SMODS.current_mod.config_tab()
  local reroll_cost = G.STATES == G.STATES.RUN and G.GAME.current_round and G.GAME.current_round.reroll_cost or 5
  local reroll_limit_price = math.summ(tro_config.reroll_limit + reroll_cost - 1) - math.summ(reroll_cost - 1)
  local reroll_limit_text = TRO.UI.create_num_input_node({
    colour = tro_config.enable_auto_reroll and G.C.RED or darken(copy_table(G.C.GREY), 0.5),
    hooked_colour = tro_config.enable_auto_reroll and darken(copy_table(G.C.RED), 0.3) or darken(copy_table(G.C.GREY), 0.5),
    ref_value = "reroll_limit", default = 30
  })

  return {n = G.UIT.ROOT, config = {
    r = 0.1,                    -- roundness of the corners
    minw = 7,
    align = "cm",
    colour = G.C.BLACK,
    emboss = 0.05,              -- how much the node is *raised* from its parent
    },
    nodes =
    {
      TRO.UI.create_column({
        nodes = {
          TRO.UI.create_row({nodes = {
            TRO.UI.create_column{
              r = 0.1,
              align = "cm",
              colour = G.C.GREY,
              emboss = 0.05,
              nodes = {
                create_slider({label = 'Joker Collection Width', label_scale = 0.45, w = 4, h = 0.3, ref_table = tro_config, ref_value = 'gallery_width', min = 5, max = 11}),
                create_slider({label = 'Joker Collection Height', label_scale = 0.45, w = 4, h = 0.3, ref_table = tro_config, ref_value = 'gallery_height', min = 3, max = 5}),
              }
            }
          }}),
          TRO.UI.create_row({nodes = {
            TRO.UI.create_column{
              r = 0.1,
              align = "cm",
              nodes = {
                TRO.UI.create_row({minh = 0.65, align = 'cr', nodes = { create_toggle({
                  align = 'cr',
                  label = 'Enable Auto Reroll?',
                  callback = TRO.UI.update_TRO_config,
                  ref_table = tro_config,
                  ref_value = 'enable_auto_reroll'
                })
              }}),
              TRO.UI.create_row({minh = 0.65, align = 'cr', nodes = { create_toggle({
                align = 'cr',
                label = 'Skip Reroll Animations?',
                active_colour = tro_config.enable_auto_reroll and G.C.RED or darken(copy_table(G.C.GREY), 0.5),
                ref_table = tro_config,
                ref_value = 'skip_reroll_anims'
              })
              }}),
              }
            }
          }}),
          TRO.UI.create_row({minh = 0.65, nodes = {
            TRO.UI.create_text_node({text = "Reroll Limit: ",
            scale = 0.4}), reroll_limit_text,
            TRO.UI.create_text_node({text = "$"..reroll_limit_price, scale = 0.4})
          }}),
        }
      }),
    }
  }
end

function SMODS.current_mod.extra_tabs()
	return {
		{
			label = 'Mods List',
			tab_definition_function = function()
				return {
          n = G.UIT.ROOT,
          config = { r = 0.1, minw = 7, align = "cm", colour = G.C.BLACK, emboss = 0.05 },
          nodes =
          {
            {
              n = G.UIT.C,
              config = { align = "bm", padding = 0.05, colour = G.C.CLEAR },
              nodes =
              {
                TRO.UI.create_row({ nodes = {
                  TRO.UI.create_column{
                    align = "cm",
                    nodes = {
                      TRO.UI.create_row({ minh = 0.65, align = 'cr',
                        TRO_dark_tooltip = 'TRO_icons_only',
                        nodes = { create_toggle({
                          align = 'cr',
                          label = 'Use Shortened Mods Page?',
                          callback = TRO.UI.update_TRO_config,
                          ref_table = tro_config,
                          ref_value = 'mod_icons_only'
                        })
                      }}),
                      TRO.UI.create_row({ minh = 0.65, align = 'cr',
                        TRO_dark_tooltip = 'TRO_ctrls_extra',
                        nodes = { create_toggle({
                          align = 'cr',
                          label = 'Switch Click Controls?',
                          ref_table = tro_config,
                          ref_value = 'invert_tile_controls'
                        })
                      }}),
                    }
                  }
                }}),
                TRO.UI.create_row({nodes = {
                  TRO.UI.create_column{align = "cm", r = 0.1, colour = G.C.GREY, emboss = 0.05,
                    nodes = {
                      create_slider({label = 'Mod List Height', label_scale = 0.45, w = 4, h = 0.3,
                        colour = tro_config.mod_icons_only and G.C.RED or darken(copy_table(G.C.GREY), 0.5),
                        ref_table = tro_config, ref_value = 'mod_page_height',
                        min = 4, max = 6
                      }),
                      create_slider({label = 'Mod List Width', label_scale = 0.45, w = 4, h = 0.3,
                        colour = tro_config.mod_icons_only and G.C.RED or darken(copy_table(G.C.GREY), 0.5),
                        ref_table = tro_config, ref_value = 'mod_page_width',
                        min = 7, max = 13
                      }),
                    }
                  }
                }}),
              }
            }
          }
        }
        end,
		},
	}
end

function TRO.UI.update_TRO_config()
  if TRO.coll_from_button then
    TRO.UI.rerender(TRO.UI.config_from_coll, true)
  else
    TRO.UI.rerender(create_UIBox_mods, true)
  end
end