local mozhi_viewas = fk.CreateSkill {
  name = "mozhi_viewas",
}

Fk:loadTranslationTable{
  ["mozhi_viewas"] = "默识",
}

mozhi_viewas:addEffect("viewas", {
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains(player:getHandlyIds(), to_select)
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard(self.mozhi)
    card:addSubcard(cards[1])
    card.skillName = "mozhi"
    return card
  end,
})

return mozhi_viewas
