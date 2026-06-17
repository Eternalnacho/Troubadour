local m = assert(SMODS.load_file("src/mods_page/helper.lua"))()
local T = Troubadour.UI

-- SMALLER MODLIST
function Troubadour.UIDEF.statModList()
  local scale = 0.75
  local currentPage, pageOptions, showingList, _, _, dminh, dminw = m.recalculateModsList()

  return T.Row { minh = 1.5 * dminh + 1, minw = 1.5 * dminw + 1, r = 0.1, padding = 0.05, colour = G.C.BLACK, nodes = {
    -- row container
    T.Col { nodes = {
      -- column container
      T.Col { minw = 5, r = 0.1, colour = G.C.CLEAR, nodes = {
        -- title row
        T.Row { nodes = {
          T.Col { nodes = {
            UIBox_button({
              label = { localize('b_mod_list') },
              shadow = true,
              scale = scale * 0.85,
              colour = G.C.BOOSTER,
              button = "openModsDirectory",
              minh = scale,
              minw = 4.5
            }),
          }},
          T.Col { nodes = {
            Troubadour.UIDEF.modlist_header_icon('tro_list', {x = 0, y = 0}, 'Troubadour_modlist_button', 'TRO_mod_list')
          }},
          T.Col { nodes = {
            Troubadour.UIDEF.modlist_header_icon('tro_folder', {x = 0, y = 0}, 'Troubadour_mod_folder_button', 'TRO_mod_folder_page')
          }},
          T.Col { nodes = {
            Troubadour.UIDEF.modlist_header_icon('mod_tags', {x = 2, y = 0}, 'Troubadour_modlist_config', 'TRO_mod_page_config')
          }},
        }},
        -- add some empty rows for spacing
        T.Row { padding = 0.05 },
        T.Row { padding = 0.05 },
        -- dynamic content rendered in this row container
        -- list of 4 x 4 mods on the current page
        T.Row { padding = 0.05, minh = dminh + 1, minw = dminw + 1,
          nodes = {
            { n = G.UIT.O, config = { align = "cm", id = 'modsList', object = Moveable() } },
          }
        },
        -- another empty row for spacing
        T.Row { padding = 0.8 },
        -- page selector
        -- does not appear when list of mods is empty
        showingList and SMODS.GUI.createOptionSelector({
          label = "",
          scale = 0.8,
          options = pageOptions,
          opt_callback = 'update_mod_list',
          no_pips = true,
          current_option = ( currentPage )
        })
      }}
    }}
  }}
end

function Troubadour.UIDEF.dynaModList(page)
  local scale = 0.75
  local _, __, showingList, startIndex, endIndex, modsRowPerPage, modsColPerRow = m.recalculateModsList(page)

  local modNodes = {}
  -- If no mods are loaded, show a default message
  if showingList == false then
    table.insert(modNodes, T.Row { padding = 0, nodes = {
        T.Text { text = localize('b_no_mods'), shadow = true, scale = scale * 0.5, colour = G.C.UI.TEXT_DARK }
      }})
  else
    local modCount = 0
    local id = 0
    local current_row = {}

    for _, condition in ipairs({
      function(mod) return not mod.can_load and not mod.disabled end,
      function(mod) return mod.can_load and mod.config_tab end,
      function(mod) return mod.can_load and not mod.config_tab end,
      function(mod) return mod.disabled end,
    }) do
      for _, modInfo in ipairs(SMODS.mod_list) do
        if modCount >= modsRowPerPage * modsColPerRow then break end
        if condition(modInfo) then
          id = id + 1
          if id >= startIndex and id <= endIndex then
            table.insert(current_row, Troubadour.ICONS.buildModTile(modInfo))
            modCount = modCount + 1
            if math.fmod(modCount, modsColPerRow) == 0 then
              table.insert(modNodes, T.Row { padding = 0, align = "lc", nodes = current_row })
              current_row = {}
            end
          end
        end
      end
    end
    if #current_row > 0 then
      table.insert(modNodes, T.Row { padding = 0, align = "lc", nodes = current_row })
    end
  end

  return T.Col { nodes = {
    T.Row { nodes = {
      T.Col { r = 0.1, padding = 0, minw = 1.4 * modsColPerRow, nodes = modNodes },
    } } } }
end

function Troubadour.UIDEF.modlist_header_icon(atlas, pos, button_func, tooltip_key)
  local tag_sprite = SMODS.create_sprite(0, 0, 0.5, 0.5, atlas, pos)
  local tile_enabled = { is = false } -- I like the darker tile look better for this
  local tile = Troubadour.Tile({
    ref_table = tile_enabled, ref_value = 'is',
    object = tag_sprite, object_args = {w = SMODS.pixels_to_unit(34), h = SMODS.pixels_to_unit(34), colour = G.C.BLUE},
    TRO_mod_tile = true,
    TRO_dark_tooltip = tooltip_key,
    no_outline = true,
    colour_override = {colour = T.C.outline_colour},
    button_func = button_func,
    shadow = true, shadow_height = 0.25, hovering = true,
  })
  return T.Col { padding = 0.1, nodes = {tile:render()} }
end