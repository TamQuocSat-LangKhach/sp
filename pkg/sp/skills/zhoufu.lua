```lua
local zhoufu = fk.CreateSkill {
  name = "zhoufu"
}

Fk:loadTranslationTable{
  ['zhoufu'] = '咒缚',
  ['#zhoufu'] = '咒缚：将一张手牌置为一名角色的“咒缚”牌，其判定时改为将“咒缚”牌作为判定牌',
  ['$zhangbao_zhou'] = '咒',
  ['#zhoufu_trigger'] = '咒缚',
  [':zhoufu'] = '出牌阶段限一次，你可以指定一名其他角色并将一张手牌移出游戏（将此牌置于该角色的武将牌旁），若如此做，该角色进行判定时，改为将此牌作为判定牌。该角色的回合结束时，若此牌仍在该角色旁，你将此牌收入手牌。',
  ['$zhoufu1'] = '违吾咒者，倾死灭亡。',
  ['$zhoufu2'] = '咒宝符命，速显威灵。',
}

zhoufu:addEffect('active', {
  anim_type = "control",
  card_num = 1,
  target_num = 1,
  prompt = "#zhoufu",
  can_use = function(self, player)
    return player:usedSkillTimes(zhoufu.name) == 0 and not player:isKongcheng()
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
  end,
  target_filter = function(self, player, to_select, selected, cards)
    return #selected == 0 and to_select ~= player.id and #Fk:currentRoom():getPlayerById(to_select):getPile("$zhangbao_zhou") == 0
  end,
  on_use = function(self, room, effect)
    local target = room:getPlayerById(effect.tos[1])
    target:addToPile("$zhangbao_zhou", effect.cards, false, zhoufu.name)
  end,
})

zhoufu:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, player, data)
    return #player:getPile("$zhangbao_zhou") > 0 and player:hasSkill(zhoufu) and player.phase == Player.NotActive
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, player, data)
    player.room:moveCards({
      from = player.id,
      ids = player:getPile("$zhangbao_zhou"),
      to = player.id,
      toArea = Card.PlayerHand,
      moveReason = fk.ReasonJustMove,
      skillName = zhoufu.name,
    })
  end,

  can_refresh = function(self, event, target, data)
    return #target:getPile("$zhangbao_zhou") > 0
  end,
  on_refresh = function(self, event, player, data)
    data.card = Fk:getCardById(player:getPile("$zhangbao_zhou")[1])
    data.card.skillName = zhoufu.name
  end,
})

return zhoufu
```