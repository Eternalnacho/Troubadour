-- HOOKING CARD CREATION FUNCTIONS FOR REROLL SIM
local s_create_card_ref = SMODS.create_card
SMODS.create_card = function(t)
  if TRO.in_reroll_sim then
    TRO.REROLL.tag_args = copy_table(t)
    TRO.REROLL.from_scc = true
  end
  local ret = s_create_card_ref(t)
  TRO.REROLL.from_scc = nil
  return ret
end

local create_card_ref = create_card
create_card = function(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
  if TRO.in_reroll_sim and not TRO.REROLL.from_scc then
    TRO.REROLL.tag_args = {
      set = _type,
      legendary = legendary,
      rarity = _rarity,
      key = forced_key,
      key_append = key_append
    }
  end
  local ret = create_card_ref(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
  return ret
end
