local shichou = fk.CreateSkill {
  name = "shichou"
}

Fk:loadTranslationTable {
  ['shichou'] = '誓仇',
  ['#shichou-choose'] = '是否使用誓仇，为此%arg额外指定至多%arg2个目标',
  [':shichou'] = '你使用【杀】可以额外选择至多X名角色为目标（X为你已损失的体力值）。',
  ['$shichou1'] = '灭族之恨，不共戴天！',
  ['$shichou2'] = '休想跑！',
}

shichou:addEffect(fk.AfterCardTargetDeclared, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(shichou.name) and player:isWounded() and data.card.trueName == "slash" and
        #data:getExtraTargets() > 0
  end,
  on_cost = function(self, event, target, player, data)
    local n = player:getLostHp()
    local tos = player.room:askToChoosePlayers(player, {
      targets = data:getExtraTargets(),
      min_num = 1,
      max_num = n,
      prompt = "#shichou-choose:::" .. data.card:toLogString() .. ":" .. tostring(n),
      skill_name = shichou.name,
      cancelable = true
    })
    if #tos > 0 then
      event:setCostData(self, tos)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    for _, p in ipairs(event:getCostData(self)) do
      data:addTarget(p)
    end
  end,
})

return shichou
