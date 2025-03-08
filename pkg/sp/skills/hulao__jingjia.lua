local hulao__jingjia = fk.CreateSkill {
  name = "hulao__jingjia"
}

Fk:loadTranslationTable{
  ['hulao__jingjia'] = '精甲',
  [':hulao__jingjia'] = '游戏开始时，你将本局游戏中加入的装备置入你的装备区。',
}

hulao__jingjia:addEffect(fk.GameStart, {
  can_trigger = function(skill, event, target, player)
    return player:hasSkill(skill.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(skill, event, target, player, data)
    local room = player.room
    local laobu_equip = {{"py_halberd", Card.Diamond, 12},{"py_hat", Card.Diamond, 1}}
    local laobu_armors = {{"py_robe", Card.Club, 1},{"py_belt", Card.Spade, 2}}
    table.insert(laobu_equip, table.random(laobu_armors))
    local cards = table.filter(U.prepareDeriveCards(room, laobu_equip, "laobu_equip"), function (id)
      return room:getCardArea(id) == Card.Void
    end)
    if #cards > 0 then
      room:moveCardIntoEquip(player, cards, hulao__jingjia.name, false, player)
    end
  end,
})

return hulao__jingjia