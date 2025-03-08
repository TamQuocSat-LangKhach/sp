local re__zishou = fk.CreateSkill {
  name = "re__zishou"
}

Fk:loadTranslationTable{
  ['re__zishou'] = '自守',
  [':re__zishou'] = '摸牌阶段，你可以额外摸X张牌（X为全场势力数）。若如此做，直到回合结束，其他角色不能被选择为你使用牌的目标。',
  ['$re__zishou1'] = '荆襄之地，固若金汤。',
  ['$re__zishou2'] = '江河霸主，何惧之有？',
}

re__zishou:addEffect(fk.DrawNCards, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(re__zishou.name) and player.phase == Player.Draw
  end,
  on_use = function(self, event, target, player, data)
    local kingdoms = {}
    for _, p in ipairs(player.room.alive_players) do
      table.insertIfNeed(kingdoms, p.kingdom)
    end
    data.n = data.n + #kingdoms
  end,
})

re__zishou:addEffect('prohibit', {
  is_prohibited = function(self, from, to, card)
  if from:hasSkill(re__zishou.name) then
    return from:usedSkillTimes("re__zishou") > 0 and from ~= to
  end
  end,
})

return re__zishou