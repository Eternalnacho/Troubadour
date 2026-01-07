-- UI FUNCTIONS
TRO.UI = {}

function TRO.UI.get_type_collection_UIBox_func(set)
  local func
  if SMODS.ConsumableTypes[set] then
    func = SMODS.ConsumableTypes[set].create_UIBox_your_collection
  elseif set == 'Joker' then
    func = create_UIBox_your_collection_jokers
  end
  return func
end

function TRO.UI.rerender_collection(set)
  G.E_MANAGER:add_event(Event({
    func = function()
      TRO.UI.get_page_num, TRO.UI.rerendering = false, true
      TRO.UI.rerender(TRO.UI.get_type_collection_UIBox_func(set), true, set)
      TRO.UI.get_page_num, TRO.UI.rerendering = true, false
      return true
    end,
  }))
end

function TRO.UI.config_from_coll()
  return create_UIBox_generic_options({
    colour = G.C.BLACK,
    back_func = 'your_collection',
    contents = SMODS.Mods["Troubadour"].config_tab().nodes})
end

function TRO.UI.reset_ui_states()
  TRO.in_collection = false
  TRO.config_from_coll = nil
  TRO.UI.targets.added_target = ''
  TRO.UI.get_page_num = true
end

-- BUTTON FUNCTIONS
function G.FUNCS.TRO_your_collection(e)
  TRO.coll_from_button = true
  G.FUNCS.your_collection()
end

function G.FUNCS.exit_search_collection()
  if G.SETTINGS.paused then
    TRO.coll_from_button = nil
    G.FUNCS.exit_overlay_menu()
  end
end

function G.FUNCS.TRO_clear_targets(e)
  if next(TRO.collection_targets) then
    TRO.FUNCS.clear_targets(true)
  end
end

function G.FUNCS.TRO_view_options(e)
  G.SETTINGS.paused = true
  TRO.config_from_coll = true
  TRO.in_collection = false
  G.FUNCS.overlay_menu{ definition = TRO.UI.config_from_coll() }
  G.OVERLAY_MENU:recalculate()
end