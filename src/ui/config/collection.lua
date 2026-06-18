local T = Troubadour.UI

-- LIST OF COLLECTION PAGES TO WIDEN
local pages = {
  {
    label = "Joker",
    ref_value_w = "gallery_width_j", minw = 5, maxw = 11,
    ref_value_h = "gallery_height_j", minh = 3, maxh = 5,
  },
  {
    label = "Voucher",
    ref_value_w = "gallery_width_v", minw = 2, maxw = 5,
    ref_value_h = "gallery_height_v", minh = 2, maxh = 4,
  },
  {
    label = "Consumable",
    ref_value_w = "gallery_width_c", minw = 6, maxw = 10,
    ref_value_h = "gallery_height_c", minh = 2, maxh = 4,
  },
  {
    label = "Enhancement",
    ref_value_w = "gallery_width_e", minw = 4, maxw = 8,
    ref_value_h = "gallery_height_e", minh = 2, maxh = 4,
  },
  {
    label = "Booster",
    ref_value_w = "gallery_width_b", minw = 4, maxw = 8,
    ref_value_h = "gallery_height_b", minh = 2, maxh = 5,
  },
}

local function is_chosen(tab)
  return Troubadour.LAST_OPEN_TAB == tab
end

local function choose_tab(tab)
  Troubadour.LAST_OPEN_TAB = tab
end

function Troubadour.UIDEF.collection_tab()
  local vertical_tabs = {}
  choose_tab "Jokers"

  Troubadour.utils.for_each(pages, function(page)
    table.insert(vertical_tabs, {
      label = page.label..'s',
      chosen = is_chosen(page.label..'s'),
      tab_definition_function = function (...)
        return T.Root { r = 0.1, nodes = {
          T.Col { nodes = {
            T.Row { minh = math.max(1, #pages), nodes = {
              T.Col { padding = 0.1, r = 0.2, minh = math.max(1, #pages * 2 / 3), outline = 1,
                  colour = T.C.colour, outline_colour = T.C.outline_colour, emboss = 0.05, nodes = {
                T.Row { nodes = {
                  T.Col { r = 0.1, colour = G.C.GREY, emboss = 0.05, nodes = {
                    create_slider({ label = page.label..' Page Width', label_scale = 0.45, w = 4, h = 0.3, colour = T.C.active,
                      ref_table = Troubadour.config, ref_value = page.ref_value_w or ('gallery_width'..page.label:lower()), min = page.minw, max = page.maxw }),
                    create_slider({ label = page.label..' Page Height', label_scale = 0.45, w = 4, h = 0.3, colour = T.C.active,
                      ref_table = Troubadour.config, ref_value = page.ref_value_h or ('gallery_height'..page.label:lower()), min = page.minh, max = page.maxh }),
                  }}
                }}
              }}
            }}
          }}
        }}
      end
    })
  end)

  return T.UIBox({
    minw = 0.0, padding = 0.2, emboss = 0.05, bg_colour = G.C.BLACK,
    contents = {
      T.Row { padding = 0.1, r = 0.1, outline = 1, outline_colour = T.C.outline_colour,
        nodes = { T.Text{ align = "tm", text = "Widen Collections", scale = 0.7 } } },
      T.Row { padding = 0, align = "tl",
        nodes = {
          Troubadour.UI.create_column_tabs({
            tab_alignment = 'tl',
            text_scale = 0.4,
            snap_to_nav = true,
            colour =  G.C.CLEAR,
            tabs = vertical_tabs
          })
        }
      },
    }
  })
end