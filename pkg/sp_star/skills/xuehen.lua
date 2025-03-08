local xuehen = fk.CreateSkill {
  name = "xuehen"
}

Fk:loadTranslationTable{
  ['xuehen'] = '雪恨',
  ['@@fenyong'] = '体力牌竖置',
  ['#xuehen-choice'] = '雪恨：选择一名角色视为对其使用【杀】，或点“取消”弃置 %dest %arg张牌',
  ['#xuehen-slash'] = '雪恨：选择一名角色视为对其使用【杀】',
  ['#xuehen-discard'] = '雪恨：弃置 %dest %arg张牌',
  [':xuehen'] = '每个角色的结束阶段开始时，若你的体力牌为竖置状态，你须横置之，然后选择一项：1.弃置当前回合角色X张牌（X为你已损失的体力值）；2.视为对一名任意角色使用一张【杀】。',
  ['$xuehen1'] = '汝等凶逆，岂欲望生乎！',
  ['$xuehen2'] = '夺目之恨犹在，今必斩汝！'
}

xuehen:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(skill, event, target, player)
    return player:hasSkill(xuehen.name) and target.phase == Player.Finish and player:getMark("@@fenyong") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(skill, event, target, player)
    local room = player.room
    room:setPlayerMark(player, "@@fenyong", 0)
    local choices = {}
    if room.current and not room.current.dead and not room.current:isNude() then
      table.insert(choices, "xuehen1")
    end
    if table.find(room:getOtherPlayers(player), function (p)
      return not player:isProhibited(p, Fk:cloneCard("slash"))
    end) then
      table.insert(choices, "xuehen2")
    end
    if #choices == 0 then return end
    if table.contains(choices, "xuehen2") then
      local cancelable = table.contains(choices, "xuehen1") and true or false
      local prompt = cancelable and "#xuehen-choice::"..room.current.id..":"..player:getLostHp() or "#xuehen-slash"
      if U.askForUseVirtualCard(room, player, "slash", nil, xuehen.name, prompt, cancelable, true, true, true) then
        return
      end
    end
    if table.contains(choices, "xuehen1") then
      local cards = room:askToChooseCards(player, {
        target = room.current,
        min = 1,
        max = player:getLostHp(),
        flag = "he",
        skill_name = xuehen.name,
        prompt = "#xuehen-discard::"..room.current.id..":"..player:getLostHp()
      })
      room:throwCard(cards, xuehen.name, room.current, player)
    end
  end,
})

return xuehen