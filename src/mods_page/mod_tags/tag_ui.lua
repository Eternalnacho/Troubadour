local m = assert(SMODS.load_file("src/mods_page/helper.lua"))()
local Row, Col = Troubadour.UI.create_row, Troubadour.UI.create_column
local Text, TextCol = Troubadour.UI.create_text_node, m.createTextColNode

-- MOD-ICON MODS PAGE UIDEFS

function Troubadour.UIDEF.mod_icon_popup(mod, scale)
  local col, bg_col, text_col = Troubadour.ICONS.get_mod_popup_colours(mod)
  local version_col = copy_table(G.C.WHITE); version_col[4] = 0.6
  local the_colour = mix_colours(G.C.BLACK, G.C.WHITE, 0.2); the_colour[4] = 0.8
  local label_nodes = {}
  -- Get Mod Name Node
  Troubadour.ICONS.get_modName_node(mod, label_nodes, {scale = scale * 0.65, colour = text_col})
  -- Get "Lovely Only" Node
  Troubadour.ICONS.get_lovely_node(mod, label_nodes, {scale = scale * 0.6, colour = version_col})
  -- Get Version Node
  Troubadour.ICONS.get_version_node(mod, label_nodes, {scale = scale * 0.6, colour = version_col})
  -- Get Author DynaText Node
  Troubadour.ICONS.get_authorDyna_node(mod, label_nodes, {scale = scale * 0.4, colour = the_colour})
  -- Priority Node ???
  Troubadour.ICONS.get_priority_node(mod, label_nodes, {scale = scale * 0.5, colour = version_col})
  -- Get Load State Node
  Troubadour.ICONS.get_loadState_nodes(mod, label_nodes, {scale = scale * 0.4, colour = version_col})

  -- Controls at bottom of UIBox
  Troubadour.ICONS.get_controls(label_nodes, {scale = scale * 0.3, colour = version_col})

  return Col { r = 0.2, padding = 0.1, emboss = 0.1, colour = bg_col,
    outline = 1, outline_colour = mix_colours(col, G.C.WHITE, 0.7),
    nodes = {
      Row { r = 0.2, padding = 0.05, emboss = 0.05, colour = col, nodes = {
        Col { r = 0.2, padding = 0.05, nodes = label_nodes }
      }}
    }}
end

function Troubadour.ICONS.get_mod_popup_colours(mod)
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

function Troubadour.ICONS.get_modName_node(mod, nodes, args)
  local modname_split = SMODS.smart_line_splitter(mod.name, 18, true)
  for _,v in ipairs(modname_split) do
    table.insert(nodes, TextCol(v, args.scale, args.colour))
  end
end

function Troubadour.ICONS.get_lovely_node(mod, nodes, args)
  if mod.lovely_only then
    table.insert(nodes, TextCol(localize('b_lovely_mod'), args.scale, args.colour))
  end
end

function Troubadour.ICONS.get_version_node(mod, nodes, args)
  local sub_node = {}
  if mod.version and mod.version ~= '0.0.0' then
    table.insert(sub_node, TextCol(('%s'):format(mod.version), args.scale, args.colour, G.UIT.C))
  end
  if #sub_node > 0 then table.insert(nodes, { n = G.UIT.R, config = {}, nodes = sub_node }) end
end

function Troubadour.ICONS.get_authorDyna_node(mod, nodes, args)
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

function Troubadour.ICONS.get_priority_node(mod, nodes, args)
  local sub_node = {}
  if not _RELEASE_MODE and mod.priority then
    table.insert(nodes, TextCol(('%s%s'):format(localize('b_priority'), number_format(mod.priority)), args.scale, args.colour))
  end
  if #sub_node > 0 then table.insert(nodes, { n = G.UIT.R, config = {}, nodes = sub_node }) end
end

function Troubadour.ICONS.get_loadState_nodes(mod, nodes, args)
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

function Troubadour.ICONS.get_controls(nodes, args)
  local ctrls = {}
  local ctrls_key = 'TRO_modControls_tooltip' .. (tro_config.invert_tile_controls and '_i' or '')
  localize{type = 'descriptions', set = 'Other', key = ctrls_key, nodes = ctrls, text_colour = args.colour}
  for _, v in ipairs(ctrls) do
    table.insert(nodes, { n = G.UIT.R, config = {}, nodes = v })
  end
end