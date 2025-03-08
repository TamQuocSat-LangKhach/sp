local duanbing = fk.CreateSkill {
  name = "duanbing"
}

Fk:loadTranslationTable{
  ['duanbing'] = '短兵',
  ['#duanbing-choose'] = '短兵：你可以额外选择一名距离为1的其他角色为目标',
  [':duanbing'] = '你使用【杀】时可以额外选择一名距离为1的其他角色为目标。',
}

duanbing:addEffect(fk.AfterCardTargetDeclared, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and data.card.trueName == "slash" and
      table.find(player.room:getUseExtraTargets(data), function(id)
        return player:distanceTo(player.room:getPlayerById(id)) == 1
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getUseExtraTargets(data), function(id)
      return player:distanceTo(room:getPlayerById(id)) == 1
    end)
    local tos = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#duanbing-choose",
      skill_name = skill.name,
      cancelable = true,
    })
    if #tos > 0 then
      event:setCostData(skill, tos[1]:objectName())
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    table.insert(data.tos, {event:getCostData(skill)})
  end,
})

return duanbing