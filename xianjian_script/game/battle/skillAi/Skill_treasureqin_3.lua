--[[
	Author:李朝野
	Date: 2017.09.22
]]

--[[
	法宝琴大招

	技能描述：
	攻击敌方单体，如果本回合内在攻击前获得增益效果，则此次附带减怒效果；
	
	脚本处理部分：
	监听是否获得增益效果，如果获得攻击时附带攻击包

	参数：
	atkId1 减怒攻击包
]]
local Skill_treasureqin_3 = class("Skill_treasureqin_3", SkillAiBasic)

function Skill_treasureqin_3:ctor(skill,id,atkId1)
	Skill_treasureqin_3.super.ctor(self, skill,id)
	
	self:errorLog(atkId1, "atkId1")

	self._atkData1 = ObjectAttack.new(atkId1)

	-- 标记是否被上了增益buff
	self._flag = false
end

--[[
	回合前重置标记
]]
function Skill_treasureqin_3:onMyRoundStart(selfHero )
	if not self:isSelfHero(selfHero) then return end

	self._flag = false
end

--[[
	检查自己是否被上增益buff
]]
function Skill_treasureqin_3:onOneBeUseBuff(attacker, defender, skill, buffObj)
	if not self:isSelfHero(defender) then return end

	if buffObj.kind == Fight.buffKind_hao then
		self._flag = true
	end
end

--[[
	如果符合条件对受击者进行减怒
]]
function Skill_treasureqin_3:onAfterAttack(attacker,defender,skill,atkData  )
	if self._flag then
		self:skillLog("法宝琴大招符合条件，对阵营%s %s号施加减怒攻击包:%s",defender.camp,defender.data.posIndex,self._atkData1.hid)
		attacker:sureAttackObj(defender,self._atkData1,skill)
	end
end

return Skill_treasureqin_3