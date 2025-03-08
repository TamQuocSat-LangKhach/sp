local cihuai = fk.CreateSkill {
  name = "cihuai"
}

Fk:loadTranslationTable{
  ['cihuai'] = '刺槐',
  ['#cihuai_invoke'] = '刺槐',
  [':cihuai'] = '出牌阶段开始时，你可以展示你的手牌，若其中没有【杀】，则你使用或打出【杀】时不需要手牌，直到你的手牌数变化或有角色死亡。',
}

-- ViewAsSkill 部分
cihuai:addEffect('viewas', {
  anim_type = "offensive",
  pattern = "slash",
  card_filter = function(skill, player, to_select, selected)
  return false
  end,
  view_as = function(skill, player, cards)
  if player:getMark("cihuai") == 0 then return end
  local c = Fk:cloneCard("slash")
  c.skillName = skill.name
  return c
  end,
})

-- TriggerSkill 部分
cihuai:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(skill, event, target, player)
  return target == player and player:hasSkill(cihuai.name) and player.phase == Player.Play and not player:isKongcheng()
  end,
  on_cost = function(skill, event, target, player)
  return player.room:askToSkillInvoke(player, { skill_name = cihuai.name })
  end,
  on_use = function(skill, event, target, player)
  local cards = player.player_cards[Player.Hand]
  player:showCards(cards)
  for _, id in ipairs(cards) do
    if Fk:getCardById(id).trueName == "slash" then
    return
    end
  end
  player.room:addPlayerMark(player, "cihuai", 1)
  end,
  
  can_refresh = function(skill, event, target, player)
  if player:hasSkill(cihuai.name, true) then
    if event == fk.AfterCardsMove then
    for _, move in ipairs(target or {}) do
      if move.from == player.id or move.to == player.id then
      for _, info in ipairs(move.moveInfo) do
        if info.fromArea == Card.PlayerHand or info.toArea == Card.PlayerHand then
        return true
        end
      end
      end
    end
    else
    return true
    end
  end
  end,
  on_refresh = function(skill, event, target, player)
  player.room:setPlayerMark(player, "cihuai", 0)
  end,
})

return cihuai