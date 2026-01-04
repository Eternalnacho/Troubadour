tro_config = SMODS.current_mod.config
TRO = {}
TRO.FUNCS, TRO.UI = {}, {}

to_number = to_number or function(x) return x end

-- Load atlases
assert(SMODS.load_file("atlases.lua"))()

-- Load backend functions
assert(SMODS.load_file("src/functions/utils.lua"))()
assert(SMODS.load_file("src/functions/inputmanager.lua"))()
assert(SMODS.load_file("src/functions/reroll_simulator.lua"))()

-- Load hooks
assert(SMODS.load_file("src/hooks/collection_hooks.lua"))()

-- Load config page
assert(SMODS.load_file("src/settings.lua"))()

-- Load auto-reroll and wider collection screen
assert(SMODS.load_file("src/reroll_until.lua"))()
assert(SMODS.load_file("src/reroll_until_ui.lua"))()
assert(SMODS.load_file("src/wider_collection.lua"))()