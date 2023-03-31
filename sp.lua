local extension = Package("sp")
extension.extensionName = "sp"

Fk:loadTranslationTable{
  ["sp"] = "SP",
}

Fk:loadTranslationTable{
  ["yangxiu"] = "杨修",
  ["danlao"] = "啖酪",
  [":danlao"] = "当一个锦囊指定了包括你在内的多个目标，你可以摸一张牌，若如此做，该锦囊对你无效。",
  ["jilei"] = "鸡肋",
  [":jilei"] = "当你受到伤害时，你可以声明一种牌的类别（基本牌、锦囊牌、装备牌），对你造成伤害的角色不能使用、打出或弃置该类别的手牌直到回合结束。",
}
local gongsunzan = General(extension, "gongsunzan", "qun", 4)
local yicong = fk.CreateDistanceSkill{
  name = "yicong",
  correct_func = function(self, from, to)
    if from:hasSkill(self.name) and from.hp > 2 then
      return -1
    end
    if to:hasSkill(self.name) and to.hp < 3 then
      return 1
    end
    return 0
  end,
}
gongsunzan:addSkill(yicong)
Fk:loadTranslationTable{
  ["gongsunzan"] = "公孙瓒",
  ["yicong"] = "义从",
  [":yicong"] = "锁定技，只要你的体力值大于2点，你计算与其他角色的距离时始终-1；只要你的体力值为2点或更低，其他角色计算与你的距离时始终+1。",
}

Fk:loadTranslationTable{
  ["yuanshu"] = "袁术",
  ["yongsi"] = "庸肆",
  [":yongsi"] = "锁定技，摸牌阶段，你额外摸X张牌，X为场上现存势力数。弃牌阶段，你至少须弃掉等同于场上现存势力数的牌（不足则全弃）。",
  ["weidi"] = "伪帝",
  [":weidi"] = "锁定技，你拥有当前主公的主公技。",
}

Fk:loadTranslationTable{
  ["caohong"] = "曹洪",
  ["yuanhu"] = "援护",
  [":yuanhu"] = "回合结束阶段开始时，你可以将一张装备牌置于一名角色的装备区里，然后根据此装备牌的种类执行以下效果。武器牌：弃置与该角色距离为1的一名角色区域中的一张牌；防具牌：该角色摸一张牌；坐骑牌：该角色回复1点体力。",
}

Fk:loadTranslationTable{
  ["guanyinping"] = "关银屏",
  ["xueji"] = "血祭",
  [":xueji"] = "出牌阶段，你可弃置一张红色牌，并对你攻击范围内的至多X名其他角色各造成1点伤害，然后这些角色各摸一张牌。X为你损失的体力值。每阶段限一次。",
  ["huxiao"] = "虎啸",
  [":huxiao"] = "若你于出牌阶段使用的【杀】被【闪】抵消，则本阶段你可以额外使用一张【杀】。",
  ["wuji"] = "武继",
  [":wuji"] = "觉醒技，回合结束阶段开始时，若本回合你已造成3点或更多伤害，你须加1点体力上限并回复1点体力，然后失去技能“虎啸”。",
}

Fk:loadTranslationTable{
  ["liuxie"] = "刘协",
  ["tianming"] = "天命",
  [":tianming"] = "当你成为【杀】的目标时，你可以弃置两张牌（不足则全弃，无牌则不弃），然后摸两张牌；若此时全场体力值最多的角色仅有一名（且不是你），该角色也可以如此做。",
  ["mizhao"] = "密诏",
  [":mizhao"] = "出牌阶段，你可以将所有手牌（至少一张）交给一名其他角色。若如此做，你令该角色与你指定的另一名有手牌的角色拼点，视为拼点赢的角色对没赢的角色使用一张【杀】。（每阶段限一次。）",
}

Fk:loadTranslationTable{
  ["lingju"] = "灵雎",
  ["jieyuan"] = "竭缘",
  [":jieyuan"] = "当你对一名其他角色造成伤害时，若其体力值大于或等于你的体力值，你可弃置一张黑色手牌令此伤害+1；当你受到一名其他角色造成的伤害时，若其体力值大于或等于你的体力值，你可弃置一张红色手牌令此伤害-1。",
  ["fenxin"] = "焚心",
  [":fenxin"] = "限定技，当你杀死一名非主公角色时，在其翻开身份牌之前，你可以与该角色交换身份牌。（你的身份为主公时不能发动此技能。）",
}

Fk:loadTranslationTable{
  ["fuwan"] = "伏完",
  ["moukui"] = "谋溃",
  [":moukui"] = "当你使用【杀】指定一名角色为目标后，你可以选择一项：摸一张牌，或弃置其一张牌。若如此做，此【杀】被【闪】抵消时，该角色弃置你的一张牌。",
}

Fk:loadTranslationTable{
  ["xiahouba"] = "夏侯霸",
  ["baobian"] = "豹变",
  [":baobian"] = "锁定技，若你的体力值为3或更少，你视为拥有技能“挑衅”；若你的体力值为2或更少，你视为拥有技能“咆哮”；若你的体力值为1，你视为拥有技能“神速”。",
}

local chenlin = General(extension, "chenlin", "wei", 3)
local bifa = fk.CreateTriggerSkill{
  name = "bifa",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self.name) and player.phase == Player.Finish and not player:isKongcheng() then
      self.bifa_tos = {}
      for _, p in ipairs(player.room:getOtherPlayers(player)) do
        if #p:getPile(self.name) == 0 then
          table.insert(self.bifa_tos, p.id)
        end
      end
      return #self.bifa_tos > 0
    end
  end,
  on_cost = function(self, event, target, player, data)
    local tos, id = player.room:askForChooseCardAndPlayers(player, self.bifa_tos, 1, 1, ".|.|.|hand|.|.", "#bifa-choose", self.name)
    if #tos > 0 then
      self.cost_data = {tos[1], id}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:getPlayerById(self.cost_data[1]):addToPile(self.name, self.cost_data[2], false, self.name)
  end,

  refresh_events = {fk.EventPhaseStart},
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(self.name) and target.phase == Player.Start and #target:getPile(self.name) > 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if player.dead or target:isKongcheng() then
      room:loseHp(target, 1, self.name)
      room:moveCards({
        from = target.id,
        ids = target:getPile(self.name),
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonPutIntoDiscardPile,
        skillName = self.name,
        specialName = self.name,
      })
      return
    end
    local type = Fk:getCardById(target:getPile(self.name)[1]):getTypeString()
    local card = room:askForCard(target, 1, 1, false, self.name, true, ".|.|.|hand|.|"..type)
    if #card > 0 then
      local dummy = Fk:cloneCard("dilu")
      dummy:addSubcards(card)
      room:obtainCard(player, dummy, false, fk.ReasonGive)
      room:obtainCard(target, target:getPile(self.name)[1], true, fk.ReasonPrey)
    else
      room:loseHp(target, 1, self.name)
      room:moveCards({
        from = target.id,
        ids = target:getPile(self.name),
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonPutIntoDiscardPile,
        skillName = self.name,
        specialName = self.name,
      })
    end
  end,
}
local songci = fk.CreateActiveSkill{
  name = "songci",
  anim_type = "control",
  mute = true,
  can_use = function(self, player)
    return true
  end,
  card_filter = function(self, to_select, selected)
    return false
  end,
  target_filter = function(self, to_select, selected)
    local target = Fk:currentRoom():getPlayerById(to_select)
    return #selected == 0 and target:getMark(self.name) == 0 and #target.player_cards[Player.Hand] ~= target.hp
  end,
  target_num = 1,
  card_num = 0,
  on_use = function(self, room, effect)
    local target = room:getPlayerById(effect.tos[1])
    room:addPlayerMark(target, self.name)
    if #target.player_cards[Player.Hand] < target.hp then
      target:drawCards(2)
      room:broadcastSkillInvoke(self.name, 1)
    else
      room:askForDiscard(target, 2, 2, true, self.name)
      room:broadcastSkillInvoke(self.name, 2)
    end
  end,
}
chenlin:addSkill(bifa)
chenlin:addSkill(songci)
Fk:loadTranslationTable{
  ["chenlin"] = "陈琳",
  ["bifa"] = "笔伐",
  [":bifa"] = "回合结束阶段开始时，你可以将一张手牌移出游戏并指定一名其他角色。该角色的回合开始时，其观看你移出游戏的牌并选择一项：交给你一张与此牌同类型的手牌并获得此牌；或将此牌置入弃牌堆，然后失去1点体力。",
  ["songci"] = "颂词",
  [":songci"] = "出牌阶段，你可以选择一项：令一名手牌数小于其体力值的角色摸两张牌；或令一名手牌数大于其体力值的角色弃置两张牌。此技能对每名角色只能用一次。",
  ["#bifa-choose"] = "笔伐：将一张手牌移出游戏并指定一名其他角色",
}

Fk:loadTranslationTable{
  ["daqiaoxiaoqiao"] = "大乔小乔",
  ["xingwu"] = "星舞",
  [":xingwu"] = "。",
  ["luoyan"] = "落雁",
  [":luoyan"] = "。",
}

Fk:loadTranslationTable{
  ["sp__xiahoushi"] = "夏侯氏",
  ["sp__yanyu"] = "燕语",
  [":sp__yanyu"] = "任意一名角色的出牌阶段开始时，你可以弃置一张牌，若如此做，则本回合的出牌阶段，每当有与你弃置牌类别相同的其他牌进入弃牌堆时，你可令任意一名角色获得此牌。每回合以此法获得的牌不能超过三张。",
  ["xiaode"] = "孝德",
  [":xiaode"] = "每当有其他角色阵亡后，你可以声明该武将牌的一项技能，若如此做，你获得此技能并失去技能“孝德”直到你的回合结束。（你不能声明觉醒技或主公技）",
}

local yuejin = General(extension, "yuejin", "wei", 4)
local xiaoguo = fk.CreateTriggerSkill{
  name = "xiaoguo",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(self.name) and target.phase == Player.Finish and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local _, discard = room:askForUseActiveSkill(player, "discard_skill", "#xiaoguo-discard", true, {
      num = 1,
      min_num = 1,
      include_equip = false,
      reason = self.name,
      pattern = ".|.|.|.|.|basic",
    })
    if discard then
      room:throwCard(discard.cards, self.name, player, player)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if #room:askForDiscard(target, 1, 1, true, self.name, true, ".|.|.|.|.|equip") > 0 then
      player:drawCards(1)
    else
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = self.name,
      }
    end
  end,
}
yuejin:addSkill(xiaoguo)
Fk:loadTranslationTable{
  ["yuejin"] = "乐进",
  ["xiaoguo"] = "骁果",
  [":xiaoguo"] = "其他角色的结束阶段开始时，你可以弃置一张基本牌。若如此做，该角色需弃置一张装备牌并令你摸一张牌，否则受到你对其造成的1点伤害。",
  ["#xiaoguo-discard"] = "骁果：你可以弃置一张基本牌，该角色需弃置一张装备牌并令你摸一张牌，否则你对其造成1点伤害",
}

Fk:loadTranslationTable{
  ["zhangbao"] = "张宝",
  ["zhoufu"] = "咒缚",
  [":zhoufu"] = "。",
  ["yingbing"] = "影兵",
  [":yingbing"] = "。",
}

local caoang = General(extension, "caoang", "wei", 4)
local kangkai = fk.CreateTriggerSkill{
  name = "kangkai",
  anim_type = "support",
  events = {fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and data.card.trueName == "slash" and player:distanceTo(player.room:getPlayerById(data.to)) <= 1
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(data.to)
    player:drawCards(1)
    if player == to then return end
    local cards = room:askForCard(player, 1, 1, true, self.name, false)
    if #cards > 0 then
      local dummy = Fk:cloneCard("dilu")
      dummy:addSubcards(cards)
      room:obtainCard(to.id, dummy, true, fk.ReasonGive)
      local card = Fk:getCardById(cards[1])
      if card.type == Card.TypeEquip and room:askForSkillInvoke(to, self.name) then  --FIXME: need prompt
        room:useCard({
          from = to.id,
          tos = {{to.id}},
          card = card,
        })
      end
    end
  end,
}
caoang:addSkill(kangkai)
Fk:loadTranslationTable{
  ["caoang"] = "曹昂",
  ["kangkai"] = "慷忾",
  [":kangkai"] = "每当一名角色成为【杀】的目标后，若你与其的距离不大于1，你可以摸一张牌，若如此做，你先将一张牌交给该角色再令其展示之，若此牌为装备牌，其可以使用之。",
}

Fk:loadTranslationTable{
  ["zhugejin"] = "诸葛瑾",
  ["huanshi"] = "缓释",
  [":huanshi"] = "。",
  ["hongyuan"] = "弘援",
  [":hongyuan"] = "。",
  ["mingzhe"] = "明哲",
  [":mingzhe"] = "。",
}

Fk:loadTranslationTable{
  ["xingcai"] = "星彩",
  ["shenxian"] = "甚贤",
  [":shenxian"] = "。",
  ["qiangwu"] = "枪舞",
  [":qiangwu"] = "。",
}

Fk:loadTranslationTable{
  ["panfeng"] = "潘凤",
  ["kuangfu"] = "狂斧",
  [":kuangfu"] = "。",
}

Fk:loadTranslationTable{
  ["zumao"] = "祖茂",
  ["yinbing"] = "引兵",
  [":yinbing"] = "。",
  ["juedi"] = "绝地",
  [":juedi"] = "。",
}

Fk:loadTranslationTable{
  ["dingfeng"] = "丁奉",
  ["duanbing"] = "短兵",
  [":duanbing"] = "。",
  ["fenxun"] = "奋迅",
  [":fenxun"] = "。",
}

Fk:loadTranslationTable{
  ["zhugedan"] = "诸葛诞",
  ["gongao"] = "功獒",
  [":gongao"] = "。",
  ["juyi"] = "举义",
  [":juyi"] = "。",
  ["weizhong"] = "威重",
  [":weizhong"] = "。",
}

Fk:loadTranslationTable{
  ["hetaihou"] = "何太后",
  ["zhendu"] = "鸩毒",
  [":zhendu"] = "。",
  ["qiluan"] = "戚乱",
  [":qiluan"] = "。",
}

Fk:loadTranslationTable{
  ["sunluyu"] = "孙鲁育",
  ["meibu"] = "魅步",
  [":meibu"] = "。",
  ["mumu"] = "穆穆",
  [":mumu"] = "。",
}

Fk:loadTranslationTable{
  ["maliang"] = "马良",
  ["xiemu"] = "协穆",
  [":xiemu"] = "。",
  ["naman"] = "纳蛮",
  [":naman"] = "。",
}

Fk:loadTranslationTable{
  ["maliang"] = "甘夫人",
  ["shushen"] = "淑慎",
  [":shushen"] = "。",
  ["shenzhi"] = "神智",
  [":shenzhi"] = "。",
}

Fk:loadTranslationTable{
  ["huangjinleishi"] = "黄巾雷使",
  ["fulu"] = "符箓",
  [":fulu"] = "。",
  ["zhuji"] = "助祭",
  [":zhuji"] = "。",
}

Fk:loadTranslationTable{
  ["wenpin"] = "文聘",
  ["zhenwei"] = "镇卫",
  [":zhenwei"] = "。",
}

Fk:loadTranslationTable{
  ["simalang"] = "司马朗",
  ["junbing"] = "郡兵",
  [":junbing"] = "。",
  ["quji"] = "去疾",
  [":quji"] = "。",
}

return extension
