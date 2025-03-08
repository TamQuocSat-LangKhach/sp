```lua
local juyi = fk.CreateSkill {
  name = "juyi"
}

Fk:loadTranslationTable{
  ['juyi'] = '举义',
  [':juyi'] = '觉醒技，准备阶段开始时，若你已受伤且体力上限大于存活角色数，你须将手牌摸至体力上限，然后获得技能“崩坏”和“威重”。',
  ['$juyi1'] = '司马氏篡权，我当替天伐之！',
  ['$juyi2'] = '若国有难，吾当举义。',
}

juyi:addEffect(fk.EventPhaseStart, {
  frequency = Skill.Wake,
  can_trigger = function(skill, event, target, player)
    return target == player and player:hasSkill(skill.name) and
      player.phase == Player.Start and
      player:usedSkillTimes(juyi.name, Player.HistoryGame) == 0
  end,
  can_wake = function(skill, event, target, player)
    return player:isWounded() and player.maxHp > #player.room.alive_players
  end,
  on_use = function(skill, event, target, player)
    local n = player.maxHp - player:getHandcardNum()
    if n > 0 then
      player:drawCards(n, juyi.name)
    end
    player.room:handleAddLoseSkills(player, "benghuai|weizhong", nil)
  end,
})

return juyi
```