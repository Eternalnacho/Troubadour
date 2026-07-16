local F = Troubadour.FUNCS

-- Folder UI helper functions

local helper_funcs = {
  recalculateList = function(page, list)
    page = page or 1
    local w = 6
    local h = 3
    return F.recalculateList(list, page, w, h)
  end,

  search_funcs = {
    id_contains_str = function(mod)
      local Search = Troubadour.ACTIVE_SEARCH
      return Search.query == '' or mod.id:lower():find(Search.query:lower(), 1, true)
    end,
    name_contains_str = function(mod)
      local Search = Troubadour.ACTIVE_SEARCH
      return Search.query == '' or mod.name and mod.name:lower():find(Search.query:lower(), 1, true)
    end,
    prefix_contains_str = function(mod)
      local Search = Troubadour.ACTIVE_SEARCH
      return Search.query == '' or mod.prefix and mod.prefix:lower():find(Search.query:lower(), 1, true)
    end,
    author_contains_str = function(mod)
      local Search = Troubadour.ACTIVE_SEARCH
      for _, auth in ipairs(mod.author) do
        local found = Search.query == '' or auth and auth:lower():find(Search.query:lower(), 1, true)
        if found then return found end
      end
    end,
    desc_contains_str = function(mod)
      local Search = Troubadour.ACTIVE_SEARCH
      return Search.query == '' or mod.description and mod.description:lower():find(Search.query:lower(), 1, true)
    end,
    deps_contain_str = function(mod)
      local Search = Troubadour.ACTIVE_SEARCH
      local filter = Troubadour.utils.filter((mod.dependencies or {}), function(dep)
        return dep[1]
          and dep[1].id ~= "Steamodded"
          and dep[1].id ~= "Lovely"
          and dep[1].id ~= "Balatro"
      end)
      for _, dep in pairs(filter or {}) do
        local found = Search.query == '' or dep[1].id and dep[1].id:lower():find(Search.query:lower(), 1, true)
        if found then return found end
      end
    end,
  },

  exclude_funcs = {
    in_folder = function(mod)
      return not Troubadour.ACTIVE_FOLDER or not Troubadour.ACTIVE_FOLDER:contains(mod)
    end,
    meta_mod = function(mod)
      return not mod.meta_mod
    end,
  }
}

return helper_funcs
