local modpage_helper = {
  concatAuthors = function(authors)
    if type(authors) == "table" then
        return table.concat(authors, ", ")
    end
    return authors or localize('b_unknown')
  end,

  recalculateModsList = function(page)
    local w = tro_config.mod_page_width * 10 % 10 < 5 and math.floor(tro_config.mod_page_width) or math.ceil(tro_config.mod_page_width)
    local h = tro_config.mod_page_height * 10 % 10 < 5 and math.floor(tro_config.mod_page_height) or math.ceil(tro_config.mod_page_height)

    page = page or SMODS.LAST_VIEWED_MODS_PAGE or 1
    SMODS.LAST_VIEWED_MODS_PAGE = page

    local modsColPerRow = w
    local modsRowPerPage = math.min( math.ceil(#SMODS.mod_list / w), h )
    local startIndex = (page - 1) * modsRowPerPage * modsColPerRow + 1
    local endIndex = startIndex + modsRowPerPage * modsColPerRow - 1

    local totalPages = math.ceil(#SMODS.mod_list / (modsRowPerPage * modsColPerRow))
    local currentPage = localize('k_page') .. ' ' .. page .. "/" .. totalPages

    local pageOptions = {}
    for i = 1, totalPages do
        table.insert(pageOptions, (localize('k_page') .. ' ' .. tostring(i) .. "/" .. totalPages))
    end
    local showingList = #SMODS.mod_list > 0

    return currentPage, pageOptions, showingList, startIndex, endIndex, modsRowPerPage, modsColPerRow
  end,

  createTextColNode = function(text, scale, colour, node)
    return { n = node or G.UIT.R, config = { padding = 0, align = "lc", maxw = 2.8, maxh = 1.5, },
      nodes = {
        { n = G.UIT.T, config = { text = text, colour = colour or G.C.UI.TEXT_LIGHT, scale = scale * 0.7 } },
      }
    }
  end,

  create_tile_spacer = function(w, h)
    return { n = G.UIT.B, config = { w = w, h = h } }
  end
}

return modpage_helper