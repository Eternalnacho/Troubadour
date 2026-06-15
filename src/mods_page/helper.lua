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

    page = page or 1
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

  recalculateModFoldersList = function(page)
    page = page or Troubadour.LAST_VIEWED_FOLDER_PAGE or 1
    Troubadour.LAST_VIEWED_FOLDER_PAGE = page

    local foldersRowPerPage = math.min( math.ceil(#Troubadour.FolderIndex / 2), 4 )
    local foldersColPerRow = 2
    local startIndex = (page - 1) * foldersRowPerPage * foldersColPerRow + 1
    local endIndex = startIndex + foldersRowPerPage * foldersColPerRow - 1

    local totalPages = math.ceil(#Troubadour.FolderIndex / (foldersRowPerPage * foldersColPerRow))
    local currentPage = localize('k_page') .. ' ' .. page .. "/" .. totalPages

    local pageOptions = {}
    for i = 1, totalPages do
      table.insert(pageOptions, (localize('k_page') .. ' ' .. tostring(i) .. "/" .. totalPages))
    end
    local showingList = #Troubadour.FolderIndex > 0

    return currentPage, pageOptions, showingList, startIndex, endIndex, foldersRowPerPage, foldersColPerRow
  end,

  TextColumn = function(text, scale, colour, node)
    return { n = node or G.UIT.R, config = { padding = 0, align = "lc", maxw = 2.8, maxh = 1.5, },
      nodes = {
        { n = G.UIT.T, config = { text = text, colour = colour or G.C.UI.TEXT_LIGHT, scale = scale * 0.7 } },
      }
    }
  end,
}

return modpage_helper