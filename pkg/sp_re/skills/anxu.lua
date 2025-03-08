local anxu = fk.CreateSkill {
  name = "re__anxu"
}

Fk:loadTranslationTable{
  ['re__anxu'] = '安恤',
  ['#anxu-give'] = '安恤：你需将一张手牌交给 %dest',
  [':re__anxu'] = '出牌阶段限一次，你可以选择两名手牌数不同的其他角色，令其中手牌多的角色将一张手牌交给手牌少的角色，然后若这两名角色手牌数相等，你摸一张牌或回复1点体力。',
  ['$re__anxu1'] = '和鸾雍雍，万福攸同。',
  ['$re__anxu2'] = '君子乐胥，万邦之屏。',
}

anxu:addEffect('active', {
  anim_type = "control",
  card_num = 0,
  target_num = 2,
  can_use = function(self, player)
    return player:usedSkillTimes(anxu.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    if #selected > 1 or to_select == player.id then return false end
    if #selected == 0 then
      return true
    elseif #selected == 1 then
      local target1 = Fk:currentRoom():getPlayerById(to_select)
      local target2 = Fk:currentRoom():getPlayerById(selected[1])
      return #target1.player_cards[Player.Hand] ~= #target2.player_cards[Player.Hand]
    else
      return false
    end
  end,
  on_use = function(self, room, use)
    local player = room:getPlayerById(use.from)
    local target1 = room:getPlayerById(use.tos[1])
    local target2 = room:getPlayerById(use.tos[2])
    local from, to
    if target1:getHandcardNum() < target2:getHandcardNum() then
      from = target1
      to = target2
    else
      from = target2
      to = target1
    end
    local card = room:askToCards(to, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = anxu.name,
      cancelable = false,
      prompt = "#anxu-give::" .. from.id
    })
    room:obtainCard(from.id, Fk:getCardById(card[1]), false, fk.ReasonGive)
    if target1:getHandcardNum() == target2:getHandcardNum() and not player.dead then
      local choices = {"draw1"}
      if player:isWounded() then
        table.insert(choices, "recover")
      end
      local choice = room:askToChoice(player, {
        choices = choices,
        skill_name = anxu.name
      })
      if choice == "draw1" then
        player:drawCards(1, anxu.name)
      else
        room:recover({
          who = player,
          num = 1,
          recoverBy = player,
          skillName = anxu.name
        })
      end
    end
  end,
})

return anxu