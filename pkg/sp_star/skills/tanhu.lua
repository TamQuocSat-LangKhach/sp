local tanhu = fk.CreateSkill {
  name = "tanhu"
}

Fk:loadTranslationTable{
  ['tanhu'] = '探虎',
  ['#tanhu'] = '探虎：与一名角色拼点，若你赢，你与其距离视为1且你对其使用普通锦囊不能被响应直到回合结束',
  ['#tanhu_trigger'] = '探虎',
  [':tanhu'] = '出牌阶段限一次，你可与一名其他角色拼点。若你赢，你获得以下技能直到回合结束：你与该角色的距离视为1，你对该角色使用的非延时类锦囊牌不能被抵消。',
}

-- 主动技
tanhu:addEffect('active', {
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  prompt = "#tanhu",
  can_use = function(self, player)
  return not player:isKongcheng() and player:usedSkillTimes(tanhu.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
  return #selected == 0 and to_select ~= player.id and player:canPindian(Fk:currentRoom():getPlayerById(to_select))
  end,
  on_use = function(self, room, effect)
  local player = room:getPlayerById(effect.from)
  local target = room:getPlayerById(effect.tos[1])
  local pindian = player:pindian({target}, tanhu.name)
  if pindian.results[target.id].winner == player then
    room:addTableMarkIfNeed(player, "tanhu-turn", target.id)
  end
  end,
})

-- 距离技能
tanhu:addEffect('distance', {
  name = "#tanhu_distance",
  correct_func = function(self, from, to) return 0 end,
  fixed_func = function(self, from, to)
  local mark = from:getTableMark("tanhu-turn")
  if table.contains(mark, to.id) then
    return 1
  end
  end,
})

-- 触发技
tanhu:addEffect(fk.CardUsing, {
  name = "#tanhu_trigger",
  mute = true,
  can_trigger = function(self, event, target, player, data)
  return target == player and player:getMark("tanhu-turn") ~= 0 and data.card:isCommonTrick() and data.tos and
    table.find(TargetGroup:getRealTargets(data.tos), function(id) return table.contains(player:getMark("tanhu-turn"), id) end)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
  data.unoffsetableList = table.map(player.room.alive_players, Util.IdMapper)
  end,
})

return tanhu