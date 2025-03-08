```lua
local qiangwu = fk.CreateSkill {
  name = "qiangwu"
}

Fk:loadTranslationTable{
  ['qiangwu'] = '枪舞',
  ['#qiangwu'] = '枪舞：进行判定，根据点数本回合使用【杀】获得增益',
  ['@qiangwu-turn'] = '枪舞',
  [':qiangwu'] = '出牌阶段限一次，你可以进行一次判定，若如此做，则直到回合结束，你使用点数小于判定牌的【杀】时不受距离限制，且你使用点数大于判定牌的【杀】时不计入出牌阶段的使用次数。',
  ['$qiangwu1'] = '父亲未尽之业，由我继续！',
  ['$qiangwu2'] = '咆哮沙场，万夫不敌！',
}

-- 主动技能
qiangwu:addEffect('active', {
  anim_type = "offensive",
  card_num = 0,
  target_num = 0,
  prompt = "#qiangwu",
  can_use = function(self, player)
    return player:usedSkillTimes(qiangwu.name) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local judge = {
    who = player,
    reason = qiangwu.name,
    pattern = ".",
    }
    room:judge(judge)
    room:setPlayerMark(player, "@qiangwu-turn", judge.card.number)
  end,
})

-- 触发技能
qiangwu:addEffect(fk.AfterCardUseDeclared, {
  anim_type = "offensive",
  can_refresh = function(self, event, target, player, data)
  return target == player and player:hasSkill(qiangwu) and player:getMark("@qiangwu-turn") > 0 and
    data.card.trueName == "slash" and data.card.number and data.card.number > player:getMark("@qiangwu-turn") and
    not data.extraUse
  end,
  on_refresh = function(self, event, target, player, data)
  data.extraUse = true
  player:addCardUseHistory(data.card.trueName, -1)
  end,
})

-- 目标修正技能
qiangwu:addEffect('targetmod', {
  distance_limit_func = function(self, player, skill, card)
  if skill.trueName == "slash_skill" and player:getMark("@qiangwu-turn") ~= 0 and card.number < player:getMark("@qiangwu-turn") then
    return 999
  end
  return 0
  end,
})

return qiangwu
```

这个技能代码中没有使用到任何需要重构的`askForXXX`方法，所以不需要进行改动。