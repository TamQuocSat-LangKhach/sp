local fanxiang = fk.CreateSkill {
  name = "fanxiang"
}

Fk:loadTranslationTable{
  ['fanxiang'] = '返乡',
  [':fanxiang'] = '觉醒技，准备阶段开始时，若全场有至少一名已受伤的角色，且你令其执行过〖良助〗选项2的效果，则你加1点体力上限并回复1点体力，失去技能〖良助〗并获得技能〖枭姬〗。',
  ['$fanxiang1'] = '兄命难违，从此两别。',
  ['$fanxiang2'] = '今夕一别，不知何日再见。',
}

fanxiang:addEffect(fk.EventPhaseStart, {
  global = false,
  can_trigger = function(skill, event, target, player, data)
  return target == player and player:hasSkill(skill.name) and
    player.phase == Player.Start and
    player:usedSkillTimes(skill.name, Player.HistoryGame) == 0
  end,
  can_wake = function(skill, event, target, player, data)
  return table.find(player.room.alive_players, function(p) 
    return p:isWounded() and table.contains(player:getTableMark("liangzhu_target"), p.id)
  end)
  end,
  on_use = function(skill, event, target, player, data)
  local room = player.room
  room:changeMaxHp(player, 1)
  if not player.dead and player:isWounded() then
    room:recover({
    who = player,
    num = 1,
    recoverBy = player,
    skillName = fanxiang.name
    })
  end
  room:handleAddLoseSkills(player, "-liangzhu|xiaoji", nil)
  end,
})

return fanxiang