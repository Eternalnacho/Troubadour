-- NUM INPUT FIELD

-- This is functionally the same as a normal text input but with a different text input func
function create_num_input(args)
  args = args or {}
  args.prompt_text = args.prompt_text or localize('k_enter_text')
  args.current_prompt_text = ''
  args.id = args.id or "num_input"

  local ret = create_text_input(args)
  ret.nodes[1].nodes[1].nodes[1].config.func = 'TRO_num_input'
  return ret
end

G.FUNCS.TRO_num_input = function(e)
  e.from_num_input = true
  G.FUNCS.text_input(e)
end

local text_input_ref = G.FUNCS.text_input
G.FUNCS.text_input = function(e, ...)
  Troubadour.nums_only = e.from_num_input and true
  text_input_ref(e, ...)
end