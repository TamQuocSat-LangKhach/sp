```lua
local yanyu = fk.CreateSkill {
  name = "yanyu"
}

Fk:loadTranslationTable{
  ['yanyu_active'] = '燕语',
}

yanyu:addEffect('active', {
  ask = function(skill, room)
  local player = skill.player
  return room:askToChooseCardsAndPlayers(player, {
    min_card_num = 1,
    max_card_num = 1,
    targets = fk.AlivePlayers(),
    min_target_num = 1,
    max_target_num = 1,
    expand_pile = player:getTableMark("yanyu_cards"),
    card_filter = function(to_select, selected)
    return #selected == 0 and table.contains(player:getTableMark("yanyu_cards"), to_select)
    end,
    target_filter = function(to_select, selected)
    return #selected == 0
    end,
  })
  end
})

return yanyu
```