local yongsi = fk.CreateSkill {
  name = "yongsi"
}

Fk:loadTranslationTable{
  ['yongsi'] = '庸肆',
  ['#yongsi-discard'] = '庸肆：你需弃掉等同于场上现存势力数的牌（%arg张）',
  [':yongsi'] = '锁定技，摸牌阶段，你额外摸X张牌，X为场上现存势力数。弃牌阶段，你至少须弃掉等同于场上现存势力数的牌（不足则全弃）。',
  ['$yongsi1'] = '大汉天下，已半入我手！',
  ['$yongsi2'] = '玉玺在手，天下我有！',
}

yongsi:addEffect(fk.DrawNCards, {
  can_trigger = function(self, event, target, player)
    return target == player and player:hasSkill(yongsi.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local kingdoms = {}
    for _, p in ipairs(room.alive_players) do
      table.insertIfNeed(kingdoms, p.kingdom)
    end
    data.n = data.n + #kingdoms
  end,
})

yongsi:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player)
    return player.phase == Player.Discard and player:hasSkill(yongsi.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local kingdoms = {}
    for _, p in ipairs(room.alive_players) do
      table.insertIfNeed(kingdoms, p.kingdom)
    end
    room:askToDiscard(player, {
      min_num = #kingdoms,
      max_num = #kingdoms,
      include_equip = true,
      skill_name = yongsi.name,
      cancelable = false,
      prompt = "#yongsi-discard:::" .. #kingdoms
    })
  end,
})

return yongsi