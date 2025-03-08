local sp__zhuiji = fk.CreateSkill {
  name = "sp__zhuiji"
}

Fk:loadTranslationTable{
  ['sp__zhuiji'] = '追击',
  [':sp__zhuiji'] = '锁定技，你计算体力值比你少的角色的距离始终为1。',
}

sp__zhuiji:addEffect('distance', {
  frequency = Skill.Compulsory,
  fixed_func = function(self, from, to)
    if from:hasSkill(sp__zhuiji.name) and from.hp >= to.hp then
      return 1
    end
  end,
})

return sp__zhuiji