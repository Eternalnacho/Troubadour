-- I'm stealing this from Too Many Jokers, it's too good not to steal.
local oldcuib = create_UIBox_generic_options
create_UIBox_generic_options = function(arg1, ...) --inserts the text into most collection pages without needing to hook each individual function
    if arg1 and arg1.back_func == "your_collection" or arg1.back_func == 'your_collection_consumables'
        and arg1.contents and arg1.contents[1] and arg1.contents[1].n == 4 and TRO.adding_key then
      local new_target = TRO.adding_key and next(TRO.collection_targets) and TRO.collection_targets[#TRO.collection_targets]
      if new_target then
        table.insert(arg1.contents, {
          n = G.UIT.R,
          config = { align = "cm", minh = 0.5 },
          nodes = {
              { n = G.UIT.C, config = { align = "cm", padding = 0.15, r = 0.2, minw = 5, colour = darken(copy_table(G.C.GREY), 0.5), emboss = 0.05 },
                nodes = { { n = G.UIT.T, config = { text = "Added key: " .. new_target, colour = G.C.WHITE, shadow = true, scale = 0.3 } } } }
          }
        })
        TRO.adding_key = nil
      end
    end
    return oldcuib(arg1, ...)
end

TRO.UI.get_page_num = true
local smodsccb = SMODS.card_collection_UIBox
SMODS.card_collection_UIBox = function(_pool, rows, args)
  args.no_materialize = TRO.adding_key and true or args.no_materialize
  if TRO.UI.rerendering then args.TRO_curr_option = TRO.UI.curr_page end
  return smodsccb(_pool, rows, args)
end