local kangkai = fk.CreateSkill {
  name = "kangkai",
}

Fk:loadTranslationTable{
  ["kangkai"] = "慷忾",
  [":kangkai"] = "当一名角色成为【杀】的目标后，若你与其距离不大于1，你可以摸一张牌，然后将一张牌交给该角色并令其展示之，若为装备牌，其可以使用之。",

  ["#kangkai-self"] = "慷忾：你可以摸一张牌",
  ["#kangkai-invoke"] = "慷忾：你可以摸一张牌，然后交给 %dest 一张牌",
  ["#kangkai-give"] = "慷忾：交给 %dest 一张牌，若为装备牌其可以使用",
  ["#kangkai-use"] = "慷忾：你可以使用%arg",

  ["$kangkai1"] = "典将军，比比看谁杀敌更多！",
  ["$kangkai2"] = "父亲快走，有我殿后！"
}

kangkai:addEffect(fk.TargetConfirmed, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(kangkai.name) and data.card.trueName == "slash" and player:distanceTo(target) <= 1
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if target == player then
      return room:askToSkillInvoke(player, {
        skill_name = kangkai.name,
        prompt = "#kangkai-self",
      })
    elseif room:askToSkillInvoke(player, {
      skill_name = kangkai.name,
      prompt = "#kangkai-invoke::"..target.id,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1, kangkai.name)
    if target == player or player:isNude() or player.dead or target.dead then return end
    local cards = room:askToCards(player, {
      skill_name = kangkai.name,
      min_num = 1,
      max_num = 1,
      prompt = "#kangkai-give::"..target.id,
      cancelable = true,
    })
    if #cards > 0 then
      room:moveCardTo(cards, Card.PlayerHand, target, fk.ReasonGive, kangkai.name, nil, true, player)
      if not table.contains(target:getCardIds("h"), cards[1]) or target.dead then return end
      target:showCards(cards)
      if not table.contains(target:getCardIds("h"), cards[1]) or target.dead then return end
      local card = Fk:getCardById(cards[1])
      if card.type == Card.TypeEquip and not target:isProhibited(target, card) and not target:prohibitUse(card) and
        room:askToSkillInvoke(target, {
          skill_name = kangkai.name,
          prompt = "#kangkai-use:::"..card:toLogString(),
        }) then
        room:useCard({
          from = target,
          tos = {target},
          card = card,
        })
      end
    end
  end,
})

return kangkai
