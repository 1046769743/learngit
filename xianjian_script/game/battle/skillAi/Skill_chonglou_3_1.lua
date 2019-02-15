
--[[
gs 重楼

地方场上 没存在1个沉默角色，则此次攻击增加一定的额外伤害

Skill_chonglou_3_1;ratio1;ratio2;


]]
local Skill_chonglou_3_1 = class("Skill_chonglou_3_1", SkillAiBasic)



--[[
ratio1:人数越少伤害越高的ratio
ratio2: 1个沉默角色 则增加一定的额外伤害
ratio3: 生命比例越高，则提升额外伤害的效果越大
]]
function Skill_chonglou_3_1:ctor(skill,id,ratio1,ratio2)
	self._skill = skill
	self._expandId = id
	self.ratio1 = ratio1  or 0
	if not ratio1 then
		echoError("___Skill_chonglou_3_1 中没有配置1个沉默角色此次攻击提升自身额外伤害")
	end
	self.ratio2 = ratio2 or 0
	if not ratio2 then
		echoError("___Skill_chonglou_3_1 中没有配置血量比例越高造成的额外伤害")
	end
end







--[[
人数越少，伤害越高
额外伤害的比例计算
]]
function Skill_chonglou_3_1:onCheckAttack(attacker,defender,skill,atkData, dmg  )
	
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
	local dmgChenMo = 0
	local cnt = 0
	if #campArr>0 then
		for k,v in pairs(campArr) do
			if v.data:checkHasOneBuffType(Fight.buffType_chenmo) then
				cnt = cnt+1
			end
		end
	end
	--计算伤害
	dmgChenMo = dmg* cnt* self.ratio1/10000
	echo("Skill_chonglou_3_1重楼沉默造成的额外伤害,",dmgChenMo)

	--计算生命值越高 伤害越高
	local dmgHp = 0
	--(1-hpPercent) * (maxPercent/10000) + 1
	dmgHp = (1+attacker.data:hp()/attacker.data:maxhp()*self.ratio2/10000)*dmg
	echo("Skill_chonglou_3_1重楼血量比例造成的额外伤害",dmgHp)

	--
	dmg = math.round(dmg + dmgChenMo+dmgHp)
	return dmg
end

return Skill_chonglou_3_1