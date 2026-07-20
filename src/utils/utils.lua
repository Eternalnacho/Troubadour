-- UTILITY FUNCTIONS
Troubadour.utils = {}

-- List functions
function Troubadour.utils.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function Troubadour.utils.filter(list, func)
  local new_list = {}
  for _, v in pairs(list) do
    if func(v) then
      new_list[#new_list + 1] = v
    end
  end
  return new_list
end

function Troubadour.utils.for_each(list, func)
  for _, v in pairs(list) do
    func(v)
  end
end

function Troubadour.utils.map_list(list, func)
  local new_list = {}
  for _, v in pairs(list) do
    new_list[#new_list + 1] = func(v)
  end
  return new_list
end

function Troubadour.defer(func, args) -- Stealing this one from Emma holy moly that's useful
  if not args then args = {} end
  G.E_MANAGER:add_event(Event({
    trigger = args.trigger or args.delay and 'after',
    delay = args.delay,
    func = function()
      func()
      return true
    end,
    blocking = args.blocking or true,
    blockable = args.blockable or false,
  }))
end

-- math functions

function math.round(n)
  return n * 10 % 10 < 5 and math.floor(n) or math.ceil(n)
end

-- mod functions

function Troubadour.toggleMod(mod)
  if not mod.should_enable then
    NFS.write(mod.path .. '.lovelyignore', '')
  else
    NFS.remove(mod.path .. '.lovelyignore')
  end
  local toChange = 1
  if mod.should_enable == not mod.disabled then
    toChange = -1
  end
  SMODS.full_restart = SMODS.full_restart + toChange
end

-- table functions

table.unpack = table.unpack or unpack

-- hooking functions helper

local hooks = {
  before = function (table, funcname, hook)
    local orig = table[funcname] or function(...) end
    table[funcname] = function(...) return hook(...) or orig(...) end
  end,

  after = function (table, funcname, hook, prevent_run)
    local orig = table[funcname] or function(...) end
    table[funcname] = function(...)
      local ret = orig(...)
      local h_ret = (not prevent_run or ret) and hook(...)
      return ret or h_ret
    end
  end,

  around = function (table, funcname, hook)
    local orig = table[funcname] or function(...) end
    table[funcname] = function(...) return hook(orig, ...) end
  end,
}

---@alias hook_type
---| "before" # Pre-Call processing
---| "after"  # Post-Call processing
---| "around" # Pre-or-Post-Call processing (requires orig in hook)
---@param hook_type hook_type
---@param table any
---@param funcname string
---@param hook function
---@param prevent_run boolean?
Troubadour.Hook = function(hook_type, table, funcname, hook, prevent_run)
  if not hook then return end
  if hooks[hook_type] then hooks[hook_type](table, funcname, hook, hook_type == 'after' and prevent_run) end
end