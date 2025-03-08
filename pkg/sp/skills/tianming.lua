local tianming = fk.CreateSkill {
  name = "tianming"
}

Fk:loadTranslationTable {
  ['tianming'] = '天命',
  ['#tianming-cost'] = '天命：你可以弃置两张牌（不足则全弃，无牌则不弃），然后摸两张牌',
  [':tianming'] = '当你成为【杀】的目标时，你可以弃置两张牌（不足则全弃，无牌则不弃），然后摸两张牌；然后若场上体力唯一最多的角色不为你，该角色也可以如此做。',
  ['$tianming1'] = '皇汉国祚，千年不息！',
  ['$tianming2'] = '朕乃大汉皇帝，天命之子！',
}

tianming:addEffect(fk.TargetConfirmed, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(tianming.name) and data.card.trueName == "slash"
  end,
  on_cost = function(self, event, target, player, data)
    local ids = table.filter(player:getCardIds("he"),
      function(id) return not player:prohibitDiscard(Fk:getCardById(id)) end)
    if #ids <= 2 then
      if player.room:askToSkillInvoke(player, {
            skill_name = tianming.name,
            prompt = "#tianming-cost"
          }) then
        event:setCostData(self, ids)
        return true
      end
    else
      local cards = player.room:askToDiscard(player, {
        min_num = 2,
        max_num = 2,
        include_equip = true,
        skill_name = tianming.name,
        cancelable = true,
        pattern = ".",
        prompt = "#tianming-cost",
        skip = true
      })
      if #cards > 0 then
        event:setCostData(self, cards)
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(event:getCostData(self), tianming.name, player, player)
    if not player.dead then
      player:drawCards(2, tianming.name)
    end
    local to = {}
    local x = 0
    for _, p in ipairs(room.alive_players) do
      if x < p.hp then
        x = p.hp
        to = { p }
      elseif x == p.hp then
        table.insert(to, p)
      end
    end
    if #to ~= 1 or to[1] == player then return end
    to = to[1]
    x = 0
    for _, id in ipairs(to:getCardIds("he")) do
      if not to:prohibitDiscard(Fk:getCardById(id)) then
        x = x + 1
        if x == 2 then break end
      end
    end
    if x == 0 then
      if room:askToSkillInvoke(to, {
            skill_name = tianming.name,
            prompt = "#tianming-cost"
          }) then
        to:drawCards(2, tianming.name)
      end
    else
      local cards = room:askToDiscard(to, {
        min_num = x,
        max_num = 2,
        include_equip = true,
        skill_name = tianming.name,
        cancelable = true,
        pattern = ".",
        prompt = "#tianming-cost"
      })
      if #cards > 0 and not to.dead then
        room:drawCards(to, 2, tianming.name)
      end
    end
  end,
})

return tianming
