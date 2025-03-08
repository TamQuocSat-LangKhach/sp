```lua
local jianshu = fk.CreateSkill {
  name = "jianshu"
}

Fk:loadTranslationTable{
  ['jianshu'] = '间书',
  ['#jianshu'] = '间书：将一张黑色手牌交给一名角色，再选择另一名角色与其拼点',
  ['#jianshu-choose'] = '间书：选择一名攻击范围内含有 %dest 的角色，两名角色拼点',
  [':jianshu'] = '限定技，出牌阶段，你可以将一张黑色手牌交给一名其他角色，并选择一名攻击范围内含有其的另一名角色，然后令这两名角色拼点：赢的角色弃置两张牌，没赢的角色失去1点体力。',
  ['$jianshu1'] = '来，让我看一出好戏吧。',
  ['$jianshu2'] = '纵有千军万马，离心则难成大事。',
}

jianshu:addEffect('active', {
  anim_type = "control",
  frequency = Skill.Limited,
  card_num = 1,
  target_num = 1,
  prompt = "#jianshu",
  can_use = function(skill, player)
    return player:usedSkillTimes(jianshu.name, Player.HistoryGame) == 0 and not player:isKongcheng()
  end,
  card_filter = function(skill, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).color == Card.Black
  end,
  target_filter = function(skill, player, to_select, selected)
    return #selected == 0 and to_select ~= player.id
  end,
  on_use = function(skill, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:obtainCard(target.id, Fk:getCardById(effect.cards[1]), false, fk.ReasonGive)
    local targets = {}
    for _, p in ipairs(room:getOtherPlayers(target)) do
      if p:inMyAttackRange(target) and target:canPindian(p) and p:canPindian(target) then
        table.insert(targets, p.id)
      end
    end
    if #targets == 0 then return end
    local to = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#jianshu-choose::" .. target.id,
      skill_name = jianshu.name,
      cancelable = false
    })
    to = room:getPlayerById(to[1])
    local pindian = target:pindian({to}, jianshu.name)
    if pindian.results[to.id].winner then
      local winner, loser
      if pindian.results[to.id].winner == target then
        winner = target
        loser = to
      else
        winner = to
        loser = target
      end
      room:askToDiscard(winner, {
        min_num = 2,
        max_num = 2,
        include_equip = true,
        skill_name = jianshu.name,
        cancelable = false
      })
      room:loseHp(loser, 1, jianshu.name)
    else
      room:loseHp(target, 1, jianshu.name)
      room:loseHp(to, 1, jianshu.name)
    end
  end,
})

return jianshu
```