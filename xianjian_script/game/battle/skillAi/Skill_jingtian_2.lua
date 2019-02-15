--[[
	Author:李朝野
	Date: 2017.07.31
	Modify: 2018.03.08 👩
]]

--[[
	景天小技能

	技能描述：
	召唤残影剑，攻击一排敌人；
	如果只攻击了一个目标，则造成额外15%的伤害，并且获得一枚铜钱;

	脚本处理部分：
	如果只攻击了一个目标，则造成额外15%的伤害，并且获得一枚铜钱;

	参数：
	ratio 造成额外伤害的比例 如 1500
	slots 需要控制的slots的名字 _ 分割 如"fu5_fu6_fu7_fu8" 填写顺序就是显示顺序
]]
local Skill_jingtian_2 = class("Skill_jingtian_2", SkillAiBasic)


function Skill_jingtian_2:ctor(skill,id,ratio,slots)
	Skill_jingtian_2.super.ctor(self, skill,id)
	
	self:errorLog(ratio, "ratio")
	self:errorLog(slots, "slots")

	self._ratio = tonumber(ratio) / 10000 or 0

	-- 记录金币个数的索引
	self._idx = 0
	-- 最大叠加次数由大招决定这个字段用于记录
	self._max = nil

	-- 符文名的映射表
	self._aniSlots = string.split(slots, "_")

	-- 用来标记是否已经检查过（同时打死两个人逻辑上检查第二个人的时候就变成了单体）
	self._falg = false
end

--[[
	判断受击者同排是否有人
	由于在一个人受击的时候无法知道是否有人共同受击，
	所以对于景天攻击一排来说，用同排是否有人判断
]]
function Skill_jingtian_2:onCheckAttack(attacker, defender, skill, atkData, dmg)
	if self._flag then return dmg end

	self._flag = true
	
	-- 寻找同排人
	local toArr = defender.campArr

	local pos = math.ceil(defender.data.posIndex / 2)
	local flag = true

	for _,hero in ipairs(toArr) do
		if hero.data.gridPos.x == pos and hero ~= defender then
			flag = false
			break
		end
	end

	if flag then
		dmg = math.round(dmg * (1 + self._ratio))
		self:skillLog("景天攻击单体，造成额外伤害，小技能伤害", dmg)
		local selfHero = self:getSelfHero()

		if self._idx < self:getMaxTimes() then
			self:addRune(1)
		end
	end

	return dmg
end

-- 攻击结束重置内容
function Skill_jingtian_2:onAfterSkill(selfHero, skill)
	self._flag = false
	
	return true
end

-- 获取最大叠加次数
function Skill_jingtian_2:getMaxTimes()
	if not self._max then
		local selfHero = self:getSelfHero()
		-- 获取大招
		local maxSKill = selfHero.data:getSkillByIndex(Fight.skillIndex_max)
		local maxSkillExpand = maxSKill and maxSKill.skillExpand or nil

		if not maxSkillExpand then return end

		-- 最大叠加次数
		local max = maxSkillExpand:getMaxTimes()

		self._max = max
	end

	return self._max
end

-- 设置符文的可见度
function Skill_jingtian_2:_setSlotVisible()
	if Fight.isDummy then return end
	for i,v in ipairs(self._aniSlots) do
		self:getSelfHero().myView:setSlotVisible(v,i <= self._idx)
	end
end

-- num 使用的符文个数
function Skill_jingtian_2:useRune( num )
	-- 减少符文数量
	local result = self._idx - num
	if result <= 0 then result = 0 end
	self._idx = result

	self:_setSlotVisible()
end

-- num 增加符文个数
function Skill_jingtian_2:addRune( num )
	-- 增加符文数量
	local result = self._idx + num
	local max = self:getMaxTimes()
	if result > max then result = max end
	self._idx = result

	self:_setSlotVisible()
end

-- 获取符文个数
function Skill_jingtian_2:getRuneNum()
	return self._idx
end

return Skill_jingtian_2