local m = assert(SMODS.load_file("src/functions/modpage_helper.lua"))()
local Tile = assert(SMODS.load_file("src/settings/tile.lua"))()
local Row, Col = TRO.UI.create_row, TRO.UI.create_column
local Text, TextCol = TRO.UI.create_text_node, m.createTextColNode

-- CONTROL SCHEME FUNCTIONS

function G.FUNCS.TRO_open_mod(e)
  play_sound('button', 1, 0.3)
  G.ROOM.jiggle = G.ROOM.jiggle + 0.5
  G.FUNCS["openModUI_" .. e.config.ref_table.id](e)
end

tro_input_manager:add_listener({ 'right_click', 'right_stick', 'x' }, function(target)
  if tro_config.invert_tile_controls then
    if target and target.TRO_mods_sprite then
      G.FUNCS.TRO_open_mod(target.parent.parent.parent)
    elseif target.config.TRO_mods_tile then
      G.FUNCS.TRO_open_mod(target)
    end
  else
    if target and target.TRO_mods_sprite then
      G.FUNCS.TRO_toggle_tile(target.parent.parent.parent)
    elseif target.config.TRO_mods_tile then
      G.FUNCS.TRO_toggle_tile(target)
    end
  end
end)

function G.FUNCS.TRO_check_tile_ctrls(e)
  if tro_config.invert_tile_controls then
    if (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then G.FUNCS.TRO_open_mod(e)
    else G.FUNCS.TRO_toggle_tile(e) end
  else
    if (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then G.FUNCS.TRO_toggle_tile(e)
    else G.FUNCS.TRO_open_mod(e) end
  end
end

function TRO.ICONS.get_controls(nodes, args)
  local ctrls = {}
  local ctrls_key = 'TRO_modControls_tooltip' .. (tro_config.invert_tile_controls and '_i' or '')
  localize{type = 'descriptions', set = 'Other', key = ctrls_key, nodes = ctrls, text_colour = args.colour}
  for _, v in ipairs(ctrls) do
    table.insert(nodes, { n = G.UIT.R, config = {}, nodes = v })
  end
end