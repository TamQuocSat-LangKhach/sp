local yinling = fk.CreateSkill {
  name = "yinling"
}

Fk:loadTranslationTable{
  ['yinling'] = '银铃',
  ['ganning_jin'] = '锦',
  ['#yinling'] = '银铃：弃一张黑色牌，将一名角色一张牌置为你的“锦”',
  [':yinling'] = '出牌阶段，你可以弃置一张黑色牌并指定一名其他角色，若如此做，你获得其一张牌并置于你的武将牌上，称为“锦”。（数量最多为四）',
}

yinling:addEffect('active', {
  anim_type = "control",
  card_num = 1,
  target_num = 1,
  derived_piles = "ganning_jin",
  prompt = "#yinling",
  can_use = function(skill, player)
    return not player:isNude() and #player:getPile("ganning_jin") < 4
  end,
  card_filter = function(skill, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).color == Card.Black and not player:prohibitDiscard(to_select)
  end,
  target_filter = function(skill, player, to_select, selected)
    return #selected == 0 and to_select ~= player.id and not Fk:currentRoom():getPlayerById(to_select):isNude()
  end,
  on_use = function(skill, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:throwCard(effect.cards, yinling.name, player, player)
    if player.dead or target.dead or target:isNude() then return end
    local id = room:askToChooseCard(player, {
      target = target,
      flag = "he",
      skill_name = yinling.name
    })
    player:addToPile("ganning_jin", id, true, yinling.name)
  end,
})

return yinling