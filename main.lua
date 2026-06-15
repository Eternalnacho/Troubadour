tro_config = SMODS.current_mod.config

Troubadour = {
  FUNCS = {},
  UIDEF = {},
  UI = {},
  ICONS = {},

  path_to_folders = function() return love.filesystem.getSaveDirectory().."/Troubadour - Mod Folders/" end,
}

-- Get directory loader
local load_dir, load_folders = assert(SMODS.load_file("src/loader.lua"))()

-- Load directories
for _, path in ipairs {
  "src/functions",
  "src/collection",
  "src/mods_page",
  "src/reroller",
} do
  load_dir(path)
end

-- Load mod folders
assert(SMODS.load_file("src/objects/folder.lua"))()
load_folders()
Troubadour.Folder('argle')
Troubadour.Folder('blargle')
Troubadour.Folder('Supercalifragilisticexpialidocious is a very long word and also i am writing a long name lmao lol get rekt')

-- Load config page
assert(SMODS.load_file("src/config_page.lua"))()

-- Load atlases
assert(SMODS.load_file("atlases.lua"))()

-- functions to execute after load
Troubadour.defer(Troubadour.FUNCS.widen_collection)