local yingyuan = fk.CreateSkill {
  name = "yingyuan"
}

Fk:loadTranslationTable{
  ['yingyuan'] = '应援',
  ['#yingyuan-card'] = '应援：你可以将 %arg 交给一名其他角色',
  [':yingyuan'] = '当你于回合内使用的牌结算完毕置入弃牌堆时，你可以将之交给一名其他角色（每回合每种牌名限一次）。',
  ['$yingyuan1'] = '接好嘞！',
  ['$yingyuan2'] = '好牌只用一次怎么够？',
}

yingyuan:addEffect(fk.CardUseFinished, {
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(yingyuan.name) and player.phase == Player.Play then
      local mark = player:getMark("yingyuan-turn")
      if type(mark) ~= "table" or not table.contains(mark, data.card.trueName) then
        local cardlist = data.card:isVirtual() and data.card.subcards or {data.card.id}
        local room = player.room
        return #cardlist > 0 and table.every(cardlist, function (id)
          return room:getCardArea(id) == Card.Processing
        end)
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local to = player.room:askToChoosePlayers(player, {
      targets = table.map(player.room:getOtherPlayers(player), Util.IdMapper),
      min_num = 1,
      max_num = 1,
      prompt = "#yingyuan-card:::"..data.card:toLogString(),
      skill_name = yingyuan.name,
      cancelable = true
    })
    if #to > 0 then
      event:setCostData(self, to[1])
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = room:getSubcardsByRule(data.card, { Card.Processing })
    local to = room:getPlayerById(event:getCostData(self))
    room:moveCardTo(cards, Card.PlayerHand, to, fk.ReasonGive, yingyuan.name, nil, true, player.id)
    if not player.dead then
      room:addTableMark(player, "yingyuan-turn", data.card.trueName)
    end
  end,
})

return yingyuan