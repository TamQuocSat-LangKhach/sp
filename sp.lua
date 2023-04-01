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

local pangde = General(extension, "sp__pangde", "wei", 4)
local juesi = fk.CreateActiveSkill{
  name = "juesi",
  anim_type = "offensive",
  can_use = function(self, player)
    return not player:isKongcheng()
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).trueName == "slash"
  end,
  target_filter = function(self, to_select, selected)
    local target = Fk:currentRoom():getPlayerById(to_select)
    return #selected == 0 and not target:isNude() and Self:inMyAttackRange(target)
  end,
  target_num = 1,
  card_num = 1,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:throwCard(effect.cards, self.name, player, player)
    local card = Fk:getCardById(room:askForDiscard(target, 1, 1, true, self.name)[1])
    if card.trueName ~= "slash" and target.hp >= player.hp and not player.dead and not target.dead then
      local duel = Fk:cloneCard("duel")
      room:useCard({
        card = duel,
        from = player.id,
        tos = {{target.id}},
      })
    end
  end,
}
pangde:addSkill("mashu")
pangde:addSkill(juesi)
Fk:loadTranslationTable{
  ["sp__pangde"] = "庞德",
  ["juesi"] = "决死",
  [":juesi"] = "出牌阶段，你可以弃置一张【杀】并选择攻击范围内的一名其他角色，然后令该角色弃置一张牌。若该角色弃置的牌不为【杀】且其体力值不小于你，你视为对其使用一张【决斗】。",
}

Fk:loadTranslationTable{
  ["sp__caiwenji"] = "蔡文姬",
  ["chenqing"] = "陈情",
  [":chenqing"] = "每轮限一次，当一名角色进入濒死状态时，你可以令另一名其他角色摸四张牌，然后弃置四张牌，若其以此法弃置的牌花色各不相同，则其视为对濒死状态的角色使用一张【桃】。",
  ["mozhi"] = "默识",
  [":mozhi"] = "结束阶段，你可以将一张手牌当你本回合使用过的第一张基本牌或非延时锦囊牌使用，然后你可以将一张手牌当你本回合使用过的第二张基本牌或非延时锦囊牌使用。",
}

Fk:loadTranslationTable{
  ["sp__machao"] = "马超",
  ["shichou"] = "誓仇",
  [":shichou"] = "你使用【杀】可以额外选择至多X名角色为目标（X为你已损失的体力值）。",
}

Fk:loadTranslationTable{
  ["sp__jiaxu"] = "贾诩",
  ["zhenlve"] = "缜略",
  [":zhenlve"] = "锁定技，你使用的非延时锦囊牌不能被【无懈可击】响应，你不能被选择为延时锦囊牌的目标。",
  ["jianshu"] = "间书",
  [":jianshu"] = "限定技，出牌阶段，你可以将一张黑色手牌交给一名其他角色，并选择一名攻击范围内含有其的另一名角色。然后令这两名角色拼点：赢的角色弃置两张牌，没赢的角色失去1点体力。",
  ["yongdi"] = "拥嫡",
  [":yongdi"] = "限定技，当你受到伤害后，你可令一名其他男性角色增加1点体力上限，然后若该角色的武将牌上有主公技且其身份不为主公，其获得此主公技。",
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

local lingju = General(extension, "lingju", "qun", 3, 3, General.Female)
local jieyuan = fk.CreateTriggerSkill{
  name = "jieyuan",
  anim_type = "offensive",
  events = {fk.DamageCaused, fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self.name) and not player:isKongcheng() then
      if event == fk.DamageCaused then
        return data.to.hp >= player.hp
      else
        return data.from and data.from.hp >= player.hp
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local pattern
    if event == fk.DamageCaused then
      pattern = ".|.|spade,club|.|.|."
    else
      pattern = ".|.|heart,diamond|.|.|."
    end
    local _, discard = room:askForUseActiveSkill(player, "discard_skill", "#jieyuan-discard", true, {
      num = 1,
      min_num = 1,
      include_equip = false,
      reason = self.name,
      pattern = pattern,
    })
    if discard then
      room:throwCard(discard.cards, self.name, player, player)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    if event == fk.DamageCaused then
      data.damage = data.damage + 1
    else
      data.damage = data.damage - 1
    end
  end,
}
local fenxin = fk.CreateTriggerSkill{
  name = "fenxin",
  anim_type = "offensive",
  events = {fk.BeforeGameOverJudge},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and player:getMark(self.name) == 0 and
      data.damage and data.damage.from and data.damage.from == player and
      player.role ~= "lord" and target.role ~= "lord"
  end,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, self.name, 1)
    local temp = player.role
    player.role = target.role
    target.role = temp
    player.room:notifyProperty(player, player, "role")
  end,
}
lingju:addSkill(jieyuan)
lingju:addSkill(fenxin)
Fk:loadTranslationTable{
  ["lingju"] = "灵雎",
  ["jieyuan"] = "竭缘",
  [":jieyuan"] = "当你对一名其他角色造成伤害时，若其体力值大于或等于你的体力值，你可弃置一张黑色手牌令此伤害+1；当你受到一名其他角色造成的伤害时，若其体力值大于或等于你的体力值，你可弃置一张红色手牌令此伤害-1。",
  ["fenxin"] = "焚心",
  [":fenxin"] = "限定技，当你杀死一名非主公角色时，在其翻开身份牌之前，你可以与该角色交换身份牌。（你的身份为主公时不能发动此技能。）",
  ["#jieyuan-discard"] = "竭缘：弃置一张黑色手牌令此伤害+1/红色手牌令此伤害-1",
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
  [":huanshi"] = "每当一名角色的判定牌生效前，你可以令该角色观看你的手牌并选择你的一张牌，你打出此牌代替之。",
  ["hongyuan"] = "弘援",
  [":hongyuan"] = "摸牌阶段，你可以少摸一张牌，令至多两名其他角色各摸一张牌。",
  ["mingzhe"] = "明哲",
  [":mingzhe"] = "每当你于回合外使用、打出或因弃置而失去一张红色牌时，你可以摸一张牌。",
}

Fk:loadTranslationTable{
  ["xingcai"] = "星彩",
  ["shenxian"] = "甚贤",
  [":shenxian"] = "你的回合外，每当有其他角色因弃置而失去牌时，若其中有基本牌，你可以摸一张牌。",
  ["qiangwu"] = "枪舞",
  [":qiangwu"] = "出牌阶段限一次，你可以进行一次判定，若如此做，则直到回合结束，你使用点数小于判定牌的【杀】时不受距离限制，且你使用点数大于判定牌的【杀】时不计入出牌阶段的使用次数。",
}

Fk:loadTranslationTable{
  ["panfeng"] = "潘凤",
  ["kuangfu"] = "狂斧",
  [":kuangfu"] = "每当你使用【杀】对目标角色造成一次伤害后，你可以选择一项: 将其装备区里的一张牌置入你的装备区；或弃置其装备区里的一张牌。",
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
  [":duanbing"] = "你使用【杀】时可以额外选择一名距离为1的其他角色为目标。",
  ["fenxun"] = "奋迅",
  [":fenxun"] = "出牌阶段限一次，你可以弃置一张牌并选择一名其他角色，令你与其的距离视为1，直到回合结束。",
}

Fk:loadTranslationTable{
  ["zhugedan"] = "诸葛诞",
  ["gongao"] = "功獒",
  [":gongao"] = "锁定技，每当一名角色死亡后，你增加1点体力上限，回复1点体力。",
  ["juyi"] = "举义",
  [":juyi"] = "觉醒技，准备阶段开始时，若你已受伤且体力上限大于存活角色数，你须将手牌摸至体力上限，然后获得技能“崩坏”和“威重”。",
  ["weizhong"] = "威重",
  [":weizhong"] = "锁定技，每当你的体力上限增加或减少时，你摸一张牌。",
}

local hetaihou = General(extension, "hetaihou", "qun", 3, 3, General.Female)
local zhendu = fk.CreateTriggerSkill{
  name = "zhendu",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(self.name) and target.phase == Player.Play and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local _, discard = room:askForUseActiveSkill(player, "discard_skill", "#zhendu-discard", true, {
      num = 1,
      min_num = 1,
      include_equip = false,
      reason = self.name,
      pattern = ".|.|.|hand|.|.",
    })
    if discard then
      room:throwCard(discard.cards, self.name, player, player)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local analeptic = Fk:cloneCard("analeptic")
      room:useCard({
        card = analeptic,
        from = target.id,
        tos = {{target.id}},
      })
    room:damage{
      from = player,
      to = target,
      damage = 1,
      skillName = self.name,
    }
  end,
}
local qiluan = fk.CreateTriggerSkill{
  name = "qiluan",
  anim_type = "offensive",
  events = {fk.BuryVictim},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and data.damage and data.damage.from and data.damage.from == player
  end,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, self.name, 1)
  end,

  refresh_events = {fk.EventPhaseStart},
  can_refresh = function(self, event, target, player, data)
    return target.phase == Player.NotActive and player:getMark(self.name) > 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(3 * player:getMark(self.name))
    room:setPlayerMark(player, self.name, 0)
  end,
}
hetaihou:addSkill(zhendu)
hetaihou:addSkill(qiluan)
Fk:loadTranslationTable{
  ["hetaihou"] = "何太后",
  ["zhendu"] = "鸩毒",
  [":zhendu"] = "其他角色的出牌阶段开始时，你可以弃置一张手牌，视为该角色使用一张【酒】，然后你对其造成1点伤害。",
  ["qiluan"] = "戚乱",
  [":qiluan"] = "每当你杀死一名角色后，可于此回合结束后摸三张牌。",
  ["#zhendu-discard"] = "鸩毒：你可以弃置一张手牌视为该角色使用一张【酒】，然后你对其造成1点伤害",
}

Fk:loadTranslationTable{
  ["sunluyu"] = "孙鲁育",
  ["meibu"] = "魅步",
  [":meibu"] = "。",
  ["mumu"] = "穆穆",
  [":mumu"] = "。",
}

Fk:loadTranslationTable{
  ["sp__maliang"] = "马良",
  ["xiemu"] = "协穆",
  [":xiemu"] = "。",
  ["naman"] = "纳蛮",
  [":naman"] = "。",
}

local ganfuren = General(extension, "ganfuren", "shu", 3, 3, General.Female)
local shushen = fk.CreateTriggerSkill{
  name = "shushen",
  anim_type = "support",
  events = {fk.HpRecover},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name)
  end,
  on_trigger = function(self, event, target, player, data)
    self.cancel_cost = false
    for i = 1, data.num do
      if self.cancel_cost then break end
      self:doCost(event, target, player, data)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askForChoosePlayers(player, table.map(room:getOtherPlayers(player), function(p) return p.id end), 1, 1, "#shushen-choose", self.name)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
    self.cancel_cost = true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    local choices = {"draw2"}
    if to:isWounded() then
      table.insert(choices, "recover")
    end
    local choice = room:askForChoice(to, choices, self.name)
    if choice == "draw2" then
      to:drawCards(2)
    else
      room:recover({
        who = to,
        num = 1,
        recoverBy = player,
        skillName = self.name
      })
    end
  end,
}
local shenzhi = fk.CreateTriggerSkill{
  name = "shenzhi",
  anim_type = "support",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Start and not player:isKongcheng()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = #player.player_cards[Player.Hand]
    room:throwCard(player.player_cards[Player.Hand], self.name, player, player)
    if player:isWounded() and n >= player.hp then
      room:recover({
        who = player,
        num = 1,
        recoverBy = player,
        skillName = self.name
      })
    end
  end,
}
ganfuren:addSkill(shushen)
ganfuren:addSkill(shenzhi)
Fk:loadTranslationTable{
  ["ganfuren"] = "甘夫人",
  ["shushen"] = "淑慎",
  [":shushen"] = "当你回复1点体力时，你可以令一名其他角色回复1点体力或摸两张牌。",
  ["shenzhi"] = "神智",
  [":shenzhi"] = "准备阶段开始时，你可以弃置所有手牌，若你以此法弃置的手牌数不小于X，你回复1点体力(X为你当前的体力值)。",
  ["#shushen-choose"] = "淑慎：你可以令一名其他角色回复1点体力或摸两张牌",
}

local huangjinleishi = General(extension, "huangjinleishi", "qun", 3, 3, General.Female)
local fulu = fk.CreateViewAsSkill{
  name = "fulu",
  anim_type = "offensive",
  pattern = "slash",
  card_filter = function(self, to_select, selected)
    if #selected == 1 then return false end
    return Fk:getCardById(to_select).name == "slash"
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then
      return nil
    end
    local c = Fk:cloneCard("thunder__slash")
    c:addSubcard(cards[1])
    return c
  end,
}
local zhuji = fk.CreateTriggerSkill{
  name = "zhuji",
  anim_type = "offensive",
  events = {fk.DamageCaused},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and data.damageType == fk.ThunderDamage and data.from ~= nil and not data.from.dead
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    self.zhuji_damage = false
    local to = data.from
    local judge = {
      who = to,
      reason = self.name,
      pattern = ".",
    }
    room:judge(judge)
    if self.zhuji_damage then
      data.damage = data.damage + 1
    end
  end,

  refresh_events = {fk.FinishJudge},
  can_refresh = function(self, event, target, player, data)
    return data.reason == self.name
  end,
  on_refresh = function(self, event, target, player, data)
    if data.card.color == Card.Black then
      self.zhuji_damage = true
    elseif data.card.color == Card.Red then
      player.room:obtainCard(target.id, data.card)
    end
  end,
}
huangjinleishi:addSkill(fulu)
huangjinleishi:addSkill(zhuji)
Fk:loadTranslationTable{
  ["huangjinleishi"] = "黄巾雷使",
  ["fulu"] = "符箓",
  [":fulu"] = "你可以将【杀】当雷【杀】使用。",
  ["zhuji"] = "助祭",
  [":zhuji"] = "当一名角色造成雷电伤害时，你可以令其进行一次判定，若结果为黑色，此伤害+1；若结果为红色，该角色获得此牌。",
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
