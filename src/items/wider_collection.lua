-- Wider Gallery Settings
create_UIBox_your_collection_jokers = function()
  local w = tro_config.gallery_width * 10 % 10 < 5 and math.floor(tro_config.gallery_width) or math.ceil(tro_config.gallery_width)
  local h = tro_config.gallery_height * 10 % 10 < 5 and math.floor(tro_config.gallery_height) or math.ceil(tro_config.gallery_height)
  local area = {}; for _ = 1, h do area[#area+1] = w end
  return SMODS.card_collection_UIBox(G.P_CENTER_POOLS.Joker, area, {
      no_materialize = true,
      modify_card = function(card, center) card.sticker = get_joker_win_sticker(center) end,
      h_mod = 0.95 * (3 / h),
      card_scale = 1 - (h / 100),
  })
end