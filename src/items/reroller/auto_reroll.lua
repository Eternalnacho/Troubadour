-- AUTO-REROLL FUNCTION FOR REROLL BUTTON
TRO.collection_targets = {}
TRO.UI.targets = { added_target = '' }
TRO.RNG_states = { prev = nil, latest = nil }

function TRO.FUNCS.auto_reroll(targets)
  -- Start the reroll sim w/ shop_jokers as the first iteration
  for _, v in pairs(G.shop_jokers.cards) do table.insert(TRO.REROLL.key_queue, v.config.center_key) end
  -- Use predictive rerolling for skipping animations
  if tro_config.skip_reroll_anims then
    TRO.FUNCS.predictive_reroll(targets)
  else
    -- Use a "normal" auto-reroll otherwise
    TRO.FUNCS.auto_roll_event(targets)
    -- Display results
    TRO.FUNCS.display_results(targets)
    -- Reset values to defaults for next time
    TRO.FUNCS.reset_rerolls()
  end
end

function TRO.FUNCS.auto_roll_event(targets)
  if TRO.REROLL.spend_limit_flag or TRO.REROLL.reroll_limit_flag then
    G.CONTROLLER.locks.shop_reroll = false
    return true
  end
  local b = {config = {}}
  G.FUNCS.can_reroll(b)
  if not b.config.button then
    G.CONTROLLER.locks.shop_reroll = false
    return true
  end
  if TRO.FUNCS.check_keys(targets) then
    G.CONTROLLER.locks.shop_reroll = false
    return true
  end
  G.FUNCS.reroll_shop()
  -- Empty key queue and edition flags
  TRO.REROLL.key_queue = {}
  TRO.REROLL.edition_flags = {}
  -- Increment amount spent tracker and reroll count tracker
  TRO.REROLL.spent = TRO.REROLL.spent + G.GAME.current_round.reroll_cost - 1
  TRO.REROLL.rerolls = TRO.REROLL.rerolls + 1
  -- Check for either limit flag
  if (TRO.REROLL.spent + G.GAME.current_round.reroll_cost) > (to_number(G.GAME.dollars) - tro_config.reroll_spend_limit) then TRO.REROLL.spend_limit_flag = true end
  if TRO.REROLL.rerolls >= tro_config.reroll_limit then TRO.REROLL.reroll_limit_flag = true end
  -- Re-call event until something stops
  G.E_MANAGER:add_event(Event {
    func = function()
      for _, card in pairs(G.shop_jokers.cards) do
        TRO.REROLL.key_queue[#TRO.REROLL.key_queue+1] = card.config.center_key
        if card.edition then TRO.REROLL.edition_flags[card.edition.key] = true end
      end
      if TRO.FUNCS.check_keys(targets) then
        G.CONTROLLER.locks.shop_reroll = false
        return true
      end
      TRO.FUNCS.auto_roll_event(TRO.collection_targets)
      return true
    end,
    blocking = false,
    blockable = true
  })
  return true
end

function TRO.FUNCS.predictive_reroll(targets)
  -- Save the RNG state for later, so we can default the game state to this
  local RNG_state = copy_table(G.GAME.pseudorandom)
  local used_jokers = copy_table(G.GAME.used_jokers)

  TRO.in_reroll_sim = true
  while not TRO.FUNCS.check_keys(targets) and not TRO.REROLL.spend_limit_flag and not TRO.REROLL.reroll_limit_flag do
    TRO.REROLL.edition_flags = {}
    TRO.REROLL.simulate_reroll()
    TRO.RNG_states.prev = TRO.RNG_states.latest
    TRO.RNG_states.latest = copy_table(G.GAME.pseudorandom)
  end
  TRO.in_reroll_sim = nil

  -- Do all the calculations with none of the actual rerolls.
  if TRO.RNG_states.prev then
    TRO.REROLL.skip_to_last()
  end
  -- Set the RNG state to one reroll from results, so we can reroll once into the correct spot
  G.GAME.used_jokers = used_jokers
  G.GAME.pseudorandom = TRO.RNG_states.prev or RNG_state
  -- Reroll
  G.E_MANAGER:add_event(Event({ func = function() G.FUNCS.reroll_shop() return true end }))
  -- Display results
  TRO.FUNCS.display_results(targets)
  -- Reset values to defaults for next time
  TRO.FUNCS.reset_rerolls()
end

function TRO.FUNCS.check_keys(targets)
  for _, key in pairs(targets) do
    if TRO.utils.contains(TRO.REROLL.key_queue, key) then
      return true
    elseif TRO.REROLL.edition_flags[''..key] then
      return true
    end
  end
end

function TRO.FUNCS.display_results(targets)
  -- Display results for posterity, and for better tracking
  if not TRO.FUNCS.check_keys(targets) then print("Reached reroll limit, joker not found")
  else
    G.E_MANAGER:add_event(Event({ trigger = 'after', delay = 0.5,
      func = function()
        play_sound('holo1')
        play_sound('timpani')
        return true
      end
    }))
  end
  print("Total rerolls: " .. TRO.REROLL.rerolls)
end

function TRO.FUNCS.reset_rerolls()
  TRO.RNG_states = { prev = nil, latest = nil }
  TRO.REROLL.rerolls = 0
  TRO.REROLL.spent = 0
  TRO.REROLL.key_queue = {}
  TRO.REROLL.edition_flags = {}
  TRO.REROLL.tag_cache = {}
  TRO.REROLL.tag_queue = {}
  TRO.reroll_cost = nil
  TRO.reroll_cost_inc = nil
  TRO.free_rerolls = nil
  TRO.REROLL.spend_limit_flag = nil
  TRO.REROLL.reroll_limit_flag = nil
end

