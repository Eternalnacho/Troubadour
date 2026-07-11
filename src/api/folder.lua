-- FOLDER OBJECT

Troubadour.Folders = {}
Troubadour.FolderIndex = {}
Troubadour.Folder = Object:extend()

---@param args table
function Troubadour.Folder:init(args)
  if self.ErrorHandler['name'](args.name) then return end

  self.name = args.name
  self.id = args.id or #Troubadour.FolderIndex + 1
  self.should_enable_all = args.enabled or (args.enabled == nil and true)
  self.items = {}
  self.item_index = {}

  if args.items and next(args.items) then
    for _, item in ipairs(args.items) do self:add_item(SMODS.Mods[item.id]) end
  end

  Troubadour.Folders[args.name] = self
  Troubadour.FolderIndex[#Troubadour.FolderIndex + 1] = self

  G.FUNCS["Troubadour_open_folder_"..self.name] = function() self:open() end
  G.FUNCS["Troubadour_close_folder_"..self.name] = function() self:close() end
  self:save()
end

---@param item Mod
function Troubadour.Folder:add_item(item)
  if not self.ErrorHandler['item'](self, item) then
    self.items[#self.items+1] = {id = item.id, enabled = not item.disabled}
    self.item_index[item.id] = #self.items
  end
  self:save()
end

function Troubadour.Folder:remove_item(item)
  if self.item_index[item.id] then
    table.remove(self.items, self.item_index[item.id])
    self.item_index[item.id] = nil
  end
  self:reindex_items()
  self:save()
end

function Troubadour.Folder:reindex_items()
  for i, item in ipairs(self.items) do
    self.item_index[item.id] = i
  end
end

function Troubadour.Folder:contains(item)
  if self.item_index[item.id] then
    return true
  end
end

function Troubadour.Folder:save()
  local save_table = {
    ['name'] = self.name,
    ['id'] = self.id,
    ['items'] = self.items,
    ['enabled'] = self.should_enable_all
  }
  SMODS.NFS.write(Troubadour.path_to_folders()..self.name..'.json', JSON.encode(save_table))
end

function Troubadour.Folder:toggle_all()
  for _, item in pairs(self.items) do
    local mod = SMODS.Mods[item.id]
    mod.should_enable = self.should_enable_all
    if not mod.should_enable then
      SMODS.NFS.write(mod.path .. '.lovelyignore', '')
    else
      SMODS.NFS.remove(mod.path .. '.lovelyignore')
    end
  end
  self:save()
end

function Troubadour.Folder:check_items()
  local changes = 0
  for _, item in pairs(self.items) do
    local mod = SMODS.Mods[item.id]
    if mod.should_enable ~= item.enabled then
      changes = changes + 1
    end
  end
  return changes
end

function Troubadour.Folder:open()
  Troubadour.ACTIVE_FOLDER = self
  G.FUNCS.overlay_menu{ definition = self.UI.mainWindow(self) }
  G.OVERLAY_MENU:recalculate()
end

function Troubadour.Folder:close()
  -- Something something overlay menu back func
  Troubadour.ACTIVE_FOLDER = nil
  G.FUNCS.mods_button()
end

function Troubadour.Folder:delete()
  SMODS.NFS.remove(Troubadour.path_to_folders()..self.name..'.json')
  Troubadour.Folders[self.name] = nil
  table.remove(Troubadour.FolderIndex, self.id)
  Troubadour.reindexFolders()
end

-- Folder Error Handling: Usually related to duplicate or nil values
Troubadour.Folder.ErrorHandler = {
  name = function(name)
    if not name or name == '' then
      sendWarnMessage(('No name entered, not creating folder'))
      return true
    elseif Troubadour.Folders[name] then
      sendWarnMessage(('Detected duplicate folder name, not creating folder'))
      return true
    end
  end,

  item = function(Folder, item)
    if not item or not SMODS.Mods[item.id] then
      sendWarnMessage(('Item not found'))
      return true
    end
    if Folder:contains(item) then
      sendWarnMessage(('Item "' .. item.name .. '" already in folder'))
      return true
    end
  end
}

-- Folder UI Functions
local helper_funcs = assert(SMODS.load_file("src/ui/mod_folders/helper.lua"))()
local window_funcs = assert(SMODS.load_file("src/ui/mod_folders/windows.lua"))()
local inner_funcs = assert(SMODS.load_file("src/ui/mod_folders/content.lua"))()
Troubadour.Folder.UI = {}
for _, funcs in pairs({ helper_funcs, window_funcs, inner_funcs }) do
  for k, func in pairs(funcs) do
    Troubadour.Folder.UI[k] = func
  end
end

function Troubadour.reindexFolders()
  for i, Folder in ipairs(Troubadour.FolderIndex) do
    Folder.id = i
    Folder:save()
  end
end

Troubadour.Hook('before', love, 'keypressed', function(key)
  if key == "escape" and Troubadour.ACTIVE_FOLDER then
    local Folder = Troubadour.ACTIVE_FOLDER
    if Folder.to_remove or Folder.to_add then
      Folder.to_remove = nil
      Folder.to_add = nil
      Folder:open()
      return
    else Folder:close(); return end
  end
end)