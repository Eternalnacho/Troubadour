---@diagnostic disable: duplicate-set-field
-- CONFIG TAB UI
local T = Troubadour.UI

SMODS.current_mod.ui_config = {
  colour = T.C.colour,
  outline_colour = T.C.outline_colour,
  tab_button_colour = darken(T.C.buttons, 0.2),
  back_colour = T.C.active,
  -- misc. colours
  author_colour = HEX('E9B800'),
}

-- function SMODS.current_mod.config_tab()
--   return T.UIBox({
--     minw = 0.0, padding = 0.2, emboss = 0.05, bg_colour = G.C.BLACK,
--     contents = {
--       T.Row { padding = 0, align = "tl",
--         nodes = {
          
--         }
--       },
--     }
--   })
-- end

G.FUNCS.TRO_settings_change_tab = function(e)
  if not e then return end
  local tab_contents = e.UIBox:get_UIE_by_ID('TRO_settings_tab_contents')
  if not tab_contents then return end
  -- Same tab, don't rebuild it.
  if tab_contents.config.oid == e.config.id then return end
  if tab_contents.config.old_chosen then tab_contents.config.old_chosen.config.chosen = nil end

  tab_contents.config.old_chosen = e
  e.config.chosen = 'vert'

  tab_contents.config.oid = e.config.id
  tab_contents.config.object:remove()
  tab_contents.config.object = UIBox{
      definition = e.config.ref_table.tab_definition_function(e.config.ref_table.tab_definition_function_args),
      config = {offset = {x=0,y=0}, parent = tab_contents, type = 'cm'}
    }
  tab_contents.UIBox:recalculate()
end

-- Load Config Tabs
assert(SMODS.load_file("src/settings/tab_collection.lua"))()
assert(SMODS.load_file("src/settings/tab_modlist.lua"))()
assert(SMODS.load_file("src/settings/tab_reroll.lua"))()

function SMODS.current_mod.extra_tabs()
	return {
    {
			label = 'Collection',
			tab_definition_function = Troubadour.UIDEF.collection_tab
		},
		{
			label = 'Mods List',
			tab_definition_function = Troubadour.UIDEF.mod_list_tab
		},
    {
			label = 'Reroller',
			tab_definition_function = Troubadour.UIDEF.reroll_tab
		}
	}
end

function Troubadour.UI.update_config()
  if Troubadour.collection_from_button then
    Troubadour.UI.rerender(Troubadour.UI.config_from_collection, true)
  elseif Troubadour.config_from_modslist then
    Troubadour.UI.rerender(Troubadour.UI.config_from_modlist, true)
  else
    G.ACTIVE_MOD_UI = SMODS.Mods["Troubadour"]
    Troubadour.UI.rerender(create_UIBox_mods, true)
  end
end