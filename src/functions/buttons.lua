-- BUTTON FUNCTIONS

function G.FUNCS.TRO_your_collection(e)
  Troubadour.collection_from_button = true
  G.FUNCS.your_collection()
end

function G.FUNCS.TRO_exit_coll_config(e)
  SMODS.save_mod_config(Troubadour)
  G.FUNCS.your_collection()
end

function G.FUNCS.TRO_exit_search_collection()
  if G.SETTINGS.paused then
    Troubadour.collection_from_button = nil
    G.FUNCS.exit_overlay_menu()
  end
end

function G.FUNCS.TRO_clear_targets(e)
  if next(Troubadour.collection_targets) then
    Troubadour.FUNCS.clear_targets(true)
  end
end

function G.FUNCS.TRO_view_options(e)
  G.SETTINGS.paused = true
  Troubadour.config_from_collection = true
  Troubadour.in_collection = false
  G.FUNCS.overlay_menu{ definition = Troubadour.UI.config_from_collection() }
  G.OVERLAY_MENU:recalculate()
end