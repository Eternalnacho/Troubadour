-- AUTO-REROLL FUNCTION FOR REROLL BUTTON
TRO.collection_targets = {}
TRO.UI.targets = { added_target = '' }
TRO.RNG_states = { prev = nil, latest = nil }

-- thank you Overstock and god bless you
local function can_reroll_into(card_key)
  local center = G.P_CENTERS[card_key]
  if not center then return false end
  if G.GAME.banned_keys and G.GAME.banned_keys[card_key] then return false end
  if center.no_appear_in_shop then return false end

  if center.yes_pool_flag and (not G.GAME.pool_flags or not G.GAME.pool_flags[center.yes_pool_flag]) then return false end
  if center.no_pool_flag and (G.GAME.pool_flags and G.GAME.pool_flags[center.no_pool_flag]) then return false end

  if center.set == 'Edition' and not center.in_shop then return false end

  if ({
    Enhanced = true,
    Back = true,
    Spectral = G.GAME.spectral_rate <= 0,
    Voucher = true
  })[center.set] then return false end
  return true
end

function TRO.FUNCS.prompt_target(target)
  if G.STATE == G.STATES.SHOP and tro_config.enable_auto_reroll then
    local reroll_button = G.shop:get_UIE_by_ID("next_round_button").parent.children[2]
    if target == reroll_button then
      if next(TRO.collection_targets) and (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then
        if type(tro_config.reroll_limit) ~= 'number' then tro_config.reroll_limit = tonumber(tro_config.reroll_limit) or 30 end
        TRO.FUNCS.auto_reroll(TRO.collection_targets)
      else
        G.FUNCS.TRO_your_collection()
      end
    end
  end
end

function TRO.FUNCS.clear_targets(from_button)
  if next(TRO.collection_targets) and (from_button == true or (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift"))) then
    TRO.collection_targets = {}
    if TRO.in_collection then
      local menu_object = G.OVERLAY_MENU:get_UIE_by_ID('TRO_targetsList')
      if menu_object then
        menu_object.config.object:remove()
        menu_object.config.object = UIBox({ definition = TRO.UIDEF.reroll_targets_list("Current Targets:"), config = {type = "cm", parent = menu_object}})
        G.OVERLAY_MENU:recalculate()
      end
    elseif G.STATE == G.STATES.SHOP and not G.SETTINGS.paused then
      update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname = "Reroll targets cleared"})
      G.E_MANAGER:add_event(Event({ trigger = 'after', delay = G.SETTINGS.GAMESPEED * 3,
        func = function()
          update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
          return true
        end
      }))
    end
  end
end

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

-- Reroller controls
tro_input_manager:add_listener({ 'right_click', 'right_stick' }, TRO.FUNCS.prompt_target)
tro_input_manager:add_listener({ 'double_click' }, TRO.FUNCS.clear_targets)

-- Hook card clicks to add search targets
local cc = Card.click
function Card:click()
  if self.area and self.area.config.collection and tro_config.enable_auto_reroll and can_reroll_into(self.config.center_key)
      and not TRO.utils.contains(TRO.collection_targets, self.config.center_key) and G.STATE == G.STATES.SHOP then
    table.insert(TRO.collection_targets, self.config.center_key)
    TRO.UI.targets.added_target = self.config.center_key
    TRO.adding_key = true
    local set = self.config.center.set
    if TRO.FUNCS.get_type_collection_UIBox_func(set) and TRO.in_collection and not TRO.coll_from_button then
      TRO.UI.rerender_collection(set)
      TRO.coll_from_button = true
    elseif TRO.in_collection then
      local menu_object = G.OVERLAY_MENU:get_UIE_by_ID('TRO_targetsList')
      if menu_object then
        menu_object.config.object:remove()
        menu_object.config.object = UIBox({ definition = TRO.UIDEF.reroll_targets_list("Current Targets:"), config = {type = "cm", parent = menu_object}})
        G.OVERLAY_MENU:recalculate()
      end
    end
  end
  return cc(self)
end