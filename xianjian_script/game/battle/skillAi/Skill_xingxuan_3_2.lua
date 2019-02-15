--[[
	Author:李朝野
	Date: 2017.09.15
	Modify: 2017.10.20
	Modify: 2018.03.10
]]


--[[
	星璇大招扩充2

	技能描述：
	如果星璇比对手血线高，需要播放另一套技能——总共4种情况， 
	星璇自身血量高于敌人，并且打了生命低于50%的——最强 
	星璇自身血量不高于敌人，并且打了生命低于50%的——第二强 
	星璇自身血量高于敌人，但是敌人生命高于50%——第三 
	星璇血量不高于敌人，且敌人生命高于50%——最弱
	如果自己血线高于对手，则附加提升伤害系数（万分比）
	
	脚本处理部分：
	大招会有两段，第一段之前要判断血量决定第二段放哪个技能；

	参数：
	hpper 血限，万分
	skills 额外技能"xxx_xxx"
	atkId 表现攻击包的Id
	dmgper 如果自己血线高于对手，则附加提升伤害系数（万分比）
]]
local Skill_xingxuan_3_1 = require("game.battle.skillAi.Skill_xingxuan_3_1")

local Skill_xingxuan_3_2 = class("Skill_xingxuan_3_2", Skill_xingxuan_3_1)

function Skill_xingxuan_3_2:ctor(skill,id, hpper, skills,atkId,dmgper)
	Skill_xingxuan_3_2.super.ctor(self, skill,id, hpper, skills,atkId)

	self:errorLog(dmgper, "dmgper")

	self._dmgPer = dmgper
end

--[[
	在第一个空攻击包收到的时候就进行检查
]]
function Skill_xingxuan_3_2:onBeforeDamageResult(attacker,defender,skill,atkData)
	-- 防止递归
	if skill == self._skill then
		return 
	end
	local hpPer = defender.data:hp() / defender.data:maxhp()
	local selfHpPer = attacker.data:hp() / attacker.data:maxhp()

	-- 不是最弱的就播一个特效
	if not (hpPer > self._hpPer and selfHpPer <= hpPer) then
		-- 不是最弱的技能，播一个特效
		attacker:sureAttackObj(attacker,self._atkData,self._skill)
	end
end

--[[
	打血前检查生命值,重写父类方法
]]
function Skill_xingxuan_3_2:onCheckAttack(attacker,defender,skill,atkData, dmg)
	local hpPer = defender.data:hp() / defender.data:maxhp()
	local selfHpPer = attacker.data:hp() / attacker.data:maxhp()


		
	if hpPer > self._hpPer and selfHpPer <= hpPer then
		self._secondSkill = self._skills[1]
	elseif hpPer > self._hpPer and selfHpPer > hpPer then
		self._secondSkill = self._skills[3]
	elseif hpPer <= self._hpPer and selfHpPer <= hpPer then
		self._secondSkill = self._skills[2]
	elseif hpPer <= self._hpPer and selfHpPer > hpPer then
		self._secondSkill = self._skills[4]
	end
	-- 如果自己血线高于对手，则附加提升伤害系数（万分比）
	if selfHpPer > hpPer then
		local exDmg = math.round(dmg * self._dmgPer/10000)
		self:skillLog("星璇大招扩充2,原伤害:%s,提升伤害:%s",dmg,exDmg)
		dmg = dmg + exDmg
	end

	return dmg
end

return Skill_xingxuan_3_2