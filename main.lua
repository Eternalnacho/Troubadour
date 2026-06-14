tro_config = SMODS.current_mod.config

Troubadour = {
  FUNCS = {},
  UIDEF = {},
  UI = {},
  ICONS = {},
}

Troubadour.folders = {}

-- Get directory loader
local load_dir = assert(SMODS.load_file("src/loader.lua"))()

-- Load backend functions
load_dir("src/functions")

-- Load mod features
load_dir("src/items")

-- Load config page
assert(SMODS.load_file("src/config_page.lua"))()

-- Load atlases
assert(SMODS.load_file("atlases.lua"))()


-- functions to execute after load
Troubadour.defer(Troubadour.FUNCS.widen_collection)