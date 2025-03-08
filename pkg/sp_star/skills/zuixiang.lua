```lua
local zuixiang = fk.CreateSkill {
  name = "zuixiang"
}

Fk:loadTranslationTable{
  ['zuixiang'] = '醉乡',
  ['#zuixiang-invoke'] = '醉乡：你可以发动“醉乡”',
  ['#zuixiang_trigger'] = '醉乡',
  [':zuixiang'] = '限定技，准备阶段开始时，你可以展示牌库顶的3张牌置于你的武将牌上，你不可以使用或打出与该些牌同类的牌，所有同类牌对你无效。之后每个你的准备阶段，你须重复展示一次，直至该些牌中任意两张点数相同时，将你武将牌上的全部牌置于你的手上。',
  ['$zuixiang1'] = '懵懵醉乡中，天下心中藏。',
  ['$zuixiang2'] = '今朝有酒，管甚案牍俗事。',
}

zuixiang:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  frequency = Skill.Limited,
  can_trigger = function(self, event, target, player)
    if target == player and player.phase == Player.Start then
    return (player:hasSkill(zuixiang.name) and player:usedSkillTimes(zuixiang.name, Player.HistoryGame) == 0) or #player:getPile(zuixiang.name) > 0
    end
  end,
  on_cost = function(self, event, target, player)
    if #player:getPile(zuixiang.name) == 0 then
    return player.room:askToSkillInvoke(player, { skill_name = zuixiang.name, prompt = "#zuixiang-invoke" })
    else
    return true
    end
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    local cards = room:getNCards(3)
    player:addToPile(zuixiang.name, cards, true, zuixiang.name)
    local number = {}
    for i = 1, #player:getPile(zuixiang.name), 1 do
    table.insertIfNeed(number, Fk:getCardById(player:getPile(zuixiang.name)[i], true).number)
    end
    if #number < #player:getPile(zuixiang.name) then
    room:moveCards({
      ids = player:getPile(zuixiang.name),
      from = player.id,
      fromArea = Card.PlayerSpecial,
      to = player.id,
      toArea = Card.PlayerHand,
      moveReason = fk.ReasonJustMove,
      skillName = zuixiang.name,
      specialName = zuixiang.name,
      moveVisible = true,
    })
    end
  end,
})

zuixiang:addEffect(fk.PreCardEffect, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
  if #player:getPile(zuixiang.name) > 0 and
    table.find(player:getPile(zuixiang.name), function(id) return Fk:getCardById(id, true).type == data.card.type end) then
    return player.id == data.to
  end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
  player:broadcastSkillInvoke(zuixiang.name)
  if data.card.sub_type == Card.SubtypeDelayedTrick then  --取消延时锦囊
    AimGroup:cancelTarget(data, player.id)
  else
    return true
  end
  end,
})

zuixiang:addEffect(fk.TargetConfirmed, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
  if #player:getPile(zuixiang.name) > 0 and
    table.find(player:getPile(zuixiang.name), function(id) return Fk:getCardById(id, true).type == data.card.type end) then
    return target == player and data.card.sub_type == Card.SubtypeDelayedTrick
  end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
  player:broadcastSkillInvoke(zuixiang.name)
  if data.card.sub_type == Card.SubtypeDelayedTrick then  --取消延时锦囊
    AimGroup:cancelTarget(data, player.id)
  else
    return true
  end
  end,
})

zuixiang:addEffect('prohibit', {
  name = "#zuixiang_prohibit",
  prohibit_use = function(self, player, card)
  if #player:getPile(zuixiang.name) > 0 then
    return table.find(player:getPile(zuixiang.name), function(id) return Fk:getCardById(id, true).type == card.type end)
  end
  end,
  prohibit_response = function(self, player, card)
  if #player:getPile(zuixiang.name) > 0 then
    return table.find(player:getPile(zuixiang.name), function(id) return Fk:getCardById(id, true).type == card.type end)
  end
  end,
})

zuixiang:addEffect('invalidity', {
  name = "#zuixiang_invalidity",
  invalidity_func = function(self, player, skill)
  if skill.attached_equip then
    return (#player:getPile(zuixiang.name) > 0 and
    table.find(player:getPile(zuixiang.name), function(id) return Fk:getCardById(id, true).type == Card.TypeEquip end))
    -- or player:getMark("zuixiangNullified") > 0
  end
  end,
})

return zuixiang
```