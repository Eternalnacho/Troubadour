
Troubadour = {
  FUNCS = {},
  UIDEF = {},
  UI = {},
  ICONS = {},

  path_to_folders = function() return love.filesystem.getSaveDirectory().."/Troubadour - Mod Folders/" end,
  config = SMODS.current_mod.config
}

-- Get directory loader
local load_dir, load_folders = assert(SMODS.load_file("src/loader.lua"))()

-- Load directories
for _, path in ipairs {
  "functions",
  "ui",
  "api",
  "src/collection",
  "src/mods_page",
} do
  load_dir(path, "src/")
end

-- Load mod folders
load_folders()

-- Load config page
assert(SMODS.load_file("src/config_page.lua"))()

-- Load atlases
assert(SMODS.load_file("atlases.lua"))()

-- functions to execute after load
Troubadour.defer(Troubadour.FUNCS.widen_collection)