local kangkai = fk.CreateSkill {
  name = "kangkai"
}

Fk:loadTranslationTable{
  ['kangkai'] = '慷忾',
  ['#kangkai-self'] = '慷忾：你可以摸一张牌',
  ['#kangkai-invoke'] = '慷忾：你可以摸一张牌，再交给 %dest 一张牌',
  ['#kangkai-give'] = '慷忾：选择一张牌交给 %dest',
  ['#kangkai-use'] = '慷忾：你可以使用%arg',
  [':kangkai'] = '当一名角色成为【杀】的目标后，若你与其的距离不大于1，你可以摸一张牌，若如此做，你先将一张牌交给该角色再令其展示之，若此牌为装备牌，其可以使用之。',
  ['$kangkai1'] = '典将军，比比看谁杀敌更多！',
  ['$kangkai2'] = '父亲快走，有我殿后！'
}

kangkai:addEffect(fk.TargetConfirmed, {
  can_trigger = function(self, event, target, player, data)
  return player:hasSkill(kangkai.name) and data.card.trueName == "slash" and (target == player or player:distanceTo(target) == 1)
  end,
  on_cost = function (self, event, target, player, data)
  local prompt = (player.id == data.to) and "#kangkai-self" or "#kangkai-invoke::"..data.to
  return player.room:askToSkillInvoke(player, {skill_name = kangkai.name, prompt = prompt})
  end,
  on_use = function(self, event, target, player, data)
  local room = player.room
  local to = room:getPlayerById(data.to)
  player:drawCards(1, kangkai.name)
  if player == to or player:isNude() or to.dead then return end
  local cards = room:askToCards(player, {
    min_num = 1,
    max_num = 1,
    pattern = ".",
    prompt = "#kangkai-give::"..to.id,
    skill_name = kangkai.name,
  })
  if #cards > 0 then
    room:moveCardTo(cards, Card.PlayerHand, to, fk.ReasonGive, kangkai.name, nil, true, player.id)
    to:showCards(cards)
    local card = Fk:getCardById(cards[1])
    if card.type == Card.TypeEquip and not to.dead and not to:isProhibited(to, card) and not to:prohibitUse(card) and
    table.contains(to:getCardIds("h"), cards[1]) and
    room:askToSkillInvoke(to, {skill_name = kangkai.name, prompt = "#kangkai-use:::"..card:toLogString()}) then
    room:useCard({
      from = to.id,
      tos = {{to.id}},
      card = card,
    })
    end
  end
  end,
})

return kangkai