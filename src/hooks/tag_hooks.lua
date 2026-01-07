-- HOOKING TAG FUNCTIONS
local yep = Tag.yep
function Tag:yep(...)
  if TRO.in_reroll_sim then
    G.E_MANAGER:add_event(Event({
      func = (function()
        self.HUD_tag.states.visible = false
        return true
      end)
    }))
    G.E_MANAGER:add_event(Event({
      trigger = 'after',
      delay = 0.1,
      func = (function()
        self:remove()
        return true
      end)
    }))
    return
  else yep(self, ...) end
end

local nope = Tag.nope
function Tag:nope()
  if TRO.in_reroll_sim then
    G.E_MANAGER:add_event(Event({
      func = (function()
        self.HUD_tag.states.visible = false
        return true
      end)
    }))
    G.E_MANAGER:add_event(Event({
      trigger = 'after',
      delay = 0.1,
      func = (function()
        self:remove()
        return true
      end)
    }))
    return
  else nope(self) end
end