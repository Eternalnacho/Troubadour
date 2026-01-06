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
    return old_FUNCS_your_collection(...)
end

local old_FUNCS_exit_overlay_menu = G.FUNCS.exit_overlay_menu
function G.FUNCS.exit_overlay_menu(...)
    TRO.in_collection = false
    return old_FUNCS_exit_overlay_menu(...)
end