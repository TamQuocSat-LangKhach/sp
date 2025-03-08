local anxian = fk.CreateSkill {
  name = "anxian"
}

Fk:loadTranslationTable{
  ['anxian'] = '安娴',
  ['#anxian1-invoke'] = '安娴：你可以防止对 %dest 造成的伤害，其弃置一张手牌，你摸一张牌',
  ['#anxian2-invoke'] = '安娴：你可以弃置一张手牌令%arg对你无效，%dest 摸一张牌',
  [':anxian'] = '每当你使用【杀】对目标角色造成伤害时，你可以防止此次伤害，令其弃置一张手牌，然后你摸一张牌；当你成为【杀】的目标时，你可以弃置一张手牌使之无效，然后该【杀】的使用者摸一张牌。',
}

anxian:addEffect(fk.DamageCaused, {
  can_trigger = function(self, event, target, player, data)
  if target == player and player:hasSkill(anxian) and data.card and data.card.trueName == "slash" then
    return not data.chain
  end
  end,
  on_cost = function(self, event, target, player, data)
  return player.room:askToSkillInvoke(player, {
    skill_name = anxian.name,
    prompt = "#anxian1-invoke::"..data.to.id
  })
  end,
  on_use = function(self, event, target, player, data)
  local room = player.room
  if event == fk.DamageCaused then
    player:broadcastSkillInvoke(anxian.name, 1)
    room:notifySkillInvoked(player, anxian.name, "control")
    if not data.to:isKongcheng() then
    room:askToDiscard(data.to, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = anxian.name,
      cancelable = false
    })
    end
    player:drawCards(1, anxian.name)
    return true
  end
  end,
})

anxian:addEffect(fk.TargetConfirming, {
  can_trigger = function(self, event, target, player, data)
  if target == player and player:hasSkill(anxian) and data.card and data.card.trueName == "slash" then
    return not player:isKongcheng()
  end
  end,
  on_cost = function(self, event, target, player, data)
  local card = player.room:askToDiscard(player, {
    min_num = 1,
    max_num = 1,
    include_equip = false,
    skill_name = anxian.name,
    cancelable = true,
    prompt = "#anxian2-invoke::"..data.from..":"..data.card:toLogString(),
  })
  if #card > 0 then
    event:setCostData(self, card)
    return true
  end
  end,
  on_use = function(self, event, target, player, data)
  local room = player.room
  player:broadcastSkillInvoke(anxian.name, 2)
  room:notifySkillInvoked(player, anxian.name, "defensive")
  table.insertIfNeed(data.nullifiedTargets, player.id)
  room:throwCard(event:getCostData(self), anxian.name, player, player)
  room:getPlayerById(data.from):drawCards(1, anxian.name)
  end,
})

return anxian