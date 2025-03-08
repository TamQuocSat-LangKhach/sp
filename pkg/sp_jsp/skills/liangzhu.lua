local liangzhu = fk.CreateSkill {
  name = "liangzhu"
}

Fk:loadTranslationTable{
  ['liangzhu'] = '良助',
  ['#liangzhu-invoke'] = '良助：你可以摸一张牌或令 %dest 摸两张牌',
  ['liangzhu_draw2'] = '其摸两张牌',
  [':liangzhu'] = '当一名角色于其出牌阶段内回复体力时，你可以选择一项：1.摸一张牌；2.令该角色摸两张牌。',
  ['$liangzhu1'] = '吾愿携弩，征战沙场，助君一战！',
  ['$liangzhu2'] = '两国结盟，你我都是一家人。',
}

liangzhu:addEffect(fk.HpRecover, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player)
    return player:hasSkill(liangzhu.name) and target.phase == Player.Play
  end,
  on_cost = function(self, event, target, player)
    return player.room:askToSkillInvoke(player, {
      skill_name = liangzhu.name,
      prompt = "#liangzhu-invoke::"..target.id,
    })
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    local choice = room:askToChoice(player, {
      choices = {"draw1", "liangzhu_draw2"},
      skill_name = liangzhu.name,
    })
    if choice == "draw1" then
      player:drawCards(1, liangzhu.name)
    else
      room:doIndicate(player.id, {target.id})
      target:drawCards(2, liangzhu.name)
      room:addTableMarkIfNeed(player, "liangzhu_target", target.id)
    end
  end,
})

return liangzhu