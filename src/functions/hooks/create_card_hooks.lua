-- HOOKING CARD CREATION FUNCTIONS FOR REROLL SIM

local s_create_card_ref = SMODS.create_card
SMODS.create_card = function(t)
  if Troubadour.in_reroll_sim and Troubadour.from_tag then
    Troubadour.REROLL.tag_args = copy_table(t)
    Troubadour.REROLL.from_scc = true
  end
  local ret = s_create_card_ref(t)
  Troubadour.REROLL.from_scc, Troubadour.from_tag = nil, nil
  return ret
end

local create_card_ref = create_card
create_card = function(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append, ...)
  if Troubadour.in_reroll_sim and not Troubadour.REROLL.from_scc then
    Troubadour.REROLL.tag_args = {
      set = _type,
      legendary = legendary,
      rarity = _rarity,
      key = forced_key,
      key_append = key_append
    }
  end
  local ret = create_card_ref(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append, ...)
  return ret
end
