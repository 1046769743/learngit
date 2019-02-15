--[[
	Author:李朝野
	Date: 2017.08.09
	Modify: 2018.03.16
]]

--[[
	徐长卿大招扩充2（联动被动）

	技能描述：
	给自己也额外增加一个等量吸收护盾；

	脚本处理部分：
	给自己也添加护盾

	参数：
	buffId 护盾buffId
	rate 每个符文对应的value
]]
local Skill_xuchangqing_3_1 = require("game.battle.skillAi.Skill_xuchangqing_3_1")
local Skill_xuchangqing_3_2 = class("Skill_xuchangqing_3_2", Skill_xuchangqing_3_1)


function Skill_xuchangqing_3_2:ctor(...)
	Skill_xuchangqing_3_2.super.ctor(self,...)
end

function Skill_xuchangqing_3_2:onCheckAttack(attacker, defender, skill, atkData, dmg)
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
		-- 根据符文数量改变buff的值
		buffObj.value = math.round(buffObj.value * (1 + self._rate * count / 10000))
		hero:checkCreateBuffByObj(buffObj,selfHero,self._skill)
		skill4expand:useRune(count)
	end
	-- 不是自己则给自己也加一个
	if hero ~= selfHero then
		self:skillLog("徐长卿大招扩充2给自己也加一个同样的护盾")
		local buffObj = ObjectBuff.new(self._buffId,self._skill)
		-- 根据符文数量改变buff的值
		buffObj.value = math.round(buffObj.value * (1 + self._rate * count / 10000))
		selfHero:checkCreateBuffByObj(buffObj,selfHero,self._skill)
	end

	return dmg
end

return Skill_xuchangqing_3_2