local aozhan = fk.CreateSkill {
  name = "hulao__aozhan",
  frequency = Skill.Compulsory,
}

Fk:loadTranslationTable {
  ['hulao__aozhan'] = '鏖战',
  [':hulao__aozhan'] = '锁定技，若你装备区里有：武器牌，你可以多使用一张【杀】；防具牌，防止你受到的超过1点的伤害；坐骑牌，摸牌阶段多摸一张牌；宝物牌，跳过你的判定阶段。',
}

aozhan:addEffect(fk.DrawNCards, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player)
    if not player:hasSkill(aozhan.name) or target ~= player then return false end
    return #player:getEquipments(Card.SubtypeOffensiveRide) > 0 or
        #player:getEquipments(Card.SubtypeDefensiveRide) > 0
  end,
  on_use = function(self, event, target, player, data)
    data.n = data.n + 1
  end,
})

aozhan:addEffect(fk.DamageInflicted, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(aozhan.name) or target ~= player then return false end
    return #player:getEquipments(Card.SubtypeArmor) > 0 and data.damage > 1
  end,
  on_use = function(self, event, target, player, data)
    data.damage = 1
  end,
})

aozhan:addEffect(fk.EventPhaseChanging, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(aozhan.name) or target ~= player then return false end
    return data.to == Player.Judge and #player:getEquipments(Card.SubtypeTreasure) > 0
  end,
  on_use = function(self, event, target, player, data)
    return true
  end,
})

aozhan:addEffect('targetmod', {
  anim_type = "offensive",
  residue_func = function(self, player, skill_name, scope)
    if player:hasSkill(aozhan.name) and #player:getEquipments(Card.SubtypeWeapon) > 0 and
        skill_name == "slash_skill" and scope == Player.HistoryPhase then
      return 1
    end
  end,
})

return aozhan
