local mumu = fk.CreateSkill {
  name = "mumu"
}

Fk:loadTranslationTable{
  ['mumu'] = '穆穆',
  ['#mumu-choose'] = '穆穆：选择一名角色，弃置其武器牌并摸一张牌；或将其的防具牌移动到你的装备区',
  ['#mumu-card'] = '穆穆：弃置武器牌，或将防具牌移动到你的装备区',
  [':mumu'] = '若你于出牌阶段内未造成伤害，则此回合的结束阶段开始时，你可以选择一项：弃置场上一张武器牌，然后摸一张牌；或将场上一张防具牌移动到你的装备区里（可替换原防具）。',
  ['$mumu1'] = '立储乃国家大事，我们姐妹不便参与。',
  ['$mumu2'] = '只求相夫教子，不求参政议事。',
}

mumu:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player)
  if target == player and player:hasSkill(mumu.name) and player.phase == Player.Finish then
    local play_ids = {}
    player.room.logic:getEventsOfScope(GameEvent.Phase, 1, function (e)
    if e.data[2] == Player.Play and e.end_id then
      table.insert(play_ids, {e.id, e.end_id})
    end
    return false
    end, Player.HistoryTurn)
    if #play_ids == 0 then return true end
    return #player.room.logic:getActualDamageEvents(1, function(e)
    if e.data[1].from == player then
      for _, ids in ipairs(play_ids) do
      if e.id > ids[1] and e.id < ids[2] then
        return true
      end
      end
    end
    end) == 0
  end
  end,
  on_cost = function(self, event, target, player)
  local targets = {}
  for _, p in ipairs(player.room:getAlivePlayers()) do
    if #p:getEquipments(Card.SubtypeWeapon) > 0 or (#p:getEquipments(Card.SubtypeArmor) > 0 and p ~= player and
    #player:getAvailableEquipSlots(Card.SubtypeArmor) > 0) then
    table.insert(targets, p.id)
    end
  end
  if #targets == 0 then return end
  local to = player.room:askToChoosePlayers(player, {
    targets = Fk:findPlayerByIds(targets),
    min_num = 1,
    max_num = 1,
    skill_name = mumu.name,
    prompt = "#mumu-choose",
  })
  if #to > 0 then
    event:setCostData(self, {tos = to})
    return true
  end
  end,
  on_use = function(self, event, target, player)
  local room = player.room
  local to = room:getPlayerById(event:getCostData(self).tos[1])
  local card_data = {}
  if #to:getEquipments(Card.SubtypeWeapon) > 0 then
    table.insert(card_data, {"weapon", to:getEquipments(Card.SubtypeWeapon)})
  end
  if to ~= player and #to:getEquipments(Card.SubtypeArmor) > 0 and #player:getAvailableEquipSlots(Card.SubtypeArmor) > 0 then
    table.insert(card_data, {"armor", to:getEquipments(Card.SubtypeArmor)})
  end
  if #card_data == 0 then return end
  local id = room:askToChooseCard(player, {
    target = player,
    flag = { card_data = card_data },
    skill_name = mumu.name,
    prompt = "#mumu-card",
  })
  if Fk:getCardById(id).sub_type == Card.SubtypeWeapon then
    room:throwCard({id}, mumu.name, to, player)
    if not player.dead then
    player:drawCards(1, mumu.name)
    end
  else
    room:moveCardIntoEquip(player, id, mumu.name, true, player)
  end
  end,
})

return mumu