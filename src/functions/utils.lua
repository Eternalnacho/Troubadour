-- UTILITY FUNCTIONS
TRO.utils = {}

-- List functions
function TRO.utils.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function TRO.utils.filter(list, func)
  local new_list = {}
  for _, v in pairs(list) do
    if func(v) then
      new_list[#new_list + 1] = v
    end
  end
  return new_list
end

function TRO.utils.for_each(list, func)
  for _, v in pairs(list) do
    func(v)
  end
end

function TRO.utils.copy_list(list)
  return TRO.utils.map_list(list, TRO.utils.id)
end

function TRO.utils.map_list(list, func)
  local new_list = {}
  for _, v in pairs(list) do
    new_list[#new_list + 1] = func(v)
  end
  return new_list
end

function TRO.utils.id(a)
  return a
end

function TRO.utils.tableToString(tbl, sep)
  local result = {}
  for _, line in ipairs(tbl) do
      local cleanedLine = line:gsub("{.-}", "")
      table.insert(result, cleanedLine)
  end
  return table.concat(result, (sep or " "))
end


-- math functions
to_number = to_number or function(x) return x end

function math.summ(n)
  return n * (n + 1) / 2
end


-- string functions
function starts_with(str, start)
	return string.sub(str, 1, #start) == start
end

function ends_with(str, ending)
	return string.sub(str, -#ending) == ending
end

function containsString(str, substring)
	local lowerStr = string.lower(str)
	local lowerSubstring = string.lower(substring)
	return string.find(lowerStr, lowerSubstring, 1, true) ~= nil
end

-- metafunctions
function TRO.utils.hook_before_function(table, funcname, hook)
  if not table[funcname] then
    table[funcname] = hook
  else
    local orig = table[funcname]
    table[funcname] = function(...)
      return hook(...)
          or orig(...)
    end
  end
end

function TRO.utils.hook_after_function(table, funcname, hook, always_run)
  if not table[funcname] then
    table[funcname] = hook
  else
    local orig = table[funcname]
    if always_run then
      table[funcname] = function(...)
        local ret = orig(...)
        local hook_ret = hook(...)
        return ret or hook_ret
      end
    else
      table[funcname] = function(...)
        return orig(...)
            or hook(...)
      end
    end
  end
end