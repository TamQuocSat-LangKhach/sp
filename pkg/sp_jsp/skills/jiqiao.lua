```lua
local jiqiao = fk.CreateSkill {
  name = "jiqiao"
}

Fk:loadTranslationTable{
  ['jiqiao'] = '机巧',
  ['#jiqiao-invoke'] = '机巧：你可以弃置任意张装备牌，亮出牌堆顶两倍数量的牌并获得其中的锦囊牌',
  [':jiqiao'] = '出牌阶段开始时，你可以弃置任意张装备牌，然后亮出牌堆顶两倍数量的牌，你获得其中的锦囊牌，将其余的牌置入弃牌堆。',
  ['$jiqiao1'] = '驭巧器，以取先机。',
  ['$jiqiao2'] = '颖悟之人，不以拙力取胜。',
}

jiqiao:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player)
    return target == player and player:hasSkill(jiqiao.name) and player.phase == Player.Play and not player:isNude()
  end,
  on_cost = function(self, event, target, player)
    local n = #player.room:askToDiscard(player, {
      min_num = 1,
      max_num = 999,
      include_equip = true,
      pattern = ".|.|.|.|.|equip",
      prompt = "#jiqiao-invoke"
    })
    if n > 0 then
      event:setCostData(self, n)
      return true
    end
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    local cards = room:getNCards(2 * event:getCostData(self))
    room:moveCards{
      ids = cards,
      toArea = Card.Processing,
      moveReason = fk.ReasonJustMove,
      skillName = jiqiao.name,
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
        skillName = jiqiao.name,
      }
    end
  end,
})

return jiqiao
```