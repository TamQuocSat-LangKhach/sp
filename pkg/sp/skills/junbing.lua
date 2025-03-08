local junbing = fk.CreateSkill {
  name = "junbing"
}

Fk:loadTranslationTable{
  ['junbing'] = '郡兵',
  ['#junbing-give'] = '郡兵：将%arg张手牌交给 %dest',
  [':junbing'] = '每名角色的结束阶段，若其手牌数小于或等于1，该角色可以摸一张牌，若该角色不是你，则其将所有手牌交给你，然后你将等量的手牌交给其。',
  ['$junbing1'] = '男儿慷慨，军中豪迈。',
  ['$junbing2'] = '郡国当有搜狩习战之备。',
}

junbing:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(skill, event, target, player, data)
    return player:hasSkill(junbing.name) and target.phase == Player.Finish and target:getHandcardNum() < 2
  end,
  on_cost = function(skill, event, target, player, data)
    return player.room:askToSkillInvoke(target, {skill_name = junbing.name})
  end,
  on_use = function(skill, event, target, player, data)
    local room = player.room
    room:drawCards(target, 1, junbing.name)
    if target == player or target.dead or player.dead or target:isKongcheng() then return false end
    local cards = target:getCardIds(Player.Hand)
    room:moveCardTo(cards, Player.Hand, player, fk.ReasonGive, junbing.name, nil, false, target.id)
    if target.dead or player.dead or player:isKongcheng() then return end
    local n = math.min(#cards, player:getHandcardNum())
    cards = room:askToCards(player, {
      min_num = n,
      max_num = n,
      include_equip = false,
      skill_name = junbing.name,
      cancelable = false,
      pattern = ".",
      prompt = "#junbing-give::"..target.id..":"..n
    })
    room:moveCardTo(cards, Player.Hand, target, fk.ReasonGive, junbing.name, nil, false, player.id)
  end,
})

return junbing