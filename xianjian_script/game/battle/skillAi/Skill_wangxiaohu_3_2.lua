-- author:pangkangning
-- data:2017.11.10
-- 王小虎，大招扩充2，需要新增效果，在释放完毕后，为自身增加免疫buffs枚举效果、不可被驱散
-- buffs 免疫的buffs枚举
-- round 回合数

--[[
	Modify: 2018.03.12 lcy
	继承大招扩充1同时修正一些写法问题
	
	参数:
	@@rate 伤害降低率
	@@lastRound 持续回合数
	@@buffs 免疫的buffs枚举
	@@round 免疫buff的回合数
]]

local Skill_wangxiaohu_3_2 = class("Skill_wangxiaohu_3_2", SkillAiBasic)

function Skill_wangxiaohu_3_2:ctor(skill,id, rate,lastRound,buffs,round)
	Skill_wangxiaohu_3_2.super.ctor(self,skill,id, rate,lastRound)

	self:errorLog(buffs, "buffs")
	self:errorLog(round, "round")

	self._buffs = string.split(buffs, "_")
	self._round = tonumber(round)
	self._nowRound = 0 --当前回合数

	table.map(self._buffs, function( v, k )
		return tonumber(v)
	end)
end
-- 判断是否有免疫
function Skill_wangxiaohu_3_2:onBeforeUseBuff(selfHero, attacker, skill, buffObj)
	local result = true
	if self._nowRound > 0 then
		-- 满足条件
		if array.isExistInArray(self._buffs, buffObj.type) then
			self:skillLog("王小虎阻止buff%s生效", buffObj.hid)
			result = false
		end
	end

	return result
end
-- 技能释放后
function Skill_wangxiaohu_3_2:onAfterSkill(selfHero,skill)
	self._nowRound = self._round --免疫生效
	return true
end
-- 我方回合结束后、减少免疫回合数
function Skill_wangxiaohu_3_2:onMyRoundEnd(selfHero)
	if self._nowRound > 0 then
		self._nowRound = self._nowRound -1
	end
end


return Skill_wangxiaohu_3_2