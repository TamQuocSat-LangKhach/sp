local chenqing = fk.CreateSkill {
  name = "chenqing"
}

Fk:loadTranslationTable{
  ['chenqing'] = '陈情',
  ['#chenqing-choose'] = '陈情：令一名其他角色摸四张牌然后弃四张牌，若花色各不相同视为对濒死角色使用【桃】',
  ['#chenqing-discard'] = '陈情：需弃置四张牌，若花色各不相同则视为对濒死角色使用【桃】',
  [':chenqing'] = '每轮限一次，当一名角色进入濒死状态时，你可以令另一名其他角色摸四张牌，然后弃置四张牌，若其以此法弃置的四张牌的花色各不相同，则其视为对濒死状态的角色使用一张【桃】。',
  ['$chenqing1'] = '陈生死离别之苦，悲乱世之跌宕。',
  ['$chenqing2'] = '乱世陈情，字字血泪！',
}

chenqing:addEffect(fk.EnterDying, {
  anim_type = "support",
  can_trigger = function(skill, event, target, player)
    return player:hasSkill(skill.name) and player:usedSkillTimes(chenqing.name, Player.HistoryRound) == 0 and
         not table.every(player.room.alive_players, function (p)
           return p == player or p == target
         end)
  end,
  on_cost = function(skill, event, target, player)
    local room = player.room
    local targets = {}
    for _, p in ipairs(room.alive_players) do
      if p ~= target and p ~= player then
        table.insert(targets, p.id)
      end
    end
    if #targets == 0 then return end
    local to = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#chenqing-choose",
      skill_name = chenqing.name,
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(skill, to[1].id)
      return true
    end
  end,
  on_use = function(skill, event, target, player)
    local room = player.room
    local to = room:getPlayerById(event:getCostData(skill))
    to:drawCards(4, chenqing.name)
    if to.dead then return end
    local cards = room:askToDiscard(to, {
      min_num = 4,
      max_num = 4,
      include_equip = true,
      skill_name = chenqing.name,
      cancelable = false,
      prompt = "#chenqing-discard",
      skip = true,
    })
    local suits = {}
    for _, id in ipairs(cards) do
      if Fk:getCardById(id).suit ~= Card.NoSuit then
        table.insertIfNeed(suits, Fk:getCardById(id).suit)
      end
    end
    room:throwCard(cards, chenqing.name, to, to)
    if #suits == 4 and not target.dead then
      room:useVirtualCard("peach", nil, to, target, chenqing.name)
    end
  end,
})

return chenqing