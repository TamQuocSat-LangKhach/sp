local weizhong = fk.CreateSkill {
  name = "weizhong"
}

Fk:loadTranslationTable{
  ['weizhong'] = '威重',
  [':weizhong'] = '锁定技，当你的体力上限增加或减少时，你摸一张牌。',
  ['$weizhong'] = '定当夷司马氏三族！',
}

weizhong:addEffect(fk.MaxHpChanged, {
  frequency = Skill.Compulsory,
  on_use = function(skill, event, target, player)
    player:drawCards(1, weizhong.name)
  end,
})

return weizhong