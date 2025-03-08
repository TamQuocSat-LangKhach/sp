local meibu = fk.CreateSkill {
  name = "meibu"
}

Fk:loadTranslationTable{
  ['meibu'] = '魅步',
  ['#meibu-invoke'] = '魅步：你可以对 %dest 发动“魅步”，令其锦囊牌视为【杀】直到回合结束',
  ['#meibu_filter'] = '止息',
  [':meibu'] = '一名其他角色的出牌阶段开始时，若你不在其攻击范围内，你可以令该角色的锦囊牌均视为【杀】直到回合结束。若如此做，视为你在其攻击范围内直到回合结束。',
  ['$meibu1'] = '萧墙之乱，宫闱之衅，实为吴国之祸啊！',
  ['$meibu2'] = '若要动手，就请先杀我吧！',
}

meibu:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player)
    return player:hasSkill(meibu.name) and target.phase == Player.Play and target ~= player and
      not target:inMyAttackRange(player) and not target.dead
  end,
  on_cost = function(self, event, target, player)
    return player.room:askToSkillInvoke(player, {
      skill_name = meibu.name,
      prompt = "#meibu-invoke::"..target.id
    })
  end,
  on_use = function(self, event, target, player)
    player.room:setPlayerMark(target, "meibu-turn", 1)
  end
})

meibu:addEffect('atkrange', {
  name = "#meibu_attackrange",
  within_func = function (self, from, to)
    return from.phase ~= Player.NotActive and to:usedSkillTimes(meibu.name, Player.HistoryTurn) > 0
  end,
})

meibu:addEffect('filter', {
  name = "#meibu_filter",
  card_filter = function(self, player, to_select)
    return player:getMark("meibu-turn") > 0 and to_select.type == Card.TypeTrick and
      table.contains(player.player_cards[Player.Hand], to_select.id)
  end,
  view_as = function(self, player, to_select)
    local card = Fk:cloneCard("slash", to_select.suit, to_select.number)
    card.skillName = meibu.name
    return card
  end,
})

return meibu