-- HOOKS FOR WIDER COLLECTION

local YOUR_COLLECTION = G.FUNCS.your_collection
function G.FUNCS.your_collection(...)
  Troubadour.FUNCS.widen_collection()
  return YOUR_COLLECTION(...)
end

local SMODS_BAT = buildAdditionsTab
buildAdditionsTab = function(mod, ...)
  Troubadour.FUNCS.widen_collection()
  return SMODS_BAT(mod, ...)
end