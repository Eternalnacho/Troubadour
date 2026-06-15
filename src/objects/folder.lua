local Row, Col = Troubadour.UI.create_row, Troubadour.UI.create_column
local troC = Troubadour.UI.mod_colours

-- FOLDER OBJECT
Troubadour.Folders = {}
Troubadour.Folder = Object:extend()

function Troubadour.Folder:init(args)
  self.name = args.name or ''
  self.should_enable_all = true
  self.items = {}

  table.insert(Troubadour.Folders, self)
  G.FUNCS["Troubadour_open_folder_"..self.name] = function() self:open() end
end

function Troubadour.Folder:add_item() end

function Troubadour.Folder:remove_item() end

function Troubadour.Folder:save() end

function Troubadour.Folder:render()
  local colour, bg_colour, text_colour = Troubadour.ICONS.get_mod_popup_colours({ can_load = true })

  local folder_icon = SMODS.create_sprite(0, 0, 0.5, 0.5, 'tro_folder', {x = 0, y = 0})
  local folder_tab = Col { padding = 0.1, r = 0.1, colour = troC.colour, outline = 1, outline_colour = bg_colour, nodes = {
    { n = G.UIT.O, config = { w = SMODS.pixels_to_unit(34), h = SMODS.pixels_to_unit(34), colour = G.C.BLUE, object = folder_icon, focus_with_object = true } },
  } }

  local label_node = Row {
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
          scroll_move = function(self, dt)
            self.real_progress = ((self.real_progress or 0) + G.real_dt / 8) % 1
            if self.real_progress < 0.25 then
              self.scroll_progress.x = 0
            elseif self.real_progress > 0.75 then
              self.scroll_progress.x = 1
            else
              self.scroll_progress.x = (self.real_progress - 0.25) / 0.5
            end
          end,
        })
      }
    }}
  }

  return Col { nodes = {
    Col {
      colour = bg_colour, emboss = 0.05, r = 0.1, minw = 1.5, minh = 1, shadow = true, shadow_height = 0.25, hover = true,
      nodes = {
        Col {
          padding = 0.1, align = "lc", minw = 4.5, minh = 1, maxh = 1.4, emboss = 0.05, r = 0.1,
          colour = colour,
          button = "Troubadour_open_folder_" .. self.name,
          nodes = {
            Col { nodes = { folder_tab } },
            Col { align = "lc", nodes = { label_node } },
          }
        },
        Col { nodes = {
          Row { nodes = {
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

function Troubadour.Folder:open()
  -- Something something overlay menu
end

function Troubadour.Folder:close()
  -- Something something overlay menu back func
end