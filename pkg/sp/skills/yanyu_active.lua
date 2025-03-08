local yanyu_ac = fk.CreateSkill {
  name = "yanyu_active"
}

Fk:loadTranslationTable {
  ['yanyu_active'] = '燕语',
}

yanyu_ac:addEffect('active', {
  expand_pile = function(self, player)
    return player:getTableMark("yanyu_cards")
  end,
  card_num = 1,
  target_num = 1,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains(player:getTableMark("yanyu_cards"), to_select)
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0
  end,
})

return yanyu_ac
