--[[
	Author:李朝野
	Date: 2017.08.09
	Modify: 2018.03.16
]]

--[[
	徐长卿大招（联动被动）

	技能描述：
	攻击敌方全体，并给己方气血比例最低奇侠增加护盾，每一枚符文提高一定护盾吸收量；

	脚本处理部分：
	根据当前符文量提升护盾吸收量

	参数：
	buffId 护盾buffId
	rate 每个符文对应的value
]]
local Skill_xuchangqing_3 = class("Skill_xuchangqing_3", SkillAiBasic)

function Skill_xuchangqing_3:ctor(skill,id, buffId, rate)
	Skill_xuchangqing_3.super.ctor(self, skill, id)

	self:errorLog(buffId, "buffId")
	self:errorLog(rate, "rate")

	-- self._buffObj = ObjectBuff.new(buffId,self._skill)
	self._buffId = buffId
	self._rate = tonumber(rate) or 0

	self._flag = false -- 标记一个技能只释放一次
end

function Skill_xuchangqing_3:onCheckAttack( attacker,defender,skill,atkData, dmg )
	if self._flag then return dmg end

	local selfHero = self:getSelfHero()
	-- 被动技能
	local specialSkill = selfHero.data:getSpecialSkill()
	local skill4expand = specialSkill and specialSkill.skillExpand or nil

	if not skill4expand then return end

	local count = skill4expand:getRuneNum()

	local hero = SkillBaseFunc:getMinHpHero(selfHero.campArr)

	if hero then
		self:skillLog("徐长卿符文数:%s，大招使用符文，血量百分比最低者为:%s号位", count, hero.data.posIndex)
		self._flag = true
		
		local buffObj = ObjectBuff.new(self._buffId,self._skill)
		buffObj.value = math.round(buffObj.value * (1 + self._rate * count / 10000))
		-- 根据符文数量改变buff的值
		hero:checkCreateBuffByObj(buffObj,selfHero,self._skill)
		skill4expand:useRune(count)
	end

	return dmg
end

function Skill_xuchangqing_3:onAfterSkill(selfHero, skill)
	-- 重置
	self._flag = false

	return true
end

return Skill_xuchangqing_3