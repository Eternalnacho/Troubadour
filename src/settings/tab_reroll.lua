-- MOD LIST CONFIG TAB UI
local troC = Troubadour.UI.mod_colours
local Row, Col = Troubadour.UI.create_row, Troubadour.UI.create_column
local Text, Num_Input = Troubadour.UI.create_text_node, Troubadour.UI.create_num_input_node
local TroUIBox = Troubadour.UI.create_UIBox_generic_options_custom

function TRO_reroll_tab()
  local reroll_cost = G.STATES == G.STATES.RUN and G.GAME.current_round and G.GAME.current_round.reroll_cost or 5
  Troubadour.REROLL.reroll_limit_price = '$'..(math.summ(tro_config.reroll_limit + reroll_cost - 1) - math.summ(reroll_cost - 1))
  return TroUIBox({
    padding = 0.15, minw = 7, emboss = 0.05, bg_colour = G.C.BLACK,
    contents = {
      Col { padding = 0.2, colour = G.C.CLEAR, nodes = {
        Row { padding = 0.05, r = 0.1, outline = 1, outline_colour = troC.outline_colour, nodes = {
          Text { align = "tm", text = "Reroll Settings", scale = 0.7 }
        }},
        Row { nodes = {
          Col { r = 0.2, colour = troC.colour, emboss = 0.05, nodes = {
            Row { nodes = {
              Col { align = 'cr', nodes = {
                Row { align = 'cr', nodes = {
                  create_toggle({
                    align = 'cr',
                    w = 0, h = 0,
                    active_colour = troC.buttons,
                    label = 'Enable Auto Reroll?',
                    callback = Troubadour.UI.update_TRO_config,
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
                      Troubadour.REROLL.reroll_limit_price = '$'..(math.summ(tro_config.reroll_limit + r_cost - 1) - math.summ(r_cost - 1))
                    end
                  },
                  Text { ref_table = Troubadour.REROLL, ref_value = 'reroll_limit_price', scale = 0.4 }
                }},
                Row { padding = 0.0 },
                Row { padding = 0.05, nodes = {
                  Text { text = "Savings Threshold: $", scale = 0.4 },
                  Num_Input{ id = "TRO_set_spend_limit",
                    colour = tro_config.enable_auto_reroll and troC.active or troC.inactive,
                    hooked_colour = tro_config.enable_auto_reroll and darken(troC.active, 0.3) or troC.inactive,
                    ref_value = "reroll_spend_limit", default = 25,
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