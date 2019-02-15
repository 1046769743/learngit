
--[[
gs 重楼

地方场上 没存在1个沉默角色，则此次攻击增加一定的额外伤害

]]
local Skill_chonglou_3_2 = class("Skill_chonglou_3_2", SkillAiBasic)



--[[
ratio1: 1个沉默角色 则增加一定的额外伤害
ratio2: 生命比例越高，则提升额外伤害的效果越大
]]
function Skill_chonglou_3_2:ctor(skill,id,radio1,ratio2)
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
攻击前
如果已经被沉默
则要城改目标的沉默效果一个回合
]]
function Skill_chonglou_3_2:onBeforeAttack(attacker,defender,skill,atkData)
	if skill.skillIndex ~= Fight.skillIndex_max then
		return
	end

	-- local camp = selfHero.camp
	-- local campArr 
	-- if camp == 1 then
	-- 	campArr = selfHero.controler.campArr_2
	-- else
	-- 	campArr = selfHero.controler.campArr_1
	-- end
	-- if #campArr>0 then
	-- 	for k,v in pairs(campArr) do
	-- 		--获取沉默的buff
	-- 		local buffs = v.data:getBuffsByType(Fight.buffType_chenmo)
	-- 		if #buffs>0 then
	-- 			for kk,vv in pairs(buffs) do
	-- 				--延长buff的作用回合数  这个要和朝阳确认这个 1 的参数要不要配置
	-- 				vv.time = vv.time+1
	-- 			end
	-- 		end
	-- 	end		
	-- end

	local buffs = defender.data:getBuffsByType(Fight.buffType_chenmo)
	if #buffs>0 then
		echo("重楼中的大招延长沉默效果一个回合-----")
		for kk,vv in pairs(buffs) do
			vv.time = vv.time+1
		end
	end

end





--[[ 
沉默角色越多伤害月高 额外伤害的比例计算
生命值越高 则伤害越高
]]
function Skill_chonglou_3_2:onCheckAttack(attacker,defender,skill,atkData, dmg  )
	
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
	echo("Skill_chonglou_3_2重楼沉默造成的额外伤害,",dmgChenMo)

	--计算生命值越高 伤害越高
	local dmgHp = 0
	--(1-hpPercent) * (maxPercent/10000) + 1
	dmgHp = (1+attacker.data:hp()/attacker.data:maxhp()*self.ratio2/10000)*dmg
	echo("Skill_chonglou_3_2重楼血量比例造成的额外伤害",dmgHp)

	--
	dmg = math.round(dmg + dmgChenMo+dmgHp)
	return dmg
end

return Skill_chonglou_3_2