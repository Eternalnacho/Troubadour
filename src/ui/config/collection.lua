local T = Troubadour.UI

--

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

-- I am VERY BLATANTLY ripping this straight from Cartomancer
function T.create_column_tabs(args)
  args = args or {}
  args.colour = args.colour or G.C.CLEAR
  args.tab_alignment = args.tab_alignment or 'cl'
  args.opt_callback = args.opt_callback or nil
  args.scale = args.scale or 1
  args.tab_w = args.tab_w or 0
  args.tab_h = args.tab_h or 0
  args.text_scale = (args.text_scale or 0.5)

  local tab_buttons = {}

  for k, v in ipairs(args.tabs) do
    if v.chosen then args.current = {k = k, v = v} end
    local id = 'tab_but_'..(v.label or '')
    tab_buttons[#tab_buttons+1] = { n = G.UIT.R, config = { align = "tm" }, nodes={
      UIBox_button({
        id = id,
        ref_table = v,
        button = 'TRO_settings_change_tab',
        func = v.func,
        label = {v.label},
        scale = args.text_scale,
        colour = darken(Troubadour.UI.mod_colours.buttons, 0.2),
        minh = 0.8 * args.scale,
        minw = 2.5 * args.scale,
        col = true,
        choice = true, 
        chosen = v.chosen and 'vert', 
        focus_args = { snap_to = args.snap_to_nav, nav = 'wide' },
      })
    }}
  end

  -- Tabs + Contents
  local tab_def = args.current.v.tab_definition_function
  local tab_args = args.current.v.tab_definition_function_args
  return T.Row (
    { padding = 0.0, align = "cl", colour = args.colour },
    {
      -- Tabs
      T.Col(
        {
          align = "cl",
          padding = 0.15,
          focus_args = { button = 'x', type = 'none' }
        },
        tab_buttons
      ),
      -- Tab contents
      T.Col(
        {
          align = args.tab_alignment,
          padding = args.padding or 0.1,
          no_fill = true,
          minh = args.tab_h,
          minw = args.tab_w
        },
        {
          {
            n = G.UIT.O,
            config = {
              id = 'TRO_settings_tab_contents',
              old_chosen = tab_buttons[1].nodes[1].nodes[1],
              object = UIBox{
                definition = tab_def(tab_args),
                config = { offset = { x = 0, y = 0 } }
              }
            }
          }
        }
      ),
    }
  )
end

function Troubadour.UIDEF.collection_tab()
  local vertical_tabs = {}
  choose_tab "Jokers"

  Troubadour.utils.for_each(pages, function(page)
    table.insert(vertical_tabs, {
      label = page.label..'s',
      chosen = is_chosen(page.label..'s'),
      tab_definition_function = function (...)
        return T.Root ({ r = 0.1}, -- Config
        { -- Contents
          T.Col ({}, -- Row container
          {
            T.Row ({ minh = math.max(1, #pages) },
            {
              T.Col (
                { -- Config
                  padding = 0.1,
                  r = 0.2,
                  minh = math.max(1, #pages * 2 / 3),
                  outline = 1,
                  colour = T.C.colour,
                  outline_colour = T.C.outline_colour,
                  emboss = 0.05
                },
                { -- Contents
                  T.Row ({}, -- Column Container
                  {
                    T.Col ({ r = 0.1, colour = G.C.GREY, emboss = 0.05 },
                    { -- Sliders for page width and height
                      create_slider({
                        label = page.label..' Page Width',
                        label_scale = 0.45,
                        w = 4, h = 0.3,
                        colour = T.C.active,
                        ref_table = Troubadour.config,
                        ref_value = page.ref_value_w or ('gallery_width'..page.label:lower()),
                        min = page.minw, max = page.maxw
                      }),
                      create_slider({
                        label = page.label..' Page Height',
                        label_scale = 0.45,
                        w = 4, h = 0.3,
                        colour = T.C.active,
                        ref_table = Troubadour.config,
                        ref_value = page.ref_value_h or ('gallery_height'..page.label:lower()),
                        min = page.minh, max = page.maxh
                      }),
                    })
                  })
                }
              )
            })
          })
        })
      end
    })
  end)

  return T.UIBox (
    { minw = 0.0, padding = 0.2, emboss = 0.05, bg_colour = G.C.BLACK },
    {
      T.Row (
        { padding = 0.1, r = 0.1, outline = 1, outline_colour = T.C.outline_colour },
        { T.Text ({ align = "tm", text = "Widen Collections", scale = 0.7 }) }
      ),
      T.Row (
        { padding = 0, align = "tl" },
        {
          T.create_column_tabs({
            tab_alignment = 'tl',
            text_scale = 0.4,
            snap_to_nav = true,
            colour =  G.C.CLEAR,
            tabs = vertical_tabs
          })
        }
      ),
    }
  )
end