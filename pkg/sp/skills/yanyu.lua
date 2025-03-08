local yanyu = fk.CreateSkill {
  name = "sp__yanyu"
}

Fk:loadTranslationTable {
  ['sp__yanyu'] = '燕语',
  ['#yanyu-cost'] = '燕语：你可以弃置一张牌，然后此出牌阶段限三次，可令任意角色获得相同类别进入弃牌堆的牌',
  ['#yanyu_delay'] = '燕语',
  ['@yanyu-phase'] = '燕语',
  ['#yanyu-choose'] = '燕语：令一名角色获得弃置的牌',
  [':sp__yanyu'] = '任意一名角色的出牌阶段开始时，你可以弃置一张牌，若如此做，则本回合的出牌阶段，当有与你弃置牌类别相同的其他牌进入弃牌堆时，你可令任意一名角色获得此牌。每回合以此法获得的牌不能超过三张。',
  ['$sp__yanyu1'] = '燕燕于飞，颉之颃之。',
  ['$sp__yanyu2'] = '终温且惠，淑慎其身。',
}

local U = require "packages/utility/utility"

yanyu:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player)
    return player:hasSkill(yanyu.name) and target.phase == Player.Play and not player:isNude()
  end,
  on_cost = function(self, event, target, player)
    local card = player.room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      pattern = ".",
      prompt = "#yanyu-cost",
      skill_name = yanyu.name,
      skip = true
    })
    if #card > 0 then
      event:setCostData(self, card)
      return true
    end
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    local card_type = Fk:getCardById(event:getCostData(self)[1]):getTypeString()
    room:throwCard(event:getCostData(self), yanyu.name, player, player)
    local x = 3 - player:usedSkillTimes("#yanyu_delay", Player.HistoryTurn)
    if not player.dead and x > 0 then
      room:setPlayerMark(player, "@yanyu-phase", { card_type, x })
    end
  end,
})

yanyu:addEffect(fk.AfterCardsMove, {
  anim_type = "support",
  can_trigger = function(self, event, target, player)
    if player.dead or player:usedSkillTimes(yanyu.name, Player.HistoryTurn) > 2 then return false end
    local mark = player:getMark("@yanyu-phase")
    if type(mark) == "table" and #mark == 2 then
      local type_name = mark[1]
      local ids = {}
      local id = -1
      local room = player.room
      for _, move in ipairs(event.data) do
        if move.toArea == Card.DiscardPile then
          for _, info in ipairs(move.moveInfo) do
            id = info.cardId
            if Fk:getCardById(id):getTypeString() == type_name and room:getCardArea(id) == Card.DiscardPile then
              table.insertIfNeed(ids, id)
            end
          end
        end
      end
      ids = U.moveCardsHoldingAreaCheck(room, ids)
      if #ids > 0 then
        event:setCostData(self, ids)
        return true
      end
    end
  end,
  on_trigger = function(self, event, target, player)
    local room = player.room
    local ids = table.simpleClone(event:getCostData(self))
    while true do
      self.cancel_cost = false
      self:doCost(event, nil, player, ids)
      if self.cancel_cost then
        self.cancel_cost = false
        break
      end
      if player.dead or player:usedSkillTimes(yanyu.name, Player.HistoryTurn) > 2 then break end
      ids = U.moveCardsHoldingAreaCheck(room, ids)
      if #ids == 0 then break end
    end
  end,
  on_cost = function(self, event, target, player)
    local room = player.room
    room:setPlayerMark(player, "yanyu_cards", event:getCostData(self))
    local _, ret = room:askToUseActiveSkill(player, {
      skill_name = "yanyu_active",
      prompt = "#yanyu-choose",
      cancelable = true,
      no_indicate = true
    })
    room:setPlayerMark(player, "yanyu_cards", 0)
    if ret then
      event:setCostData(self, { ret.targets[1], ret.cards[1] })
      return true
    end
    self.cancel_cost = true
  end,
  on_use = function(self, event, target, player)
    player:broadcastSkillInvoke("sp__yanyu")
    local mark = player:getMark("@yanyu-phase")
    if type(mark) == "table" or #mark == 2 then
      local x = 3 - player:usedSkillTimes(yanyu.name, Player.HistoryTurn)
      player.room:setPlayerMark(player, "@yanyu-phase", x > 0 and { mark[1], x } or 0)
    end
    player.room:obtainCard(event:getCostData(self)[1], event:getCostData(self)[2], true, fk.ReasonGive)
  end,
})

return yanyu
