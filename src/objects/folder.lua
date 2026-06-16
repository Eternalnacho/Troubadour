---@diagnostic disable: undefined-field
local T = Troubadour.UI

-- FOLDER OBJECT

Troubadour.Folders = {}
Troubadour.FolderIndex = {}
Troubadour.Folder = Object:extend()

---@param name string
---@param items table
function Troubadour.Folder:init(name, items)
  if self:handle_errors(name) then return end

  self.name = name
  self.id = #Troubadour.FolderIndex + 1
  self.should_enable_all = true
  self.items = {}
  self.item_index = {}

  if items and next(items) then
    for _, item in ipairs(items) do self:add_item(SMODS.Mods[item]) end
  end

  Troubadour.Folders[name] = self
  Troubadour.FolderIndex[#Troubadour.FolderIndex + 1] = self
  G.FUNCS["Troubadour_open_folder_"..self.name] = function() self:open() end

  self:save()
end

function Troubadour.Folder:add_item(item)
  if not Troubadour.utils.contains(self.items, item.id) then
    self.items[#self.items+1] = item.id
    self.item_index[item.id] = #self.items
  end
  self:save()
end

function Troubadour.Folder:remove_item(item)
  if self.items[item.id] then
    table.remove(self.items, self.item_index[item.id])
    self.item_index[item.id] = nil
  end
  self:save()
end

function Troubadour.Folder:save()
  local save_table = {
    ['name'] = self.name,
    ['items'] = self.items,
  }
  SMODS.NFS.write(Troubadour.path_to_folders()..self.name..'.json', JSON.encode(save_table))
end

function Troubadour.Folder:open()
  -- Something something overlay menu
end

function Troubadour.Folder:close()
  -- Something something overlay menu back func
end

function Troubadour.Folder:delete()
  SMODS.NFS.remove(Troubadour.path_to_folders()..self.name..'.lua')
  Troubadour.Folders[self.name] = nil
  table.remove(Troubadour.FolderIndex, self.id)
end

function Troubadour.Folder:render()
  local colour, bg_colour, _ = Troubadour.ICONS.get_mod_popup_colours({ can_load = true })
  local folder_icon = SMODS.create_sprite(0, 0, 0.5, 0.5, 'tro_folder', {x = 0, y = 0})
  local folder_tab = T.Col { padding = 0.1, r = 0.1, colour = T.C.colour, outline = 1, outline_colour = bg_colour, nodes = {
      { n = G.UIT.O, config = { w = SMODS.pixels_to_unit(34), h = SMODS.pixels_to_unit(34), colour = G.C.BLUE, object = folder_icon, focus_with_object = true } },
    }}
  local label_node = self:get_label()

  return T.Col { nodes = {
    T.Col {
      colour = bg_colour, emboss = 0.05, r = 0.1, minw = 1.5, minh = 1, shadow = true, shadow_height = 0.25, hover = true,
      nodes = {
        T.Col {
          padding = 0.1, align = "lc", minw = 4.5, minh = 1, maxh = 1.4, emboss = 0.05, r = 0.1,
          colour = colour,
          button = "Troubadour_open_folder_" .. self.name,
          nodes = {
            T.Col { nodes = { folder_tab } },
            T.Col { align = "lc", nodes = { label_node } },
          }
        },
        T.Col { nodes = {
          T.Row { nodes = {
            create_toggle({
              label = '',
              ref_table = self,
              ref_value = 'should_enable_all',
              col = true, hide_label = true,
              w = 0, h = 0.2, scale = 1,
              callback = (function(_set_toggle)
                -- THIS IS WHAT WILL MASS ENABLE/DISABLE MODS IN FOLDER
                if next(self.items) then
 
                end
              end)
            })
          }}
        }}
      }
    }
  }}
end

function Troubadour.Folder:get_label()
  local _, _, text_colour = Troubadour.ICONS.get_mod_popup_colours({ can_load = true })
  return T.Row {
    nodes = {{
      n = G.UIT.O,
      config = {
        object = SMODS.UIScrollBox({
          content = DynaText({
            string = self.name,
            colours = { text_colour or G.C.UI.TEXT_LIGHT },
            shadow = true,
            scale = 0.375,
          }),
          container = { config = { can_collide = false } },
          overflow = {
            node_config = { no_overflow = "h", w = 3 },
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
    }}
  }
end

function Troubadour.Folder:handle_errors(name)
  if not name or name == '' then
    sendWarnMessage(('No name entered, not creating folder'))
    return true
  elseif Troubadour.Folders[name] then
    sendWarnMessage(('Detected duplicate folder name, not creating folder'))
    return true
  end
end