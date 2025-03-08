local shenwei = fk.CreateSkill {
  name = "shenwei"
}

Fk:loadTranslationTable{
  ['shenwei'] = '神威',
  [':shenwei'] = '锁定技，摸牌阶段，你额外摸两张牌；你的手牌上限+2。',
}

shenwei:addEffect(fk.DrawNCards, {
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  on_use = function(skill, event, target, player, data)
    data.n = data.n + 2
  end,
})

shenwei:addEffect('maxcards', {
  name = "#shenwei_maxcards",
  correct_func = function(skill, player)
    if player:hasSkill(shenwei.name) then
      return 2
    end
  end,
})

return shenwei