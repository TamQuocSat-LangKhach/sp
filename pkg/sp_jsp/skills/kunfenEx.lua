```lua
local kunfenEx = fk.CreateSkill {
  name = "kunfenEx"
}

Fk:loadTranslationTable{
  ['kunfenEx'] = '困奋',
  [':kunfenEx'] = '结束阶段开始时，你可以失去1点体力，然后摸两张牌。',
  ['$kunfenEx1'] = '纵使困顿难行，亦当砥砺奋进！',
  ['$kunfenEx2'] = '兴蜀需时，众将且勿惫怠！',
}

kunfenEx:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(skill, event, target, player)
    return target == player and player:hasSkill(skill.name) and player.phase == Player.Finish
  end,
  on_use = function(skill, event, target, player)
    player.room:loseHp(player, 1, skill.name)
    if player:isAlive() then
      player.room:drawCards(player, 2, {skill_name = skill.name})
    end
  end,
})

return kunfenEx
```