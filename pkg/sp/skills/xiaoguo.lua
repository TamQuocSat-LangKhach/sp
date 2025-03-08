local xiaoguo = fk.CreateSkill {
  name = "xiaoguo"
}

Fk:loadTranslationTable{
  ['xiaoguo'] = '骁果',
  ['#xiaoguo-invoke'] = '骁果：你可以弃置一张基本牌，%dest 需弃置一张装备牌并令你摸一张牌，否则你对其造成1点伤害',
  ['#xiaoguo-discard'] = '骁果：你需弃置一张装备牌并令 %src 摸一张牌，否则其对你造成1点伤害',
  [':xiaoguo'] = '其他角色的结束阶段开始时，你可以弃置一张基本牌。若如此做，该角色需弃置一张装备牌并令你摸一张牌，否则受到你对其造成的1点伤害。',
  ['$xiaoguo1'] = '三军听我号令，不得撤退！',
  ['$xiaoguo2'] = '看我先登城头，立下首功！',
}

xiaoguo:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player)
    return target ~= player and player:hasSkill(xiaoguo.name) and target.phase == Player.Finish and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player)
    local card = player.room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = xiaoguo.name,
      cancelable = true,
      pattern = ".|.|.|.|.|basic",
      prompt = "#xiaoguo-invoke::" .. target.id,
      skip = true
    })
    if #card > 0 then
      event:setCostData(self, card)
      return true
    end
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    room:throwCard(event:getCostData(self), xiaoguo.name, player, player)
    if target.dead then return end
    if #room:askToDiscard(target, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = xiaoguo.name,
      cancelable = true,
      pattern = ".|.|.|.|.|equip",
      prompt = "#xiaoguo-discard:" .. player.id,
      skip = true
    }) > 0 then
      if not player.dead then
        player:drawCards(1, xiaoguo.name)
      end
    else
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = xiaoguo.name,
      }
    end
  end,
})

return xiaoguo