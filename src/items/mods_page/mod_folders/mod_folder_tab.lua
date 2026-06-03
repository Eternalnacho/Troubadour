local troC = Troubadour.UI.mod_colours
local Row, Col, Text = Troubadour.UI.create_row, Troubadour.UI.create_column, Troubadour.UI.create_text_node
local TroUIBox = Troubadour.UI.create_UIBox_generic_options_custom

function Troubadour.UIDEF.mod_folder_button()
  local tag_sprite = SMODS.create_sprite(0, 0, 1, 1, 'tro_modicon', {x = 0, y = 0})
  local tile_node = {
    n = G.UIT.C,
    config = {
      r = 0.1,
      minh = 2,
      align = 'cm',
      padding = 0.05,
      emboss = 0.05,
      colour = troC.inactive,
      outline = 1,
      outline_colour = troC.outline_colour,
      button = 'Troubadour_mod_folder_button',
      TRO_dark_tooltip = 'TRO_mod_folder_page',
    }
  }

  tile_node.nodes = {
    {
      n = G.UIT.R,
      config = {
        align = "cm",
        r = 0.1,
        padding = 0.1,
        emboss = 0.02,
        colour = troC.inactive,
      },
      nodes = {
        {
          n = G.UIT.O,
          config = {
            align = "cm",
            object = tag_sprite,
            focus_with_object = true,
          }
        },
      }
    }
  }
  Troubadour.ICONS.buildClickableTag(tag_sprite, 1, nil, tile_node.config.TRO_dark_tooltip, G.FUNCS.Troubadour_mod_folder_button)
  return Col{ padding = 0.2, nodes = {tile_node} }
end

G.FUNCS.Troubadour_mod_folder_button = function()
  return
end