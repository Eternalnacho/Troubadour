local T = Troubadour.UI

--

local modpage_helper = {
  concatAuthors = function(authors)
    if type(authors) == "table" then
        return table.concat(authors, ", ")
    end
    return authors or localize('b_unknown')
  end,

  TextColumn = function(text, scale, colour, node)
    return {
      n = node or G.UIT.R,
      config = {
        padding = 0,
        align = "lc",
        maxw = 2.8,
        maxh = 1.5
      },
      nodes = {
        T.Text ({
          text = text,
          colour = colour or G.C.UI.TEXT_LIGHT,
          scale = scale * 0.7
        }),
      }
    }
  end,

  ---@param list table
  ---@param page integer
  ---@param width integer
  ---@param height integer
  recalculateList = function(list, page, width, height)
    page = page or 1
    width = width or 3
    height = height or 4

    local cols = width
    local rows = math.min( math.ceil( #list / cols ), ( height ) )

    local startIndex = ( page - 1 ) * rows * cols + 1
    local endIndex = startIndex + rows * cols - 1

    local totalPages = math.ceil( #list / ( rows * cols ) )
    local currentPage = localize('k_page') .. ' ' .. page .. "/" .. totalPages

    local pageOptions = {}
    for i = 1, totalPages do
      table.insert(pageOptions, (localize('k_page') .. ' ' .. tostring(i) .. "/" .. totalPages))
    end
    local showingList = #list > 0

    return currentPage, pageOptions, showingList, startIndex, endIndex, rows, cols
  end,

  renderModList = function(list, page, calc_func, item_func)
    local scale = 0.75
    local _, _, showingList, startIndex, endIndex, totalRows, totalCols = calc_func(page, list)

    local modNodes = {}
    -- If no mods are loaded, show a default message
    if showingList == false then
      table.insert(modNodes, T.Row { padding = 0, nodes = {
          T.Text { text = localize('b_no_mods'), shadow = true, scale = scale * 0.5, colour = G.C.UI.TEXT_DARK }
        }})
    else
      local modCount = 0
      local id = 0
      local current_row = {}

      for _, condition in ipairs({
        function(mod) return not mod.can_load and not mod.disabled end,
        function(mod) return mod.can_load end,
        function(mod) return mod.disabled end,
      }) do
        for _, item in ipairs(list) do
          if modCount >= totalRows * totalCols then break end
          if condition(SMODS.Mods[item.id]) then
            id = id + 1
            if id >= startIndex and id <= endIndex then
              table.insert(current_row,
                T.Col (
                  { align = "tm" },
                  { T.Col ({ padding = 0.0, minw = 1, minh = 1 }, { item_func(item) }) }
                )
              )
              modCount = modCount + 1
              if math.fmod(modCount, totalCols) == 0 then
                table.insert(modNodes, T.Row ({ padding = 0, align = "tl" }, current_row ))
                current_row = {}
              end
            end
          end
        end
      end
      if next(current_row) then
        table.insert(modNodes, T.Row ({ padding = 0, align = "tl" }, current_row ))
      end
    end

    return T.Col (
      { align = "tm" },
      { T.Row ({ align = "tm" }, { T.Col ({ r = 0.1, padding = 0, align = "tm", minw = 1.4 * totalCols }, modNodes) }) }
    )
  end,
}

modpage_helper.recalculateModsList = function(page)
  local w = math.round(Troubadour.config.mod_page_width)
  local h = math.round(Troubadour.config.mod_page_height)

  -- we don't use SMODS.LAST_VIEWED_MODS_PAGE here
  -- because the number of pages differs between the types of mod menu
  page = page or 1
  SMODS.LAST_VIEWED_MODS_PAGE = page

  return modpage_helper.recalculateList(SMODS.mod_list, page, w, h)
end

modpage_helper.recalculateModFoldersList = function(page)
  local w = 2
  local h = 4

  page = page or Troubadour.LAST_VIEWED_FOLDER_PAGE or 1
  Troubadour.LAST_VIEWED_FOLDER_PAGE = page

  return modpage_helper.recalculateList(Troubadour.FolderIndex, page, w, h)
end

return modpage_helper