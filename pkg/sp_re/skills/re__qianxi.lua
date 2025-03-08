local re__qianxi = fk.CreateSkill {
  name = "re__qianxi"
}

Fk:loadTranslationTable{
  ['re__qianxi'] = '潜袭',
  ['#qianxi-discard'] = '潜袭：弃置一张牌，令一名角色本回合不能使用或打出此颜色的手牌',
  [':re__qianxi'] = '准备阶段开始时，你可以摸一张牌然后弃置一张牌。若如此做，你选择距离为1的一名角色，然后直到回合结束，该角色不能使用或打出与你以此法弃置的牌颜色相同的手牌。',
}

re__qianxi:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player)
  return target == player and player:hasSkill(re__qianxi.name) and player.phase == Player.Start
  end,
  on_use = function(self, event, target, player)
  local room = player.room
  player:drawCards(1, re__qianxi.name)
  local card = room:askToDiscard(player, {
    min_num = 1,
    max_num = 1,
    include_equip = true,
    skill_name = re__qianxi.name,
    cancelable = false,
    pattern = ".",
    prompt = "#qianxi-discard"
  })
  local targets = {}
  for _, p in ipairs(room:getOtherPlayers(player)) do
    if player:distanceTo(p) == 1 then
    table.insert(targets, p)
    end
  end
  if #targets == 0 then return end
  local tos = room:askToChoosePlayers(player, {
    targets = targets,
    min_num = 1,
    max_num = 1,
    prompt = "#qianxi-choose",
    skill_name = re__qianxi.name,
    cancelable = false
  })
  room:setPlayerMark(room:getPlayerById(tos[1].id), "@qianxi-turn", Fk:getCardById(card[1]):getColorString())
  end,
})

re__qianxi:addEffect('prohibit', {
  prohibit_use = function(self, player, card)
  return player:getMark("@qianxi-turn") ~= 0 and card:getColorString() == player:getMark("@qianxi-turn")
  end,
  prohibit_response = function(self, player, card)
  return player:getMark("@qianxi-turn") ~= 0 and card:getColorString() == player:getMark("@qianxi-turn")
  end,
})

return re__qianxi