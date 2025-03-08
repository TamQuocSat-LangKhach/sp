local zhaolie = fk.CreateSkill {
  name = "zhaolie"
}

Fk:loadTranslationTable{
  ['zhaolie'] = '昭烈',
  ['#zhaolie-choose'] = '昭烈：你可以少摸一张牌，亮出牌堆顶三张牌，令一名角色根据其中基本牌数受到伤害或弃牌',
  ['#zhaolie-discard'] = '昭烈：你需依次弃置%arg张牌，否则 %src 对你造成%arg2点伤害',
  [':zhaolie'] = '摸牌阶段摸牌时，你可以少摸一张，指定你攻击范围内的一名角色亮出牌堆顶上3张牌，将其中的非基本牌和【桃】置于弃牌堆，该角色进行二选一：你对其造成X点伤害，然后他获得这些基本牌；或他依次弃置X张牌，然后你获得这些基本牌。（X为其中非基本牌的数量）',
}

zhaolie:addEffect(fk.DrawNCards, {
  anim_type = "offensive",
  can_trigger = function(skill, event, target, player, data)
  return target == player and player:hasSkill(zhaolie.name) and data.n > 0
  end,
  on_cost = function(skill, event, target, player, data)
  local targets = table.map(table.filter(player.room:getOtherPlayers(player),
    function(p) return player:inMyAttackRange(p) end), Util.IdMapper)
  if #targets == 0 then return end
  local to = player.room:askToChoosePlayers(player, {
    targets = targets,
    min_num = 1,
    max_num = 1,
    prompt = "#zhaolie-choose",
    skill_name = zhaolie.name,
    cancelable = true,
  })
  if #to > 0 then
    event:setCostData(skill, to[1].id)
    return true
  end
  end,
  on_use = function(skill, event, target, player, data)
  local room = player.room
  data.n = data.n - 1
  local to = room:getPlayerById(event:getCostData(skill))
  local cards = room:getNCards(3)
  room:moveCards({
    ids = cards,
    toArea = Card.Processing,
    moveReason = fk.ReasonJustMove,
    skillName = zhaolie.name,
    proposer = player.id,
  })
  local get = {}
  local throw = {}
  for _, id in ipairs(cards) do
    local card = Fk:getCardById(id)
    if card.type ~= Card.TypeBasic or card.name == "peach" then
    table.insert(throw, id)
    else
    table.insert(get, id)
    end
  end
  if #throw > 0 then
    room:delay(1000)
    room:moveCards({
    ids = throw,
    toArea = Card.DiscardPile,
    moveReason = fk.ReasonPutIntoDiscardPile,
    })
  end
  if #get > 0 then
    if to:isNude() or #to:getCardIds{Player.Hand, Player.Equip} < #get then
    room:damage{
      from = player,
      to = to,
      damage = #get,
      skillName = zhaolie.name,
    }
    if not to.dead then
      room:obtainCard(to.id, get, true, fk.ReasonJustMove)
    end
    else
    local discards = room:askToDiscard(to, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = zhaolie.name,
      cancelable = true,
      prompt = "#zhaolie-discard:"..player.id.."::"..tostring(#get)..":"..tostring(#get),
    })
    if #discards > 0 then
      for i = 1, #get - 1 do
      room:askToDiscard(to, {
        min_num = 1,
        max_num = 1,
        include_equip = true,
        skill_name = zhaolie.name,
        cancelable = false,
      })
      end
      room:obtainCard(player.id, get, true, fk.ReasonJustMove)
    else
      room:damage{
      from = player,
      to = to,
      damage = #get,
      skillName = zhaolie.name,
      }
      if not to.dead then
      room:obtainCard(to.id, get, true, fk.ReasonJustMove)
      end
    end
    end
  end
  end,
})

return zhaolie