local cest = card_eval_status_text
function card_eval_status_text(...)
  if not TRO.skip_anims then cest(...) end
end

local jc = juice_card
function juice_card(...)
  if not TRO.skip_anims then jc(...) end
end

local cju = Card.juice_up
function Card:juice_up(...)
  if not TRO.skip_anims then cju(self, ...) end
end