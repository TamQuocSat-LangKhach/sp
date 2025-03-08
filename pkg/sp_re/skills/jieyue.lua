```lua
local jieyue = fk.CreateSkill {
  name = "jieyue"
}

Fk:loadTranslationTable{
  ['jieyue'] = '节钺',
  ['$jieyue'] = '节钺',
  ['#jieyue_trigger'] = '节钺',
  ['#jieyue-cost'] = '节钺：你可以弃置一张手牌，令一名其他角色执行后续效果',
  ['#jieyue-give'] = '节钺：将一张牌置为 %src 的“节钺”牌，或其弃置你一张牌',
  [':jieyue'] = '结束阶段开始时，你可以弃置一张手牌并选择一名其他角色，若如此做，除非该角色将一张牌置于你的武将牌上，否则你弃置其一张牌。若你的武将牌上有牌，则你可以将红色手牌当【闪】、黑色手牌当【无懈可击】使用或打出，准备阶段开始时，你获得你武将牌上的牌。',
  ['$jieyue1'] = '诸军严整，敌军自乱。',
  ['$jieyue2'] = '安营驻寨，严守城防。',
  ['$jieyue3'] = '不动如泰山。',
  ['$jieyue4'] = '纪法严明，无懈可击。',
}

-- ViewAsSkill
jieyue:addEffect('viewas', {
  pattern = "jink,nullification",
  mute = true,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
  end,
  before_use = function(self, player, use)
    if use.card.name == "jink" then
      player:broadcastSkillInvoke(jieyue.name, 3)
      player.room:notifySkillInvoked(player, jieyue.name, "defensive")
    elseif use.card.name == "nullification" then
      player:broadcastSkillInvoke(jieyue.name, 4)
      player.room:notifySkillInvoked(player, jieyue.name, "defensive")
    end
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    local card
    if Fk:getCardById(cards[1]).color == Card.Red then
      card = Fk:cloneCard("jink")
    elseif Fk:getCardById(cards[1]).color == Card.Black then
      card = Fk:cloneCard("nullification")
    end
    card.skillName = jieyue.name
    card:addSubcard(cards[1])
    return card
  end,
  enabled_at_response = function(self, player)
    return #player:getPile("$jieyue") > 0
  end,
})

-- TriggerSkill
jieyue:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target == player then
      if player.phase == Player.Finish then
        return player:hasSkill(jieyue.name) and not player:isKongcheng()
      elseif player.phase == Player.Start then
        return #player:getPile("$jieyue") > 0
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if player.phase == Player.Finish then
      local room = player.room
      local targets = {}
      for _, p in ipairs(room:getOtherPlayers(player)) do
        if not p:isNude() then
          table.insert(targets, p.id)
        end
      end
      if #targets == 0 then return end
      local tos, id = player.room:askToChooseCardsAndPlayers(player, {
        min_card_num = 1,
        max_card_num = 1,
        targets = targets,
        pattern = ".|.|.|hand|.|.",
        prompt = "#jieyue-cost",
        skill_name = "jieyue"
      })
      if #tos > 0 then
        event:setCostData(self, {tos[1], id})
        return true
      end
    elseif player.phase == Player.Start then
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(jieyue.name, math.random(1,2))
    player.room:notifySkillInvoked(player, jieyue.name, "defensive")
    if player.phase == Player.Finish then
      room:throwCard(event:getCostData(self)[2], "jieyue", player, player)
      if player.dead then return end
      local to = room:getPlayerById(event:getCostData(self)[1])
      local card = room:askToCards(to, {
        min_num = 1,
        max_num = 1,
        include_equip = true,
        skill_name = "jieyue",
        cancelable = true,
        pattern = ".",
        prompt = "#jieyue-give:"..player.id
      })
      if #card > 0 then
        player:addToPile("$jieyue", card, false, "jieyue")
      else
        local id = room:askToChooseCard(player, {
          target = to,
          flag = "he",
          skill_name = "jieyue"
        })
        room:throwCard({id}, "jieyue", to, player)
      end
    elseif player.phase == Player.Start then
      if player.dead then return end
      room:moveCards({
        from = player.id,
        ids = player:getPile("$jieyue"),
        to = player.id,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonJustMove,
        skillName = jieyue.name,
      })
    end
  end,
})

return jieyue
```