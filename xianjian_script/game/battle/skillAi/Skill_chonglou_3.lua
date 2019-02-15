
--[[
gs 重楼

地方场上 没存在1个沉默角色，则此次攻击增加一定的额外伤害

]]
local Skill_chonglou_3 = class("Skill_chonglou_3", SkillAiBasic)


function Skill_chonglou_3:ctor(skill,id,ratio )
	self._skill = skill
	self._expandId = id
	self.ratio = ratio  or 0
	if not ratio then
		echoError("___Skill_chonglou_3 中没有配置此次攻击的额外伤害的比例")
	end
end

--[[
额外伤害的比例计算
]]
function Skill_chonglou_3:onCheckAttack(attacker,defender,skill,atkData, dmg  )
	
	if skill.skillIndex ~= Fight.skillIndex_max then
		return
	end
	local camp = attacker.camp
	local campArr 
	
	if camp == 1 then
		campArr = attacker.controler.campArr_2
	else
		campArr = attacker.controler.campArr_1 
	end

	local cnt = 0
	if #campArr>0 then
		for k,v in pairs(campArr) do
			if v.data:checkHasOneBuffType(Fight.buffType_chenmo) then
				cnt = cnt+1
			end
		end
	end
	--计算伤害
	dmg = math.round(dmg + dmg* cnt* self.ratio/10000)
	return dmg
end

return Skill_chonglou_3