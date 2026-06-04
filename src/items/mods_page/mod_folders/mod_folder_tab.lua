local troC = Troubadour.UI.mod_colours
local Row, Col, Text = Troubadour.UI.create_row, Troubadour.UI.create_column, Troubadour.UI.create_text_node
local TroUIBox = Troubadour.UI.create_UIBox_generic_options_custom

function Troubadour.UIDEF.mod_folder_button()
  local tag_sprite = SMODS.create_sprite(0, 0, 0.5, 0.5, 'tro_folder', {x = 0, y = 0})
  local tile_node = {
    n = G.UIT.C,
    config = {
      r = 0.1,
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
  return Col{ padding = 0.1, nodes = {tile_node} }
end

function Troubadour.UIDEF.modpage_config_button()
  local tag_sprite = SMODS.create_sprite(0, 0, 0.5, 0.5, 'mod_tags', {x = 2, y = 0})
  local tile_node = {
    n = G.UIT.C,
    config = {
      r = 0.1,
      align = 'cm',
      padding = 0.05,
      emboss = 0.05,
      colour = troC.inactive,
      outline = 1,
      outline_colour = troC.outline_colour,
      button = 'Troubadour_mod_list_config',
      TRO_dark_tooltip = 'TRO_config',
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
  return Col{ padding = 0, nodes = {tile_node} }
end

G.FUNCS.Troubadour_mod_folder_button = function(e)
  return
end

G.FUNCS.Troubadour_mod_list_config = function(e)
  G.SETTINGS.paused = true
  Troubadour.config_from_modslist = true
  G.FUNCS.overlay_menu{ definition = Troubadour.UI.config_from_modlist() }
  G.OVERLAY_MENU:recalculate()
end

function Troubadour.UI.config_from_modlist()
  return create_UIBox_generic_options({
    colour = G.C.BLACK,
    back_func = "Troubadour_exit_modlist_config",
    contents = SMODS.Mods["Troubadour"].extra_tabs()[1].tab_definition_function().nodes})
end

function G.FUNCS.Troubadour_exit_modlist_config(e)
  Troubadour.config_from_modslist = nil
  SMODS.save_mod_config(Troubadour)
  G.FUNCS.mods_button()
end