-- SMALLER MODLIST
local m = assert(SMODS.load_file("src/functions/modpage_helper.lua"))()
local Tile = assert(SMODS.load_file("src/settings/tile.lua"))()
local Row, Col = TRO.UI.create_row, TRO.UI.create_column
local Text, TextCol = TRO.UI.create_text_node, m.createTextColNode

local statModList_ref = SMODS.GUI.staticModListContent
SMODS.GUI.staticModListContent = function()
  if tro_config.mod_icons_only then
    return TRO.UIDEF.statModList()
  else
    return statModList_ref()
  end
end

local dynaModList_ref = SMODS.GUI.dynamicModListContent
SMODS.GUI.dynamicModListContent = function(page, ...)
  if tro_config.mod_icons_only then
    return TRO.UIDEF.dynaModList(page)
  else
    return dynaModList_ref(page, ...)
  end
end

function TRO.UIDEF.statModList()
  local scale = 0.75
  local currentPage, pageOptions, showingList, _, _, dminh, dminw = m.recalculateModsList()
  return Row { minh = 1.5 * dminh + 1, minw = 1.5 * dminw + 1, r = 0.1, padding = 0.05, colour = G.C.BLACK, nodes = {
    -- row container
    Col { padding = 0.05, nodes = {
      -- column container
      Col { minw = 5, padding = 0.05, r = 0.1, colour = G.C.CLEAR, nodes = {
        -- title row
        Row { padding = 0.05, nodes = {
          UIBox_button({
            label = { localize('b_mod_list') },
            shadow = true,
            scale = scale * 0.85,
            colour = G.C.BOOSTER,
            button = "openModsDirectory",
            minh = scale,
            minw = 9
          }),
        }},
        -- add some empty rows for spacing
        Row { padding = 0.05 },
        Row { padding = 0.05 },
        Row { padding = 0.05 },
        Row { padding = 0.05 },
        -- dynamic content rendered in this row container
        -- list of 4 x 4 mods on the current page
        Row { padding = 0.05, minh = dminh + 1, minw = dminw + 1,
          nodes = {
            { n = G.UIT.O, config = { align = "cm", id = 'modsList', object = Moveable() } },
          }
        },
        -- another empty row for spacing
        Row { padding = 0.8 },
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

function TRO.UIDEF.dynaModList(page)
  local scale = 0.75
  local _, __, showingList, startIndex, endIndex, modsRowPerPage, modsColPerRow = m.recalculateModsList(page)

  local modNodes = {}
  -- If no mods are loaded, show a default message
  if showingList == false then
    table.insert(modNodes, Row { padding = 0, nodes = {
        Text { text = localize('b_no_mods'), shadow = true, scale = scale * 0.5, colour = G.C.UI.TEXT_DARK }
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
            table.insert(current_row, TRO.ICONS.createModBoxTile(modInfo))
            modCount = modCount + 1
            if math.fmod(modCount, modsColPerRow) == 0 then
              table.insert(modNodes, Row { padding = 0, align = "lc", nodes = current_row })
              current_row = {}
            end
          end
        end
      end
    end
    if #current_row > 0 then
      table.insert(modNodes, Row { padding = 0, align = "lc", nodes = current_row })
    end
  end

  return Col { r = 0.1, padding = 0, minw = 1.4 * modsColPerRow, nodes = modNodes }
end

function TRO.ICONS.getModtagInfo(mod)
  local tag_pos = { x = 0, y = 0 }
  local tag_atlas = mod.prefix and mod.prefix .. '_modicon' or 'modicon'

  if not mod.can_load then
    tag_atlas = "mod_tags"
    if mod.disabled then
      tag_pos = { x = 1, y = 0 }
    end
  end
  return tag_atlas, tag_pos
end

function TRO.ICONS.buildModtag(mod)
  local tag_atlas, tag_pos = TRO.ICONS.getModtagInfo(mod)
  local tag_sprite = SMODS.create_sprite(0, 0, 0.8 * 1, 0.8 * 1, SMODS.get_atlas(tag_atlas) or SMODS.get_atlas('tags'), tag_pos)
  tag_sprite.T.scale = 1
  tag_sprite:define_draw_steps({
    { shader = 'dissolve', shadow_height = 0.05 },
    { shader = 'dissolve' },
  })
  tag_sprite.float = true
  tag_sprite.states.hover.can = true
  tag_sprite.states.click.can = true
  tag_sprite.states.drag.can = false
  tag_sprite.states.collide.can = true
  tag_sprite.TRO_mods_sprite = true

  tag_sprite.hover = function(_self)
    if not G.CONTROLLER.dragging.target or G.CONTROLLER.using_touch then
      if not _self.hovering and _self.states.visible then
        _self.hovering = true
        if _self == tag_sprite then
          _self.hover_tilt = 3
          _self:juice_up(0.05, 0.02)
          play_sound('paper1', math.random() * 0.1 + 0.55, 0.42)
          play_sound('tarot2', math.random() * 0.1 + 0.55, 0.09)
        end
        _self.config.h_popup = TRO.UIDEF.mod_icon_popup(mod, 0.75)
        _self.config.h_popup_config = { align = 'tm', offset = { x = 0, y = -0.3 }, parent = _self }
        Node.hover(_self)
        if _self.children.alert then
          _self.children.alert:remove()
          _self.children.alert = nil
          G:save_progress()
        end
      end
    end
  end
  tag_sprite.click = function(self)
    if tro_config.invert_tile_controls then
      if (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then G.FUNCS.TRO_open_mod(self.parent.parent.parent)
      else self.parent.parent.parent:click() end
    else
      if (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then self.parent.parent.parent:click()
      else G.FUNCS.TRO_open_mod(self.parent.parent.parent) end
    end
  end
  tag_sprite.stop_hover = function(_self)
    _self.hovering = false; Node.stop_hover(_self); _self.hover_tilt = 0
  end

  tag_sprite:juice_up()
  return tag_sprite
end

function TRO.ICONS.createModBoxTile(modInfo)
  local units, mod_tile
  if modInfo.should_enable == nil then
    modInfo.should_enable = not modInfo.disabled
  end
  if SMODS.full_restart == nil then
    SMODS.full_restart = 0
  end

  units = SMODS.pixels_to_unit(34) * 2
  mod_tile = Tile({
    ref_table = modInfo,
    ref_value = 'should_enable',
    object = TRO.ICONS.buildModtag(modInfo),
    object_args = {w = units, h = units, colour = G.C.BLUE},
    hover = true,
    TRO_mods_tile = true,
    no_outline = true,
    button_func = 'TRO_check_tile_ctrls',
    focus_args = {funnel_from = true},
    callback = function(_set_toggle)
      if not modInfo.should_enable then
        NFS.write(modInfo.path .. '.lovelyignore', '')
      else
        NFS.remove(modInfo.path .. '.lovelyignore')
      end
      local toChange = 1
      if modInfo.should_enable == not modInfo.disabled then
        toChange = -1
      end
      SMODS.full_restart = SMODS.full_restart + toChange
    end,
  })

  return Col { padding = 0.05, nodes = { Col { padding = 0.0, minw = 1, minh = 1, nodes = { mod_tile:render() } } } }
end

function G.FUNCS.TRO_check_tile_ctrls(e)
  if tro_config.invert_tile_controls then
    if (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then G.FUNCS.TRO_open_mod(e)
    else G.FUNCS.TRO_toggle_tile(e) end
  else
    if (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then G.FUNCS.TRO_toggle_tile(e)
    else G.FUNCS.TRO_open_mod(e) end
  end
end

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

-- MOD-ICON MODS PAGE UIDEFS
function TRO.UIDEF.mod_icon_popup(mod, scale)
  local col, bg_col, text_col = TRO.ICONS.get_mod_popup_colours(mod)
  local version_col = copy_table(G.C.WHITE); version_col[4] = 0.6
  local the_colour = mix_colours(G.C.BLACK, G.C.WHITE, 0.2); the_colour[4] = 0.8
  local label_nodes = {}
  -- Get Mod Name Node
  TRO.ICONS.get_modName_node(mod, label_nodes, {scale = scale * 0.65, colour = text_col})
  -- Get "Lovely Only" Node
  TRO.ICONS.get_lovely_node(mod, label_nodes, {scale = scale * 0.6, colour = version_col})
  -- Get Version Node
  TRO.ICONS.get_version_node(mod, label_nodes, {scale = scale * 0.6, colour = version_col})
  -- Get Author DynaText Node
  TRO.ICONS.get_authorDyna_node(mod, label_nodes, {scale = scale * 0.4, colour = the_colour})
  -- Priority Node ???
  TRO.ICONS.get_priority_node(mod, label_nodes, {scale = scale * 0.5, colour = version_col})
  -- Get Load State Node
  TRO.ICONS.get_loadState_nodes(mod, label_nodes, {scale = scale * 0.4, colour = version_col})

  -- Controls at bottom of UIBox
  TRO.ICONS.get_controls(label_nodes, {scale = scale * 0.3, colour = version_col})

  return Col { r = 0.2, padding = 0.1, emboss = 0.1, colour = bg_col,
    outline = 1, outline_colour = mix_colours(col, G.C.WHITE, 0.7),
    nodes = {
      Row { r = 0.2, padding = 0.05, emboss = 0.05, colour = col, nodes = {
        Col { r = 0.2, padding = 0.05, nodes = label_nodes }
      }}
    }}
end

function TRO.ICONS.get_mod_popup_colours(mod)
  local col, bg_col, text_col
  if mod.can_load then
    col = mix_colours(G.C.UI.BACKGROUND_INACTIVE, {0, 0.1, 0.2, 1}, 0.8)
    text_col = mix_colours(G.C.GREEN, G.C.WHITE, 0.9)
  elseif mod.disabled then
    col = mix_colours(G.C.UI.BACKGROUND_INACTIVE, {0, 0, 0, 1}, 0.6)
    text_col = mix_colours(G.C.FILTER, G.C.JOKER_GREY, 0.6)
  else
    col = mix_colours(G.C.RED, G.C.BLACK, 0.5)
    text_col = G.C.TEXT_DARK
  end
  bg_col = mix_colours({0.5, 0.5, 0.5, 1}, col, 0.5)
  return col, bg_col, text_col
end

function TRO.ICONS.get_modName_node(mod, nodes, args)
  local modname_split = SMODS.smart_line_splitter(mod.name, 18, true)
  for _,v in ipairs(modname_split) do
    table.insert(nodes, TextCol(v, args.scale, args.colour))
  end
end

function TRO.ICONS.get_lovely_node(mod, nodes, args)
  if mod.lovely_only then
    table.insert(nodes, TextCol(localize('b_lovely_mod'), args.scale, args.colour))
  end
end

function TRO.ICONS.get_version_node(mod, nodes, args)
  local sub_node = {}
  if mod.version and mod.version ~= '0.0.0' then
    table.insert(sub_node, TextCol(('%s'):format(mod.version), args.scale, args.colour, G.UIT.C))
  end
  if #sub_node > 0 then table.insert(nodes, { n = G.UIT.R, config = {}, nodes = sub_node }) end
end

function TRO.ICONS.get_authorDyna_node(mod, nodes, args)
  if not mod.lovely_only then
    local tx = m.concatAuthors(mod.author)
    local authorDynatext = DynaText{
        string = tx,
        scale = args.scale,
        colours = {args.colour},
        shadow = true,
        maxw = 2.4,
        marquee = true,
    }
    table.insert(nodes,
      Row { padding = 0, align = "lc", maxw = 4.5, maxh = 1.5, nodes =
          {
            { n = G.UIT.T, config = { text= localize('b_by'), scale = args.scale, colour = args.colour } },
            { n = G.UIT.O, config = {object = authorDynatext} }
          }
      })
  end
end

function TRO.ICONS.get_priority_node(mod, nodes, args)
  local sub_node = {}
  if not _RELEASE_MODE and mod.priority then
    table.insert(nodes, TextCol(('%s%s'):format(localize('b_priority'), number_format(mod.priority)), args.scale, args.colour))
  end
  if #sub_node > 0 then table.insert(nodes, { n = G.UIT.R, config = {}, nodes = sub_node }) end
end

function TRO.ICONS.get_loadState_nodes(mod, nodes, args)
  local sub_node = {}
  local tag_state = 'load_success'
  local specific_vars = {}

  if not mod.can_load then
    tag_state = 'load_failure'
    if next(mod.load_issues.dependencies) then
      tag_state = tag_state .. '_d'
      table.insert(specific_vars, m.concatAuthors(mod.load_issues.dependencies))
    end
    if next(mod.load_issues.conflicts) then
      tag_state = tag_state .. '_c'
      table.insert(specific_vars, m.concatAuthors(mod.load_issues.conflicts))
    end
    if mod.load_issues.outdated then
      tag_state = 'load_failure_o'
    end
    if mod.load_issues.version_mismatch then
      tag_state = 'load_failure_i'
      specific_vars = { mod.load_issues.version_mismatch, MODDED_VERSION:gsub('-STEAMODDED', '') }
    end
    if mod.load_issues.main_file_not_found then
      tag_state = 'load_failure_m'
      specific_vars = { mod.main_file }
    end
    if mod.load_issues.prefix_conflict then
      tag_state = 'load_failure_p'
      local name = mod.load_issues.prefix_conflict
      for _, o_mod in ipairs(SMODS.mod_list) do
        if o_mod.id == o_mod.load_issues.prefix_conflict then
          name = o_mod.name or name
        end
      end
      specific_vars = { name }
    end
    if mod.disabled then
      tag_state = 'load_disabled'
    end
  end

  local state_nodes = {}
  localize{type = 'descriptions', set = 'Other', key = tag_state, nodes = state_nodes, vars = specific_vars, text_colour = args.colour}

  for i, v in ipairs(state_nodes) do
    for _, vv in ipairs(v) do
      table.insert(sub_node, vv)
    end
    if i < #state_nodes then table.insert(sub_node, Text{ text = ' ', scale = args.scale }) end
  end
  if #sub_node > 0 then table.insert(nodes, { n = G.UIT.R, config = {}, nodes = sub_node }) end
end

function TRO.ICONS.get_controls(nodes, args)
  local ctrls = {}
  local ctrls_key = 'TRO_modControls_tooltip' .. (tro_config.invert_tile_controls and '_i' or '')
  localize{type = 'descriptions', set = 'Other', key = ctrls_key, nodes = ctrls, text_colour = args.colour}
  for _, v in ipairs(ctrls) do
    table.insert(nodes, { n = G.UIT.R, config = {}, nodes = v })
  end
end