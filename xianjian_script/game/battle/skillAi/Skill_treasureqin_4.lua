--[[
	Author:李朝野
	Date: 2017.09.22
]]
--[[
	法宝琴被动

	技能描述：
	每损失1%的生命增加一定的攻击力；

	脚本处理部分：
	每损失1%的生命增加一定的攻击力，这个值会在每个自己的回合开始刷新，不会实时刷新；

	参数：
	rate 每1%对应攻击力的提升的万分比
]]
local Skill_treasureqin_4 = class("Skill_treasureqin_4", SkillAiBasic)

function Skill_treasureqin_4:ctor(skill,id,rate)
	Skill_treasureqin_4.super.ctor(self,skill,id)

	self:errorLog(rate, "rate")

	self._rate = tonumber(rate) or 0

	-- 记录已经提升的暴击伤害
	self._record = 0
end

--[[
	回合开始检查是否触发加攻击力的效果
]]
function Skill_treasureqin_4:onMyRoundStart(selfHero)
	if not self:isSelfHero(selfHero) then return end
	-- 检查当前损失血量
	if selfHero.data:hp() >= selfHero.data:maxhp() and self._record == 0 then return end
	
	local per = (selfHero.data:maxhp() - selfHero.data:hp()) / selfHero.data:maxhp()
	-- 提升的攻击力
	local atk = math.round(per * 100 * self._rate * selfHero.data:atk() / 10000)
	self:skillLog("法宝琴去除以前加的攻击力值:%s",self._record)
	-- 先减去以前提升的伤害
	selfHero.data:changeValue(Fight.value_atk , -self._record, 1, 0)
	self:skillLog("法宝剑重新提供攻击力值:%s",atk)
	-- 再重新提升伤害
	selfHero.data:changeValue(Fight.value_atk , atk, 1, 0)
	self._record = atk
end

return Skill_treasureqin_4