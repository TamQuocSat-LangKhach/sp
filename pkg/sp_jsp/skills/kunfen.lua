```lua
local kunfen = fk.CreateSkill {
  name = "kunfen"
}

Fk:loadTranslationTable{
  ['kunfen'] = '困奋',
  [':kunfen'] = '锁定技，结束阶段开始时，你失去1点体力，然后摸两张牌。',
  ['$kunfen1'] = '纵使困顿难行，亦当砥砺奋进！',
  ['$kunfen2'] = '兴蜀需时，众将且勿惫怠！',
}

kunfen:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player)
    return target == player and player:hasSkill(kunfen.name) and player.phase == Player.Finish
  end,
  on_use = function(self, event, target, player)
    player.room:loseHp(player, 1, kunfen.name)
    if player:isAlive() then
    player.room:drawCards(player, { num = 2, reason = kunfen.name })
    end
  end,
})

return kunfen
```