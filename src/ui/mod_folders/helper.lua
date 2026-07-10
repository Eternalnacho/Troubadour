local T = Troubadour.UI
local m = assert(SMODS.load_file("src/mods_page/helper.lua"))()

-- Folder UI helper functions

local helper_funcs = {
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
                  T.Col ({ padding = 0.1, r = 0.1, colour = T.C.colour, outline = 1, outline_colour = bg_colour },
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
        local toChange = Folder:check_items()
        SMODS.full_restart = SMODS.full_restart + toChange
      end
    })
    if not Folder.should_enable_all then
      Troubadour.defer(function() G.FUNCS.toggle(t) end)
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

  recalculateList = function(list, page)
    page = page or 1
    local w = 6
    local h = 3
    return m.recalculateList(list, page, w, h)
  end,

  modList = function(Folder, page)
    local render = m.renderModList( Folder.items, page, Folder.UI.recalculateList, function(item)
      return Troubadour.UIDEF.modListIcon(SMODS.Mods[item.id])
    end)
    return T.UIBox ({ minw = 0, minh = 0, bg_colour = G.C.CLEAR }, {render})
  end,

  addList = function(Folder, page)
    local render = m.renderModList( Folder.items, page, Folder.UI.recalculateList, function(item)
      return Troubadour.ModTile({
        mod = SMODS.Mods[item.id],
        ref_table = Troubadour.ACTIVE_FOLDER.to_add,
        ref_value = item.id,
        button_func = 'TRO_toggle_tile',
        callback = function() T.updateObject('Troubadour_addQueue', Troubadour.ACTIVE_SEARCH:to_add()) end,
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
}

return helper_funcs
