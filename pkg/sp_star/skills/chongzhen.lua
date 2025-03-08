local chongzhen = fk.CreateSkill {
  name = "chongzhen"
}

Fk:loadTranslationTable{
  ['chongzhen'] = '冲阵',
  ['#chongzhen-invoke'] = '冲阵：你可以获得 %dest 的一张手牌',
  [':chongzhen'] = '每当你发动〖龙胆〗使用或打出一张手牌时，你可以立即获得对方的一张手牌。',
  ['$chongzhen1'] = '陷阵杀敌，一马当先！',
  ['$chongzhen2'] = '贼将休走，可敢与我一战？'
}

chongzhen:addEffect(fk.CardUsing, {
  events = {fk.CardUsing, fk.CardResponding},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(chongzhen.name) and
      table.find(data.card.skillNames, function(name) return string.find(name, "longdan") end) then
      local id
      if event == fk.CardUsing then
        if data.card.trueName == "slash" then
          id = data.tos[1][1]
        elseif data.card.name == "jink" then
          if data.responseToEvent then
            id = data.responseToEvent.from  -- jink
          end
        end
      elseif event == fk.CardResponding then
        if data.responseToEvent then
          if data.responseToEvent.from == player.id then
            id = data.responseToEvent.to  -- duel used by zhaoyun
          else
            id = data.responseToEvent.from  -- savage_assault, archery_attack, passive duel

            -- TODO: Lenovo shu zhaoyun may chongzhen liubei when responding to jijiang
          end
        end
      end
      if id ~= nil then
        event:setCostData(self, id)
        return not player.room:getPlayerById(id):isKongcheng()
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = chongzhen.name,
      prompt = "#chongzhen-invoke::" .. event:getCostData(self),
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(event:getCostData(self))
    local card = room:askToChooseCard(player, {
      target = to,
      flag = "h",
      skill_name = chongzhen.name,
    })
    room:obtainCard(player.id, card, false, fk.ReasonPrey)
  end,
})

return chongzhen