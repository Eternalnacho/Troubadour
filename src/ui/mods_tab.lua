local m = assert(SMODS.load_file("src/mods_page/helper.lua"))()
local T = Troubadour.UI

-- SMALLER MODLIST

function Troubadour.UIDEF.statModList()
  local scale = 0.75
  local currentPage, pageOptions, showingList, _, _, dminh, dminw = m.recalculateModsList()

  return T.Row { minh = 1.5 * dminh + 1, minw = 1.5 * dminw + 1, r = 0.1, colour = G.C.BLACK, nodes = {
    -- row container
    T.Col { nodes = {
      -- column container
      T.Col { minw = 5, r = 0.1, nodes = {
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
        }},
        -- add some empty rows for spacing
        T.Row {},
        T.Row {},
        -- dynamic content rendered in this row container
        -- list of 4 x 4 mods on the current page
        T.Row { minh = dminh + 1, minw = dminw + 1,
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
            table.insert(current_row, Troubadour.UIDEF.modListIcon(modInfo))
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
    }}
  }}
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
    colour_override = {colour = T.C.outline_colour},
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

  return T.Col ({},
    {
      T.Col ({ padding = 0.0, minw = 1, minh = 1 }, { Troubadour.ModTile({mod = modInfo}):render() })
    }
  )
end

function Troubadour.UIDEF.getModTagInfo(mod)
  local tag_pos = { x = 0, y = 0 }
  local tag_atlas = mod.prefix and mod.prefix .. '_modicon' or 'modicon'

  if not mod.can_load then
    if mod.disabled and not mod.icon_path then
      tag_atlas = 'TRO_' .. mod.id .. '_modicon'
    end
  end

  return tag_atlas, tag_pos
end

function Troubadour.UIDEF.modTagSprite(mod)
  local tag_atlas, tag_pos = Troubadour.UIDEF.getModTagInfo(mod)
  local tag_sprite = SMODS.create_sprite(0, 0, 0.8, 0.8, SMODS.get_atlas(tag_atlas) or SMODS.get_atlas('tags'), tag_pos)

  tag_sprite.T.scale = 1
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

Troubadour.UIDEF.modNodes = {
  name = function(mod, nodes, args)
    local modname_split = SMODS.smart_line_splitter(mod.name, 18, true)
    for _,v in ipairs(modname_split) do
      table.insert(nodes, m.TextColumn(v, args.scale, args.colour))
    end
  end,

  lovely = function(mod, nodes, args)
    if mod.lovely_only then
      table.insert(nodes, m.TextColumn(localize('b_lovely_mod'), args.scale, args.colour))
    end
  end,

  version = function(mod, nodes, args)
    local sub_node = {}
    if mod.version and mod.version ~= '0.0.0' then
      table.insert(sub_node, m.TextColumn(('%s'):format(mod.version), args.scale, args.colour, G.UIT.C))
    end
    if #sub_node > 0 then table.insert(nodes, { n = G.UIT.R, config = {}, nodes = sub_node }) end
  end,

  authors = function(mod, nodes, args)
    if not mod.lovely_only then
      local tx = m.concatAuthors(mod.author)
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
      table.insert(nodes, m.TextColumn(('%s%s'):format(localize('b_priority'), number_format(mod.priority)), args.scale, args.colour))
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