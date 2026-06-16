-- MOD LIST CONFIG TAB UI
local T = Troubadour.UI

Troubadour.UIDEF.reroll_tab = function()
  local reroll_cost = G.STATES == G.STATES.RUN and G.GAME.current_round and G.GAME.current_round.reroll_cost or 5
  Troubadour.REROLL.reroll_limit_price = '$'..(math.summ(Troubadour.config.reroll_limit + reroll_cost - 1) - math.summ(reroll_cost - 1))
  return T.UIBox({
    padding = 0.15, minw = 7, emboss = 0.05, bg_colour = G.C.BLACK,
    contents = {
      T.Col { padding = 0.2, nodes = {
        T.Row { r = 0.1, outline = 1, outline_colour = T.C.outline_colour, nodes = {
          T.Text { align = "tm", text = "Reroll Settings", scale = 0.7 }
        }},
        T.Row { nodes = {
          T.Col { r = 0.2, colour = T.C.colour, emboss = 0.05, nodes = {
            T.Row { nodes = {
              T.Col { align = 'cr', nodes = {
                T.Row { align = 'cr', nodes = {
                  create_toggle({
                    align = 'cr',
                    w = 0, h = 0,
                    active_colour = T.C.buttons,
                    label = 'Enable Auto Reroll?',
                    callback = Troubadour.UI.update_config,
                    ref_table = Troubadour.config,
                    ref_value = 'enable_auto_reroll'
                  })
                }},
                T.Row { align = 'cr', nodes = {
                  create_toggle({
                    align = 'cr',
                    w = 0,
                    label = 'Skip Reroll Animations?',
                    active_colour = Troubadour.config.enable_auto_reroll and T.C.buttons or T.C.inactive,
                    ref_table = Troubadour.config,
                    ref_value = 'skip_reroll_anims'
                  })
                }},
              }}
            }},
            T.Row { padding = 0.1, nodes = {
              T.Col ({ r = 0.15, padding = 0.1, colour = G.C.GREY, emboss = 0.05 }, {
                T.Row ({ align = 'cr'}, {
                  T.Text { text = "Reroll Limit:  ", scale = 0.4 },
                  T.Num {
                    id = "TRO_set_reroll_limit",
                    colour = Troubadour.config.enable_auto_reroll and T.C.active or T.C.inactive,
                    hooked_colour = Troubadour.config.enable_auto_reroll and darken(T.C.active, 0.3) or T.C.inactive,
                    ref_value = "reroll_limit", default = 30,
                    prompt_text = '' .. Troubadour.REROLL.reroll_limit_price,
                    callback = function()
                      local r_cost = G.STATES == G.STATES.RUN and G.GAME.current_round and G.GAME.current_round.reroll_cost or 5
                      Troubadour.REROLL.reroll_limit_price = '$'..(math.summ(Troubadour.config.reroll_limit + r_cost - 1) - math.summ(r_cost - 1))
                    end
                  },
                }),
                -- T.Row ({ align = 'cr', padding = 0 }, {
                --   T.Col ({ padding = 0 }, { T.Text { ref_table = Troubadour.REROLL, ref_value = 'reroll_limit_price', scale = 0.4 } })
                -- }),
                T.Row ({ align = 'cr' }, {
                  T.Text { text = "Savings Threshold: $", scale = 0.4 },
                  T.Num {
                    id = "TRO_set_spend_limit",
                    colour = Troubadour.config.enable_auto_reroll and T.C.active or T.C.inactive,
                    hooked_colour = Troubadour.config.enable_auto_reroll and darken(T.C.active, 0.3) or T.C.inactive,
                    ref_value = "reroll_spend_limit", default = 25,
                  }
                })
              })
            }}
          }}
        }}
      }}
    }
  })
end