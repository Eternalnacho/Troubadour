-- SEARCH FUNCTIONALITY (INSPIRED BY / ADAPTED FROM TMJ AND IMM)

---@class Searcher
---@field query string
---@field list any
---@field id string
---@field SEARCH_FUNCS function[]
---@field EXCLUDE_FUNCS function[]
local Searcher = Object:extend()

Searcher.init = function(self, args)
  Troubadour.ACTIVE_SEARCH = self
  self.query = ''
  self.list = args.list or {}
  self.id = args.id or 'TroubadourSearchResult'

  self.SEARCH_FUNCS = args.search_funcs or {}
  self.EXCLUDE_FUNCS = args.exclude_funcs or {}
end

Searcher.filter_invalid = function(self, list)
  for _, func in pairs(self.EXCLUDE_FUNCS) do
    list = Troubadour.utils.filter(list, func)
  end
  return list
end

Searcher.filter_query = function(self, list)
  local res = {}
  Troubadour.utils.for_each(list, function(item)
    for _, func in pairs(self.SEARCH_FUNCS) do
      if func(item) then res[#res+1] = item ; return end
    end
  end)
  return res
end

Searcher.get_list = function(self)
  local result = SMODS.shallow_copy(self.list)
  result = self:filter_invalid(result)
  result = self:filter_query(result)
  return result
end

Searcher.update_list = function(self, page)
  local list = self:get_list()
  Troubadour.UI.updateObject(self.id, self.render_list(list, page or 1))
end

-- Text Input Field
Searcher.get_text_input = function(self)
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

-- Result render needs to be defined elsewhere
Searcher.render_list = function(list, page) end

-- Option Selector requires a G.FUNCS entry
G.FUNCS.Troubadour_update_search = function(args)
  local Search = Troubadour.ACTIVE_SEARCH
  if not args or not args.cycle_config or not Search then return end
  Search:update_list(args.cycle_config.current_option)
end

-- Hooking the end of G.FUNCS.text_input_key for search-specific live updates
Troubadour.Hook('after', G.FUNCS, 'text_input_key', function()
  local hook_config = G.CONTROLLER.text_input_hook
      and G.CONTROLLER.text_input_hook.config.ref_table
  if Troubadour.ACTIVE_SEARCH and hook_config
      and hook_config.ref_table == Troubadour.ACTIVE_SEARCH
      and hook_config.ref_value == 'query' then
    Troubadour.ACTIVE_SEARCH:update_list()
  end
end)

Troubadour.Hook('before', love, 'keypressed', function(key)
  if key == "escape" and type(G.OVERLAY_MENU) == 'table' and Troubadour.ACTIVE_SEARCH then
    Troubadour.ACTIVE_SEARCH = nil
  end
end)

Troubadour.Searcher = Searcher