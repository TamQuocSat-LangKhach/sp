local luoyan = fk.CreateSkill {
  name = "luoyan"
}

Fk:loadTranslationTable{
  ['luoyan'] = '落雁',
  ['xingwu'] = '星舞',
  [':luoyan'] = '锁定技，若你的武将牌上有牌，你视为拥有技能〖天香〗和〖流离〗。',
}

luoyan:addEffect(fk.AfterCardsMove, {
  can_refresh = function(skill, event, target, player, data)
    if player:hasSkill(luoyan.name, true) and player.phase == Player.Discard then
      for _, move in ipairs(data) do
        if move.skillName == "xingwu" then
          return true
        end
      end
    end
  end,
  on_refresh = function(skill, event, target, player, data)
    local room = player.room
    if #player:getPile("xingwu") == 0 and (player:hasSkill("tianxiang", true) or player:hasSkill("liuli", true)) then
      room:handleAddLoseSkills(player, "-tianxiang|-liuli", nil, true, false)
    end
    if #player:getPile("xingwu") > 0 and not (player:hasSkill("tianxiang", true) and player:hasSkill("liuli", true)) then
      room:handleAddLoseSkills(player, "tianxiang|liuli", nil, true, false)
    end
  end,
})

return luoyan