```lua
local nuzhan = fk.CreateSkill {
  name = "nuzhan"
}

Fk:loadTranslationTable{
  ['nuzhan'] = '怒斩',
  [':nuzhan'] = '锁定技，你将锦囊牌当【杀】使用时，此【杀】不计入出牌阶段使用次数；你将装备牌当【杀】使用时，此【杀】伤害+1。',
}

nuzhan:addEffect(fk.AfterCardUseDeclared, {
  can_trigger = function(self, event, target, player, data)
  if target == player and player:hasSkill(nuzhan.name, false, true) and data.card and data.card.trueName == "slash" and
    data.card:isVirtual() and #data.card.subcards == 1 then
    local subcard = Fk:getCardById(data.card.subcards[1])
    return player.phase == Player.Play and subcard.type == Card.TypeTrick
  end
  end,
  on_use = function(self, event, target, player, data)
  player:addCardUseHistory(data.card.trueName, -1)
  end,
})

nuzhan:addEffect(fk.PreCardUse, {
  can_trigger = function(self, event, target, player, data)
  if target == player and player:hasSkill(nuzhan.name, false, true) and data.card and data.card.trueName == "slash" and
    data.card:isVirtual() and #data.card.subcards == 1 then
    local subcard = Fk:getCardById(data.card.subcards[1])
    return subcard.type == Card.TypeEquip
  end
  end,
  on_use = function(self, event, target, player, data)
  data.additionalDamage = (data.additionalDamage or 0) + 1
  end,
})

return nuzhan
```