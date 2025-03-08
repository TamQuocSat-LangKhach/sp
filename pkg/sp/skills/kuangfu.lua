local kuangfu = fk.CreateSkill {
  name = "kuangfu"
}

Fk:loadTranslationTable{
  ['kuangfu'] = '狂斧',
  ['kuangfu_discard'] = '弃置其一张装备',
  ['kuangfu_move'] = '将其一张装备置入你的装备区',
  [':kuangfu'] = '当你使用【杀】对目标角色造成一次伤害后，你可以选择一项: 将其装备区里的一张牌置入你的装备区；或弃置其装备区里的一张牌。',
  ['$kuangfu1'] = '吾乃上将潘凤，可斩华雄！',
  ['$kuangfu2'] = '这家伙，还是给我用吧！',
}

kuangfu:addEffect(fk.Damage, {
  anim_type = "offensive",
  can_trigger = function(skill, event, target, player, data)
    return target == player and player:hasSkill(kuangfu.name) and data.card and data.card.trueName == "slash" and
         not data.chain and not data.to.dead and #data.to:getCardIds("e") > 0
  end,
  on_use = function(skill, event, target, player, data)
    local room = player.room
    local choices = {"kuangfu_discard"}
    if data.to:canMoveCardsInBoardTo(player, "e") then
      table.insert(choices, 1, "kuangfu_move")
    end
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = kuangfu.name
    })
    if choice == "kuangfu_move" then
      room:askToMoveCardInBoard(player, {
        target_one = data.to,
        target_two = player,
        skill_name = kuangfu.name,
        flag = "e",
        move_from = data.to
      })
    else
      local id = room:askToChooseCard(player, {
        target = data.to,
        flag = "e",
        skill_name = kuangfu.name
      })
      room:throwCard({id}, kuangfu.name, data.to, player)
    end
  end,
})

return kuangfu