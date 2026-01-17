TRO.UI.get_page_num = true
local card_collection_uibox = SMODS.card_collection_UIBox
SMODS.card_collection_UIBox = function(_pool, rows, args)
  args.no_materialize = TRO.adding_key and true or args.no_materialize
  if TRO.UI.rerendering then args.TRO_curr_option = TRO.UI.curr_page end
  return card_collection_uibox(_pool, rows, args)
end

local old_FUNCS_your_collection = G.FUNCS.your_collection
function G.FUNCS.your_collection(...)
    TRO.in_collection = true
    TRO.UI.targets.added_target = ''
    TRO.config_from_coll = nil
    TRO.UI.widen_consumable_screens()
    return old_FUNCS_your_collection(...)
end

local uibox_your_collection = create_UIBox_your_collection
create_UIBox_your_collection = function()
  local ret = uibox_your_collection()
  -- Changing the back button function if collection was called from the button
    -- also thank you to NeatoJokers for showing me this trick
  local back_button_deepfind = SMODS.deepfind(ret, 'overlay_menu_back_button', true)[1]
  if back_button_deepfind then
    local back_button = back_button_deepfind.objtree[#back_button_deepfind.objtree - 2]
    back_button.config.button = TRO.coll_from_button and 'exit_search_collection' or back_button.config.button
  end

  -- Adding the Auto-reroll UI
  table.insert(ret.nodes[1].nodes[1].nodes[1].nodes, (TRO.coll_from_button or next(TRO.collection_targets)) and TRO.UIDEF.auto_reroll_menu_UI())
  return ret
end

local old_FUNCS_exit_overlay_menu = G.FUNCS.exit_overlay_menu
function G.FUNCS.exit_overlay_menu(...)
    TRO.UI.reset_ui_states()
    return old_FUNCS_exit_overlay_menu(...)
end