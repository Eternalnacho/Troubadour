-- CONFIG TAB UI
local config_contents = assert(SMODS.load_file("src/settings/collection_pages.lua"))()
local troC = TRO.UI.mod_colours
local Root, Row, Col = TRO.UI.create_root_node, TRO.UI.create_row, TRO.UI.create_column
local Text, Num_Input = TRO.UI.create_text_node, TRO.UI.create_num_input_node
local TroUIBox = TRO.UI.create_UIBox_generic_options_custom

SMODS.current_mod.ui_config = {
  colour = troC.colour,
  outline_colour = troC.outline_colour,
  tab_button_colour = darken(troC.buttons, 0.2),
  back_colour = troC.active,
  -- misc. colours
  author_colour = HEX('E9B800'),
}

local function is_chosen(tab)
  return TRO.LAST_OPEN_TAB == tab
end

local function choose_tab(tab)
    TRO.LAST_OPEN_TAB = tab
end

function SMODS.current_mod.config_tab()
  local vertical_tabs = {}
  choose_tab "Jokers"

  TRO.utils.for_each(config_contents.pages, function(page)
    table.insert(vertical_tabs, {
      label = page.label..'s',
      chosen = is_chosen(page.label..'s'),
      tab_definition_function = function (...)
        return Root { r = 0.1, nodes = {
          Col { nodes = {
            Row { minh = math.max(1, #config_contents.pages), nodes = {
              Col { padding = 0.1, r = 0.2, minh = math.max(1, #config_contents.pages * 2 / 3),
                    colour = troC.colour, outline = 1, outline_colour = troC.outline_colour, emboss = 0.05, nodes = {
                  Row { nodes = {
                    Col { r = 0.1, colour = G.C.GREY, emboss = 0.05, nodes = {
                      create_slider({ label = page.label..' Page Width', label_scale = 0.45, w = 4, h = 0.3, colour = troC.active,
                        ref_table = tro_config, ref_value = page.ref_value_w or ('gallery_width'..page.label:lower()), min = page.minw, max = page.maxw }),
                      create_slider({ label = page.label..' Page Height', label_scale = 0.45, w = 4, h = 0.3, colour = troC.active,
                        ref_table = tro_config, ref_value = page.ref_value_h or ('gallery_height'..page.label:lower()), min = page.minh, max = page.maxh }),
                    }}
                  }}
                }}
              }}
            }}
          }}
      end
    })
  end)

  return TroUIBox({
    minw = 0.0, padding = 0.2, emboss = 0.05, bg_colour = G.C.BLACK,
    contents = {
      Row { padding = 0.1, r = 0.1, outline = 1, outline_colour = troC.outline_colour,
        nodes = { Text{ align = "tm", text = "Widen Collections", scale = 0.7 } } },
      Row { padding = 0, align = "tl", colour = G.C.CLEAR,
        nodes = {
          TRO.UI.create_column_tabs({
            tab_alignment = 'tl',
            text_scale = 0.4,
            snap_to_nav = true,
            colour =  G.C.CLEAR, -- G.C.RED,
            tabs = vertical_tabs
          })
        }
      },
    }
  })
end

G.FUNCS.TRO_settings_change_tab = function(e)
  if not e then return end
  local tab_contents = e.UIBox:get_UIE_by_ID('TRO_settings_tab_contents')
  if not tab_contents then return end
  -- Same tab, don't rebuild it.
  if tab_contents.config.oid == e.config.id then return end
  if tab_contents.config.old_chosen then tab_contents.config.old_chosen.config.chosen = nil end

  tab_contents.config.old_chosen = e
  e.config.chosen = 'vert'

  tab_contents.config.oid = e.config.id
  tab_contents.config.object:remove()
  tab_contents.config.object = UIBox{
      definition = e.config.ref_table.tab_definition_function(e.config.ref_table.tab_definition_function_args),
      config = {offset = {x=0,y=0}, parent = tab_contents, type = 'cm'}
    }
  tab_contents.UIBox:recalculate()
end

function SMODS.current_mod.extra_tabs()
	return {
		{
			label = 'Mods List',
			tab_definition_function = function()
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
                      callback = TRO.UI.update_TRO_config,
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
                      callback = TRO.UI.update_TRO_config,
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
		},
    {
			label = 'Reroller',
			tab_definition_function = function()
        local reroll_cost = G.STATES == G.STATES.RUN and G.GAME.current_round and G.GAME.current_round.reroll_cost or 5
        TRO.REROLL.reroll_limit_price = '$'..(math.summ(tro_config.reroll_limit + reroll_cost - 1) - math.summ(reroll_cost - 1))
				return TroUIBox({
          padding = 0.15, minw = 7, emboss = 0.05, bg_colour = G.C.BLACK,
          contents = {
            Col { padding = 0.2, colour = G.C.CLEAR, nodes = {
              Row { padding = 0.05, r = 0.1, outline = 1, outline_colour = troC.outline_colour,
                nodes = { Text {align = "tm", text = "Reroll Settings", scale = 0.7} } },
              Row { nodes = {
                Col { r = 0.2, colour = troC.colour, emboss = 0.05, nodes = {
                  Row { nodes = {
                    Col { align = "cr", nodes = {
                      Row { align = 'cr', nodes = {
                        create_toggle({
                          align = 'cr',
                          w = 0, h = 0,
                          active_colour = troC.buttons,
                          label = 'Enable Auto Reroll?',
                          callback = TRO.UI.update_TRO_config,
                          ref_table = tro_config,
                          ref_value = 'enable_auto_reroll'
                        })
                      }},
                      Row { align = 'cr', nodes = {
                        create_toggle({
                          align = 'cr',
                          w = 0,
                          label = 'Skip Reroll Animations?',
                          active_colour = tro_config.enable_auto_reroll and troC.buttons or troC.inactive,
                          ref_table = tro_config,
                          ref_value = 'skip_reroll_anims'
                        })
                      }},
                    }}
                  }},
                  Row { padding = 0.1, nodes = {
                    Col { r = 0.15, colour = G.C.GREY, emboss = 0.05, nodes = {
                      Row { padding = 0.05, nodes = {
                        Text { text = "Reroll Limit: ", scale = 0.4 },
                        Num_Input { id = "TRO_set_reroll_limit",
                          colour = tro_config.enable_auto_reroll and troC.active or troC.inactive,
                          hooked_colour = tro_config.enable_auto_reroll and darken(troC.active, 0.3) or troC.inactive,
                          ref_value = "reroll_limit", default = 30,
                          callback = function()
                            local r_cost = G.STATES == G.STATES.RUN and G.GAME.current_round and G.GAME.current_round.reroll_cost or 5
                            TRO.REROLL.reroll_limit_price = '$'..(math.summ(tro_config.reroll_limit + r_cost - 1) - math.summ(r_cost - 1))
                          end
                        },
                        Text { ref_table = TRO.REROLL, ref_value = 'reroll_limit_price', scale = 0.4 }
                      }},
                      Row { padding = 0.0 },
                      Row { padding = 0.05, nodes = {
                        Text { text = "Savings Threshold: $", scale = 0.4 },
                        Num_Input{ id = "TRO_set_spend_limit",
                          colour = tro_config.enable_auto_reroll and troC.active or troC.inactive,
                          hooked_colour = tro_config.enable_auto_reroll and darken(troC.active, 0.3) or troC.inactive,
                          ref_value = "reroll_spend_limit", default = 25
                        }
                      }}
                    }}
                  }}
                }}
              }}
            }}
          }
        })
      end
		}
	}
end

function TRO.UI.update_TRO_config()
  if TRO.coll_from_button then
    TRO.UI.rerender(TRO.UI.config_from_coll, true)
  else
    G.ACTIVE_MOD_UI = SMODS.Mods["Troubadour"]
    TRO.UI.rerender(create_UIBox_mods, true)
  end
end

SMODS.current_mod.save_mod_config = function(tro)
  if type(tro_config.reroll_limit) ~= "number" then
    tro_config.reroll_limit = tonumber(tro_config.reroll_limit)
  end
  if type(tro_config.reroll_spend_limit) ~= "number" then
    tro_config.reroll_spend_limit = tonumber(tro_config.reroll_spend_limit)
  end
  SMODS.save_mod_config(tro)
end