local jilei = fk.CreateSkill {
  name = "jilei"
}

Fk:loadTranslationTable{
  ['jilei'] = '鸡肋',
  ['@jilei-turn'] = '鸡肋',
  [':jilei'] = '当你受到伤害后，你可以声明一种牌的类别（基本牌、锦囊牌、装备牌），对你造成伤害的角色不能使用、打出或弃置该类别的手牌直到回合结束。',
  ['$jilei1'] = '食之无肉，弃之有味。',
  ['$jilei2'] = '曹公之意我已了然！',
}

jilei:addEffect(fk.Damaged, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jilei.name) and data.from and not data.from.dead
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = room:askToChoice(player, {
      choices = {"basic", "trick", "equip"},
      skill_name = jilei.name
    })
    local types = data.from:getMark("@jilei-turn")
    if types == 0 then types = {} end
    table.insertIfNeed(types, choice .. "_char")
    room:setPlayerMark(data.from, "@jilei-turn", types)
  end,
})

jilei:addEffect('prohibit', {
  prohibit_use = function(self, player, card)
  local mark = player:getMark("@jilei-turn")
  if type(mark) == "table" and table.contains(mark, card:getTypeString() .. "_char") then
    local subcards = card:isVirtual() and card.subcards or {card.id}
    return #subcards > 0 and table.every(subcards, function(id)
    return table.contains(player:getCardIds(Player.Hand), id)
    end)
  end
  end,
  prohibit_response = function(self, player, card)
  local mark = player:getMark("@jilei-turn")
  if type(mark) == "table" and table.contains(mark, card:getTypeString() .. "_char") then
    local subcards = card:isVirtual() and card.subcards or {card.id}
    return #subcards > 0 and table.every(subcards, function(id)
    return table.contains(player:getCardIds(Player.Hand), id)
    end)
  end
  end,
  prohibit_discard = function(self, player, card)
  local mark = player:getMark("@jilei-turn")
  return type(mark) == "table" and table.contains(mark, card:getTypeString() .. "_char")
  end,
})

return jilei