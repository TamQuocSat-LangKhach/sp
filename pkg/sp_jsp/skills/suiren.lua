local suiren = fk.CreateSkill {
  name = "suiren"
}

Fk:loadTranslationTable{
  ['suiren'] = '随仁',
  ['#suiren-choose'] = '随仁：你可以失去〖义从〗，然后加1点体力上限并回复1点体力，令一名角色摸三张牌',
  [':suiren'] = '限定技，准备阶段开始时，你可以失去技能〖义从〗，然后加1点体力上限并回复1点体力，再令一名角色摸三张牌。',
}

sui-ren:addEffect(fk.EventPhaseStart, {
  frequency = Skill.Limited,
  can_trigger = function(skill, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and player:usedSkillTimes(skill.name, Player.HistoryGame) == 0
      and player.phase == Player.Start and player:hasSkill("yicong", true)
  end,
  on_cost = function(skill, event, target, player, data)
    local to = player.room:askToChoosePlayers(player, {
      targets = table.map(player.room:getAlivePlayers(), function (p) return p end),
      min_num = 1,
      max_num = 1,
      prompt = "#suiren-choose",
      skill_name = skill.name
    })
    if #to > 0 then
      event:setCostData(skill, to[1].id)
      return true
    end
  end,
  on_use = function(skill, event, target, player, data)
    local room = player.room
    room:handleAddLoseSkills(player, "-yicong", nil, true, false)
    room:changeMaxHp(player, 1)
    if player:isWounded() then
      room:recover({
        who = player,
        num = 1,
        recoverBy = player,
        skillName = skill.name
      })
    end
    room:getPlayerById(event:getCostData(skill)):drawCards(3, suiren.name)
  end,
})

return suiren