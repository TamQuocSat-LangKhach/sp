local mingzhe = fk.CreateSkill {
  name = "mingzhe"
}

Fk:loadTranslationTable{
  ['mingzhe'] = '明哲',
  [':mingzhe'] = '当你于回合外使用、打出或因弃置而失去一张红色牌时，你可以摸一张牌。',
  ['$mingzhe1'] = '明以洞察，哲以保身。',
  ['$mingzhe2'] = '塞翁失马，焉知非福？',
}

mingzhe:addEffect(fk.CardUsing, {
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(mingzhe) and player.phase == Player.NotActive then
    return player == target and data.card.color == Card.Red
    end
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askToSkillInvoke(player, { skill_name = mingzhe.name }) then
    return true
    end
    skill.cancel_cost = true
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, mingzhe.name)
  end,
})

mingzhe:addEffect(fk.CardResponding, {
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(mingzhe) and player.phase == Player.NotActive then
    return player == target and data.card.color == Card.Red
    end
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askToSkillInvoke(player, { skill_name = mingzhe.name }) then
    return true
    end
    skill.cancel_cost = true
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, mingzhe.name)
  end,
})

mingzhe:addEffect(fk.AfterCardsMove, {
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(mingzhe) and player.phase == Player.NotActive then
    for _, move in ipairs(data) do
      if move.from == player.id and move.moveReason == fk.ReasonDiscard then
      for _, info in ipairs(move.moveInfo) do
        if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
         Fk:getCardById(info.cardId).color == Card.Red then
        return true
        end
      end
      end
    end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    local x = 1
    for _, move in ipairs(data) do
    if move.from == player.id and move.moveReason == fk.ReasonDiscard then
      for _, info in ipairs(move.moveInfo) do
      if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
         Fk:getCardById(info.cardId).color == Card.Red then
        x = x + 1
      end
      end
    end
    end

    local ret
    for _ = 1, x do
    if skill.cancel_cost or not player:hasSkill(mingzhe) then
      skill.cancel_cost = false
      break
    end
    ret = skill:doCost(event, target, player, data)
    if ret then return ret end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askToSkillInvoke(player, { skill_name = mingzhe.name }) then
    return true
    end
    skill.cancel_cost = true
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, mingzhe.name)
  end,
})

return mingzhe