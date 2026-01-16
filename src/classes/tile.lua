local Tile = Object:extend()

local tile_colour_enabled = mix_colours(G.C.UI.TEXT_DARK, {0.7,0.8,0.9,1}, 0.8)
local tile_colour_disabled = mix_colours(G.C.UI.BACKGROUND_INACTIVE, { 0, 0, 0, 1 }, 0.6)

local backdrop_colour_enabled = mix_colours({ 0.5, 0.5, 0.5, 0.2 }, tile_colour_enabled, 0.5)
local backdrop_colour_disabled = mix_colours({ 0.5, 0.5, 0.5, 0.2 }, tile_colour_disabled, 0.5)

local outline_colour_enabled = mix_colours(tile_colour_enabled, G.C.BLACK, 0.5)
local outline_colour_disabled = mix_colours(tile_colour_disabled, G.C.BLACK, 0.5)


function G.FUNCS.TRO_toggle_tile(e)
  e.config.ref_table[e.config.ref_value] = not e.config.ref_table[e.config.ref_value]

  if e.config.callback then
    e.config.callback(e.config.ref_table[e.config.ref_value])
  end

  local enabled = e.config.ref_table[e.config.ref_value]
  -- backdrop colour
  e.config.colour = enabled and backdrop_colour_enabled or backdrop_colour_disabled
  -- outline colour
  e.config.outline_colour = e.config.outline and (enabled and outline_colour_enabled or outline_colour_disabled)
  -- change tile colour
  e.children[1].config.colour = enabled and tile_colour_enabled or tile_colour_disabled
end

function Tile:init(args)
  self.label = args.label or ''
  self.ref_value = args.ref_value
  self.ref_table = args.ref_table
  self.button_func = args.button_func
  self.callback = args.callback

  self.detailed_tooltip = args.tooltip
  self.object = args.object
  self.object_args = args.object_args
  self.focus_args = args.focus_args

  self.no_outline = args.no_outline
  self.hover = args.hover
  self.TRO_mods_tile = args.TRO_mods_tile

  self.click_timeout = 0.3
end

function Tile:render()
  local enabled = self.ref_table[self.ref_value]
  if self.condition == false then enabled = false end

  return {
    n = G.UIT.C,
    config = {
      r = 0.1,
      padding = 0.05,
      emboss = 0.05,
      colour = enabled and backdrop_colour_enabled or backdrop_colour_disabled,
      outline = not self.no_outline and 1,
      outline_colour = not self.no_outline and (enabled and outline_colour_enabled or outline_colour_disabled),
      button = self.button_func or "TRO_toggle_tile",
      ref_table = self.ref_table,
      ref_value = self.ref_value,
      callback = self.callback,
      detailed_tooltip = self.detailed_tooltip,
      hover = self.hover,
      TRO_mods_tile = self.TRO_mods_tile,
      focus_args = self.focus_args
    },
    nodes = {
      {
        n = G.UIT.R,
        config = {
          align = "cm",
          r = 0.1,
          padding = 0.1,
          emboss = 0.02,
          colour = enabled and tile_colour_enabled or tile_colour_disabled,
        },
        nodes = {
          {
            n = G.UIT.O,
            config = {
              object = self.object,
              w = self.object_args.w,
              h = self.object_args.h,
              colour = self.object_args.colour,
              focus_with_object = true,
              focus_args = self.focus_args and {funnel_to = true},
            }
          },
        }
      }
    }
  }
end

return Tile
