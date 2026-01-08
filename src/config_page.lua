function TRO.UI.UIE_config_args(args)
  return {
    align = args.align or "bm",
    padding = args.padding or 0.05,
    colour = args.colour or G.C.CLEAR,
    emboss = args.emboss,
    minh = args.minh,
    maxh = args.maxh,
    minw = args.minw,
    maxw = args.maxw,
    h = args.h,
    w = args.w,
    r = args.r,
    id = args.id,
  }
end

function TRO.UI.create_column(args)
  return {
    n = G.UIT.C,
    config = TRO.UI.UIE_config_args(args),
    nodes = args.nodes or {}
  }
end

function TRO.UI.create_row(args)
  return {
    n = G.UIT.R,
    config = TRO.UI.UIE_config_args(args),
    nodes = args.nodes or {}
  }
end

function TRO.UI.create_text_node(args)
  return {
    n = G.UIT.T,
    config = {
      text = args.text,
      ref_table = args.ref_table,
      ref_value = args.ref_value,
      scale = args.scale or 1,
      colour = args.colour or G.C.WHITE,
      shadow = args.shadow,
      vert = args.vert
    }
  }
end

function TRO.UI.create_num_input_node(args)
  return create_text_input({
    colour = tro_config.enable_auto_reroll and G.C.RED or darken(copy_table(G.C.GREY), 0.5),
    hooked_colour = tro_config.enable_auto_reroll and darken(copy_table(G.C.RED), 0.3) or darken(copy_table(G.C.GREY), 0.5),
    w = 3, h = 1,
    prompt_text = "",
    ref_table = tro_config,
    ref_value = args.ref_value,
    extended_corpus = true,
    keyboard_offset = 1,
    callback = function()
      tro_config[args.ref_value] = string.gsub(tro_config[args.ref_value], "O", "0")
      tro_config[args.ref_value] = tonumber(tro_config[args.ref_value]) or tonumber(args.default)
      TRO.UI.update_TRO_config()
    end
  })
end

function SMODS.current_mod.config_tab()
  local reroll_cost = G.STATES == G.STATES.RUN and G.GAME.current_round and G.GAME.current_round.reroll_cost or 5
  local reroll_limit_price = math.summ(tro_config.reroll_limit + reroll_cost - 1) - math.summ(reroll_cost - 1)
  local reroll_limit_text = TRO.UI.create_num_input_node({ref_value = "reroll_limit", default = 30})
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
                create_slider({label = 'Joker Collection Width', w = 4, h = 0.3, ref_table = tro_config, ref_value = 'gallery_width', min = 5, max = 11}),
                create_slider({label = 'Joker Collection Height', w = 4, h = 0.3, ref_table = tro_config, ref_value = 'gallery_height', min = 3, max = 5}),
              }
            }
          }}),
          TRO.UI.create_row({minh = 0.65, nodes = { create_toggle({
              align = 'cr',
              label = 'Enable Auto Reroll?',
              callback = TRO.UI.update_TRO_config,
              ref_table = tro_config,
              ref_value = 'enable_auto_reroll'
            })
          }}),
          TRO.UI.create_row({minh = 0.65, nodes = { create_toggle({
            align = 'cr',
            label = 'Skip Reroll Animations?',
            ref_table = tro_config,
            ref_value = 'skip_reroll_anims'
          })
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

function TRO.UI.update_TRO_config()
  if TRO.coll_from_button then
    TRO.UI.rerender(TRO.UI.config_from_coll, true)
  elseif SMODS.LAST_SELECTED_MOD_TAB == "config" then
    TRO.UI.rerender(create_UIBox_mods, true)
  end
end
