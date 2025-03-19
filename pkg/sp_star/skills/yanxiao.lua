local yanxiao = fk.CreateSkill {
  name = "yanxiao"
}

Fk:loadTranslationTable{
  ['yanxiao'] = '言笑',
  ['#yanxiao'] = '言笑：将一张<font color=>♦</font>置入一名角色判定区，其判定阶段开始时获得判定区内所有牌',
  [':yanxiao'] = '出牌阶段，你可以将一张<font color=>♦</font>牌置于一名角色的判定区内，判定区内有“言笑”牌的角色下个判定阶段开始时，获得其判定区里的所有牌。',
}

yanxiao:addEffect('active', {
  anim_type = "support",
  card_num = 1,
  target_num = 1,
  prompt = "#yanxiao",
  can_use = function(self, player)
  return not player:isNude()
  end,
  card_filter = function(self, player, to_select, selected)
  return #selected == 0 and Fk:getCardById(to_select).suit == Card.Diamond
  end,
  target_filter = function(self, player, to_select, selected)
  return #selected == 0 and not Fk:currentRoom():getPlayerById(to_select):hasDelayedTrick("yanxiao_trick")
  end,
  on_use = function(self, room, effect)
  local target = room:getPlayerById(effect.tos[1])
  local card = Fk:cloneCard("yanxiao_trick")
  card:addSubcards(effect.cards)
  target:addVirtualEquip(card)
  room:moveCardTo(card, Card.PlayerJudge, target, fk.ReasonPut, { skill_name = yanxiao.name })
  end,
})

yanxiao:addEffect(fk.EventPhaseStart, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
  return player.phase == Player.Judge and player:hasDelayedTrick("yanxiao_trick")
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
  player.room:obtainCard(player.id, player:getCardIds(Player.Judge), true, fk.ReasonPrey)
  end,
})

return yanxiao