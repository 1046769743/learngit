--[[
	Author:李朝野
	Date: 2017.10.09
]]

--[[
	法宝镜被动

	技能描述：
	拥有10%反击概率，当气血第一次低于35%时，反击概率提升20%（永久，不可被清除）；
	————反击，在对手攻击之后，对敌人造成自身攻击一定比例的伤害（无视对手防御值）；

	脚本处理部分：
	在敌人攻击之后对敌人造成一定伤害（视为反击）

	参数：
	rate 反击概率
	proportion 触发效果的生命比例
	hpexRate 满足触发血量提升的反击概率
]]
local Skill_treasurejing_4 = class("Skill_treasurejing_4", SkillAiBasic)

function Skill_treasurejing_4:ctor(skill,id, rate, proportion, hpexRate)
	Skill_treasurejing_4.super.ctor(self, skill, id)
	
	self:errorLog(rate, "rate")
	self:errorLog(proportion, "proportion")
	self:errorLog(hpexRate, "hpexRate")

	self._rate = tonumber(rate) or 0
	self._proportion = tonumber(proportion) or 0
	self._hpexRate = tonumber(hpexRate) or 0
	
	--[[
		params = {
			rate
			atkrate
			round
		}
	]]
	self._exParams = {} -- 其他条件影响的变量（类似于独立维护了一种buff）
	-- 血量触发（触发一次）
	self._hpTrigger = true

	self._skill._isFightBack = true
end

function Skill_treasurejing_4:onMyRoundStart(selfHero)
	if not self:isSelfHero(selfHero) then return end

	local temp = {}
	for _,p in ipairs(self._exParams) do
		p.round = p.round - 1
		if p.round > 0 then
			table.insert(temp, p)
		end
	end

	self._exParams = temp
end

function Skill_treasurejing_4:onAfterHited( selfHero,attacker,skill,atkData )
	-- 拼接技能不反击
	if skill.isStitched then
		return
	end
	-- 只反击活人
	if not SkillBaseFunc:isLiveHero(attacker) then
		return
	end
	if selfHero.data:hp()<=0 or attacker.data:hp()<=0 or selfHero.camp == selfHero.logical.currentCamp then
		--自己血量和敌人血量大于0才有效, 己方回合不反弹
		return
	end
	-- 不是伤害类型的不生效
	if not atkData:sta_dmg() then
		return
	end
	-- 不能行动的不反击
	if not selfHero.data:checkCanAttack() then
		return
	end
	-- 检查血量触发
	if self._hpTrigger and selfHero.data:hp()/selfHero.data:maxhp() <= self._proportion/10000 then
		self:skillLog("法宝镜血量符合要求触发被动，增加概率")
		self._hpTrigger = false
		self._rate = self._rate + self._hpexRate
	end

	-- 检查反击触发
	local rate = self._rate

	local exrate,exatkrate = self:_getExparamsValue()

	rate = rate + exrate

	self:skillLog("法宝镜当前触发反击的概率:%s",rate)
	if rate >= BattleRandomControl.getOneRandomInt(10001,1) then
		-- 改变伤害率
		if exatkrate > 0 then
			self._skill.damageR = self._skill.damageR + exatkrate
		end

		selfHero.triggerSkillControler:pushOneSkillFunc(selfHero, function()
			-- selfHero:checkSkill(self._skill, 0, false, nil)
			-- 攻击前发现自己不能动了，跳过反击
			if not selfHero.data:checkCanAttack() then
				-- 进行下一项
				return selfHero.triggerSkillControler:excuteTriggerSkill()
			else
				return selfHero:checkTreasure(1,self._skill.skillIndex)
			end
		end)

		-- 打完归位
		selfHero.triggerSkillControler:pushOneSkillFunc(selfHero, function()
			-- 需要在这里将伤害率改回 不然可能导致五灵的加成应用错误
			if exatkrate > 0 then
				self._skill.damageR = self._skill.damageR - exatkrate
			end
			--（这里由于实现方式暂时不容易跳过10帧）
			if selfHero.data:checkCanAttack() then
				selfHero:checkResumeTreasure()
				selfHero:movetoInitPos(2)
			end

		end, 10) -- 强给10帧
	end
end

-- 获取可变参数值
function Skill_treasurejing_4:_getExparamsValue()
	local rate = 0
	local atkrate = 0

	for _,p in ipairs(self._exParams) do
		if p.round ~= 0 then
			rate = rate + p.rate
			atkrate = atkrate + p.atkrate
		end
	end

	return rate,atkrate
end

-- 传入可变参数
function Skill_treasurejing_4:setExtraParams(round, rate, atkrate)
	local round = round or 0
	local rate = rate or 0
	local atkrate = atkrate or 0
	if round == 0 then
		return
	end
	local p = {
		round = round,
		rate = rate,
		atkrate = atkrate
	}
	table.insert(self._exParams, p)
end

return Skill_treasurejing_4