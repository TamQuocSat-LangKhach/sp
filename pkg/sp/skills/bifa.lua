```lua
local bifa = fk.CreateSkill {
  name = "bifa"
}

Fk:loadTranslationTable{
  ['bifa'] = '笔伐',
  ['$bifa'] = '笔伐',
  ['#bifa-cost'] = '笔伐：将一张手牌移出游戏并指定一名其他角色',
  ['#bifa-invoke'] = '笔伐：交给 %src 一张 %arg 并获得%arg2；或点“取消”将此牌置入弃牌堆并失去1点体力',
  [':bifa'] = '结束阶段开始时，你可以将一张手牌移出游戏并指定一名其他角色。该角色的回合开始时，其观看你移出游戏的牌并选择一项：交给你一张与此牌同类型的手牌并获得此牌；或将此牌置入弃牌堆，然后失去1点体力。',
  ['$bifa1'] = '笔墨纸砚，皆兵器也！',
  ['$bifa2'] = '汝德行败坏，人所不齿也！',
}

bifa:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player)
    return target == player and player:hasSkill(bifa.name) and player.phase == Player.Finish and not player:isKongcheng() and
      table.find(player.room:getOtherPlayers(player, false), function(p) return #p:getPile("$bifa") == 0 end)
  end,
  on_cost = function(self, event, target, player)
    local targets = table.map(table.filter(player.room:getOtherPlayers(player, false), function(p)
      return #p:getPile("$bifa") == 0
    end), Util.IdMapper)
    local tos, id = player.room:askToChooseCardsAndPlayers(player, {
      min_card_num = 1,
      max_card_num = 1,
      targets = targets,
      pattern = ".|.|.|hand",
      prompt = "#bifa-cost",
      skill_name = bifa.name,
    })
    if #tos > 0 then
      event:setCostData(self, {tos = tos, cards = {id}})
      return true
    end
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    local to = room:getPlayerById(event:getCostData(self).tos[1])
    room:setPlayerMark(player, "bifa_to", to.id)
    to:addToPile("$bifa", event:getCostData(self).cards, false, bifa.name, player.id, {})
  end,
})

bifa:addEffect('visibility', {
  name = '#bifa_visible',
  card_visible = function(self, player, card)
    if player:getPileNameOfId(card.id) == "$bifa" then
      return false
    end
  end
})

bifa:addEffect(fk.TurnStart, {
  name = "#bifa_trigger",
  mute = true,
  can_trigger = function(self, event, target, player)
    return target == player and #player:getPile("$bifa") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player)
    local room = player.room
    local src = table.find(room.alive_players, function (p)
      return p:getMark("bifa_to") == player.id
    end)
    if src == nil or player:isKongcheng() then
      room:loseHp(player, 1, "bifa")
      room:moveCards({
        from = player.id,
        ids = player:getPile("$bifa"),
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonPutIntoDiscardPile,
        skillName = "bifa",
      })
      return
    end
    src:broadcastSkillInvoke("bifa")
    room:notifySkillInvoked(src, "bifa", "control")
    room:doIndicate(src.id, {player.id})
    room:setPlayerMark(src, "bifa_to", 0)
    local card = Fk:getCardById(player:getPile("$bifa")[1])
    local type = card:getTypeString()
    local give = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      pattern = ".|.|.|hand|.|"..type,
      prompt = "#bifa-invoke:"..src.id.."::"..type..":"..card:toLogString(),
      skill_name = "bifa",
    })
    if #give > 0 then
      room:moveCardTo(give, Card.PlayerHand, src, fk.ReasonGive, "bifa", nil, false, player.id)
      if not player.dead and #player:getPile("$bifa") > 0 then
        room:moveCardTo(player:getPile("$bifa"), Card.PlayerHand, player, fk.ReasonPrey, "bifa", nil, false, player.id)
      end
    else
      room:moveCards({
        from = player.id,
        ids = player:getPile("$bifa"),
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonPutIntoDiscardPile,
        skillName = "bifa",
      })
      if not player.dead then
        room:loseHp(player, 1, "bifa")
      end
    end
  end,
})

return bifa
```