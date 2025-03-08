local zhenwei = fk.CreateSkill {
  name = "zhenwei"
}

Fk:loadTranslationTable{
  ['zhenwei'] = '镇卫',
  ['#zhenwei-invoke'] = '%src对%dest使用%arg，是否弃置一张牌来发动 镇卫',
  ['zhenwei_transfer'] = '摸一张牌并将此牌转移给你',
  ['zhenwei_recycle'] = '取消此牌，回合结束时使用者将之收回',
  ['#zhenwei_delay'] = '镇卫',
  [':zhenwei'] = '当一名其他角色成为【杀】或黑色锦囊牌的唯一目标时，若该角色的体力值小于你，你可以弃置一张牌并选择一项：摸一张牌，然后你成为此牌的目标；或令此牌失效并将之移出游戏，该回合结束时令此牌的使用者收回此牌。',
  ['$zhenwei1'] = '再敢来犯，仍叫你无功而返！',
  ['$zhenwei2'] = '江夏防线，固若金汤！',
}

zhenwei:addEffect(fk.TargetConfirming, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(zhenwei) and not player:isNude() and data.from ~= player.id and
         (data.card.trueName == "slash" or (data.card.type == Card.TypeTrick and data.card.color == Card.Black)) and
         U.isOnlyTarget(target, data, event) and target.hp < player.hp
  end,
  on_cost = function(self, event, target, player, data)
    local cards = player.room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = zhenwei.name,
      cancelable = true,
      pattern = ".",
      prompt = "#zhenwei-invoke:" .. data.from .. ":" .. data.to .. ":" .. data.card:toLogString()
    })
    if #cards > 0 then
      event:setCostData(self, cards)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(event:getCostData(self), zhenwei.name, player, player)
    if player.dead then return false end
    local choice = room:askToChoice(player, {
      choices = {"zhenwei_transfer", "zhenwei_recycle"},
      skill_name = zhenwei.name,
    })
    if choice == "zhenwei_transfer" then
      room:drawCards(player, 1, zhenwei.name)
      if player.dead then return false end
      if U.canTransferTarget(player, data) then
        local targets = {player.id}
        if type(data.subTargets) == "table" then
          table.insertTable(targets, data.subTargets)
        end
        AimGroup:addTargets(room, data, targets)
        AimGroup:cancelTarget(data, target.id)
        return true
      end
    else
      data.tos = AimGroup:initAimGroup({})
      data.targetGroup = {}
      local use_from = room:getPlayerById(data.from)
      if not use_from.dead and U.hasFullRealCard(room, data.card) then
        use_from:addToPile(zhenwei.name, data.card, true, zhenwei.name)
      end
      return true
    end
  end,
})

zhenwei:addEffect(fk.TurnEnd, {
  name = "#zhenwei_delay",
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return #player:getPile("zhenwei") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:moveCardTo(player:getPile("zhenwei"), Card.PlayerHand, player, fk.ReasonJustMove, "zhenwei", nil, true, player.id)
  end,
})

return zhenwei