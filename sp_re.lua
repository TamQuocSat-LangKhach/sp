local extension = Package("sp_re")
extension.extensionName = "sp"

Fk:loadTranslationTable{
  ["sp_re"] = "RE.SP",
  ["re"] = "RE",
}

local masu = General(extension, "re__masu", "shu", 3)
local sanyao = fk.CreateActiveSkill{
  name = "sanyao",
  anim_type = "offensive",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isNude()
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and not Self:prohibitDiscard(Fk:getCardById(to_select))
  end,
  target_filter = function(self, to_select, selected)
    if #selected == 0 then
      local n = 0
      for _, p in ipairs(Fk:currentRoom().alive_players) do
        if p.hp > n then
          n = p.hp
        end
      end
      return Fk:currentRoom():getPlayerById(to_select).hp == n
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:throwCard(effect.cards, self.name, player, player)
    if not (player.dead or target.dead) then
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = self.name,
      }
    end
  end
}
local zhiman = fk.CreateTriggerSkill{
  name = "zhiman",
  events = {fk.DamageCaused},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.to ~= player
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#zhiman-invoke::"..data.to.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if #data.to:getCardIds{Player.Equip, Player.Judge} > 0 then
      local card = room:askForCardChosen(player, data.to, "ej", self.name)
      room:obtainCard(player.id, card, true, fk.ReasonPrey)
    end
    return true
  end
}
masu:addSkill(sanyao)
masu:addSkill(zhiman)
Fk:loadTranslationTable{
  ["re__masu"] = "马谡",
  ["#re__masu"] = "傲才自负",
  ["illustrator:re__masu"] = "XXX",

  ["sanyao"] = "散谣",
  [":sanyao"] = "出牌阶段限一次，你可以弃置一张牌并选择一名体力值最大的角色，你对其造成1点伤害。",
  ["zhiman"] = "制蛮",
  [":zhiman"] = "当你对其他角色造成伤害时，你可以防止此伤害，然后获得其装备区或判定区的一张牌。",
  ["#zhiman-invoke"] = "制蛮：你可以防止对 %dest 造成的伤害，然后获得其场上的一张牌",

  ["$sanyao1"] = "三人成虎，事多有。",
  ["$sanyao2"] = "散谣惑敌，不攻自破！",
  ["$zhiman1"] = "兵法谙熟于心，取胜千里之外！",
  ["$zhiman2"] = "丞相多虑，且看我的！",
  ["~re__masu"] = "败军之罪，万死难赎……",
}

local yujin = General(extension, "re__yujin", "wei", 4)
local jieyue = fk.CreateViewAsSkill{
  name = "jieyue",
  pattern = "jink,nullification",
  mute = true,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
  end,
  before_use = function(self, player, use)
    if use.card.name == "jink" then
      player:broadcastSkillInvoke(self.name, 3)
      player.room:notifySkillInvoked(player, self.name, "defensive")
    elseif use.card.name == "nullification" then
      player:broadcastSkillInvoke(self.name, 4)
      player.room:notifySkillInvoked(player, self.name, "defensive")
    end
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return end
    local card
    if Fk:getCardById(cards[1]).color == Card.Red then
      card = Fk:cloneCard("jink")
    elseif Fk:getCardById(cards[1]).color == Card.Black then
      card = Fk:cloneCard("nullification")
    end
    card.skillName = self.name
    card:addSubcard(cards[1])
    return card
  end,
  enabled_at_response = function(self, player)
    return #player:getPile("$jieyue") > 0
  end,
}
local jieyue_trigger = fk.CreateTriggerSkill{
  name = "#jieyue_trigger",
  anim_type = "control",
  mute = true,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if target == player then
      if player.phase == Player.Finish then
        return player:hasSkill("jieyue") and not player:isKongcheng()
      elseif player.phase == Player.Start then
        return #player:getPile("$jieyue") > 0
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if player.phase == Player.Finish then
      local room = player.room
      local targets = {}
      for _, p in ipairs(room:getOtherPlayers(player)) do
        if not p:isNude() then
          table.insert(targets, p.id)
        end
      end
      if #targets == 0 then return end
      local tos, id = player.room:askForChooseCardAndPlayers(player, targets, 1, 1, ".|.|.|hand|.|.", "#jieyue-cost", "jieyue")
      if #tos > 0 then
        self.cost_data = {tos[1], id}
        return true
      end
    elseif player.phase == Player.Start then
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("jieyue", math.random(1,2))
    player.room:notifySkillInvoked(player, "jieyue", "defensive")
    if player.phase == Player.Finish then
      room:throwCard(self.cost_data[2], "jieyue", player, player)
      if player.dead then return end
      local to = room:getPlayerById(self.cost_data[1])
      local card = room:askForCard(to, 1, 1, true, "jieyue", true, ".", "#jieyue-give:"..player.id)
      if #card > 0 then
        player:addToPile("$jieyue", card, false, "jieyue")
      else
        local id = room:askForCardChosen(player, to, "he", "jieyue")
        room:throwCard({id}, "jieyue", to, player)
      end
    elseif player.phase == Player.Start then
      if player.dead then return end
      room:moveCards({
        from = player.id,
        ids = player:getPile("$jieyue"),
        to = player.id,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonJustMove,
        skillName = "jieyue",
      })
    end
  end,
}
jieyue:addRelatedSkill(jieyue_trigger)
yujin:addSkill(jieyue)
Fk:loadTranslationTable{
  ["re__yujin"] = "于禁",
  ["#re__yujin"] = "讨暴坚垒",
  ["illustrator:re__yujin"] = "depp",

  ["jieyue"] = "节钺",
  [":jieyue"] = "结束阶段开始时，你可以弃置一张手牌并选择一名其他角色，若如此做，除非该角色将一张牌置于你的武将牌上，否则你弃置其一张牌。"..
  "若你的武将牌上有牌，则你可以将红色手牌当【闪】、黑色手牌当【无懈可击】使用或打出，准备阶段开始时，你获得你武将牌上的牌。",
  ["#jieyue_trigger"] = "节钺",
  ["$jieyue"] = "节钺",
  ["#jieyue-cost"] = "节钺：你可以弃置一张手牌，令一名其他角色执行后续效果",
  ["#jieyue-give"] = "节钺：将一张牌置为 %src 的“节钺”牌，或其弃置你一张牌",

  ["$jieyue1"] = "诸军严整，敌军自乱。",
  ["$jieyue2"] = "安营驻寨，严守城防。",
  ["$jieyue3"] = "不动如泰山。",
  ["$jieyue4"] = "纪法严明，无懈可击。",
  ["~re__yujin"] = "我，无颜面对丞相了……",
}

local liubiao = General(extension, "re__liubiao", "qun", 3)
local re__zishou = fk.CreateTriggerSkill{
  name = "re__zishou",
  anim_type = "drawcard",
  events = {fk.DrawNCards},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and player.phase == Player.Draw
  end,
  on_use = function(self, event, target, player, data)
    local kingdoms = {}
    for _, p in ipairs(player.room.alive_players) do
      table.insertIfNeed(kingdoms, p.kingdom)
    end
    data.n = data.n + #kingdoms
  end,
}
local zishou_prohibit = fk.CreateProhibitSkill{
  name = "#zishou_prohibit",
  is_prohibited = function(self, from, to, card)
    if from:hasSkill(self) then
      return from:usedSkillTimes("re__zishou") > 0 and from ~= to
    end
  end,
}
re__zishou:addRelatedSkill(zishou_prohibit)
liubiao:addSkill(re__zishou)
liubiao:addSkill("zongshi")
Fk:loadTranslationTable{
  ["re__liubiao"] = "刘表",
  ["#re__liubiao"] = "跨蹈汉南",
  ["illustrator:re__liubiao"] = "歌路",

  ["re__zishou"] = "自守",
  [":re__zishou"] = "摸牌阶段，你可以额外摸X张牌（X为全场势力数）。若如此做，直到回合结束，其他角色不能被选择为你使用牌的目标。",

  ["$re__zishou1"] = "荆襄之地，固若金汤。",
  ["$re__zishou2"] = "江河霸主，何惧之有？",
  ["~re__liubiao"] = "优柔寡断，要不得啊。",
}

local madai = General(extension, "re__madai", "shu", 4)
local re__qianxi = fk.CreateTriggerSkill{
  name = "re__qianxi",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1, self.name)
    local card = room:askForDiscard(player, 1, 1, true, self.name, false, ".", "#qianxi-discard")
    local targets = {}
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if player:distanceTo(p) == 1 then
        table.insert(targets, p.id)
      end
    end
    if #targets == 0 then return end
    local tos = room:askForChoosePlayers(player, targets, 1, 1, "#qianxi-choose", self.name, false)
    room:setPlayerMark(room:getPlayerById(tos[1]), "@qianxi-turn", Fk:getCardById(card[1]):getColorString())
  end,
}
local re__qianxi_prohibit = fk.CreateProhibitSkill{  --actually the same as YJ2012 new MaDai
  name = "#re__qianxi_prohibit",
  prohibit_use = function(self, player, card)
    return player:getMark("@qianxi-turn") ~= 0 and card:getColorString() == player:getMark("@qianxi-turn")
  end,
  prohibit_response = function(self, player, card)
    return player:getMark("@qianxi-turn") ~= 0 and card:getColorString() == player:getMark("@qianxi-turn")
  end,
}
re__qianxi:addRelatedSkill(re__qianxi_prohibit)
madai:addSkill("mashu")
madai:addSkill(re__qianxi)
Fk:loadTranslationTable{
  ["re__madai"] = "马岱",
  ["#re__madai"] = "临危受命",
  ["illustrator:re__madai"] = "歌路",

  ["re__qianxi"] = "潜袭",
  [":re__qianxi"] = "准备阶段开始时，你可以摸一张牌然后弃置一张牌。若如此做，你选择距离为1的一名角色，然后直到回合结束，"..
  "该角色不能使用或打出与你以此法弃置的牌颜色相同的手牌。",
  ["#qianxi-discard"] = "潜袭：弃置一张牌，令一名角色本回合不能使用或打出此颜色的手牌",

  ["~re__madai"] = "我怎么会死在这里……",
}

local bulianshi = General(extension, "re__bulianshi", "wu", 3, 3, General.Female)
local anxu = fk.CreateActiveSkill{
  name = "re__anxu",
  anim_type = "control",
  card_num = 0,
  target_num = 2,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    if #selected > 1 or to_select == Self.id then return false end
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
    local card = room:askForCard(to, 1, 1, false, self.name, false, ".", "#anxu-give::"..from.id)
    room:obtainCard(from.id, Fk:getCardById(card[1]), false, fk.ReasonGive)
    if target1:getHandcardNum() == target2:getHandcardNum() and not player.dead then
      local choices = {"draw1"}
      if player:isWounded() then
        table.insert(choices, "recover")
      end
      local choice = room:askForChoice(player, choices, self.name)
      if choice == "draw1" then
        player:drawCards(1, self.name)
      else
        room:recover({
          who = player,
          num = 1,
          recoverBy = player,
          skillName = self.name
        })
      end
    end
  end,
}
bulianshi:addSkill(anxu)
bulianshi:addSkill("zhuiyi")
Fk:loadTranslationTable{
  ["re__bulianshi"] = "步练师",
  ["#re__bulianshi"] = "无冕之后",
  ["illustrator:re__bulianshi"] = "depp",

  ["re__anxu"] = "安恤",
  [":re__anxu"] = "出牌阶段限一次，你可以选择两名手牌数不同的其他角色，令其中手牌多的角色将一张手牌交给手牌少的角色，然后若这两名角色手牌数相等，"..
  "你摸一张牌或回复1点体力。",
  ["#anxu-give"] = "安恤：你需将一张手牌交给 %dest",

  ["$re__anxu1"] = "和鸾雍雍，万福攸同。",
  ["$re__anxu2"] = "君子乐胥，万邦之屏。",
  ["~re__bulianshi"] = "江之永矣，不可方思。",
}

local xusheng = General(extension, "re__xusheng", "wu", 4)
local pojun = fk.CreateTriggerSkill{
  name = "re__pojun",
  anim_type = "offensive",
  events = {fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Play and data.card.trueName == "slash" and
      not player.room:getPlayerById(data.to):isNude()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(data.to)
    local cards = room:askForCardsChosen(player, to, 0, to.hp, "he", self.name)
    if #cards > 0 then
      to:addToPile("$re__pojun", cards, false, self.name)
    end
  end,
}
local pojun_delay = fk.CreateTriggerSkill{
  name = "#re__pojun_delay",
  mute = true,
  events = {fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    return #player:getPile("$re__pojun") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:moveCardTo(player:getPile("$re__pojun"), Player.Hand, player, fk.ReasonPrey, "re__pojun")
  end,
}
pojun:addRelatedSkill(pojun_delay)
xusheng:addSkill(pojun)
Fk:loadTranslationTable{
  ["re__xusheng"] = "徐盛",
  ["#re__xusheng"] = "江东的铁壁",
  ["illustrator:re__xusheng"] = "L",

  ["re__pojun"] = "破军",
  [":re__pojun"] = "当你于出牌阶段内使用【杀】指定一个目标后，你可以将其至多X张牌扣置于该角色的武将牌旁（X为其体力值）。"..
  "若如此做，当前回合结束后，该角色获得其武将牌旁的所有牌。",
  ["#re__pojun_delay"] = "破军",
  ["$re__pojun"] = "破军",

  ["$re__pojun1"] = "大军在此！汝等休想前进一步！",
  ["$re__pojun2"] = "敬请，养精蓄锐！",
  ["~re__xusheng"] = "盛，不能奋身出命，不亦辱乎……",
}

return extension
