local T = Troubadour.UI

-- SEARCH FIELD FUNCS (ADAPTED FROM TMJ AND IMM)
Troubadour.Searcher = Object:extend()

Troubadour.Searcher.init = function(self)
  Troubadour.ACTIVE_SEARCH = self
  self.folder = Troubadour.ACTIVE_FOLDER
  self.query = ''
  self.searchWidth = 8
end

Troubadour.Searcher.FUNCS = {
  id_contains_string = function(self, mod)
    return self.query == '' or mod.id:lower():find(self.query:lower(), 1, true)
  end,
  name_contains_string = function(self, mod)
    return self.query == '' or mod.name:lower():find(self.query:lower(), 1, true)
  end,
  not_in_folder = function(self, mod)
    return not Troubadour.ACTIVE_FOLDER:contains(mod)
  end,
}

Troubadour.Searcher.get_list = function(self)
  local result = {}
  for _, mod in pairs(SMODS.Mods) do
    local include = true
    for _, func in pairs(self.FUNCS) do
      if not func(self, mod) then include = false end
    end
    if include then result[#result+1] = mod end
  end
  return result
end

Troubadour.Searcher.update_list = function(self)
  local list = self:get_list()
end

Troubadour.Searcher.get_text_input = function(self)
  local args = {
    ref_table = self,
    ref_value = 'query',
    id = "troubadour_searcher_text_input",
    prompt_text = localize('b_tro_search_placeholder'),
    current_prompt_text = ''
  }

  local ret = create_text_input(args)
  ret.config.ref_table = args
  ret.nodes[1].nodes[1].nodes[1].config.ref_table = ret.config.ref_table
  return ret
end

G.FUNCS.Troubadour_searcher_text_input = function(e)
  e.Troubadour_searcher = true
  G.FUNCS.text_input(e)
end

Troubadour.Hook('after', _G, 'MODIFY_TEXT_INPUT', function()
  if Troubadour.ACTIVE_SEARCH then
    Troubadour.ACTIVE_SEARCH:update_list()
  end
end, true)