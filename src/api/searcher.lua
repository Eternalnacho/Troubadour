local T = Troubadour.UI

-- SEARCH FUNCTIONALITY (ADAPTED FROM TMJ AND IMM)

Troubadour.Searcher = Object:extend()

Troubadour.Searcher.init = function(self)
  Troubadour.ACTIVE_SEARCH = self
  self.targets = {}
  self.query = ''
end

Troubadour.Searcher.SEARCH_FUNCS = {
  id_contains_string = function(mod)
    local Search = Troubadour.ACTIVE_SEARCH
    return Search.query == '' or mod.id:lower():find(Search.query:lower(), 1, true)
  end,
  name_contains_string = function(mod)
    local Search = Troubadour.ACTIVE_SEARCH
    return Search.query == '' or mod.name and mod.name:lower():find(Search.query:lower(), 1, true)
  end,
}

Troubadour.Searcher.INVALID_FUNCS = {
  in_folder = function(mod)
    return not Troubadour.ACTIVE_FOLDER:contains(mod)
  end,
  meta_mod = function(mod)
    return not mod.meta_mod
  end,
}

Troubadour.Searcher.filter_invalid = function(self, list)
  for _, func in pairs(self.INVALID_FUNCS) do
    list = Troubadour.utils.filter(list, func)
  end
  return list
end

Troubadour.Searcher.filter_query = function(self, list)
  for _, func in pairs(self.SEARCH_FUNCS) do
    list = Troubadour.utils.filter(list, func)
  end
  return list
end

Troubadour.Searcher.get_list = function(self)
  local result = SMODS.shallow_copy(SMODS.mod_list)
  result = self:filter_invalid(result)
  result = self:filter_query(result)
  return result
end

Troubadour.Searcher.update_list = function(self, page, id)
  local list = self:get_list()
  local fake_folder = { items = list, UI = Troubadour.Folder.UI }
  T.updateObject(id or 'TroubadourSearchResult', self.render_list(fake_folder, page or 1))
end

G.FUNCS.Troubadour_update_search = function(args)
  if not args or not args.cycle_config then return end
  if not Troubadour.ACTIVE_SEARCH then return end
  Troubadour.ACTIVE_SEARCH:update_list(args.cycle_config.current_option)
end

Troubadour.Hook('after', G.FUNCS, 'text_input_key', function()
  local hook_config = G.CONTROLLER.text_input_hook and G.CONTROLLER.text_input_hook.config.ref_table
  if Troubadour.ACTIVE_SEARCH and hook_config and hook_config.ref_table == Troubadour.ACTIVE_SEARCH and hook_config.ref_value == 'query' then
    Troubadour.ACTIVE_SEARCH:update_list()
  end
end)

-- UI

-- Text Input Field
Troubadour.Searcher.get_text_input = function(self)
  local args = {
    ref_table = self,
    ref_value = 'query',
    id = "troubadour_searcher_text_input",
    prompt_text = localize('b_tro_search_placeholder'),
    current_prompt_text = '',
    extended_corpus = true,
  }
  local ret = create_text_input(args)
  return ret
end

-- Dynamic Mod List
Troubadour.Searcher.render_list = function(Folder, page) end