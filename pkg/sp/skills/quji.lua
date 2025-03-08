local quji = fk.CreateSkill {
  name = "quji"
}

Fk:loadTranslationTable{
  ['quji'] = '去疾',
  ['#quji'] = '去疾：弃置%arg张牌，令至多等量角色回复体力，若弃置了黑色牌，你失去1点体力',
  [':quji'] = '出牌阶段限一次，若你已受伤，你可以弃置X张牌并选择至多X名已受伤的角色，令这些角色各回复1点体力，然后若你以此法弃置过的牌中有黑色牌，你失去1点体力。（X为你已损失的体力值）',
  ['$quji1'] = '若不去兵之疾，则将何以守国？',
  ['$quji2'] = '愿为将士，略尽绵薄。',
}

local min_card_num = function (player)
  return player:getLostHp()
end

local prompt = function (player)
  return "#quji:::"..player:getLostHp()
end

quji:addEffect('active', {
  anim_type = "support",
  min_card_num = min_card_num,
  min_target_num = 1,
  prompt = prompt,
  can_use = function(self, player)
    return player:isWounded() and player:usedSkillTimes(skill.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected < min_card_num(player)
  end,
  target_filter = function(self, player, to_select, selected, cards)
    return #selected < min_card_num(player) and Fk:currentRoom():getPlayerById(to_select):isWounded()
    and #cards == min_card_num(player)
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local loseHp = table.find(effect.cards, function(id) return Fk:getCardById(id).color == Card.Black end)
    room:throwCard(effect.cards, skill.name, player, player)
    local tos = effect.tos
    room:sortPlayersByAction(tos)
    for _, pid in ipairs(tos) do
    local to = room:getPlayerById(pid)
    if not to.dead and to:isWounded() then
      room:recover({
      who = to,
      num = 1,
      recoverBy = player,
      skillName = skill.name
      })
    end
    end
    if loseHp and not player.dead then
    room:loseHp(player, 1, skill.name)
    end
  end,
})

return quji