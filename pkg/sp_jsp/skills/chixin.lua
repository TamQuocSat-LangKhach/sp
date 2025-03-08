```lua
local chixin = fk.CreateSkill {
  name = "chixin"
}

Fk:loadTranslationTable{
  ['chixin'] = '赤心',
  ['#chixin_targetmod'] = '赤心',
  ['#chixin_record'] = '赤心',
  [':chixin'] = '你可以将<font color=>♦</font>牌当【杀】或【闪】使用或打出。出牌阶段，你对你攻击范围内的每名角色均可使用一张【杀】。',
}

-- ViewAsSkill部分
chixin:addEffect('viewas', {
  pattern = "slash,jink",
  interaction = function()
  local names = {}
  if Fk.currentResponsePattern == nil and Self:canUse(Fk:cloneCard("slash")) then
    table.insertIfNeed(names, "slash")
  else
    for _, name in ipairs({"slash", "jink"}) do
    if Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(Fk:cloneCard(name)) then
      table.insertIfNeed(names, name)
    end
    end
  end
  if #names == 0 then return end
  return UI.ComboBox {choices = names}  --FIXME: 体验很不好！
  end,
  card_filter = function(self, player, to_select, selected)
  return #selected == 0 and Fk:getCardById(to_select).suit == Card.Diamond
  end,
  view_as = function(self, player, cards)
  if #cards ~= 1 or self.interaction.data == nil then return end
  local card = Fk:cloneCard(self.interaction.data)
  card.skillName = chixin.name
  card:addSubcard(cards[1])
  return card
  end,
})

-- TargetModSkill部分
chixin:addEffect('targetmod', {
  bypass_times = function(self, player, skill, scope, card, to)
  return player:hasSkill(chixin) and skill.trueName == "slash_skill" and to
    and scope == Player.HistoryPhase and player:inMyAttackRange(to) and to:getMark("chixin_slashed-phase") == 0
  end
})

-- TriggerSkill部分
chixin:addEffect(fk.TargetSpecified, {
  mute = true,
  can_refresh = function(self, event, target, player, data)
  if target == player and player:hasSkill(chixin, true) and data.card and data.card.trueName == "slash" then
    local to = player.room:getPlayerById(data.to)
    return to and to:getMark("chixin_slashed-phase") == 0
  end
  end,
  on_refresh = function(self, event, target, player, data)
  local room = player.room
  local to = room:getPlayerById(data.to)
  if to then room:addPlayerMark(to, "chixin_slashed-phase", 1) end
  end,
})

-- EventAcquireSkill部分，合并到TriggerSkill的同一effect中
chixin:addEffect(fk.EventAcquireSkill, {
  can_refresh = function(self, event, target, player, data)
  return target == player and data == chixin and player.phase == Player.Play
  end,
  on_refresh = function(self, event, target, player, data)
  local room = player.room
  room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
    local use = e.data[1]
    if use.from == player.id and use.tos and use.card and use.card.trueName == "slash" then
    table.every(TargetGroup:getRealTargets(use.tos), function(pid)
      local to = room:getPlayerById(pid)
      if to then room:addPlayerMark(to, "chixin_slashed-phase", 1) end
    end)
    end
    return false
  end, Player.HistoryPhase)
  end,
})

return chixin
```