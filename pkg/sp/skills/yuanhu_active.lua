local yuanhu = fk.CreateSkill {
  name = "yuanhu"
}

Fk:loadTranslationTable{
  ['#yuanhu_active'] = '援护',
}

yuanhu:addEffect('active', {
  card_num = 1,
  target_num = 1,
  card_filter = function(skill, player, to_select, selected)
  return #selected == 0 and Fk:getCardById(to_select).type == Card.TypeEquip
  end,
  target_filter = function(skill, player, to_select, selected, selected_cards)
  return #selected == 0 and #selected_cards == 1 and
    Fk:currentRoom():getPlayerById(to_select):hasEmptyEquipSlot(Fk:getCardById(selected_cards[1]).sub_type)
  end,
})

return yuanhu