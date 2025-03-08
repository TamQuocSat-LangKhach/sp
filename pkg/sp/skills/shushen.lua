```lua
local shushen = fk.CreateSkill {
  name = "shushen"
}

Fk:loadTranslationTable{
  ['shushen'] = '淑慎',
  ['#shushen-choose'] = '淑慎：你可以令一名其他角色回复1点体力或摸两张牌',
  [':shushen'] = '当你回复1点体力时，你可以令一名其他角色回复1点体力或摸两张牌。',
  ['$shushen1'] = '妾身无恙，相公请安心征战。',
  ['$shushen2'] = '船到桥头自然直。',
}

shushen:addEffect(fk.HpRecover, {
  on_trigger = function(self, event, target, player, data)
    self.cancel_cost = false
    for i = 1, data.num do
      if self.cancel_cost or not player:hasSkill(shushen) then break end
      self:doCost(event, target, player, data)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      targets = table.map(room:getOtherPlayers(player), Util.IdMapper),
      min_num = 1,
      max_num = 1,
      prompt = "#shushen-choose",
      skill_name = shushen.name,
      cancelable = true
    })
    if #to > 0 then
      event:setCostData(self, to[1])
      return true
    end
    self.cancel_cost = true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(event:getCostData(self))
    local choices = {"draw2"}
    if to:isWounded() then
      table.insert(choices, "recover")
    end
    local choice = room:askToChoice(to, {
      choices = choices,
      skill_name = shushen.name
    })
    if choice == "draw2" then
      to:drawCards(2, shushen.name)
    else
      room:recover({
        who = to,
        num = 1,
        recoverBy = player,
        skillName = shushen.name
      })
    end
  end,
})

return shushen
```