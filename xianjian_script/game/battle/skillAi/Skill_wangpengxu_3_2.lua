--[[
	Author:李朝野
	Date: 2017.08.04
	Modify: 2018.03.10
]]
--[[
	王蓬絮大招扩充2

	技能描述：
	每驱散目标一层增益状态则增强减少若干防御力

	脚本处理部分：
	计数并改变buff的值

	参数：
	atkId 带眩晕buff的攻击包
	num 满足附带眩晕的增益个数
	buffsId 减防buffId（物防_法防）
]]
local Skill_wangpengxu_3_1 = require("game.battle.skillAi.Skill_wangpengxu_3_1")

local Skill_wangpengxu_3_2 = class("Skill_wangpengxu_3_2", Skill_wangpengxu_3_1)

function Skill_wangpengxu_3_2:ctor(skill,id, atkId, num, buffsId)
	Skill_wangpengxu_3_2.super.ctor(self,skill,id, atkId, num)

	self:errorLog(buffsId, "buffsId")

	self._buffsId = string.split(buffsId, "_")
end

--[[
	攻击结束后施加额外攻击包
]]
function Skill_wangpengxu_3_2:onAfterSkill(selfHero, skill)
	for defender,num in pairs(self._flag) do
		if num > 0 then
			for _,buffId in ipairs(self._buffsId) do
				local buffObj = self:getBuff(buffId)
				buffObj.value = tonumber(buffObj.value) * num
				if buffObj.calValue then
					buffObj.calValue.rate = tonumber(buffObj.calValue.rate) * num
					buffObj.calValue.n = tonumber(buffObj.calValue.n) * num
				end

				-- 做减防
				defender:checkCreateBuffByObj(buffObj, selfHero, skill)
			end
		end
	end

	-- 后做父类函数，父类函数里会清除计数
	return Skill_wangpengxu_3_2.super.onAfterSkill(self, selfHero, skill)
end

return Skill_wangpengxu_3_2