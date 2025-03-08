local fenxin = fk.CreateSkill {
  name = "fenxin"
}

Fk:loadTranslationTable{
  ['fenxin'] = '焚心',
  ['#fenxin-invoke'] = '焚心：你可以与 %src 交换身份牌',
  [':fenxin'] = '限定技，当你杀死一名非主公角色时，在其翻开身份牌之前，你可以与该角色交换身份牌。（你的身份为主公时不能发动此技能。）',
  ['$fenxin1'] = '主上，这是最后的机会……',
  ['$fenxin2'] = '杀人，诛心。',
}

fenxin:addEffect(fk.BeforeGameOverJudge, {
  anim_type = "offensive",
  frequency = Skill.Limited,
  can_trigger = function(skill, event, target, player, data)
    return player:hasSkill(skill.name) and player:usedSkillTimes(fenxin.name, Player.HistoryGame) == 0 and
         data.damage and data.damage.from and data.damage.from == player and
         player.role ~= "lord" and target.role ~= "lord"
  end,
  on_cost = function (skill, event, target, player, data)
    if player.room:askToSkillInvoke(player, {
      skill_name = skill.name,
      prompt = "#fenxin-invoke:"..target.id
    }) then
      event:setCostData(skill, {tos = {target.id}})
      return true
    end
  end,
  on_use = function(skill, event, target, player, data)
    player.role, target.role = target.role, player.role
    player.room:broadcastProperty(player, "role")
    player.room:broadcastProperty(target, "role")
  end,
})

return fenxin