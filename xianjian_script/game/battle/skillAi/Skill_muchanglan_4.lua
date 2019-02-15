--[[
	Author:李朝野
	Date: 2018.01.08
]]

--[[
	暮菖兰被动

	技能描述:
	飞花伴霞，第二回合起，每三个回合（2,5,8,11……）此回合首次受到暮菖兰攻击的目标，立刻结算一次身上持续类伤害；
	如果在飞花伴霞状态下开启怒气仙术，获得惩罚——在下回合开始前进入眩晕状态，持续一回合。

	脚本处理部分:
	记录回合，达到一定回合间隔后，使受攻击的目标立刻结算身上的状态；
	需要记录生效人物保证不再多次触发;
	如果满足惩罚条件，为自己增加眩晕。

	参数:
	@@rSpace 回合间隔
	@@buffs 目标buff类型 2_3 （脚本里会额外判断是否为持续类型）
	@@atkId 眩晕攻击包
	@@slots 需要控制的slots的名字 _ 分割 如"fu5_fu6_fu7_fu8" 激活时全部显示
]]
local Skill_muchanglan_4 = class("Skill_muchanglan_4", SkillAiBasic)

function Skill_muchanglan_4:ctor(skill,id, rSpace, buffs, atkId, slots)
	Skill_muchanglan_4.super.ctor(self,skill,id)

	self:errorLog(rSpace, "rSpace")
	self:errorLog(buffs, "buffs")
	self:errorLog(atkId, "atkId")
	self:errorLog(slots, "slots")

	self._rSpace = tonumber(rSpace or 1)
	self._buffs = string.split(buffs, "_")

	table.map(self._buffs, function( v, k )
  		return tonumber(v)
  	end)

	self._atkData = ObjectAttack.new(atkId)

	self._roundCount = 0 -- 记录回合
	self._isActive = false -- 记录是否激活了飞花伴霞
	self._record = {} -- 记录施加过被动的人，保证每人指回受到一次作用
	self._willBStun = false -- 标记是否将被眩晕惩罚

	-- 符文名的映射表
	self._aniSlots = string.split(slots, "_")
end

-- 回合开始前检查是否激活了状态
function Skill_muchanglan_4:onMyRoundStart(selfHero)
	if self:isSelfHero(selfHero) then
		self._roundCount = self._roundCount + 1
		-- 2或满足间隔的回合
		if self._roundCount == 2 or (self._roundCount - 2) % self._rSpace == 0 then
			self._isActive = true -- 标记激活
			self:skillLog("暮菖兰飞花伴霞激活，当前回合计数:%s",self._roundCount)
			-- 做一些表现相关的内容
			self:_setSlotVisible(true)
		end

		-- 是否该被惩罚
		if self._willBStun then
			self._willBStun = false
			self:skillLog("暮菖兰受到惩罚，对自己施加攻击包:%s",self._atkData.hid)
			-- 给自己做眩晕的攻击包
			selfHero:sureAttackObj(selfHero,self._atkData,self._skill)
		end
	end
end

-- 回合结束后取消激活状态
function Skill_muchanglan_4:onMyRoundEnd(selfHero)
	if not self:isSelfHero(selfHero) then return end

	if self._isActive then
		self._isActive = false
		-- 重置一下标记
		for k,_ in pairs(self._record) do
			self._record[k] = false
		end
		-- 取消激活状态，做一些表现相关的内容
		self:_setSlotVisible(false)
	end
end

-- 放大招时候做检测
function Skill_muchanglan_4:onCheckAttack(attacker,defender,skill,atkData, dmg)
	if self._isActive and skill.skillIndex == Fight.skillIndex_max then
		self:skillLog("暮菖兰在飞花伴霞状态下开启了怒气仙术，下回合开始前将受到惩罚")
		self._willBStun = true
	end
end

-- 最后一个攻击包之后根据自己的状态为敌人强制结算持续类buff
function Skill_muchanglan_4:onAfterAttack(attacker, defender, skill, atkData)
	-- 激活了，没作用过
	if self._isActive and not self._record[defender] then
		self:skillLog("暮菖兰在飞花伴霞状态下将强制结算阵营:%s,%s号位配置的buff",defender.camp,defender.data.posIndex)
		-- 立刻结算目标类型buff
		for _,bt in ipairs(self._buffs) do
			local buffs = defender.data:getBuffsByType(bt)
			if buffs then
				for _,buff in ipairs(buffs) do
					-- 回合结算的buff
					if buff and buff.runType == Fight.buffRunType_round then
						defender.data:doBuffFunc(buff)
					end
				end
			end
		end
		self._record[defender] = true
	end
end

-- 控制slot显隐
function Skill_muchanglan_4:_setSlotVisible(value)
	if Fight.isDummy then return end

	for _,name in ipairs(self._aniSlots) do
		self:getSelfHero().myView:setSlotVisible(name, value)
	end
end

return Skill_muchanglan_4