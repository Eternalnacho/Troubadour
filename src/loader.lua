local function load_file(file, load_item)
  if file.init then
    file.init()
  end
  -- can add load funcs here later if need be
end

local function load_directory(path, load_item, options)
  options = options or {}
  local files = NFS.getDirectoryItems(SMODS.current_mod.path .. path)

  for _, file_path in ipairs(files) do
    local file_type = NFS.getInfo(SMODS.current_mod.path .. path .. '/' .. file_path).type

    if file_type == "directory" then
      load_directory(path .. '/' .. file_path, load_item, options)
    elseif file_type ~= "symlink" then
      local file = assert(SMODS.load_file(path .. '/' .. file_path))()

      if type(file) == 'table' and file.can_load ~= false then
        if options.pre_load then options.pre_load(file) end
        load_file(file, load_item)
        if options.post_load then options.post_load(file) end
      end
    end
  end
end

local function load_folders()
  -- load whatever file we store folder data in
  local folder_dir = SMODS.NFS.getInfo(Troubadour.path_to_folders())
  if folder_dir.type ~= "directory" then
    SMODS.NFS.createDirectory(Troubadour.path_to_folders())
  end
  folder_dir = SMODS.NFS.getDirectoryItems(Troubadour.path_to_folders())

  -- iterate over whatever list we load and do the init thing
  for _, path in pairs(folder_dir) do
    if SMODS.NFS.newFileData(Troubadour.path_to_folders()..'/'..path):getExtension() == 'json' then
      local folder_table = assert(JSON.decode(SMODS.NFS.read(Troubadour.path_to_folders()..'/'..path)))
      Troubadour.Folder(folder_table.name, folder_table.items)
    end
  end
end

return load_directory, load_folders