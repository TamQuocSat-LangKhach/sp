local yingyuan = fk.CreateSkill {
  name = "yingyuan",
}

Fk:loadTranslationTable{
  ["yingyuan"] = "应援",
  [":yingyuan"] = "当你于回合内使用的牌结算完毕置入弃牌堆时，你可以将之交给一名其他角色（每回合每种牌名限一次）。",

  ["#yingyuan-card"] = "应援：你可以将 %arg 交给一名其他角色",

  ["$yingyuan1"] = "接好嘞！",
  ["$yingyuan2"] = "好牌只用一次怎么够？",
}

yingyuan:addEffect(fk.CardUseFinished, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yingyuan.name) and player.room.current == player and
      player.room:getCardArea(data.card) == Card.Processing and
      not table.contains(player:getTableMark("yingyuan-turn"), data.card.trueName) and
      #player.room:getOtherPlayers(player, false) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      skill_name = yingyuan.name,
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player, false),
      prompt = "#yingyuan-card:::"..data.card:toLogString(),
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addTableMark(player, "yingyuan-turn", data.card.trueName)
    local to = event:getCostData(self).tos[1]
    room:moveCardTo(data.card, Card.PlayerHand, to, fk.ReasonGive, yingyuan.name, nil, true, player)
  end,
})

return yingyuan
