-- WIDER COLLECTION SCREENS

-- Jokers
create_UIBox_your_collection_jokers = function()
  local w = tro_config.gallery_width_j * 10 % 10 < 5 and math.floor(tro_config.gallery_width_j) or math.ceil(tro_config.gallery_width_j)
  local h = tro_config.gallery_height_j * 10 % 10 < 5 and math.floor(tro_config.gallery_height_j) or math.ceil(tro_config.gallery_height_j)
  local area = {}; for _ = 1, h do area[#area+1] = w end
  return SMODS.card_collection_UIBox(G.P_CENTER_POOLS.Joker, area, {
      no_materialize = true,
      modify_card = function(card, center) card.sticker = get_joker_win_sticker(center) end,
      h_mod = 0.95 * (3 / h),
      card_scale = 1 - (h / 100),
  })
end

-- Vouchers
create_UIBox_your_collection_vouchers = function()
  local w = tro_config.gallery_width_v * 10 % 10 < 5 and math.floor(tro_config.gallery_width_v) * 2 or math.ceil(tro_config.gallery_width_v) * 2
  local h = tro_config.gallery_height_v * 10 % 10 < 5 and math.floor(tro_config.gallery_height_v) or math.ceil(tro_config.gallery_height_v)
  local area = {}; for _ = 1, h do area[#area+1] = w end
  return SMODS.card_collection_UIBox(G.P_CENTER_POOLS.Voucher, area, {
    area_type = 'voucher',
    modify_card = function(card, center, i, j)
      card.ability.order = i+(j-1)*4
      if (SMODS.Mods["FlowerPot"] or {}).can_load then
        if FlowerPot.CONFIG.voucher_sticker_enabled < 3 then card.sticker = get_voucher_win_sticker(center) end
      end
    end,
  })
end

-- Consumables
TRO.UI.widen_consumable_screens = function()
  for _, con in pairs(SMODS.ConsumableTypes) do
    local amt = #TRO.utils.filter(G.P_CENTER_POOLS[con.key], function(v) return not v.no_collection end)
    local con_w = tro_config.gallery_width_c * 10 % 10 < 5 and math.floor(tro_config.gallery_width_c) or math.ceil(tro_config.gallery_width_c)
    local con_h = tro_config.gallery_height_c * 10 % 10 < 5 and math.floor(tro_config.gallery_height_c) or math.ceil(tro_config.gallery_height_c)
    -- evening out the rows
    con_h = math.min(con_h, math.ceil(amt/con_w))
    con_w = math.min(con_w, math.ceil(amt/con_h))
    local con_area = {}; for i = 1, con_h do
      con_area[#con_area+1] = (con.collection_rows[1] ~= con.collection_rows[2] and i % 2 == 1) and math.max(con.collection_rows[1], con_w - 1)
        or math.max(con.collection_rows[1], con_w)
    end
    con.collection_rows = con_area
  end
end

-- Enhancements
create_UIBox_your_collection_enhancements = function()
  local w = tro_config.gallery_width_e * 10 % 10 < 5 and math.floor(tro_config.gallery_width_e) or math.ceil(tro_config.gallery_width_e)
  local h = tro_config.gallery_height_e * 10 % 10 < 5 and math.floor(tro_config.gallery_height_e) or math.ceil(tro_config.gallery_height_e)
  local area = {}; for _ = 1, h do area[#area+1] = w end
  return SMODS.card_collection_UIBox(G.P_CENTER_POOLS.Enhanced, area, {
      no_materialize = true,
      snap_back = true,
      h_mod = 1.03,
      infotip = localize('ml_edition_seal_enhancement_explanation'),
      hide_single_page = true,
  })
end

-- Enhancements
create_UIBox_your_collection_boosters = function()
  local w = tro_config.gallery_width_b * 10 % 10 < 5 and math.floor(tro_config.gallery_width_b) or math.ceil(tro_config.gallery_width_b)
  local h = tro_config.gallery_height_b * 10 % 10 < 5 and math.floor(tro_config.gallery_height_b) or math.ceil(tro_config.gallery_height_b)
  local area = {}; for _ = 1, h do area[#area+1] = w end
  return SMODS.card_collection_UIBox(G.P_CENTER_POOLS.Booster, area, {
      h_mod = 1.3 * (1 - (h - 2) / 50),
      w_mod = 1.25 * (1 - (w - 4) / 50),
      card_scale = 1.27 * (1 - (h - 2) / 50),
  })
end