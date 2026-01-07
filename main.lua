tro_config = SMODS.current_mod.config
TRO = {}
TRO.FUNCS, TRO.UI = {}, {}

-- Get directory loader
local load_dir = assert(SMODS.load_file("src/loader.lua"))()

-- Load backend functions
load_dir("src/functions")

-- Load config page
assert(SMODS.load_file("src/config_page.lua"))()

-- Load hooks
load_dir("src/hooks")

-- Load auto-reroll and wider collection screen
load_dir("src/items")

-- Load atlases
assert(SMODS.load_file("atlases.lua"))()