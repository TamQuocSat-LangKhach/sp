local danlao = fk.CreateSkill {
  name = "danlao"
}

Fk:loadTranslationTable{
  ['danlao'] = '啖酪',
  [':danlao'] = '当一个锦囊指定了包括你在内的多个目标，你可以摸一张牌，若如此做，该锦囊对你无效。',
  ['$danlao1'] = '来来，一人一口！',
  ['$danlao2'] = '我喜欢！',
}

danlao:addEffect(fk.TargetConfirmed, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(danlao.name) and data.card.type == Card.TypeTrick and #AimGroup:getAllTargets(data.tos) > 1
  end,
  on_use = function(self, event, target, player, data)
    table.insertIfNeed(data.nullifiedTargets, player.id)
    player:drawCards(1, danlao.name)
  end,
})

return danlao