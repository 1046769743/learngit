--[[
	Author:李朝野
	Date: 2017.06.22
	Modify: 2018.03.16
]]

--[[
	徐长卿被动（此脚本部分逻辑需要填在被动技能处才能生效）

	技能描述：
	徐长卿被攻击时，获得1枚符文，符文上限为4枚；——去掉了防御增加

	脚本处理部分：
	徐长卿每受击一次获得一个符文

	参数：
	@@slots 需要控制的slots的名字 _ 分割 如"fu5_fu6_fu7_fu8" 填写顺序就是显示顺序
]]
local Skill_xuchangqing_4 = class("Skill_xuchangqing_4", SkillAiBasic)

function Skill_xuchangqing_4:ctor(skill,id, slots)
	Skill_xuchangqing_4.super.ctor(self, skill, id)

	self:errorLog(slots, "slots")

	-- 记录将要执行的索引
	self._idx = 0
	-- 最大叠加次数
	self._max = 4

	-- 符文名的映射表
	self._aniSlots = string.split(slots, "_")
end

--[[
	被攻击后的触发
]]
function Skill_xuchangqing_4:onAfterHited(selfHero,attacker,skill,atkData)
	if selfHero.data:hp()<0 then
		--徐长卿血量大于0才有效
		return
	end
	-- 已经加满不再加
	if self._idx >= self._max then
		return 
	end

	self._idx = self._idx + 1

	self:_setSlotVisible()
end

-- 设置符文的可见度
function Skill_xuchangqing_4:_setSlotVisible()
	if Fight.isDummy then return end
	for i,v in ipairs(self._aniSlots) do
		self:getSelfHero().myView:setSlotVisible(v,i <= self._idx)
	end
end

-- num 使用的符文个数
function Skill_xuchangqing_4:useRune( num )
	-- 减少符文数量
	local result = self._idx - num
	if result <= 0 then result = 0 end
	self._idx = result

	self:_setSlotVisible()
end
-- 获取符文个数
function Skill_xuchangqing_4:getRuneNum()
	return self._idx
end

return Skill_xuchangqing_4