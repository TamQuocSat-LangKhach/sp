local jieyuan = fk.CreateSkill {
  name = "jieyuan"
}

Fk:loadTranslationTable{
  ['jieyuan'] = '竭缘',
  ['#jieyuan1-invoke'] = '竭缘：你可以弃置一张黑色手牌令对 %dest 造成的伤害+1',
  ['#jieyuan2-invoke'] = '竭缘：你可以弃置一张红色手牌令此伤害-1',
  [':jieyuan'] = '当你对一名其他角色造成伤害时，若其体力值大于或等于你的体力值，你可弃置一张黑色手牌令此伤害+1；当你受到一名其他角色造成的伤害时，若其体力值大于或等于你的体力值，你可弃置一张红色手牌令此伤害-1。',
  ['$jieyuan1'] = '我所有的努力，都是为了杀你！',
  ['$jieyuan2'] = '我必须活下去！',
}

jieyuan:addEffect(fk.DamageCaused, {
  mute = true,
  can_trigger = function(skill, event, target, player, data)
  if target == player and player:hasSkill(jieyuan.name) and not player:isKongcheng() then
    return data.to.hp >= player.hp
  end
  end,
  on_cost = function(skill, event, target, player, data)
  local pattern, prompt = ".|.|spade,club|.|.|.", "#jieyuan1-invoke::" .. data.to.id
  local card = player.room:askToDiscard(player, {
    min_num = 1,
    max_num = 1,
    include_equip = false,
    skill_name = jieyuan.name,
    cancelable = true,
    pattern = pattern,
    prompt = prompt,
    skip = true
  })
  if #card > 0 then
    event:setCostData(skill, card)
    return true
  end
  end,
  on_use = function(skill, event, target, player, data)
  local room = player.room
  room:throwCard(event:getCostData(skill), jieyuan.name, player, player)
  player:broadcastSkillInvoke(jieyuan.name, 1)
  room:notifySkillInvoked(player, jieyuan.name, "offensive")
  data.damage = data.damage + 1
  end,
})

jieyuan:addEffect(fk.DamageInflicted, {
  mute = true,
  can_trigger = function(skill, event, target, player, data)
  if target == player and player:hasSkill(jieyuan.name) and not player:isKongcheng() then
    return data.from and data.from.hp >= player.hp
  end
  end,
  on_cost = function(skill, event, target, player, data)
  local pattern, prompt = ".|.|heart,diamond|.|.|.", "#jieyuan2-invoke"
  local card = player.room:askToDiscard(player, {
    min_num = 1,
    max_num = 1,
    include_equip = false,
    skill_name = jieyuan.name,
    cancelable = true,
    pattern = pattern,
    prompt = prompt,
    skip = true
  })
  if #card > 0 then
    event:setCostData(skill, card)
    return true
  end
  end,
  on_use = function(skill, event, target, player, data)
  local room = player.room
  room:throwCard(event:getCostData(skill), jieyuan.name, player, player)
  player:broadcastSkillInvoke(jieyuan.name, 2)
  room:notifySkillInvoked(player, jieyuan.name, "defensive")
  data.damage = data.damage - 1
  end,
})

return jieyuan