--[[
	Author:李朝野
	Date: 2017.06.21
	Modify: 2017.11.07 pangkangning
	Modify: 2017.11.19 pangkangning
	Modify: 2017.12.29 lcy
]]

--[[
	龙幽
	修改版：
	在前面技能的基础上概率重置攻击

	脚本处理部分：
	修改版内容；
	概率重置攻击
	
	参数：
	buffs 需要检查的buff类型 xx_xx_xx
	skillId 额外释放的技能Id
	failSkillId 判定失败释放的技能Id
	action 重置攻击时的攻击动作
	ratio 重置概率
]]
local Skill_longyou_3_1 = require("game.battle.skillAi.Skill_longyou_3_1")
local Skill_longyou_3_2 = class("Skill_longyou_3_2", Skill_longyou_3_1)

function Skill_longyou_3_2:ctor(skill,id,buffs,skillId,failSkillId,action,ratio)
	Skill_longyou_3_2.super.ctor(self,skill,id,buffs,skillId,failSkillId)
	
	self:errorLog(action, "action")
	self:errorLog(ratio, "ratio")

	-- 重新攻击的次数
	self.maxCnt = 1
	self.ratio = tonumber(ratio) or 0
	self._action = action
	-- 记录是否做了动作
	self._flag = false
end

function Skill_longyou_3_2:onAfterSkill(selfHero,skill)
	local result = Skill_longyou_3_2.super.onAfterSkill(self, selfHero,skill)
	-- 如果大招之后还有事做 直接返回
	if not result then return result end

	-- 是否是大招
	if skill.skillIndex ~= Fight.skillIndex_max then return true end
	-- 判断一次往回跑
	if self._flag then 
		self._flag = false
		return true 
	end

	if self.ratio>BattleRandomControl.getOneRandomInt(10001,1) then
		if not Fight.isDummy then
			-- 只处理视图的就只在处理视图的时候再做标记
			self._flag = true

			self:skillLog("龙幽重置攻击")
			selfHero:justFrame(self._action)
			selfHero:insterEffWord({1, Fight.wenzi_chongzhigongji, Fight.buffKind_hao})

			-- 激励动作
			-- 重新检查一下能量状态
			-- selfHero:checkFullEnergyStyle()
			local totalFrames = selfHero:getTotalFrames(self._action)
			selfHero:pushOneCallFunc(tonumber(totalFrames), "onSkillActionComplete",{})
			result = false
		end

		selfHero:resetAttackState("all")
		-- 重置敌人身上关于我本回合的伤害信息
		selfHero:resetCurEnemyDmgInfo()
	end

	return result
end

return Skill_longyou_3_2