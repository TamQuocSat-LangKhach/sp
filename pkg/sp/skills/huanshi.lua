local huanshi = fk.CreateSkill {
  name = "huanshi"
}

Fk:loadTranslationTable{
  ['huanshi'] = '缓释',
  ['#huanshi-invoke'] = '缓释：你可以令 %dest 观看你的手牌并打出其中一张牌修改其判定',
  [':huanshi'] = '当一名角色的判定牌生效前，你可以令该角色观看你的手牌并选择你的一张牌，你打出此牌代替之。',
  ['$huanshi1'] = '缓乐之危急，释兵之困顿。',
  ['$huanshi2'] = '尽死生之力，保友邦之安。',
}

huanshi:addEffect(fk.AskForRetrial, {
  anim_type = "support",
  can_trigger = function(self, event, target, player)
    return player:hasSkill(huanshi.name) and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player)
    if player.room:askToSkillInvoke(player, {
      skill_name = huanshi.name,
      prompt = "#huanshi-invoke::" .. target.id
    }) then
      player.room:doIndicate(player.id, {target.id})
      return true
    end
  end,
  on_use = function(self, event, target, player)
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
    local id = room:askToChooseCard(target, {
      target = player,
      flag = { card_data = card_data },
      skill_name = huanshi.name
    })
    local card = Fk:getCardById(id)
    if not player:prohibitResponse(card) then
      room:retrial(card, player, event.data, huanshi.name)
    end
  end,
})

return huanshi