---@diagnostic disable: undefined-field
local T = Troubadour.UI
local m = assert(SMODS.load_file("src/mods_page/helper.lua"))()

-- FOLDER OBJECT

Troubadour.Folders = {}
Troubadour.FolderIndex = {}
Troubadour.Folder = Object:extend()

---@param args table
function Troubadour.Folder:init(args)
  if self.ErrorHandler['name'](args.name) then return end

  self.name = args.name
  self.id = args.id or #Troubadour.FolderIndex + 1
  self.should_enable_all = args.enabled
  self.items = {}
  self.item_index = {}

  if args.items and next(args.items) then
    for _, item in ipairs(args.items) do self:add_item(SMODS.Mods[item.id]) end
  end

  Troubadour.Folders[args.name] = self
  Troubadour.FolderIndex[#Troubadour.FolderIndex + 1] = self

  G.FUNCS["Troubadour_open_folder_"..self.name] = function() self:open() end
  G.FUNCS["Troubadour_close_folder_"..self.name] = function() self:close() end
  self:save()
end

---@param item Mod
function Troubadour.Folder:add_item(item)
  if not self.ErrorHandler['item'](self, item) then
    self.items[#self.items+1] = {id = item.id, enabled = not item.disabled}
    self.item_index[item.id] = #self.items
  end
  self:save()
end

function Troubadour.Folder:remove_item(item)
  if self.item_index[item.id] then
    table.remove(self.items, self.item_index[item.id])
    self.item_index[item.id] = nil
  end
  self:save()
end

function Troubadour.Folder:contains(item)
  if self.item_index[item.id] then
    return true
  end
end

function Troubadour.Folder:save()
  local save_table = {
    ['name'] = self.name,
    ['id'] = self.id,
    ['items'] = self.items,
    ['enabled'] = self.should_enable_all
  }
  SMODS.NFS.write(Troubadour.path_to_folders()..self.name..'.json', JSON.encode(save_table))
end

function Troubadour.Folder:toggle_all()
  for _, item in pairs(self.items) do
    local mod = SMODS.Mods[item.id]
    mod.should_enable = self.should_enable_all
    if not mod.should_enable then
      SMODS.NFS.write(mod.path .. '.lovelyignore', '')
    else
      SMODS.NFS.remove(mod.path .. '.lovelyignore')
    end
  end
  self:save()
end

function Troubadour.Folder:check_items()
  local changes = false
  for _, item in pairs(self.items) do
    local mod = SMODS.Mods[item.id]
    if mod.should_enable ~= item.enabled then
      changes = true
    end
  end
  return changes
end

function Troubadour.Folder:open()
  Troubadour.ACTIVE_FOLDER = self
  G.FUNCS.overlay_menu{ definition = self.UI.window(self) }
  G.OVERLAY_MENU:recalculate()
end

function Troubadour.Folder:close()
  -- Something something overlay menu back func
  G.FUNCS.mods_button()
end

function Troubadour.Folder:delete()
  SMODS.NFS.remove(Troubadour.path_to_folders()..self.name..'.json')
  Troubadour.Folders[self.name] = nil
  table.remove(Troubadour.FolderIndex, self.id)
  Troubadour.reindexFolders()
end

function Troubadour.reindexFolders()
  for i, Folder in ipairs(Troubadour.FolderIndex) do
    Folder.id = i
    Folder:save()
  end
end

Troubadour.Folder.ErrorHandler = {
  name = function(name)
    if not name or name == '' then
      sendWarnMessage(('No name entered, not creating folder'))
      return true
    elseif Troubadour.Folders[name] then
      sendWarnMessage(('Detected duplicate folder name, not creating folder'))
      return true
    end
  end,

  item = function(Folder, item)
    if not item or not SMODS.Mods[item.id] then
      sendWarnMessage(('Item not found'))
      return true
    end
    if Folder:contains(item) then
      sendWarnMessage(('Item "' .. item.name .. '" already in folder'))
      return true
    end
  end
}

Troubadour.Folder.UI = {
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
                  T.Col ( { padding = 0.1, r = 0.1, colour = T.C.colour, outline = 1, outline_colour = bg_colour },
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
              T.Col ({ align = "lc"}, { T.Row({}, { Folder.UI.label(Folder, nil, text_colour) }) }),
            }
          ),
          -- Enable All / Disable All toggle
          T.Col ({}, { T.Row ({}, { Folder.UI.toggle(Folder) }) })
        }
      )
    }}
  end,

  label = function(Folder, minw, text_colour)
    return {
      n = G.UIT.O,
      config = {
        object = SMODS.UIScrollBox({
          content = DynaText({
            string = Folder.name,
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
      callback = function(_set_toggle)
        Folder:toggle_all()
        local toChange = Folder:check_items() and 1 or -1
        SMODS.full_restart = SMODS.full_restart + toChange
      end
    })
    if not Folder.should_enable_all then
      Troubadour.defer(function() G.FUNCS.toggle(t) end)
    end
    return t
  end,

  window = function(Folder)
    local scale = 0.75
    local currentPage, pageOptions, showingList, _, _, dminh, dminw = m.recalculateModFolder(Folder)

    Troubadour.defer(function() G.FUNCS.Troubadour_update_folder_items({cycle_config = {}}) end)

    return create_UIBox_generic_options({
      colour = G.C.BLACK,
      outline_colour = T.C.outline_colour,
      back_func = "Troubadour_close_folder_" .. Folder.name,
      contents = { -- nodes
        T.Row { minh = 1.5 * dminh + 1, minw = 1.5 * dminw + 1, r = 0.1, colour = G.C.BLACK, nodes = {
          -- row container
          T.Col { nodes = {
            -- column container
            T.Col { r = 0.1, nodes = {
              -- title row
              T.Row ({ padding = 0 }, {
                T.Col ({ padding = 0.1, minw = dminw, outline = 1, r = 0.1}, {
                  T.Text { text = Folder.name, shadow = true, scale = scale, colour = G.C.UI.TEXT_LIGHT },
                })
              }),
              -- dynamic content rendered in this row container
              -- list of 4 x 3 mods on the current page
              T.Row { minh = dminh + 1, minw = dminw + 1,
                nodes = {
                  { n = G.UIT.O, config = { align = "cm", id = 'TroubadourFolderItems', object = Moveable() } },
                }
              },
              -- another empty row for spacing
              T.Row { padding = 0.8 },
              -- folder controls
              T.Row { padding = 0.5, nodes = {
                -- remove mod button
                showingList and T.Col ({ padding = 0 },
                  {
                    UIBox_button({
                      label = { localize('b_tro_remove_item') },
                      shadow = true,
                      scale = 0.4,
                      colour = darken(G.C.MULT, 0.1),
                      button = "Troubadour_delete_mod_folder_window", -- [[REPLACE WITH REMOVE MOD BUTTON FUNC]]
                      minh = 0.7,
                      minw = 2,
                    })
                  }
                ) or nil,
                -- Page Selector
                showingList and T.Col { nodes = {
                  SMODS.GUI.createOptionSelector({
                    colour = T.C.active,
                    scale = 0.8,
                    options = pageOptions,
                    opt_callback = 'Troubadour_update_folder_items',
                    no_pips = true,
                    current_option = ( currentPage )
                  })
                }} or nil,
                -- Add Mod Button
                T.Col ({ padding = 0 },
                  {
                    UIBox_button({
                      label = { localize('b_tro_add_item') },
                      shadow = true,
                      scale = 0.4,
                      colour = G.C.BOOSTER,
                      button = "Troubadour_add_item_to_blargle", -- [[REPLACE WITH ADD MOD BUTTON FUNC]]
                      minh = 0.7,
                      minw = 2,
                    })
                  }
                ),
              }},
            }}
          }}
        }}
      }
    })
  end,
}