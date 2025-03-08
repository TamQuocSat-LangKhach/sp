local dahe = fk.CreateSkill {
  name = "dahe"
}

Fk:loadTranslationTable{
  ['dahe'] = '大喝',
  ['#dahe-prompt'] = '大喝：你可以拼点，若你赢，其本回合非<font color=>♥</font>【闪】无效，若没赢你须弃牌',
  ['@@dahe-turn'] = '被大喝',
  ['#dahe-choose'] = '大喝：你可以将%arg交给一名角色',
  ['#dahe_trigger'] = '大喝',
  [':dahe'] = '出牌阶段，你可以与一名其他角色拼点；若你赢，该角色的非<font color=>♥</font>【闪】无效直到回合结束，你可以将该角色拼点的牌交给场上一名体力不多于你的角色。若你没赢，你须展示手牌并选择一张弃置。每阶段限一次。',
}

dahe:addEffect('active', {
  anim_type = "offensive",
  card_num = 0,
  target_num = 1,
  prompt = "#dahe-prompt",
  can_use = function(self, player)
  return not player:isKongcheng() and player:usedSkillTimes(dahe.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
  return #selected == 0 and player:canPindian(Fk:currentRoom():getPlayerById(to_select))
  end,
  on_use = function(self, room, effect)
  local player = room:getPlayerById(effect.from)
  local target = room:getPlayerById(effect.tos[1])
  local pindian = player:pindian({target}, dahe.name)
  if pindian.results[target.id].winner == player then
    room:setPlayerMark(target, "@@dahe-turn", 1)
    local card = pindian.results[target.id].toCard
    if room:getCardArea(card) == Card.DiscardPile then
    local to = room:askToChoosePlayers(player, {
      targets = table.map(table.filter(room.alive_players, function(p)
      return player.hp >= p.hp end), Util.IdMapper),
      min_num = 1,
      max_num = 1,
      prompt = "#dahe-choose:::"..card:toLogString(),
      skill_name = dahe.name,
      cancelable = true
    })
    if #to > 0 then
      room:obtainCard(to[1], card, true, fk.ReasonGive, player.id, dahe.name)
    end
    end
  else
    if not player:isKongcheng() then
    player:showCards(player.player_cards[Player.Hand])
    room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = dahe.name,
      cancelable = false
    })
    end
  end
  end,
})

dahe:addEffect(fk.PreCardEffect, {
  can_trigger = function(self, event, target, player, data)
  return target == player and player:getMark("@@dahe-turn") > 0 and data.card.name == "jink" and data.card.suit ~= Card.Heart
  end,
  on_cost = Util.TrueFunc,
  on_use = Util.TrueFunc,
})

return dahe