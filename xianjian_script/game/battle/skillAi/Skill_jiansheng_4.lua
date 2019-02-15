--[[
	Author:李朝野
	Date: 2017.08.31
	Modify: 2018.03.21
]]
--[[
	剑圣被动

	技能描述：
	初始为修炼状态，每对一个目标造成伤害，修炼等级增加一层，
	每层修炼增加2%攻击力，可以被驱散。
	当修炼等级达到6层时，进入伏魔状态，伏魔状态增加12%攻击力，伏魔状态不可被驱散。
	
	脚本处理部分：
	记录修炼状态层数,做相关操作

	参数：
	当前技能配置为一个可释放技能，为进入伏魔状态的动作以及特效

	@@buffIdP 每层加攻击力的buff（配置为强制叠加）
	@@buffIdX 达成状态后添加攻击力的buffId（配置为不可驱散）
	@@maxNum 达成要求的层数
	@@lastRound 伏魔状态持续回合数
	@@slots 需要控制的slots的名字 _ 分割 如"fu5_fu6_fu7_fu8" 填写顺序就是显示顺序
]]
local Skill_jiansheng_4 = class("Skill_jiansheng_4", SkillAiBasic)

function Skill_jiansheng_4:ctor(skill,id, buffIdP, buffIdX, maxNum, lastRound, slots)
	Skill_jiansheng_4.super.ctor(self,skill,id)

	self:errorLog(buffIdP, "buffIdP")
	self:errorLog(buffIdX, "buffIdX")
	self:errorLog(maxNum, "maxNum")
	self:errorLog(lastRound, "lastRound")
	self:errorLog(slots, "slots")

	self._buffIdP = buffIdP or 0
	self._buffIdX = buffIdX or 0
	self._maxNum = tonumber(maxNum or 0)
	self._lastRound = tonumber(lastRound or 0)
	self._slots = string.split(slots, "_")

	self._round = 0 -- 伏魔状态剩余回合

	-- 记录修炼层数
	self._count = 0
end

-- 增加修炼层数
function Skill_jiansheng_4:onCheckAttack(attacker, defender, skill, atkData, dmg)
	-- 伏魔状态或已经满了不需要加
	if self:isSpStatus() or self._count >= self._maxNum then return dmg end
	-- 加一个修炼的buff
	local buffObj = self:getBuff(self._buffIdP)
	attacker:checkCreateBuffByObj(buffObj, attacker, skill)

	self:skillLog("剑圣增加修炼层数")

	return dmg
end

-- 技能结束后检查
function Skill_jiansheng_4:onAfterSkill(selfHero, skill)
	local result = true
	-- 如果已经是伏魔状态了则不需要检查了
	if self:isSpStatus() then return result end
	-- 如果修炼层数达到要求，开始进入伏魔状态
	if self._count == self._maxNum then
		self:skillLog("剑圣满足伏魔条件，当前修炼层数:",self._count)
		-- result = false
		-- 改变待机状态
		selfHero:setUseSpStand(true)
		-- 清掉已经加上的修炼的buff
		selfHero.data:clearOneBuffByHid(self._buffIdP)
		-- 添加伏魔的加攻buff
		local buffObj = self:getBuff(self._buffIdX)
		selfHero:checkCreateBuffByObj(buffObj, selfHero, skill)

		self._round = self._lastRound

		-- 放出技能
		self._skill.isStitched = true

		selfHero.triggerSkillControler:pushOneSkillFunc(selfHero, function()
			-- 如果当前自己不能行动或对方已经死亡则不会进行攻击
			if SkillBaseFunc:isLiveHero(selfHero) and selfHero.data:checkCanAttack() then
				selfHero:checkSkill(self._skill, false, self._skill.skillIndex)
			else
				-- 执行下一项
				selfHero.triggerSkillControler:excuteTriggerSkill()
			end
		end)
	end

	return result
end

-- 敌方回合结束后
function Skill_jiansheng_4:onEnemyRoundEnd(selfHero)
	if not self:isSelfHero(selfHero) then return end
	if self._round == 0 then return end

	self._round = self._round - 1
	-- 伏魔状态结束
	if not self:isSpStatus() then
		self:skillLog("剑圣伏魔状态结束")
		-- 改变待机状态
		selfHero:setUseSpStand(false)
		-- 清掉伏魔buff
		selfHero.data:clearOneBuffByHid(self._buffIdX)
	end
end

-- 是否特殊状态
function Skill_jiansheng_4:isSpStatus()
	return self._round > 0
end

-- 设置符文的可见度
function Skill_jiansheng_4:_setSlotVisible()
	if Fight.isDummy then return end

	local selfHero = self:getSelfHero()
	for i,v in ipairs(self._slots) do
		selfHero.myView:setSlotVisible(v, i <= self._count)
	end
end

-- 被加buff时
function Skill_jiansheng_4:onBeUseBuff(selfHero, attacker, skill, buffObj)
	-- 如果是伏魔状态下 不需要处理
	if self:isSpStatus() then return end
	-- 如果是当前buff则继续累计次数
	if buffObj.hid == self._buffIdP and self._count < self._maxNum then
		self._count = self._count + 1
		self:skillLog("获得一个修炼buff,增长层数,当前层数:",self._count)
		-- 控制显示层
		self:_setSlotVisible()
	end
end

-- 被清除buff时
function Skill_jiansheng_4:onBuffBeClear(selfHero, buffObj)
	-- 如果是伏魔状态下不需要处理
	if self:isSpStatus() then return end
	-- 如果清理的是当前的buff
	if buffObj.hid == self._buffIdP and self._count > 0 then
		self._count = self._count - 1
		self:skillLog("失去一个修炼buff,减少层数,当前层数:",self._count)
		-- 控制显示层
		self:_setSlotVisible()
	end
end

return Skill_jiansheng_4