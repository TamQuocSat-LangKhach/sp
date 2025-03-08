local shichoul = fk.CreateSkill {
  name = "shichoul$"
}

Fk:loadTranslationTable{
  ['shichoul'] = '誓仇',
  ['#shichoul-invoke'] = '誓仇：你可以将两张牌交给一名蜀势力角色，你受到的伤害均转移给其直到其进入濒死状态',
  ['@@shichoul'] = '誓仇',
}

shichoul:addEffect(fk.TurnStart, {
  can_trigger = function(skill, event, target, player)
  return target == player and
       player:hasSkill(skill.name) and
       player:usedSkillTimes(skill.name, Player.HistoryGame) == 0 and
       #player:getCardIds{Player.Hand, Player.Equip} > 1 and
       table.find(player.room.alive_players, function(p)
       return p ~= player and p.kingdom == "shu"
       end)
  end,
  on_cost = function(skill, event, target, player)
  local room = player.room
  local targets = table.map(table.filter(room.alive_players, function(p) 
    return p ~= player and p.kingdom == "shu" 
  end), Util.IdMapper)

  if #targets == 0 then return false end

  local tos, cards = room:askToChooseCardsAndPlayers(player, {
    min_card_num = 2,
    max_card_num = 2,
    targets = targets,
    min_target_num = 1,
    max_target_num = 1,
    prompt = "#shichoul-invoke",
  })
  
  if #tos == 1 and #cards == 2 then
    event:setCostData(skill, {tos, cards})
    return true
  end

  return false
  end,
  on_use = function(skill, event, target, player)
  local room = player.room
  local ret = event:getCostData(skill)
  local to = room:getPlayerById(ret[1][1])
  
  room:notifySkillInvoked(player, skill.name)
  player:broadcastSkillInvoke(skill.name)

  room:obtainCard(to, ret[2], false, fk.ReasonGive, player.id)
  room:setPlayerMark(player, "shichoul", to.id)

  local mark = to:getMark("@@shichoul")
  
  if mark == 0 then 
    mark = {}
  end
  
  table.insert(mark, player.id)
  room:setPlayerMark(to, "@@shichoul", mark)  
  end,
})

shichoul:addEffect(fk.DamageInflicted, {
  can_trigger = function(skill, event, target, player)
  return target == player and
       player:getMark("shichoul") ~= 0 and 
       not player.room:getPlayerById(player:getMark("shichoul")).dead
  end,
  on_use = function(skill, event, target, player, data)
  local room = player.room
  
  room:notifySkillInvoked(player, skill.name, "defensive")
  player:broadcastSkillInvoke(skill.name)

  local to = room:getPlayerById(player:getMark("shichoul"))
  
  room:damage{
    from = data.from,
    to = to,
    damage = data.damage,
    damageType = data.damageType,
    skillName = data.skillName,
    chain = data.chain,
    card = data.card
  }
  
  if not to.dead then 
    to:drawCards(data.damage, skill.name)
  end
  
  return true
  end,
})

shichoul:addEffect(fk.EnterDying, {
  can_trigger = function(skill, event, target, player) 
  return player:getMark("shichoul") ~= 0 and 
       (target:getMark("@@shichoul") ~= 0 or (target == player and event == fk.Death))
  end,
  on_use = function(skill, event, target, player)
  local room = player.room
  local to = room:getPlayerById(player:getMark("shichoul"))
  
  room:setPlayerMark(target, "@@shichoul", 0)

  local mark = to:getTableMark("@@shichoul")
  table.removeOne(mark, player.id)
  
  if #mark == 0 then 
    mark = 0
  end
  
  room:setPlayerMark(to, "@@shichoul", mark)
  room:setPlayerMark(player, "shichoul", 0)
  end,
})

return shichoul