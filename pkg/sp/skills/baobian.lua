local baobian = fk.CreateSkill {
  name = "baobian",
  frequency = Skill.Compulsory,
}

Fk:loadTranslationTable{
  ['baobian'] = '豹变',
  [':baobian'] = '锁定技，若你的体力值为3或更少，你视为拥有技能〖挑衅〗；若你的体力值为2或更少，你视为拥有技能〖咆哮〗；若你的体力值为1，你视为拥有技能〖神速〗。',
  ['$baobian1'] = '变可生，不变则死。',
  ['$baobian2'] = '适时而动，穷极则变。',
}

local function baobianChange(player, hp, skill_name)
  local room = player.room
  local skills = player.tag["baobian"]
  if type(skills) ~= "table" then skills = {} end
  if player.hp <= hp then
    if not table.contains(skills, skill_name) then
      player:broadcastSkillInvoke("baobian")
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

local on_use = function(self, event, target, player, data)
  baobianChange(player, 1, "ol_ex__shensu")
  baobianChange(player, 2, "ex__paoxiao")
  baobianChange(player, 3, "ol_ex__tiaoxin")
end

baobian:addEffect(fk.HpChanged, {
  anim_type = "offensive",
  on_use = on_use,
})

baobian:addEffect(fk.MaxHpChanged, {
  anim_type = "offensive",
  on_use = on_use,
})

return baobian