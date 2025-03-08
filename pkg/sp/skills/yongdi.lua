local yongdi = fk.CreateSkill {
  name = "yongdi",
  frequency = Skill.Limited,
}

Fk:loadTranslationTable {
  ['yongdi'] = '拥嫡',
  ['#yongdi-choose'] = '拥嫡：你可令一名其他男性角色增加1点体力上限并获得其武将牌上的主公技',
  [':yongdi'] = '限定技，当你受到伤害后，你可令一名其他男性角色增加1点体力上限，然后若该角色的武将牌上有主公技且其身份不为主公，其获得此主公技。',
  ['$yongdi1'] = '臣愿为世子，肝脑涂地。',
  ['$yongdi2'] = '嫡庶有别，尊卑有序。',
}

yongdi:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return target == player and target:hasSkill(yongdi.name) and
        player:usedSkillTimes(yongdi.name, Player.HistoryGame) == 0 and
        table.find(player.room:getOtherPlayers(player), function(p) return p:isMale() end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      targets = table.filter(room:getOtherPlayers(player), function(p)
        return p:isMale()
      end),
      min_num = 1,
      max_num = 1,
      prompt = "#yongdi-choose",
      skill_name = yongdi.name
    })

    if #to > 0 then
      event:setCostData(self, to[1])
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self)
    room:changeMaxHp(to, 1)

    if to.role ~= "lord" then
      for _, skill in ipairs(Fk.generals[to.general].skills) do
        if skill:hasTag(Skill.Lord) then
          room:handleAddLoseSkills(to, skill.name, nil)
        end
      end

      if to.deputyGeneral ~= "" then
        for _, skill in ipairs(Fk.generals[to.deputyGeneral].skills) do
          if skill:hasTag(Skill.Lord) then
            room:handleAddLoseSkills(to, skill.name, nil)
          end
        end
      end
    end
  end,
})

return yongdi
