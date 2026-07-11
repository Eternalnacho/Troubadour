local T = Troubadour.UI
local m = assert(SMODS.load_file("src/mods_page/helper.lua"))()

-- Folder Inner UI Elements

local elements = {
  modList = function(Folder, page)
    local render = m.renderModList( Folder.items, page, Folder.UI.recalculateList, function(item)
      return Troubadour.UIDEF.modListIcon(SMODS.Mods[item.id])
    end)
    return T.UIBox ({ minw = 0, minh = 0, bg_colour = G.C.CLEAR }, {render})
  end,

  addList = function(list, page)
    local Folder = { items = list, UI = Troubadour.Folder.UI }
    local render = m.renderModList( Folder.items, page, Folder.UI.recalculateList, function(item)
      return Troubadour.ModTile({
        mod = SMODS.Mods[item.id],
        ref_table = Troubadour.ACTIVE_FOLDER.to_add,
        ref_value = item.id,
        button_func = 'TRO_toggle_tile',
        callback = function()
          local active = Troubadour.ACTIVE_FOLDER
          T.updateObject('Troubadour_addQueue', active.UI.addQueueUIBox(active))
        end,
        colour_override = {
          enabled = G.C.BOOSTER
        },
      }):render()
    end)
    return T.UIBox ({ minw = 9, minh = 5, bg_colour = G.C.CLEAR }, {render})
  end,

  deleteList = function(Folder, page)
    local render = m.renderModList( Folder.items, page, Folder.UI.recalculateList, function(item)
      return Troubadour.ModTile({
        mod = SMODS.Mods[item.id],
        ref_table = Folder.to_remove,
        ref_value = item.id,
        button_func = 'TRO_toggle_tile',
        callback = function() end, -- this needs to be an empty function because the default for mod tiles is the restart check
        colour_override = {
          enabled = darken(G.C.MULT, 0.5)
        },
      }):render()
    end)
    return T.UIBox ({ minw = 0, minh = 0, bg_colour = G.C.CLEAR }, {render})
  end,

  addQueueUIBox = function(Folder)
    local title_row = T.Row ({ minh = 0.5 }, { T.Text ({ text = "To Add:", colour = G.C.UI.TEXT_LIGHT, scale = 0.5 }) })
    local display_list = Folder.UI.addQueueTargets(Folder)
    local render = T.Row ({ r = 0.2, padding = 0.15 }, { title_row, display_list })
    return T.UIBox ({ minh = 0, minw = 2, bg_colour = T.C.inactive }, {render})
  end,

  addQueueTargets = function(Folder)
    local target_list = {}

    -- Local function for list nodes
    local label_node = function(label)
      return T.Row (
        { r = 0.2, minw = 3.75 },
        { Troubadour.Folder.UI.label(label, 3.5, G.C.WHITE) }
      )
    end

    -- Add a label node to target_list for each viable target
    for id, is_target in pairs(Folder.to_add) do
      local target = is_target and SMODS.Mods[id] and SMODS.Mods[id].name
      target_list[#target_list+1] = target and label_node(target) or nil
    end

    -- Default case when the list is empty
    if not next(target_list) then target_list = { label_node('') } end

    -- Final list UI
    local result_ui = T.Row ({ --[[config]] }, { T.Col ({ colour = G.C.GREY, r = 0.2 }, target_list) })
    return result_ui
  end
}

return elements