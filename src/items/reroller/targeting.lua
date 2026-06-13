-- thank you Overstock and god bless you
local function can_reroll_into(card_key)
  if not tro_config.enable_auto_reroll or G.STATE ~= G.STATES.SHOP then return end
  local center = G.P_CENTERS[card_key]
  if not center then return false end
  if G.GAME.banned_keys and G.GAME.banned_keys[card_key] then return false end
  if center.no_appear_in_shop then return false end

  if center.yes_pool_flag and (not G.GAME.pool_flags or not G.GAME.pool_flags[center.yes_pool_flag]) then return false end
  if center.no_pool_flag and (G.GAME.pool_flags and G.GAME.pool_flags[center.no_pool_flag]) then return false end

  if center.set == 'Edition' and not center.in_shop then return false end

  if ({
    Enhanced = true,
    Back = true,
    Spectral = G.GAME.spectral_rate <= 0,
    Voucher = true
  })[center.set] then return false end
  return true
end

local function is_reroll_button(target)
  if G.STATE == G.STATES.SHOP then
    local reroll_button = G.shop:get_UIE_by_ID("next_round_button").parent.children[2]
    if target == reroll_button then return true end
  end
end

local function update_menu_target_list(object)
  if object then
    object.config.object:remove()
    object.config.object = UIBox({ definition = Troubadour.UIDEF.reroll_targets_list("Current Targets:"), config = {type = "cm", parent = object}})
    G.OVERLAY_MENU:recalculate()
  end
end

function Troubadour.FUNCS.prompt_target(target)
  if is_reroll_button(target) and tro_config.enable_auto_reroll then
    if next(Troubadour.collection_targets) and (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") or G.CONTROLLER.held_buttons.triggerleft) then
      if type(tro_config.reroll_limit) ~= 'number' then tro_config.reroll_limit = tonumber(tro_config.reroll_limit) or 30 end
      Troubadour.FUNCS.auto_reroll(Troubadour.collection_targets)
    else
      G.FUNCS.TRO_your_collection()
    end
  end
end

function Troubadour.FUNCS.clear_targets(from_button)
  if next(Troubadour.collection_targets) and (from_button == true or (love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift"))) then
    Troubadour.collection_targets = {}

    if Troubadour.in_collection then
      update_menu_target_list(G.OVERLAY_MENU:get_UIE_by_ID('TRO_targetsList'))

    elseif G.STATE == G.STATES.SHOP and not G.SETTINGS.paused then
      update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname = "Reroll targets cleared"})
      Troubadour.defer(function()
        update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
      end, {delay = G.SETTINGS.GAMESPEED * 3})
    end
  end
end

-- Hook card clicks to add search targets
local cc = Card.click
function Card:click()
  if self.area and self.area.config.collection and can_reroll_into(self.config.center_key)
      and not Troubadour.utils.contains(Troubadour.collection_targets, self.config.center_key) then
    table.insert(Troubadour.collection_targets, self.config.center_key)
    Troubadour.UI.targets.added_target = self.config.center_key
    Troubadour.adding_key = true
    local set = self.config.center.set

    if Troubadour.FUNCS.get_type_collection_UIBox_func(set) and Troubadour.in_collection and not Troubadour.collection_from_button then
      Troubadour.UI.rerender_collection(set)
      Troubadour.collection_from_button = true

    elseif Troubadour.in_collection then
      update_menu_target_list(G.OVERLAY_MENU:get_UIE_by_ID('TRO_targetsList'))
    end
  end
  return cc(self)
end

-- Reroller controls
tro_input_manager:add_listener({ 'right_click', 'right_stick' }, Troubadour.FUNCS.prompt_target)
tro_input_manager:add_listener({ 'double_click' }, Troubadour.FUNCS.clear_targets)