local zhenlue = fk.CreateSkill {
  name = "zhenlue"
}

Fk:loadTranslationTable {
  ['zhenlue'] = '缜略',
  [':zhenlue'] = '锁定技，你使用的非延时锦囊牌不能被抵消，你不能被选择为延时锦囊牌的目标。',
}

zhenlue:addEffect(fk.AfterCardUseDeclared, {
  anim_type = "control",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zhenlue.name) and
        data.card.type == Card.TypeTrick and data.card.sub_type ~= Card.SubtypeDelayedTrick
  end,
  on_use = function(self, event, target, player, data)
    data.unoffsetableList = table.simpleClone(player.room.alive_players)
  end,
})

zhenlue:addEffect('prohibit', {
  name = "#zhenlue_prohibit",
  is_prohibited = function(self, from, to, card)
    return to:hasSkill(zhenlue.name) and card.sub_type == Card.SubtypeDelayedTrick
  end,
})

return zhenlue
