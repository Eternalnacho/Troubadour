-- HOOKING TAG FUNCTIONS

local yep = Tag.yep
function Tag:yep(...)
  if Troubadour.in_reroll_sim then
    self.triggered = false
    return
  else yep(self, ...) end
end

local nope = Tag.nope
function Tag:nope()
  if Troubadour.in_reroll_sim then
    self.triggered = false
    return
  else nope(self) end
end

local apply_to_run = Tag.apply_to_run
function Tag:apply_to_run(...)
  local ret = apply_to_run(self, ...)
  if Troubadour.in_reroll_sim then
    self.triggered = false
  end
  return ret
end