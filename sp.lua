local extension = Package("sp")
extension.extensionName = "sp"

local U = require "packages/utility/utility"

Fk:loadTranslationTable{
  ["sp"] = "SP",
  ["hulao1"] = "虎牢关",
  ["hulao2"] = "虎牢关",
}

local yangxiu = General(extension, "yangxiu", "wei", 3)
local danlao = fk.CreateTriggerSkill{
  name = "danlao",
  anim_type = "defensive",
  events = {fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.type == Card.TypeTrick and #AimGroup:getAllTargets(data.tos) > 1
  end,
  on_use = function(self, event, target, player, data)
    table.insertIfNeed(data.nullifiedTargets, player.id)
    player:drawCards(1, self.name)
  end,
}
local jilei = fk.CreateTriggerSkill{
  name = "jilei",
  anim_type = "masochism",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.from and not data.from.dead
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = room:askForChoice(player, {"basic", "trick", "equip"}, self.name)
    local types = data.from:getMark("@jilei-turn")
    if types == 0 then types = {} end
    table.insertIfNeed(types, choice .. "_char")
    room:setPlayerMark(data.from, "@jilei-turn", types)
  end,
}
local jilei_prohibit = fk.CreateProhibitSkill{
  name = "#jilei_prohibit",
  prohibit_use = function(self, player, card)
    local mark = player:getMark("@jilei-turn")
    if type(mark) == "table" and table.contains(mark, card:getTypeString() .. "_char") then
      local subcards = card:isVirtual() and card.subcards or {card.id}
      return #subcards > 0 and table.every(subcards, function(id)
        return table.contains(player:getCardIds(Player.Hand), id)
      end)
    end
  end,
  prohibit_response = function(self, player, card)
    local mark = player:getMark("@jilei-turn")
    if type(mark) == "table" and table.contains(mark, card:getTypeString() .. "_char") then
      local subcards = card:isVirtual() and card.subcards or {card.id}
      return #subcards > 0 and table.every(subcards, function(id)
        return table.contains(player:getCardIds(Player.Hand), id)
      end)
    end
  end,
  prohibit_discard = function(self, player, card)
    local mark = player:getMark("@jilei-turn")
    return type(mark) == "table" and table.contains(mark, card:getTypeString() .. "_char")
  end,
}
jilei:addRelatedSkill(jilei_prohibit)
yangxiu:addSkill(danlao)
yangxiu:addSkill(jilei)
Fk:loadTranslationTable{
  ["yangxiu"] = "杨修",
  ["#yangxiu"] = "恃才放旷",
  ["cv:yangxiu"] = "彭尧",
  ["illustrator:yangxiu"] = "张可",
  ["danlao"] = "啖酪",
  [":danlao"] = "当一个锦囊指定了包括你在内的多个目标，你可以摸一张牌，若如此做，该锦囊对你无效。",
  ["jilei"] = "鸡肋",
  [":jilei"] = "当你受到伤害后，你可以声明一种牌的类别（基本牌、锦囊牌、装备牌），对你造成伤害的角色不能使用、打出或弃置该类别的手牌直到回合结束。",
  ["@jilei-turn"] = "鸡肋",

  ["$danlao1"] = "来来，一人一口！",
  ["$danlao2"] = "我喜欢！",
  ["$jilei1"] = "食之无肉，弃之有味。",
  ["$jilei2"] = "曹公之意我已了然！",
  ["~yangxiu"] = "我固自以死之晚也……",
}

local gongsunzan = General(extension, "gongsunzan", "qun", 4)
local yicong = fk.CreateDistanceSkill{
  name = "yicong",
  frequency = Skill.Compulsory,
  correct_func = function(self, from, to)
    if from:hasSkill(self) and from.hp > 2 then
      return -1
    end
    if to:hasSkill(self) and to.hp < 3 then
      return 1
    end
    return 0
  end,
}
local yicong_audio = fk.CreateTriggerSkill{
  name = "#yicong_audio",

  refresh_events = {fk.HpChanged},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill("yicong") and not player:isFakeSkill("yicong")
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if player.hp > 2 and data.num > 0 and player.hp - data.num < 3 then
      room:notifySkillInvoked(player, "yicong", "offensive")
      player:broadcastSkillInvoke("yicong", 1)
    elseif player.hp < 3 and data.num < 0 and player.hp - data.num > 2 then
      room:notifySkillInvoked(player, "yicong", "defensive")
      player:broadcastSkillInvoke("yicong", 2)
    end
  end,
}
yicong:addRelatedSkill(yicong_audio)
gongsunzan:addSkill(yicong)
Fk:loadTranslationTable{
  ["gongsunzan"] = "公孙瓒",
  ["#gongsunzan"] = "白马将军",
  ["illustrator:gongsunzan"] = "Vincent",
  ["yicong"] = "义从",
  [":yicong"] = "锁定技，只要你的体力值大于2点，你计算与其他角色的距离时始终-1；只要你的体力值为2点或更低，其他角色计算与你的距离时始终+1。",

  ["$yicong1"] = "冲啊！",
  ["$yicong2"] = "众将听令，排好阵势，御敌！",
  ["~gongsunzan"] = "我军将败，我已无颜苟活于世……",
}

local yuanshu = General(extension, "yuanshu", "qun", 4)
local yongsi = fk.CreateTriggerSkill{
  name = "yongsi",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.DrawNCards, fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) then
      if event == fk.EventPhaseStart then
        return player.phase == Player.Discard
      end
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local kingdoms = {}
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      table.insertIfNeed(kingdoms, p.kingdom)
    end
    if event == fk.DrawNCards then
      data.n = data.n + #kingdoms
    else
      player.room:askForDiscard(player, #kingdoms, #kingdoms, true, self.name, false, ".", "#yongsi-discard:::"..#kingdoms)
    end
  end,
}
yuanshu:addSkill(yongsi)
local weidi = fk.CreateTriggerSkill{
  name = "weidi",
  events = {fk.GameStart, fk.EventAcquireSkill},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    local lordCheck = table.find(player.room.alive_players, function (p)
      return p ~= player and p.role == "lord" and
      table.find(p.player_skills, function(s) return s.lordSkill and not player:hasSkill(s, true) end) ~= nil
    end)
    if event == fk.GameStart then
      return lordCheck
    else
      if target == player then
        return data == self and player.room:getBanner("RoundCount") and lordCheck
      else
        return data.lordSkill and not player:hasSkill(data, true) and target.role == "lord"
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local skills = {}
    if event == fk.GameStart or target == player then
      for _, p in ipairs(room.alive_players) do
        if p ~= player and p.role == "lord" then
          for _, s in ipairs(p.player_skills) do
            if s.lordSkill and not player:hasSkill(s, true)  then
              table.insert(skills, s.name)
            end
          end
        end
      end
    else
      table.insert(skills, data.name)
    end
    if #skills > 0 then
      room:handleAddLoseSkills(player, table.concat(skills, "|"), nil)
    end
  end,
}
yuanshu:addSkill(weidi)
Fk:loadTranslationTable{
  ["yuanshu"] = "袁术",
  ["#yuanshu"] = "仲家帝",
  ["cv:yuanshu"] = "彭尧", -- or 马洋 ?
  ["designer:yuanshu"] = "韩旭",
  ["illustrator:yuanshu"] = "吴昊",

  ["yongsi"] = "庸肆",
  [":yongsi"] = "锁定技，摸牌阶段，你额外摸X张牌，X为场上现存势力数。弃牌阶段，你至少须弃掉等同于场上现存势力数的牌（不足则全弃）。",
  ["weidi"] = "伪帝",
  [":weidi"] = "锁定技，你视为拥有主公的主公技。",
  ["#yongsi-discard"] = "庸肆：你需弃掉等同于场上现存势力数的牌（%arg张）",

  ["$yongsi1"] = "大汉天下，已半入我手！",
  ["$yongsi2"] = "玉玺在手，天下我有！",
  ["$weidi1"] = "你们都得听我的号令！",
  ["$weidi2"] = "我才是皇帝！",
  ["~yuanshu"] = "可恶！就差……一步了……",
}

local pangde = General(extension, "sp__pangde", "wei", 4)
local juesi = fk.CreateActiveSkill{
  name = "juesi",
  anim_type = "offensive",
  card_num = 1,
  target_num = 1,
  prompt = "#juesi",
  can_use = function(self, player)
    return not player:isKongcheng()
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).trueName == "slash" and not Self:prohibitDiscard(Fk:getCardById(to_select))
  end,
  target_filter = function(self, to_select, selected)
    local target = Fk:currentRoom():getPlayerById(to_select)
    return #selected == 0 and not target:isNude() and Self:inMyAttackRange(target)
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:throwCard(effect.cards, self.name, player, player)
    if target.dead then return end
    local card = room:askForDiscard(target, 1, 1, true, self.name, false, ".", "#juesi-discard:"..player.id)
    if #card > 0 then
      card = Fk:getCardById(card[1])
      if card.trueName ~= "slash" and target.hp >= player.hp and not player.dead and not target.dead then
        room:useVirtualCard("duel", nil, player, target, self.name)
      end
    end
  end,
}
pangde:addSkill("mashu")
pangde:addSkill(juesi)
Fk:loadTranslationTable{
  ["sp__pangde"] = "庞德",
  ["#sp__pangde"] = "抬榇之悟",
  ["illustrator:sp__pangde"] = "天空之城",
  ["juesi"] = "决死",
  [":juesi"] = "出牌阶段，你可以弃置一张【杀】并选择攻击范围内的一名其他角色，然后令该角色弃置一张牌。"..
  "若该角色弃置的牌不为【杀】且其体力值不小于你，你视为对其使用一张【决斗】。",
  ["#juesi"] = "决死：弃置一张【杀】，令一名角色弃一张牌",
  ["#juesi-discard"] = "决死：你需弃置一张牌，若不为【杀】且你体力值不小于 %src，视为其对你使用【决斗】",

  ["$juesi1"] = "死都不怕，还能怕你！",
  ["$juesi2"] = "抬棺而战，不死不休！",
  ["~sp__pangde"] = "受魏王厚恩，唯以死报之。",
}

local lvbu = General(extension, "hulao1__godlvbu", "god", 8)
lvbu.hidden = true
lvbu.hulao_status = 1
local hulao__jingjia = fk.CreateTriggerSkill{
  name = "hulao__jingjia",
  events = {fk.GameStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local laobu_equip = {{"py_halberd", Card.Diamond, 12},{"py_hat", Card.Diamond, 1}}
    local laobu_armors = {{"py_robe", Card.Club, 1},{"py_belt", Card.Spade, 2}}
    table.insert(laobu_equip, table.random(laobu_armors))
    local cards = table.filter(U.prepareDeriveCards(room, laobu_equip, "laobu_equip"), function (id)
      return room:getCardArea(id) == Card.Void
    end)
    if #cards > 0 then
      room:moveCardIntoEquip(player, cards, self.name, false, player)
    end
  end,
}
local hulao__aozhan = fk.CreateTriggerSkill{
  name = "hulao__aozhan",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = { fk.DrawNCards, fk.DamageInflicted, fk.EventPhaseChanging},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) or target ~= player then return false end
    if event == fk.DrawNCards then
      return #player:getEquipments(Card.SubtypeOffensiveRide) > 0 or #player:getEquipments(Card.SubtypeDefensiveRide) > 0
    elseif event == fk.EventPhaseChanging then
      return data.to == Player.Judge and #player:getEquipments(Card.SubtypeTreasure) > 0
    elseif event == fk.DamageInflicted then
      return #player:getEquipments(Card.SubtypeArmor) > 0 and data.damage > 1
    end
  end,
  on_use = function(self, event, target, player, data)
    if event == fk.EventPhaseChanging then
      return true
    elseif event == fk.DrawNCards then
      data.n = data.n + 1
    elseif event == fk.DamageInflicted then
      data.damage = 1
    end
  end,
}
local hulao__aozhan__targetmod = fk.CreateTargetModSkill{
  name = "#hulao__aozhan__targetmod",
  anim_type = "offensive",
  residue_func = function(self, player, skill, scope)
    if player:hasSkill("hulao__aozhan") and #player:getEquipments(Card.SubtypeWeapon) > 0 and
      skill.trueName == "slash_skill" and scope == Player.HistoryPhase then
      return 1
    end
  end,
}
hulao__aozhan:addRelatedSkill(hulao__aozhan__targetmod)
lvbu:addSkill("mashu")
lvbu:addSkill("wushuang")
lvbu:addSkill(hulao__jingjia)
lvbu:addSkill(hulao__aozhan)
Fk:loadTranslationTable{
  ["hulao1__godlvbu"] = "神吕布",
  ["#hulao1__godlvbu"] = "最强神话",
  ["illustrator:hulao1__godlvbu"] = "LiuHeng",

  ["hulao__jingjia"] = "精甲",
  [":hulao__jingjia"] = "游戏开始时，你将本局游戏中加入的装备置入你的装备区。",
  ["hulao__aozhan"] = "鏖战",
  [":hulao__aozhan"] = "锁定技，若你装备区里有：武器牌，你可以多使用一张【杀】；防具牌，防止你受到的超过1点的伤害"..
  "；坐骑牌，摸牌阶段多摸一张牌；宝物牌，跳过你的判定阶段。",
}

local lvbu2 = General(extension, "hulao2__godlvbu", "god", 4)
lvbu2.hidden = true
lvbu2.hulao_status = 2
local xiuluo = fk.CreateTriggerSkill{
  name = "xiuluo",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start and
      #player:getCardIds(Player.Judge) > 0 and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local pattern = ".|.|"..table.concat(table.map(player:getCardIds(Player.Judge), function(id)
      return Fk:getCardById(id, true):getSuitString() end), ",")
    local card = player.room:askForDiscard(player, 1, 1, false, self.name, true, pattern, "#xiuluo-invoke", true)
    if #card > 0 then
      self.cost_data = card
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local suit = Fk:getCardById(self.cost_data[1], true).suit
    room:throwCard(self.cost_data, self.name, player, player)
    local cards = table.filter(player:getCardIds(Player.Judge), function(id)
      return Fk:getCardById(id, true).suit == suit end)
    if #cards == 0 then return false end
    local cid = room:askForCardChosen(player, player, {
      card_data = {
        { "$Judge", cards }
      }
    }, self.name)
    room:throwCard(cid, self.name, player, player)
    while #player:getCardIds(Player.Judge) > 0 and not player:isKongcheng() and not player.dead do
      local pattern = ".|.|"..table.concat(table.map(player:getCardIds(Player.Judge), function(id)
        return Fk:getCardById(id, true):getSuitString() end), ",")
      local card = room:askForDiscard(player, 1, 1, false, self.name, true, pattern, "#xiuluo-invoke")
      if #card == 0 then break end
      suit = Fk:getCardById(card[1], true).suit
      cards = table.filter(player:getCardIds(Player.Judge), function(id)
        return Fk:getCardById(id, true).suit == suit end)
      if #cards > 0 then
        cid = room:askForCardChosen(player, player, { card_data = { { "$Judge", cards } } }, self.name)
        room:throwCard(cid, self.name, player, player)
      end
    end
  end
}
local hulao__shenwei = fk.CreateTriggerSkill{
  name = "hulao__shenwei",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.DrawNCards},
  on_use = function(self, event, target, player, data)
    data.n = data.n + math.min(3, #player.room:getOtherPlayers(player))
  end,
}
local hulao__shenwei_maxcards = fk.CreateMaxCardsSkill{
  name = "#hulao__shenwei_maxcards",
  correct_func = function(self, player)
    if player:hasSkill(hulao__shenwei) then
      return math.min(3, #table.filter(Fk:currentRoom().alive_players, function (p)
        return p ~= player
      end))
    end
  end,
}
local shenji = fk.CreateTargetModSkill{
  name = "shenji",
  anim_type = "offensive",
  residue_func = function(self, player, skill, scope)
    if player:hasSkill(self) and skill.trueName == "slash_skill" and scope == Player.HistoryPhase then
      return 1
    end
  end,
  extra_target_func = function(self, player, skill)
    if player:hasSkill(self) and skill.trueName == "slash_skill" then
      return 2
    end
  end,
}
hulao__shenwei:addRelatedSkill(hulao__shenwei_maxcards)
lvbu2:addSkill("mashu")
lvbu2:addSkill("wushuang")
lvbu2:addSkill(xiuluo)
lvbu2:addSkill(hulao__shenwei)
lvbu2:addSkill(shenji)
local shenwei = fk.CreateTriggerSkill{
  name = "shenwei",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.DrawNCards},
  on_use = function(self, event, target, player, data)
    data.n = data.n + 2
  end,
}
local shenwei_maxcards = fk.CreateMaxCardsSkill{
  name = "#shenwei_maxcards",
  correct_func = function(self, player)
    if player:hasSkill(shenwei) then
      return 2
    end
  end,
}
shenwei:addRelatedSkill(shenwei_maxcards)
Fk:addSkill(shenwei)
Fk:loadTranslationTable{
  ["hulao2__godlvbu"] = "神吕布",
  ["#hulao2__godlvbu"] = "暴怒的战神",
  ["illustrator:hulao2__godlvbu"] = "LiuHeng",

  ["xiuluo"] = "修罗",
  [":xiuluo"] = "准备阶段，你可以弃置与你判定区内一张牌花色相同的一张手牌，弃置你判定区内的此牌且你可以重复此流程。",
  ["hulao__shenwei"] = "神威",
  [":hulao__shenwei"] = "锁定技，摸牌阶段，你额外摸X张牌；你的手牌上限+X（X为其他存活角色数且至多为3）。",
  ["shenwei"] = "神威",
  [":shenwei"] = "锁定技，摸牌阶段，你额外摸两张牌；你的手牌上限+2。",
  ["shenji"] = "神戟",
  [":shenji"] = "你使用【杀】的次数上限+1，额定目标数上限+2。",
  ["#xiuluo-invoke"] = "修罗：你可以弃一张花色相同的手牌，以弃置你判定区里的一张延时锦囊",

  ["$xiuluo1"] = "准备受死吧！",
  ["$xiuluo2"] = "鼠辈，螳臂当车！",
  ["$hulao__shenwei1"] = "荧烛之火，也敢与日月争辉！",
  ["$hulao__shenwei2"] = "我不会输给任何人！",
  ["$shenji1"] = "杂鱼们，都去死吧！",
  ["$shenji2"] = "竟想赢我，痴人说梦！",
  ["~hulao2__godlvbu"] = "虎牢关……失守了……",
}

local caiwenji = General(extension, "sp__caiwenji", "wei", 3, 3, General.Female)
local chenqing = fk.CreateTriggerSkill{
  name = "chenqing",
  anim_type = "support",
  events = {fk.EnterDying},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryRound) == 0 and
    not table.every(player.room.alive_players, function (p)
      return p == player or p == target
    end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    for _, p in ipairs(room.alive_players) do
      if p ~= target and p ~= player then
        table.insert(targets, p.id)
      end
    end
    if #targets == 0 then return end
    local to = room:askForChoosePlayers(player, targets, 1, 1, "#chenqing-choose", self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    to:drawCards(4, self.name)
    if to.dead then return end
    local cards = room:askForDiscard(to, 4, 4, true, self.name, false, ".", "#chenqing-discard", true)
    local suits = {}
    for _, id in ipairs(cards) do
      if Fk:getCardById(id).suit ~= Card.NoSuit then
        table.insertIfNeed(suits, Fk:getCardById(id).suit)
      end
    end
    room:throwCard(cards, self.name, to, to)
    if #suits == 4 and not target.dead then
      room:useVirtualCard("peach", nil, to, target, self.name)
    end
  end,
}
local mozhi_view_as = fk.CreateViewAsSkill{
  name = "mozhi_view_as",
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard(Self:getMark("mozhi_to_use"))
    card:addSubcard(cards[1])
    card.skillName = "mozhi"
    return card
  end,
}
local mozhi = fk.CreateTriggerSkill{
  name = "mozhi",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and player.phase == Player.Finish and not player:isKongcheng() then
      local room = player.room
      local names = player:getMark("mozhi_record-phase")
      if type(names) ~= "table" then
        names = {}
        local play_ids = {}
        room.logic:getEventsOfScope(GameEvent.Phase, 1, function (e)
          if e.data[2] == Player.Play then
            table.insert(play_ids, {e.id, e.end_id})
          end
          return false
        end, Player.HistoryTurn)
        room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
          local in_play = false
          for _, ids in ipairs(play_ids) do
            if #ids == 2 and e.id > ids[1] and e.id < ids[2] then
              in_play = true
              break
            end
          end
          if in_play then
            local use = e.data[1]
            if use.from == player.id and (use.card.type == Card.TypeBasic or use.card:isCommonTrick()) then
              table.insert(names, use.card.name)
            end
          end
          return #names > 1
        end, Player.HistoryTurn)
        room:setPlayerMark(player, "mozhi_record-phase", names)
      end
      if #names > 0 then
        local name = names[1]
        local to_use = Fk:cloneCard(name)
        return player:canUse(to_use) and not player:prohibitUse(to_use)
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local names = player:getMark("mozhi_record-phase")
    if type(names) ~= "table" then return false end
    local name = names[1]
    local to_use = Fk:cloneCard(name)
    if not player:canUse(to_use) or player:prohibitUse(to_use) then return false end
    local room = player.room
    room:setPlayerMark(player, "mozhi_to_use", name)
    local success, dat = room:askForUseActiveSkill(player, "mozhi_view_as", "#mozhi-invoke:::"..name, true)
    if success then
      self.cost_data = dat
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = Fk:cloneCard(player:getMark("mozhi_to_use"))
    card.skillName = self.name
    card:addSubcards(self.cost_data.cards)
    room:useCard{
      from = player.id,
      tos = table.map(self.cost_data.targets, function(id) return {id} end),
      card = card,
    }
    if player.dead then return end
    local names = player:getMark("mozhi_record-phase")
    if type(names) == "table" and #names > 1 then
      local name = names[2]
      local to_use = Fk:cloneCard(name)
      if not player:canUse(to_use) or player:prohibitUse(to_use) then return false end
      room:setPlayerMark(player, "mozhi_to_use", name)
      local success, dat = player.room:askForUseActiveSkill(player, "mozhi_view_as", "#mozhi-invoke:::"..name, true)
      if success then
        card = Fk:cloneCard(player:getMark("mozhi_to_use"))
        card.skillName = self.name
        card:addSubcards(dat.cards)
        room:useCard{
          from = player.id,
          tos = table.map(dat.targets, function(id) return {id} end),
          card = card,
        }
      end
    end
  end,
}
Fk:addSkill(mozhi_view_as)
caiwenji:addSkill(chenqing)
caiwenji:addSkill(mozhi)
Fk:loadTranslationTable{
  ["sp__caiwenji"] = "蔡文姬",
  ["#sp__caiwenji"] = "金璧之才",
  ["cv:sp__caiwenji"] = "小N",
  ["designer:sp__caiwenji"] = "韩旭",
  ["illustrator:sp__caiwenji"] = "木美人",

  ["chenqing"] = "陈情",
  [":chenqing"] = "每轮限一次，当一名角色进入濒死状态时，你可以令另一名其他角色摸四张牌，然后弃置四张牌，"..
  "若其以此法弃置的四张牌的花色各不相同，则其视为对濒死状态的角色使用一张【桃】。",
  ["mozhi"] = "默识",
  ["mozhi_view_as"] = "默识",
  [":mozhi"] = "结束阶段，你可以将一张手牌当你本回合出牌阶段使用过的第一张基本牌或非延时锦囊牌使用，"..
  "然后你可以将一张手牌当你本回合出牌阶段使用过的第二张基本牌或非延时锦囊牌使用。",
  ["#chenqing-choose"] = "陈情：令一名其他角色摸四张牌然后弃四张牌，若花色各不相同视为对濒死角色使用【桃】",
  ["#chenqing-discard"] = "陈情：需弃置四张牌，若花色各不相同则视为对濒死角色使用【桃】",
  ["#mozhi-invoke"] = "默识：你可以将一张手牌当【%arg】使用",

  ["$chenqing1"] = "陈生死离别之苦，悲乱世之跌宕。",
  ["$chenqing2"] = "乱世陈情，字字血泪！",
  ["$mozhi1"] = "博闻强识，不辱才女之名。",
  ["$mozhi2"] = "今日默书，方恨千卷诗书未能全记。",
  ["~sp__caiwenji"] = "命运……弄人……",
}

local machao = General(extension, "sp__machao", "qun", 4)
local sp__zhuiji = fk.CreateDistanceSkill{
  name = "sp__zhuiji",
  frequency = Skill.Compulsory,
  fixed_func = function(self, from, to)
    if from:hasSkill(self) and from.hp >= to.hp then
      return 1
    end
  end,
}
local shichou = fk.CreateTriggerSkill{
  name = "shichou",
  anim_type = "offensive",
  events = {fk.AfterCardTargetDeclared},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:isWounded() and data.card.trueName == "slash" and
      #player.room:getUseExtraTargets(data) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local n = player:getLostHp()
    local tos = player.room:askForChoosePlayers(player, player.room:getUseExtraTargets(data), 1, n,
    "#shichou-choose:::"..data.card:toLogString()..":"..tostring(n), self.name, true)
    if #tos > 0 then
      self.cost_data = tos
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    table.insertTable(data.tos, table.map(self.cost_data, function (p)
      return {p}
    end))
  end,
}
machao:addSkill(sp__zhuiji)
machao:addSkill(shichou)
Fk:loadTranslationTable{
  ["sp__machao"] = "马超",
  ["#sp__machao"] = "西凉的猛狮",
  ["designer:sp__machao"] = "凌天翼",
  ["illustrator:sp__machao"] = "天空之城",
  ["sp__zhuiji"] = "追击",
  [":sp__zhuiji"] = "锁定技，你计算体力值比你少的角色的距离始终为1。",
  ["shichou"] = "誓仇",
  [":shichou"] = "你使用【杀】可以额外选择至多X名角色为目标（X为你已损失的体力值）。",

  ["#shichou-choose"] = "是否使用誓仇，为此%arg额外指定至多%arg2个目标",

  ["$shichou1"] = "灭族之恨，不共戴天！",
  ["$shichou2"] = "休想跑！",
  ["~sp__machao"] = "西凉，回不去了……",
}

local jiaxu = General(extension, "sp__jiaxu", "wei", 3)
local zhenlue = fk.CreateTriggerSkill{
  name = "zhenlue",
  anim_type = "control",
  events = {fk.AfterCardUseDeclared},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      data.card.type == Card.TypeTrick and data.card.sub_type ~= Card.SubtypeDelayedTrick
  end,
  on_use = function(self, event, target, player, data)
    data.unoffsetableList = table.map(player.room.alive_players, Util.IdMapper)
  end,
}
local zhenlue_prohibit = fk.CreateProhibitSkill{
  name = "#zhenlue_prohibit",
  is_prohibited = function(self, from, to, card)
    return to:hasSkill(self) and card.sub_type == Card.SubtypeDelayedTrick
  end,
}
local jianshu = fk.CreateActiveSkill{
  name = "jianshu",
  anim_type = "control",
  frequency = Skill.Limited,
  card_num = 1,
  target_num = 1,
  prompt = "#jianshu",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0 and not player:isKongcheng()
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).color == Card.Black
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
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
    local to = room:askForChoosePlayers(player, targets, 1, 1, "#jianshu-choose::"..target.id, self.name, false)
    to = room:getPlayerById(to[1])
    local pindian = target:pindian({to}, self.name)
    if pindian.results[to.id].winner then
      local winner, loser
      if pindian.results[to.id].winner == target then
        winner = target
        loser = to
      else
        winner = to
        loser = target
      end
      room:askForDiscard(winner, 2, 2, true, self.name, false, ".")
      room:loseHp(loser, 1, self.name)
    else
      room:loseHp(target, 1, self.name)
      room:loseHp(to, 1, self.name)
    end
  end
}
local yongdi = fk.CreateTriggerSkill{
  name = "yongdi",
  anim_type = "masochism",
  frequency = Skill.Limited,
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and target:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryGame) == 0 and
      table.find(player.room:getOtherPlayers(player), function (p) return p:isMale() end)
  end,
  on_cost = function(self, event, target, player, data)
    local to = player.room:askForChoosePlayers(player, table.map(table.filter(player.room:getOtherPlayers(player), function(p)
      return p:isMale() end), Util.IdMapper), 1, 1, "#yongdi-choose", self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    room:changeMaxHp(to, 1)
    if to.role ~= "lord" then
      for _, skill in ipairs(Fk.generals[to.general].skills) do
        if skill.lordSkill then
          room:handleAddLoseSkills(to, skill.name, nil)
        end
      end
      if to.deputyGeneral ~= "" then
        for _, skill in ipairs(Fk.generals[to.deputyGeneral].skills) do
          if skill.lordSkill then
            room:handleAddLoseSkills(to, skill.name, nil)
          end
        end
      end
    end
  end,
}
zhenlue:addRelatedSkill(zhenlue_prohibit)
jiaxu:addSkill(zhenlue)
jiaxu:addSkill(jianshu)
jiaxu:addSkill(yongdi)
Fk:loadTranslationTable{
  ["sp__jiaxu"] = "贾诩",
  ["#sp__jiaxu"] = "算无遗策",
  ["designer:sp__jiaxu"] = "千幻",
  ["illustrator:sp__jiaxu"] = "雪君S",
  ["zhenlue"] = "缜略",
  [":zhenlue"] = "锁定技，你使用的非延时锦囊牌不能被抵消，你不能被选择为延时锦囊牌的目标。",
  ["jianshu"] = "间书",
  [":jianshu"] = "限定技，出牌阶段，你可以将一张黑色手牌交给一名其他角色，并选择一名攻击范围内含有其的另一名角色，"..
  "然后令这两名角色拼点：赢的角色弃置两张牌，没赢的角色失去1点体力。",
  ["yongdi"] = "拥嫡",
  [":yongdi"] = "限定技，当你受到伤害后，你可令一名其他男性角色增加1点体力上限，然后若该角色的武将牌上有主公技且其身份不为主公，其获得此主公技。",
  ["#jianshu"] = "间书：将一张黑色手牌交给一名角色，再选择另一名角色与其拼点",
  ["#jianshu-choose"] = "间书：选择一名攻击范围内含有 %dest 的角色，两名角色拼点",
  ["#yongdi-choose"] = "拥嫡：你可令一名其他男性角色增加1点体力上限并获得其武将牌上的主公技",

  ["$jianshu1"] = "来，让我看一出好戏吧。",
  ["$jianshu2"] = "纵有千军万马，离心则难成大事。",
  ["$yongdi1"] = "臣愿为世子，肝脑涂地。",
  ["$yongdi2"] = "嫡庶有别，尊卑有序。",
  ["~sp__jiaxu"] = "立嫡之事，真是取祸之道！",
}

local caohong = General(extension, "caohong", "wei", 4)
local yuanhu_active = fk.CreateActiveSkill{
  name = "#yuanhu_active",
  card_num = 1,
  target_num = 1,
  card_filter = function(self, to_select, selected, targets)
    return #selected == 0 and Fk:getCardById(to_select).type == Card.TypeEquip
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and #selected_cards == 1 and
      Fk:currentRoom():getPlayerById(to_select):hasEmptyEquipSlot(Fk:getCardById(selected_cards[1]).sub_type)
  end,
}
local yuanhu = fk.CreateTriggerSkill{
  name = "yuanhu",
  mute = true,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish
  end,
  on_cost = function(self, event, target, player, data)
    local success, dat = player.room:askForUseActiveSkill(player, "#yuanhu_active", "#yuanhu-invoke", true)
    if success and dat then
      self.cost_data = {cards = dat.cards, tos = dat.targets}
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, self.name, "support", self.cost_data.tos)
    local to = room:getPlayerById(self.cost_data.tos[1])
    local card = Fk:getCardById(self.cost_data.cards[1])
    room:moveCardIntoEquip(to, self.cost_data.cards[1], self.name, false, player)
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
      local p = room:askForChoosePlayers(player, targets, 1, 1, "#yuanhu-choose::"..to.id, self.name, false)
      if #p > 0 then
        card = room:askForCardChosen(player, room:getPlayerById(p[1]), "hej", self.name)
        room:throwCard(card, self.name, room:getPlayerById(p[1]), player)
      end
    elseif card.sub_type == Card.SubtypeArmor then
      player:broadcastSkillInvoke("yuanhu", 2)
      to:drawCards(1, self.name)
    elseif card.sub_type == Card.SubtypeOffensiveRide or card.sub_type == Card.SubtypeDefensiveRide then
      player:broadcastSkillInvoke("yuanhu", 3)
      if to:isWounded() then
        room:recover({
          who = to,
          num = 1,
          recoverBy = player,
          skillName = self.name,
        })
      end
    end
  end,
}
Fk:addSkill(yuanhu_active)
caohong:addSkill(yuanhu)
Fk:loadTranslationTable{
  ["caohong"] = "曹洪",
  ["#caohong"] = "福将",
  ["designer:caohong"] = "韩旭",
  ["illustrator:caohong"] = "LiuHeng",
  ["yuanhu"] = "援护",
  [":yuanhu"] = "结束阶段开始时，你可以将一张装备牌置于一名角色的装备区里，然后根据此装备牌的种类执行以下效果：<br>"..
  "武器牌：弃置与该角色距离为1的一名角色区域中的一张牌；<br>防具牌：该角色摸一张牌；<br>坐骑牌：该角色回复1点体力。",
  ["#yuanhu_active"] = "援护",
  ["#yuanhu-invoke"] = "援护：你可以将一张装备牌置入一名角色的装备区",
  ["#yuanhu-choose"] = "援护：弃置 %dest 距离1的一名角色区域中的一张牌",

  ["$yuanhu1"] = "将军，这件兵器可还趁手？",
  ["$yuanhu2"] = "刀剑无眼，须得小心防护。",
  ["$yuanhu3"] = "宝马配英雄！哈哈哈哈……",
  ["~caohong"] = "福兮祸所伏……",
}

local guanyinping = General(extension, "guanyinping", "shu", 3, 3, General.Female)
local xueji = fk.CreateActiveSkill{
  name = "xueji",
  anim_type = "offensive",
  card_num = 1,
  min_target_num = 1,
  max_target_num = function ()
    return Self:getLostHp()
  end,
  prompt = function ()
    return "#xueji:::"..Self:getLostHp()
  end,
  can_use = function(self, player)
    return player:isWounded() and player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, to_select, selected, targets)
    return #selected == 0 and Fk:getCardById(to_select).color == Card.Red and not Self:prohibitDiscard(Fk:getCardById(to_select))
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    if #selected < Self:getLostHp() and #selected_cards > 0 then
      if Fk:currentRoom():getCardArea(selected_cards[1]) ~= Player.Equip then
        return Self:inMyAttackRange(Fk:currentRoom():getPlayerById(to_select))
      else
        return Self:distanceTo(Fk:currentRoom():getPlayerById(to_select)) == 1
      end
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:throwCard(effect.cards, self.name, player, player)
    local tos = effect.tos
    room:sortPlayersByAction(tos)
    for _, pid in ipairs(tos) do
      local p = room:getPlayerById(pid)
      if not p.dead then
        room:damage{
          from = player,
          to = p,
          damage = 1,
          skillName = self.name,
        }
      end
    end
    for _, pid in ipairs(tos) do
      local p = room:getPlayerById(pid)
      if not p.dead then
        p:drawCards(1, self.name)
      end
    end
  end,
}
local huxiao = fk.CreateTriggerSkill{
  name = "huxiao",
  anim_type = "offensive",
  events = {fk.CardEffectCancelledOut},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.trueName == "slash" and player.phase == Player.Play
  end,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, MarkEnum.SlashResidue.."-phase")
  end,
}
local wuji = fk.CreateTriggerSkill{
  name = "wuji",
  anim_type = "special",
  events = {fk.EventPhaseStart},
  frequency = Skill.Wake,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      player.phase == Player.Finish and
      player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player, data)
    local n = 0
    player.room.logic:getActualDamageEvents(1, function(e)
      local damage = e.data[1]
      if damage.from == player then
        n = n + damage.damage
      end
    end)
    return n > 2
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, 1)
    if player:isWounded() and not player.dead then
      room:recover({
        who = player,
        num = 1,
        recoverBy = player,
        skillName = self.name
      })
    end
    room:handleAddLoseSkills(player, "-huxiao", nil, true, false)
  end,
}
guanyinping:addSkill(xueji)
guanyinping:addSkill(huxiao)
guanyinping:addSkill(wuji)
Fk:loadTranslationTable{
  ["guanyinping"] = "关银屏",
  ["#guanyinping"] = "武姬",
  ["designer:guanyinping"] = "韩旭",
  ["illustrator:guanyinping"] = "木美人",
  ["xueji"] = "血祭",
  [":xueji"] = "出牌阶段限一次，你可弃置一张红色牌，并对你攻击范围内的至多X名其他角色各造成1点伤害（X为你损失的体力值），然后这些角色各摸一张牌。",
  ["huxiao"] = "虎啸",
  [":huxiao"] = "若你于出牌阶段使用的【杀】被【闪】抵消，则本阶段你可以额外使用一张【杀】。",
  ["wuji"] = "武继",
  [":wuji"] = "觉醒技，结束阶段开始时，若本回合你已造成3点或更多伤害，你须加1点体力上限并回复1点体力，然后失去技能〖虎啸〗。",
  ["#xueji"] = "血祭：弃置一张红色牌，对至多%arg名角色各造成1点伤害并各摸一张牌",

  ["$xueji1"] = "取你首级，祭先父之灵！",
  ["$xueji2"] = "这炽热的鲜血，父亲，你可感觉得到？",
  ["$huxiao1"] = "大仇未报，还不能放弃！",
  ["$huxiao2"] = "虎父无犬女！",
  ["$wuji1"] = "我感受到了，父亲的力量。",
  ["$wuji2"] = "我也要像父亲那样坚强。",
  ["~guanyinping"] = "父亲，你来救我了吗……",
}

local liuxie = General(extension, "liuxie", "qun", 3)
local tianming = fk.CreateTriggerSkill{
  name = "tianming",
  anim_type = "defensive",
  events = {fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.trueName == "slash"
  end,
  on_cost = function(self, event, target, player, data)
    local ids = table.filter(player:getCardIds("he"), function(id) return not player:prohibitDiscard(Fk:getCardById(id)) end)
    if #ids < 3 then
      if player.room:askForSkillInvoke(player, self.name, data, "#tianming-cost") then
        self.cost_data = ids
        return true
      end
    else
      local cards = player.room:askForDiscard(player, 2, 2, true, self.name, true, ".", "#tianming-cost", true)
      if #cards > 0 then
        self.cost_data = cards
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(self.cost_data, self.name, player, player)
    if not player.dead then
      player:drawCards(2, self.name)
    end
    local to = {}
    local x = 0
    for _, p in ipairs(room.alive_players) do
      if x < p.hp then
        x = p.hp
        to = {p}
      elseif x == p.hp then
        table.insert(to, p)
      end
    end
    if #to ~= 1 or to[1] == player then return end
    to = to[1]
    x = 0
    for _, id in ipairs(to:getCardIds("he")) do
      if not to:prohibitDiscard(Fk:getCardById(id)) then
        x = x+1
        if x == 2 then break end
      end
    end
    if x == 0 then
      if room:askForSkillInvoke(to, self.name, data, "#tianming-cost") then
        to:drawCards(2, self.name)
      end
    else
      local cards = room:askForDiscard(to, x, 2, true, self.name, true, ".", "#tianming-cost")
      if #cards > 0 and not to.dead then
        room:drawCards(to, 2, self.name)
      end
    end
  end,
}
local mizhao = fk.CreateActiveSkill{
  name = "mizhao",
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  prompt = "#mizhao",
  can_use = function(self, player)
    return not player:isKongcheng() and player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:obtainCard(target.id, player:getCardIds(Player.Hand), false, fk.ReasonGive, player.id)
    if player.dead or target.dead or target:isKongcheng() then return end
    local targets = table.filter(room:getOtherPlayers(player), function(p)
      return target:canPindian(p) and p ~= target
    end)
    if #targets == 0 then return end
    local tos = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1,
      "#mizhao-choose::"..target.id, self.name, false)
    local to = room:getPlayerById(tos[1])
    local pindian = target:pindian({to}, self.name)
    if pindian.results[to.id].winner then
      local winner, loser
      if pindian.results[to.id].winner == target then
        winner = target
        loser = to
      else
        winner = to
        loser = target
      end
      if loser.dead then return end
      room:useVirtualCard("slash", nil, winner, {loser}, self.name)
    end
  end
}
liuxie:addSkill(tianming)
liuxie:addSkill(mizhao)
Fk:loadTranslationTable{
  ["liuxie"] = "刘协",
  ["#liuxie"] = "受困天子",
  ["designer:liuxie"] = "韩旭",
  ["illustrator:liuxie"] = "LiuHeng",
  ["tianming"] = "天命",
  [":tianming"] = "当你成为【杀】的目标时，你可以弃置两张牌（不足则全弃，无牌则不弃），然后摸两张牌；然后若场上体力唯一最多的角色不为你，"..
  "该角色也可以如此做。",
  ["mizhao"] = "密诏",
  [":mizhao"] = "出牌阶段限一次，你可以将所有手牌（至少一张）交给一名其他角色。若如此做，你令该角色与你指定的另一名有手牌的其他角色拼点，"..
  "视为拼点赢的角色对没赢的角色使用一张【杀】。",
  ["#tianming-cost"] = "天命：你可以弃置两张牌（不足则全弃，无牌则不弃），然后摸两张牌",
  ["#mizhao"] = "密诏：将所有手牌交给一名角色，令其与另一名角色拼点",
  ["#mizhao-choose"] = "密诏：选择与 %dest 拼点的角色，赢者视为对没赢者使用【杀】",

  ["$tianming1"] = "皇汉国祚，千年不息！",
  ["$tianming2"] = "朕乃大汉皇帝，天命之子！",
  ["$mizhao1"] = "爱卿世受皇恩，堪此重任。",
  ["$mizhao2"] = "此诏事关重大，切记小心行事。",
  ["~liuxie"] = "为什么，不把复兴汉室的权力交给我……",
}

local lingju = General(extension, "lingju", "qun", 3, 3, General.Female)
local jieyuan = fk.CreateTriggerSkill{
  name = "jieyuan",
  mute = true,
  events = {fk.DamageCaused, fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and not player:isKongcheng() then
      if event == fk.DamageCaused then
        return data.to.hp >= player.hp
      else
        return data.from and data.from.hp >= player.hp
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local pattern, prompt
    if event == fk.DamageCaused then
      pattern = ".|.|spade,club|.|.|."
      prompt = "#jieyuan1-invoke::"..data.to.id
    else
      pattern = ".|.|heart,diamond|.|.|."
      prompt = "#jieyuan2-invoke"
    end
    local card = player.room:askForDiscard(player, 1, 1, false, self.name, true, pattern, prompt, true)
    if #card > 0 then
      self.cost_data = card
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(self.cost_data, self.name, player, player)
    if event == fk.DamageCaused then
      player:broadcastSkillInvoke(self.name, 1)
      room:notifySkillInvoked(player, self.name, "offensive")
      data.damage = data.damage + 1
    else
      player:broadcastSkillInvoke(self.name, 2)
      room:notifySkillInvoked(player, self.name, "defensive")
      data.damage = data.damage - 1
    end
  end,
}
local fenxin = fk.CreateTriggerSkill{
  name = "fenxin",
  anim_type = "offensive",
  frequency = Skill.Limited,
  events = {fk.BeforeGameOverJudge},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryGame) == 0 and
      data.damage and data.damage.from and data.damage.from == player and
      player.role ~= "lord" and target.role ~= "lord"
  end,
  on_cost = function (self, event, target, player, data)
    if player.room:askForSkillInvoke(player, self.name, data, "#fenxin-invoke:"..target.id) then
      self.cost_data = {tos = {target.id}}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.role, target.role = target.role, player.role
    player.room:broadcastProperty(player, "role")
    player.room:broadcastProperty(target, "role")
  end,
}
lingju:addSkill(jieyuan)
lingju:addSkill(fenxin)
Fk:loadTranslationTable{
  ["lingju"] = "灵雎",
  ["#lingju"] = "情随梦逝",
  ["designer:lingju"] = "韩旭",
  ["illustrator:lingju"] = "木美人",
  ["jieyuan"] = "竭缘",
  [":jieyuan"] = "当你对一名其他角色造成伤害时，若其体力值大于或等于你的体力值，你可弃置一张黑色手牌令此伤害+1；"..
  "当你受到一名其他角色造成的伤害时，若其体力值大于或等于你的体力值，你可弃置一张红色手牌令此伤害-1。",
  ["fenxin"] = "焚心",
  [":fenxin"] = "限定技，当你杀死一名非主公角色时，在其翻开身份牌之前，你可以与该角色交换身份牌。（你的身份为主公时不能发动此技能。）",
  ["#fenxin-invoke"] = "焚心：你可以与 %src 交换身份牌",
  ["#jieyuan1-invoke"] = "竭缘：你可以弃置一张黑色手牌令对 %dest 造成的伤害+1",
  ["#jieyuan2-invoke"] = "竭缘：你可以弃置一张红色手牌令此伤害-1",

  ["$jieyuan1"] = "我所有的努力，都是为了杀你！",
  ["$jieyuan2"] = "我必须活下去！",
  ["$fenxin1"] = "主上，这是最后的机会……",
  ["$fenxin2"] = "杀人，诛心。",
  ["~lingju"] = "主上，对不起……",
}

local fuwan = General(extension, "fuwan", "qun", 4)
local moukui = fk.CreateTriggerSkill{
  name = "moukui",
  anim_type = "offensive",
  events = {fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.trueName == "slash"
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(data.to)
    local choices = {"Cancel", "draw1"}
    if not to:isNude() then
      table.insert(choices, "moukui_discard::" .. to.id)
    end
    local choice = room:askForChoice(player, choices, self.name, "#moukui-invoke::"..data.to)
    if choice ~= "Cancel" then
      self.cost_data = choice
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(data.to)
    if self.cost_data == "draw1" then
      player:drawCards(1, self.name)
    else
      local id = room:askForCardChosen(player, to, "he", self.name)
      room:throwCard({id}, self.name, to, player)
    end
    data.extra_data = data.extra_data or {}
    data.extra_data.moukui = data.extra_data.moukui or {}
    table.insert(data.extra_data.moukui, data.to)
  end,
}
local moukui_delay = fk.CreateTriggerSkill{
  name = "#moukui_delay",
  mute = true,
  events = {fk.CardEffectCancelledOut},
  can_trigger = function(self, event, target, player, data)
    if target == player and data.card.trueName == "slash" and not player.dead then
      local e = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard, true)
      if e then
        local use = e.data[1]
        if use.extra_data and use.extra_data.moukui and table.contains(use.extra_data.moukui, data.to) and
          not player.room:getPlayerById(data.to).dead then
          return true
        end
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("moukui")
    room:notifySkillInvoked(player, "moukui", "negative")
    local to = room:getPlayerById(data.to)
    room:doIndicate(data.to, {player.id})
    if player:isNude() then return end
    local id = room:askForCardChosen(to, player, "he", "moukui")
    room:throwCard(id, "moukui", player, to)
  end,
}
moukui:addRelatedSkill(moukui_delay)
fuwan:addSkill(moukui)
Fk:loadTranslationTable{
  ["fuwan"] = "伏完",
  ["#fuwan"] = "沉毅的国丈",
  ["illustrator:fuwan"] = "LiuHeng",
  ["moukui"] = "谋溃",
  [":moukui"] = "当你使用【杀】指定一名角色为目标后，你可以选择一项：摸一张牌，或弃置其一张牌。若如此做，此【杀】被【闪】抵消时，该角色弃置你的一张牌。",
  ["#moukui-invoke"] = "谋溃：你可以发动“谋溃”，对 %dest 执行一项",
  ["moukui_discard"] = "弃置%dest一张牌",
  ["#moukui_delay"] = "谋溃",

  ["$moukui1"] = "你的死期到了。",
  ["$moukui2"] = "同归于尽吧！",
  ["~fuwan"] = "后会有期……",
}

local xiahouba = General(extension, "xiahouba", "shu", 4)
local function BaobianChange(player, hp, skill_name)
  local room = player.room
  local skills = player.tag["baobian"]
  if type(skills) ~= "table" then skills = {} end
  if player.hp <= hp then
    if not table.contains(skills, skill_name) then
      player:broadcastSkillInvoke("baobian")
      room:handleAddLoseSkills(player, skill_name, "baobian")
      table.insert(skills, skill_name)
    end
  else
    if table.contains(skills, skill_name) then
      room:handleAddLoseSkills(player, "-"..skill_name, nil)
      table.removeOne(skills, skill_name)
    end
  end
  player.tag["baobian"] = skills
end
local baobian = fk.CreateTriggerSkill{
  name = "baobian",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.HpChanged, fk.MaxHpChanged},
  on_use = function(self, event, target, player, data)
    BaobianChange(player, 1, "ol_ex__shensu")
    BaobianChange(player, 2, "ex__paoxiao")
    BaobianChange(player, 3, "ol_ex__tiaoxin")
  end,
}
xiahouba:addSkill(baobian)
xiahouba:addRelatedSkill("ol_ex__tiaoxin")
xiahouba:addRelatedSkill("ex__paoxiao")
xiahouba:addRelatedSkill("ol_ex__shensu")
Fk:loadTranslationTable{
  ["xiahouba"] = "夏侯霸",
  ["#xiahouba"] = "棘途壮志",
  ["illustrator:xiahouba"] = "熊猫探员",
  ["baobian"] = "豹变",
  [":baobian"] = "锁定技，若你的体力值为3或更少，你视为拥有技能〖挑衅〗；若你的体力值为2或更少，你视为拥有技能〖咆哮〗；"..
  "若你的体力值为1，你视为拥有技能〖神速〗。",

  ["$baobian1"] = "变可生，不变则死。",
  ["$baobian2"] = "适时而动，穷极则变。",
  ["$ol_ex__tiaoxin_xiahouba1"] = "跪下受降，饶你不死！",
  ["$ol_ex__tiaoxin_xiahouba2"] = "黄口小儿，可听过将军名号？",
  ["$ex__paoxiao_xiahouba1"] = "喝！",
  ["$ex__paoxiao_xiahouba2"] = "受死吧！",
  ["$ol_ex__shensu_xiahouba1"] = "冲杀敌阵，来去如电！",
  ["$ol_ex__shensu_xiahouba2"] = "今日有恙在身，须得速战速决！",
  ["~xiahouba"] = "弃魏投蜀，死而无憾。",
}

local chenlin = General(extension, "chenlin", "wei", 3)
local bifa = fk.CreateTriggerSkill{
  name = "bifa",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish and not player:isKongcheng() and
      table.find(player.room:getOtherPlayers(player, false), function(p) return #p:getPile("$bifa") == 0 end)
  end,
  on_cost = function(self, event, target, player, data)
    local targets = table.map(table.filter(player.room:getOtherPlayers(player, false), function(p)
      return #p:getPile("$bifa") == 0 end), Util.IdMapper)
    local tos, id = player.room:askForChooseCardAndPlayers(player, targets, 1, 1, ".|.|.|hand", "#bifa-cost", self.name, true)
    if #tos > 0 then
      self.cost_data = {tos = tos, cards = {id}}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data.tos[1])
    room:setPlayerMark(player, "bifa_to", to.id)
    to:addToPile("$bifa", self.cost_data.cards, false, self.name, player.id, {})
  end,
}

local bifa_visible=fk.CreateVisibilitySkill{
  name = '#bifa_visible',
  card_visible = function(self, player, card)
    if player:getPileNameOfId(card.id) == "$bifa" then
      return false
    end
  end
}
bifa:addRelatedSkill(bifa_visible)

local bifa_trigger = fk.CreateTriggerSkill{
  name = "#bifa_trigger",
  mute = true,
  events = {fk.TurnStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and #player:getPile("$bifa") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local src = table.find(room.alive_players, function (p)
      return p:getMark("bifa_to") == player.id
    end)
    if src == nil or player:isKongcheng() then
      room:loseHp(player, 1, "bifa")
      room:moveCards({
        from = player.id,
        ids = player:getPile("$bifa"),
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonPutIntoDiscardPile,
        skillName = "bifa",
      })
      return
    end
    src:broadcastSkillInvoke("bifa")
    room:notifySkillInvoked(src, "bifa", "control")
    room:doIndicate(src.id, {player.id})
    room:setPlayerMark(src, "bifa_to", 0)
    local card = Fk:getCardById(player:getPile("$bifa")[1])
    local type = card:getTypeString()
    local give = room:askForCard(player, 1, 1, false, "bifa", true, ".|.|.|hand|.|"..type,
    "#bifa-invoke:"..src.id.."::"..type..":"..card:toLogString())
    if #give > 0 then
      room:moveCardTo(give, Card.PlayerHand, src, fk.ReasonGive, "bifa", nil, false, player.id)
      if not player.dead and #player:getPile("$bifa") > 0 then
        room:moveCardTo(player:getPile("$bifa"), Card.PlayerHand, player, fk.ReasonPrey, "bifa", nil, false, player.id)
      end
    else
      room:moveCards({
        from = player.id,
        ids = player:getPile("$bifa"),
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonPutIntoDiscardPile,
        skillName = "bifa",
      })
      if not player.dead then
        room:loseHp(player, 1, "bifa")
      end
    end
  end,
}
local songci = fk.CreateActiveSkill{
  name = "songci",
  anim_type = "control",
  mute = true,
  card_num = 0,
  target_num = 1,
  prompt = "#songci",
  can_use = Util.TrueFunc,
  card_filter = Util.FalseFunc,
  target_tip = function (self, to_select, selected, selected_cards, card, selectable, extra_data)
    local target = Fk:currentRoom():getPlayerById(to_select)
    if table.contains(Self:getTableMark(self.name), to_select) then
      return nil
    elseif target:getHandcardNum() < target.hp then
      return { {content = "draw" , type = "normal"} }
    elseif target:getHandcardNum() > target.hp then
      return { {content = "discard", type = "warning"} }
    end
  end,
  target_filter = function(self, to_select, selected)
    local target = Fk:currentRoom():getPlayerById(to_select)
    return #selected == 0 and not table.contains(Self:getTableMark(self.name), to_select) and target:getHandcardNum() ~= target.hp
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:addTableMark(player, self.name, target.id)
    if target:getHandcardNum() < target.hp then
      player:broadcastSkillInvoke(self.name, 1)
      target:drawCards(2, self.name)
    else
      player:broadcastSkillInvoke(self.name, 2)
      room:askForDiscard(target, 2, 2, true, self.name, false)
    end
  end,
}
bifa:addRelatedSkill(bifa_trigger)
chenlin:addSkill(bifa)
chenlin:addSkill(songci)
Fk:loadTranslationTable{
  ["chenlin"] = "陈琳",
  ["#chenlin"] = "破竹之咒",
  ["designer:chenlin"] = "韩旭",
  ["illustrator:chenlin"] = "木美人",
  ["bifa"] = "笔伐",
  [":bifa"] = "结束阶段开始时，你可以将一张手牌移出游戏并指定一名其他角色。该角色的回合开始时，其观看你移出游戏的牌并选择一项："..
  "交给你一张与此牌同类型的手牌并获得此牌；或将此牌置入弃牌堆，然后失去1点体力。",
  ["songci"] = "颂词",
  [":songci"] = "出牌阶段，你可以选择一项：令一名手牌数小于其体力值的角色摸两张牌；或令一名手牌数大于其体力值的角色弃置两张牌。此技能对每名角色只能用一次。",
  ["#bifa-cost"] = "笔伐：将一张手牌移出游戏并指定一名其他角色",
  ["#bifa-invoke"] = "笔伐：交给 %src 一张 %arg 并获得%arg2；或点“取消”将此牌置入弃牌堆并失去1点体力",
  ["$bifa"] = "笔伐",
  ["#songci"] = "颂词：令一名手牌数小于体力值的角色摸两张牌，或令一名手牌数大于体力值的角色弃两张牌",

  ["$bifa1"] = "笔墨纸砚，皆兵器也！",
  ["$bifa2"] = "汝德行败坏，人所不齿也！",
  ["$songci1"] = "将军德才兼备，大汉之栋梁也！",
  ["$songci2"] = "汝窃国奸贼，人人得而诛之！",
  ["~chenlin"] = "来人……我的笔呢……",
}

local daqiaoxiaoqiao = General(extension, "daqiaoxiaoqiao", "wu", 3, 3, General.Female)
local xingwu = fk.CreateTriggerSkill{
  name = "xingwu",
  anim_type = "offensive",
  derived_piles = "xingwu",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Discard and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local colors = player:getMark("xingwu-turn")
    if type(colors) ~= "table" then
      colors = {}
    end
    local pattern = "."
    if #colors == 2 then
      return
    elseif #colors == 1 then
      if colors[1] == Card.Black then
        pattern = ".|.|heart,diamond"
      else
        pattern = ".|.|spade,club"
      end
    end
    local card = player.room:askForCard(player, 1, 1, false, self.name, true, pattern, "#xingwu-cost")
    if #card > 0 then
      self.cost_data = card
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:addToPile(self.name, self.cost_data, true, self.name)
    if #player:getPile(self.name) >= 3 then
      room:moveCards({
        from = player.id,
        ids = player:getPile(self.name),
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonPutIntoDiscardPile,
        skillName = self.name,
      })
      local targets = table.filter(room:getOtherPlayers(player), function(p)
        return p:isMale()
      end)
      if #targets > 0 then
        local to = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1, "#xingwu-choose", self.name, false)
        local victim = room:getPlayerById(to[1])
        room:damage{
          from = player,
          to = victim,
          damage = 2,
          skillName = self.name,
        }
        victim:throwAllCards("e")
      end
    end
  end,

  refresh_events = {fk.CardUsing},
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(self, true) and target == player and player.phase ~= Player.NotActive
  end,
  on_refresh = function(self, event, target, player, data)
    local colors = player:getMark("xingwu-turn")
    if type(colors) ~= "table" then
      colors = {}
    end
    if data.card.color ~= Card.NoColor then
      table.insertIfNeed(colors, data.card.color)
    end
    player.room:setPlayerMark(player, "xingwu-turn", colors)
  end,
}
local luoyan = fk.CreateTriggerSkill{
  name = "luoyan",
  anim_type = "special",
  frequency = Skill.Compulsory,

  refresh_events = {fk.AfterCardsMove},
  can_refresh = function(self, event, target, player, data)
    if player:hasSkill(self, true) and player.phase == Player.Discard then
      for _, move in ipairs(data) do
        if move.skillName == "xingwu" then
          return true
        end
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if #player:getPile("xingwu") == 0 and (player:hasSkill("tianxiang", true) or player:hasSkill("liuli", true)) then
      room:handleAddLoseSkills(player, "-tianxiang|-liuli", nil, true, false)
    end
    if #player:getPile("xingwu") > 0 and not (player:hasSkill("tianxiang", true) and player:hasSkill("liuli", true)) then
      room:handleAddLoseSkills(player, "tianxiang|liuli", nil, true, false)
    end
  end,
}
daqiaoxiaoqiao:addSkill(xingwu)
daqiaoxiaoqiao:addSkill(luoyan)
daqiaoxiaoqiao:addRelatedSkill("tianxiang")
daqiaoxiaoqiao:addRelatedSkill("liuli")
Fk:loadTranslationTable{
  ["daqiaoxiaoqiao"] = "大乔小乔",
  ["#daqiaoxiaoqiao"] = "江东之花",
  ["designer:daqiaoxiaoqiao"] = "韩旭",
  ["illustrator:daqiaoxiaoqiao"] = "木美人",

  ["xingwu"] = "星舞",
  [":xingwu"] = "弃牌阶段开始时，你可以将一张与你本回合使用的牌颜色均不同的手牌置于武将牌上。"..
  "若此时你武将牌上的牌达到三张，则弃置这些牌，然后对一名男性角色造成2点伤害并弃置其装备区中的所有牌。",
  ["luoyan"] = "落雁",
  [":luoyan"] = "锁定技，若你的武将牌上有牌，你视为拥有技能〖天香〗和〖流离〗。",
  ["#xingwu-cost"] = "星舞：你可以将一张与你本回合使用的牌颜色均不同的手牌置为“星舞”牌",
  ["#xingwu-choose"] = "星舞：对一名男性角色造成2点伤害并弃置其装备区所有牌",

  ["$xingwu1"] = "哼，不要小瞧女孩子哦！",
  ["$xingwu2"] = "姐妹齐心，其利断金。",
  ["$tianxiang_daqiaoxiaoqiao1"] = "替我挡着吧~",
  ["$tianxiang_daqiaoxiaoqiao2"] = "哼！我才不怕你呢~",
  ["$liuli_daqiaoxiaoqiao1"] = "呵呵，交给你啦~",
  ["$liuli_daqiaoxiaoqiao2"] = "不懂得怜香惜玉么~",
  ["~daqiaoxiaoqiao"] = "伯符，公瑾，请一定要守护住我们的江东啊！",
}

local xiahoushi = General(extension, "sp__xiahoushi", "shu", 3, 3, General.Female)
local sp__yanyu = fk.CreateTriggerSkill{
  name = "sp__yanyu",
  anim_type = "support",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target.phase == Player.Play and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askForDiscard(player, 1, 1, true, self.name, true, ".", "#yanyu-cost", true)
    if #card > 0 then
      self.cost_data = card
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card_type = Fk:getCardById(self.cost_data[1]):getTypeString()
    room:throwCard(self.cost_data, self.name, player, player)
    local x = 3 - player:usedSkillTimes("#yanyu_delay", Player.HistoryTurn)
    if not player.dead and x > 0 then
      room:setPlayerMark(player, "@yanyu-phase", {card_type, x})
    end
  end,
}
local yanyu_active = fk.CreateActiveSkill{
  name = "yanyu_active",
  expand_pile = function(self)
    return Self:getTableMark("yanyu_cards")
  end,
  card_num = 1,
  target_num = 1,
  card_filter = function(self, to_select, selected, targets)
    return #selected == 0 and table.contains(Self:getTableMark("yanyu_cards"), to_select)
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0
  end,
}
Fk:addSkill(yanyu_active)
local yanyu_delay = fk.CreateTriggerSkill{
  name = "#yanyu_delay",
  anim_type = "support",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player.dead or player:usedSkillTimes(self.name, Player.HistoryTurn) > 2 then return false end
    local mark = player:getMark("@yanyu-phase")
    if type(mark) == "table" and #mark == 2 then
      local type_name = mark[1]
      local ids = {}
      local id = -1
      local room = player.room
      for _, move in ipairs(data) do
        if move.toArea == Card.DiscardPile then
          for _, info in ipairs(move.moveInfo) do
            id = info.cardId
            if Fk:getCardById(id):getTypeString() == type_name and room:getCardArea(id) == Card.DiscardPile then
              table.insertIfNeed(ids, id)
            end
          end
        end
      end
      ids = U.moveCardsHoldingAreaCheck(room, ids)
      if #ids > 0 then
        self.cost_data = ids
        return true
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    local room = player.room
    local ids = table.simpleClone(self.cost_data)
    while true do
      self.cancel_cost = false
      self:doCost(event, nil, player, ids)
      if self.cancel_cost then
        self.cancel_cost = false
        break
      end
      if player.dead or player:usedSkillTimes(self.name, Player.HistoryTurn) > 2 then break end
      ids = U.moveCardsHoldingAreaCheck(room, ids)
      if #ids == 0 then break end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "yanyu_cards", data)
    local _, ret = room:askForUseActiveSkill(player, "yanyu_active", "#yanyu-choose", true, nil, true)
    room:setPlayerMark(player, "yanyu_cards", 0)
    if ret then
      self.cost_data = {ret.targets[1], ret.cards[1]}
      return true
    end
    self.cancel_cost = true
  end,
  on_use = function(self, event, target, player, data)
    player:broadcastSkillInvoke("sp__yanyu")
    local mark = player:getMark("@yanyu-phase")
    if type(mark) == "table" or #mark == 2 then
      local x = 3 - player:usedSkillTimes(self.name, Player.HistoryTurn)
      player.room:setPlayerMark(player, "@yanyu-phase", x > 0 and {mark[1], x} or 0)
    end
    player.room:obtainCard(self.cost_data[1], self.cost_data[2], true, fk.ReasonGive)
  end,
}
local xiaode = fk.CreateTriggerSkill{
  name = "xiaode",
  anim_type = "special",
  events = {fk.Deathed},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self)
  end,
  on_cost = function(self, event, target, player, data)
    self.cost_data = {}
    local skills = Fk.generals[target.general]:getSkillNameList()
    if target.deputyGeneral ~= "" then table.insertTable(skills, Fk.generals[target.deputyGeneral]:getSkillNameList()) end
    for _, skill_name in ipairs(skills) do
      local skill = Fk.skills[skill_name]
      if skill.frequency ~= Skill.Wake and not player:hasSkill(skill, true) and
        not skill.lordSkill and not skill_name:endsWith("&") then
        table.insertIfNeed(self.cost_data, skill_name)
      end
    end
    return #self.cost_data > 0 and player.room:askForSkillInvoke(player, self.name, nil, "#xiaode-invoke::"..target.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = room:askForChoice(player, self.cost_data, self.name, "#xiaode-choice::"..target.id, true)
    room:handleAddLoseSkills(player, choice.."|-xiaode", nil, true, true)
    local mark = player:getMark(self.name)
    if mark == 0 then mark = {} end
    table.insertIfNeed(mark, choice)
    room:setPlayerMark(player, self.name, mark)
  end,

  refresh_events = {fk.TurnEnd},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark(self.name) ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local names = self.name
    for _, skill in ipairs(player:getMark(self.name)) do
      if player:hasSkill(skill, true) then
        names = names.."|-"..skill
      end
    end
    room:handleAddLoseSkills(player, names, nil, true, false)
  end,
}
sp__yanyu:addRelatedSkill(yanyu_delay)
xiahoushi:addSkill(sp__yanyu)
xiahoushi:addSkill(xiaode)
Fk:loadTranslationTable{
  ["sp__xiahoushi"] = "夏侯氏",
  ["#sp__xiahoushi"] = "疾冲之恋",
  ["illustrator:sp__xiahoushi"] = "牧童的短笛",
  ["designer:sp__xiahoushi"] = "桃花僧",
  ["cv:sp__xiahoushi"] = "橘枍shii吖（新月杀原创）",

  ["sp__yanyu"] = "燕语",
  [":sp__yanyu"] = "任意一名角色的出牌阶段开始时，你可以弃置一张牌，若如此做，则本回合的出牌阶段，当有与你弃置牌类别相同的其他牌进入弃牌堆时，"..
  "你可令任意一名角色获得此牌。每回合以此法获得的牌不能超过三张。",
  ["xiaode"] = "孝德",
  [":xiaode"] = "当有其他角色阵亡后，你可以声明该武将牌的一项技能，若如此做，你获得此技能并失去技能〖孝德〗直到你的回合结束。（你不能声明觉醒技或主公技）",
  ["@yanyu-phase"] = "燕语",
  ["#yanyu_delay"] = "燕语",
  ["#yanyu-cost"] = "燕语：你可以弃置一张牌，然后此出牌阶段限三次，可令任意角色获得相同类别进入弃牌堆的牌",
  ["yanyu_active"] = "燕语",
  ["#yanyu-choose"] = "燕语：令一名角色获得弃置的牌",
  ["#xiaode-invoke"] = "孝德：你可以获得 %dest 武将牌上的一个技能直到你的回合结束",
  ["#xiaode-choice"] = "孝德：选择要获得 %dest 的技能",

  -- CV: @橘枍shii吖
  ["$sp__yanyu1"] = "燕燕于飞，颉之颃之。",
  ["$sp__yanyu2"] = "终温且惠，淑慎其身。",
  ["$xiaode"] = "有孝有德，以引为翼。",
  ["~sp__xiahoushi"] = "燕语叮嘱，愿君安康。",
}

local yuejin = General(extension, "yuejin", "wei", 4)
local xiaoguo = fk.CreateTriggerSkill{
  name = "xiaoguo",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(self) and target.phase == Player.Finish and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askForDiscard(player, 1, 1, false, self.name, true, ".|.|.|.|.|basic",
      "#xiaoguo-invoke::"..target.id, true)
    if #card > 0 then
      self.cost_data = card
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    room:throwCard(self.cost_data, self.name, player, player)
    if target.dead then return end
    if #room:askForDiscard(target, 1, 1, true, self.name, true, ".|.|.|.|.|equip", "#xiaoguo-discard:"..player.id) > 0 then
      if not player.dead then
        player:drawCards(1, self.name)
      end
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
  ["#yuejin"] = "奋强突固",
  ["illustrator:yuejin"] = "巴萨小马",
  ["xiaoguo"] = "骁果",
  [":xiaoguo"] = "其他角色的结束阶段开始时，你可以弃置一张基本牌。若如此做，该角色需弃置一张装备牌并令你摸一张牌，否则受到你对其造成的1点伤害。",
  ["#xiaoguo-invoke"] = "骁果：你可以弃置一张基本牌，%dest 需弃置一张装备牌并令你摸一张牌，否则你对其造成1点伤害",
  ["#xiaoguo-discard"] = "骁果：你需弃置一张装备牌并令 %src 摸一张牌，否则其对你造成1点伤害",

  ["$xiaoguo1"] = "三军听我号令，不得撤退！",
  ["$xiaoguo2"] = "看我先登城头，立下首功！",
  ["~yuejin"] = "箭疮发作，吾命休矣。",
}

local zhangbao = General(extension, "zhangbao", "qun", 3)
local zhoufu = fk.CreateActiveSkill{
  name = "zhoufu",
  anim_type = "control",
  card_num = 1,
  target_num = 1,
  prompt = "#zhoufu",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name) == 0 and not player:isKongcheng()
  end,
  card_filter = function(self, to_select, selected, targets)
    return #selected == 0 and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
  end,
  target_filter = function(self, to_select, selected, cards)
    return #selected == 0 and to_select ~= Self.id and #Fk:currentRoom():getPlayerById(to_select):getPile("$zhangbao_zhou") == 0
  end,
  on_use = function(self, room, effect)
    local target = room:getPlayerById(effect.tos[1])
    target:addToPile("$zhangbao_zhou", effect.cards, false, self.name)
  end,
}
local zhoufu_trigger = fk.CreateTriggerSkill{
  name = "#zhoufu_trigger",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return #target:getPile("$zhangbao_zhou") > 0 and player:hasSkill(self) and target.phase == Player.NotActive
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:moveCards({
      from = target.id,
      ids = target:getPile("$zhangbao_zhou"),
      to = player.id,
      toArea = Card.PlayerHand,
      moveReason = fk.ReasonJustMove,
      skillName = "zhoufu",
    })
  end,

  refresh_events = {fk.StartJudge},
  can_refresh = function(self, event, target, player, data)
    return #target:getPile("$zhangbao_zhou") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    data.card = Fk:getCardById(target:getPile("$zhangbao_zhou")[1])
    data.card.skillName = "zhoufu"
  end,
}
local yingbing = fk.CreateTriggerSkill{
  name = "yingbing",
  anim_type = "drawcard",
  events = {fk.AskForRetrial},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and data.card.skillName == "zhoufu"
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(2, self.name)
  end,
}
zhoufu:addRelatedSkill(zhoufu_trigger)
zhangbao:addSkill(zhoufu)
zhangbao:addSkill(yingbing)
Fk:loadTranslationTable{
  ["zhangbao"] = "张宝",
  ["#zhangbao"] = "地公将军",
  ["designer:zhangbao"] = "韩旭",
  ["illustrator:zhangbao"] = "大佬荣",

  ["zhoufu"] = "咒缚",
  [":zhoufu"] = "出牌阶段限一次，你可以指定一名其他角色并将一张手牌移出游戏（将此牌置于该角色的武将牌旁），"..
  "若如此做，该角色进行判定时，改为将此牌作为判定牌。该角色的回合结束时，若此牌仍在该角色旁，你将此牌收入手牌。",
  ["yingbing"] = "影兵",
  [":yingbing"] = "受到“咒缚”技能影响的角色进行判定时，你可以摸两张牌。",
  ["$zhangbao_zhou"] = "咒",
  ["#zhoufu_trigger"] = "咒缚",
  ["#zhoufu"] = "咒缚：将一张手牌置为一名角色的“咒缚”牌，其判定时改为将“咒缚”牌作为判定牌",

  ["$zhoufu1"] = "违吾咒者，倾死灭亡。",
  ["$zhoufu2"] = "咒宝符命，速显威灵。",
  ["$yingbing1"] = "朱雀玄武，誓为我征。",
  ["$yingbing2"] = "所呼立至，所召立前。",
  ["~zhangbao"] = "黄天……为何？！",
}

local caoang = General(extension, "caoang", "wei", 4)
local kangkai = fk.CreateTriggerSkill{
  name = "kangkai",
  anim_type = "support",
  events = {fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and data.card.trueName == "slash" and (target == player or player:distanceTo(target) == 1)
  end,
  on_cost = function (self, event, target, player, data)
    local prompt = (player.id == data.to) and "#kangkai-self" or "#kangkai-invoke::"..data.to
    return player.room:askForSkillInvoke(player, self.name, nil, prompt)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(data.to)
    player:drawCards(1, self.name)
    if player == to or player:isNude() or to.dead then return end
    local cards = room:askForCard(player, 1, 1, true, self.name, false, ".", "#kangkai-give::"..to.id)
    if #cards > 0 then
      room:moveCardTo(cards, Card.PlayerHand, to, fk.ReasonGive, self.name, nil, true, player.id)
      to:showCards(cards)
      local card = Fk:getCardById(cards[1])
      if card.type == Card.TypeEquip and not to.dead and not to:isProhibited(to, card) and not to:prohibitUse(card) and
        table.contains(to:getCardIds("h"), cards[1]) and
        room:askForSkillInvoke(to, self.name, data, "#kangkai-use:::"..card:toLogString()) then
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
  ["#caoang"] = "取义成仁",
  ["designer:caoang"] = "韩旭",
  ["illustrator:caoang"] = "Zero",

  ["kangkai"] = "慷忾",
  [":kangkai"] = "当一名角色成为【杀】的目标后，若你与其的距离不大于1，你可以摸一张牌，若如此做，你先将一张牌交给该角色再令其展示之，"..
  "若此牌为装备牌，其可以使用之。",
  ["#kangkai-invoke"] = "慷忾：你可以摸一张牌，再交给 %dest 一张牌",
  ["#kangkai-self"] = "慷忾：你可以摸一张牌",
  ["#kangkai-give"] = "慷忾：选择一张牌交给 %dest",
  ["#kangkai-use"] = "慷忾：你可以使用%arg",

  ["$kangkai1"] = "典将军，比比看谁杀敌更多！",
  ["$kangkai2"] = "父亲快走，有我殿后！",
  ["~caoang"] = "典将军，还是你赢了……",
}

local zhugejin = General(extension, "zhugejin", "wu", 3)
local huanshi = fk.CreateTriggerSkill{
  name = "huanshi",
  anim_type = "support",
  events = {fk.AskForRetrial},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askForSkillInvoke(player,self.name, nil, "#huanshi-invoke::"..target.id) then
      player.room:doIndicate(player.id, {target.id})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local handcards = player:getCardIds(Player.Hand)
    local equips = player:getCardIds(Player.Equip)
    local card_data = {}
    if #handcards > 0 then
      table.insert(card_data, { "$Hand", handcards })
    end
    if #equips > 0 then
      table.insert(card_data, { "$Equip", equips })
    end
    local id = room:askForCardChosen(target, player, { card_data = card_data }, self.name)
    local card = Fk:getCardById(id)
    if not player:prohibitResponse(card) then
      room:retrial(card, player, data, self.name)
    end
  end,
}
local hongyuan = fk.CreateTriggerSkill{
  name = "hongyuan",
  anim_type = "support",
  events = {fk.DrawNCards},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.n > 0
  end,
  on_cost = function(self, event, target, player, data)
    local tos = player.room:askForChoosePlayers(player, table.map(player.room:getOtherPlayers(player, false), Util.IdMapper),
    1, 2, "#hongyuan-cost", self.name, true)
    if #tos > 0 then
      self.cost_data = tos
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    data.n = data.n - 1
    player.room:setPlayerMark(player, "hongyuan_targets-phase", self.cost_data)
  end,
}
local hongyuan_delay = fk.CreateTriggerSkill{
  name = "#hongyuan_delay",
  anim_type = "support",
  events = {fk.EventPhaseEnd},
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return not player.dead and type(player:getMark("hongyuan_targets-phase")) == "table"
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local tos = player:getMark("hongyuan_targets-phase")
    for _, id in ipairs(tos) do
      local p = room:getPlayerById(id)
      if not p.dead then
        room:drawCards(p, 1, hongyuan.name)
      end
    end
  end,
}
local mingzhe = fk.CreateTriggerSkill{
  name = "mingzhe",
  anim_type = "drawcard",
  events = {fk.CardUsing, fk.CardResponding, fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and player.phase == Player.NotActive then
      if event == fk.AfterCardsMove then
        for _, move in ipairs(data) do
        if move.from == player.id and move.moveReason == fk.ReasonDiscard then
          for _, info in ipairs(move.moveInfo) do
            if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
            Fk:getCardById(info.cardId).color == Card.Red then
              return true
            end
          end
        end
      end
      else
        return player == target and data.card.color == Card.Red
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    local x = 1
    if event == fk.AfterCardsMove then
      x = 0
      for _, move in ipairs(data) do
        if move.from == player.id and move.moveReason == fk.ReasonDiscard then
          for _, info in ipairs(move.moveInfo) do
            if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
            Fk:getCardById(info.cardId).color == Card.Red then
              x = x + 1
            end
          end
        end
      end
    end
    local ret
    for _ = 1, x do
      if self.cancel_cost or not player:hasSkill(self) then
        self.cancel_cost = false
        break
      end
      ret = self:doCost(event, target, player, data)
      if ret then return ret end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askForSkillInvoke(player, self.name, data) then
      return true
    end
    self.cancel_cost = true
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
}
hongyuan:addRelatedSkill(hongyuan_delay)
zhugejin:addSkill(huanshi)
zhugejin:addSkill(hongyuan)
zhugejin:addSkill(mingzhe)
Fk:loadTranslationTable{
  ["zhugejin"] = "诸葛瑾",
  ["#zhugejin"] = "联盟的维系者",
  ["designer:zhugejin"] = "韩旭",
  ["illustrator:zhugejin"] = "G.G.G.",
  ["huanshi"] = "缓释",
  [":huanshi"] = "当一名角色的判定牌生效前，你可以令该角色观看你的手牌并选择你的一张牌，你打出此牌代替之。",
  ["hongyuan"] = "弘援",
  [":hongyuan"] = "摸牌阶段，你可以少摸一张牌，令至多两名其他角色各摸一张牌。",
  ["mingzhe"] = "明哲",
  [":mingzhe"] = "当你于回合外使用、打出或因弃置而失去一张红色牌时，你可以摸一张牌。",
  ["#huanshi-invoke"] = "缓释：你可以令 %dest 观看你的手牌并打出其中一张牌修改其判定",
  ["#hongyuan-cost"] = "弘援：你可以少摸一张牌，令至多两名其他角色各摸一张牌",
  ["#hongyuan_delay"] = "弘援",

  ["$huanshi1"] = "缓乐之危急，释兵之困顿。",
  ["$huanshi2"] = "尽死生之力，保友邦之安。",
  ["$hongyuan1"] = "诸将莫慌，粮草已到。",
  ["$hongyuan2"] = "自舍其身，施于天下。",
  ["$mingzhe1"] = "明以洞察，哲以保身。",
  ["$mingzhe2"] = "塞翁失马，焉知非福？",
  ["~zhugejin"] = "君臣不相负，来世复君臣。",
}

local xingcai = General(extension, "xingcai", "shu", 3, 3, General.Female)
local shenxian = fk.CreateTriggerSkill{
  name = "shenxian",
  anim_type = "drawcard",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and player.phase == Player.NotActive then
      for _, move in ipairs(data) do
        if move.toArea == Card.DiscardPile and move.moveReason == fk.ReasonDiscard and move.from ~= player.id then
          for _, info in ipairs(move.moveInfo) do
            if Fk:getCardById(info.cardId).type == Card.TypeBasic then
              return true
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
}
local qiangwu = fk.CreateActiveSkill{
  name = "qiangwu",
  anim_type = "offensive",
  card_num = 0,
  target_num = 0,
  prompt = "#qiangwu",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local judge = {
      who = player,
      reason = self.name,
      pattern = ".",
    }
    room:judge(judge)
    room:setPlayerMark(player, "@qiangwu-turn", judge.card.number)
  end,
}
local qiangwu_record = fk.CreateTriggerSkill{
  name = "#qiangwu_record",
  anim_type = "offensive",

  refresh_events = {fk.AfterCardUseDeclared},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:getMark("@qiangwu-turn") > 0 and
      data.card.trueName == "slash" and data.card.number and data.card.number > player:getMark("@qiangwu-turn") and
      not data.extraUse
  end,
  on_refresh = function(self, event, target, player, data)
    data.extraUse = true
    player:addCardUseHistory(data.card.trueName, -1)
  end,
}
local qiangwu_targetmod = fk.CreateTargetModSkill{
  name = "#qiangwu_targetmod",
  distance_limit_func = function(self, player, skill, card)
    if skill.trueName == "slash_skill" and player:getMark("@qiangwu-turn") ~= 0 and card.number < player:getMark("@qiangwu-turn") then
      return 999
    end
    return 0
  end,
}
qiangwu:addRelatedSkill(qiangwu_record)
qiangwu:addRelatedSkill(qiangwu_targetmod)
xingcai:addSkill(shenxian)
xingcai:addSkill(qiangwu)
Fk:loadTranslationTable{
  ["xingcai"] = "星彩",
  ["#xingcai"] = "敬哀皇后",
  ["designer:xingcai"] = "韩旭",
  ["illustrator:xingcai"] = "depp",
  ["cv:xingcai"] = "shourei小N",

  ["shenxian"] = "甚贤",
  [":shenxian"] = "你的回合外，当有其他角色因弃置而失去牌时，若其中有基本牌，你可以摸一张牌。",
  ["qiangwu"] = "枪舞",
  [":qiangwu"] = "出牌阶段限一次，你可以进行一次判定，若如此做，则直到回合结束，你使用点数小于判定牌的【杀】时不受距离限制，且你使用点数大于判定牌的【杀】时不计入出牌阶段的使用次数。",
  ["@qiangwu-turn"] = "枪舞",
  ["#qiangwu"] = "枪舞：进行判定，根据点数本回合使用【杀】获得增益",

  ["$shenxian1"] = "愿尽己力，为君分忧。",
  ["$shenxian2"] = "抚慰军心，以安国事。",
  ["$qiangwu1"] = "父亲未尽之业，由我继续！",
  ["$qiangwu2"] = "咆哮沙场，万夫不敌！",
  ["~xingcai"] = "复兴汉室之路，臣妾再也不能陪伴左右了……",
}

local panfeng = General(extension, "panfeng", "qun", 4)
local kuangfu = fk.CreateTriggerSkill{
  name = "kuangfu",
  anim_type = "offensive",
  events = {fk.Damage},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card and data.card.trueName == "slash" and
      not data.chain and not data.to.dead and #data.to:getCardIds("e") > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choices = {"kuangfu_discard"}
    if data.to:canMoveCardsInBoardTo(player, "e") then
      table.insert(choices, 1, "kuangfu_move")
    end
    local choice = room:askForChoice(player, choices, self.name)
    if choice == "kuangfu_move" then
      room:askForMoveCardInBoard(player, data.to, player, self.name, "e", data.to)
    else
      local id = room:askForCardChosen(player, data.to, "e", self.name)
      room:throwCard({id}, self.name, data.to, player)
    end
  end
}
panfeng:addSkill(kuangfu)
Fk:loadTranslationTable{
  ["panfeng"] = "潘凤",
  ["#panfeng"] = "联军上将",
  ["illustrator:panfeng"] = "G.G.G.",
  ["kuangfu"] = "狂斧",
  [":kuangfu"] = "当你使用【杀】对目标角色造成一次伤害后，你可以选择一项: 将其装备区里的一张牌置入你的装备区；或弃置其装备区里的一张牌。",
  ["kuangfu_move"] = "将其一张装备置入你的装备区",
  ["kuangfu_discard"] = "弃置其一张装备",

  ["$kuangfu1"] = "吾乃上将潘凤，可斩华雄！",
  ["$kuangfu2"] = "这家伙，还是给我用吧！",
  ["~panfeng"] = "来者……可是魔将……",
}

local zumao = General(extension, "zumao", "wu", 4)
local yinbing = fk.CreateTriggerSkill{
  name = "yinbing",
  anim_type = "control",
  expand_pile = "yinbing",
  derived_piles = "$yinbing",
  events = {fk.EventPhaseStart, fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      if event == fk.EventPhaseStart then
        return target == player and player.phase == Player.Finish and not player:isNude()
      else
        return target == player and #player:getPile("$yinbing") > 0 and data.card and
          (data.card.trueName == "slash" or data.card.name == "duel")
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseStart then
      local cards = room:askForCard(player, 1, 999, true, self.name, true, ".|.|.|.|.|trick,equip", "#yinbing-cost")
      if #cards > 0 then
        self.cost_data = cards
        return true
      end
    else
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseStart then
      player:addToPile("$yinbing", self.cost_data, false, self.name)
    else
      local card = room:askForCard(player, 1, 1, false, self.name, false, ".|.|.|$yinbing", "#yingbing-remove", "$yinbing")
      room:moveCardTo(card, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, self.name, nil, true, player.id)
    end
  end,
}
local juedi = fk.CreateTriggerSkill{
  name = "juedi",
  anim_type = "support",
  events = {fk.EventPhaseStart},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start and #player:getPile("$yinbing") > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    for _, p in ipairs(room.alive_players) do
      if player.hp >= p.hp and player ~= p then
        table.insertIfNeed(targets, p.id)
      end
    end
    local tos = room:askForChoosePlayers(player, targets, 1, 1, "#juedi-choose", self.name, true, false)
    if #tos > 0 then
      local to = room:getPlayerById(tos[1])
      local x = #player:getPile("$yinbing")
      room:moveCardTo(player:getPile("$yinbing"), Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, self.name, nil, true, player.id)
      if not to.dead and to:isWounded() then
        room:recover({
          who = to,
          num = 1,
          recoverBy = player,
          skillName = self.name
        })
      end
      if not to.dead then
        room:drawCards(to, x, self.name)
      end
    else
      room:moveCardTo(player:getPile("$yinbing"), Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, self.name, nil, true, player.id)
      local x = player.maxHp - player:getHandcardNum()
      if x > 0 and not player.dead then
        room:drawCards(player, x, self.name)
      end
    end
  end,
}
zumao:addSkill(yinbing)
zumao:addSkill(juedi)
Fk:loadTranslationTable{
  ["zumao"] = "祖茂",
  ["#zumao"] = "碧血染赤帻",
  ["designer:zumao"] = "韩旭",
  ["illustrator:zumao"] = "DH",

  ["yinbing"] = "引兵",
  [":yinbing"] = "结束阶段，你可以将任意张非基本牌置于你的武将牌上，当你受到【杀】或【决斗】造成的伤害后，你移去你武将牌上的一张牌。",
  ["juedi"] = "绝地",
  [":juedi"] = "锁定技，准备阶段，你选择一项: 1.移去“引兵”牌，然后将手牌摸至体力上限；2.令体力值小于等于你的一名其他角色获得“引兵”牌，"..
  "然后回复1点体力并摸等量的牌。",
  ["#yinbing-cost"] = "引兵：你可以将任意张非基本牌置于你的武将牌上",
  ["$yinbing"] = "引兵",
  ["#yingbing-remove"] = "引兵：你需移去一张“引兵”牌",
  ["#juedi-choose"] = "绝地：令一名其他角色获得“引兵”牌然后回复1点体力并摸等量的牌，或点“取消”移去“引兵”牌令自己摸牌",

  ["$yinbing1"] = "追兵凶猛，末将断后！",
  ["$yinbing2"] = "将军走此小道，追兵交我应付！",
  ["$juedi1"] = "困兽之斗，以全忠义！",
  ["$juedi2"] = "提起武器，最后一搏！",
  ["~zumao"] = "孙将军，已经，安全了吧……",
}

local dingfeng = General(extension, "dingfeng", "wu", 4)
local duanbing = fk.CreateTriggerSkill{
  name = "duanbing",
  anim_type = "offensive",
  events = {fk.AfterCardTargetDeclared},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.trueName == "slash" and
      table.find(player.room:getUseExtraTargets(data), function(id)
        return player:distanceTo(player.room:getPlayerById(id)) == 1
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getUseExtraTargets(data), function(id)
      return player:distanceTo(room:getPlayerById(id)) == 1
    end)
    local tos = room:askForChoosePlayers(player, targets, 1, 1, "#duanbing-choose", self.name, true)
    if #tos > 0 then
      self.cost_data = tos[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    table.insert(data.tos, {self.cost_data})
  end,
}
dingfeng:addSkill(duanbing)
local fenxun = fk.CreateActiveSkill{
  name = "fenxun",
  anim_type = "offensive",
  card_num = 1,
  target_num = 1,
  prompt = "#fenxun",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isNude()
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and not Self:prohibitDiscard(Fk:getCardById(to_select))
  end,
  target_filter = function(self, to_select, selected, cards)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:addTableMark(player, "fenxun-turn", effect.tos[1])
    room:throwCard(effect.cards, self.name, player, player)
  end,
}
local fenxun_distance = fk.CreateDistanceSkill{
  name = "#fenxun_distance",
  fixed_func = function(self, from, to)
    if table.contains(from:getTableMark("fenxun-turn"), to.id) then
      return 1
    end
  end,
}
fenxun:addRelatedSkill(fenxun_distance)
dingfeng:addSkill(fenxun)
Fk:loadTranslationTable{
  ["dingfeng"] = "丁奉",
  ["#dingfeng"] = "清侧重臣",
  ["illustrator:dingfeng"] = "G.G.G.",
  ["duanbing"] = "短兵",
  [":duanbing"] = "你使用【杀】时可以额外选择一名距离为1的其他角色为目标。",
  ["fenxun"] = "奋迅",
  [":fenxun"] = "出牌阶段限一次，你可以弃置一张牌并选择一名其他角色，令你与其的距离视为1，直到回合结束。",
  ["#duanbing-choose"] = "短兵：你可以额外选择一名距离为1的其他角色为目标",
  ["#fenxun"] = "奋迅：弃一张牌，你与一名角色的距离视为1直到回合结束",

  ["~dingfeng"] = "这风，太冷了。",
}

local zhugedan = General(extension, "zhugedan", "wei", 4)
local gongao = fk.CreateTriggerSkill{
  name = "gongao",
  anim_type = "support",
  frequency = Skill.Compulsory,
  events = {fk.Deathed},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, 1)
    if not player.dead and player:isWounded() then
      room:recover({
        who = player,
        num = 1,
        recoverBy = player,
        skillName = self.name
      })
    end
  end,
}
local juyi = fk.CreateTriggerSkill{
  name = "juyi",
  frequency = Skill.Wake,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
     player.phase == Player.Start and
     player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player, data)
    return player:isWounded() and player.maxHp > #player.room.alive_players
  end,
  on_use = function(self, event, target, player, data)
    local n = player.maxHp - player:getHandcardNum()
    if n > 0 then
      player:drawCards(n, self.name)
    end
    player.room:handleAddLoseSkills(player, "benghuai|weizhong", nil)
  end,
}
local weizhong = fk.CreateTriggerSkill{
  name = "weizhong",
  frequency = Skill.Compulsory,
  events = {fk.MaxHpChanged},
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
}
zhugedan:addSkill(gongao)
zhugedan:addSkill(juyi)
zhugedan:addRelatedSkill("benghuai")
zhugedan:addRelatedSkill(weizhong)
Fk:loadTranslationTable{
  ["zhugedan"] = "诸葛诞",
  ["#zhugedan"] = "薤露蒿里",
  ["designer:zhugedan"] = "韩旭",
  ["illustrator:zhugedan"] = "雪君S",
  ["gongao"] = "功獒",
  [":gongao"] = "锁定技，当一名角色死亡后，你增加1点体力上限，回复1点体力。",
  ["juyi"] = "举义",
  [":juyi"] = "觉醒技，准备阶段开始时，若你已受伤且体力上限大于存活角色数，你须将手牌摸至体力上限，然后获得技能“崩坏”和“威重”。",
  ["weizhong"] = "威重",
  [":weizhong"] = "锁定技，当你的体力上限增加或减少时，你摸一张牌。",

  ["$gongao1"] = "攻城拔寨，建功立业。",
  ["$gongao2"] = "恪尽职守，忠心事主。",
  ["$juyi1"] = "司马氏篡权，我当替天伐之！",
  ["$juyi2"] = "若国有难，吾当举义。",
  ["$weizhong"] = "定当夷司马氏三族！",
  ["$benghuai_zhugedan"] = "咳……咳咳……",
  ["~zhugedan"] = "诸葛一氏定会为我复仇！",
}

local hetaihou = General(extension, "hetaihou", "qun", 3, 3, General.Female)
local zhendu = fk.CreateTriggerSkill{
  name = "zhendu",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target ~= player and target.phase == Player.Play and player:hasSkill(self) and not player:isKongcheng() and not target.dead
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askForDiscard(player, 1, 1, false, self.name, true, ".|.|.|hand", "#zhendu-invoke::"..target.id, true)
    if #card > 0 then
      self.cost_data = card
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    room:throwCard(self.cost_data, self.name, player, player)
    if not target.dead and target:canUseTo(Fk:cloneCard("analeptic"), target) then
      room:useVirtualCard("analeptic", nil, target, target, self.name, false)
      if target.dead then return end
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = self.name,
      }
    end
  end,
}
local qiluan = fk.CreateTriggerSkill{
  name = "qiluan",
  anim_type = "offensive",
  events = {fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and #player.room.logic:getEventsOfScope(GameEvent.Death, 1, function (e)
      local deathData = e.data[1]
      if deathData.damage and deathData.damage.from == player then
        return true
      end
    end, Player.HistoryTurn) > 0
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(3, self.name)
  end,
}
hetaihou:addSkill(zhendu)
hetaihou:addSkill(qiluan)
Fk:loadTranslationTable{
  ["hetaihou"] = "何太后",
  ["#hetaihou"] = "弄权之蛇蝎",
  ["cv:hetaihou"] = "水原",
  ["designer:hetaihou"] = "淬毒",
  ["illustrator:hetaihou"] = "琛·美弟奇",
  ["zhendu"] = "鸩毒",
  [":zhendu"] = "其他角色的出牌阶段开始时，你可弃置一张手牌，其视为使用一张【酒】，然后你对其造成1点伤害。",
  ["qiluan"] = "戚乱",
  [":qiluan"] = "一名角色的回合结束时，若你杀死过角色，你可摸3张牌。",
  ["#zhendu-invoke"] = "鸩毒：你可以弃置一张手牌视为 %dest 使用一张【酒】，然后你对其造成1点伤害",

  ["$zhendu1"] = "怪只怪你，不该生有皇子！",
  ["$zhendu2"] = "后宫之中，岂有你的位置！",
  ["$qiluan1"] = "待我召吾兄入宫，谁敢不从？",
  ["$qiluan2"] = "本后自有哥哥在外照应，有什么好担心的！",
  ["~hetaihou"] = "你们男人造的孽，非要说什么红颜祸水……",
}

local sunluyu = General(extension, "sunluyu", "wu", 3, 3, General.Female)
local meibu = fk.CreateTriggerSkill{
  name = "meibu",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target.phase == Player.Play and target ~= player and
      not target:inMyAttackRange(player) and not target.dead
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#meibu-invoke::"..target.id)
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(target, "meibu-turn", 1)
  end,
}
local meibu_filter = fk.CreateFilterSkill{
  name = "#meibu_filter",
  card_filter = function(self, to_select, player)
    return player:getMark("meibu-turn") > 0 and to_select.type == Card.TypeTrick and
    table.contains(player.player_cards[Player.Hand], to_select.id)
  end,
  view_as = function(self, to_select)
    local card = Fk:cloneCard("slash", to_select.suit, to_select.number)
    card.skillName = "meibu"
    return card
  end,
}
local meibu_attackrange = fk.CreateAttackRangeSkill{
  name = "#meibu_attackrange",
  within_func = function (self, from, to)
    return from.phase ~= Player.NotActive and to:usedSkillTimes("meibu", Player.HistoryTurn) > 0
  end,
}
local mumu = fk.CreateTriggerSkill{
  name = "mumu",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and player.phase == Player.Finish then
      local play_ids = {}
      player.room.logic:getEventsOfScope(GameEvent.Phase, 1, function (e)
        if e.data[2] == Player.Play and e.end_id then
          table.insert(play_ids, {e.id, e.end_id})
        end
        return false
      end, Player.HistoryTurn)
      if #play_ids == 0 then return true end
      return #player.room.logic:getActualDamageEvents(1, function(e)
        if e.data[1].from == player then
          for _, ids in ipairs(play_ids) do
            if e.id > ids[1] and e.id < ids[2] then
              return true
            end
          end
        end
      end) == 0
    end
  end,
  on_cost = function(self, event, target, player, data)
    local targets = {}
    for _, p in ipairs(player.room:getAlivePlayers()) do
      if #p:getEquipments(Card.SubtypeWeapon) > 0 or (#p:getEquipments(Card.SubtypeArmor) > 0 and p ~= player and
        #player:getAvailableEquipSlots(Card.SubtypeArmor) > 0) then
        table.insert(targets, p.id)
      end
    end
    if #targets == 0 then return end
    local to = player.room:askForChoosePlayers(player, targets, 1, 1, "#mumu-choose", self.name, true)
    if #to > 0 then
      self.cost_data = {tos = to}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data.tos[1])
    local card_data = {}
    if #to:getEquipments(Card.SubtypeWeapon) > 0 then
      table.insert(card_data, {"weapon", to:getEquipments(Card.SubtypeWeapon)})
    end
    if to ~= player and #to:getEquipments(Card.SubtypeArmor) > 0 and #player:getAvailableEquipSlots(Card.SubtypeArmor) > 0 then
      table.insert(card_data, {"armor", to:getEquipments(Card.SubtypeArmor)})
    end
    if #card_data == 0 then return end
    local id = room:askForCardChosen(player, player, { card_data = card_data }, self.name, "#mumu-card")
    if Fk:getCardById(id).sub_type == Card.SubtypeWeapon then
      room:throwCard({id}, self.name, to, player)
      if not player.dead then
        player:drawCards(1, self.name)
      end
    else
      room:moveCardIntoEquip(player, id, self.name, true, player)
    end
  end,
}
meibu:addRelatedSkill(meibu_attackrange)
meibu:addRelatedSkill(meibu_filter)
sunluyu:addSkill(meibu)
sunluyu:addSkill(mumu)
Fk:loadTranslationTable{
  ["sunluyu"] = "孙鲁育",
  ["#sunluyu"] = "舍身饲虎",
  ["cv:sunluyu"] = "sakula小舞",
  ["designer:sunluyu"] = "桃花僧",
  ["illustrator:sunluyu"] = "depp",
  ["meibu"] = "魅步",
  [":meibu"] = "一名其他角色的出牌阶段开始时，若你不在其攻击范围内，你可以令该角色的锦囊牌均视为【杀】直到回合结束。若如此做，视为你在其攻击范围内直到回合结束。",
  ["mumu"] = "穆穆",
  [":mumu"] = "若你于出牌阶段内未造成伤害，则此回合的结束阶段开始时，你可以选择一项：弃置场上一张武器牌，然后摸一张牌；"..
  "或将场上一张防具牌移动到你的装备区里（可替换原防具）。",
  ["#meibu-invoke"] = "魅步：你可以对 %dest 发动“魅步”，令其锦囊牌视为【杀】直到回合结束",
  ["#meibu_filter"] = "止息",
  ["#mumu-choose"] = "穆穆：选择一名角色，弃置其武器牌并摸一张牌；或将其的防具牌移动到你的装备区",
  ["#mumu-card"] = "穆穆：弃置武器牌，或将防具牌移动到你的装备区",

  ["$meibu1"] = "萧墙之乱，宫闱之衅，实为吴国之祸啊！",
  ["$meibu2"] = "若要动手，就请先杀我吧！",
  ["$mumu1"] = "立储乃国家大事，我们姐妹不便参与。",
  ["$mumu2"] = "只求相夫教子，不求参政议事。",
  ["~sunluyu"] = "姐姐，你且好自为之……",
}

local getKingdom = function(player)
  local ret = player.kingdom
  if ret == "wild" then
    ret = player.role
  end
  return ret
end

local nos__maliang = General(extension, "nos__maliang", "shu", 3)
local xiemu = fk.CreateActiveSkill{
  name = "xiemu",
  anim_type = "drawcard",
  card_num = 1,
  target_num = 0,
  prompt = "#xiemu",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name) == 0 and not player:isKongcheng()
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).trueName == "slash" and not Self:prohibitDiscard(Fk:getCardById(to_select))
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:throwCard(effect.cards, self.name, player, player)
    local choices = {}
    for _, p in ipairs(room.alive_players) do
      local kingdom = getKingdom(p)
      if kingdom ~= "unknown" then
        table.insertIfNeed(choices, kingdom)
      end
    end
    local kingdom = room:askForChoice(player, choices, self.name)
    room:setPlayerMark(player, "@xiemu", kingdom)
  end
}
local xiemu_record = fk.CreateTriggerSkill{
  name = "#xiemu_record",
  anim_type = "drawcard",
  events = {fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    return target == player and not player.dead and player:getMark("@xiemu") ~= 0 and
      data.from ~= player.id and getKingdom(player.room:getPlayerById(data.from)) == player:getMark("@xiemu") and
      data.card.color == Card.Black
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(2, xiemu.name)
  end,

  refresh_events = {fk.TurnStart},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@xiemu") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@xiemu", 0)
  end,
}
local naman = fk.CreateTriggerSkill{
  name = "naman",
  anim_type = "drawcard",
  events = {fk.CardRespondFinished},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and data.card.trueName == "slash" and data.from ~= player.id then
      return player.room:getCardArea(data.card) == Card.Processing
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:obtainCard(player.id, data.card, true, fk.ReasonJustMove)
  end,
}
xiemu:addRelatedSkill(xiemu_record)
nos__maliang:addSkill(xiemu)
nos__maliang:addSkill(naman)
Fk:loadTranslationTable{
  ["nos__maliang"] = "马良",
  ["#nos__maliang"] = "白眉智士",
  ["xiemu"] = "协穆",
  [":xiemu"] = "出牌阶段限一次，你可以弃置一张【杀】并选择一个势力，然后直到你的下回合开始，该势力的其他角色使用的黑色牌指定目标后，"..
  "若你是此牌的目标，你可以摸两张牌。",
  ["naman"] = "纳蛮",
  [":naman"] = "当其他角色打出的【杀】进入弃牌堆时，你可以获得之。",
  ["@xiemu"] = "协穆",
  ["#xiemu_record"] = "协穆",
  ["#xiemu"] = "协穆：弃一张【杀】并选择一个势力，直到你下回合，该势力角色使用黑色牌指定你为目标后，你摸两张牌",

  ["$xiemu1"] = "休要再起战事。",
  ["$xiemu2"] = "暴戾之气，伤人害己。",
  ["$naman1"] = "弃暗投明，光耀门楣！",
  ["$naman2"] = "慢着，让我来！",
  ["~nos__maliang"] = "皇叔为何不听我之言？",
}

local maliang = General(extension, "maliang", "shu", 3)
local zishu = fk.CreateTriggerSkill{
  name = "zishu",
  mute = true,
  frequency = Skill.Compulsory,
  events = {fk.TurnEnd, fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      if event == fk.TurnEnd then
        return target ~= player and table.find(player.player_cards[Player.Hand], function (id)
          return Fk:getCardById(id):getMark("@@zishu-inhand") > 0
        end)
      elseif player.phase ~= Player.NotActive then
        for _, move in ipairs(data) do
          if move.to == player.id and move.toArea == Player.Hand and move.skillName ~= self.name then
            return true
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.TurnEnd then
      player:broadcastSkillInvoke(self.name, 2)
      room:notifySkillInvoked(player, self.name, "negative")
      local cards = {}
      for _, id in ipairs(player:getCardIds(Player.Hand)) do
        if Fk:getCardById(id):getMark("@@zishu-inhand") > 0 then
          table.insert(cards, id)
        end
      end
      if #cards > 0 then
        room:moveCards({
          from = player.id,
          ids = cards,
          toArea = Card.DiscardPile,
          moveReason = fk.ReasonPutIntoDiscardPile,
          skillName = self.name,
          proposer = player.id,
        })
      end
    else
      player:broadcastSkillInvoke(self.name, 1)
      room:notifySkillInvoked(player, self.name, "drawcard")
      player:drawCards(1, self.name)
    end
  end,

  refresh_events = {fk.AfterCardsMove, fk.AfterTurnEnd},
  can_refresh = function(self, event, target, player, data)
    if event == fk.AfterCardsMove then
      return player:hasSkill(self, true) and player.phase == Player.NotActive
    else
      table.find(player.player_cards[Player.Hand], function (id)
        return Fk:getCardById(id):getMark("@@zishu-inhand") > 0
      end)
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.AfterCardsMove then
      for _, move in ipairs(data) do
        if move.to == player.id and move.toArea == Player.Hand then
          for _, info in ipairs(move.moveInfo) do
            local id = info.cardId
            if room:getCardArea(id) == Card.PlayerHand and room:getCardOwner(id) == player then
              room:setCardMark(Fk:getCardById(id), "@@zishu-inhand", 1)
            end
          end
        end
      end
    elseif event == fk.AfterTurnEnd then
      for _, id in ipairs(player:getCardIds(Player.Hand)) do
        room:setCardMark(Fk:getCardById(id), "@@zishu-inhand", 0)
      end
    end
  end,
}
local yingyuan = fk.CreateTriggerSkill{
  name = "yingyuan",
  anim_type = "support",
  events = {fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and player.phase == Player.Play then
      local mark = player:getMark("yingyuan-turn")
      if type(mark) ~= "table" or not table.contains(mark, data.card.trueName) then
        local cardlist = data.card:isVirtual() and data.card.subcards or {data.card.id}
        local room = player.room
        return #cardlist > 0 and table.every(cardlist, function (id)
          return room:getCardArea(id) == Card.Processing
        end)
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local to = player.room:askForChoosePlayers(player, table.map(player.room:getOtherPlayers(player), Util.IdMapper), 1, 1,
      "#yingyuan-card:::"..data.card:toLogString(), self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = room:getSubcardsByRule(data.card, { Card.Processing })
    local to = room:getPlayerById(self.cost_data)
    room:moveCardTo(cards, Card.PlayerHand, to, fk.ReasonGive, self.name, nil, true, player.id)
    if player.dead then return end
    room:addTableMark(player, "yingyuan-turn", data.card.trueName)
  end,
}
maliang:addSkill(zishu)
maliang:addSkill(yingyuan)
Fk:loadTranslationTable{
  ["maliang"] = "马良",
  ["#maliang"] = "白眉智士",
  ["cv:maliang"] = "马洋",
  ["illustrator:maliang"] = "LiuHeng",
  ["zishu"] = "自书",
  [":zishu"] = "锁定技，你的回合外，其他角色回合结束时，将你手牌中所有本回合获得的牌置入弃牌堆；你的回合内，当你不因此技能获得牌时，摸一张牌。",
  ["yingyuan"] = "应援",
  [":yingyuan"] = "当你于回合内使用的牌结算完毕置入弃牌堆时，你可以将之交给一名其他角色（每回合每种牌名限一次）。",
  ["#zishu-discard"] = "自书",
  ["#yingyuan-card"] = "应援：你可以将 %arg 交给一名其他角色",

  ["@@zishu-inhand"] = "自书",

  ["$zishu1"] = "慢着，让我来！",
  ["$zishu2"] = "身外之物，不要也罢！",
  ["$yingyuan1"] = "接好嘞！",
  ["$yingyuan2"] = "好牌只用一次怎么够？",
  ["~maliang"] = "我的使命完成了吗……",
}

local ganfuren = General(extension, "ganfuren", "shu", 3, 3, General.Female)
local shushen = fk.CreateTriggerSkill{
  name = "shushen",
  anim_type = "support",
  events = {fk.HpRecover},
  on_trigger = function(self, event, target, player, data)
    self.cancel_cost = false
    for i = 1, data.num do
      if self.cancel_cost or not player:hasSkill(self) then break end
      self:doCost(event, target, player, data)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askForChoosePlayers(player, table.map(room:getOtherPlayers(player), Util.IdMapper), 1, 1, "#shushen-choose",
      self.name, true)
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
      to:drawCards(2, self.name)
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
    return target == player and player:hasSkill(self) and player.phase == Player.Start and
    table.find(player:getCardIds("h"), function(id) return not player:prohibitDiscard(Fk:getCardById(id)) end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = table.filter(player:getCardIds("h"), function(id) return not player:prohibitDiscard(Fk:getCardById(id)) end)
    room:throwCard(cards, self.name, player, player)
    if player:isWounded() and not player.dead and #cards >= player.hp then
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
  ["#ganfuren"] = "昭烈皇后",
  ["illustrator:ganfuren"] = "琛·美弟奇",

  ["shushen"] = "淑慎",
  [":shushen"] = "当你回复1点体力时，你可以令一名其他角色回复1点体力或摸两张牌。",
  ["shenzhi"] = "神智",
  [":shenzhi"] = "准备阶段开始时，你可以弃置所有手牌，若你以此法弃置的手牌数不小于X，你回复1点体力(X为你当前的体力值)。",
  ["#shushen-choose"] = "淑慎：你可以令一名其他角色回复1点体力或摸两张牌",

  ["$shushen1"] = "妾身无恙，相公请安心征战。",
  ["$shushen2"] = "船到桥头自然直。",
  ["$shenzhi1"] = "子龙将军，一切都托付给你了。",
  ["$shenzhi2"] = "阿斗，相信妈妈，没事的。",
  ["~ganfuren"] = "请替我照顾好阿斗。",
}

local huangjinleishi = General(extension, "huangjinleishi", "qun", 3, 3, General.Female)
local fulu = fk.CreateViewAsSkill{
  name = "fulu",
  anim_type = "offensive",
  pattern = "slash",
  prompt = "#fulu",
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
    return player:hasSkill(self) and data.damageType == fk.ThunderDamage and data.from and not data.from.dead
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#zhuji-invoke:"..data.from.id .. ":" .. data.to.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = data.from
    local judge = {
      who = to,
      reason = self.name,
      pattern = ".",
    }
    room:judge(judge)
    if judge.card.color == Card.Black then
      data.damage = data.damage + 1
    end
  end,
}
local zhuji_delay = fk.CreateTriggerSkill{
  name = "#zhuji_delay",
  events = {fk.FinishJudge},
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and not player.dead and data.card.color == Card.Red and data.reason == zhuji.name
      and player.room:getCardArea(data.card.id) == Card.Processing
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:obtainCard(player.id, data.card)
  end,
}
zhuji:addRelatedSkill(zhuji_delay)
huangjinleishi:addSkill(fulu)
huangjinleishi:addSkill(zhuji)
Fk:loadTranslationTable{
  ["huangjinleishi"] = "黄巾雷使",
  ["#huangjinleishi"] = "雷祭之姝",
  ["cv:huangjinleishi"] = "穆小橘v（新月杀原创）",
  ["designer:huangjinleishi"] = "韩旭",
  ["illustrator:huangjinleishi"] = "depp",
  ["fulu"] = "符箓",
  [":fulu"] = "你可以将【杀】当雷【杀】使用。",
  ["zhuji"] = "助祭",
  [":zhuji"] = "当一名角色造成雷电伤害时，你可以令其进行一次判定，若结果为黑色，此伤害+1；若结果为红色，该角色获得此牌。",
  ["#fulu"] = "符箓：你可以将【杀】当雷【杀】使用",
  ["#zhuji-invoke"] = "你可发动助祭，令%src判定，若为黑色则对%dest造成的伤害+1，红色则其获得判定牌",
  ["#zhuji_delay"] = "助祭",

  ["$fulu1"] = "电母雷公，速降神通。",
  ["$fulu2"] = "山岳高昂，五雷速发。",
  ["$zhuji1"] = "大神宏量，请昭太平！",
  ["$zhuji2"] = "惠民济困，共辟黄天。",
  ["~huangjinleishi"] = "速报大贤良师……大事已泄……",
}

local wenpin = General(extension, "wenpin", "wei", 4)
local zhenwei = fk.CreateTriggerSkill{
  name = "zhenwei",
  anim_type = "defensive",
  events = {fk.TargetConfirming},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and not player:isNude() and data.from ~= player.id and
      (data.card.trueName == "slash" or (data.card.type == Card.TypeTrick and data.card.color == Card.Black)) and
      U.isOnlyTarget(target, data, event) and target.hp < player.hp
  end,
  on_cost = function(self, event, target, player, data)
    local cards = player.room:askForDiscard(player, 1, 1, true, self.name, true, ".",
    "#zhenwei-invoke:" .. data.from .. ":" .. data.to .. ":" .. data.card:toLogString())
    if #cards > 0 then
      self.cost_data = cards
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(self.cost_data, self.name, player, player)
    if player.dead then return false end
    local choice = room:askForChoice(player, {"zhenwei_transfer", "zhenwei_recycle"}, self.name)
    if choice == "zhenwei_transfer" then
      room:drawCards(player, 1, self.name)
      if player.dead then return false end
      if U.canTransferTarget(player, data) then
        local targets = {player.id}
        if type(data.subTargets) == "table" then
          table.insertTable(targets, data.subTargets)
        end
        AimGroup:addTargets(room, data, targets)
        AimGroup:cancelTarget(data, target.id)
        return true
      end
    else
      data.tos = AimGroup:initAimGroup({})
      data.targetGroup = {}
      local use_from = room:getPlayerById(data.from)
      if not use_from.dead and U.hasFullRealCard(room, data.card) then
        use_from:addToPile(self.name, data.card, true, self.name)
      end
      return true
    end
  end,
}
local zhenwei_delay = fk.CreateTriggerSkill{
  name = "#zhenwei_delay",
  mute = true,
  events = {fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    return #player:getPile("zhenwei") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:moveCardTo(player:getPile("zhenwei"), Card.PlayerHand, player, fk.ReasonJustMove, "zhenwei", nil, true, player.id)
  end,
}
zhenwei:addRelatedSkill(zhenwei_delay)
wenpin:addSkill(zhenwei)
Fk:loadTranslationTable{
  ["wenpin"] = "文聘",
  ["#wenpin"] = "坚城宿将",
  ["illustrator:wenpin"] = "G.G.G.",
  ["zhenwei"] = "镇卫",
  [":zhenwei"] = "当一名其他角色成为【杀】或黑色锦囊牌的唯一目标时，若该角色的体力值小于你，你可以弃置一张牌并选择一项："..
  "摸一张牌，然后你成为此牌的目标；或令此牌失效并将之移出游戏，该回合结束时令此牌的使用者收回此牌。",
  ["#zhenwei-invoke"] = "%src对%dest使用%arg，是否弃置一张牌来发动 镇卫",
  ["zhenwei_transfer"] = "摸一张牌并将此牌转移给你",
  ["zhenwei_recycle"] = "取消此牌，回合结束时使用者将之收回",
  ["#zhenwei_delay"] = "镇卫",

  ["$zhenwei1"] = "再敢来犯，仍叫你无功而返！",
  ["$zhenwei2"] = "江夏防线，固若金汤！",
  ["~wenpin"] = "终于……也守不住了……",
}

local simalang = General(extension, "simalang", "wei", 3)
local junbing = fk.CreateTriggerSkill{
  name = "junbing",
  anim_type = "support",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target.phase == Player.Finish and target:getHandcardNum() < 2
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(target, self.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:drawCards(target, 1, self.name)
    if target == player or target.dead or player.dead or target:isKongcheng() then return false end
    local cards = target:getCardIds(Player.Hand)
    room:moveCardTo(cards, Player.Hand, player, fk.ReasonGive, self.name, nil, false, target.id)
    if target.dead or player.dead or player:isKongcheng() then return end
    local n = math.min(#cards, player:getHandcardNum())
    cards = room:askForCard(player, n, n, false, self.name, false, ".",
      "#junbing-give::"..target.id..":"..n)
    room:moveCardTo(cards, Player.Hand, target, fk.ReasonGive, self.name, nil, false, player.id)
  end,
}
local quji = fk.CreateActiveSkill{
  name = "quji",
  anim_type = "support",
  min_card_num = function ()
    return Self:getLostHp()
  end,
  min_target_num = 1,
  prompt = function ()
    return "#quji:::"..Self:getLostHp()
  end,
  can_use = function(self, player)
    return player:isWounded() and player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, to_select, selected)
    return #selected < Self:getLostHp()
  end,
  target_filter = function(self, to_select, selected, cards)
    return #selected < Self:getLostHp() and Fk:currentRoom():getPlayerById(to_select):isWounded()
    and #cards == Self:getLostHp()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local loseHp = table.find(effect.cards, function(id) return Fk:getCardById(id).color == Card.Black end)
    room:throwCard(effect.cards, self.name, player, player)
    local tos = effect.tos
    room:sortPlayersByAction(tos)
    for _, pid in ipairs(tos) do
      local to = room:getPlayerById(pid)
      if not to.dead and to:isWounded() then
        room:recover({
          who = to,
          num = 1,
          recoverBy = player,
          skillName = self.name
        })
      end
    end
    if loseHp and not player.dead then
      room:loseHp(player, 1, self.name)
    end
  end,
}
simalang:addSkill(junbing)
simalang:addSkill(quji)
Fk:loadTranslationTable{
  ["simalang"] = "司马朗",
  ["#simalang"] = "再世神农",
  ["designer:simalang"] = "韩旭",
  ["illustrator:simalang"] = "Sky",
  ["junbing"] = "郡兵",
  [":junbing"] = "每名角色的结束阶段，若其手牌数小于或等于1，该角色可以摸一张牌，若该角色不是你，则其将所有手牌交给你，然后你将等量的手牌交给其。",
  ["quji"] = "去疾",
  [":quji"] = "出牌阶段限一次，若你已受伤，你可以弃置X张牌并选择至多X名已受伤的角色，令这些角色各回复1点体力，然后若你以此法弃置过的牌中有黑色牌，"..
  "你失去1点体力。（X为你已损失的体力值）",
  ["#junbing-give"] = "郡兵：将%arg张手牌交给 %dest",
  ["#quji"] = "去疾：弃置%arg张牌，令至多等量角色回复体力，若弃置了黑色牌，你失去1点体力",

  ["$junbing1"] = "男儿慷慨，军中豪迈。",
  ["$junbing2"] = "郡国当有搜狩习战之备。",
  ["$quji1"] = "若不去兵之疾，则将何以守国？",
  ["$quji2"] = "愿为将士，略尽绵薄。",
  ["~simalang"] = "微功未效，有辱国恩……",
}

return extension
