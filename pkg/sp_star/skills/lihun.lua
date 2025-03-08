```lua
local lihun = fk.CreateSkill {
  name = "lihun"
}

Fk:loadTranslationTable{
  ['lihun'] = '离魂',
  ['#lihun'] = '离魂：弃一张牌并翻面，获得一名角色所有手牌，本阶段结束时交给其体力值的牌',
  ['#lihun-give'] = '离魂：你需交还 %dest %arg张牌',
  [':lihun'] = '出牌阶段限一次，你可以弃置一张牌并将你的武将牌翻面，若如此做，指定一名男性角色，获得其所有手牌。出牌阶段结束时，你须为该角色的每一点体力分配给其一张牌。',
  ['$lihun1'] = '将军~这些都赏给妾身好不好嘛~',
  ['$lihun2'] = '这些人家不喜欢嘛~还给你吧~',
}

-- 主动技能效果
lihun:addEffect('active', {
  mute = true,
  card_num = 1,
  target_num = 1,
  prompt = "#lihun",
  can_use = function(self, player)
    return player:usedSkillTimes(lihun.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and not player:prohibitDiscard(Fk:getCardById(to_select))
  end,
  target_filter = function(self, player, to_select, selected, cards)
    local target = Fk:currentRoom():getPlayerById(to_select)
    return #selected == 0 and #cards == 1 and
      not target:isKongcheng() and (target:isMale())
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    player:broadcastSkillInvoke(lihun.name, 1)
    room:notifySkillInvoked(player, lihun.name, "control")
    room:addTableMarkIfNeed(player, "lihun-phase", target.id)
    room:throwCard(effect.cards, lihun.name, player, player)
    if player.dead then return end
    player:turnOver()
    if player.dead or target.dead or target:isKongcheng() then return end
    room:moveCardTo(target:getCardIds("h"), Card.PlayerHand, player, fk.ReasonPrey, lihun.name, nil, false, player.id)
  end,
})

-- 触发技能效果
lihun:addEffect('trigger', {
  mute = true,
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    return target == player and player.phase == Player.Play and player:getMark("lihun-phase") ~= 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(lihun.name, 2)
    room:notifySkillInvoked(player, lihun.name, "control")
    local mark = player:getMark("lihun-phase")
    room:sortPlayersByAction(mark)
    for _, id in ipairs(mark) do
      if player.dead or player:isNude() then return end
      local to = room:getPlayerById(id)
      if not to.dead then
        local cards = player:getCardIds("he")
        local n = to.hp
        if n < #cards then
          cards = room:askToDiscard(player, {
            min_num = n,
            max_num = n,
            include_equip = true,
            skill_name = "lihun",
            cancelable = false,
            prompt = "#lihun-give::"..to.id..":"..n
          })
        end
        room:moveCardTo(cards, Card.PlayerHand, to, fk.ReasonGive, lihun.name, nil, false, player.id)
      end
    end
  end,
})

return lihun
```