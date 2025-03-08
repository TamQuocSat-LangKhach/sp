local hongyuan = fk.CreateSkill {
  name = "hongyuan"
}

Fk:loadTranslationTable{
  ['hongyuan'] = '弘援',
  ['#hongyuan-cost'] = '弘援：你可以少摸一张牌，令至多两名其他角色各摸一张牌',
  ['#hongyuan_delay'] = '弘援',
  [':hongyuan'] = '摸牌阶段，你可以少摸一张牌，令至多两名其他角色各摸一张牌。',
  ['$hongyuan1'] = '诸将莫慌，粮草已到。',
  ['$hongyuan2'] = '自舍其身，施于天下。',
}

hongyuan:addEffect(fk.DrawNCards, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
  return target == player and player:hasSkill(hongyuan.name) and data.n > 0
  end,
  on_cost = function(self, event, target, player, data)
  local tos = player.room:askToChoosePlayers(player, {
    targets = table.map(player.room:getOtherPlayers(player, false), Util.IdMapper),
    min_num = 1,
    max_num = 2,
    prompt = "#hongyuan-cost",
    skill_name = hongyuan.name,
    cancelable = true
  })
  if #tos > 0 then
    event:setCostData(self, tos)
    return true
  end
  end,
  on_use = function(self, event, target, player, data)
  data.n = data.n - 1
  player.room:setPlayerMark(player, "hongyuan_targets-phase", event:getCostData(self))
  end,
})

hongyuan:addEffect(fk.EventPhaseEnd, {
  anim_type = "support",
  mute = true,
  can_trigger = function(self, event, target, player, data)
  return not player.dead and type(player:getMark("hongyuan_targets-phase")) == "table"
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
  local room = player.room
  local tos = player:getMark("hongyuan_targets-phase")
  for _, id in ipairs(tos) do
    local p = room:getPlayerById(id)
    if not p.dead then
    room:drawCards(p, 1, hongyuan.name)
    end
  end
  end,
})

return hongyuan