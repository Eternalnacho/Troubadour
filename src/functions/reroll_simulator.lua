-- SHOP REROLL SIMULATION FUNCTIONS
TRO.REROLL = {}
TRO.REROLL.tag_cache = {}
TRO.REROLL.edition_flags = {}
TRO.REROLL.rerolls = 0
TRO.REROLL.spent = 0
TRO.in_reroll_sim = nil

function TRO.REROLL.simulate_reroll()
  TRO.reroll_cost = TRO.reroll_cost or G.GAME.current_round.reroll_cost
  -- Tracking total money spent
  TRO.REROLL.spent = TRO.REROLL.spent + TRO.reroll_cost
  -- Accounting for free rerolls in spending calculations
  TRO.free_rerolls = TRO.free_rerolls or G.GAME.current_round.free_rerolls
  local final_free = TRO.free_rerolls > 0
  TRO.free_rerolls = math.max(TRO.free_rerolls - 1, 0)
  TRO.REROLL.calculate_reroll_cost(final_free)
  -- Clearing the "shop jokers" in simulation
  for i = #TRO.REROLL.key_queue, 1, -1 do
    if G.GAME.used_jokers[TRO.REROLL.key_queue[i]] then G.GAME.used_jokers[TRO.REROLL.key_queue[i]] = nil end
    table.remove(TRO.REROLL.key_queue, i)
  end
  -- Get next set of shop jokers
  for _ = 1, G.GAME.shop.joker_max do
    TRO.REROLL.get_next_shop_key()
  end
  -- Increment reroll count
  TRO.REROLL.rerolls = TRO.REROLL.rerolls + 1
end

function TRO.REROLL.calculate_reroll_cost(skip_increase)
  TRO.reroll_cost_inc = TRO.reroll_cost_inc or 0
  if not skip_increase then TRO.reroll_cost_inc = TRO.reroll_cost_inc + 1 end
  TRO.reroll_cost = G.GAME.current_round.reroll_cost + TRO.reroll_cost_inc
end

function TRO.REROLL.get_next_shop_key()
  -- Checking tags for store modifiers
  TRO.REROLL.key_queue = TRO.REROLL.key_queue or {}
  TRO.REROLL.tag_args = TRO.REROLL.tag_args or {}
  local k_shop_tag, k_tag_type = TRO.REROLL.get_next_shop_tag('create')
  local e_shop_tag, e_tag_type = TRO.REROLL.get_next_shop_tag('modify')
  local args = TRO.REROLL.check_rates()
  -- Check if tag changes rates / keys
  if k_shop_tag then
    TRO.REROLL.calculate_shop_tag(k_shop_tag, k_tag_type, args)
    table.insert(TRO.REROLL.tag_cache, k_shop_tag)
  end
  if e_shop_tag then
    TRO.REROLL.calculate_shop_tag(e_shop_tag, e_tag_type, args)
    table.insert(TRO.REROLL.tag_cache, e_shop_tag)
  end
  -- if there's a forced key we know what joker will appear
  if args.key then
    TRO.REROLL.key_queue[#TRO.REROLL.key_queue+1] = args.key
  -- *now* we get the pool and so on
  else
    local _pool, _pool_key = get_current_pool(args.set, args.rarity, args.legendary, args.key_append)
    local center_key = pseudorandom_element(_pool, pseudoseed(_pool_key))
    local it = 1
    while center_key == 'UNAVAILABLE' do
        it = it + 1
        center_key = pseudorandom_element(_pool, pseudoseed(_pool_key..'_resample'..it))
    end
    TRO.REROLL.key_queue[#TRO.REROLL.key_queue+1] = center_key
  end
  -- counting editions
  if args.edition then
    TRO.REROLL.edition_flags[args.edition] = true
  elseif args.set == 'Joker' then
    local edition = poll_edition('edi'..(args.key_append or '')..G.GAME.round_resets.ante)
    if edition then TRO.REROLL.edition_flags[edition] = true end
  end
  G.GAME.used_jokers[TRO.REROLL.key_queue[#TRO.REROLL.key_queue]] = true
end

function TRO.REROLL.get_next_shop_tag(_type)
  for _, v in ipairs(G.GAME.tags) do
    if v.config.type == 'store_joker_'.._type and not TRO.utils.contains(TRO.REROLL.tag_cache, v) then
      return v, v.config.type
    end
  end
end

function TRO.REROLL.calculate_shop_tag(tag, tag_type, args)
  local flags = SMODS.calculate_context({prevent_tag_trigger = tag, other_context = {type = tag_type, area = G.shop_jokers}})
  if flags and flags.prevent_trigger or TRO.utils.contains(TRO.REROLL.tag_cache, tag) then return end
  if tag_type == 'store_joker_create' then
    if tag.name == 'Rare Tag' then
      args.key_append = 'rta'
      args.rarity = 1
      args.set = 'Joker'
    elseif tag.name == 'Uncommon Tag' then
      args.key_append = 'uta'
      args.rarity = 0.9
      args.set = 'Joker'
    else
      local card = tag:apply_to_run({type = 'store_joker_create', area = G.shop_jokers})
      for k, v in pairs(TRO.REROLL.tag_args) do
        args[k] = v
      end
      if card then card:remove() end
    end
  else
    local tag_center = G.P_TAGS[tag.key]
    if tag_center and tag_center.config.edition and args.set == 'Joker' then
      TRO.REROLL.edition_flags['e_'..tag_center.config.edition] = true
    end
  end
end

function TRO.REROLL.get_card_type_rates()
  G.GAME.spectral_rate = G.GAME.spectral_rate or 0
  -- need to preserve order to leave RNG unchanged
  local rates = {
    {type = 'Joker', val = G.GAME.joker_rate},
    {type = 'Tarot', val = G.GAME.tarot_rate},
    {type = 'Planet', val = G.GAME.planet_rate},
    {type = (G.GAME.used_vouchers["v_illusion"] and pseudorandom(pseudoseed('illusion')) > 0.6) and 'Enhanced' or 'Base', val = G.GAME.playing_card_rate},
    {type = 'Spectral', val = G.GAME.spectral_rate},
  }
  for _, v in ipairs(SMODS.ConsumableType.ctype_buffer) do
      if not (v == 'Tarot' or v == 'Planet' or v == 'Spectral') then
          table.insert(rates, { type = v, val = G.GAME[v:lower()..'_rate'] })
      end
  end
  return rates
end

function TRO.REROLL.check_rates()
  local rates = TRO.REROLL.get_card_type_rates()
  local check_rate = 0
  local total_rate = G.GAME.joker_rate + G.GAME.playing_card_rate
  for _, v in ipairs(SMODS.ConsumableType.ctype_buffer) do
      total_rate = total_rate + G.GAME[v:lower()..'_rate']
  end
  local polled_rate = pseudorandom(pseudoseed('cdt'..G.GAME.round_resets.ante)) * total_rate

  for _, v in ipairs(rates) do
    if polled_rate > check_rate and polled_rate <= check_rate + v.val then
      local args = {set = v.type, area = G.shop_jokers, key_append = 'sho'}
      local flags
      -- CHECK IF CALCULATING CONTEXTS CREATE_SHOP_CARD AND MODIFY_SHOP_CARD WILL SUCK
      if tro_config.include_joker_calcs then
        flags = SMODS.calculate_context({create_shop_card = true, set = v.type})
        args = SMODS.merge_defaults(flags and flags.shop_create_flags or {}, args) or args
      end
      return args
    end
    check_rate = check_rate + v.val
  end
end