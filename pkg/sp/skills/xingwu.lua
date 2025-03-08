local xingwu = fk.CreateSkill {
  name = "xingwu"
}

Fk:loadTranslationTable{
  ['xingwu'] = '星舞',
  ['#xingwu-cost'] = '星舞：你可以将一张与你本回合使用的牌颜色均不同的手牌置为“星舞”牌',
  ['#xingwu-choose'] = '星舞：对一名男性角色造成2点伤害并弃置其装备区所有牌',
  [':xingwu'] = '弃牌阶段开始时，你可以将一张与你本回合使用的牌颜色均不同的手牌置于武将牌上。若此时你武将牌上的牌达到三张，则弃置这些牌，然后对一名男性角色造成2点伤害并弃置其装备区中的所有牌。',
  ['$xingwu1'] = '哼，不要小瞧女孩子哦！',
  ['$xingwu2'] = '姐妹齐心，其利断金。',
}

xingwu:addEffect(fk.EventPhaseStart, {
  global = false,
  can_trigger = function(self, event, target, player)
    return target == player and player:hasSkill(xingwu) and player.phase == Player.Discard and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player)
    local colors = player:getMark("xingwu-turn")
    if type(colors) ~= "table" then
      colors = {}
    end
    local pattern = "."
    if #colors == 2 then
      return
    elseif #colors == 1 then
      if colors[1] == Card.Black then
        pattern = ".|.|heart,diamond"
      else
        pattern = ".|.|spade,club"
      end
    end
    local card = player.room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = xingwu.name,
      cancelable = true,
      pattern = pattern,
      prompt = "#xingwu-cost"
    })
    if #card > 0 then
      event:setCostData(self, card)
      return true
    end
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    player:addToPile(xingwu.name, event:getCostData(self), true, xingwu.name)
    if #player:getPile(xingwu.name) >= 3 then
      room:moveCards({
        from = player.id,
        ids = player:getPile(xingwu.name),
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonPutIntoDiscardPile,
        skillName = xingwu.name,
      })
      local targets = table.filter(room:getOtherPlayers(player), function(p)
        return p:isMale()
      end)
      if #targets > 0 then
        local to = room:askToChoosePlayers(player, {
          min_num = 1,
          max_num = 1,
          prompt = "#xingwu-choose",
          skill_name = xingwu.name,
          cancelable = false,
          targets = targets
        })
        local victim = room:getPlayerById(to[1])
        room:damage{
          from = player,
          to = victim,
          damage = 2,
          skillName = xingwu.name,
        }
        victim:throwAllCards("e")
      end
    end
  end,
})

xingwu:addEffect(fk.CardUsing, {
  global = false,
  can_refresh = function(self, event, target, player)
    return player:hasSkill(xingwu, true) and target == player and player.phase ~= Player.NotActive
  end,
  on_refresh = function(self, event, target, player)
    local colors = player:getMark("xingwu-turn")
    if type(colors) ~= "table" then
      colors = {}
    end
    if data.card.color ~= Card.NoColor then
      table.insertIfNeed(colors, data.card.color)
    end
    player.room:setPlayerMark(player, "xingwu-turn", colors)
  end,
})

return xingwu