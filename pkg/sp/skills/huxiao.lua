local huxiao = fk.CreateSkill {
  name = "huxiao"
}

Fk:loadTranslationTable{
  ['huxiao'] = '虎啸',
  [':huxiao'] = '若你于出牌阶段使用的【杀】被【闪】抵消，则本阶段你可以额外使用一张【杀】。',
  ['$huxiao1'] = '大仇未报，还不能放弃！',
  ['$huxiao2'] = '虎父无犬女！',
}

huxiao:addEffect(fk.CardEffectCancelledOut, {
  can_trigger = function(skill, event, target, player, data)
    return target == player and player:hasSkill(huxiao.name) and data.card.trueName == "slash" and player.phase == Player.Play
  end,
  on_use = function(skill, event, target, player, data)
    player.room:addPlayerMark(player, MarkEnum.SlashResidue.."-phase")
  end,
})

return huxiao