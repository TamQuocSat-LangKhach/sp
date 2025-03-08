local zhuji = fk.CreateSkill {
  name = "zhuji"
}

Fk:loadTranslationTable{
  ['zhuji'] = '助祭',
  ['#zhuji-invoke'] = '你可发动助祭，令%src判定，若为黑色则对%dest造成的伤害+1，红色则其获得判定牌',
  ['#zhuji_delay'] = '助祭',
  [':zhuji'] = '当一名角色造成雷电伤害时，你可以令其进行一次判定，若结果为黑色，此伤害+1；若结果为红色，该角色获得此牌。',
  ['$zhuji1'] = '大神宏量，请昭太平！',
  ['$zhuji2'] = '惠民济困，共辟黄天。',
}

zhuji:addEffect(fk.DamageCaused, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(zhuji) and data.damageType == fk.ThunderDamage and data.from and not data.from.dead
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {skill_name = zhuji.name, prompt = "#zhuji-invoke:"..data.from.id .. ":" .. data.to.id})
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = data.from
    local judge = {
    who = to,
    reason = zhuji.name,
    pattern = ".",
    }
    room:judge(judge)
    if judge.card.color == Card.Black then
    data.damage = data.damage + 1
    end
  end,
})

zhuji:addEffect(fk.FinishJudge, {
  global = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and not player.dead and data.card.color == Card.Red and data.reason == zhuji.name
    and player.room:getCardArea(data.card.id) == Card.Processing
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:obtainCard(player.id, data.card)
  end,
})

return zhuji