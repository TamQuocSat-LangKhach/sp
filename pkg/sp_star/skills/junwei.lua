local junwei = fk.CreateSkill {
  name = "junwei"
}

Fk:loadTranslationTable{
  ['junwei'] = '军威',
  ['ganning_jin'] = '锦',
  ['#junwei-invoke'] = '军威：你可以将三张“锦”置入弃牌堆',
  ['#junwei-choose'] = '军威：选择一名角色，其展示【闪】并由你交给一名角色，或失去1点体力并移除一张装备直到其回合结束',
  ['#junwei-card'] = '军威：展示一张【闪】并由 %src 交给一名角色，否则失去1点体力并被移除一张装备直到你回合结束',
  ['#junwei-give'] = '军威：将%arg交给一名角色',
  ['#junwei_delay'] = '军威',
  [':junwei'] = '结束阶段开始时，你可以将三张“锦”置入弃牌堆。若如此做，你须指定一名角色并令其选择一项：1.亮出一张【闪】，然后由你交给任意一名角色。2.该角色失去1点体力，然后由你选择将其装备区的一张牌移出游戏，在该角色的回合结束后，将以此法移出游戏的装备牌移回原处。',
}

junwei:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
  return target == player and player.phase == Player.Finish and #player:getPile("ganning_jin") > 2
  end,
  on_cost = function(self, event, target, player, data)
  local cards = player.room:askToCards(player, {
    min_num = 3,
    max_num = 3,
    pattern = ".|.|.|ganning_jin|.|.",
    prompt = "#junwei-invoke",
    skill_name = junwei.name
  })
  if #cards == 3 then
    event:setCostData(self, cards)
    return true
  end
  end,
  on_use = function(self, event, target, player, data)
  local room = player.room
  room:moveCardTo(event:getCostData(self), Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, junwei.name, nil, true, player.id)
  local targets = table.map(room:getAlivePlayers(), Util.IdMapper)
  local to = room:askToChoosePlayers(player, {
    min_num = 1,
    max_num = 1,
    prompt = "#junwei-choose",
    skill_name = junwei.name
  })
  to = room:getPlayerById(to[1])
  local card = {}
  if not to:isKongcheng() then
    card = room:askToCards(to, {
    min_num = 1,
    max_num = 1,
    pattern = "jink",
    prompt = "#junwei-card:" .. player.id,
    skill_name = junwei.name
    })
  end
  if #card > 0 then
    to:showCards(card)
    local p = room:askToChoosePlayers(player, {
    min_num = 1,
    max_num = 1,
    prompt = "#junwei-give:::" .. Fk:getCardById(card[1]):toLogString(),
    skill_name = junwei.name
    })
    if p ~= to.id then
    p = room:getPlayerById(p[1])
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonGive, junwei.name, nil, true, player.id)
    end
  else
    room:loseHp(to, 1, junwei.name)
    if not to.dead and #to:getCardIds("e") > 0 then
    local id = room:askToChooseCard(player, {
      target = to,
      flag = "e",
      skill_name = junwei.name
    })
    to:addToPile(junwei.name, id, true, junwei.name)
    end
  end
  end,
})

junwei:addEffect(fk.TurnEnd, {
  name = "#junwei_delay",
  mute = true,
  can_trigger = function(self, event, target, player, data)
  return target == player and #player:getPile("junwei") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
  local room = player.room
  for i = #player:getPile("junwei"), 1, -1 do
    if player.dead then return end
    room:moveCardIntoEquip(player, player:getPile("junwei")[i], "junwei", true, player)
  end
  end,
})

return junwei