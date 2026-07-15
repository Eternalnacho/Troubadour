local F = Troubadour.FUNCS
local T = Troubadour.UI

-- Folder Inner UI Elements

local elements = {
  render = function(Folder)
    local colour, bg_colour, text_colour = Troubadour.UIDEF.get_mod_popup_colours()
    local folder_icon = SMODS.create_sprite(0, 0, 0.5, 0.5, 'tro_folder', {x = 0, y = 0})

    return T.Col { nodes = {
      T.Col (
        { -- config
          colour = bg_colour, emboss = 0.05, r = 0.1, minw = 1.5, minh = 1,
          shadow = true, shadow_height = 0.25, hover = true
        },
        { -- nodes
          T.Col (
            { -- config
              padding = 0.1, align = "lc", minw = 4.5, minh = 1, maxh = 1.4,
              emboss = 0.05, r = 0.1, colour = colour,
              button = "Troubadour_open_folder_" .. Folder.name
            },
            { -- nodes
              -- Folder Icon
              T.Col ({},
                {
                  T.Col (
                    {
                      padding = 0.1,
                      r = 0.1,
                      colour = T.C.colour,
                      outline = 1,
                      outline_colour = bg_colour
                    },
                    {
                      {
                        n = G.UIT.O,
                        config = {
                          w = SMODS.pixels_to_unit(34),
                          h = SMODS.pixels_to_unit(34),
                          colour = G.C.BLUE,
                          object = folder_icon,
                          focus_with_object = true
                        }
                      },
                    }
                  )
                }
              ),
              -- Folder Label
              T.Col ({ align = "lc"}, { T.Row({}, { Folder.UI.label(Folder.name, nil, text_colour) }) }),
            }
          ),
          -- Enable All / Disable All toggle
          T.Col ({}, { T.Row ({}, { Folder.UI.toggle(Folder) }) })
        }
      )
    }}
  end,

  label = function(name, minw, text_colour)
    return {
      n = G.UIT.O,
      config = {
        object = SMODS.UIScrollBox({
          content = DynaText({
            string = name,
            colours = { text_colour or G.C.UI.TEXT_LIGHT },
            shadow = true,
            scale = 0.375,
          }),
          container = { config = { can_collide = false } },
          overflow = {
            node_config = { no_overflow = "h", w = minw or 3 },
            config = { can_collide = false }
          },
          sync_mode = "progress",
          scroll_move = function(_self, dt)
            _self.real_progress = ((_self.real_progress or 0) + G.real_dt / 8) % 1
            if _self.real_progress < 0.25 then
              _self.scroll_progress.x = 0
            elseif _self.real_progress > 0.75 then
              _self.scroll_progress.x = 1
            else
              _self.scroll_progress.x = (_self.real_progress - 0.25) / 0.5
            end
          end,
        })
      }
    }
  end,

  toggle = function(Folder)
    local t = create_toggle({
      label = '',
      ref_table = Folder,
      ref_value = 'should_enable_all',
      col = true, hide_label = true,
      w = 0, h = 0.2, scale = 1,
      callback = function()
        Folder:toggle_all()
      end
    })
    if not Folder.should_enable_all then
      local toggle = t.nodes[1].nodes[1].nodes[1]
      if toggle then
        Troubadour.defer(function() G.FUNCS.toggle(toggle) end)
      end
    end
    return t
  end,

  button = function(label, colour, button_func)
    return T.Col ({ padding = 0 }, {
      UIBox_button({
        label = { localize(label) }, colour = colour, button = button_func,
        shadow = true, scale = 0.4, minh = 0.7, minw = 2,
      })
    })
  end,

  modList = function(Folder, page)
    local render = F.renderModList( Folder.items, page, Folder.UI.recalculateList, function(item)
      return Troubadour.UIDEF.modListIcon(SMODS.Mods[item.id])
    end)
    return T.UIBox ({ minw = 0, minh = 0, bg_colour = G.C.CLEAR }, {render})
  end,

  addList = function(list, page)
    local Folder = { items = list, UI = Troubadour.Folder.UI }
    local render = F.renderModList( Folder.items, page, Folder.UI.recalculateList, function(item)
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
    local render = F.renderModList( Folder.items, page, Folder.UI.recalculateList, function(item)
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