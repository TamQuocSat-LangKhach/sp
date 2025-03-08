```lua
local fenxun = fk.CreateSkill {
  name = "fenxun"
}

Fk:loadTranslationTable{
  ['fenxun'] = '奋迅',
  ['#fenxun'] = '奋迅：弃一张牌，你与一名角色的距离视为1直到回合结束',
  [':fenxun'] = '出牌阶段限一次，你可以弃置一张牌并选择一名其他角色，令你与其的距离视为1，直到回合结束。',
}

fenxun:addEffect('active', {
  anim_type = "offensive",
  card_num = 1,
  target_num = 1,
  prompt = "#fenxun",
  can_use = function(self, player)
    return player:usedSkillTimes(fenxun.name, Player.HistoryPhase) == 0 and not player:isNude()
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and not player:prohibitDiscard(Fk:getCardById(to_select))
  end,
  target_filter = function(self, player, to_select, selected, cards)
    return #selected == 0 and to_select ~= player.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:addTableMark(player, "fenxun-turn", effect.tos[1])
    room:throwCard(effect.cards, fenxun.name, player, player)
  end,
})

fenxun:addEffect('distance', {
  name = "#fenxun_distance",
  fixed_func = function(self, from, to)
  if table.contains(from:getTableMark("fenxun-turn"), to.id) then
    return 1
  end
  end,
})

return fenxun
```

这段代码不需要进行重构，因为其中没有使用任何`askForXXX`方法。