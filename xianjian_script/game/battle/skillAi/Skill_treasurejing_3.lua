--[[
	Author:李朝野
	Date: 2017.10.09
]]

--[[
	法宝镜大招

	技能描述：
	攻击敌方一列单位，为自身增加在接下来两回合内获得30%反击概率；

	脚本处理部分：
	为自身增加在接下来两回合内获得30%反击概率；

	参数：
	rate 获得的反击概率
	round 持续的回合数
	atkrate 获得的额外反击伤害率
]]
local Skill_treasurejing_3 = class("Skill_treasurejing_3", SkillAiBasic)

function Skill_treasurejing_3:ctor(skill,id, rate, round, atkrate)
	Skill_treasurejing_3.super.ctor(self, skill, id)
	
	self:errorLog(rate, "rate")
	self:errorLog(round, "round")
	self:errorLog(atkrate, "atkrate")

	self._rate = tonumber(rate) or 0
	self._round = tonumber(round) or 0
	self._atkrate = tonumber(atkrate) or 0
end

--[[
	放技能之前为被动提供参数
]]
function Skill_treasurejing_3:onBeforeAttack(attacker,defender,skill,atkData)
	local selfHero = self:getSelfHero()

	-- 被动技能
	local specialSkill = selfHero.data:getSpecialSkill()
	local skill4expand = specialSkill and specialSkill.skillExpand or nil

	if not skill4expand then return end
	self:skillLog("法宝镜大招之后提升反击相关参数round:%s,rate:%s,atkrate:%s", self._round, self._rate, self._atkrate)
	skill4expand:setExtraParams(self._round, self._rate, self._atkrate)
end

return Skill_treasurejing_3