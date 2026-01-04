-- AUTO-REROLL FUNCTION FOR REROLL BUTTON
TRO.collection_targets = {}

-- thank you Overstock and god bless you
local function can_reroll_into(card_key)
  local center = G.P_CENTERS[card_key]
  if not center then return false end
  if G.GAME.banned_keys and G.GAME.banned_keys[card_key] then return false end
  if center.no_appear_in_shop then return false end
  if center.yes_pool_flag and (not G.GAME.pool_flags or not G.GAME.pool_flags[center.yes_pool_flag]) then return false end
  if center.no_pool_flag and (G.GAME.pool_flags and G.GAME.pool_flags[center.no_pool_flag]) then return false end

  -- This looks like cryptid bs
  if G.GAME.cry_banished_keys and G.GAME.cry_banished_keys[card_key] then return false end
  if (({
    Enhanced = true, Edition = true, Back = true,
    Spectral = G.GAME.spectral_rate <= 0 and not (G.GAME.selected_back.effect.center.key == "b_cry_equilibrium"),
    Code = G.GAME.code_rate and (G.GAME.code_rate <= 0) and not (G.GAME.selected_back.effect.center.key == "b_cry_equilibrium"),
    Voucher = not (G.GAME.selected_back.effect.center.key == "b_cry_equilibrium"),
  })[center.set]) then return false end
  return true
end

function TRO.FUNCS.prompt_target(target)
  if G.STATE == G.STATES.SHOP and tro_config.enable_auto_reroll then
    local reroll_button = G.shop:get_UIE_by_ID("next_round_button").parent.children[2]
    if target == reroll_button then
      if next(TRO.collection_targets) and (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then
        TRO.FUNCS.find_targets(TRO.collection_targets)
      else
        G.FUNCS.TRO_your_collection()
      end
    end
  end
end

function TRO.FUNCS.find_targets(targets)
  local modded_tags_found
  for _, v in ipairs(G.GAME.tags) do
    if v.config.type == 'store_joker_create' and not (v.name == 'Rare Tag' or v.name == 'Uncommon Tag') then
      modded_tags_found = true
      break
    end
  end
  if modded_tags_found then
    print("Auto-reroll can't be used until modded joker-creating tags are used")
  elseif #targets > 0 then
    TRO.FUNCS.auto_reroll(targets)
  end
end

function TRO.FUNCS.auto_reroll(targets)
  TRO.REROLL.rerolls = 0
  TRO.REROLL.key_queue = {}
  -- Save the RNG state for later, so we can default the game state to this
  local RNG_state = copy_table(G.GAME.pseudorandom)
  local used_jokers = copy_table(G.GAME.used_jokers)
  -- Start the reroll sim w/ shop_jokers as the first iteration
  for _, v in pairs(G.shop_jokers.cards) do table.insert(TRO.REROLL.key_queue, v.config.center_key) end

  -- Simulate rerolls until either the keys are found or the limit is reached
  while not TRO.FUNCS.check_keys(targets) and TRO.REROLL.spent <= to_number(G.GAME.dollars) and TRO.REROLL.rerolls < tro_config.reroll_limit do
    TRO.REROLL.simulate_reroll()
  end

  -- Now roll out the simulated rerolls
  G.E_MANAGER:add_event(Event({
    func = function()
      -- Reset the RNG state to snapshot, undoing the simulations
      G.GAME.used_jokers = used_jokers
      G.GAME.pseudorandom = RNG_state
      -- Reroll the shop until target is hit
      for _ = 1, TRO.REROLL.rerolls do
        G.E_MANAGER:add_event(Event({ func = function() G.FUNCS.reroll_shop() return true end }))
      end

      G.E_MANAGER:add_event(Event({ trigger = 'after', delay = 0.5,
        func = function()
          play_sound('holo1')
          play_sound('timpani')
          return true
        end
      }))
      -- Display results for posterity, and for better tracking
      if not TRO.FUNCS.check_keys(targets) then print("Reached reroll limit, joker not found") end
      print("Total rerolls: " .. TRO.REROLL.rerolls)
      -- Reset values to defaults for next time
      TRO.FUNCS.reset_rerolls()
      return true
    end
    }))
end

function TRO.FUNCS.reset_rerolls()
  TRO.REROLL.rerolls = 0
  TRO.REROLL.spent = 0
  TRO.REROLL.key_queue = {}
  TRO.REROLL.tag_cache = {}
  TRO.reroll_cost = nil
  TRO.reroll_cost_inc = nil
  TRO.free_rerolls = nil
end

function TRO.FUNCS.clear_targets(from_button)
  if next(TRO.collection_targets) and (from_button == true or (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift"))) then
    TRO.collection_targets = {}
    if G.STATE == G.STATES.SHOP and not G.SETTINGS.paused then
      update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname = "Reroll targets cleared"})
      G.E_MANAGER:add_event(Event({ trigger = 'after', delay = G.SETTINGS.GAMESPEED * 3,
        func = function()
          update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
          return true
        end
      }))
    end
    print("Clearing reroll search targets")
  end
end

function TRO.FUNCS.check_keys(targets)
  for _, key in pairs(targets) do
    if TRO.utils.contains(TRO.REROLL.key_queue, key) then
      return true
    end
  end
end

tro_input_manager:add_listener({ 'right_click', 'right_stick' }, TRO.FUNCS.prompt_target)
tro_input_manager:add_listener({ 'double_click' }, TRO.FUNCS.clear_targets)

-- Hook card clicks to add search targets
local cc = Card.click
function Card:click()
  if self.area and self.area.config.collection and tro_config.enable_auto_reroll and can_reroll_into(self.config.center_key)
      and not TRO.utils.contains(TRO.collection_targets, self.config.center_key) and G.STATE == G.STATES.SHOP then
    table.insert(TRO.collection_targets, self.config.center_key)
    TRO.adding_key = true
    local set = self.config.center.set  
    if TRO.UI.get_type_collection_UIBox_func(set) and G.SETTINGS.paused then
      TRO.UI.rerender_collection(set)
    end
  end
  return cc(self)
end

function G.FUNCS.TRO_your_collection(e)
  TRO.coll_from_button = true
  G.FUNCS.your_collection(e)
end

function G.FUNCS.exit_search_collection()
  if G.SETTINGS.paused then
    G.FUNCS.exit_overlay_menu()
    TRO.coll_from_button = nil
  end
end

function G.FUNCS.TRO_clear_targets(e)
  if next(TRO.collection_targets) then
    TRO.FUNCS.clear_targets(true)
    G.E_MANAGER:add_event(Event({
      blocking = false,
      blockable = false,
      no_delete = true,
      func = function()
        TRO.UI.rerender(create_UIBox_your_collection, nil, true)
        return true
      end,
    }))
  end
end