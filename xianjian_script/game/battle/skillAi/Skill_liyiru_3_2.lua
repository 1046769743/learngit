--[[
	Author:李朝野
	Date: 2017.08.05
	Modify: 2017.10.12
]]
--[[
	王蓬絮被动

	技能描述：
	大招治疗附带效果，若被治疗者为攻击类角色，则提升其本回合攻击力；
	若是防御类角色，则额外恢复更多血量；
	若是辅助类角色，则提升一定怒气；->若是辅助类角色，使其下一次释放大招消耗量减少1点；

	脚本处理部分：
	被治疗者角色判断

	参数：
	atkId1 加攻击力的攻击包
	atkId2 回血攻击包
	atkId3 带有减少怒气消耗buff的攻击包
]]
local Skill_liyiru_3_2 = class("Skill_liyiru_3_2", SkillAiBasic)

function Skill_liyiru_3_2:ctor(skill,id,atkId1,atkId2,atkId3)
	Skill_liyiru_3_2.super.ctor(self, skill, id)

	self:errorLog(atkId1, "atkId1")
	self:errorLog(atkId2, "atkId2")
	self:errorLog(atkId3, "atkId3")

	self._atkData1 = ObjectAttack.new(atkId1)
	self._atkData2 = ObjectAttack.new(atkId2)
	self._atkData3 = ObjectAttack.new(atkId3)
end
--[[
	检测李忆如是否为生命比例最低的角色
]]
function Skill_liyiru_3_2:onCheckTreat(attacker,defender,skill,atkData, dmg)
	-- attacker:sureAttackObj(attacker,self._atkData,self._skill)
	-- 判断是否是被加血的（或者判断是否是自己人？因为加血是给自己人）
	if atkData:sta_addHp() then
		-- 判断角色类型
		if SkillBaseFunc:checkProfession( Fight.profession_atk,defender ) then
			self:skillLog("李忆如大招扩充2给阵营%s，%s号位加血，攻击类角色",defender.camp,defender.data.posIndex)
			attacker:sureAttackObj(defender,self._atkData1,self._skill)
		elseif SkillBaseFunc:checkProfession( Fight.profession_def,defender )  then
			self:skillLog("李忆如大招扩充2给阵营%s，%s号位加血，防御类角色",defender.camp,defender.data.posIndex)
			attacker:sureAttackObj(defender,self._atkData2,self._skill)
		elseif SkillBaseFunc:checkProfession( Fight.profession_sup,defender ) then
			self:skillLog("李忆如大招扩充2给阵营%s，%s号位加血，辅助类角色",defender.camp,defender.data.posIndex)
			attacker:sureAttackObj(defender,self._atkData3,self._skill)
		end
	end

	return dmg
end

return Skill_liyiru_3_2