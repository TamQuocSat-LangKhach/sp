local linglong = fk.CreateSkill {
  name = "linglong"
}

Fk:loadTranslationTable{
  ['linglong'] = '玲珑',
  [':linglong'] = '锁定技，若你的装备区没有防具牌，视为你装备着【八卦阵】；若你的装备区没有坐骑牌，你的手牌上限+1；若你的装备区没有宝物牌，视为你拥有技能〖奇才〗。',
  ['$linglong1'] = '哼～书中自有玲珑心～',
  ['$linglong2'] = '哼～自然是多多益善咯～',
}

linglong:addEffect(fk.AskForCardUse, {
  frequency = Skill.Compulsory,
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(linglong) and not player:isFakeSkill(linglong) and
      (data.cardName == "jink" or (data.pattern and Exppattern:Parse(data.pattern):matchExp("jink|0|nosuit|none"))) and
      not player:getEquipment(Card.SubtypeArmor) and player:getMark(fk.MarkArmorNullified) == 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, { skill_name = linglong.name })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local judgeData = {
      who = player,
      reason = "eight_diagram",
      pattern = ".|.|heart,diamond",
    }
    room:judge(judgeData)

    if judgeData.card.color == Card.Red then
      if event == fk.AskForCardUse then
        data.result = {
          from = player.id,
          card = Fk:cloneCard('jink'),
        }
        data.result.card.skillName = "eight_diagram"
        data.result.card.skillName = linglong.name

        if data.eventData then
          data.result.toCard = data.eventData.toCard
          data.result.responseToEvent = data.eventData.responseToEvent
        end
      else
        data.result = Fk:cloneCard('jink')
        data.result.skillName = "eight_diagram"
        data.result.skillName = linglong.name
      end
      return true
    end
  end,
})

linglong:addEffect(fk.AskForCardResponse, {
  frequency = Skill.Compulsory,
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(linglong) and not player:isFakeSkill(linglong) and
      (data.cardName == "jink" or (data.pattern and Exppattern:Parse(data.pattern):matchExp("jink|0|nosuit|none"))) and
      not player:getEquipment(Card.SubtypeArmor) and player:getMark(fk.MarkArmorNullified) == 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, { skill_name = linglong.name })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local judgeData = {
      who = player,
      reason = "eight_diagram",
      pattern = ".|.|heart,diamond",
    }
    room:judge(judgeData)

    if judgeData.card.color == Card.Red then
      if event == fk.AskForCardUse then
        data.result = {
          from = player.id,
          card = Fk:cloneCard('jink'),
        }
        data.result.card.skillName = "eight_diagram"
        data.result.card.skillName = linglong.name

        if data.eventData then
          data.result.toCard = data.eventData.toCard
          data.result.responseToEvent = data.eventData.responseToEvent
        end
      else
        data.result = Fk:cloneCard('jink')
        data.result.skillName = "eight_diagram"
        data.result.skillName = linglong.name
      end
      return true
    end
  end,
})

linglong:addEffect("maxcards", {
  name = "#linglong_maxcards",
  correct_func = function(self, player)
    if player:hasSkill(linglong) and player:getEquipment(Card.SubtypeOffensiveRide) == nil and
      player:getEquipment(Card.SubtypeDefensiveRide) == nil then
      return 1
    end
    return 0
  end,
})

linglong:addEffect("targetmod", {
  name = "#linglong_targetmod",
  frequency = Skill.Compulsory,
  bypass_distances = function(self, player, skill, card)
    return player:hasSkill(linglong) and player:getEquipment(Card.SubtypeTreasure) == nil and card and card.type == Card.TypeTrick
  end,
})

return linglong