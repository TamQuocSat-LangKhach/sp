
local fulu = fk.CreateSkill {
  name = "fulu",
}

Fk:loadTranslationTable{
  ["fulu"] = "符箓",
  [":fulu"] = "你可以将【杀】当雷【杀】使用。",

  ["#fulu"] = "符箓：你可以将【杀】当雷【杀】使用",

  ["$fulu1"] = "电母雷公，速降神通。",
  ["$fulu2"] = "山岳高昂，五雷速发。",
}

fulu:addEffect("viewas", {
  anim_type = "offensive",
  pattern = "slash",
  prompt = "#fulu",
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).name == "slash"
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    local c = Fk:cloneCard("thunder__slash")
    c.skillName = fulu.name
    c:addSubcard(cards[1])
    return c
  end,
})

return fulu
