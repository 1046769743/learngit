--[[
	Author:李朝野
	Date: 2017.06.26
]]


--[[
	景天

	技能描述：
	单体，并有一定几率连续再次对目标触发怒气技能攻击，最大连击上限5次；
	扩展怒气技，如果怒气技能对目标造成了击杀，则恢复自身15%最大生命。
	大招连击率提升，并且最大连击上限增至7次；
	增加需求：
	在景天第一回合登场时获得一枚额外硬币

	脚本处理部分：
	并有一定几率连续再次对目标触发怒气技能攻击，最大连击上限5次；
	如果怒气技能对目标造成了击杀，则恢复自身15%最大生命。
	提升最大连击上限（配表可解决）

	参数：
	@@maxTimes 最大连击次数
	@@ratios 每次的触发概率 "1000_2000"这样配为了减少参数个数
	@@skills 每次成功触发播放的skillId "xxxxxx_xxxxxx"
	@@failSkill 判定失败时播放的skillId "xxxxxx"
	@@atkId 击杀恢复的生命值的攻击包
	增加需求
	@@num 额外增加的金币个数
]]
local Skill_jingtian_3_1 = require("game.battle.skillAi.Skill_jingtian_3_1")
local Skill_jingtian_3_2 = class("Skill_jingtian_3_2", Skill_jingtian_3_1)


function Skill_jingtian_3_2:ctor(skill,id,maxTimes,ratios,skills,failSkill,atkId,num)
	Skill_jingtian_3_2.super.ctor(self,skill,id,maxTimes,ratios,skills,failSkill,atkId)
	-- 标记是否是第一次加
	self._flag = true
	-- 额外增加的金币个数
	self._num = tonumber(num) or 0
end

--[[
	首回合给个硬币
]]
function Skill_jingtian_3_2:onMyRoundStart( selfHero )
	if not self:isSelfHero(selfHero) then return end
	if self._flag then
		self:skillLog("首回合开始前给景天%s个硬币",self._num)
		self._flag = false
		-- 获取小技能的扩充
		local smallSkill = selfHero.data:getSkillByIndex(Fight.skillIndex_small)
		local smallSkillExpand = smallSkill and smallSkill.skillExpand or nil

		if smallSkillExpand then
			-- 加一个金币
			smallSkillExpand:addRune(self._num)
		end
	end
end

return Skill_jingtian_3_2