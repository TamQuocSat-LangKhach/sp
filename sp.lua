local extension = Package("sp")
extension.extensionName = "sp"

Fk:loadTranslationTable{
  ["sp"] = "SP",
}

local yangxiu = General(extension, "yangxiu", "wei", 3)
local danlao = fk.CreateTriggerSkill{
  name = "danlao",
  anim_type = "defensive",
  events = {fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.card.type == Card.TypeTrick and #AimGroup:getAllTargets(data.tos) > 1
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
    table.insertIfNeed(data.nullifiedTargets, player.id)
  end,
}
local jilei = fk.CreateTriggerSkill{
  name = "jilei",
  anim_type = "masochism",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.from and not data.from.dead
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = room:askForChoice(player, {"basic", "trick", "equip"}, self.name)
    local types = data.from:getMark("@jilei-turn")
    if types == 0 then types = {} end
    table.insertIfNeed(types, choice)
    room:setPlayerMark(data.from, "@jilei-turn", types)
  end,
}
local jilei_prohibit = fk.CreateProhibitSkill{
  name = "#jilei_prohibit",
  prohibit_use = function(self, player, card)
    if player:getMark("@jilei-turn") ~= 0 then
      return table.contains(player:getMark("@jilei-turn"), card:getTypeString())
    end
  end,
  prohibit_response = function(self, player, card)
    if player:getMark("@jilei-turn") ~= 0 then
      return table.contains(player:getMark("@jilei-turn"), card:getTypeString())
    end
  end,
  prohibit_discard = function(self, player, card)
    if player:getMark("@jilei-turn") ~= 0 then
      return table.contains(player:getMark("@jilei-turn"), card:getTypeString())
    end
  end,
}
jilei:addRelatedSkill(jilei_prohibit)
yangxiu:addSkill(danlao)
yangxiu:addSkill(jilei)
Fk:loadTranslationTable{
  ["yangxiu"] = "杨修",
  ["danlao"] = "啖酪",
  [":danlao"] = "当一个锦囊指定了包括你在内的多个目标，你可以摸一张牌，若如此做，该锦囊对你无效。",
  ["jilei"] = "鸡肋",
  [":jilei"] = "当你受到伤害后，你可以声明一种牌的类别（基本牌、锦囊牌、装备牌），对你造成伤害的角色不能使用、打出或弃置该类别的手牌直到回合结束。",
  ["@jilei-turn"] = "鸡肋",
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

local yuanshu = General(extension, "yuanshu", "qun", 4)
local yongsi = fk.CreateTriggerSkill{
  name = "yongsi",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.DrawNCards, fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self.name) then
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
      if #player.player_cards[Player.Hand] + #player.player_cards[Player.Equip] <= #kingdoms then
        player:throwAllCards("he")
      else
        player.room:askForDiscard(player, #kingdoms, #kingdoms, true, self.name, false, ".", "#yongsi-discard:::"..#kingdoms)
      end
    end
  end,
}
yuanshu:addSkill(yongsi)
Fk:loadTranslationTable{
  ["yuanshu"] = "袁术",
  ["yongsi"] = "庸肆",
  [":yongsi"] = "锁定技，摸牌阶段，你额外摸X张牌，X为场上现存势力数。弃牌阶段，你至少须弃掉等同于场上现存势力数的牌（不足则全弃）。",
  ["weidi"] = "伪帝",
  [":weidi"] = "锁定技，你拥有当前主公的主公技。",
  ["#yongsi-discard"] = "庸肆：你需弃掉等同于场上现存势力数的牌（%arg张）",
}

local pangde = General(extension, "sp__pangde", "wei", 4)
local juesi = fk.CreateActiveSkill{
  name = "juesi",
  anim_type = "offensive",
  card_num = 1,
  target_num = 1,
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
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:throwCard(effect.cards, self.name, player, player)
    local card = Fk:getCardById(room:askForDiscard(target, 1, 1, true, self.name, false, ".", "#juesi-discard:"..player.id)[1])
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
  [":juesi"] = "出牌阶段，你可以弃置一张【杀】并选择攻击范围内的一名其他角色，然后令该角色弃置一张牌。"..
  "若该角色弃置的牌不为【杀】且其体力值不小于你，你视为对其使用一张【决斗】。",
  ["#juesi-discard"] = "决死：你需弃置一张牌，若不为【杀】且你体力值不小于 %src，视为其对你使用【决斗】",
}

local caiwenji = General(extension, "sp__caiwenji", "wei", 3, 3, General.Female)
local chenqing = fk.CreateTriggerSkill{
  name = "chenqing",
  anim_type = "support",
  events = {fk.EnterDying},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and player:usedSkillTimes(self.name, Player.HistoryRound) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if p ~= target then
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
    local n = to:getCardIds{Player.Hand, Player.Equip}
    if n < 4 then
      to:throwAllCards("he")  --清俭
      return
    end
    local cards = room:askForDiscard(to, 4, 4, true, self.name, false, ".", "#chenqing-discard")
    local suits = {}
    for _, id in ipairs(cards) do
      table.insertIfNeed(suits, Fk:getCardById(id).suit)
    end
    if #suits == 4 then
      room:useVirtualCard("peach", nil, to, target, self.name)
    end
  end,
}
local mozhi = fk.CreateViewAsSkill{
  name = "mozhi",
  interaction = function()
    return UI.ComboBox {choices = {Self:getMark("mozhi-turn")[1]}}
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
  end,
  view_as = function(self, cards)
    if #cards ~= 1 or not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcard(cards[1])
    card.skillName = self.name
    return card
  end,
  enabled_at_play = function(self, player)
    return false
  end,
  enabled_at_response = function(self, player)
    return player:getMark("mozhi-turn") ~= 0 and not player:isKongcheng()
  end,
}
local mozhi_record = fk.CreateTriggerSkill{
  name = "#mozhi_record",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Finish and
      player:getMark("mozhi-turn") ~= 0 and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local name = player:getMark("mozhi-turn")[1]
    if name == "jink" or name == "nullification" or (name == "peach" and not player:isWounded()) then return end
    local success, dat = player.room:askForUseViewAsSkill(player, "mozhi", "#mozhi-invoke:::"..name, true)
    if success then
      self.cost_data = dat
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = Fk.skills["mozhi"]:viewAs(self.cost_data.cards)
    local mark = player:getMark("mozhi-turn")
    table.remove(mark, 1)
    if #mark == 0 then
      room:setPlayerMark(player, "mozhi-turn", 0)
    else
      room:setPlayerMark(player, "mozhi-turn", mark)
    end
    room:useCard{
      from = player.id,
      tos = table.map(self.cost_data.targets, function(id) return {id} end),
      card = card,
    }
    if player.dead or player:getMark("mozhi-turn") == 0 then return end
    local name = player:getMark("mozhi-turn")[1]
    if name == "jink" or name == "nullification" or (name == "peach" and not player:isWounded()) then return end
    local success, dat = player.room:askForUseViewAsSkill(player, "mozhi", "#mozhi-invoke:::"..name, true)
    if success then
      local card = Fk.skills["mozhi"]:viewAs(dat.cards)
      room:useCard{
        from = player.id,
        tos = table.map(dat.targets, function(id) return {id} end),
        card = card,
      }
    end
  end,

  refresh_events = {fk.AfterCardUseDeclared},
  can_refresh = function(self, event, target, player, data)
    return target == player and player.phase == Player.Play and
      data.card.type == Card.TypeBasic or (data.card.type == Card.TypeTrick and data.card.sub_type ~= Card.SubtypeDelayedTrick)
  end,
  on_refresh = function(self, event, target, player, data)
    local mark = player:getMark("mozhi-turn")
    if mark == 0 then mark = {} end
    if #mark < 2 then
      table.insert(mark, data.card.name)
    end
    player.room:setPlayerMark(player, "mozhi-turn", mark)
  end,
}
mozhi:addRelatedSkill(mozhi_record)
caiwenji:addSkill(chenqing)
caiwenji:addSkill(mozhi)
Fk:loadTranslationTable{
  ["sp__caiwenji"] = "蔡文姬",
  ["chenqing"] = "陈情",
  [":chenqing"] = "每轮限一次，当一名角色进入濒死状态时，你可以令另一名其他角色摸四张牌，然后弃置四张牌，"..
  "若其以此法弃置的牌花色各不相同，则其视为对濒死状态的角色使用一张【桃】。",
  ["mozhi"] = "默识",
  [":mozhi"] = "结束阶段，你可以将一张手牌当你本回合出牌阶段使用过的第一张基本牌或非延时锦囊牌使用，"..
  "然后你可以将一张手牌当你本回合出牌阶段使用过的第二张基本牌或非延时锦囊牌使用。",
  ["#chenqing-choose"] = "陈情：令一名其他角色摸四张牌然后弃四张牌，若花色各不相同视为对濒死角色使用【桃】",
  ["#chenqing-discard"] = "陈情：需弃置四张牌，若花色各不相同则视为对濒死角色使用【桃】",
  ["#mozhi_record"] = "默识",
  ["#mozhi-invoke"] = "默识：你可以将一张手牌当【%arg】使用",
}

local machao = General(extension, "sp__machao", "qun", 4)
local shichou = fk.CreateTargetModSkill{
  name = "shichou",
  extra_target_func = function(self, player, skill)
    if player:hasSkill(self.name) and skill.trueName == "slash_skill" then
      return player:getLostHp()
    end
    return 0
  end,
}
machao:addSkill("zhuiji")
machao:addSkill(shichou)
Fk:loadTranslationTable{
  ["sp__machao"] = "马超",
  ["shichou"] = "誓仇",
  [":shichou"] = "你使用【杀】可以额外选择至多X名角色为目标（X为你已损失的体力值）。",
}

local jiaxu = General(extension, "sp__jiaxu", "wei", 3)
local zhenlve = fk.CreateTriggerSkill{
  name = "zhenlve",
  anim_type = "control",
  events = {fk.AfterCardUseDeclared},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
      data.card.type == Card.TypeTrick and data.card.sub_type ~= Card.SubtypeDelayedTrick
  end,
  on_use = function(self, event, target, player, data)
    data.prohibitedCardNames = {"nullification"}
  end,
}
local zhenlve_prohibit = fk.CreateProhibitSkill{
  name = "#zhenlve_prohibit",
  is_prohibited = function(self, from, to, card)
    return to:hasSkill(self.name) and card.sub_type == Card.SubtypeDelayedTrick
  end,
}
local jianshu = fk.CreateActiveSkill{
  name = "jianshu",
  anim_type = "control",
  card_num = 1,
  target_num = 1,
  frequency = Skill.Limited,
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
      if not p:isKongcheng() and p:inMyAttackRange(target) then
        table.insert(targets, p.id)
      end
    end
    if #targets == 0 then return end
    local to = room:askForChoosePlayers(player, targets, 1, 1, "#jianshu-choose", self.name)
    if #to == 0 then
      to = room:getPlayerById(table.random(targets))
    else
      to = room:getPlayerById(to[1])
    end
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
    return target == player and target:hasSkill(self.name) and player:usedSkillTimes(self.name, Player.HistoryGame) == 0 and
      not table.every(player.room:getOtherPlayers(player), function (p) return not p.gender == General.Male end)
  end,
  on_cost = function(self, event, target, player, data)
    local to = player.room:askForChoosePlayers(player, table.map(table.filter(player.room:getOtherPlayers(player), function(p)
      return p.gender == General.Male end), function(p) return p.id end), 1, 1, "#yongdi-choose", self.name)
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
    end
  end,
}
zhenlve:addRelatedSkill(zhenlve_prohibit)
jiaxu:addSkill(zhenlve)
jiaxu:addSkill(jianshu)
jiaxu:addSkill(yongdi)
jiaxu:addSkill("cheat")
Fk:loadTranslationTable{
  ["sp__jiaxu"] = "贾诩",
  ["zhenlve"] = "缜略",
  [":zhenlve"] = "锁定技，你使用的非延时锦囊牌不能被【无懈可击】响应，你不能被选择为延时锦囊牌的目标。",
  ["jianshu"] = "间书",
  [":jianshu"] = "限定技，出牌阶段，你可以将一张黑色手牌交给一名其他角色，并选择一名攻击范围内含有其的另一名角色。"..
  "然后令这两名角色拼点：赢的角色弃置两张牌，没赢的角色失去1点体力。",
  ["yongdi"] = "拥嫡",
  [":yongdi"] = "限定技，当你受到伤害后，你可令一名其他男性角色增加1点体力上限，然后若该角色的武将牌上有主公技且其身份不为主公，其获得此主公技。",
  ["#jianshu-choose"] = "间书：选择一名攻击范围内含有其的角色，两名角色拼点",
  ["#yongdi-choose"] = "拥嫡：你可令一名其他男性角色增加1点体力上限并获得其武将牌上的主公技",
}

local caohong = General(extension, "caohong", "wei", 4)
local yuanhu_active = fk.CreateActiveSkill{
  name = "#yuanhu_active",
  anim_type = "support",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return not player:isNude()
  end,
  card_filter = function(self, to_select, selected, targets)
    return #selected == 0 and Fk:getCardById(to_select).type == Card.TypeEquip
  end,
  target_filter = function(self, to_select, selected, cards)
    return #selected == 0 and #cards == 1 and Fk:currentRoom():getPlayerById(to_select):getEquipment(Fk:getCardById(cards[1]).sub_type) == nil
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:moveCards({
      ids = effect.cards,
      from = player.id,
      to = target.id,
      toArea = Card.PlayerEquip,
      moveReason = fk.ReasonPut,
    })
    local card = Fk:getCardById(effect.cards[1])
    if card.sub_type == Card.SubtypeWeapon then
      local targets = {}
      for _, p in ipairs(room:getOtherPlayers(target)) do
        if target:distanceTo(p) == 1 and not p:isAllNude() then
          table.insertIfNeed(targets, p.id)
        end
      end
      local to = room:askForChoosePlayers(player, targets, 1, 1, "#yuanhu-choose::"..target.id, self.name, false)
      if #to > 0 then
        local card = room:askForCardChosen(player, room:getPlayerById(to[1]), "hej", self.name)
        room:throwCard({card}, self.name, room:getPlayerById(to[1]), player)
      end
    elseif card.sub_type == Card.SubtypeArmor then
      target:drawCards(1, self.name)
    elseif card.sub_type == Card.SubtypeOffensiveRide or card.sub_type == Card.SubtypeDefensiveRide then
      if target:isWounded() then
        room:recover({
          who = target,
          num = 1,
          recoverBy = player,
          skillName = self.name
        })
      end
    end
  end,
}
local yuanhu = fk.CreateTriggerSkill{
  name = "yuanhu",
  anim_type = "support",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Finish
  end,
  on_cost = function(self, event, target, player, data)
    player.room:askForUseActiveSkill(player, "#yuanhu_active", "#yuanhu-invoke", true)
  end,
}
Fk:addSkill(yuanhu_active)
caohong:addSkill(yuanhu)
Fk:loadTranslationTable{
  ["caohong"] = "曹洪",
  ["yuanhu"] = "援护",
  [":yuanhu"] = "回合结束阶段开始时，你可以将一张装备牌置于一名角色的装备区里，然后根据此装备牌的种类执行以下效果：<br>"..
  "武器牌：弃置与该角色距离为1的一名角色区域中的一张牌；<br>防具牌：该角色摸一张牌；<br>坐骑牌：该角色回复1点体力。",
  ["#yuanhu_active"] = "援护",
  ["#yuanhu-invoke"] = "援护：你可以将一张装备牌置入一名角色的装备区",
  ["#yuanhu-choose"] = "援护：弃置 %dest 距离1的一名角色区域中的一张牌",
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
  can_use = function(self, player)
    return player:isWounded() and player:usedSkillTimes(self.name) == 0 and not player:isNude()
  end,
  card_filter = function(self, to_select, selected, targets)
    return #selected == 0 and Fk:getCardById(to_select).color == Card.Red  --TODO: throw the weapon
  end,
  target_filter = function(self, to_select, selected, cards)
    return #selected < Self:getLostHp() and Self:inMyAttackRange(Fk:currentRoom():getPlayerById(to_select))
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:throwCard(effect.cards, self.name, player, player)
    for _, p in ipairs(effect.tos) do
      room:damage{
        from = player,
        to = room:getPlayerById(p),
        damage = 1,
        skillName = self.name,
      }
    end
    for _, p in ipairs(effect.tos) do
      if not room:getPlayerById(p).dead then
        room:getPlayerById(p):drawCards(1)
      end
    end
  end,
}
local huxiao = fk.CreateTriggerSkill{
  name = "huxiao",
  anim_type = "offensive",
  events = {fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self.name) and player.phase == Player.Play then
      if data.card.name == "jink" and data.toCard and data.toCard.trueName == "slash" then
        return data.responseToEvent.from == player.id
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    player:addCardUseHistory(data.toCard.trueName, -1)
  end,
}
local wuji = fk.CreateTriggerSkill{
  name = "wuji",
  anim_type = "special",
  events = {fk.EventPhaseStart},
  frequency = Skill.Wake,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
      player.phase == Player.Finish and
      player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player, data)
    return player:getMark("wuji-turn") > 2
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
    room:handleAddLoseSkills(player, "-huxiao", nil)
  end,

  refresh_events = {fk.Damage},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name, true) and player:getMark(self.name) == 0 and player.phase ~= Player.NotActive
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "wuji-turn", data.damage)
  end,
}
guanyinping:addSkill(xueji)
guanyinping:addSkill(huxiao)
guanyinping:addSkill(wuji)
Fk:loadTranslationTable{
  ["guanyinping"] = "关银屏",
  ["xueji"] = "血祭",
  [":xueji"] = "出牌阶段，你可弃置一张红色牌，并对你攻击范围内的至多X名其他角色各造成1点伤害，然后这些角色各摸一张牌。X为你损失的体力值。每阶段限一次。",
  ["huxiao"] = "虎啸",
  [":huxiao"] = "若你于出牌阶段使用的【杀】被【闪】抵消，则本阶段你可以额外使用一张【杀】。",
  ["wuji"] = "武继",
  [":wuji"] = "觉醒技，回合结束阶段开始时，若本回合你已造成3点或更多伤害，你须加1点体力上限并回复1点体力，然后失去技能“虎啸”。",
}

local liuxie = General(extension, "liuxie", "qun", 3)
local tianming = fk.CreateTriggerSkill{
  name = "tianming",
  anim_type = "defensive",
  events = {fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.card.trueName == "slash"
  end,
  on_cost = function(self, event, target, player, data)
    if player:isNude() then
      return player.room:askForSkillInvoke(player, self.name, data, "#tianming-cost")
    else
      local cards = player.room:askForDiscard(player, math.min(2, #player:getCardIds{Player.Hand, Player.Equip}), 2,
        true, self.name, true, ".", "#tianming-cost")
      if #cards >= math.min(2, #player:getCardIds{Player.Hand, Player.Equip}) then
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(2)
    local n = player.hp
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if p.hp > n then
        n = p.hp
      end
    end
    local tos = {}
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if p.hp == n then
        table.insert(tos, p)
      end
    end
    if #tos > 1 then return end
    local to = tos[1]
    if to:isNude() then
      if room:askForSkillInvoke(to, self.name, data, "#tianming-cost") then
        to:drawCards(2)
      end
    else
      local cards = room:askForDiscard(to, math.min(2, #to:getCardIds{Player.Hand, Player.Equip}), 2,
        true, self.name, true, ".", "#tianming-cost")
      if #cards >= math.min(2, #to:getCardIds{Player.Hand, Player.Equip}) then
        to:drawCards(2)
      end
    end
  end,
}
local mizhao = fk.CreateActiveSkill{
  name = "mizhao",
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return not player:isKongcheng() and player:usedSkillTimes(self.name) == 0
  end,
  card_filter = function(self, to_select, selected)
    return false
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local dummy = Fk:cloneCard("dilu")
    dummy:addSubcards(player.player_cards[Player.Hand])
    room:obtainCard(target.id, dummy, false, fk.ReasonGive)
    local targets = {}
    for _, p in ipairs(room:getOtherPlayers(target)) do
      if not p:isKongcheng() and p ~= player then
        table.insert(targets, p.id)
      end
    end
    if #targets == 0 then return end
    local to = room:askForChoosePlayers(player, targets, 1, 1, "#mizhao-choose::"..target.id, self.name)
    if #to == 0 then
      to = room:getPlayerById(table.random(targets))
    else
      to = room:getPlayerById(to[1])
    end
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
      room:useVirtualCard("slash", nil, winner, {loser}, self.name)
    end
  end
}
liuxie:addSkill(tianming)
liuxie:addSkill(mizhao)
Fk:loadTranslationTable{
  ["liuxie"] = "刘协",
  ["tianming"] = "天命",
  [":tianming"] = "当你成为【杀】的目标时，你可以弃置两张牌（不足则全弃，无牌则不弃），然后摸两张牌；"..
  "若此时全场体力值最多的角色仅有一名（且不是你），该角色也可以如此做。",
  ["mizhao"] = "密诏",
  [":mizhao"] = "出牌阶段，你可以将所有手牌（至少一张）交给一名其他角色。若如此做，你令该角色与你指定的另一名有手牌的角色拼点，"..
  "视为拼点赢的角色对没赢的角色使用一张【杀】。（每阶段限一次。）",
  ["#tianming-cost"] = "天命：你可以弃置两张牌（不足则全弃，无牌则不弃），然后摸两张牌",
  ["#mizhao-choose"] = "密诏：选择与 %dest 拼点的角色，赢者视为对没赢者使用【杀】",
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
    local pattern, prompt
    if event == fk.DamageCaused then
      pattern = ".|.|spade,club|.|.|."
      prompt = "#jieyuan1-invoke::"..data.from.id
    else
      pattern = ".|.|heart,diamond|.|.|."
      prompt = "#jieyuan2-invoke"
    end
    return #player.room:askForDiscard(player, 1, 1, false, self.name, true, pattern, prompt) > 0
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
  frequency = Skill.Limited,
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
  [":jieyuan"] = "当你对一名其他角色造成伤害时，若其体力值大于或等于你的体力值，你可弃置一张黑色手牌令此伤害+1；"..
  "当你受到一名其他角色造成的伤害时，若其体力值大于或等于你的体力值，你可弃置一张红色手牌令此伤害-1。",
  ["fenxin"] = "焚心",
  [":fenxin"] = "限定技，当你杀死一名非主公角色时，在其翻开身份牌之前，你可以与该角色交换身份牌。（你的身份为主公时不能发动此技能。）",
  ["#jieyuan1-invoke"] = "竭缘：你可以弃置一张黑色手牌令对 %dest 造成的伤害+1",
  ["#jieyuan2-invoke"] = "竭缘：你可以弃置一张红色手牌令此伤害-1",
}

local fuwan = General(extension, "fuwan", "qun", 4)
local moukui = fk.CreateTriggerSkill{
  name = "moukui",
  anim_type = "offensive",
  events = {fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.firstTarget and data.card.trueName == "slash"
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(data.to)
    local choices = {"draw1"}
    if not to:isNude() then
      table.insert(choices, "moukui_discard")
    end
    local choice = room:askForChoice(player, choices, self.name)
    if choice == "draw1" then
      player:drawCards(1, self.name)
    else
      local id = room:askForCardChosen(player, to, "he", self.name)
      room:throwCard({id}, self.name, to, player)
    end
    data.card.extra_data = {self.name, data.to}
  end,

  refresh_events = {fk.CardUseFinished},
  can_refresh = function(self, event, target, player, data)
    if player:hasSkill(self.name) and data.card.name == "jink" and data.responseToEvent.from == player.id then
      if data.toCard.extra_data and data.toCard.extra_data[1] == self.name and data.toCard.extra_data[2] == target.id then
        return not player:isNude()
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(target.id, {player.id})
    local id = room:askForCardChosen(target, player, "he", self.name)
    room:throwCard({id}, self.name, player, target)
  end,
}
fuwan:addSkill(moukui)
Fk:loadTranslationTable{
  ["fuwan"] = "伏完",
  ["moukui"] = "谋溃",
  [":moukui"] = "当你使用【杀】指定一名角色为目标后，你可以选择一项：摸一张牌，或弃置其一张牌。若如此做，此【杀】被【闪】抵消时，该角色弃置你的一张牌。",
  ["moukui_discard"] = "弃置其一张牌",
}

local xiahouba = General(extension, "xiahouba", "shu", 4)
local function BaobianChange(player, hp, skill_name)
  local room = player.room
	local skills = player.tag["baobian"]
  if type(skills) ~= "table" then skills = {} end
	if player.hp <= hp then
		if not table.contains(skills, skill_name) then
			if player.hp == hp then
				--room:broadcastSkillInvoke("baobian", 4 - hp)  FIXME: no audio yet
			end
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
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name)
  end,
  on_trigger = function(self, event, target, player, data)
    BaobianChange(player, 1, "shensu")
    BaobianChange(player, 2, "paoxiao")
    BaobianChange(player, 3, "tiaoxin")
  end,
}
xiahouba:addSkill(baobian)
xiahouba:addRelatedSkill("tiaoxin")
xiahouba:addRelatedSkill("paoxiao")
xiahouba:addRelatedSkill("shensu")
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
    local tos, id = player.room:askForChooseCardAndPlayers(player, self.bifa_tos, 1, 1, ".|.|.|hand|.|.", "#bifa-cost", self.name, true)
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
    return player:hasSkill(self.name, true, true) and target.phase == Player.Start and #target:getPile(self.name) > 0
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
      target:removeCards(Player.Special, player:getPile(self.name), self.name)
      return
    end
    local type = Fk:getCardById(target:getPile(self.name)[1]):getTypeString()
    local card = room:askForCard(target, 1, 1, false, self.name, true, ".|.|.|hand|.|"..type, "#bifa-invoke:::"..type)
    if #card > 0 then
      room:obtainCard(player.id, Fk:getCardById(card[1]), false, fk.ReasonGive)
      room:obtainCard(target.id, target:getPile(self.name)[1], true, fk.ReasonPrey)
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
      target:removeCards(Player.Special, player:getPile(self.name), self.name)
    end
  end,
}
local songci = fk.CreateActiveSkill{
  name = "songci",
  anim_type = "control",
  mute = true,
  card_num = 0,
  target_num = 1,
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
  on_use = function(self, room, effect)
    local target = room:getPlayerById(effect.tos[1])
    room:addPlayerMark(target, self.name)
    if #target.player_cards[Player.Hand] < target.hp then
      target:drawCards(2)
      room:broadcastSkillInvoke(self.name, 1)
    else
      room:askForDiscard(target, 2, 2, true, self.name, false)
      room:broadcastSkillInvoke(self.name, 2)
    end
  end,
}
chenlin:addSkill(bifa)
chenlin:addSkill(songci)
Fk:loadTranslationTable{
  ["chenlin"] = "陈琳",
  ["bifa"] = "笔伐",
  [":bifa"] = "回合结束阶段开始时，你可以将一张手牌移出游戏并指定一名其他角色。该角色的回合开始时，其观看你移出游戏的牌并选择一项："..
  "交给你一张与此牌同类型的手牌并获得此牌；或将此牌置入弃牌堆，然后失去1点体力。",
  ["songci"] = "颂词",
  [":songci"] = "出牌阶段，你可以选择一项：令一名手牌数小于其体力值的角色摸两张牌；或令一名手牌数大于其体力值的角色弃置两张牌。此技能对每名角色只能用一次。",
  ["#bifa-cost"] = "笔伐：将一张手牌移出游戏并指定一名其他角色",
  ["#bifa-invoke"] = "笔伐：交出一张%arg手牌并获得此牌；或点“取消”将此牌置入弃牌堆并失去1点体力",
}

local daqiaoxiaoqiao = General(extension, "daqiaoxiaoqiao", "wu", 3, 3, General.Female)
local xingwu = fk.CreateTriggerSkill{
  name = "xingwu",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Discard and not player:isKongcheng()
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
    player:addToPile(self.name, self.cost_data, false, self.name)
    if #player:getPile(self.name) >= 3 then
      room:moveCards({
        from = player.id,
        ids = player:getPile(self.name),
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonPutIntoDiscardPile,
        skillName = self.name,
      })
      player:removeCards(Player.Special, player:getPile(self.name), self.name)
      local targets = {}
      for _, p in ipairs(room:getOtherPlayers(player)) do
        if p.gender == General.Male then
          table.insertIfNeed(targets, p.id)
        end
      end
      if #targets > 0 then
        local to = room:askForChoosePlayers(player, targets, 1, 1, "#xingwu-choose", self.name, false)
        local victim
        if #to > 0 then
          victim = room:getPlayerById(to[1])
        else
          victim = room:getPlayerById(targets[math.random(1, #targets)])
        end
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
    return player:hasSkill(self.name, true) and target == player and player.phase ~= Player.NotActive
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
    if player:hasSkill(self.name, true) and player.phase == Player.Discard then
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
  ["xingwu"] = "星舞",
  [":xingwu"] = "弃牌阶段开始时，你可以将一张与你本回合使用的牌颜色均不同的手牌置于武将牌上。"..
  "若此时你武将牌上的牌达到三张，则弃置这些牌，然后对一名男性角色造成2点伤害并弃置其装备区中的所有牌。",
  ["luoyan"] = "落雁",
  [":luoyan"] = "锁定技，若你的武将牌上有牌，你视为拥有技能“天香”和“流离”。",
  ["#xingwu-cost"] = "星舞：你可以将一张与你本回合使用的牌颜色均不同的手牌置为“星舞”牌",
  ["#xingwu-choose"] = "星舞：对一名男性角色造成2点伤害并弃置其装备区所有牌",
}

local xiahoushi = General(extension, "sp__xiahoushi", "shu", 3, 3, General.Female)
local sp__yanyu = fk.CreateTriggerSkill{
  name = "sp__yanyu",
  anim_type = "support",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and target.phase == Player.Play and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askForDiscard(player, 1, 1, false, self.name, true, ".", "#yanyu-cost")
    if #card > 0 then
      self.yanyu_type = Fk:getCardById(card[1]):getTypeString()
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@yanyu", self.yanyu_type)
  end,

  refresh_events = {fk.EventPhaseEnd},
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(self.name) and player:getMark("@yanyu") ~= 0 and target.phase >= Player.Play
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@yanyu", 0)
  end,
}
local yanyu_give = fk.CreateTriggerSkill{
  name = "#yanyu_give",
  anim_type = "support",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self.name) and player:getMark("@yanyu") ~= nil and player:usedSkillTimes(self.name) < 3 then
      local room = player.room
      if room.current.phase ~= Player.Play then return end
      self.yanyu_id = nil
      for _, move in ipairs(data) do
        if move.toArea == Card.DiscardPile and move.skillName ~= "sp__yanyu" then
          for _, info in ipairs(move.moveInfo) do
            if Fk:getCardById(info.cardId):getTypeString() == player:getMark("@yanyu") then
              self.yanyu_id = info.cardId
              return true
            end
          end
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local to = player.room:askForChoosePlayers(player, table.map(player.room:getAlivePlayers(), function(p)
      return p.id end), 1, 1, "#yanyu-choose:::"..Fk:getCardById(self.yanyu_id):toLogString(), self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:obtainCard(self.cost_data, self.yanyu_id, true, fk.ReasonGive)
  end,
}
local xiaode = fk.CreateTriggerSkill{
  name = "xiaode",
  anim_type = "special",
  events ={fk.Deathed},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name)
  end,
  on_cost = function(self, event, target, player, data)
    self.cost_data = {}
    local skills = table.map(Fk.generals[target.general].skills, function(s) return s.name end)
    for _, skill in ipairs(skills) do
      if target:hasSkill(skill, true, true) and skill.frequency ~= Skill.Wake and
        string.sub(skill, #skill, #skill) ~= "$" and not player:hasSkill(skill, true) then
        table.insertIfNeed(self.cost_data, skill)
      end
    end
    return #self.cost_data > 0 and player.room:askForSkillInvoke(player, self.name, nil, "#xiaode-invoke::"..target.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = room:askForChoice(player, self.cost_data, self.name)
    room:handleAddLoseSkills(player, choice.."|-xiaode", nil, true, true)
    player.tag[self.name] = player.tag[self.name] or {}
    table.insertIfNeed(player.tag[self.name], choice)
  end,

  refresh_events ={fk.TurnEnd},
  can_refresh = function(self, event, target, player, data)
    return target == player and player.tag[self.name] and #player.tag[self.name] > 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local names = self.name
    for _, skill in ipairs(player.tag[self.name]) do
      if player:hasSkill(skill, true) then
        names = names.."|-"..skill
      end
    end
    room:handleAddLoseSkills(player, names, nil, true, false)
  end,
}
sp__yanyu:addRelatedSkill(yanyu_give)
xiahoushi:addSkill(sp__yanyu)
xiahoushi:addSkill(xiaode)
Fk:loadTranslationTable{
  ["sp__xiahoushi"] = "夏侯氏",
  ["sp__yanyu"] = "燕语",
  [":sp__yanyu"] = "任意一名角色的出牌阶段开始时，你可以弃置一张牌，若如此做，则本回合的出牌阶段，每当有与你弃置牌类别相同的其他牌进入弃牌堆时，"..
  "你可令任意一名角色获得此牌。每回合以此法获得的牌不能超过三张。",
  ["xiaode"] = "孝德",
  [":xiaode"] = "每当有其他角色阵亡后，你可以声明该武将牌的一项技能，若如此做，你获得此技能并失去技能〖孝德〗直到你的回合结束。（你不能声明觉醒技或主公技）",
  ["@yanyu"] = "燕语",
  ["#yanyu_give"] = "燕语",
  ["#yanyu-cost"] = "燕语：你可以弃置一张牌，然后此出牌阶段限三次，可令任意角色获得相同类别进入弃牌堆的牌",
  ["#yanyu-choose"] = "燕语：你可令任意一名角色获得%arg",
  ["#xiaode-invoke"] = "孝德：你可以获得 %dest 武将牌上的一个技能直到你的回合结束",
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
    return #player.room:askForDiscard(player, 1, 1, false, self.name, true, ".|.|.|.|.|basic", "#xiaoguo-invoke::"..target.id) > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if #room:askForDiscard(target, 1, 1, true, self.name, true, ".|.|.|.|.|equip", "#xiaoguo-discard:"..player.id) > 0 then
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
  ["#xiaoguo-invoke"] = "骁果：你可以弃置一张基本牌，%dest 需弃置一张装备牌并令你摸一张牌，否则你对其造成1点伤害",
  ["#xiaoguo-discard"] = "骁果：你需弃置一张装备牌并令 %src 摸一张牌，否则其对你造成1点伤害",
}

local zhangbao = General(extension, "zhangbao", "qun", 3)
local zhoufu = fk.CreateActiveSkill{
  name = "zhoufu",
  anim_type = "control",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name) == 0 and not player:isKongcheng()
  end,
  card_filter = function(self, to_select, selected, targets)
    return #selected == 0 and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
  end,
  target_filter = function(self, to_select, selected, cards)
    return #selected == 0 and to_select ~= Self.id and #Fk:currentRoom():getPlayerById(to_select):getPile("zhangbao_zhou") == 0
  end,
  on_use = function(self, room, effect)
    local target = room:getPlayerById(effect.tos[1])
    target:addToPile("zhangbao_zhou", effect.cards, false, self.name)
  end,
}
local zhoufu_trigger = fk.CreateTriggerSkill{
  name = "#zhoufu_trigger",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return #target:getPile("zhangbao_zhou") > 0 and player:hasSkill(self.name) and target.phase == Player.NotActive
  end,
  on_cost = function(self, event, target, player, data)
    return true
  end,
  on_use = function(self, event, target, player, data)
    target:removeCards(Player.Special, target:getPile("zhangbao_zhou"), "zhoufu")
    player.room:moveCards({
      from = target.id,
      ids = target:getPile("zhangbao_zhou"),
      to = player.id,
      toArea = Card.PlayerHand,
      moveReason = fk.ReasonJustMove,
      skillName = "zhoufu",
    })
  end,

  refresh_events = {fk.StartJudge},
  can_refresh = function(self, event, target, player, data)
    return #target:getPile("zhangbao_zhou") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    data.card = Fk:getCardById(target:getPile("zhangbao_zhou")[1])
    data.card.skillName = "zhoufu"
  end,
}
local yingbing = fk.CreateTriggerSkill{
  name = "yingbing",
  anim_type = "drawcard",
  events = {fk.AskForRetrial},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and data.card.skillName == "zhoufu"
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
  ["zhoufu"] = "咒缚",
  [":zhoufu"] = "出牌阶段限一次，你可以指定一名其他角色并将一张手牌移出游戏（将此牌置于该角色的武将牌旁），"..
  "若如此做，该角色进行判定时，改为将此牌作为判定牌。该角色的回合结束时，若此牌仍在该角色旁，你将此牌收入手牌。",
  ["yingbing"] = "影兵",
  [":yingbing"] = "受到“咒缚”技能影响的角色进行判定时，你可以摸两张牌。",
  ["zhangbao_zhou"] = "咒",
  ["#zhoufu_trigger"] = "咒缚",
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
    local cards = room:askForCard(player, 1, 1, true, self.name, false, ".", "#kangkai-give::"..to.id)
    if #cards > 0 then
      local card = Fk:getCardById(cards[1])
      room:obtainCard(to.id, card, true, fk.ReasonGive)
      if card.type == Card.TypeEquip and room:askForSkillInvoke(to, self.name, data, "#kangkai-use:::"..card:toLogString()) then
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
  [":kangkai"] = "每当一名角色成为【杀】的目标后，若你与其的距离不大于1，你可以摸一张牌，若如此做，你先将一张牌交给该角色再令其展示之，"..
  "若此牌为装备牌，其可以使用之。",
  ["#kangkai-give"] = "慷忾：选择一张牌交给 %dest",
  ["#kangkai-use"] = "慷忾：你可以使用%arg",
}

local zhugejin = General(extension, "zhugejin", "wu", 3)
local huanshi = fk.CreateTriggerSkill{
  name = "huanshi",
  anim_type = "support",
  events = {fk.AskForRetrial},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player,self.name, nil, "#huanshi-invoke::"..target.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:fillAG(target, player.player_cards[Player.Hand])
    local id = room:askForAG(target, player.player_cards[Player.Hand], false, self.name)
    room:closeAG(target)
    room:retrial(Fk:getCardById(id), player, data, self.name)
  end,
}
local hongyuan = fk.CreateTriggerSkill{
  name = "hongyuan",
  anim_type = "support",
  events = {fk.DrawNCards},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.n > 0
  end,
  on_cost = function(self, event, target, player, data)
    local tos = player.room:askForChoosePlayers(player, table.map(player.room:getOtherPlayers(player), function(p) return p.id end), 1, 2, "#hongyuan-cost", self.name, true)
    if #tos > 0 then
      self.cost_data = tos
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    for _, p in ipairs(self.cost_data) do
      player.room:getPlayerById(p):drawCards(1)
    end
    data.n = data.n - 1
  end,
}
local mingzhe = fk.CreateTriggerSkill{
  name = "mingzhe",
  anim_type = "drawcard",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self.name) and player.phase == Player.NotActive then
      self.trigger_times = 0
      for _, move in ipairs(data) do
        if move.from == player.id and (move.moveReason == fk.ReasonUse or move.moveReason == fk.ReasonResonpse or move.moveReason == fk.ReasonDiscard) then
          for _, info in ipairs(move.moveInfo) do
            if Fk:getCardById(info.cardId).color == Card.Red then
              self.trigger_times = self.trigger_times + 1
            end
          end
        end
      end
      return self.trigger_times > 0
    end
  end,
  on_trigger = function(self, event, target, player, data)
    local ret
    for i = 1, self.trigger_times do
      ret = self:doCost(event, target, player, data)
      if ret then return ret end
    end
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
}
zhugejin:addSkill(huanshi)
zhugejin:addSkill(hongyuan)
zhugejin:addSkill(mingzhe)
Fk:loadTranslationTable{
  ["zhugejin"] = "诸葛瑾",
  ["huanshi"] = "缓释",
  [":huanshi"] = "每当一名角色的判定牌生效前，你可以令该角色观看你的手牌并选择你的一张牌，你打出此牌代替之。",
  ["hongyuan"] = "弘援",
  [":hongyuan"] = "摸牌阶段，你可以少摸一张牌，令至多两名其他角色各摸一张牌。",
  ["mingzhe"] = "明哲",
  [":mingzhe"] = "每当你于回合外使用、打出或因弃置而失去一张红色牌时，你可以摸一张牌。",
  ["#huanshi-invoke"] = "缓释：你可以令 %dest 观看你的手牌并打出其中一张牌修改其判定",
  ["#hongyuan-cost"] = "弘援：你可以少摸一张牌，令至多两名其他角色各摸一张牌",
}

local xingcai = General(extension, "xingcai", "shu", 3, 3, General.Female)
local shenxian = fk.CreateTriggerSkill{
  name = "shenxian",
  anim_type = "drawcard",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self.name) and player.phase == Player.NotActive then
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
  can_use = function(self, player)
    return player:usedSkillTimes(self.name) == 0
  end,
  card_filter = function(self, to_select, selected)
    return false
  end,
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
    if target == player and player:hasSkill(self.name) and player:getMark("@qiangwu-turn") > 0 then
      return data.card.trueName == "slash" and data.card.number and data.card.number > player:getMark("@qiangwu-turn")
    end
  end,
  on_refresh = function(self, event, target, player, data)
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
  ["shenxian"] = "甚贤",
  [":shenxian"] = "你的回合外，每当有其他角色因弃置而失去牌时，若其中有基本牌，你可以摸一张牌。",
  ["qiangwu"] = "枪舞",
  [":qiangwu"] = "出牌阶段限一次，你可以进行一次判定，若如此做，则直到回合结束，你使用点数小于判定牌的【杀】时不受距离限制，且你使用点数大于判定牌的【杀】时不计入出牌阶段的使用次数。",
  ["@qiangwu-turn"] = "枪舞",
}

local nos__panfeng = General(extension, "nos__panfeng", "qun", 4)
local nos__kuangfu = fk.CreateTriggerSkill{
  name = "nos__kuangfu",
  anim_type = "offensive",
  events = {fk.Damage},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and not data.chain and data.card and data.card.trueName == "slash" and not data.to.dead and #data.to.player_cards[Player.Equip] > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choices = {"nos__kuangfu_discard"}
    local ids = {}
    for _, e in ipairs(data.to.player_cards[Player.Equip]) do
      if player:getEquipment(Fk:getCardById(e).sub_type) == nil then
        table.insert(ids, e)
      end
    end
    if #ids > 0 then
      table.insert(choices, 1, "nos__kuangfu_move")
    end
    local choice = room:askForChoice(player, choices, self.name)
    if choice == "nos__kuangfu_move" then
      room:fillAG(player, ids)
      local id = room:askForAG(player, ids, true, self.name)
      room:closeAG(player)
      room:moveCards({
        from = data.to.id,
        ids = {id},
        to = player.id,
        toArea = Card.PlayerEquip,
        moveReason = fk.ReasonJustMove,
        proposer = player.id,
        skillName = self.name,
      })
    else
      local id = player.room:askForCardChosen(player, data.to, "e", self.name)
      room:throwCard(id, self.name, data.to, player)
    end
  end
}
nos__panfeng:addSkill(nos__kuangfu)
Fk:loadTranslationTable{
  ["nos__panfeng"] = "潘凤",
  ["nos__kuangfu"] = "狂斧",
  [":nos__kuangfu"] = "每当你使用【杀】对目标角色造成一次伤害后，你可以选择一项: 将其装备区里的一张牌置入你的装备区；或弃置其装备区里的一张牌。",
  ["nos__kuangfu_move"] = "将其一张装备置入你的装备区",
  ["nos__kuangfu_discard"] = "弃置其一张装备",
}

local panfeng = General(extension, "panfeng", "qun", 4)
local kuangfu = fk.CreateActiveSkill{
  name = "kuangfu",
  anim_type = "offensive",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, to_select, selected)
    return false
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and #Fk:currentRoom():getPlayerById(to_select).player_cards[Player.Equip] > 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local id = room:askForCardChosen(player, target, "e", self.name)
    room:throwCard({id}, self.name, target, player)
    local targets = {}
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if not player:isProhibited(p, Fk:cloneCard("slash")) then
        table.insert(targets, p.id)
      end
    end
    if #targets == 0 then return end
    local to = room:askForChoosePlayers(player, targets, 1, 1, "#kuangfu-slash", self.name, false)
    if #to > 0 then
      to = to[1]
    else
      to = table.random(targets)
    end
    room:useVirtualCard("slash", nil, player, room:getPlayerById(to), self.name, true)
    if not player.dead then
      if effect.from == effect.tos[1] and player:getMark("kuangfu-phase") > 0 then
        player:drawCards(2, self.name)
      end
      if effect.from ~= effect.tos[1] and player:getMark("kuangfu-phase") == 0 then
        if #player:getCardIds{Player.Hand, Player.Equip} < 3 then
          player:throwAllCards("he")
        else
          player.room:askForDiscard(player, 2, 2, true, "kuangfu", false)
        end
      end
    end
  end,
}
local kuangfu_record = fk.CreateTriggerSkill{
  name = "#kuangfu_record",

  refresh_events = {fk.Damage},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.card and table.contains(data.card.skillNames, "kuangfu")
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "kuangfu-phase", 1)
  end,
}
kuangfu:addRelatedSkill(kuangfu_record)
panfeng:addSkill(kuangfu)
Fk:loadTranslationTable{
  ["panfeng"] = "潘凤",
  ["kuangfu"] = "狂斧",
  [":kuangfu"] = "出牌阶段限一次，你可以弃置场上的一张装备牌，视为使用一张【杀】（此【杀】无距离限制且不计次数）。若你弃置的不是你的牌且此【杀】未造成伤害，你弃置两张手牌；若弃置的是你的牌且此【杀】造成伤害，你摸两张牌。",
  ["#kuangfu-slash"] = "狂斧：选择视为使用【杀】的目标",
}

local zumao = General(extension, "zumao", "wu", 4)
local yinbing = fk.CreateTriggerSkill{
  name = "yinbing",
  anim_type = "control",
  expand_pile = "yinbing",
  events = {fk.EventPhaseStart, fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self.name) then
      if event == fk.EventPhaseStart then
        return target == player and player.phase == Player.Finish and not player:isNude()
      else
        return target == player and #player:getPile(self.name) > 0 and data.card and (data.card.trueName == "slash" or data.card.name == "duel")
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = {}
    if event == fk.EventPhaseStart then
      cards = room:askForCard(player, 1, 999, true, self.name, true, ".|.|.|.|.|trick,equip", "#yinbing-cost")
    else
      cards = room:askForCard(player, 1, 1, false, self.name, true, ".|.|.|yinbing|.|.", "#yinbing-invoke", "yinbing")
      if #cards == 0 then cards = {player:getPile(self.name)[math.random(1, #player:getPile(self.name))]} end
    end
    if #cards > 0 then
      self.cost_data = cards
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseStart then
      player:addToPile(self.name, self.cost_data, false, self.name)
    else
      room:moveCards({
        from = player.id,
        ids = self.cost_data,
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonPutIntoDiscardPile,
        skillName = self.name,
        specialName = self.name,
      })
      player:removeCards(Player.Special, {self.cost_data}, self.name)
    end
  end,
}
local juedi = fk.CreateTriggerSkill{
  name = "juedi",
  anim_type = "support",
  events = {fk.EventPhaseStart},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Start and #player:getPile("yinbing") > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if player.hp >= p.hp then
        table.insertIfNeed(targets, p.id)
      end
    end
    local to = room:askForChoosePlayers(player, targets, 1, 1, "#juedi-choose", self.name, false)
    if #to > 0 then
      self.cost_data = to[1]
    else
      self.cost_data = player.id
    end
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = #player:getPile("yinbing")
    if self.cost_data == player.id then
      room:moveCards({
        from = player.id,
        ids = player:getPile("yinbing"),
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonPutIntoDiscardPile,
        skillName = self.name,
      })
      player:drawCards(n, self.name)
    else
      local to = room:getPlayerById(self.cost_data)
      local dummy = Fk:cloneCard("dilu")
      dummy:addSubcards(player:getPile("yinbing"))
      room:obtainCard(to.id, dummy, false, fk.ReasonGive)
      if to:isWounded() then
        room:recover({
          who = to,
          num = 1,
          recoverBy = player,
          skillName = self.name
        })
      end
      to:drawCards(n, self.name)
    end
  end,
}
zumao:addSkill(yinbing)
zumao:addSkill(juedi)
Fk:loadTranslationTable{
  ["zumao"] = "祖茂",
  ["yinbing"] = "引兵",
  [":yinbing"] = "结束阶段，你可以将任意张非基本牌置于你的武将牌上，当你受到【杀】或【决斗】造成的伤害后，你移去你武将牌上的一张牌。",
  ["juedi"] = "绝地",
  [":juedi"] = "锁定技，准备阶段，你选择一项: 1.移去“引兵”牌，然后将手牌摸至体力上限；2.令体力值小于等于你的一名其他角色获得“引兵”牌，然后回复1点体力并摸等量的牌。",
  ["#yinbing-cost"] = "引兵：你可以将任意张非基本牌置于你的武将牌上",
  ["#yinbing-invoke"] = "引兵：你需移去一张“引兵”牌（点“取消”则随机移去一张）",
  ["#juedi-choose"] = "绝地：令一名其他角色获得“引兵”牌然后回复1点体力并摸等量的牌，或点“取消”移去“引兵”牌令自己摸牌",
}

local dingfeng = General(extension, "dingfeng", "wu", 4)
local duanbing = fk.CreateTriggerSkill{
  name = "duanbing",
  anim_type = "offensive",
  events = {fk.TargetSpecifying},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and #player.room.alive_players > 2 and data.card.trueName == "slash"
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if not table.contains(data.tos[1], p.id) and player:distanceTo(p) == 1 then  --TODO: target filter
        table.insertIfNeed(targets, p.id)
      end
    end
    local to = room:askForChoosePlayers(player, targets, 1, 1, "#duanbing-choose", self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    TargetGroup:pushTargets(data.targetGroup, self.cost_data)  --TODO: sort by action order
  end,
}
local fenxun = fk.CreateActiveSkill{
  name = "fenxun",
  anim_type = "offensive",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name) == 0 and not player:isNude()
  end,
  card_filter = function(self, to_select, selected, targets)
    return #selected == 0
  end,
  target_filter = function(self, to_select, selected, cards)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:throwCard(effect.cards, self.name, player, player)
    player:setFixedDistance(room:getPlayerById(effect.tos[1]), 1)
  end,
}
dingfeng:addSkill(duanbing)
dingfeng:addSkill(fenxun)
Fk:loadTranslationTable{
  ["dingfeng"] = "丁奉",
  ["duanbing"] = "短兵",
  [":duanbing"] = "你使用【杀】时可以额外选择一名距离为1的其他角色为目标。",
  ["fenxun"] = "奋迅",
  [":fenxun"] = "出牌阶段限一次，你可以弃置一张牌并选择一名其他角色，令你与其的距离视为1，直到回合结束。",
  ["#duanbing-choose"] = "短兵：你可以额外选择一名距离为1的其他角色为目标",
}

local zhugedan = General(extension, "zhugedan", "wei", 4)
local gongao = fk.CreateTriggerSkill{
  name = "gongao",
  anim_type = "support",
  frequency = Skill.Compulsory,
  events = {fk.Death},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and target ~= player
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
  end,
}
local juyi = fk.CreateTriggerSkill{
  name = "juyi",
  frequency = Skill.Wake,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
     player.phase == Player.Start and
     player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player, data)
    return player:isWounded() and player.maxHp > #player.room.alive_players
  end,
  on_use = function(self, event, target, player, data)
    local n = player.maxHp - #player.player_cards[Player.Hand]
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
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name)
  end,
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
    return #player.room:askForDiscard(player, 1, 1, false, self.name, true, ".|.|.|hand|.|.", "#zhendu-invoke::"..target.id) > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:useVirtualCard("analeptic", nil, target, target, self.name, false)
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
  ["#zhendu-invoke"] = "鸩毒：你可以弃置一张手牌视为 %dest 使用一张【酒】，然后你对其造成1点伤害",
}

--local sunluyu = General(extension, "sunluyu", "wu", 3, 3, General.Female)
local meibu = fk.CreateTriggerSkill{
  name = "meibu",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and target.phase == Player.Play and not target:inMyAttackRange(player)
  end,
  on_use = function(self, event, target, player, data)
    player.room:handleAddLoseSkills(target, "#meibu_filter", nil, false, true)
    for _, id in ipairs(target.player_cards[Player.Hand]) do
      --FIXME: the effect of card was filtered instantly, but the target didn't!
      Fk:filterCard(id, target)
    end
  end,

  refresh_events = {fk.EventPhaseStart},
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill("#meibu_filter", true, true) and player.phase >= Player.NotActive
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:handleAddLoseSkills(player, "-#meibu_filter", nil, false, true)
    for _, id in ipairs(player.player_cards[Player.Hand]) do
      Fk:filterCard(id, player)
    end
  end,
}
local meibu_filter = fk.CreateFilterSkill{
  name = "#meibu_filter",
  card_filter = function(self, to_select, player)
    return player:hasSkill(self.name) and to_select.type == Card.TypeTrick
  end,
  view_as = function(self, to_select)
    local card = Fk:cloneCard("slash", to_select.suit, to_select.number)
    card.skillName = "meibu"
    return card
  end,
}
local meibu_attackrange = fk.CreateAttackRangeSkill{
  name = "#meibu_attackrange",
  correct_func = function (self, from, to)
    if from.phase ~= Player.NotActive and to:hasSkill("meibu") and to:usedSkillTimes("meibu") > 0 then
      return 999
    end
    return 0
  end,
}
local mumu = fk.CreateTriggerSkill{
  name = "mumu",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self.name) and player.phase == Player.Finish then
      if player:getMark("mumu-turn") == 0 then
        self.mumu_tos = {}
        for _, p in ipairs(player.room:getAlivePlayers()) do
          if p:getEquipment(Card.SubtypeWeapon) ~= nil or (p:getEquipment(Card.SubtypeArmor) ~= nil and p ~= player) then
            table.insert(self.mumu_tos, p.id)
          end
        end
        return #self.mumu_tos > 0
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local to = player.room:askForChoosePlayers(player, self.mumu_tos, 1, 1, "#mumu-choose", self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if self.cost_data == player.id then
      room:throwCard({player:getEquipment(Card.SubtypeWeapon)}, self.name, player, player)
      player:drawCards(1)
      return
    end
    local to = room:getPlayerById(self.cost_data)
    local ids = {}
    if to:getEquipment(Card.SubtypeWeapon) ~= nil then
      table.insert(ids, to:getEquipment(Card.SubtypeWeapon))
    end
    if to:getEquipment(Card.SubtypeArmor) ~= nil then
      table.insert(ids, to:getEquipment(Card.SubtypeArmor))
    end
    local id
    if #ids == 1 then
      id = ids[1]
    else
      room:fillAG(player, ids)
      id = room:askForAG(player, ids, false, self.name)
      room:closeAG(player)
    end
    if Fk:getCardById(id).sub_type == Card.SubtypeWeapon then
      room:throwCard({id}, self.name, to, player)
      player:drawCards(1)
    else
      if player:getEquipment(Card.SubtypeArmor) ~= nil then
        room:moveCards({
            ids = {player:getEquipment(Card.SubtypeArmor)},
            from = player.id,
            toArea = Card.DiscardPile,
            moveReason = fk.ReasonPutIntoDiscardPile,
          },
          {
            ids = {id},
            from = to.id,
            to = player.id,
            toArea = Card.PlayerEquip,
            moveReason = fk.ReasonJustMove,
          })
      else
        room:moveCards({
          ids = {id},
          from = to.id,
          to = player.id,
          toArea = Card.PlayerEquip,
          moveReason = fk.ReasonJustMove,
        })
      end
    end
  end,

  refresh_events = {fk.Damage},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Play
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "mumu-turn", 1)
  end,
}
meibu:addRelatedSkill(meibu_attackrange)
--Fk:addSkill(meibu_filter)
--sunluyu:addSkill(meibu)
--sunluyu:addSkill(mumu)
Fk:loadTranslationTable{
  ["sunluyu"] = "孙鲁育",
  ["meibu"] = "魅步",
  [":meibu"] = "一名其他角色的出牌阶段开始时，若你不在其攻击范围内，你可以令该角色的锦囊牌均视为【杀】直到回合结束。若如此做，视为你在其攻击范围内直到回合结束。",
  ["mumu"] = "穆穆",
  [":mumu"] = "若你于出牌阶段内未造成伤害，则此回合的结束阶段开始时，你可以选择一项：弃置场上一张武器牌，然后摸一张牌；或将场上一张防具牌移动到你的装备区里（可替换原防具）。",
  ["#meibu_filter"] = "魅步",
  ["#mumu-choose"] = "穆穆：弃置场上一张武器牌并摸一张牌；或将场上一张防具牌移动到你的装备区（可替换原防具）",
}

local nos__maliang = General(extension, "nos__maliang", "shu", 3)
local xiemu = fk.CreateActiveSkill{
  name = "xiemu",
  anim_type = "drawcard",
  card_num = 1,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name) == 0 and not player:isKongcheng()
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).trueName == "slash"
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:throwCard(effect.cards, self.name, player, player)
    local kingdom = room:askForChoice(player, {"wei", "shu", "wu", "qun"}, self.name)
    room:setPlayerMark(player, "@xiemu", kingdom)
   end
}
local xiemu_record = fk.CreateTriggerSkill{
  name = "#xiemu_record",
  anim_type = "drawcard",
  events = {fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player:getMark("@xiemu") ~= 0 and
      data.from ~= player.id and player.room:getPlayerById(data.from).kingdom == player:getMark("@xiemu") and
      data.card.color == Card.Black
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(2)
  end,

  refresh_events = {fk.EventPhaseStart},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Start
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
    if player:hasSkill(self.name) and data.card.trueName == "slash" and data.from ~= player.id then
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
  ["xiemu"] = "协穆",
  [":xiemu"] = "出牌阶段限一次，你可以弃置一张【杀】并选择一个势力，然后直到你的下回合开始，该势力的其他角色使用的黑色牌指定目标后，若你是此牌的目标，你可以摸两张牌。",
  ["naman"] = "纳蛮",
  [":naman"] = "每当其他角色打出的【杀】进入弃牌堆时，你可以获得之。",
  ["@xiemu"] = "协穆",
  ["#xiemu_record"] = "协穆",
}

local maliang = General(extension, "maliang", "shu", 3)
local zishu = fk.CreateTriggerSkill{
  name = "zishu",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseStart, fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self.name) then return end
    if event == fk.EventPhaseStart and target.phase == Player.NotActive then
      local cards = player:getMark("#zishu-discard")
      return cards ~= 0 and cards ~= {}
    elseif event == fk.AfterCardsMove and player.phase < Player.NotActive then
      for _, move in ipairs(data) do
        return move.skillName ~= self.name and move.toArea == Player.Hand and move.to == player.id
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    if event == fk.EventPhaseStart then
      local discards = player:getMark("#zishu-discard")
      for _, id in ipairs(discards) do
        for _, card in ipairs(player.player_cards[Player.Hand]) do
          if id == card then
            player.room:throwCard(card, self.name, player, player)
          end
        end
      end
      player.room:setPlayerMark(player, "#zishu-discard", 0)
    elseif event == fk.AfterCardsMove then
      player:drawCards(1, self.name)
    end
  end,

  refresh_events = {fk.AfterCardsMove},
  can_refresh = function(self, event, target, player, data)
    if player:hasSkill(self.name) then
      for _, move in ipairs(data) do
        return move.skillName ~= self.name and move.toArea == Player.Hand and move.to == player.id
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    if player.phase == Player.NotActive then
      local discards = player:getMark("#zishu-discard")
      if discards == 0 then discards = {} end
      local cards = {}
      for _, move in ipairs(data) do
        for _, info in ipairs(move.moveInfo) do
          if move.toArea == Player.Hand and move.to == player.id and info.cardId ~= nil then
            table.insert(cards, info.cardId)
          end
        end
      end
      table.insertTable(discards, cards)
      player.room:setPlayerMark(player, "#zishu-discard", discards)
    end
  end,
}
local yingyuan = fk.CreateTriggerSkill{
  name = "yingyuan",
  anim_type = "support",
  events = {fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self.name) and target == player and player.phase == Player.Play and data.card ~= nil and player.room:getCardArea(data.card) == Card.Processing then
      local cardMark = player:getMark("#yingyuan-give")
      if cardMark == 0 then cardMark = {} end
      return not table.contains(cardMark, data.card.trueName)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local to = player.room:askForChoosePlayers(player, table.map(player.room:getOtherPlayers(player), function(p)
      return p.id end), 1, 1, "#yingyuan-give:::" .. data.card.name, self.name)
    if #to > 0 then
      self.cost_data = to
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local cards = data.card
    player.room:obtainCard(self.cost_data[1], cards, false, fk.ReasonGive)
    local cardMark = player:getMark("#yingyuan-give")
    if cardMark == 0 then cardMark = {} end
    table.insert(cardMark, cards.trueName)
    player.room:setPlayerMark(player, "#yingyuan-give", cardMark)
  end,

  refresh_events = {fk.EventPhaseStart},
  can_refresh = function(self, event, target, player, data)
    if player:hasSkill(self.name) and target.phase == Player.NotActive then
      local cards = player:getMark("#yingyuan-give")
      return cards ~= 0 and cards ~= {}
    end
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "#yingyuan-give", 0)
  end,
}
maliang:addSkill(zishu)
maliang:addSkill(yingyuan)
Fk:loadTranslationTable{
  ["maliang"] = "马良",
  ["zishu"] = "自书",
  [":zishu"] = "锁定技，你的回合外，你获得的牌均会在当前回合结束后置入弃牌堆；你的回合内，当你不因此技能效果获得牌时，摸一张牌。",
  ["yingyuan"] = "应援",
  [":yingyuan"] = "当你于回合内使用的牌置入弃牌堆后，你可以将之交给一名其他角色（相同牌名的牌每回合限一次）。",
  ["#zishu-discard"] = "自书",
  ["#yingyuan-give"] = "应援：你可以将 %arg 交给一名其他角色",

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
    local to = room:askForChoosePlayers(player, table.map(room:getOtherPlayers(player), function(p) return p.id end), 1, 1, "#shushen-choose", self.name, true)
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
    return player:hasSkill(self.name) and data.damageType == fk.ThunderDamage and data.from and not data.from.dead
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#zhuji-invoke::"..data.from.id)
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

  refresh_events = {fk.FinishJudge},
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(self.name) and data.reason == self.name
  end,
  on_refresh = function(self, event, target, player, data)
    if data.card.color == Card.Red and player.room:getCardArea(data.card) == Card.Processing then
      player.room:obtainCard(target.id, data.card, true, fk.ReasonJustMove)
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
  ["#zhuji-invoke"] = "助祭：你可令 %dest 判定，若为黑色则此伤害+1，若为红色其获得判定牌",
}

local wenpin = General(extension, "wenpin", "wei", 4)
local zhenwei = fk.CreateTriggerSkill{
  name = "zhenwei",
  anim_type = "defensive",
  events = {fk.TargetConfirming},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and data.from ~= player.id and data.firstTarget and
      (data.card.trueName == "slash" or (data.card.type == Card.TypeTrick and data.card.color == Card.Black)) and
      #AimGroup:getAllTargets(data.tos) == 1 and
      player.room:getPlayerById(data.to).hp < player.hp and
      not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    return #player.room:askForDiscard(player, 1, 1, true, self.name, true, ".", "#zhenwei-invoke:::"..data.card:toLogString()) > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    TargetGroup:removeTarget(data.targetGroup, data.to)
    local choice = room:askForChoice(player, {"zhenwei_transfer", "zhenwei_recycle"}, self.name)
    if choice == "zhenwei_transfer" then
      player:drawCards(1, self.name)
      --FIXME:collateral
      if not target:isProhibited(player, data.card) then
        TargetGroup:pushTargets(data.targetGroup, player.id)
      end
    else
      room:getPlayerById(data.from):addToPile(self.name, data.card, true, self.name)
    end
  end,

  refresh_events = {fk.TurnEnd},
  can_refresh = function(self, event, target, player, data)
    return #player:getPile(self.name) > 0
  end,
  on_refresh = function(self, event, target, player, data)
    local dummy = Fk:cloneCard("dilu")
    dummy:addSubcards(player:getPile(self.name))
    player.room:obtainCard(player.id, dummy, true, fk.ReasonJustMove)
  end,
}
wenpin:addSkill(zhenwei)
Fk:loadTranslationTable{
  ["wenpin"] = "文聘",
  ["zhenwei"] = "镇卫",
  [":zhenwei"] = "每当一名其他角色成为【杀】或黑色锦囊牌的唯一目标时，若该角色的体力值小于你，你可以弃置一张牌并选择一项: 摸一张牌，然后你成为此牌的目标；或令此牌失效并将之移出游戏，该回合结束时令此牌的使用者收回此牌。",
  ["#zhenwei-invoke"] = "镇卫：你可以弃置一张牌将%arg转移给你，或取消之并令使用者回合结束时收回",
  ["zhenwei_transfer"] = "摸一张牌并将此牌转移给你",
  ["zhenwei_recycle"] = "取消此牌，回合结束时使用者将之收回",
}

local simalang = General(extension, "simalang", "wei", 3)
local junbing = fk.CreateTriggerSkill{
  name = "junbing",
  anim_type = "support",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and target.phase == Player.Finish and #target.player_cards[Player.Hand] < 2
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(target, self.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    target:drawCards(1)
    if target == player then return end
    local dummy1 = Fk:cloneCard("dilu")
    dummy1:addSubcards(target.player_cards[Player.Hand])
    room:obtainCard(player.id, dummy1, false, fk.ReasonGive)
    local n = #dummy1.subcards
    local cards = room:askForCard(player, n, n, false, self.name, false, ".", "#junbing-give::"..target.id..":"..n)
    local dummy2 = Fk:cloneCard("dilu")
    dummy2:addSubcards(cards)
    room:obtainCard(target.id, dummy2, false, fk.ReasonGive)
  end,
}
local quji = fk.CreateActiveSkill{
  name = "quji",
  anim_type = "support",
  min_card_num = function ()
    return Self:getLostHp()
  end,
  min_target_num = 1,
  can_use = function(self, player)
    return player:isWounded() and player:usedSkillTimes(self.name) == 0
  end,
  card_filter = function(self, to_select, selected, targets)
    return #selected < Self:getLostHp()
  end,
  target_filter = function(self, to_select, selected, cards)
    return #selected < Self:getLostHp() and Fk:currentRoom():getPlayerById(to_select):isWounded()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:throwCard(effect.cards, self.name, player, player)
    for i = 1, #effect.tos, 1 do
      room:recover({
        who = room:getPlayerById(effect.tos[i]),
        num = 1,
        recoverBy = player.id,
        skillName = self.name
      })
    end
    for _, id in ipairs(effect.cards) do
      if Fk:getCardById(id).color == Card.Black then
        room:loseHp(player, 1, self.name)
        break
      end
    end
  end,
}
simalang:addSkill(junbing)
simalang:addSkill(quji)
Fk:loadTranslationTable{
  ["simalang"] = "司马朗",
  ["junbing"] = "郡兵",
  [":junbing"] = "每名角色的结束阶段，若其手牌数小于或等于1，该角色可以摸一张牌，若该角色不是你，则其将所有手牌交给你，然后你将等量的手牌交给其。",
  ["quji"] = "去疾",
  [":quji"] = "出牌阶段限一次，若你已受伤，你可以弃置X张牌并选择至多X名已受伤的角色，令这些角色各回复1点体力，然后若此此你以此法弃置过的牌中有黑色牌，你失去1点体力。（X为你已损失的体力值）",
  ["#junbing-give"] = "郡兵：将%arg张手牌交给 %dest",
}

return extension
