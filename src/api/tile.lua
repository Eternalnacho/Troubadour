---@diagnostic disable: undefined-field
local T = Troubadour.UI

T.C.Tile = {
  enabled = mix_colours(G.C.UI.TEXT_DARK, {0.7,0.8,0.9,1}, 0.8),
  disabled = mix_colours(G.C.UI.BACKGROUND_INACTIVE, { 0, 0, 0, 1 }, 0.6),
}

T.C.Tile.backdrop_enabled = mix_colours({ 0.5, 0.5, 0.5, 0.2 }, T.C.Tile.enabled, 0.5)
T.C.Tile.backdrop_disabled = mix_colours({ 0.5, 0.5, 0.5, 0.2 }, T.C.Tile.disabled, 0.5)

T.C.Tile.outline_enabled = mix_colours(T.C.Tile.enabled, G.C.BLACK, 0.5)
T.C.Tile.outline_disabled = mix_colours(T.C.Tile.disabled, G.C.BLACK, 0.5)

local tile_colour = T.C.Tile


-- TILE OBJECT
Troubadour.Tile = Object:extend()

function G.FUNCS.TRO_toggle_tile(e)
  e.config.ref_table[e.config.ref_value] = not e.config.ref_table[e.config.ref_value]
  local enabled = e.config.ref_table[e.config.ref_value]
  if e.config.callback then e.config.callback(enabled) end

  e.config.colour = enabled and tile_colour.backdrop_enabled or tile_colour.backdrop_disabled
  e.config.outline_colour = e.config.outline and (enabled and tile_colour.outline_enabled or tile_colour.outline_disabled)

  -- change tile colour
  e.children[1].config.colour = enabled and tile_colour.enabled or tile_colour.disabled
end

function Troubadour.Tile:init(args)
  self.ref_table = args.ref_table
  self.ref_value = args.ref_value
  self.button_func = args.button_func
  self.callback = args.callback

  self.detailed_tooltip = args.tooltip
  self.TRO_dark_tooltip = args.TRO_dark_tooltip

  self.object = args.object
  self.object_args = args.object_args

  self.no_outline = args.no_outline
  self.shadow = args.shadow
  self.shadow_height = args.shadow_height
  self.hovering = args.hovering

  self.click_timeout = 0.3
end

function Troubadour.Tile:render()
  local enabled = self.ref_table[self.ref_value]
  local tile_node = {
    n = G.UIT.C,
    config = {
      r = 0.1,
      padding = 0.05,
      emboss = 0.05,
      colour = enabled and tile_colour.backdrop_enabled or tile_colour.backdrop_disabled,
      outline = not self.no_outline and 1,
      outline_colour = not self.no_outline and (enabled and tile_colour.outline_enabled or tile_colour.outline_disabled),
      button = self.button_func or "TRO_toggle_tile",
      ref_table = self.ref_table,
      ref_value = self.ref_value,
      callback = self.callback,
      TRO_dark_tooltip = self.TRO_dark_tooltip,
      detailed_tooltip = self.detailed_tooltip,
      shadow = self.shadow,
      shadow_height = self.shadow_height,
      hover = self.hovering,
    }
  }

  if self.colour_override then for k, _ in pairs(self.colour_override) do
    tile_node.config[k] = self.colour_override[k] end
  end

  tile_node.nodes = {
    {
      n = G.UIT.R,
      config = {
        align = "cm",
        r = 0.1,
        padding = 0.1,
        emboss = 0.02,
        colour = enabled and tile_colour.enabled or tile_colour.disabled,
        minw = self.minw,
        minh = self.minh,
      },
      nodes = {
        self.object and {
          n = G.UIT.O,
          config = {
            object = self.object,
            w = self.object_args.w,
            h = self.object_args.h,
            colour = self.object_args.colour,
            focus_with_object = true,
          }
        },
      }
    }
  }
  return tile_node
end
