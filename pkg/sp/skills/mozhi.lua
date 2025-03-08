```lua
local mozhi = fk.CreateSkill {
  name = "mozhi"
}

Fk:loadTranslationTable{
  ['mozhi'] = '默识',
  ['mozhi_view_as'] = '默识',
  ['#mozhi-invoke'] = '默识：你可以将一张手牌当【%arg】使用',
  [':mozhi'] = '结束阶段，你可以将一张手牌当你本回合出牌阶段使用过的第一张基本牌或非延时锦囊牌使用，然后你可以将一张手牌当你本回合出牌阶段使用过的第二张基本牌或非延时锦囊牌使用。',
  ['$mozhi1'] = '博闻强识，不辱才女之名。',
  ['$mozhi2'] = '今日默书，方恨千卷诗书未能全记。',
}

mozhi:addEffect(fk.EventPhaseStart, {
  global = false,
  can_trigger = function(self, event, target, player)
    if target == player and player:hasSkill(mozhi.name) and player.phase == Player.Finish and not player:isKongcheng() then
      local room = player.room
      local names = player:getMark("mozhi_record-phase")
      if type(names) ~= "table" then
        names = {}
        local play_ids = {}
        room.logic:getEventsOfScope(GameEvent.Phase, 1, function (e)
          if e.data[2] == Player.Play then
            table.insert(play_ids, {e.id, e.end_id})
          end
          return false
        end, Player.HistoryTurn)
        room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
          local in_play = false
          for _, ids in ipairs(play_ids) do
            if #ids == 2 and e.id > ids[1] and e.id < ids[2] then
              in_play = true
              break
            end
          end
          if in_play then
            local use = e.data[1]
            if use.from == player.id and (use.card.type == Card.TypeBasic or use.card:isCommonTrick()) then
              table.insert(names, use.card.name)
            end
          end
          return #names > 1
        end, Player.HistoryTurn)
        room:setPlayerMark(player, "mozhi_record-phase", names)
      end
      if #names > 0 then
        local name = names[1]
        local to_use = Fk:cloneCard(name)
        return player:canUse(to_use) and not player:prohibitUse(to_use)
      end
    end
  end,
  on_cost = function(self, event, target, player)
    local names = player:getMark("mozhi_record-phase")
    if type(names) ~= "table" then return false end
    local name = names[1]
    local to_use = Fk:cloneCard(name)
    if not player:canUse(to_use) or player:prohibitUse(to_use) then return false end
    local room = player.room
    room:setPlayerMark(player, "mozhi_to_use", name)
    local success, dat = room:askToUseActiveSkill(player, {
      skill_name = "mozhi_view_as",
      prompt = "#mozhi-invoke:::"..name,
      cancelable = true,
    })
    if success then
      event:setCostData(self, dat)
      return true
    end
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    local card = Fk:cloneCard(player:getMark("mozhi_to_use"))
    card.skillName = mozhi.name
    local cost_data = event:getCostData(self)
    card:addSubcards(cost_data.cards)
    room:useCard{
      from = player.id,
      tos = table.map(cost_data.targets, function(id) return {id} end),
      card = card,
    }
    if player.dead then return end
    local names = player:getMark("mozhi_record-phase")
    if type(names) == "table" and #names > 1 then
      local name = names[2]
      local to_use = Fk:cloneCard(name)
      if not player:canUse(to_use) or player:prohibitUse(to_use) then return false end
      room:setPlayerMark(player, "mozhi_to_use", name)
      local success, dat = room:askToUseActiveSkill(player, {
        skill_name = "mozhi_view_as",
        prompt = "#mozhi-invoke:::"..name,
        cancelable = true,
      })
      if success then
        card = Fk:cloneCard(player:getMark("mozhi_to_use"))
        card.skillName = mozhi.name
        card:addSubcards(dat.cards)
        room:useCard{
          from = player.id,
          tos = table.map(dat.targets, function(id) return {id} end),
          card = card,
        }
      end
    end
  end,
})

return mozhi
```