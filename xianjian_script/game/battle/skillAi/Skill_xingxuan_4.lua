--[[
	Author:李朝野
	Date: 2017.09.15
	Modify: 2018.03.10
]]


--[[
	星璇被动

	技能描述：
	回合开始前，敌方每有一个气血比例低于X%的人，星璇提升%x暴击率;

	脚本处理部分：
	回合开始前对条件做检查，添加buff

	参数：
	rate 触发血量
	buffId 提升暴击率的buffId（配置为不可驱散）
	action 加buff时做的动作
]]
local Skill_xingxuan_4 = class("Skill_xingxuan_4", SkillAiBasic)

function Skill_xingxuan_4:ctor(skill,id, rate, buffId, action)
	Skill_xingxuan_4.super.ctor(self, skill, id)
	
	self:errorLog(rate, "rate")
	self:errorLog(buffId, "buffId")
	self:errorLog(action, "action")

	self._rate = (tonumber(rate) or 5000) / 10000
	self._buffId = buffId or 0
	self._action = action or "none"
end
--[[
	我方回合前做检查
]]
function Skill_xingxuan_4:onMyRoundStart(selfHero)
	if not self:isSelfHero(selfHero) then return end

	-- 检查敌方血量
	local toArr = selfHero.toArr
	local num = 0
	for _,hero in ipairs(toArr) do
		-- 满足血量条件
		if hero.data:getAttrPercent(Fight.value_health) <= self._rate then
			num = num + 1
		end
	end

	if num > 0 then
		self:skillLog("敌方气血低于:%s的人有:%s个",self._rate,num)
		-- selfHero:checkCreateBuffByObj(self:getBuff(self._buffId), selfHero, self._skill)
		local buffObj = self:getBuff(self._buffId)
		buffObj.value = tonumber(buffObj.value) * num
		if buffObj.calValue then
			buffObj.calValue.rate = tonumber(buffObj.calValue.rate) * num
			buffObj.calValue.n = tonumber(buffObj.calValue.n) * num
		end

		-- 做加buff
		selfHero:checkCreateBuffByObj(buffObj, selfHero, skill)

		self:_chkDoAction()
	end
end

--[[
	处理做动作的函数
]]
function Skill_xingxuan_4:_chkDoAction()
	if not Fight.isDummy then
		local selfHero = self:getSelfHero()
		-- 可攻击才做动作
		if selfHero.data:checkCanAttack() and self._action ~= "none" then
			selfHero:setRoundReady(Fight.process_myRoundStart, false)
			selfHero:justFrame(self._action)
			-- 做完动作再准备完成
			local totalFrames = selfHero:getTotalFrames(self._action)
			selfHero:pushOneCallFunc(tonumber(totalFrames), "setRoundReady", {Fight.process_myRoundStart, true})
		end
	end
end

return Skill_xingxuan_4