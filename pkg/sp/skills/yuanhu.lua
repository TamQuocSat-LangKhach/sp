```lua
local yuanhu = fk.CreateSkill {
  name = "yuanhu"
}

Fk:loadTranslationTable{
  ['yuanhu'] = '援护',
  ['#yuanhu_active'] = '援护',
  ['#yuanhu-invoke'] = '援护：你可以将一张装备牌置入一名角色的装备区',
  ['#yuanhu-choose'] = '援护：弃置 %dest 距离1的一名角色区域中的一张牌',
  [':yuanhu'] = '结束阶段开始时，你可以将一张装备牌置于一名角色的装备区里，然后根据此装备牌的种类执行以下效果：<br>武器牌：弃置与该角色距离为1的一名角色区域中的一张牌；<br>防具牌：该角色摸一张牌；<br>坐骑牌：该角色回复1点体力。',
  ['$yuanhu1'] = '将军，这件兵器可还趁手？',
  ['$yuanhu2'] = '刀剑无眼，须得小心防护。',
  ['$yuanhu3'] = '宝马配英雄！哈哈哈哈……',
}

yuanhu:addEffect(fk.EventPhaseStart, {
  mute = true,
  can_trigger = function(self, event, target, player)
    return target == player and player:hasSkill(yuanhu.name) and player.phase == Player.Finish
  end,
  on_cost = function (self, event, target, player)
    local success, dat = player.room:askToUseActiveSkill(player, {
      skill_name = "#yuanhu_active",
      prompt = "#yuanhu-invoke",
      cancelable = true,
    })
    if success and dat then
      event:setCostData(self, {cards = dat.cards, tos = dat.targets})
      return true
    end
  end,
  on_use = function (self, event, target, player)
    local room = player.room
    room:notifySkillInvoked(player, yuanhu.name, "support", event:getCostData(self).tos)
    local to = room:getPlayerById(event:getCostData(self).tos[1])
    local card = Fk:getCardById(event:getCostData(self).cards[1])
    room:moveCardIntoEquip(to, event:getCostData(self).cards[1], yuanhu.name, false, player)
    if to.dead then return end
    if card.sub_type == Card.SubtypeWeapon then
      player:broadcastSkillInvoke("yuanhu", 1)
      local targets = {}
      for _, p in ipairs(room:getOtherPlayers(to)) do
        if target:distanceTo(p) == 1 and not p:isAllNude() then
          table.insertIfNeed(targets, p.id)
        end
      end
      if #targets == 0 or player.dead then return end
      local p = room:askToChoosePlayers(player, {
        targets = targets,
        min_num = 1,
        max_num = 1,
        prompt = "#yuanhu-choose::"..to.id,
        skill_name = yuanhu.name,
        cancelable = false,
      })
      if #p > 0 then
        card = room:askToChooseCard(player, {
          target = room:getPlayerById(p[1]),
          flag = "hej",
          skill_name = yuanhu.name,
        })
        room:throwCard(card, yuanhu.name, room:getPlayerById(p[1]), player)
      end
    elseif card.sub_type == Card.SubtypeArmor then
      player:broadcastSkillInvoke("yuanhu", 2)
      to:drawCards(1, yuanhu.name)
    elseif card.sub_type == Card.SubtypeOffensiveRide or card.sub_type == Card.SubtypeDefensiveRide then
      player:broadcastSkillInvoke("yuanhu", 3)
      if to:isWounded() then
        room:recover({
          who = to,
          num = 1,
          recoverBy = player,
          skillName = yuanhu.name,
        })
      end
    end
  end,
})

return yuanhu
```