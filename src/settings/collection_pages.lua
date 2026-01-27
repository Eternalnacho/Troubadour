-- LIST OF COLLECTION PAGES TO WIDEN
local pages = {
  {
    label = "Joker",
    ref_value_w = "gallery_width_j", minw = 5, maxw = 11,
    ref_value_h = "gallery_height_j", minh = 3, maxh = 5,
  },
  {
    label = "Voucher",
    ref_value_w = "gallery_width_v", minw = 2, maxw = 5,
    ref_value_h = "gallery_height_v", minh = 2, maxh = 4,
  },
  {
    label = "Consumable",
    ref_value_w = "gallery_width_c", minw = 6, maxw = 10,
    ref_value_h = "gallery_height_c", minh = 2, maxh = 4,
  },
  {
    label = "Enhancement",
    ref_value_w = "gallery_width_e", minw = 4, maxw = 8,
    ref_value_h = "gallery_height_e", minh = 2, maxh = 4,
  },
  {
    label = "Booster",
    ref_value_w = "gallery_width_b", minw = 4, maxw = 8,
    ref_value_h = "gallery_height_b", minh = 2, maxh = 5,
  },
}

return { pages = pages }