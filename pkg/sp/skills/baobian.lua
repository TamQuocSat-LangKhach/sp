local baobian = fk.CreateSkill {
  name = "baobian"
}

Fk:loadTranslationTable{
  ['baobian'] = '豹变',
  [':baobian'] = '锁定技，若你的体力值为3或更少，你视为拥有技能〖挑衅〗；若你的体力值为2或更少，你视为拥有技能〖咆哮〗；若你的体力值为1，你视为拥有技能〖神速〗。',
  ['$baobian1'] = '变可生，不变则死。',
  ['$baobian2'] = '适时而动，穷极则变。',
}

baobian:addEffect(fk.HpChanged, {
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  on_use = function(skill, event, target, player, data)
    BaobianChange(player, 1, "ol_ex__shensu", baobian.name)
    BaobianChange(player, 2, "ex__paoxiao", baobian.name)
    BaobianChange(player, 3, "ol_ex__tiaoxin", baobian.name)
  end,
})

baobian:addEffect(fk.MaxHpChanged, {
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  on_use = function(skill, event, target, player, data)
    BaobianChange(player, 1, "ol_ex__shensu", baobian.name)
    BaobianChange(player, 2, "ex__paoxiao", baobian.name)
    BaobianChange(player, 3, "ol_ex__tiaoxin", baobian.name)
  end,
})

return baobian