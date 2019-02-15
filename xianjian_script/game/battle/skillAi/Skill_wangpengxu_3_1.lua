--[[
	Author: lcy
	Date: 2018.03.10
]]

--[[
	王蓬絮大招扩充1

	技能描述:
	若驱散目标增益状态不少于3个，则附带眩晕效果

	脚本处理部分:
	记录可清除增益个数，满足条件进行眩晕

	参数:
	atkId 带眩晕buff的攻击包
	num 满足附带眩晕的增益个数
]]
local Skill_wangpengxu_3_1 = class("Skill_wangpengxu_3_1", SkillAiBasic)

function Skill_wangpengxu_3_1:ctor(skill,id,atkId,num)
	Skill_wangpengxu_3_1.super.ctor(self, skill, id)

	self:errorLog(atkId, "atkId")
	self:errorLog(num, "num")

	self._atkData = ObjectAttack.new(atkId)
	self._num = tonumber(num or 3)
	self._flag = {}
end

--[[
	检查受击者身上有多少可驱散的增益状态
]]
function Skill_wangpengxu_3_1:onBeforePurify(attacker, defender, skill, atkData)
	-- 统计科驱散的buff数量
	local num = defender.data:getBuffNumsByKind(Fight.buffKind_hao, true)
	
	if not self._flag[defender] then self._flag[defender] = num end

	self:skillLog("王蓬絮驱散阵营:%s,%s号位，可驱散buff数量:%s",defender.camp,defender.data.posIndex,num)
end

-- 技能结束后做额外眩晕攻击包
function Skill_wangpengxu_3_1:onAfterSkill(selfHero, skill)
	-- 对满足条件的人做攻击包
	for defender,num in pairs(self._flag) do
		if num >= self._num then
			selfHero:sureAttackObj(defender, self._atkData, self._skill)
		end
	end
	-- 清空
	self._flag = {}

	return true
end

return Skill_wangpengxu_3_1