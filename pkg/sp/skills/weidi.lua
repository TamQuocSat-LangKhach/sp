local weidi = fk.CreateSkill {
  name = "weidi",
  frequency = Skill.Compulsory,
}

Fk:loadTranslationTable{
  ['weidi'] = '伪帝',
  [':weidi'] = '锁定技，你视为拥有主公的主公技。',
  ['$weidi1'] = '你们都得听我的号令！',
  ['$weidi2'] = '我才是皇帝！',
}

weidi:addEffect(fk.GameStart, {
  can_trigger = function(self, event, target, player)
    if not player:hasSkill(weidi.name) then return false end
    local lordCheck = table.find(player.room.alive_players, function (p)
      return p ~= player and p.role == "lord" and
        table.find(p.player_skills, function(s)
          return s:hasTag(Skill.Lord) and not player:hasSkill(s, true)
        end) ~= nil
    end)
    return lordCheck
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    local skills = {}
    for _, p in ipairs(room.alive_players) do
      if p ~= player and p.role == "lord" then
        for _, s in ipairs(p.player_skills) do
          if s:hasTag(Skill.Lord) and not player:hasSkill(s, true) then
            table.insert(skills, s.name)
          end
        end
      end
    end
    if #skills > 0 then
      room:handleAddLoseSkills(player, table.concat(skills, "|"), nil)
    end
  end,
})

weidi:addEffect(fk.EventAcquireSkill, {
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(weidi.name) then return false end
    local lordCheck = table.find(player.room.alive_players, function (p)
      return p ~= player and p.role == "lord" and
        table.find(p.player_skills, function(s)
          return s:hasTag(Skill.Lord) and not player:hasSkill(s, true)
        end) ~= nil
    end)
    if target == player then
      return data.skill.name == weidi.name and player.room:getBanner("RoundCount") and lordCheck
    else
      return data.skill:hasTag(Skill.Lord) and not player:hasSkill(data.skill, true) and
        target.role == "lord"
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local skills = {}
    if target == player then
      for _, p in ipairs(room.alive_players) do
        if p ~= player and p.role == "lord" then
          for _, s in ipairs(p.player_skills) do
            if s:hasTag(Skill.Lord) and not player:hasSkill(s, true)  then
              table.insert(skills, s.name)
            end
          end
        end
      end
    else
      table.insert(skills, data.skill.name)
    end
    if #skills > 0 then
      room:handleAddLoseSkills(player, table.concat(skills, "|"), nil)
    end
  end,
})

return weidi