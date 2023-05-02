local extension = Package("sp_jsp")
extension.extensionName = "sp"

Fk:loadTranslationTable{
  ["sp_jsp"] = "JSP",
  ["jsp"] = "JSP",
}

local sunshangxiang = General(extension, "jsp__sunshangxiang", "shu", 3, 3, General.Female)
local liangzhu = fk.CreateTriggerSkill{
  name = "liangzhu",
  anim_type = "drawcard",
  events = {fk.HpRecover},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and target.phase == Player.Play
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = room:askForChoice(player, {"draw1", "liangzhu_draw2"}, self.name)
    if choice == "draw1" then
      player:drawCards(1)
      room:addPlayerMark(player, self.name, 1)
    else
      target:drawCards(2)
      room:addPlayerMark(target, self.name, 1)
    end
  end,
}
local fanxiang = fk.CreateTriggerSkill{
  name = "fanxiang",
  frequency = Skill.Wake,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self.name) and player:usedSkillTimes(self.name, Player.HistoryGame) == 0 and
     player.phase == Player.Start then
      for _, p in ipairs(player.room:getAlivePlayers()) do
        if p:isWounded() and p:getMark("liangzhu") > 0 then
          return true
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, 1)
    room:recover({
      who = player,
      num = 1,
      recoverBy = player,
      skillName = self.name
    })
    room:handleAddLoseSkills(player, "-liangzhu|xiaoji", nil)
  end,
}
sunshangxiang:addSkill(liangzhu)
sunshangxiang:addSkill(fanxiang)
sunshangxiang:addRelatedSkill("xiaoji")
Fk:loadTranslationTable{
  ["jsp__sunshangxiang"] = "孙尚香",
  ["liangzhu"] = "良助",
  [":liangzhu"] = "当一名角色于其出牌阶段内回复体力时，你可以选择一项：摸一张牌，或令该角色摸两张牌。",
  ["fanxiang"] = "返乡",
  [":fanxiang"] = "觉醒技，准备阶段开始时，若全场有至少一名已受伤的角色，且你曾发动〖良助〗令其摸牌，则你回复1点体力和体力上限，失去技能〖良助〗并获得技能〖枭姬〗。",
  ["liangzhu_draw2"] = "其摸两张牌",
}

local machao = General(extension, "jsp__machao", "qun", 4)
local zhuiji = fk.CreateDistanceSkill{
  name = "zhuiji",
  frequency = Skill.Compulsory,
  correct_func = function(self, from, to)
    if from:hasSkill(self.name) then
      if from.hp > to.hp then
        from:setFixedDistance(to, 1)
      else
        from:removeFixedDistance(to)
      end
    end
    return 0
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
    if player:hasSkill(self.name, true) then
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
    return target == player and player:hasSkill(self.name) and player:usedSkillTimes(self.name, Player.HistoryGame) == 0 and
      player.phase == Player.Start and
      #player.player_cards[Player.Hand] > player.hp and
      not string.find(player.room:getLord().general, "liubei")
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
  events = {fk.AfterCardUseDeclared, fk.DamageCaused},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self.name, false, true) and data.card and data.card.trueName == "slash" and data.card:isVirtual() and #data.card.subcards == 1 then
      if event == fk.AfterCardUseDeclared then
        return player.phase == Player.Play and Fk:getCardById(data.card.subcards[1]).type == Card.TypeTrick
      else
        return not data.chain and Fk:getCardById(data.card.subcards[1]).type == Card.TypeEquip
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    if event == fk.AfterCardUseDeclared then
      player:addCardUseHistory(data.card.trueName, -1)
    else
      data.damage = data.damage + 1
    end
  end,
}
guanyu:addSkill(danji)
guanyu:addSkill("wusheng")
guanyu:addRelatedSkill(nuzhan)
Fk:loadTranslationTable{
  ["jsp__guanyu"] = "关羽",
  ["danji"] = "单骑",
  [":danji"] = "觉醒技，准备阶段开始时，若你的手牌数大于体力值且本局游戏的主公不是刘备，你须减1点体力上限，然后获得技能〖马术〗和〖怒斩〗。",
  ["nuzhan"] = "怒斩",
  [":nuzhan"] = "锁定技，你将锦囊牌当【杀】使用时，此【杀】不计入出牌阶段使用次数；你将装备牌当【杀】使用时，此【杀】伤害+1。",
}

local jiangwei = General(extension, "jsp__jiangwei", "wei", 4)
local kunfen = fk.CreateTriggerSkill{
  name = "kunfen",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Finish
  end,
  on_cost = function(self, event, target, player, data)
    if player:usedSkillTimes("fengliang", Player.HistoryGame) == 0 then
      return true
    else
      return player.room:askForSkillInvoke(player, self.name)
    end
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
    return target == player and player:hasSkill(self.name) and player:usedSkillTimes(self.name, Player.HistoryGame) == 0
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
    room:handleAddLoseSkills(player, "tiaoxin", nil)
  end,
}
jiangwei:addSkill(kunfen)
jiangwei:addSkill(fengliang)
jiangwei:addRelatedSkill("tiaoxin")
Fk:loadTranslationTable{
  ["jsp__jiangwei"] = "姜维",
  ["kunfen"] = "困奋",
  [":kunfen"] = "锁定技，结束阶段开始时，你失去1点体力，然后摸两张牌。",
  ["fengliang"] = "逢亮",
  [":fengliang"] = "觉醒技，当你进入濒死状态时，你减1点体力上限并将体力值回复至2点，然后获得技能〖挑衅〗，将技能〖困奋〗改为非锁定技。",
}

Fk:loadTranslationTable{
  ["jsp__zhaoyun"] = "赵云",
  ["chixin"] = "赤心",
  [":chixin"] = "你可以将♦牌当【杀】或【闪】使用或打出。出牌阶段，你对你攻击范围内的每名角色均可使用一张【杀】。",
  ["suiren"] = "随仁",
  [":suiren"] = "限定技，准备阶段开始时，你可以失去技能〖义从〗，然后加1点体力上限并回复1点体力，再令一名角色摸三张牌。",
}

Fk:loadTranslationTable{
  ["jsp__huangyueying"] = "黄月英",
  ["jiqiao"] = "机巧",
  [":jiqiao"] = "出牌阶段开始时，你可以弃置任意张装备牌，然后亮出牌堆顶两倍数量的牌，你获得其中的锦囊牌，将其余的牌置入弃牌堆。",
  ["linglong"] = "玲珑",
  [":linglong"] = "锁定技，若你的装备区没有防具牌，视为你装备着【八卦阵】；若你的装备区没有坐骑牌，你的手牌上限+1；若你的装备区没有宝物牌，视为你拥有技能〖奇才〗。",
}

return extension
