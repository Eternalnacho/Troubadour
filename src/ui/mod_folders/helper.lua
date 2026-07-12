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

  search_funcs = {
    id_contains_str = function(mod)
      local Search = Troubadour.ACTIVE_SEARCH
      return Search.query == '' or mod.id:lower():find(Search.query:lower(), 1, true)
    end,
    name_contains_str = function(mod)
      local Search = Troubadour.ACTIVE_SEARCH
      return Search.query == '' or mod.name and mod.name:lower():find(Search.query:lower(), 1, true)
    end,
    author_contains_str = function(mod)
      local Search = Troubadour.ACTIVE_SEARCH
      for _, auth in ipairs(mod.author) do
        local found = Search.query == '' or auth and auth:lower():find(Search.query:lower(), 1, true)
        if found then return found end
      end
    end,
    desc_contains_str = function(mod)
      local Search = Troubadour.ACTIVE_SEARCH
      return Search.query == '' or mod.description and mod.description:lower():find(Search.query:lower(), 1, true)
    end,
    deps_contain_str = function(mod)
      local Search = Troubadour.ACTIVE_SEARCH
      local filter = Troubadour.utils.filter((mod.dependencies or {}), function(dep)
        return dep[1]
          and dep[1].id ~= "Steamodded"
          and dep[1].id ~= "Lovely"
          and dep[1].id ~= "Balatro"
      end)
      for _, dep in pairs(filter or {}) do
        local found = Search.query == '' or dep[1].id and dep[1].id:lower():find(Search.query:lower(), 1, true)
        if found then return found end
      end
    end,
  },

  exclude_funcs = {
    in_folder = function(mod)
      return not Troubadour.ACTIVE_FOLDER:contains(mod)
    end,
    meta_mod = function(mod)
      return not mod.meta_mod
    end,
  }
}

return helper_funcs
