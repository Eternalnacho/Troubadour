local troC = Troubadour.UI.mod_colours
local Row, Col, Text = Troubadour.UI.create_row, Troubadour.UI.create_column, Troubadour.UI.create_text_node
local TroUIBox = Troubadour.UI.create_UIBox_generic_options_custom



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