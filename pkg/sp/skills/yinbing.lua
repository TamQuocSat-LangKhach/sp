local yinbing = fk.CreateSkill {
  name = "yinbing"
}

Fk:loadTranslationTable{
  ['yinbing'] = '引兵',
  ['$yinbing'] = '引兵',
  ['#yinbing-cost'] = '引兵：你可以将任意张非基本牌置于你的武将牌上',
  ['#yingbing-remove'] = '引兵：你需移去一张“引兵”牌',
  [':yinbing'] = '结束阶段，你可以将任意张非基本牌置于你的武将牌上，当你受到【杀】或【决斗】造成的伤害后，你移去你武将牌上的一张牌。',
  ['$yinbing1'] = '追兵凶猛，末将断后！',
  ['$yinbing2'] = '将军走此小道，追兵交我应付！'
}

yinbing:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  expand_pile = "yinbing",
  derived_piles = "$yinbing",
  can_trigger = function(self, event, target, player)
    return target == player and player.phase == Player.Finish and not player:isNude()
  end,
  on_cost = function(self, event, target, player)
    local room = player.room
    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = 999,
      include_equip = true,
      pattern = ".|.|.|.|.|trick,equip",
      prompt = "#yinbing-cost"
    })
    if #cards > 0 then
      event:setCostData(self, cards)
      return true
    end
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    player:addToPile("$yinbing", event:getCostData(self), false, yinbing.name)
  end,
})

yinbing:addEffect(fk.Damaged, {
  anim_type = "control",
  expand_pile = "yinbing",
  derived_piles = "$yinbing",
  can_trigger = function(self, event, target, player, data)
    return target == player and #player:getPile("$yinbing") > 0 and data.card and
      (data.card.trueName == "slash" or data.card.name == "duel")
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    local card = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      pattern = ".|.|.|$yinbing",
      prompt = "#yingbing-remove"
    })
    room:moveCardTo(card[1], Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, yinbing.name, nil, true, player.id)
  end,
})

return yinbing