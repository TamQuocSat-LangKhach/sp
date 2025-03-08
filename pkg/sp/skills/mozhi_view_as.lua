```lua
local mozhi = fk.CreateSkill {
  name = "mozhi",
}

Fk:loadTranslationTable{
  ['mozhi_view_as'] = '默识',
  ['mozhi'] = '默识',
}

mozhi:addEffect('viewas', {
  card_filter = function(skill, player, to_select, selected)
    return #selected == 0 and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
  end,
  view_as = function(skill, player, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard(player:getMark("mozhi_to_use"))
    card:addSubcard(cards[1])
    card.skillName = "mozhi"
    return card
  end,
})

return mozhi
```