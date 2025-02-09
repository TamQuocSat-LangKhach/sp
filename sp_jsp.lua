local extension = Package("sp_jsp")
extension.extensionName = "sp"

Fk:loadTranslationTable{
  ["sp_jsp"] = "JSP",
  ["jsp"] = "JSP",
}

local U = require "packages/utility/utility"

local sunshangxiang = General(extension, "jsp__sunshangxiang", "shu", 3, 3, General.Female)
local liangzhu = fk.CreateTriggerSkill{
  name = "liangzhu",
  anim_type = "drawcard",
  events = {fk.HpRecover},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target.phase == Player.Play
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#liangzhu-invoke::"..target.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = room:askForChoice(player, {"draw1", "liangzhu_draw2"}, self.name)
    if choice == "draw1" then
      player:drawCards(1, self.name)
    else
      room:doIndicate(player.id, {target.id})
      target:drawCards(2, self.name)
      room:addTableMarkIfNeed(player, "liangzhu_target", target.id)
    end
  end,
}
local fanxiang = fk.CreateTriggerSkill{
  name = "fanxiang",
  frequency = Skill.Wake,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      player.phase == Player.Start and
      player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player, data)
    return table.find(player.room.alive_players, function(p) 
      return p:isWounded() and table.contains(player:getTableMark("liangzhu_target"), p.id)
    end)
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
    room:handleAddLoseSkills(player, "-liangzhu|xiaoji", nil)
  end,
}
sunshangxiang:addSkill(liangzhu)
sunshangxiang:addSkill(fanxiang)
sunshangxiang:addRelatedSkill("xiaoji")
Fk:loadTranslationTable{
  ["jsp__sunshangxiang"] = "孙尚香",
  ["#jsp__sunshangxiang"] = "梦醉良缘",
  ["illustrator:jsp__sunshangxiang"] = "木美人",
  ["designer:jsp__sunshangxiang"] = "韩旭",

  ["liangzhu"] = "良助",
  [":liangzhu"] = "当一名角色于其出牌阶段内回复体力时，你可以选择一项：1.摸一张牌；2.令该角色摸两张牌。",
  ["fanxiang"] = "返乡",
  [":fanxiang"] = "觉醒技，准备阶段开始时，若全场有至少一名已受伤的角色，且你令其执行过〖良助〗选项2的效果，则你加1点体力上限并回复1点体力，失去技能〖良助〗并获得技能〖枭姬〗。",
  ["#liangzhu-invoke"] = "良助：你可以摸一张牌或令 %dest 摸两张牌",
  ["liangzhu_draw2"] = "其摸两张牌",

  ["$liangzhu1"] = "吾愿携弩，征战沙场，助君一战！",
  ["$liangzhu2"] = "两国结盟，你我都是一家人。",
  ["$fanxiang1"] = "兄命难违，从此两别。",
  ["$fanxiang2"] = "今夕一别，不知何日再见。",
  ["$xiaoji_jsp__sunshangxiang1"] = "弓马何须忌红妆？",
  ["$xiaoji_jsp__sunshangxiang2"] = "双剑夸巧，不让须眉！",
  ["~jsp__sunshangxiang"] = "东途难归，初心难追。",
}

local machao = General(extension, "jsp__machao", "qun", 4)
local zhuiji = fk.CreateDistanceSkill{
  name = "zhuiji",
  frequency = Skill.Compulsory,
  fixed_func = function(self, from, to)
    if from:hasSkill(self) and from.hp > to.hp then
      return 1
    end
  end,
}
local cihuai = fk.CreateViewAsSkill{
  name = "cihuai",
  anim_type = "offensive",
  pattern = "slash",
  card_filter = function(self, to_select, selected)
    return false
  end,
  view_as = function(self, cards)
    if Self:getMark(self.name) == 0 then return end
    local c = Fk:cloneCard("slash")
    c.skillName = self.name
    return c
  end,
}
local cihuai_invoke = fk.CreateTriggerSkill{
  name = "#cihuai_invoke",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill("cihuai") and player.phase == Player.Play and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, "cihuai")
  end,
  on_use = function(self, event, target, player, data)
    local cards = player.player_cards[Player.Hand]
    player:showCards(cards)
    for _, id in ipairs(cards) do
      if Fk:getCardById(id).trueName == "slash" then
        return
      end
    end
    player.room:addPlayerMark(player, "cihuai", 1)
  end,

  refresh_events = {fk.AfterCardsMove, fk.Death},
  can_refresh = function(self, event, target, player, data)
    if player:hasSkill(self, true) then
      if event == fk.AfterCardsMove then
        for _, move in ipairs(data) do
          if move.from == player.id or move.to == player.id then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerHand or info.toArea == Card.PlayerHand then
                return true
              end
            end
          end
        end
      else
        return true
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "cihuai", 0)
  end,
}
cihuai:addRelatedSkill(cihuai_invoke)
machao:addSkill(zhuiji)
machao:addSkill(cihuai)
Fk:loadTranslationTable{
  ["jsp__machao"] = "马超",
  ["#jsp__machao"] = "西凉的猛狮",
  ["illustrator:jsp__machao"] = "depp",
  ["designer:jsp__machao"] = "伴剑一生",

  ["zhuiji"] = "追击",
  [":zhuiji"] = "锁定技，你计算体力值比你少的角色的距离始终为1。",
  ["cihuai"] = "刺槐",
  [":cihuai"] = "出牌阶段开始时，你可以展示你的手牌，若其中没有【杀】，则你使用或打出【杀】时不需要手牌，直到你的手牌数变化或有角色死亡。",
  ["#cihuai_invoke"] = "刺槐",
}

local guanyu = General(extension, "jsp__guanyu", "wei", 4)
local danji = fk.CreateTriggerSkill{
  name = "danji",
  frequency = Skill.Wake,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      player.phase == Player.Start and
      player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player, data)
    return #player.player_cards[Player.Hand] > player.hp and not string.find(player.room:getLord().general, "liubei")
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, -1)
    room:handleAddLoseSkills(player, "mashu|nuzhan", nil)
  end,
}
local nuzhan = fk.CreateTriggerSkill{
  name = "nuzhan",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.AfterCardUseDeclared, fk.PreCardUse},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self, false, true) and data.card and data.card.trueName == "slash" and
      data.card:isVirtual() and #data.card.subcards == 1 then
      if event == fk.AfterCardUseDeclared then
        return player.phase == Player.Play and Fk:getCardById(data.card.subcards[1]).type == Card.TypeTrick
      else
        return Fk:getCardById(data.card.subcards[1]).type == Card.TypeEquip
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    if event == fk.AfterCardUseDeclared then
      player:addCardUseHistory(data.card.trueName, -1)
    else
      data.additionalDamage = (data.additionalDamage or 0) + 1
    end
  end,
}
guanyu:addSkill(danji)
guanyu:addSkill("wusheng")
guanyu:addRelatedSkill(nuzhan)
Fk:loadTranslationTable{
  ["jsp__guanyu"] = "关羽",
  ["#jsp__guanyu"] = "汉寿亭侯",
  ["illustrator:jsp__guanyu"] = "Zero",

  ["danji"] = "单骑",
  [":danji"] = "觉醒技，准备阶段开始时，若你的手牌数大于体力值且本局游戏的主公不是刘备，你须减1点体力上限，然后获得技能〖马术〗和〖怒斩〗。",
  ["nuzhan"] = "怒斩",
  [":nuzhan"] = "锁定技，你将锦囊牌当【杀】使用时，此【杀】不计入出牌阶段使用次数；你将装备牌当【杀】使用时，此【杀】伤害+1。",

  ["$wusheng_jsp__guanyu1"] = "以义传魂，以武入圣！",
  ["$wusheng_jsp__guanyu2"] = "义击逆流，武安黎庶！",
  ["$danji1"] = "单骑护嫂千里，只为桃园之义！",
  ["$danji2"] = "独身远涉，赤心归国！",
  ["~jsp__guanyu"] = "樊城一去，死亦无惧！",
}

local jiangwei = General(extension, "jsp__jiangwei", "wei", 4)
local kunfen = fk.CreateTriggerSkill{
  name = "kunfen",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish
  end,
  on_use = function(self, event, target, player, data)
    player.room:loseHp(player, 1, self.name)
    if player:isAlive() then
      player.room:drawCards(player, 2, self.name)
    end
  end,
}
local kunfenEx = fk.CreateTriggerSkill{
  name = "kunfenEx",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish
  end,
  on_use = function(self, event, target, player, data)
    player.room:loseHp(player, 1, self.name)
    if player:isAlive() then
      player.room:drawCards(player, 2, self.name)
    end
  end,
}
local fengliang = fk.CreateTriggerSkill{
  name = "fengliang",
  anim_type = "defensive",
  events = {fk.EnterDying},
  frequency = Skill.Wake,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player, data)
    return player.dying
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, -1)
    room:recover({
      who = player,
      num = 2 - player.hp,
      recoverBy = player,
      skillName = self.name
    })
    room:handleAddLoseSkills(player, "tiaoxin", nil, true, false)
    if player:hasSkill("kunfen", true) then
      if player.phase == Player.Finish and player:usedSkillTimes("kunfen", Player.HistoryPhase) > 0 then
        room:handleAddLoseSkills(player, "-kunfen", nil, false, true)
        local phase = room.logic:getCurrentEvent():findParent(GameEvent.Phase)
        if phase ~= nil then
          phase:addCleaner(function()
            room:handleAddLoseSkills(player, "kunfenEx", nil, false, true)
          end)
        end
      else
        room:handleAddLoseSkills(player, "-kunfen|kunfenEx", nil, false, true)
      end
    end
  end,
}
Fk:addSkill(kunfenEx)
jiangwei:addSkill(kunfen)
jiangwei:addSkill(fengliang)
jiangwei:addRelatedSkill("tiaoxin")
Fk:loadTranslationTable{
  ["jsp__jiangwei"] = "姜维",
  ["#jsp__jiangwei"] = "幼麒",
  ["illustrator:jsp__jiangwei"] = "depp",
  ["cv:jsp__jiangwei"] = "绯川陵彦",
  ["designer:jsp__jiangwei"] = "梦三",

  ["kunfen"] = "困奋",
  [":kunfen"] = "锁定技，结束阶段开始时，你失去1点体力，然后摸两张牌。",
  ["fengliang"] = "逢亮",
  [":fengliang"] = "觉醒技，当你进入濒死状态时，你减1点体力上限并将体力值回复至2点，然后获得技能〖挑衅〗，将技能〖困奋〗改为非锁定技。",
  ["kunfenEx"] = "困奋",
  [":kunfenEx"] = "结束阶段开始时，你可以失去1点体力，然后摸两张牌。",

  ["$kunfen1"] = "纵使困顿难行，亦当砥砺奋进！",
  ["$kunfen2"] = "兴蜀需时，众将且勿惫怠！",
  ["$kunfenEx1"] = "纵使困顿难行，亦当砥砺奋进！",
  ["$kunfenEx2"] = "兴蜀需时，众将且勿惫怠！",
  ["$fengliang1"] = "得遇丞相，再生之德！",
  ["$fengliang2"] = "丞相大义，维岂有不从之理？",
  ["$tiaoxin_jsp__jiangwei1"] = "今日天公作美，怎能不战而退？",
  ["$tiaoxin_jsp__jiangwei2"] = "贼将无胆，何不早降！",
  ["~jsp__jiangwei"] = "伯约已尽力而为，奈何大汉，国运衰微……",
}

local zhaoyun = General(extension, "jsp__zhaoyun", "qun", 3)
local chixin = fk.CreateViewAsSkill{
  name = "chixin",
  pattern = "slash,jink",
  interaction = function()
    local names = {}
    if Fk.currentResponsePattern == nil and Self:canUse(Fk:cloneCard("slash")) then
      table.insertIfNeed(names, "slash")
    else
      for _, name in ipairs({"slash", "jink"}) do
        if Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(Fk:cloneCard(name)) then
          table.insertIfNeed(names, name)
        end
      end
    end
    if #names == 0 then return end
    return UI.ComboBox {choices = names}  --FIXME: 体验很不好！
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).suit == Card.Diamond
  end,
  view_as = function(self, cards)
    if #cards ~= 1 or self.interaction.data == nil then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = self.name
    card:addSubcard(cards[1])
    return card
  end,
}
local chixin_targetmod = fk.CreateTargetModSkill{
  name = "#chixin_targetmod",
  bypass_times = function(self, player, skill, scope, card, to)
    return player:hasSkill(self) and skill.trueName == "slash_skill" and to
    and scope == Player.HistoryPhase and player:inMyAttackRange(to) and to:getMark("chixin_slashed-phase") == 0
  end
}
local chixin_record = fk.CreateTriggerSkill{
  name = "#chixin_record",
  mute = true,
  refresh_events = {fk.TargetSpecified, fk.EventAcquireSkill},
  can_refresh = function(self, event, target, player, data)
    if event == fk.EventAcquireSkill then
      return target == player and data == self and player.phase == Player.Play
    end
    if target == player and player:hasSkill(self, true) and data.card and data.card.trueName == "slash" then
      local to = player.room:getPlayerById(data.to)
      return to and to:getMark("chixin_slashed-phase") == 0
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EventAcquireSkill then
      room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
        local use = e.data[1]
        if use.from == player.id and use.tos and use.card and use.card.trueName == "slash" then
          table.every(TargetGroup:getRealTargets(use.tos), function(pid)
            local to = room:getPlayerById(pid)
            if to then room:addPlayerMark(to, "chixin_slashed-phase", 1) end
          end)
        end
        return false
      end, Player.HistoryPhase)
    else
      room:addPlayerMark(room:getPlayerById(data.to), "chixin_slashed-phase", 1)
    end
  end,
}
local suiren = fk.CreateTriggerSkill{
  name = "suiren",
  frequency = Skill.Limited,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryGame) == 0 and
      player.phase == Player.Start and player:hasSkill("yicong", true)  --失去义从是发动条件吗？
  end,
  on_cost = function(self, event, target, player, data)
    local to = player.room:askForChoosePlayers(player, table.map(player.room:getAlivePlayers(), function (p)
      return p.id end), 1, 1, "#suiren-choose", self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:handleAddLoseSkills(player, "-yicong", nil, true, false)
    room:changeMaxHp(player, 1)
    if player:isWounded() then
      room:recover({
        who = player,
        num = 1,
        recoverBy = player,
        skillName = self.name
      })
    end
    room:getPlayerById(self.cost_data):drawCards(3, self.name)
  end,
}
chixin:addRelatedSkill(chixin_targetmod)
chixin:addRelatedSkill(chixin_record)
zhaoyun:addSkill("yicong")
zhaoyun:addSkill(chixin)
zhaoyun:addSkill(suiren)
Fk:loadTranslationTable{
  ["jsp__zhaoyun"] = "赵云",
  ["#jsp__zhaoyun"] = "常山的游龙",
  ["illustrator:jsp__zhaoyun"] = "天空之城",

  ["chixin"] = "赤心",
  [":chixin"] = "你可以将<font color='red'>♦</font>牌当【杀】或【闪】使用或打出。出牌阶段，你对你攻击范围内的每名角色均可使用一张【杀】。",
  ["suiren"] = "随仁",
  [":suiren"] = "限定技，准备阶段开始时，你可以失去技能〖义从〗，然后加1点体力上限并回复1点体力，再令一名角色摸三张牌。",
  ["#chixin_targetmod"] = "赤心",
  ["#chixin_record"] = "赤心",
  ["#suiren-choose"] = "随仁：你可以失去〖义从〗，然后加1点体力上限并回复1点体力，令一名角色摸三张牌",
}

local huangyueying = General(extension, "jsp__huangyueying", "qun", 3, 3, General.Female)
local jiqiao = fk.CreateTriggerSkill{
  name = "jiqiao",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Play and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local n = #player.room:askForDiscard(player, 1, 999, true, self.name, true, ".|.|.|.|.|equip", "#jiqiao-invoke")
    if n > 0 then
      self.cost_data = n
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = room:getNCards(2*self.cost_data)
    room:moveCards{
      ids = cards,
      toArea = Card.Processing,
      moveReason = fk.ReasonJustMove,
      skillName = self.name,
      proposer = player.id,
    }
    local get = {}
    for i = #cards, 1, -1 do
      if Fk:getCardById(cards[i]).type == Card.TypeTrick then
        table.insert(get, cards[i])
        table.removeOne(cards, cards[i])
      end
    end
    if #get > 0 then
      room:delay(1000)
      room:obtainCard(player.id, get, true, fk.ReasonJustMove)
    end
    if #cards > 0 then
      room:delay(1000)
      room:moveCards{
        ids = cards,
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonJustMove,
        skillName = self.name,
      }
    end
  end,
}
local linglong = fk.CreateTriggerSkill{
  name = "linglong",
  events = {fk.AskForCardUse, fk.AskForCardResponse},
  frequency = Skill.Compulsory,
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and not player:isFakeSkill(self) and
      (data.cardName == "jink" or (data.pattern and Exppattern:Parse(data.pattern):matchExp("jink|0|nosuit|none"))) and
      not player:getEquipment(Card.SubtypeArmor) and player:getMark(fk.MarkArmorNullified) == 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, data)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local judgeData = {
      who = player,
      reason = "eight_diagram",
      pattern = ".|.|heart,diamond",
    }
    room:judge(judgeData)

    if judgeData.card.color == Card.Red then
      if event == fk.AskForCardUse then
        data.result = {
          from = player.id,
          card = Fk:cloneCard('jink'),
        }
        data.result.card.skillName = "eight_diagram"
        data.result.card.skillName = "linglong"

        if data.eventData then
          data.result.toCard = data.eventData.toCard
          data.result.responseToEvent = data.eventData.responseToEvent
        end
      else
        data.result = Fk:cloneCard('jink')
        data.result.skillName = "eight_diagram"
        data.result.skillName = "linglong"
      end
      return true
    end
  end
}
local linglong_maxcards = fk.CreateMaxCardsSkill{
  name = "#linglong_maxcards",
  correct_func = function(self, player)
    if player:hasSkill("linglong") and player:getEquipment(Card.SubtypeOffensiveRide) == nil and
      player:getEquipment(Card.SubtypeDefensiveRide) == nil then
      return 1
    end
    return 0
  end,
}
local linglong_targetmod = fk.CreateTargetModSkill{
  name = "#linglong_targetmod",
  frequency = Skill.Compulsory,
  bypass_distances = function(self, player, skill, card)
    return player:hasSkill("linglong") and player:getEquipment(Card.SubtypeTreasure) == nil and card and card.type == Card.TypeTrick
  end,
}
linglong:addRelatedSkill(linglong_maxcards)
linglong:addRelatedSkill(linglong_targetmod)
huangyueying:addSkill(jiqiao)
huangyueying:addSkill(linglong)
huangyueying:addRelatedSkill("qicai")
Fk:loadTranslationTable{
  ["jsp__huangyueying"] = "黄月英",
  ["#jsp__huangyueying"] = "闺中璞玉",
  ["designer:jsp__huangyueying"] = "韩旭",
  ["illustrator:jsp__huangyueying"] = "木美人",

  ["jiqiao"] = "机巧",
  [":jiqiao"] = "出牌阶段开始时，你可以弃置任意张装备牌，然后亮出牌堆顶两倍数量的牌，你获得其中的锦囊牌，将其余的牌置入弃牌堆。",
  ["linglong"] = "玲珑",
  [":linglong"] = "锁定技，若你的装备区没有防具牌，视为你装备着【八卦阵】；若你的装备区没有坐骑牌，你的手牌上限+1；"..
  "若你的装备区没有宝物牌，视为你拥有技能〖奇才〗。",
  ["#jiqiao-invoke"] = "机巧：你可以弃置任意张装备牌，亮出牌堆顶两倍数量的牌并获得其中的锦囊牌",

  ["$jiqiao1"] = "驭巧器，以取先机。",
  ["$jiqiao2"] = "颖悟之人，不以拙力取胜。",
  ["$linglong1"] = "哼～书中自有玲珑心～",
  ["$linglong2"] = "哼～自然是多多益善咯～",
  ["~jsp__huangyueying"] = "只恨不能再助夫君了……",
}

return extension
