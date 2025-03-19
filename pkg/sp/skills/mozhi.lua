local mozhi = fk.CreateSkill {
  name = "mozhi",
}

Fk:loadTranslationTable {
  ["mozhi"] = "默识",
  [":mozhi"] = "结束阶段，你可以将一张手牌当你本回合出牌阶段使用过的第一张基本牌或普通锦囊牌使用，然后你可以将一张手牌当你本回合"..
  "出牌阶段使用过的第二张基本牌或普通锦囊牌使用。",

  ["#mozhi-invoke"] = "默识：你可以将一张手牌当【%arg】使用",

  ["$mozhi1"] = "博闻强识，不辱才女之名。",
  ["$mozhi2"] = "今日默书，方恨千卷诗书未能全记。",
}

mozhi:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(mozhi.name) and player.phase == Player.Finish and #player:getHandlyIds() > 0 then
      local room = player.room
      local names = {}
      local phase_ids = {}
      room.logic:getEventsOfScope(GameEvent.Phase, 1, function(e)
        if e.data.phase == Player.Play then
          table.insert(phase_ids, { e.id, e.end_id })
        end
      end, Player.HistoryTurn)
      if #phase_ids == 0 then return end
      room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
        local in_play = false
        for _, ids in ipairs(phase_ids) do
          if #ids == 2 and e.id > ids[1] and e.id < ids[2] then
            in_play = true
            break
          end
        end
        if in_play then
          local use = e.data
          if use.from == player and (use.card.type == Card.TypeBasic or use.card:isCommonTrick()) then
            table.insert(names, use.card.name)
          end
        end
        return #names > 1
      end, Player.HistoryTurn)
      if #names > 0 then
        event:setCostData(self, {extra_data = names})
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local names = event:getCostData(self).extra_data
    local success, dat = room:askToUseActiveSkill(player, {
      skill_name = "mozhi_viewas",
      prompt = "#mozhi-invoke:::"..names[1],
      cancelable = true,
      extra_data = {
        mozhi = names[1],
      }
    })
    if success and dat then
      event:setCostData(self, {choice = names, extra_data = dat})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local names = event:getCostData(self).choice
    local dat = event:getCostData(self).extra_data
    local card = Fk:cloneCard(names[1])
    card.skillName = mozhi.name
    card:addSubcards(dat.cards)
    room:useCard {
      from = player,
      tos = dat.targets,
      card = card,
      extraUse = true,
    }
    if player.dead or #player:getHandlyIds() == 0 then return end
    if #names == 2 then
      local success, dat = room:askToUseActiveSkill(player, {
        skill_name = "mozhi_viewas",
        prompt = "#mozhi-invoke:::"..names[2],
        cancelable = true,
        extra_data = {
          mozhi = names[2],
        }
      })
      if success and dat then
        card = Fk:cloneCard(names[2])
        card.skillName = mozhi.name
        card:addSubcards(dat.cards)
        room:useCard {
          from = player,
          tos = dat.targets,
          card = card,
          extraUse = true,
        }
      end
    end
  end,
})

return mozhi
