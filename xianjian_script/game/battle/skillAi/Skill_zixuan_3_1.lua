--[[
	Author:李朝野
	Date: 2018.03.13
]]

--[[
	紫萱大招扩充1

	技能描述：
	释放怒气仙术时，每有一个傀儡增加X点攻击力
	
	脚本处理部分：
	释放大招之前，根据傀儡数量增加攻击力

	参数：
	@@buffId 加攻buffId
	@@frame 执行加攻的帧数，需要在第一个攻击包之前才能生效
]]
local Skill_zixuan_3 = require("game.battle.skillAi.Skill_zixuan_3")

local Skill_zixuan_3_1 = class("Skill_zixuan_3_1", Skill_zixuan_3)

function Skill_zixuan_3_1:ctor(skill,id, buffId, frame)
	Skill_zixuan_3_1.super.ctor(self,skill,id)

	self:errorLog(buffId, "buffId")

	self._buffId = buffId or 0

	-- 注册
	self:registSkillFunc(5, c_func(self.frameFunc,self))
end

-- 要注册的事件
function Skill_zixuan_3_1:frameFunc(attacker,skill,frame)
	local selfHero = self:getSelfHero()

	-- 统计敌我双方属于我方的傀儡数量
	local function calKuiLei( arr )
		local num = 0
		for _,hero in ipairs(arr) do
			if hero.data:checkHasOneBuffType(Fight.buffType_kuilei) 
				and hero.puppeteer == selfHero.camp 
			then
				num = num + 1
			end
		end
		return num
	end

	local count = calKuiLei(selfHero.campArr)
	count = count + calKuiLei(selfHero.toArr)

	-- 要加攻击力
	if count > 0 then
		self:skillLog("对方有%s个傀儡，紫萱将为自己增加攻击力",count)
		local buffObj = self:getBuff(self._buffId)
		buffObj.value = tonumber(buffObj.value) * count
		if buffObj.calValue then
			buffObj.calValue.rate = tonumber(buffObj.calValue.rate) * count
			buffObj.calValue.n = tonumber(buffObj.calValue.n) * count
		end

		--做加攻
		selfHero:checkCreateBuffByObj(buffObj, selfHero, skill)
	end
end

return Skill_zixuan_3_1