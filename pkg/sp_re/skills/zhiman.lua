local zhiman = fk.CreateSkill {
  name = "zhiman"
}

Fk:loadTranslationTable{
  ['zhiman'] = '制蛮',
  ['#zhiman-invoke'] = '制蛮：你可以防止对 %dest 造成的伤害，然后获得其场上的一张牌',
  [':zhiman'] = '当你对其他角色造成伤害时，你可以防止此伤害，然后获得其装备区或判定区的一张牌。',
  ['$zhiman1'] = '兵法谙熟于心，取胜千里之外！',
  ['$zhiman2'] = '丞相多虑，且看我的！',
}

zhiman:addEffect(fk.DamageCaused, {
  can_trigger = function(self, event, target, player, data)
  return target == player and player:hasSkill(skill.name) and data.to ~= player
  end,
  on_cost = function(self, event, target, player, data)
  return player.room:askToSkillInvoke(player, { skill_name = skill.name, prompt = "#zhiman-invoke::" .. data.to.id })
  end,
  on_use = function(self, event, target, player, data)
  local room = player.room
  if #data.to:getCardIds{Player.Equip, Player.Judge} > 0 then
    local card = room:askToChooseCard(player, { target = data.to, flag = "ej", skill_name = skill.name })
    room:obtainCard(player.id, card, true, fk.ReasonPrey)
  end
  return true
  end,
})

return zhiman