local zishu = fk.CreateSkill {
  name = "zishu"
}

Fk:loadTranslationTable{
  ['zishu'] = '自书',
  ['@@zishu-inhand'] = '自书',
  [':zishu'] = '锁定技，你的回合外，其他角色回合结束时，将你手牌中所有本回合获得的牌置入弃牌堆；你的回合内，当你不因此技能获得牌时，摸一张牌。',
  ['$zishu1'] = '慢着，让我来！',
  ['$zishu2'] = '身外之物，不要也罢！',
}

zishu:addEffect(fk.TurnEnd, {
  mute = true,
  frequency = Skill.Compulsory,
  can_trigger = function(skill, event, target, player)
    if player:hasSkill(zishu.name) then
      return target ~= player and table.find(player.player_cards[Player.Hand], function (id)
        return Fk:getCardById(id):getMark("@@zishu-inhand") > 0
      end)
    end
  end,
  on_use = function(skill, event, target, player)
    local room = player.room
    if event == fk.TurnEnd then
      player:broadcastSkillInvoke(zishu.name, 2)
      room:notifySkillInvoked(player, zishu.name, "negative")
      local cards = {}
      for _, id in ipairs(player:getCardIds(Player.Hand)) do
        if Fk:getCardById(id):getMark("@@zishu-inhand") > 0 then
          table.insert(cards, id)
        end
      end
      if #cards > 0 then
        room:moveCards({
          from = player.id,
          ids = cards,
          toArea = Card.DiscardPile,
          moveReason = fk.ReasonPutIntoDiscardPile,
          skill_name = zishu.name,
          proposer = player.id,
        })
      end
    end
  end,
})

zishu:addEffect(fk.AfterCardsMove, {
  mute = true,
  frequency = Skill.Compulsory,
  can_trigger = function(skill, event, target, player)
    if player:hasSkill(zishu.name) then
      if player.phase ~= Player.NotActive then
        for _, move in ipairs(data) do
          if move.to == player.id and move.toArea == Player.Hand and move.skill_name ~= zishu.name then
            return true
          end
        end
      end
    end
  end,
  on_use = function(skill, event, target, player)
    local room = player.room
    player:broadcastSkillInvoke(zishu.name, 1)
    room:notifySkillInvoked(player, zishu.name, "drawcard")
    player:drawCards(1, zishu.name)
  end,
})

zishu:addEffect(fk.AfterCardsMove, {
  can_refresh = function(skill, event, target, player)
    return player:hasSkill(zishu.name, true) and player.phase == Player.NotActive
  end,
  on_refresh = function(skill, event, target, player)
    local room = player.room
    for _, move in ipairs(data) do
      if move.to == player.id and move.toArea == Player.Hand then
        for _, info in ipairs(move.moveInfo) do
          local id = info.cardId
          if room:getCardArea(id) == Card.PlayerHand and room:getCardOwner(id) == player then
            room:setCardMark(Fk:getCardById(id), "@@zishu-inhand", 1)
          end
        end
      end
    end
  end,
})

zishu:addEffect(fk.AfterTurnEnd, {
  can_refresh = function(skill, event, target, player)
    return table.find(player.player_cards[Player.Hand], function (id)
      return Fk:getCardById(id):getMark("@@zishu-inhand") > 0
    end)
  end,
  on_refresh = function(skill, event, target, player)
    local room = player.room
    for _, id in ipairs(player:getCardIds(Player.Hand)) do
      room:setCardMark(Fk:getCardById(id), "@@zishu-inhand", 0)
    end
  end,
})

return zishu