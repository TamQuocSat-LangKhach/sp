local mouduan = fk.CreateSkill {
  name = "mouduan"
}

Fk:loadTranslationTable{
  ['mouduan'] = '谋断',
  ['#mouduan-invoke'] = '谋断：你可以弃置一张牌，转换状态',
  [':mouduan'] = '转化技，通常状态下，你拥有标记“武”并拥有技能〖激昂〗和〖谦逊〗。当你的手牌数为2张或以下时，你须将你的标记翻面为“文”，将该两项技能转化为〖英姿〗和〖克己〗。任一角色的回合开始前，你可弃一张牌将标记翻回。<br><font color=>转换技，阳：你拥有〖激昂〗和〖谦逊〗，当你失去手牌后，若你的手牌数小于等于2，你发动此技能；阴，你拥有〖英姿〗和〖克己〗，一名角色回合开始前，你可以弃置一张牌。',
}

mouduan:addEffect(fk.AfterCardsMove, {
  can_trigger = function(skill, event, target, player, data)
  if player:hasSkill(mouduan) then
    if player:getSwitchSkillState(mouduan.name, false) == fk.SwitchYang then
    for _, move in ipairs(data) do
      if move.from == player.id then
      return player:getHandcardNum() < 3
      end
    end
    end
  end
  end,
  on_cost = function(skill, event, target, player, data)
  return true
  end,
  on_use = function(skill, event, target, player, data)
  local room = player.room
  if player:getSwitchSkillState(mouduan.name, true) == fk.SwitchYang then
    room:handleAddLoseSkills(player, "-jiang|-qianxun|yingzi|keji", nil, false, true)
  end
  end,
})

mouduan:addEffect(fk.TurnStart, {
  can_trigger = function(skill, event, target, player, data)
  if player:hasSkill(mouduan) then
    return player:getSwitchSkillState(mouduan.name, false) ~= fk.SwitchYang
  end
  end,
  on_cost = function(skill, event, target, player, data)
  local card = player.room:askToDiscard(player, {
    min_num = 1,
    max_num = 1,
    include_equip = true,
    skill_name = mouduan.name,
    cancelable = true,
    pattern = ".",
    prompt = "#mouduan-invoke"
  })
  if #card > 0 then
    event:setCostData(skill, card)
    return true
  end
  end,
  on_use = function(skill, event, target, player, data)
  local room = player.room
  room:handleAddLoseSkills(player, "jiang|qianxun|-yingzi|-keji", nil, false, true)
  room:throwCard(event:getCostData(skill), mouduan.name, player, player)
  end,
})

mouduan:addEffect(fk.GameStart, {
  can_refresh = function(skill, event, target, player, data)
  return player:hasSkill(mouduan)
  end,
  on_refresh = function(skill, event, target, player, data)
  local room = player.room
  room:handleAddLoseSkills(player, "jiang|qianxun", nil, false, true)
  end,
})

mouduan:addEffect(fk.EventAcquireSkill, {
  can_refresh = function(skill, event, target, player, data)
  return target == player and data == mouduan
  end,
  on_refresh = function(skill, event, target, player, data)
  local room = player.room
  room:handleAddLoseSkills(player, "jiang|qianxun", nil, false, true)
  end,
})

mouduan:addEffect(fk.EventLoseSkill, {
  can_refresh = function(skill, event, target, player, data)
  return target == player and data == mouduan
  end,
  on_refresh = function(skill, event, target, player, data)
  local room = player.room
  room:handleAddLoseSkills(player, "-jiang|-qianxun|-yingzi|-keji", nil, false, true)
  end,
})

return mouduan