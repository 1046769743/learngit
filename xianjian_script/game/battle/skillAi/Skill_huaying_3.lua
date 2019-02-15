--[[
	Author:李朝野
	Date: 2017.06.21
	Modify: 2018.03.10
]]


--[[
	花楹大招
	
	技能描述：
	治疗3个目标，驱散三个目标，每驱散一个负面buff给驱散的目标恢复5%最大生命值
	
	脚本处理部分：
	统计驱散负面buff个数、恢复目标生命值

	参数：
	@@atkId 恢复生命攻击包
]]
local Skill_huaying_3 = class("Skill_huaying_3", SkillAiBasic)

function Skill_huaying_3:ctor(skill,id,atkId)
	Skill_huaying_3.super.ctor(self, skill, id)

	self:errorLog(atkId, "atkId")

	self._atkData = ObjectAttack.new(atkId)
	self._flag = {}
end

-- 进行治疗时检查
function Skill_huaying_3:onBeforePurify(attacker,defender,skill,atkData)
	-- 统计可驱散的buff数量
	local num = defender.data:getBuffNumsByKind(Fight.buffKind_huai, true)
	if not self._flag[defender] then self._flag[defender] = num end

	self:skillLog("花楹驱散阵营:%s,%s号位，可驱散buff数量:%s",defender.camp,defender.data.posIndex,num)
end

-- 技能结束后做额外加血攻击包
function Skill_huaying_3:onAfterSkill(selfHero,skill)
	-- 对记录的人分别做额外加血攻击包
	for defender,num in pairs(self._flag) do
		-- 驱散了几个加几次
		for i=1,num do
			selfHero:sureAttackObj(defender,self._atkData,self._skill)
		end
	end

	self._flag = {} -- 清理记录

	return true
end

return Skill_huaying_3