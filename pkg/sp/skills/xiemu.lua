local xiemu = fk.CreateSkill {
  name = "xiemu"
}

Fk:loadTranslationTable{
  ['xiemu'] = '协穆',
  ['#xiemu'] = '协穆：弃一张【杀】并选择一个势力，直到你下回合，该势力角色使用黑色牌指定你为目标后，你摸两张牌',
  ['@xiemu'] = '协穆',
  ['#xiemu_record'] = '协穆',
  [':xiemu'] = '出牌阶段限一次，你可以弃置一张【杀】并选择一个势力，然后直到你的下回合开始，该势力的其他角色使用的黑色牌指定目标后，若你是此牌的目标，你可以摸两张张牌。',
  ['$xiemu1'] = '休要再起战事。',
  ['$xiemu2'] = '暴戾之气，伤人害己。',
}

xiemu:addEffect('active', {
  anim_type = "drawcard",
  card_num = 1,
  target_num = 0,
  prompt = "#xiemu",
  can_use = function(self, player)
    return player:usedSkillTimes(xiemu.name) == 0 and not player:isKongcheng()
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).trueName == "slash" and not self:prohibitDiscard(Fk:getCardById(to_select))
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:throwCard(effect.cards, xiemu.name, player, player)
    local choices = {}
    for _, p in ipairs(room.alive_players) do
      local kingdom = getKingdom(p)
      if kingdom ~= "unknown" then
        table.insertIfNeed(choices, kingdom)
      end
    end
    local kingdom = room:askToChoice(player, {
      choices = choices,
      skill_name = xiemu.name,
    })
    room:setPlayerMark(player, "@xiemu", kingdom)
  end
})

xiemu:addEffect(fk.TargetConfirmed, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and not player.dead and player:getMark("@xiemu") ~= 0 and
      data.from ~= player.id and getKingdom(player.room:getPlayerById(data.from)) == player:getMark("@xiemu") and
      data.card.color == Card.Black
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(2, xiemu.name)
  end,
})

xiemu:addEffect(fk.TurnStart, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@xiemu") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@xiemu", 0)
  end,
})

return xiemu