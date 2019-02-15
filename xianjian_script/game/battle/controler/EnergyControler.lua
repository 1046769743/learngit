--[[
	怒气控制器
	lcy
	2017.9.16
]]
local Fight = Fight
-- local BattleControler = BattleControler
EnergyControler = class("EnergyControler")

EnergyControler.controler = nil -- 游戏控制器
EnergyControler.logical = nil -- 逻辑控制器
--[[
	怒气信息(怒气信息分为整怒气和散怒气)
	散怒气用来积累整怒气，兑换关系为
	5散 = 当前兑换率 * 1
	camp = {
		entire = 0,
		piece = 0,
		rate = 1, -- 这里有一个设定，每满一次增长率会+1
	}
]]
EnergyControler.energyInfo = nil 
-- EnergyControler.maxEntireEnergy = Fight.maxEntireEnergy  -- 最大整怒气点数
EnergyControler.maxPieceEnergy = Fight.maxPieceEnergy	-- 最大散怒气点数
EnergyControler.maxP2E_Rate = Fight.maxP2E_Rate	-- 最大怒气转换率
EnergyControler.energyCache = nil -- 怒气缓存，如果一个人被点击放大招排队了，技能又没放出来，会退还；只存entire
-- EnergyControler.initEnergy = 0 --初始化的怒气点数
-- EnergyControler.roundEnergyMax = Fight.roundEnergyMax --每回合恢复怒气最大值
-- {} 

-- 构造
function EnergyControler:ctor(controler)
	self.controler = controler
	self.logical = controler.logical
	-- self.maxEntireEnergy = Fight.maxEntireEnergy --默认值
	-- self.initEnergy = 0
	-- self.roundEnergyMax = Fight.roundEnergyMax
	self.energyCache = {
		[Fight.camp_1] = {},
		[Fight.camp_2] = {},
	}
	-- 初始化怒气相关信息(分敌我双方)

	local eInfo = self.controler.levelInfo:getBattleEnergyRule()
	self.energyInfo = {}
	for i=1,2 do
		local tmp = {
				entire = 0,
				piece = 0,
				rate = 1,
				maxEntire = Fight.maxEntireEnergy,-- 最大整怒气点数
				initEnergy = 0 ,--初始化的怒气点数
				roundEnergyMax = eInfo.roundEnergyMax,--每回合恢复怒气最大值
			}
		table.insert(self.energyInfo,tmp)
	end
end

-- 设置初始怒气信息 v1怒气初始值增量;v2怒气最大值增量;v3怒气每回合恢复最大量增值
-- function EnergyControler:setInitEnergy( v1,v2,v3 )
-- 	self.initEnergy = v1 or self.initEnergy
-- 	self.maxEntireEnergy = v2 or self.maxEntireEnergy
-- 	self.roundEnergyMax = v3 or self.roundEnergyMax
-- 	echoError ("设置初始怒气====",v1,v2,v3)
-- end

function EnergyControler:getInitEnergy(camp)
	return self.energyInfo[camp].initEnergy
end
function EnergyControler:getMaxEntireEnergy(camp)
	return self.energyInfo[camp].maxEntire
end
function EnergyControler:getEntire(camp )
	return self.energyInfo[camp].entire
end
-- 获取回合最大怒气
function EnergyControler:getRoundEnergyMax(camp)
	return self.energyInfo[camp].roundEnergyMax
end

-- 获取怒气信息
function EnergyControler:getEnergyInfo(camp)
	return self.energyInfo[camp]
end
-- 设定最大怒气上限[改方法需要在setEnergyInfo之前调用]
function EnergyControler:setMaxEntireEnergy( camp,energy )
	if self.energyInfo[camp].maxEntire ~= energy then
		self.energyInfo[camp].maxEntire = energy
		-- 跑一条消息通知UI怒气相关变化
		FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_MAX_ENERGY_CHANGE)
	end
end
-- 设定怒气信息
function EnergyControler:setEnergyInfo(eInfo, camp)
	local eInfo = eInfo or {}
	-- self.energyInfo[camp] = eInfo
	for k,v in pairs(eInfo) do
		self.energyInfo[camp][k] = v
	end

	self:checkVaild(camp)
	
	-- 重新set也要发一下消息
	local tmp = table.copy(self:getEnergyInfo(camp))
	tmp.camp = camp
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_ENERGY_CHANGE,tmp)
end
-- 设定大怒气
function EnergyControler:setEntire(camp, entire)
	if not camp or not entire then return end
	
	self.energyInfo[camp].entire = entire

	self:checkVaild(camp)
	-- 重新set也要发一下消息
	local tmp = table.copy(self:getEnergyInfo(camp))
	tmp.camp = camp
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_ENERGY_CHANGE,tmp)
end
-- 检查数据有效性
function EnergyControler:checkVaild( camp )
	local function chk(eInfo)
		if eInfo.entire > eInfo.maxEntire then
			eInfo.entire = eInfo.maxEntire
		end
		if self:chkIsInfiniteEnergy() then
			eInfo.entire = eInfo.maxEntire
		end
		if eInfo.piece > self.maxPieceEnergy then
			eInfo.piece = self.maxPieceEnergy
		end
		if eInfo.rate > self.maxP2E_Rate then
			eInfo.rate = self.maxP2E_Rate
		end
	end
	if not camp then
		for k,eInfo in pairs(self.energyInfo) do
			chk(eInfo)
		end
	else
		chk(self.energyInfo[camp])
	end
end
--[[
	伙伴使用怒气(整)
	使用怒气返回成功与否，使用怒气时只会使用整怒气
]]
function EnergyControler:useEnergyByHero(hero)
	local result = false

	local value = hero:getEnergyCost()
	local camp = hero.camp
	local eInfo = self.energyInfo[camp]

	-- -- 影响怒气消耗的buff标记使用
	-- hero.data:useBuffsByType(Fight.buffType_energyCost)

	-- -- 怒气免费buff标记使用
	-- if hero.data:useBuffsByType(Fight.buffType_energyNoCost) then
	if hero.data:checkHasOneBuffType(Fight.buffType_energyNoCost) then
		-- 有怒气免费buff，不需要做下面的消耗逻辑
		return true
	end

	if eInfo.entire >= value then
		result = true
		
		if (not Fight.debugFullEnergy) and (not self:chkIsInfiniteEnergy()) then
			eInfo.entire = eInfo.entire - value
			-- 如果小怒气是满的，要把小怒气加上来
			-- if eInfo.piece >= self.maxPieceEnergy then
			-- 	self:energyP2E(0, camp, false)
			-- end
		end
		-- 怒气使用了，需要加至公式玩法数组中
		self.controler:udpateRefreshQuestion(value)

		-- if camp == 1 then
			local msg = table.copy(eInfo)
			msg.plus = false
			msg.camp = camp
			FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_ENERGY_CHANGE,msg)
		-- end
	end

	return result
end
--[[
	直接使用怒气(整)
	返回成功与否
]]
function EnergyControler:useEnergy(value, camp)
	local result = false
	if not value or not camp then return result end
	
	local eInfo = self.energyInfo[camp]

	if eInfo.entire >= value then
		result = true
		
		if (not Fight.debugFullEnergy) and (not self:chkIsInfiniteEnergy()) then
			eInfo.entire = eInfo.entire - value
			-- 如果小怒气是满的，要把小怒气加上来
			-- if eInfo.piece >= self.maxPieceEnergy then
			-- 	self:energyP2E(0, camp, false)
			-- end
		end

		-- if camp == 1 then
			local msg = table.copy(eInfo)
			msg.plus = false
			msg.camp = camp
			FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_ENERGY_CHANGE,msg)
		-- end
	end

	return result
end
--[[
	小怒气转换大怒气，返回最终值
	@@piece 小怒气
	@@camp 阵营
	@@noChange 不改变真实值
	return entire,piece,rate
]]
function EnergyControler:energyP2E(piece, camp, noChange)
	local resEntire = 0
	local resPiece = 0
	local resRate = 0
	local eInfo = self.energyInfo[camp]
	
	resEntire = eInfo.entire
	resPiece = eInfo.piece + piece
	resRate = eInfo.rate

	if resPiece < 0 then
		resPiece = 0
	end

	while resPiece >= self.maxPieceEnergy do
		-- 大怒气满了
		if resEntire >= eInfo.maxEntire then
			resEntire = eInfo.maxEntire
			-- 增长率也满了，小怒气直接积累满
			if resRate + 1 > self.maxP2E_Rate then
				resPiece = self.maxPieceEnergy
				break
			else -- 增长率没满这一管怒气用来增加增长率
				resRate = resRate + 1
				resPiece = resPiece - self.maxPieceEnergy
			end
		else -- 大怒气没满增加大怒气
			resEntire = resEntire + resRate
			if resEntire > self.maxEntire then
				resEntire = self.maxEntire
			end
			if resRate + 1 <= self.maxP2E_Rate then
				resRate = resRate + 1
			end
			resPiece = resPiece - self.maxPieceEnergy
		end
	end

	if not noChange then
		eInfo.entire,eInfo.piece,eInfo.rate = resEntire,resPiece,resRate
	end

	return resEntire,resPiece,resRate
end
--[[
	根据人物增加怒气
	日后有怒气来源需求可以区分
]]
function EnergyControler:_addEnergyByHero(etype, value, hero)
	if etype ~= Fight.energy_entire then
		echoError("加怒气的类型不对----",etype)
	end
	local result = false
	local camp = hero.camp

	if not hero.data:checkHasOneBuffType(Fight.buffType_fengnu) then
		result = true
		local eInfo = self.energyInfo[camp]

		if etype == Fight.energy_entire then
			eInfo.entire = eInfo.entire + value
			if eInfo.entire < 0 then
				eInfo.entire = 0
			end
		-- elseif etype == Fight.energy_piece then
		-- 	self:energyP2E(value, camp, false)
		end

		if eInfo.entire > eInfo.maxEntire then
			eInfo.entire = eInfo.maxEntire
		end
	end

	return result
end
--[[
	不通过人物直接给阵营增加怒气
]]
function EnergyControler:_addEnergyByCamp(etype, value, camp)
	local result = false
	local camp = camp

	if true then
		result = true
		local eInfo = self.energyInfo[camp]

		if etype == Fight.energy_entire then
			eInfo.entire = eInfo.entire + value
			if eInfo.entire < 0 then
				eInfo.entire = 0
			end
		-- elseif etype == Fight.energy_piece then
		-- 	self:energyP2E(value, camp, false)
		end

		if eInfo.entire > eInfo.maxEntire then
			eInfo.entire = eInfo.maxEntire
		end
	end

	return result
end
-- 增加怒气（这里应该写成根据hero增加怒气）
-- 有可能会减，先不改名
function EnergyControler:addEnergy(etype, value, hero, camp)
	local result = false
	local flag = false
	local tcamp = nil

	-- if etype ~= Fight.energy_entire and etype ~= Fight.energy_piece then
	if etype ~= Fight.energy_entire then
		echoError("怒气类型不对啊小伙子", etype)
	end

	if hero then
		result = self:_addEnergyByHero(etype, value, hero)
		tcamp = hero.camp
	elseif camp then
		result = self:_addEnergyByCamp(etype, value, camp)
		tcamp = camp
	else
		echoError("你啥都不告诉我你让我往哪加怒气啊,hero camp 为nil")
	end

	-- if result and tcamp == 1 then
	if result then
		local msg = table.copy(self.energyInfo[tcamp])
		msg.plus = value > 0
		msg.camp = tcamp
		FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_ENERGY_CHANGE, msg)
	end

	-- echo("当前怒气值===========",hero.camp, self.energyInfo[hero.camp])
	return result
end

-- 怒气值是否够用
function EnergyControler:isEnergyEnough(value, camp)
	return self.energyInfo[camp].entire >= value
end

-- 缓存当前怒气
-- 2018.3.2换一个怒气缓存结构，现在退怒气会精确到人
-- 2018.05.28 skillId 当是神器技能的时候，使用skillId做缓存的key
function EnergyControler:cacheEnergy(hero, skillId)
	if skillId then
		self.energyCache[hero.camp][skillId] = hero:getEnergyCost()
	else
		self.energyCache[hero.camp][hero] = hero:getEnergyCost()
	end
end

-- 出队一个缓存的怒气信息
-- 2018.05.28 skillId 当是神器技能的时候，使用skillId做缓存的key
function EnergyControler:dequequeEnergyCache(hero, skillId)
	if skillId then
		self.energyCache[hero.camp][skillId] = nil
	else
		self.energyCache[hero.camp][hero] = nil
	end
end

-- 根据人物恢复缓存怒气
function EnergyControler:returnEnergyByHero(hero)
	local camp = hero.camp
	local entire = self.energyCache[camp][hero]
	if entire then
		self:_addEnergyByCamp(Fight.energy_entire, entire, camp)
		FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_ENERGY_RETURN, table.copy(self.energyInfo[camp]))
	end
end

-- 根据队伍恢复缓存怒气
function EnergyControler:returnEnergyByCamp(camp)
	-- 将怒气一一退回
	echo("退还怒气", camp)

	local function _returnE( camp )
		for k,entire in pairs(self.energyCache[camp]) do
			self:_addEnergyByCamp(Fight.energy_entire, entire, camp)
			self.energyCache[camp][k] = nil
		end

		-- self.energyCache[camp] = {}

		FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_ENERGY_RETURN, table.copy(self.energyInfo[camp]))
	end

	if camp then
		_returnE(camp)
	else
		_returnE(Fight.camp_1)
		_returnE(Fight.camp_2)
	end
	
	-- FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_ENERGY_RETURN, table.copy(self.energyInfo[1]))
end
-- 答题玩法无限怒气
function EnergyControler:setInfiniteEnergy(b )
	self.infiniteEnergy = b
end
function EnergyControler:chkIsInfiniteEnergy()
	return self.infiniteEnergy or false
end

return EnergyControler