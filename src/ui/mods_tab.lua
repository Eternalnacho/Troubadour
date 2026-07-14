local F = Troubadour.FUNCS
local T = Troubadour.UI

-- SMALLER MODLIST

function Troubadour.UIDEF.statModList()
  local currentPage, pageOptions, showingList, _, _, dminh, dminw = F.recalculateModsList()
  local Searcher = Troubadour.Searcher({
    width = 4.5,
    id = 'modsList',
    list = SMODS.mod_list,
    search_funcs = Troubadour.Folder.UI.search_funcs,
  })
  Searcher.render_list = Troubadour.UIDEF.dynaModList
  local modsList = UIBox({
    definition = Troubadour.UIDEF.dynaModList(SMODS.mod_list, 1),
    config = { type = "cm" }
  })

  local contents = T.Row (
    {
      minh = 1.5 * dminh + 1,
      minw = 1.5 * dminw + 1,
      r = 0.1,
      colour = G.C.BLACK,
    },
    {
      T.Col ({}, {
        T.Col ({ r = 0.1 }, {
          -- Title Row
          T.Row ({}, {
            T.Col ({}, {
              UIBox_button({
                label = { localize('b_mod_list') },
                shadow = true,
                scale = 0.75 * 0.85,
                colour = G.C.BOOSTER,
                button = "openModsDirectory",
                minh = 0.75,
                minw = 4.5
              }),
            }),
            T.Col {},
            T.Col { nodes = {
              Troubadour.UIDEF.modHeaderIcon('tro_list', {x = 0, y = 0}, 'Troubadour_modlist_button', 'TRO_mod_list')
            }},
            T.Col { nodes = {
              Troubadour.UIDEF.modHeaderIcon('tro_folder', {x = 0, y = 0}, 'Troubadour_mod_folder_button', 'TRO_mod_folder_page')
            }},
            T.Col { nodes = {
              Troubadour.UIDEF.modHeaderIcon('mod_tags', {x = 2, y = 0}, 'Troubadour_modlist_config', 'TRO_mod_page_config')
            }},
            showingList and T.Col ({}, { Searcher:get_text_input() }),
          }),
          -- Spacer Row
          T.Row ({}, { T.Col({ colour = G.C.GREY, minw = dminw * 1.2 }) }),
          -- Dynamic Content : Mod List
          T.Row ({},
            {{
              n = G.UIT.O,
              config = {
                align = "cm",
                id = 'modsList',
                object = modsList
              }
            }}
          ),
          -- Page Selector (does not appear when mod list is empty)
          showingList and SMODS.GUI.createOptionSelector({
            scale = 0.8,
            options = pageOptions,
            opt_callback = 'Troubadour_update_mod_list',
            no_pips = true,
            current_option = ( currentPage )
          }),
        })
      })
    })
  return T.UIBox ({
    emboss = 0.05,
    minh = 6,
    minw = 8,
    r = 0.1,
    bg_colour = G.C.BLACK,
    contents = { contents }
  })
end

function Troubadour.UIDEF.dynaModList(list, page)
  if not list then list = SMODS.mod_list end
  local _, _, _, _, _, dminh, dminw = F.recalculateModsList()
  local render = F.renderModList(list, page, F.recalculateModsList, Troubadour.UIDEF.modListIcon)
  return T.UIBox ({ minw = dminw * 1.5 + 0.5, minh = dminh * 1.5 + 0.5, bg_colour = G.C.CLEAR }, {render})
end

-- MOD-ICON COLOURS

function Troubadour.UIDEF.get_mod_popup_colours(mod)
  if not mod then mod = {can_load = true} end

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

-- ICON UI DEFINITIONS

function Troubadour.UIDEF.modHeaderIcon(atlas, pos, button_func, tooltip_key)
  local tag_sprite = SMODS.create_sprite(0, 0, 0.5, 0.5, atlas, pos)
  local tile_enabled = { is = false } -- I like the darker tile look better for this
  local tile = Troubadour.Tile({
    ref_table = tile_enabled, ref_value = 'is',
    object = tag_sprite, object_args = {w = SMODS.pixels_to_unit(34), h = SMODS.pixels_to_unit(34), colour = G.C.BLUE},
    TRO_mod_tile = true,
    TRO_dark_tooltip = tooltip_key,
    no_outline = true,
    colour_override = { outline_disabled = T.C.outline_colour },
    button_func = button_func,
    shadow = true, shadow_height = 0.25, hovering = true,
  })

  return T.Col(
    { padding = 0.1 }, -- config
    { tile:render() }  -- nodes
  )
end

function Troubadour.UIDEF.modListIcon(modInfo)
  if modInfo.should_enable == nil then modInfo.should_enable = not modInfo.disabled end
  if SMODS.full_restart == nil then SMODS.full_restart = 0 end
  return Troubadour.ModTile({mod = modInfo}):render()
end

function Troubadour.UIDEF.getModTagInfo(mod)
  local tag_pos = { x = 0, y = 0 }
  local tag_atlas = mod.prefix and mod.prefix .. '_modicon' or 'modicon'

  if not mod.can_load then
    if next(mod.load_issues.dependencies)
        or next(mod.load_issues.conflicts)
        or mod.load_issues.outdated
        or mod.load_issues.version_mismatch
        or mod.load_issues.main_file_not_found
        or next(mod.load_issues.prefix_conflicts or {}) then
      tag_atlas = "mod_tags"
    end
    if mod.disabled and not mod.icon_path then
      tag_atlas = 'TRO_' .. mod.id .. '_modicon'
    end
  end

  return tag_atlas, tag_pos
end

function Troubadour.UIDEF.modTagSprite(mod)
  local tag_atlas, tag_pos = Troubadour.UIDEF.getModTagInfo(mod)
  local tag_sprite = SMODS.create_sprite(0, 0, 1, 1, SMODS.get_atlas(tag_atlas) or SMODS.get_atlas('tags'), tag_pos)

  tag_sprite:define_draw_steps({
    { shader = 'dissolve', shadow_height = 0.05 },
    { shader = 'dissolve' },
    mod.disabled and {shader = 'dissolve', shadow_height = 0, tilt_shadow = 1}
  })

  tag_sprite.float = true
  tag_sprite:juice_up(0.2)
  return tag_sprite
end

-- NODES FOR MOD TILE POPUP

local concatTable = function(tbl_or_str)
  if type(tbl_or_str) == "table" then return table.concat(tbl_or_str, ", ") end
  return tbl_or_str or localize('b_unknown')
end

local textCol = function(text, scale, colour, node)
  return {
    n = node or G.UIT.R,
    config = { align = "lc", maxw = 2.8, maxh = 1.5 },
    nodes = { T.Text ({ text = text, colour = colour or G.C.UI.TEXT_LIGHT, scale = scale * 0.7 }) }
  }
end

Troubadour.UIDEF.modNodes = {
  name = function(mod, nodes, args)
    if not mod.name then return end
    local modname_split = SMODS.smart_line_splitter(mod.name, 18, true)
    for _,v in ipairs(modname_split) do
      table.insert(nodes, textCol(v, args.scale, args.colour))
    end
  end,

  lovely = function(mod, nodes, args)
    if mod.lovely_only then
      table.insert(nodes, textCol(localize('b_lovely_mod'), args.scale, args.colour))
    end
  end,

  version = function(mod, nodes, args)
    local sub_node = {}
    if mod.version and mod.version ~= '0.0.0' then
      table.insert(sub_node, textCol(('%s'):format(mod.version), args.scale, args.colour, G.UIT.C))
    end
    if #sub_node > 0 then table.insert(nodes, { n = G.UIT.R, config = {}, nodes = sub_node }) end
  end,

  authors = function(mod, nodes, args)
    if not mod.lovely_only then
      local tx = concatTable(mod.author)
      local authorBox = SMODS.UIScrollBox({
        content = DynaText({
          string = tx,
          scale = args.scale,
          colours = { args.colour },
          shadow = true,
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
      table.insert(nodes,
        T.Row { padding = 0, align = "lc", maxw = 4.5, maxh = 1.5, nodes =
            {
              { n = G.UIT.T, config = { text= localize('b_by'), scale = args.scale, colour = args.colour } },
              { n = G.UIT.O, config = {object = authorBox} }
            }
        })
    end
  end,

  priority = function(mod, nodes, args)
    local sub_node = {}
    if not _RELEASE_MODE and mod.priority then
      table.insert(nodes, textCol(('%s%s'):format(localize('b_priority'), number_format(mod.priority)), args.scale, args.colour))
    end
    if #sub_node > 0 then table.insert(nodes, { n = G.UIT.R, config = {}, nodes = sub_node }) end
  end,

  loadState = function(mod, nodes, args)
    local sub_node = {}
    local tag_state = 'load_success'
    local specific_vars = {}

    if not mod.can_load then
      tag_state = 'load_failure'
      if next(mod.load_issues.dependencies) then
        tag_state = tag_state .. '_d'
        table.insert(specific_vars, concatTable(mod.load_issues.dependencies))
      end
      if next(mod.load_issues.conflicts) then
        tag_state = tag_state .. '_c'
        table.insert(specific_vars, concatTable(mod.load_issues.conflicts))
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
      if i < #state_nodes then table.insert(sub_node, T.Text{ text = ' ', scale = args.scale }) end
    end
    if #sub_node > 0 then table.insert(nodes, { n = G.UIT.R, config = {}, nodes = sub_node }) end
  end,

  controls = function(nodes, args)
    local ctrls = {}
    local ctrls_key = 'TRO_modControls_tooltip' .. (Troubadour.config.invert_tile_controls and '_i' or '')
    localize{type = 'descriptions', set = 'Other', key = ctrls_key, nodes = ctrls, text_colour = args.colour}
    for _, v in ipairs(ctrls) do
      table.insert(nodes, { n = G.UIT.R, config = {}, nodes = v })
    end
  end
}