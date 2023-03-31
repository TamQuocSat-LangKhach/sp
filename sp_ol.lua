local extension = Package("sp_ol")
extension.extensionName = "sp"

Fk:loadTranslationTable {
  ["sp_ol"] = "OL.SP",
}

Fk:loadTranslationTable {
  ["zhugeke"] = "诸葛恪",
  ["aocai"] = "傲才",
  [":aocai"] = "当你于回合外需要使用或打出一张基本牌时，你可以观看牌堆顶的两张牌，若你观看的牌中有此牌，你可以使用或打出之。",
  ["duwu"] = "黩武",
  [":duwu"] = "出牌阶段，你可以弃置X张牌对你攻击范围内的一名其他角色造成1点伤害（X为该角色的体力值）。若你以此法令该角色进入濒死状态，则濒死状态结算后你失去1点体力，且本回合不能再发动“黩武”。",
}

Fk:loadTranslationTable {
  ["chengyu"] = "程昱",
  ["shefu"] = "设伏",
  [":shefu"] = "结束阶段开始时，你可将一张手牌扣置于武将牌上，称为“伏兵”。若如此做，你为“伏兵”记录一个基本牌或锦囊牌的名称（须与其他“伏兵”记录的名称均不同）。当其他角色于你的回合外使用手牌时，你可将记录的牌名与此牌相同的一张“伏兵”置人弃牌堆，然后此牌无效。",
  ["benyu"] = "贲育",
  [":benyu"] = "当你受到伤害后，若你的手牌数不大于伤害来源手牌数，你可以将手牌摸至与伤害来源手牌数相同（最多摸至5张）；否则你可以弃置大于伤害来源手牌数的手牌，然后对其造成1点伤害。",
}

local sunhao = General(extension, "sunhao", "wu", 5)
local canshi = fk.CreateTriggerSkill{
  name = "canshi",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Draw
  end,
  on_use = function(self, event, target, player, data)
    local n = 0
    for _, p in ipairs(player.room:getAlivePlayers()) do
      if p:isWounded() then
        n = n + 1
      end
    end
    player:drawCards(n)
    return true
  end,

  refresh_events = {fk.CardUsing},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and (data.card.type == Card.TypeBasic or data.card.type == Card.TypeTrick) and player:usedSkillTimes(self.name) > 0 and not player:isNude()
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:askForDiscard(player, 1, 1, true, self.name)
  end,
}
local chouhai = fk.CreateTriggerSkill{
  name = "chouhai",
  anim_type = "negative",
  frequency = Skill.Compulsory,
  events = {fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player:isKongcheng()
  end,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + 1
  end,
}
sunhao:addSkill(canshi)
sunhao:addSkill(chouhai)
Fk:loadTranslationTable {
  ["sunhao"] = "孙皓",
  ["canshi"] = "残蚀",
  [":canshi"] = "摸牌阶段开始时，你可以放弃摸牌，摸X张牌（X为已受伤的角色数），若如此做，当你于此回合内使用基本牌或锦囊牌时，你弃置一张牌。",
  ["chouhai"] = "仇海",
  [":chouhai"] = "锁定技，当你受到伤害时，若你没有手牌，你令此伤害+1。",
  ["guiming"] = "归命",
  [":guiming"] = "主公技，锁定技，其他吴势力角色于你的回合内视为已受伤的角色。",
}

Fk:loadTranslationTable {
  ["zhanglu"] = "张鲁",
  ["yishe"] = "义舍",
  [":yishe"] = "结束阶段开始时，若你的武将牌上没有牌，你可以摸两张牌。若如此做，你将两张牌置于武将牌上称为“米”，当“米”移至其他区域后，若你的武将牌上没有“米”，你回复1点体力。",
  ["bushi"] = "布施",
  [":bushi"] = "当你受到1点伤害后，或其他角色受到你造成的1点伤害后，受到伤害的角色可以获得一张“米”。",
  ["midao"] = "米道",
  [":midao"] = "当一张判定牌生效前，你可以打出一张“米”代替之。",
}

Fk:loadTranslationTable {
  ["guansuo"] = "关索",
  ["zhengnan"] = "征南",
  [":zhengnan"] = "当其他角色死亡后，你可以摸三张牌，若如此做，你获得下列技能中的任意一个：“武圣”，“当先”和“制蛮”。",
  ["xiefang"] = "撷芳",
  [":xiefang"] = "锁定技，你计算与其他角色的距离-X（X为女性角色数）。",
}

local mayunlu = General(extension, "mayunlu", "shu", 4, 4, General.Female)
local fengpo = fk.CreateTriggerSkill{
  name = "fengpo",
  anim_type = "offensive",
  events = {fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self.name) and (data.card.trueName == "slash" or data.card.name == "duel") then
        return player:usedCardTimes("slash") + player:usedCardTimes("duel") <= 1
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(data.to)
    if to:isKongcheng() then return end
    local n = 0
    for _, id in ipairs(to:getCardIds(Player.Hand)) do
      if Fk:getCardById(id).suit == Card.Diamond then
        n = n + 1
      end
    end
    local choice = room:askForChoice(player, {"fengpo_draw", "fengpo_damage"}, self.name)
    if choice == "fengpo_draw" then
      player:drawCards(n)
    else
      data.additionalDamage = (data.additionalDamage or 0) + n
    end
  end,
}
mayunlu:addSkill("mashu")
mayunlu:addSkill(fengpo)
Fk:loadTranslationTable {
  ["mayunlu"] = "马云騄",
  ["fengpo"] = "凤魄",
  [":fengpo"] = "当你于出牌阶段内使用的第一张【杀】或【决斗】仅指定唯一目标后，你可以选择一项:1.摸X张牌；2.此牌造成的伤害+X。(X为其♦手牌数)",
  ["fengpo_draw"] = "摸X张牌",
  ["fengpo_damage"] = "伤害+X",
}

return extension
