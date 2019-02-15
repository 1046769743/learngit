--[[
	Author:李朝野
	Date: 2018.01.13
	Modify: 2018.03.19
]]

--[[
	南宫煌被动

	技能描述:
	单回合承受50%伤害，则获得盾（五灵轮形态）转换待机动作，持续2回合;

	脚本处理部分:
	监听自己受击情况，当回合内损失血量超过限制则给自己加护盾的buff;
	buff与五灵轮形态强相关，有盾就是有此形态

	参数:
	@@hpPer 损失血量限制（万分）
	-- @@buffId  此buff从大招中获取
]]
local Skill_nangonghuang_4 = class("Skill_nangonghuang_4", SkillAiBasic)

function Skill_nangonghuang_4:ctor(skill,id, hpPer)
	Skill_nangonghuang_4.super.ctor(self, skill,id)

	self:errorLog(hpPer, "hpPer")

	self._hpPer = tonumber(hpPer or 0) / 10000
	
	self._buffId = nil
	self._totalDmg = 0
	self._flag = false -- 标志是否已经开启了状态
end
-- 检查加buff
function Skill_nangonghuang_4:onBeHit(attacker,defender,skill,atkData,atkResult,dmg)
	if self._flag then return end
	-- 额定血量
	local hp = defender.data:maxhp() * self._hpPer
	-- 需要剪切伤害
	if self._totalDmg + dmg > hp then
		self:skillLog("南宫煌被动触发，当前回合已经损失血量",self._totalDmg)
		self._flag = true
		self:_getTreatShield()
	else
		self._totalDmg = self._totalDmg + dmg
	end
end

-- 我方回合开始前重置标记
function Skill_nangonghuang_4:onMyRoundStart(selfHero)
	if not self:isSelfHero(selfHero) then return end

	if self._flag then
		self._flag = false
	end

	-- 重置伤害数
	self._totalDmg = 0
end

-- 获得治疗护盾
function Skill_nangonghuang_4:_getTreatShield()
	local selfHero = self:getSelfHero()
	-- 加buff
	local buffObj = self:getBuff(self:_getBuffId())
	selfHero:checkCreateBuffByObj(buffObj, selfHero, self._skill)
	-- 设置特殊动作
	-- selfHero:setUseSpStand(true)

	self:skillLog("给南宫煌添加治疗护盾buffId:%s",self:_getBuffId())
end

-- 当有buff消失时
function Skill_nangonghuang_4:onBuffBeClear(selfHero, buffObj)
	-- 是当前的buff
	if buffObj.hid == self:_getBuffId() then
		-- 取消特殊动作
		selfHero:setUseSpStand(false)
	end
end

-- 添加此buff后
function Skill_nangonghuang_4:onBeUseBuff(selfHero,attacker,skill,buffObj)
	-- 是当前的buff
	if buffObj.hid == self:_getBuffId() then
		-- 设置特殊动作
		selfHero:setUseSpStand(true)
	end
end

-- 获取buffId
function Skill_nangonghuang_4:_getBuffId()
	if not self._buffId then
		local selfHero = self:getSelfHero()
		-- 大招
		local maxSkill = selfHero.data:getSkillByIndex(Fight.skillIndex_max)
		local skill3expand = maxSkill and maxSkill.skillExpand or nil

		if not skill3expand then return 0 end

		self._buffId = skill3expand:_getExBuffId()
	end

	return self._buffId
end

return Skill_nangonghuang_4