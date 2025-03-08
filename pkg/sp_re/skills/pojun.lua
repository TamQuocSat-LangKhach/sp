```lua
local pojun = fk.CreateSkill {
  name = "re__pojun"
}

Fk:loadTranslationTable{
  ['re__pojun'] = '破军',
  ['$re__pojun'] = '破军',
  ['#re__pojun_delay'] = '破军',
  [':re__pojun'] = '当你于出牌阶段内使用【杀】指定一个目标后，你可以将其至多X张牌扣置于该角色的武将牌旁（X为其体力值）。若如此做，当前回合结束后，该角色获得其武将牌旁的所有牌。',
  ['$re__pojun1'] = '大军在此！汝等休想前进一步！',
  ['$re__pojun2'] = '敬请，养精蓄锐！',
}

pojun:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(pojun.name) and player.phase == Player.Play and data.card.trueName == "slash" and
      not player.room:getPlayerById(data.to):isNude()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(data.to)
    local cards = room:askToChooseCards(player, {
      target = to,
      min = 0,
      max = to.hp,
      flag = "he",
      skill_name = pojun.name
    })
    if #cards > 0 then
      to:addToPile("$re__pojun", cards, false, pojun.name)
    end
  end,
})

pojun:addEffect(fk.TurnEnd, {
  name = "#re__pojun_delay",
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return #player:getPile("$re__pojun") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:moveCardTo(player:getPile("$re__pojun"), Player.Hand, player, fk.ReasonPrey, "re__pojun")
  end,
})

return pojun
```