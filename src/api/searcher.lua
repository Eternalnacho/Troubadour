local T = Troubadour.UI
local m = assert(SMODS.load_file("src/mods_page/helper.lua"))()

-- SEARCH FIELD FUNCS (ADAPTED FROM TMJ AND IMM)
Troubadour.Searcher = Object:extend()

Troubadour.Searcher.init = function(self)
  Troubadour.ACTIVE_SEARCH = self
  self.folder = Troubadour.ACTIVE_FOLDER
  self.targets = {}

  self.query = ''
  self.searchWidth = 8
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
  local result = SMODS.shallow_copy(SMODS.Mods)
  result = self:filter_invalid(result)
  result = self:filter_query(result)
  return result
end

Troubadour.Searcher.update_list = function(self, page)
  local list = self:get_list()
  local fake_folder = { items = list, UI = self.folder.UI }
  SMODS.GUI.DynamicUIManager.updateDynamicAreas({
    ["TroubadourSearchResult"] = self:render_list(fake_folder, page or 1)
  })
end

G.FUNCS.Troubadour_update_search = function(args)
  if not args or not args.cycle_config then return end
  if not Troubadour.ACTIVE_SEARCH then return end
  Troubadour.ACTIVE_SEARCH:update_list(args.cycle_config.current_option)
end

Troubadour.Hook('after', G.FUNCS, 'text_input_key', function()
  local hook_config = G.CONTROLLER.text_input_hook and G.CONTROLLER.text_input_hook.config.ref_table
  if Troubadour.ACTIVE_SEARCH and hook_config and hook_config.ref_value == 'query' then
    Troubadour.ACTIVE_SEARCH:update_list()
  end
end)

-- UI

-- Dynamic Mod List
Troubadour.Searcher.render_list = function(self, Folder, page)
  local render = m.renderModList( Folder.items, page, Folder.UI.recalculateList, function(item)
    return Troubadour.ModTile({
      mod = SMODS.Mods[item.id],
      ref_table = self.targets,
      ref_value = item.id,
      button_func = 'TRO_toggle_tile',
      callback = function()
        Troubadour.ACTIVE_SEARCH:update_targets(G.OVERLAY_MENU:get_UIE_by_ID('Troubadour_addQueue'))
      end,
      colour_override = {
        enabled = G.C.BOOSTER
      },
    }):render()
  end)
  return T.UIBox({ minw = 9, minh = 5, bg_colour = G.C.CLEAR, contents = {render} })
end

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

-- Target list update function
Troubadour.Searcher.update_targets = function(self, object)
  if object then
    object.config.object:remove()
    object.config.object = UIBox({ definition = self:to_add(), config = {type = "cm", parent = object}})
    object.UIBox:recalculate()
  end
end

Troubadour.Searcher.to_add = function(self)
  local display_list = self:get_targets()
  table.insert(display_list.nodes, 1, T.Row { minh = 0.7, nodes = { T.Text { text = "To Add:", colour = G.C.UI.TEXT_LIGHT, scale = 0.5 } } })
  return T.UIBox{ minh = 0.0, minw = 0.0, bg_colour = T.C.inactive, contents = { T.Row { r = 0.2, padding = 0.15, nodes = display_list.nodes } } }
end

Troubadour.Searcher.get_targets = function(self)
  local display_list = T.Col ({ colour = G.C.GREY }, { T.Row ({}, { T.Col ({ colour = G.C.GREY, r = 0.2 }, {}) }) })
  local nodes = display_list.nodes[1].nodes[1].nodes

  for id, v in pairs(self.targets) do
    local target = v and SMODS.Mods[id] and SMODS.Mods[id].name
    table.insert(nodes, target and T.Row ({ r = 0.2, minw = 3}, { T.Text { text = target, colour = G.C.WHITE, scale = 0.4 } }) or nil)
  end

  local default = T.Row ({ r = 0.2, minw = 3 }, { T.Text { text = '', colour = G.C.WHITE, scale = 0.4 } })
  if not next(nodes) then table.insert(nodes, default) end
  return display_list
end