-- AUTO-REROLL FUNCTION FOR REROLL BUTTON
Troubadour.collection_targets = {}
Troubadour.UI.targets = { added_target = '' }
Troubadour.RNG_states = { prev = nil, latest = nil }

function Troubadour.FUNCS.auto_reroll(targets)
  -- Start the reroll sim w/ shop_jokers as the first iteration
  for _, v in pairs(G.shop_jokers.cards) do table.insert(Troubadour.REROLL.key_queue, v.config.center_key) end
  -- Use predictive rerolling for skipping animations
  if tro_config.skip_reroll_anims then
    Troubadour.FUNCS.predictive_reroll(targets)
  else
    -- Use a "normal" auto-reroll otherwise
    Troubadour.FUNCS.auto_roll_event(targets)
    -- Display results
    Troubadour.FUNCS.display_results(targets)
    -- Reset values to defaults for next time
    Troubadour.FUNCS.reset_rerolls()
  end
end

function Troubadour.FUNCS.auto_roll_event(targets)
  if Troubadour.REROLL.spend_limit_flag or Troubadour.REROLL.reroll_limit_flag then
    G.CONTROLLER.locks.shop_reroll = false
    return true
  end
  local b = {config = {}}
  G.FUNCS.can_reroll(b)
  if not b.config.button then
    G.CONTROLLER.locks.shop_reroll = false
    return true
  end
  if Troubadour.FUNCS.check_keys(targets) then
    G.CONTROLLER.locks.shop_reroll = false
    return true
  end
  G.FUNCS.reroll_shop()
  -- Empty key queue and edition flags
  Troubadour.REROLL.key_queue = {}
  Troubadour.REROLL.edition_flags = {}
  -- Increment amount spent tracker and reroll count tracker
  Troubadour.REROLL.spent = Troubadour.REROLL.spent + G.GAME.current_round.reroll_cost - 1
  Troubadour.REROLL.rerolls = Troubadour.REROLL.rerolls + 1
  -- Check for either limit flag
  if (Troubadour.REROLL.spent + G.GAME.current_round.reroll_cost) > (to_number(G.GAME.dollars) - tro_config.reroll_spend_limit) then Troubadour.REROLL.spend_limit_flag = true end
  if Troubadour.REROLL.rerolls >= tro_config.reroll_limit then Troubadour.REROLL.reroll_limit_flag = true end
  -- Re-call event until something stops
  G.E_MANAGER:add_event(Event {
    func = function()
      for _, card in pairs(G.shop_jokers.cards) do
        Troubadour.REROLL.key_queue[#Troubadour.REROLL.key_queue+1] = card.config.center_key
        if card.edition then Troubadour.REROLL.edition_flags[card.edition.key] = true end
      end
      if Troubadour.FUNCS.check_keys(targets) then
        G.CONTROLLER.locks.shop_reroll = false
        return true
      end
      Troubadour.FUNCS.auto_roll_event(Troubadour.collection_targets)
      return true
    end,
    blocking = false,
    blockable = true
  })
  return true
end

function Troubadour.FUNCS.predictive_reroll(targets)
  -- Save the RNG state for later, so we can default the game state to this
  local RNG_state = copy_table(G.GAME.pseudorandom)
  local used_jokers = copy_table(G.GAME.used_jokers)

  Troubadour.in_reroll_sim = true
  while not Troubadour.FUNCS.check_keys(targets) and not Troubadour.REROLL.spend_limit_flag and not Troubadour.REROLL.reroll_limit_flag do
    Troubadour.REROLL.edition_flags = {}
    Troubadour.REROLL.simulate_reroll()
    Troubadour.RNG_states.prev = Troubadour.RNG_states.latest
    Troubadour.RNG_states.latest = copy_table(G.GAME.pseudorandom)
  end
  Troubadour.in_reroll_sim = nil

  -- Do all the calculations with none of the actual rerolls.
  if Troubadour.RNG_states.prev then
    Troubadour.REROLL.skip_to_last()
  end
  -- Set the RNG state to one reroll from results, so we can reroll once into the correct spot
  G.GAME.used_jokers = used_jokers
  G.GAME.pseudorandom = Troubadour.RNG_states.prev or RNG_state
  -- Reroll
  G.E_MANAGER:add_event(Event({ func = function() G.FUNCS.reroll_shop() return true end }))
  -- Display results
  Troubadour.FUNCS.display_results(targets)
  -- Reset values to defaults for next time
  Troubadour.FUNCS.reset_rerolls()
end

function Troubadour.FUNCS.check_keys(targets)
  for _, key in pairs(targets) do
    if Troubadour.utils.contains(Troubadour.REROLL.key_queue, key) then
      return true
    elseif Troubadour.REROLL.edition_flags[''..key] then
      return true
    end
  end
end

function Troubadour.FUNCS.display_results(targets)
  -- Display results for posterity, and for better tracking
  if not Troubadour.FUNCS.check_keys(targets) then print("Reached reroll limit, joker not found")
  else
    G.E_MANAGER:add_event(Event({ trigger = 'after', delay = 0.5,
      func = function()
        play_sound('holo1')
        play_sound('timpani')
        return true
      end
    }))
  end
  print("Total rerolls: " .. Troubadour.REROLL.rerolls)
end

function Troubadour.FUNCS.reset_rerolls()
  Troubadour.RNG_states = { prev = nil, latest = nil }
  Troubadour.REROLL.rerolls = 0
  Troubadour.REROLL.spent = 0
  Troubadour.REROLL.key_queue = {}
  Troubadour.REROLL.edition_flags = {}
  Troubadour.REROLL.tag_cache = {}
  Troubadour.REROLL.tag_queue = {}
  Troubadour.reroll_cost = nil
  Troubadour.reroll_cost_inc = nil
  Troubadour.free_rerolls = nil
  Troubadour.REROLL.spend_limit_flag = nil
  Troubadour.REROLL.reroll_limit_flag = nil
end

