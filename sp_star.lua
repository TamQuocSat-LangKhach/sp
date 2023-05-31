local extension = Package("sp_star")
extension.extensionName = "sp"

Fk:loadTranslationTable{
  ["sp_star"] = "☆SP",
  ["starsp"] = "☆SP",
}

local zhaoyun = General(extension, "starsp__zhaoyun", "qun", 3)
local chongzhen = fk.CreateTriggerSkill{
  name = "chongzhen",
  anim_type = "offensive",
  events = {fk.CardUsing, fk.CardResponding},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self.name) and table.contains(data.card.skillNames, "longdan") then
      local id
      if event == fk.CardUsing then
        if data.card.name == "slash" then
          id = data.tos[1][1]
        elseif data.card.name == "jink" then
          if data.responseToEvent then
            id = data.responseToEvent.from  --jink
          end
        end
      elseif event == fk.CardResponding then
        if data.responseToEvent then
          if data.responseToEvent.from == player.id then
            id = data.responseToEvent.to  --duel used by zhaoyun
          else
            id = data.responseToEvent.from  --savsavage_assault, archery_attack, passive duel

            --TODO: Lenovo shu zhaoyun may chongzhen liubei when responding to jijiang
          end
        end
      end
      if id ~= nil then
        self.cost_data = id
        return not player.room:getPlayerById(id):isKongcheng()
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    local card = room:askForCardChosen(player, to, "h", self.name)
    room:obtainCard(player.id, card, false, fk.ReasonPrey)
  end,
}
zhaoyun:addSkill("longdan")
zhaoyun:addSkill(chongzhen)
Fk:loadTranslationTable{
  ["starsp__zhaoyun"] = "赵云",
  ["chongzhen"] = "冲阵",
  [":chongzhen"] = "每当你发动“龙胆”使用或打出一张手牌时，你可以立即获得对方的一张手牌。",
}

local diaochan = General(extension, "starsp__diaochan", "qun", 3, 3, General.Female)
local lihun = fk.CreateActiveSkill{
  name = "lihun",
  anim_type = "control",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name) == 0
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0
  end,
  target_filter = function(self, to_select, selected)
    local target = Fk:currentRoom():getPlayerById(to_select)
    return #selected == 0 and target.gender == General.Male and not target:isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:throwCard(effect.cards, self.name, player)
    local dummy = Fk:cloneCard("dilu")
    dummy:addSubcards(target:getCardIds(Player.Hand))
    room:obtainCard(player.id, dummy, false, fk.ReasonPrey)
    player:turnOver()
    player.tag[self.name] = {target.id}
  end,
}
local lihun_record = fk.CreateTriggerSkill{
  name = "#lihun_record",

  refresh_events = {fk.EventPhaseEnd},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name, true) and player.phase == Player.Play and player:usedSkillTimes("lihun") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(player.tag["lihun"][1])
    if to.dead or player:isNude() then return end
    local n = math.min(to.hp, #player:getCardIds{Player.Hand, Player.Equip})
    local dummy = Fk:cloneCard("dilu")
    if n == #player:getCardIds{Player.Hand, Player.Equip} then
      dummy:addSubcards(player:getCardIds{Player.Hand, Player.Equip})
    else
      local cards = room:askForCard(player, n, n, true, "lihun", false, ".", "#lihun-give::"..to.id..":"..n)
      dummy:addSubcards(cards)
    end
    room:obtainCard(to.id, dummy, false, fk.ReasonGive)
  end,
}
lihun:addRelatedSkill(lihun_record)
diaochan:addSkill(lihun)
diaochan:addSkill("biyue")
Fk:loadTranslationTable{
  ["starsp__diaochan"] = "貂蝉",
  ["lihun"] = "离魂",
  [":lihun"] = "出牌阶段，你可以弃置一张牌并将你的武将牌翻面，若如此做，指定一名男性角色，获得其所有手牌。"..
  "出牌阶段结束时，你须为该角色的每一点体力分配给其一张牌，每回合限一次。",
  ["#lihun-give"] = "离魂：你需交还 %dest %arg张牌",
}

local caoren = General(extension, "starsp__caoren", "wei", 4)
local kuiwei = fk.CreateTriggerSkill{
  name = "kuiwei",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Finish
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = 0
    for _, p in ipairs(room:getAlivePlayers()) do
      if p:getEquipment(Card.SubtypeWeapon) ~= nil then
        n = n + 1
      end
    end
    player:drawCards(2 + n, self.name)
    player:turnOver()
    room:addPlayerMark(player, self.name, 1)
  end,

  refresh_events = {fk.EventPhaseStart},
  can_refresh = function(self, event, target, player, data)
    return target == player  and player.phase == Player.Draw and player:getMark(self.name) > 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, self.name, 0)
    local n = 0
    for _, p in ipairs(room:getAlivePlayers()) do
      if p:getEquipment(Card.SubtypeWeapon) ~= nil then
        n = n + 1
      end
    end
    if n == 0 then return end
    if #player:getCardIds{Player.Hand, Player.Equip} <= n then
      player:throwAllCards("he")
    else
      room:askForDiscard(player, n, n, true, self.name, false, ".", "#kuiwei-discard:::"..n)
    end
  end,
}
local yanzheng = fk.CreateViewAsSkill{
  name = "yanzheng",
  anim_type = "defensive",
  pattern = "nullification",
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:currentRoom():getCardArea(to_select) == Player.Equip
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return end
    local c = Fk:cloneCard("nullification")
    c.skillName = self.name
    c:addSubcard(cards[1])
    return c
  end,
  enabled_at_play = function (self, player)
    return false
  end,
  enabled_at_response = function (self, player)
    return #player.player_cards[Player.Hand] > player.hp and #player.player_cards[Player.Equip] > 0
  end,
}
caoren:addSkill(kuiwei)
caoren:addSkill(yanzheng)
Fk:loadTranslationTable{
  ["starsp__caoren"] = "曹仁",
  ["kuiwei"] = "溃围",
  [":kuiwei"] = "回合结束阶段开始时，你可以摸2+X张牌，然后将你的武将牌翻面。若如此做，在你的下个摸牌阶段开始时，你须弃置X张牌。"..
  "X等于当时场上装备区内的武器牌的数量。",
  ["yanzheng"] = "严整",
  [":yanzheng"] = "若你的手牌数大于你的体力值，你可以将你装备区内的牌当【无懈可击】使用。",
  ["#kuiwei-discard"] = "溃围：你需弃置%arg张牌",
}

Fk:loadTranslationTable{
  ["starsp__pangtong"] = "庞统",
  ["manjuan"] = "漫卷",
  [":manjuan"] = "每当你将获得任何一张牌，将之置于弃牌堆。若此情况处于你的回合中，你可依次将与该牌点数相同的一张牌从弃牌堆置于你手上。",
  ["zuixiang"] = "醉乡",
  [":zuixiang"] = "限定技，回合开始阶段开始时，你可以展示牌库顶的3张牌置于你的武将牌上，你不可以使用或打出与该些牌同类的牌，所有同类牌对你无效。"..
  "之后每个你的回合开始阶段，你须重复展示一次，直至该些牌中任意两张点数相同时，将你武将牌上的全部牌置于你的手上。",
}

local zhangfei = General(extension, "starsp__zhangfei", "shu", 4)
local jyie = fk.CreateTriggerSkill{
  name = "jyie",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.CardUsing},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.card.trueName == "slash" and data.card.color == Card.Red
  end,
  on_use = function(self, event, target, player, data)
    data.additionalDamage = (data.additionalDamage or 0) + 1
  end,
}
local dahe = fk.CreateActiveSkill{
  name = "dahe",
  anim_type = "offensive",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return not player:isKongcheng() and player:usedSkillTimes(self.name) == 0
  end,
  card_filter = function(self, to_select, selected)
    return false
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= Self.id and not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local pindian = player:pindian({target}, self.name)
    if pindian.results[target.id].winner == player then
      room:addPlayerMark(target, "dahe-turn", 1)
      local card = pindian.results[target.id].toCard
      if room:getCardArea(card.id) == Card.DiscardPile then
        local to = room:askForChoosePlayers(player, table.map(table.filter(room:getAlivePlayers(), function(p)
          return player.hp >= p.hp end), function(p) return p.id end), 1, 1, "#dahe-choose:::"..card:toLogString(), self.name)
        if #to > 0 then
          room:obtainCard(to[1], card, true, fk.ReasonJustMove)
        end
      end
    else
      if not player:isKongcheng() then
        player:showCards(player.player_cards[Player.Hand])
        room:askForDiscard(player, 1, 1, false, self.name, false)
      end
    end
  end,
}
local dahe_trigger = fk.CreateTriggerSkill{
  name = "#dahe_trigger",
  mute = true,
  events = {fk.PreCardEffect},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("dahe-turn") > 0 and data.card.name == "jink" and data.card.suit ~= Card.Heart
  end,
  on_cost = function(self, event, target, player, data)
    return true
  end,
  on_use = function(self, event, target, player, data)
    return true
  end,
}
dahe:addRelatedSkill(dahe_trigger)
zhangfei:addSkill(jyie)
zhangfei:addSkill(dahe)
Fk:loadTranslationTable{
  ["starsp__zhangfei"] = "张飞",
  ["jyie"] = "嫉恶",
  [":jyie"] = "锁定技，你使用的红色【杀】造成的伤害+1。",
  ["dahe"] = "大喝",
  [":dahe"] = "出牌阶段，你可以与一名其他角色拼点；若你赢，该角色的非<font color='red'>♥</font>【闪】无效直到回合结束，"..
  "你可以将该角色拼点的牌交给场上一名体力不多于你的角色。若你没赢，你须展示手牌并选择一张弃置。每阶段限一次。",
  ["#dahe-choose"] = "大喝：你可以将%arg交给一名角色",
}

Fk:loadTranslationTable{
  ["starsp__lvmeng"] = "吕蒙",
  ["tanhu"] = "探虎",
  [":tanhu"] = "出牌阶段，你可与一名其他角色拼点。若你赢，你获得以下技能直到回合结束：你与该角色的距离视为1，"..
  "你对该角色使用的非延时类锦囊牌不能被【无懈可击】抵消。每阶段限一次。",
  ["mouduan"] = "谋断",
  [":mouduan"] = "转化技，通常状态下，你拥有标记“武”并拥有技能〖激昂〗和〖谦逊〗。当你的手牌数为2张或以下时，你须将你的标记翻面为“文”，"..
  "将该两项技能转化为〖英姿〗和〖克己〗。任一角色的回合开始前，你可弃一张牌将标记翻回。",
  --转换技，阳：你拥有激昂谦逊，当你失去手牌后，若你的手牌数小于等于2，你发动此技能；阴，你拥有英姿克己，一名角色准备阶段，你可以弃置一张牌
}

Fk:loadTranslationTable{
  ["starsp__liubei"] = "刘备",
  ["zhaolie"] = "昭烈",
  [":zhaolie"] = "摸牌阶段摸牌时，你可以少摸一张，指定你攻击范围内的一名角色亮出牌堆顶上3张牌，将其中的非基本牌和【桃】置于弃牌堆，该角色进行二选一："..
  "你对其造成X点伤害，然后他获得这些基本牌；或他依次弃置X张牌，然后你获得这些基本牌。（X为其中非基本牌的数量）",
  ["shichou"] = "誓仇",
  [":shichou"] = "主公技，限定技，回合开始时，你可指定一名蜀国角色并交给其两张牌。本盘游戏中，每当你受到伤害时，改为该角色代替你受到等量的伤害，"..
  "然后摸等量的牌，直到该角色第一次进入濒死状态。",
}

Fk:loadTranslationTable{
  ["starsp__daqiao"] = "大乔",
  ["yanxiao"] = "言笑",
  [":zhaolie"] = "出牌阶段，你可以将一张♦牌置于一名角色的判定区内，判定区内有“言笑”牌的角色下个判定阶段开始时，获得其判定区里的所有牌。",
  ["anxian"] = "安娴",
  [":anxian"] = "每当你使用【杀】对目标角色造成伤害时，你可以防止此次伤害，令其弃置一张手牌，然后你摸一张牌；当你成为【杀】的目标时，"..
  "你可以弃置一张手牌使之无效，然后该【杀】的使用者摸一张牌。",
}

Fk:loadTranslationTable{
  ["starsp__ganning"] = "甘宁",
  ["yinling"] = "银铃",
  [":yinling"] = "出牌阶段，你可以弃置一张黑色牌并指定一名其他角色，若如此做，你获得其一张牌并置于你的武将牌上，称为“锦”。（数量最多为四）",
  ["junwei"] = "军威",
  [":junwei"] = "回合结束阶段开始时，你可以将三张“锦”置入弃牌堆。若如此做，你须指定一名角色并令其选择一项：1.亮出一张【闪】，然后由你交给任意一名角色。"..
  "2.该角色失去1点体力，然后由你选择将其装备区的一张牌移出游戏，在该角色的回合结束后，将以此法移出游戏的装备牌移回原处。",
}

local xiahoudun = General(extension, "starsp__xiahoudun", "wei", 4)
local fenyong = fk.CreateTriggerSkill{
  name = "fenyong",
  anim_type = "defensive",
  events = {fk.Damaged, fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    if target == player then
      if event == fk.Damaged then
        return player:hasSkill(self.name)
      else
        return player:getMark("@@fenyong") > 0
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if event == fk.Damaged then
      return player.room:askForSkillInvoke(player, self.name, nil, "#fenyong-invoke")
    else
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    if event == fk.Damaged then
      player.room:setPlayerMark(player, "@@fenyong", 1)
    else
      return true
    end
  end,
}
local xuehen = fk.CreateTriggerSkill{
  name = "xuehen",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and target.phase == Player.Finish and player:getMark("@@fenyong") > 0
  end,
  on_cost = function(self, event, target, player, data)
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@fenyong", 0)
    local current = room.current
    local targets = {}
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if not player:isProhibited(p, Fk:cloneCard("slash")) then
        table.insert(targets, p.id)
      end
    end
    if #targets == 0 and (current == nil or current.dead or current:isNude()) then return end
    if #targets == 0 then
      if #current:getCardIds{Player.Hand, Player.Equip} <= player:getLostHp() then
        current:throwAllCards("he")
      else
        local cards = room:askForCardsChosen(player, current, player:getLostHp(), player:getLostHp(), "he", self.name)
        room:throwCard(cards, self.name, current, player)
      end
    else
      if current == nil or current.dead or current:isNude() or player:getLostHp() == 0 then
        local to = room:askForChoosePlayers(player, targets, 1, 1, "#xuehen-slash", self.name, false)
        if #to > 0 then
          to = room:getPlayerById(to[1])
        else
          to = room:getPlayerById(table.random(targets))
        end
        room:useVirtualCard("slash", nil, player, to, self.name, true)
      else
        local to = room:askForChoosePlayers(player, targets, 1, 1, "#xuehen-choose::"..current.id..":"..player:getLostHp(), self.name, false)
        if #to > 0 then
          room:useVirtualCard("slash", nil, player, room:getPlayerById(to[1]), self.name, true)
        else
          if #current:getCardIds{Player.Hand, Player.Equip} <= player:getLostHp() then
            current:throwAllCards("he")
          else
            local cards = room:askForCardsChosen(player, current, player:getLostHp(), player:getLostHp(), "he", self.name)
            room:throwCard(cards, self.name, current, player)
          end
        end
      end
    end
  end,
}
xiahoudun:addSkill(fenyong)
xiahoudun:addSkill(xuehen)
Fk:loadTranslationTable{
  ["starsp__xiahoudun"] = "夏侯惇",
  ["fenyong"] = "奋勇",
  [":fenyong"] = "每当你受到一次伤害后，你可以竖置你的体力牌；当你的体力牌为竖置状态时，防止你受到的所有伤害。",
  ["xuehen"] = "雪恨",
  [":xuehen"] = "每个角色的回合结束阶段开始时，若你的体力牌为竖置状态，你须横置之，然后选择一项：1.弃置当前回合角色X张牌（X为你已损失的体力值）；"..
  "2.视为对一名任意角色使用一张【杀】。",
  ["#fenyong-invoke"] = "奋勇：你可以竖置你的体力牌！",
  ["@@fenyong"] = "体力牌竖直",
  ["#xuehen-slash"] = "雪恨：选择一名角色视为对其使用【杀】",
  ["#xuehen-choose"] = "雪恨：选择一名角色视为对其使用【杀】，或点“取消”弃置 %dest %arg张牌",
}

return extension
