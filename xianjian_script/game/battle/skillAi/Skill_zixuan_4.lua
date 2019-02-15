--[[
	Author:李朝野
	Date: 2017.7.18
	Modify: 2018.03.13
]]

--[[
	紫萱被动

	技能描述：
	己方阵亡的伙伴会被紫萱用傀儡虫复活（无生命，不可被攻击），会正常释放小技能对敌人进行攻击，但是不会获得怒气；
	持续两回合；
	
	脚本处理部分：
	己方阵亡的伙伴被马上作为傀儡复活

	参数：
	action 释放技能时播的人物动作（从source表头索引）
	buffId 傀儡buff
]]

local Skill_zixuan_4 = class("Skill_zixuan_4", SkillAiBasic)

function Skill_zixuan_4:ctor(skill,id,action,buffId)
	Skill_zixuan_4.super.ctor(self, skill,id)

	self:errorLog(action, "action")
	self:errorLog(buffId, "buffId")
	
	self._buffId = buffId
	self._action = action or "none"

	self._diedHero = {} -- 我方死亡的人
	self._dieEnemyHero = {} -- 敌方死亡的人
end

-- 有人死亡就触发
function Skill_zixuan_4:onOneHeroDied( attacker, defender )
	if self:isSelfHero(defender) then
		self:skillLog("紫萱死亡，将要被傀儡复活的人物一起死亡")
		for i,v in ipairs(self._diedHero) do
			if v.reliveState == 3 then
				v.reliveState = 2
				-- 也要从diedArr里移除
				local diedArr = v.diedArr
				--移除自己
				table.removebyvalue(diedArr, v)
				-- 在这里做死亡动作会导致无法正常死亡，此时可能不是最后一个攻击包
				-- v:justFrame(Fight.actions.action_die, nil, true)
				v:doHeroDie(true)
			end
		end

		self._diedHero = {}
		return 
	end
	local selfHero = self:getSelfHero()
	-- 中立怪不复活
	if defender:getHeroProfession() == Fight.profession_neutral then
		return
	end
	
	-- boss不复活
	if defender:getHeroProfession() == Fight.profession_boss then
		return
	end

	-- 特殊的怪不复活（姥姥）须臾仙境
	if BattleControler:getBattleLabel() == GameVars.battleLabels.wonderLandPve then
		if defender.data:isRobootNPC() and defender.camp == selfHero.camp then
			return
		end
	end

	-- 需要根据以前的标记来重置标记（如果双方都有紫萱这很必要）
	local oldState = defender.reliveState
	if defender.reliveState == 0 then
		defender.reliveState = 3
	else
		-- return
		-- 标记一下这里要改
	end

	if defender.camp == selfHero.camp then -- 自己队友
		self:skillLog("队友加入紫萱的复活数组",defender.data.posIndex)
		self._diedHero[#self._diedHero + 1] = defender
	else
		-- 需要判断傀儡虫
		if not defender.data:checkHasOneBuffType(Fight.buffType_klchong) then
			defender.reliveState = oldState
			return 
		end
		
		self:skillLog("敌方加入紫萱的复活数组",defender.data.posIndex)

		local num = #self._dieEnemyHero
		self._dieEnemyHero[num + 1] = defender
		-- 注册一个攻击结束后复活敌方的函数，如果已经注册过了就不再注册了
		if num == 0 then
			-- 动作时长
			local frame = nil
			if selfHero.data:checkCanAttack() then
				frame = selfHero:getTotalFrames(self._action)
			end
			selfHero.triggerSkillControler:pushOneSkillFunc(selfHero, function()
				self:skillLog("紫萱复活敌方人作为傀儡")
				-- 做个动作
				if frame and not Fight.isDummy then
					selfHero:gotoFrame(self._action)
				end
				self:_reliveHero(self._dieEnemyHero)

				self._dieEnemyHero = {}
			end, frame or 10)
		end
	end

	-- 处理下显示
	defender:setOpacity(0, 15)
	if defender.healthBar then
		-- 不能用visible因为上面有点击事件
		defender.healthBar:opacity(0)
	end
end

-- 回合开始前判定
function Skill_zixuan_4:onMyRoundStart( selfHero )
	if self:isSelfHero(selfHero) then
		if not self:_chkHasRelive(self._diedHero) then
			return
		else
			if not Fight.isDummy then
				selfHero:setRoundReady(Fight.process_myRoundStart, false)
				-- 进行了复活做一个动作
				selfHero:justFrame(self._action)
				-- 做完这个动作恢复人物该有的状态
				local totalFrames = selfHero:getTotalFrames(self._action)
				selfHero:pushOneCallFunc(tonumber(totalFrames), "setRoundReady",{Fight.process_myRoundStart, true})
			end
		end

		-- 复活
		self:_reliveHero(self._diedHero)
		self._diedHero = {}
	end
end

-- 复活傀儡操作
function Skill_zixuan_4:_reliveHero(arr)
	local selfHero = self:getSelfHero()

	for _,hero in ipairs(arr) do		
		-- 复活一下血量为0.5，加傀儡buff
		if hero.reliveState == 3 then
			self:skillLog("紫萱执行复活傀儡操作，复活队伍%s,%s号位", hero.camp, hero.data.posIndex)
			-- 复活
			hero:doReliveAction(true)
			-- 挪回原位
			hero:updatePosAfterQuick()

			hero:setOpacity(255)
			-- 血量设定为1
			hero.data:changeValue(Fight.value_health, 1, Fight.valueChangeType_num)
			-- 清除自身所有buff
			hero.data:clearBuffByKind(Fight.buffKind_huai,true)
			hero.data:clearBuffByKind(Fight.buffKind_hao,true)

			-- 上傀儡buff
			local buffObj = self:getBuff(self._buffId, self._skill)
			if hero.camp ~= selfHero.camp then
				-- 敌人作为负面buff
				buffObj.kind = Fight.buffKind_huai
			end
			hero:checkCreateBuffByObj(buffObj, selfHero, self._skill)
			
			hero.reliveState = 2

			hero.puppeteer = selfHero.camp
			-- 调整朝向
			hero:setWay(hero.way)
		end
	end
end

-- 查找是否有可复活的人
function Skill_zixuan_4:_chkHasRelive(arr)
	if not arr or #arr == 0 then return false end

	for _,hero in ipairs(arr) do
		if hero.reliveState == 3 then
			return true
		end
	end

	return false
end

return Skill_zixuan_4