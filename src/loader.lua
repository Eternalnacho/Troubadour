local dir_index = {
  ['functions'] = {
    "utils.lua",
    "ui.lua",
    "inputmanager.lua"
  },

  ['api'] = {
    "folder.lua",
    "tile.lua",
    "modtile.lua"
  }
}

local function load_directory_from_index(path, prefix)
  for _, file in ipairs(dir_index[path]) do
    assert(SMODS.load_file(prefix .. path .. '/' .. file))()
  end
end

local function load_directory(path, load_item)
  if dir_index[path] then
    load_directory_from_index(path, "src/")
  end
  local files = NFS.getDirectoryItems(SMODS.current_mod.path .. path)

  for _, file_path in ipairs(files) do
    local file_type = NFS.getInfo(SMODS.current_mod.path .. path .. '/' .. file_path).type

    if file_type == "directory" then
      load_directory(path .. '/' .. file_path, load_item)
    elseif file_type ~= "symlink" then
      assert(SMODS.load_file(path .. '/' .. file_path))()
    end
  end
end

local function load_folders()
  -- load whatever file we store folder data in
  SMODS.NFS.createDirectory(Troubadour.path_to_folders())
  local folder_dir = SMODS.NFS.getDirectoryItems(Troubadour.path_to_folders())

  -- iterate over whatever list we load and do the init thing
  if folder_dir and next(folder_dir) then
    for _, path in pairs(folder_dir) do
      if SMODS.NFS.newFileData(Troubadour.path_to_folders()..'/'..path):getExtension() == 'json' then
        local folder_table = assert(JSON.decode(SMODS.NFS.read(Troubadour.path_to_folders()..'/'..path)))
        Troubadour.Folder({
          name = folder_table.name,
          id = folder_table.id,
          items = folder_table.items
        })
        print("Registered Folder: '"..folder_table.name.."'")
      end
    end
  end

  table.sort(Troubadour.FolderIndex, function(a, b) return a.id < b.id end)
  Troubadour.reindexFolders()
end

return load_directory, load_folders