```lua
local qiluan = fk.CreateSkill {
  name = "qiluan"
}

Fk:loadTranslationTable{
  ['qiluan'] = '戚乱',
  [':qiluan'] = '一名角色的回合结束时，若你杀死过角色，你可摸3张牌。',
  ['$qiluan1'] = '待我召吾兄入宫，谁敢不从？',
  ['$qiluan2'] = '本后自有哥哥在外照应，有什么好担心的！',
}

qiluan:addEffect(fk.TurnEnd, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player)
    return #player.room.logic:getEventsOfScope(GameEvent.Death, 1, function (e)
      local deathData = e.data[1]
      if deathData.damage and deathData.damage.from == player then
        return true
      end
    end, Player.HistoryTurn) > 0
  end,
  on_use = function(self, event, target, player)
    player:drawCards(3, qiluan.name)
  end,
})

return qiluan
```