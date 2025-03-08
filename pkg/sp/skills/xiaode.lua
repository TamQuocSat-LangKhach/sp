local xiaode = fk.CreateSkill {
  name = "xiaode"
}

Fk:loadTranslationTable{
  ['xiaode'] = '孝德',
  ['#xiaode-invoke'] = '孝德：你可以获得 %dest 武将牌上的一个技能直到你的回合结束',
  ['#xiaode-choice'] = '孝德：选择要获得 %dest 的技能',
  [':xiaode'] = '当有其他角色阵亡后，你可以声明该武将牌的一项技能，若如此做，你获得此技能并失去技能〖孝德〗直到你的回合结束。（你不能声明觉醒技或主公技）',
  ['$xiaode'] = '有孝有德，以引为翼。',
}

xiaode:addEffect(fk.Deathed, {
  can_trigger = function(self, event, target, player)
    return player:hasSkill(xiaode.name)
  end,
  on_cost = function(self, event, target, player)
    event:setCostData(player, {})
    local skills = Fk.generals[target.general]:getSkillNameList()
    if target.deputyGeneral ~= "" then table.insertTable(skills, Fk.generals[target.deputyGeneral]:getSkillNameList()) end
    for _, skill_name in ipairs(skills) do
      local skill = Fk.skills[skill_name]
      if skill.frequency ~= Skill.Wake and not player:hasSkill(skill, true) and
         not skill.lordSkill and not skill_name:endsWith("&") then
        table.insertIfNeed(event:getCostData(player), skill_name)
      end
    end
    return #event:getCostData(player) > 0 and player.room:askToSkillInvoke(player, {
      skill_name = xiaode.name,
      prompt = "#xiaode-invoke::"..target.id,
    })
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    local choice = room:askToChoice(player, {
      choices = event:getCostData(player),
      skill_name = xiaode.name,
      prompt = "#xiaode-choice::"..target.id,
      detailed = true,
    })
    room:handleAddLoseSkills(player, choice.."|-xiaode", nil, true, true)
    local mark = player:getMark(xiaode.name)
    if mark == 0 then mark = {} end
    table.insertIfNeed(mark, choice)
    room:setPlayerMark(player, xiaode.name, mark)
  end,
})

xiaode:addEffect(fk.TurnEnd, {
  can_refresh = function(self, event, target, player)
    return target == player and player:getMark(xiaode.name) ~= 0
  end,
  on_refresh = function(self, event, target, player)
    local room = player.room
    local names = xiaode.name
    for _, skill in ipairs(player:getMark(xiaode.name)) do
      if player:hasSkill(skill, true) then
        names = names.."|-"..skill
      end
    end
    room:handleAddLoseSkills(player, names, nil, true, false)
  end,
})

return xiaode