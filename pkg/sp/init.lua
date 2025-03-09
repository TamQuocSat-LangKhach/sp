local extension = Package:new("sp")
extension.extensionName = "sp"

extension:loadSkillSkelsByPath "./packages/sp/pkg/sp/skills"

local U = require "packages/utility/utility"

Fk:loadTranslationTable{
  ["sp"] = "SP",
  ["hulao1"] = "虎牢关",
  ["hulao2"] = "虎牢关",
}

General(extension, "yangxiu", "wei", 3):addSkills { "danlao", "jilei" }
Fk:loadTranslationTable{
  ["yangxiu"] = "杨修",
  ["#yangxiu"] = "恃才放旷",
  ["cv:yangxiu"] = "彭尧",
  ["illustrator:yangxiu"] = "张可",
  ["~yangxiu"] = "我固自以死之晚也……",
}

General(extension, "gongsunzan", "qun", 4):addSkills { "yicong" }
Fk:loadTranslationTable{
  ["gongsunzan"] = "公孙瓒",
  ["#gongsunzan"] = "白马将军",
  ["illustrator:gongsunzan"] = "Vincent",
  ["~gongsunzan"] = "我军将败，我已无颜苟活于世……",
}

General(extension, "yuanshu", "qun", 4):addSkills { "yongsi", "weidi" }
Fk:loadTranslationTable{
  ["yuanshu"] = "袁术",
  ["#yuanshu"] = "仲家帝",
  ["cv:yuanshu"] = "彭尧", -- or 马洋 ?
  ["designer:yuanshu"] = "韩旭",
  ["illustrator:yuanshu"] = "吴昊",

  ["~yuanshu"] = "可恶！就差……一步了……",
}

General(extension, "sp__pangde", "wei", 4):addSkills { "mashu", "juesi" }
Fk:loadTranslationTable{
  ["sp__pangde"] = "庞德",
  ["#sp__pangde"] = "抬榇之悟",
  ["illustrator:sp__pangde"] = "天空之城",

  ["~sp__pangde"] = "受魏王厚恩，唯以死报之。",
}

local lvbu = General(extension, "hulao1__godlvbu", "god", 8)
lvbu.hidden = true
lvbu.hulao_status = 1
lvbu:addSkills { "mashu", "wushuang", "hulao__jingjia", "hulao__aozhan" }
Fk:loadTranslationTable{
  ["hulao1__godlvbu"] = "神吕布",
  ["#hulao1__godlvbu"] = "最强神话",
  ["illustrator:hulao1__godlvbu"] = "LiuHeng",
}

local lvbu2 = General(extension, "hulao2__godlvbu", "god", 4)
lvbu2.hidden = true
lvbu2.hulao_status = 2
lvbu2:addSkills { "mashu", "wushuang", "xiuluo", "hulao__shenwei", "shenji" }
Fk:loadTranslationTable{
  ["hulao2__godlvbu"] = "神吕布",
  ["#hulao2__godlvbu"] = "暴怒的战神",
  ["illustrator:hulao2__godlvbu"] = "LiuHeng",

  ["~hulao2__godlvbu"] = "虎牢关……失守了……",
}

General(extension, "sp__caiwenji", "wei", 3, 3, General.Female):addSkills { "chenqing", "mozhi" }
Fk:loadTranslationTable{
  ["sp__caiwenji"] = "蔡文姬",
  ["#sp__caiwenji"] = "金璧之才",
  ["cv:sp__caiwenji"] = "小N",
  ["designer:sp__caiwenji"] = "韩旭",
  ["illustrator:sp__caiwenji"] = "木美人",

  ["~sp__caiwenji"] = "命运……弄人……",
}

General(extension, "sp__machao", "qun", 4):addSkills { "sp__zhuiji", "shichou" }
Fk:loadTranslationTable{
  ["sp__machao"] = "马超",
  ["#sp__machao"] = "西凉的猛狮",
  ["designer:sp__machao"] = "凌天翼",
  ["illustrator:sp__machao"] = "天空之城",

  ["~sp__machao"] = "西凉，回不去了……",
}

General(extension, "sp__jiaxu", "wei", 3):addSkills { "zhenlue", "jianshu", "yongdi" }
Fk:loadTranslationTable{
  ["sp__jiaxu"] = "贾诩",
  ["#sp__jiaxu"] = "算无遗策",
  ["designer:sp__jiaxu"] = "千幻",
  ["illustrator:sp__jiaxu"] = "雪君S",

  ["~sp__jiaxu"] = "立嫡之事，真是取祸之道！",
}

General(extension, "caohong", "wei", 4):addSkills { "yuanhu" }
Fk:loadTranslationTable{
  ["caohong"] = "曹洪",
  ["#caohong"] = "福将",
  ["designer:caohong"] = "韩旭",
  ["illustrator:caohong"] = "LiuHeng",

  ["~caohong"] = "福兮祸所伏……",
}

General(extension, "guanyinping", "shu", 3, 3, General.Female):addSkills { "xueji", "huxiao", "wuji" }
Fk:loadTranslationTable{
  ["guanyinping"] = "关银屏",
  ["#guanyinping"] = "武姬",
  ["designer:guanyinping"] = "韩旭",
  ["illustrator:guanyinping"] = "木美人",

  ["~guanyinping"] = "父亲，你来救我了吗……",
}

General(extension, "liuxie", "qun", 3):addSkills { "tianming", "mizhao" }
Fk:loadTranslationTable{
  ["liuxie"] = "刘协",
  ["#liuxie"] = "受困天子",
  ["designer:liuxie"] = "韩旭",
  ["illustrator:liuxie"] = "LiuHeng",

  ["~liuxie"] = "为什么，不把复兴汉室的权力交给我……",
}

General(extension, "lingju", "qun", 3, 3, General.Female):addSkills { "jieyuan", "fenxin" }
Fk:loadTranslationTable{
  ["lingju"] = "灵雎",
  ["#lingju"] = "情随梦逝",
  ["designer:lingju"] = "韩旭",
  ["illustrator:lingju"] = "木美人",

  ["~lingju"] = "主上，对不起……",
}

General(extension, "fuwan", "qun", 4):addSkills { "moukui" }
Fk:loadTranslationTable{
  ["fuwan"] = "伏完",
  ["#fuwan"] = "沉毅的国丈",
  ["illustrator:fuwan"] = "LiuHeng",

  ["~fuwan"] = "后会有期……",
}

local xiahouba = General(extension, "xiahouba", "shu", 4)
xiahouba:addSkills { "baobian" }
xiahouba:addRelatedSkills {"ol_ex__tiaoxin", "ex__paoxiao", "ol_ex__shensu" }
Fk:loadTranslationTable{
  ["xiahouba"] = "夏侯霸",
  ["#xiahouba"] = "棘途壮志",
  ["illustrator:xiahouba"] = "熊猫探员",

  ["$ol_ex__tiaoxin_xiahouba1"] = "跪下受降，饶你不死！",
  ["$ol_ex__tiaoxin_xiahouba2"] = "黄口小儿，可听过将军名号？",
  ["$ex__paoxiao_xiahouba1"] = "喝！",
  ["$ex__paoxiao_xiahouba2"] = "受死吧！",
  ["$ol_ex__shensu_xiahouba1"] = "冲杀敌阵，来去如电！",
  ["$ol_ex__shensu_xiahouba2"] = "今日有恙在身，须得速战速决！",
  ["~xiahouba"] = "弃魏投蜀，死而无憾。",
}

General(extension, "chenlin", "wei", 3):addSkills { "bifa", "songci" }
Fk:loadTranslationTable{
  ["chenlin"] = "陈琳",
  ["#chenlin"] = "破竹之咒",
  ["designer:chenlin"] = "韩旭",
  ["illustrator:chenlin"] = "木美人",

  ["~chenlin"] = "来人……我的笔呢……",
}

local daqiaoxiaoqiao = General(extension, "daqiaoxiaoqiao", "wu", 3, 3, General.Female)
daqiaoxiaoqiao:addSkills { "xingwu", "luoyan" }
daqiaoxiaoqiao:addRelatedSkill("tianxiang")
daqiaoxiaoqiao:addRelatedSkill("liuli")
Fk:loadTranslationTable{
  ["daqiaoxiaoqiao"] = "大乔小乔",
  ["#daqiaoxiaoqiao"] = "江东之花",
  ["designer:daqiaoxiaoqiao"] = "韩旭",
  ["illustrator:daqiaoxiaoqiao"] = "木美人",

  ["$tianxiang_daqiaoxiaoqiao1"] = "替我挡着吧~",
  ["$tianxiang_daqiaoxiaoqiao2"] = "哼！我才不怕你呢~",
  ["$liuli_daqiaoxiaoqiao1"] = "呵呵，交给你啦~",
  ["$liuli_daqiaoxiaoqiao2"] = "不懂得怜香惜玉么~",
  ["~daqiaoxiaoqiao"] = "伯符，公瑾，请一定要守护住我们的江东啊！",
}

General(extension, "sp__xiahoushi", "shu", 3, 3, General.Female):addSkills { "sp__yanyu", "xiaode" }
Fk:loadTranslationTable{
  ["sp__xiahoushi"] = "夏侯氏",
  ["#sp__xiahoushi"] = "疾冲之恋",
  ["illustrator:sp__xiahoushi"] = "牧童的短笛",
  ["designer:sp__xiahoushi"] = "桃花僧",
  ["cv:sp__xiahoushi"] = "橘枍shii吖",

  ["~sp__xiahoushi"] = "燕语叮嘱，愿君安康。",
}

General(extension, "yuejin", "wei", 4):addSkills { "sp__xiaoguo" }
Fk:loadTranslationTable{
  ["yuejin"] = "乐进",
  ["#yuejin"] = "奋强突固",
  ["illustrator:yuejin"] = "巴萨小马",
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

General:new(extension, "dingfeng", "wu", 4):addSkills{"sp__duanbing", "sp__fenxun"}
Fk:loadTranslationTable{
  ["dingfeng"] = "丁奉",
  ["#dingfeng"] = "清侧重臣",
  ["illustrator:dingfeng"] = "G.G.G.",
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

General:new(extension, "ganfuren", "shu", 3, 3, General.Female):addSkills{"sp__shushen", "sp__shenzhi"}
Fk:loadTranslationTable{
  ["ganfuren"] = "甘夫人",
  ["#ganfuren"] = "昭烈皇后",
  ["illustrator:ganfuren"] = "琛·美弟奇",
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
