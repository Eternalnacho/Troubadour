local T = Troubadour.UI

-- SEARCH FIELD FUNCS (ADAPTED FROM TMJ AND IMM)
Troubadour.Searcher = Object:extend()

Troubadour.Searcher.init = function(self)
  self.folder = Troubadour.ACTIVE_FOLDER
  self.query = ''
end

Troubadour.Searcher.FUNCS = {
  contains_string = {
    ['id'] = function(self, mod)
      return mod.id:lower():find(self.query:lower(), 1, true)
    end,
    ['name'] = function(self, mod)
      return mod.name:lower():find(self.query:lower(), 1, true)
    end,
  },
  not_in_folder = function(mod)
    return not Troubadour.ACTIVE_FOLDER:contains(mod)
  end
}