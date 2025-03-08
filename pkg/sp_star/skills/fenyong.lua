local fenyong = fk.CreateSkill {
  name = "fenyong"
}

Fk:loadTranslationTable{
  ['fenyong'] = '愤勇',
  ['@@fenyong'] = '体力牌竖置',
  ['#fenyong-invoke'] = '愤勇：你可以竖置你的体力牌！',
  [':fenyong'] = '每当你受到一次伤害后，你可以竖置你的体力牌；当你的体力牌为竖置状态时，防止你受到的所有伤害。',
  ['$fenyong1'] = '独目苍狼，虽伤亦勇！',
  ['$fenyong2'] = '愤勇当先，鬼神难伤！',
}

fenyong:addEffect(fk.Damaged, {
  can_trigger = function(skill, event, target, player)
    if target == player and player:hasSkill(fenyong.name) then
      return true
    end
  end,
  on_cost = function(skill, event, target, player)
    return player.room:askToSkillInvoke(player, {
      skill_name = fenyong.name,
      prompt = "#fenyong-invoke",
    })
  end,
  on_use = function(skill, event, target, player)
    local room = player.room
    room:notifySkillInvoked(player, fenyong.name)
    player:broadcastSkillInvoke(fenyong.name, 1)
    room:setPlayerMark(player, "@@fenyong", 1)
  end,
})

fenyong:addEffect(fk.DamageInflicted, {
  can_trigger = function(skill, event, target, player)
    if target == player and player:hasSkill(fenyong.name) then
      return player:getMark("@@fenyong") > 0
    end
  end,
  on_cost = function(skill, event, target, player)
    return true
  end,
  on_use = function(skill, event, target, player)
    local room = player.room
    room:notifySkillInvoked(player, fenyong.name)
    player:broadcastSkillInvoke(fenyong.name, 2)
    return true
  end,
})

return fenyong