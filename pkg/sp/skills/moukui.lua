local moukui = fk.CreateSkill {
  name = "moukui"
}

Fk:loadTranslationTable {
  ['moukui'] = '谋溃',
  ['moukui_discard'] = '弃置%dest一张牌',
  ['#moukui-invoke'] = '谋溃：你可以发动“谋溃”，对 %dest 执行一项',
  ['#moukui_delay'] = '谋溃',
  [':moukui'] = '当你使用【杀】指定一名角色为目标后，你可以选择一项：摸一张牌，或弃置其一张牌。若如此做，此【杀】被【闪】抵消时，该角色弃置你的一张牌。',
  ['$moukui1'] = '你的死期到了。',
  ['$moukui2'] = '同归于尽吧！',
}

moukui:addEffect(fk.TargetSpecified, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(moukui.name) and data.card.trueName == "slash"
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = data.to
    local choices = { "Cancel", "draw1" }
    if not to:isNude() then
      table.insert(choices, "moukui_discard::" .. to.id)
    end
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = moukui.name,
      prompt = "#moukui-invoke::" .. data.to
    })
    if choice ~= "Cancel" then
      event:setCostData(self, choice)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = data.to
    if event:getCostData(self) == "draw1" then
      player:drawCards(1, moukui.name)
    else
      local id = room:askToChooseCard(player, {
        target = to,
        flag = "he",
        skill_name = moukui.name
      })
      room:throwCard({ id }, moukui.name, to, player)
    end
    data.extra_data = data.extra_data or {}
    data.extra_data.moukui = data.extra_data.moukui or {}
    table.insert(data.extra_data.moukui, data.to)
  end,
})

moukui:addEffect(fk.CardEffectCancelledOut, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if target == player and data.card.trueName == "slash" and not player.dead then
      local e = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard, true)
      if e then
        local use = e.data
        if use.extra_data and use.extra_data.moukui and table.contains(use.extra_data.moukui, data.to) and
            not data.to.dead then
          return true
        end
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("moukui")
    room:notifySkillInvoked(player, "moukui", "negative")
    local to = data.to
    room:doIndicate(data.to, { player })
    if player:isNude() then return end
    local id = room:askToChooseCard(to, {
      target = player,
      flag = "he",
      skill_name = "moukui"
    })
    room:throwCard(id, "moukui", player, to)
  end,
})

return moukui
