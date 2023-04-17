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
    if player:hasSkill(self.name) and data.card.skillName == "longdan" then
      local id
      if event == fk.CardUsing then
        if data.card.name == "slash" then
          for i = 1, #data.tos, 1 do  --for multi-targets slash
            id = data.tos[i][1]
            if not player.room:getPlayerById(id):isKongcheng() then
              self.chongzhen_to = id
              return true
            end
          end
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
        self.chongzhen_to = id
        return not player.room:getPlayerById(id):isKongcheng()
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.chongzhen_to)
    local card = room:askForCardChosen(player, to, "h", self.name)
    room:obtainCard(player.id, card, false)
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
    room:obtainCard(player.id, dummy, false)
    player:turnOver()
    room:addPlayerMark(target, self.name, 1)
  end,
}
local lihun_record = fk.CreateTriggerSkill{
  name = "#lihun_record",

  refresh_events = {fk.EventPhaseEnd},
  can_refresh = function(self, event, target, player, data)
    if target == player and player:hasSkill(self.name, true) and player.phase == Player.Play and player:usedSkillTimes("lihun") > 0 then
      for _, p in ipairs(player.room:getAlivePlayers()) do
        if p:getMark("lihun") > 0 then
          self.lihun_to = {p.id}
          return true
        end
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.lihun_to[1])
    room:setPlayerMark(to, "lihun", 0)
    if player:isNude() then return end
    local n = math.min(to.hp, #player:getCardIds(Player.Hand) + #player:getCardIds(Player.Equip))
    local dummy = Fk:cloneCard("dilu")
    if n == #player.player_cards[Player.Hand] + #player.player_cards[Player.Equip] then
      dummy:addSubcards(player:getCardIds(Player.Hand))
      dummy:addSubcards(player:getCardIds(Player.Equip))
    else
      local cards = room:askForCard(player, n, n, true, "lihun", false, "#lihun-give")
      dummy:addSubcards(cards)
    end
    room:obtainCard(to.id, dummy, false)
  end,
}
lihun:addRelatedSkill(lihun_record)
diaochan:addSkill(lihun)
diaochan:addSkill("biyue")
Fk:loadTranslationTable{
  ["starsp__diaochan"] = "貂蝉",
  ["lihun"] = "离魂",
  [":lihun"] = "出牌阶段，你可以弃置一张牌并将你的武将牌翻面，若如此做，指定一名男性角色，获得其所有手牌。出牌阶段结束时，你须为该角色的每一点体力分配给其一张牌，每回合限一次。",
  ["#lihun-give"] = "离魂：你需交还该角色体力值张数的牌",
}

return extension
