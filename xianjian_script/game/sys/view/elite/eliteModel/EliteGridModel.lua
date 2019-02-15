--[[
	Author: 张燕广
	Date:2017-07-27
	Description: 锁妖塔网格类
	1.网格中的一切都是事件EventModel
	2.网格非每帧刷新，依赖消息手动刷新状态
	3.网格状态或其事件的类型发生变化时，会更新Event的视图
]]

local EliteBasicModel = require("game.sys.view.elite.eliteModel.EliteBasicModel")
EliteGridModel = class("EliteGridModel",EliteBasicModel)

function EliteGridModel:ctor( controler ,xIdx,yIdx,gridInfo)
	EliteGridModel.super.ctor(self,controler)
	self.gridInfo = gridInfo
	self.gridType = self:checkGridType()

	self.xIdx = xIdx
	self.yIdx = yIdx

	-- 格子ID，后端设定的规则
	self.gid = xIdx .. "_" .. yIdx

	-- 格子状态
	self.GRID_STATUS = FuncEliteMap.GRID_STATUS

	-- 设置默认状态
	self.gridStatus = nil
	self.isHasSceneAlertMonster = nil

	-- 是否打开调试开关(打印格子坐标)
	self.DEBUG = false

	self.OPEN_CHEAT = false

	-- 初始化事件模型
	self:initEventModel()
	-- 初始化笼子模型
	-- self:initCageModel()
end

function EliteGridModel:registerEvent()
	EliteGridModel.super.registerEvent(self)
	-- 场景中是否有警戒怪 发生变化
	EventControler:addEventListener(EliteEvent.ELITE_IS_HAS_ALERT_MONSTER_CHANGE, self.setIsHasSceneAlertMonsterStatus, self)
end

-- 初始化事件model
function EliteGridModel:initEventModel()
	self.eventModel = self.controler:createEventModels(self)
end


-- 清空笼子
function EliteGridModel:clearCage()
	if self.eventModel then
		self.eventModel:clearCage()
		self.cageModel = nil
	end
end

-- 当主角运动到目标(指的是点击的格子)格子
function EliteGridModel:onCharArriveTargetGrid(event)
	if event and event.params then
		local grid = event.params.grid
		if grid and grid == self then
			if self.eventModel then
				self.eventModel:onCharArriveTargetGrid(grid)
			end
		end

		local charGridModel = self.controler.charModel:getGridModel()
		if charGridModel then
			if charGridModel.eventModel then
				charGridModel.eventModel:onCharArriveTargetGrid(grid)
			end
		end
	end
end

function EliteGridModel:getEventModel()
	return self.eventModel
end

-- 创建GridModel时，先设置view信息
function EliteGridModel:setViewInfo(ctn,xpos,ypos,zpos)
	self.viewCtn = ctn
	if xpos and ypos and zpos then
		self:setPos(xpos,ypos,zpos)
	end

	self:showDebugInfo()
end

-- @TEST 显示debug信息
function EliteGridModel:showDebugInfo()
	if self.DEBUG and not self.gridStatus then
		local xIdx = self.xIdx
		local yIdx = self.yIdx

		local ttf = display.newTTFLabel({text = "(" .. xIdx .. "," .. yIdx .. ")", size = 18, color = cc.c3b(255,0,0)})
		ttf:pos(self.pos.x,self.pos.y+10)
		ttf:zorder(100)

		self.ttfView = ttf
		self.viewCtn:addChild(ttf)
	end
end

-- 格子模型对应的数据对象
function EliteGridModel:setGridInfo(gridInfo)
	self.gridInfo = gridInfo
end

function EliteGridModel:getGridInfo()
	return self.gridInfo
end

-- 初始化格子视图
function EliteGridModel:initView(ctn,xpos,ypos,zpos,isHasSceneAlertMonster)
	local girdViewStatus = self.gridStatus
	if self:hasExplored() then
		-- 特殊处理普通障碍物
		if self:hasNormalObstracle() then
			girdViewStatus = self.GRID_STATUS.OBSTRACLE
		end
	end

	if isHasSceneAlertMonster then
		girdViewStatus = self.GRID_STATUS.CAN_NOT_EXPLORE
	end
	local view = self.controler:getGridView(girdViewStatus)
	local size = view:getContentSize()
	EliteGridModel.super.initView(self,ctn,view,xpos,ypos,zpos,size)
end

-- 是否有普通障碍物
-- 必须用数据判断，不能通过EventModel判断
function EliteGridModel:hasNormalObstracle()
	local xIdx,yIdx = self.xIdx,self.yIdx
	local gridInfo = self.gridInfo
	local gridType = gridInfo[FuncEliteMap.GRID_BIT.TYPE]

	if gridType == FuncEliteMap.GRID_BIT_TYPE.OBSTACLE then
		local eventId = gridInfo[FuncEliteMap.GRID_BIT.TYPE_ID]
		if eventId == FuncEliteMap.NORMAL_OBSTACLE_ID then
			return true
		end
		return false
	else
		return false
	end
end

-- 格子ID，可以根据ID快速查找指定格子
function EliteGridModel:getId()
	return self.gid
end

-- 是否有事件模型
function EliteGridModel:hasEventModel()
	return self.eventModel ~= nil
end

--[[
	是否可以点击格子
	1.如果主角被锁定，只有警戒怪所在的格子才能点击;
	2.如果主角没有被锁定,任意格子都可以点击
]]
function EliteGridModel:canClick()
	-- 主角刷新函数 已经初始化所有状态才能点击
	-- 解决刚进精英探索主界面时快速点击 造成主角脱离怪物锁定的bug
	if not self.controler.hasInitAllStatus then
		echo("________ 嘿嘿嘿 _______________")
		return 
	end
	local isCharLock = self.controler.charModel:isCharLock()
	-- 如果主角被锁定
	if isCharLock then
		if self.eventModel then
			if self:hasAlertMonster() then
				return true
			end
		end
		return false
	else
		return true
	end
end

-- 是否可以探索格子
function EliteGridModel:canExplore()
	return self.gridStatus == FuncEliteMap.GRID_STATUS.CAN_EXPLORE
		or self:isEmpty()
end

-- 是否已探索
function EliteGridModel:hasExplored()
	-- 必须用数据判断状态，不能用self.gridStatus，
	-- 因为其他grid判断该grid的状态时，当前grid可能还没更新self.gridStatus
	local gridInfo = self.gridInfo
	-- dump(gridInfo)

	-- 格子位状态(配置+服务器更新)
	local gridBitStatus = gridInfo[FuncEliteMap.GRID_BIT.STATUS]
	-- 已探索
	if tostring(gridBitStatus) == FuncEliteMap.GRID_BIT_STATUS.EXPLORED then
		return true
	end	

	if self:isEmpty() then
		return true
	end

	if tonumber(self.gridStatus) == FuncEliteMap.GRID_STATUS.OBSTRACLE then
		return true
	end

	return false
end

-- TODO 根据复杂度决定是否将事件消耗判断逻辑移到具体的event model中
-- 能否消耗事件
function EliteGridModel:canCostEvent(showTip)
	if not self:hasExplored() then
		return false
	end

	-- 是否有笼子，有笼子不可消耗
	if showTip and self:hasGridCage() then
		-- "请先解除封印"
		WindowControler:showTips(GameConfig.getLanguage("#tid_tower_prompt_108"))
		return false
	end

	-- 是否是主角的邻居
	local charModel = self.controler.charModel
	if charModel:isNeighbor(self) then
		return true
	end

	-- 如果主角与当前格子重叠
	if self.controler.charModel:getGridModel() == self then
		return true
	end
	
	-- 是否有空邻居
	-- if self.controler:hasEmptyNeighbor(self) then
	-- 	return true
	-- end
	local charGrid = self.controler.charModel:getGridModel()
	if self.controler:hasPath(charGrid,self) then
		return true
	else
		if showTip then
			-- 进度不足，无法探索
			WindowControler:showTips(GameConfig.getLanguage("#tid_tower_prompt_107"))
		end
		return false
	end

	return false
end

-- 主角能否通过该格子
function EliteGridModel:canPass(isTryFindPath)
	if self:isEmpty() then
		return true
	end

	local gridInfo = self.gridInfo
	-- 格子状态
	local gridStatus = gridInfo[FuncEliteMap.GRID_BIT.STATUS]
	if gridStatus == FuncEliteMap.GRID_BIT_STATUS.EXPLORED then
		local gridType = gridInfo[FuncEliteMap.GRID_BIT.TYPE]
		-- 如果是怪
		if gridType == FuncEliteMap.GRID_BIT_TYPE.MONSTER or 
			 gridType == FuncEliteMap.GRID_BIT_TYPE.EXIT or 
			 gridType == FuncEliteMap.GRID_BIT_TYPE.ORGAN or 
			 gridType == FuncEliteMap.GRID_BIT_TYPE.BOX 
			 then
			return false
		elseif gridType == FuncEliteMap.GRID_BIT_TYPE.DEFAULT_OPENED then
			return true
		end
		return false
	-- 
	elseif gridStatus == FuncEliteMap.GRID_BIT_STATUS.NOT_EXPLORE and isTryFindPath then
		local gridType = gridInfo[FuncEliteMap.GRID_BIT.TYPE]
		if gridType == FuncEliteMap.GRID_BIT_TYPE.EMPTY then
			local hasNotExplore = true
			return true,hasNotExplore
		end
	end

	return false
end

-- 点击该该格子时，主角能否站立在该格子上
-- 目前：只有毒格子可以站立
function EliteGridModel:canStand()
	if self:isEmpty() then
		return true
	end

	local gridInfo = self.gridInfo
	-- 格子状态
	local gridStatus = gridInfo[FuncEliteMap.GRID_BIT.STATUS]
	if gridStatus == FuncEliteMap.GRID_BIT_STATUS.EXPLORED then
		local gridType = gridInfo[FuncEliteMap.GRID_BIT.TYPE]
		if gridType == FuncEliteMap.GRID_BIT_TYPE.POISON then
			return true
		end

		return false
	end

	return false
end

-- 每帧刷新
function EliteGridModel:dummyFrame()
	self:updateGridStatus()
	self:updateGridType()

	-- 已经探索过的格子，才更新eventModel
	if self:hasExplored() then
		-- 检查警戒状态
		self:checkAlertedStatus()
		if self.eventModel then
			self.eventModel:updateFrame()
		end
	end
end

function EliteGridModel:getEventZOrder()
	return self.zorder + 1
end

-- 检查被警戒状态
function EliteGridModel:checkAlertedStatus()
	if not self:hasExplored() then
		return
	end

	if self:isGirdAlerted() then
		self:showAlertedView(true)
	else
		self:showAlertedView(false)
	end
end

-- 更新格子状态,状态变化时更新Grid视图&更新Event视图
function EliteGridModel:updateGridStatus()
	local gridStatus = self:checkGridStatus()

	if self.gridStatus == gridStatus then
		return
	else
		self.gridStatus = gridStatus
		local function callback()
			self:updateEventView()
		end
		self:updateGridView(nil,callback)
	end
end

-- 更新格子类型,类型变化时重置Event
function EliteGridModel:updateGridType()
	local gridType = self:checkGridType()
	if self.gridType == gridType then
		return
	else
		self.gridType = gridType
		self:resetEventModel()
	end
end

-- 重置事件model
function EliteGridModel:resetEventModel()
	if self.eventModel then
		self.eventModel:deleteMe()
		self.eventModel = nil
	end

	local callBack = function()
		self:initEventModel()
		if self.eventModel then
			self.eventModel:createEventView()
		end
	end
	
	self.myView:delayCall(callBack, 1/GameVars.GAMEFRAMERATE )
end

function EliteGridModel:checkGridType()
	local gridType = self.gridInfo[FuncEliteMap.GRID_BIT.TYPE]
	return gridType
end

-- 重新计算格子状态
function EliteGridModel:checkGridStatus()
	local debugX = 0
	local debugY = 0

	local xIdx,yIdx = self.xIdx,self.yIdx
	local gridInfo = self.gridInfo
	-- 格子状态
	local gridStatus = nil

	local isEmpty = self:isEmpty()
	-- 是否是空格子
	if isEmpty then
		gridStatus = self.GRID_STATUS.EVENT_CLEAR
		-- echo("___ xIdx,yIdx_ 是 空格子 _____",xIdx,yIdx)
		return gridStatus
	end

	-- 非空条件：1.未探索 2.已探索，有事件
	-- 格子位状态(配置+服务器更新)
	local gridBitStatus = gridInfo[FuncEliteMap.GRID_BIT.STATUS]
	-- 已探索
	if gridBitStatus == FuncEliteMap.GRID_BIT_STATUS.EXPLORED then
		gridStatus = self.GRID_STATUS.EXPLORED
	-- 未探索
	elseif gridBitStatus == FuncEliteMap.GRID_BIT_STATUS.NOT_EXPLORE then
		-- 默认可以探索 
		gridStatus = self.GRID_STATUS.CAN_EXPLORE

		-- -- 是否有笼子，有笼子一定不可探索
		-- if self:hasGridCage() then
		-- 	gridStatus = self.GRID_STATUS.CAN_NOT_EXPLORE
		-- 	return gridStatus
		-- end

		-- 判断是否有一个空的邻居
		if self.controler:hasEmptyNeighbor(self) then
			gridStatus = self.GRID_STATUS.CAN_EXPLORE
		else
			gridStatus = self.GRID_STATUS.CAN_NOT_EXPLORE
		end

		if xIdx == debugX and yIdx == debugY then
			echo("\n--------gridStatus====",gridStatus)
		end

		-- if self:hasSkipedMonster() then
		-- 	gridStatus = self.GRID_STATUS.CAN_EXPLORE
		-- end

		if xIdx == debugX and yIdx == debugY then
			echo("self:findSurroundPassGrid()----",self:findSurroundPassGrid())
		end

		if self:findSurroundPassGrid() then
			gridStatus = self.GRID_STATUS.CAN_EXPLORE
		end

		-- 通过寻路判断是否可以到达
		local charGrid = self.controler.charModel:getGridModel()
		if self.controler:hasPath(charGrid,self) then
			gridStatus = self.GRID_STATUS.CAN_EXPLORE
		else
			gridStatus = self.GRID_STATUS.CAN_NOT_EXPLORE
		end

		-- 是否被守卫
		if self:isGuarded() then
			gridStatus = self.GRID_STATUS.CAN_NOT_EXPLORE
		end

		-- 是否被警戒怪保护了
		if self:isGirdAlerted() then
			gridStatus = self.GRID_STATUS.CAN_NOT_EXPLORE
		end
	end

	-- echo("______ xIdx,yIdx,gridStatus __________",xIdx,yIdx,gridStatus)
	return gridStatus
end

-- 格子是否被警戒了
function EliteGridModel:isGirdAlerted()
	local grids = self.controler:getSurroundGrids(self)
	for k,v in pairs(grids) do
		-- 如果已经翻开，且是警戒怪
		if v:hasAlertMonster() then
			return true
		end
	end

	return false
end

-- 是否有警戒状态的怪
--
--Author:      zhuguangyuan
--DateTime:    2018-01-02 21:50:46
--Description: 劫财劫色npc也会锁定主角
--
function EliteGridModel:hasAlertMonster()
	if not self:hasExplored() then
		return false
	end

	if not self.eventModel then
		return false
	end

	local charModel = self.controler.charModel
	local charGrid = charModel:getGridModel()
	if charModel and charGrid then
		if not self.controler:isSurroundGrid(self,charGrid) then
			return false
		end
	end

	if self.eventModel:getEventType() == FuncEliteMap.GRID_BIT_TYPE.MONSTER 
		and self.eventModel:isAlertMonster() then
		return true
	else
		return false
	end
end

-- 是否有绕过的怪
function EliteGridModel:hasSkipedMonster()
	local grids = self.controler:getGuardMeGrids(self)
	for k,v in pairs(grids) do
		local gridInfo = v.gridInfo
		local gridType = gridInfo[FuncEliteMap.GRID_BIT.TYPE]
		if gridType == FuncEliteMap.GRID_BIT_TYPE.MONSTER then
			local monsterStatus = gridInfo[FuncEliteMap.GRID_BIT.TYPE_PARAM]
			-- 是星怪已经被绕过，且没有跟主角重叠
			if monsterStatus == FuncEliteMap.MONSTER_STATUS.SKIPED 
				and v.eventModel and v.eventModel:isOverlapChar() then
				return true
			else
				return false
			end
		end
	end
end

-- 是否被守卫(星怪会守卫其左侧三个格子)
function EliteGridModel:isGuarded()
	local xIdx,yIdx = self.xIdx,self.yIdx
	local gridInfo = self.gridInfo

	local grids = self.controler:getGuardMeGrids(self)
	for k,v in pairs(grids) do
		-- 如果已经翻开，且有星级怪
		if v:hasExplored() and v:hasStarMonster() then
			return true
		end
	end

	return false
end

-- 是否有星怪(星怪会守卫其左侧三个格子)
-- 精英怪被打过之后不会再守卫
function EliteGridModel:hasStarMonster()
	local xIdx,yIdx = self.xIdx,self.yIdx
	local gridInfo = self.gridInfo

	local gridType = gridInfo[FuncEliteMap.GRID_BIT.TYPE]

	if gridType == FuncEliteMap.GRID_BIT_TYPE.MONSTER then
		if self.eventModel then
			local raidId = self.eventModel:getEventId()
			if raidId and (not WorldModel:isPassRaid(raidId)) then
				return true
			end
		else
			return false
		end
		-- local monsterId = gridInfo[FuncEliteMap.GRID_BIT.TYPE_ID]
		-- local monsterData = FuncTower.getMonsterData(monsterId)
		-- local monsterStatus = gridInfo[FuncEliteMap.GRID_BIT.TYPE_PARAM]

		-- -- 是星怪且没有被绕过
		-- if monsterData.star == FuncEliteMap.MONSTER_STAR_TYPE.STAR 
		-- 	and monsterStatus ~= FuncEliteMap.MONSTER_STATUS.SKIPED then
			-- return true
		-- else
		-- 	return false
		-- end
	else
		return false
	end
end

-- 是否有笼子
function EliteGridModel:hasGridCage()
	if self:isEmpty() then
		return false
	end

	if self.cageModel then
		return true
	else
		return false
	end
end

-- 是否是空格子
-- 1.空配置的格子 2.格子已被打开且格子事件被消耗掉
function EliteGridModel:isEmpty()
	local xIdx,yIdx = self.xIdx,self.yIdx

	if not EliteMapModel:isValidGrid(xIdx, yIdx) then
		return false
	end

	local gridInfo = self.gridInfo

	-- 格子状态
	local gridStatus = gridInfo[FuncEliteMap.GRID_BIT.STATUS]
	local gridType = gridInfo[FuncEliteMap.GRID_BIT.TYPE]
	local isEmpty = false
	-- 格子被清空
	if gridStatus == FuncEliteMap.GRID_BIT_STATUS.CLEAR then
		isEmpty = true
	-- 格子已探索
	elseif gridStatus == FuncEliteMap.GRID_BIT_STATUS.EXPLORED then
		-- 精英里 探索后的怪格子都不能通过
		if gridType == FuncEliteMap.GRID_BIT_TYPE.MONSTER then
			return false
		elseif gridType == FuncEliteMap.GRID_BIT_TYPE.DEFAULT_OPENED then
			return true
		end
		local hasEvent = self:hasGridEvent(xIdx,yIdx)
		-- 是否有事件
		if hasEvent then
			isEmpty = false
		else
			isEmpty = true
		end
	else
		-- 主角出生地
		if EliteMapModel:isCharBirthPos(xIdx,yIdx) then
			isEmpty = true
		end
	end
	return isEmpty
end

-- 格子是否有事件
function EliteGridModel:hasGridEvent()
	local xIdx,yIdx = self.xIdx,self.yIdx

	local gridInfo = self.gridInfo
	local gridType = gridInfo[FuncEliteMap.GRID_BIT.TYPE]

	local hasEvent = false
	-- 空配置的格子
	if gridType == FuncEliteMap.GRID_BIT_TYPE.EMPTY then
		hasEvent = false
	elseif 
			table.isValueIn(FuncEliteMap.GRID_BIT_TYPE,gridType)
			and gridType ~= FuncEliteMap.GRID_BIT_TYPE.EMPTY
			and gridType ~= FuncEliteMap.GRID_BIT_TYPE.BIRTH
			-- TODO 是否去掉商店
			and gridType ~= FuncEliteMap.GRID_BIT_TYPE.SHOP
		then
		hasEvent = true
	-- TODO 是否去掉商店
	elseif gridType == FuncEliteMap.GRID_BIT_TYPE.SHOP then
		local shopInfo = self.gridInfo.ext
		if shopInfo then
			hasEvent = true
		end
	end

	return hasEvent
end

-- 更新事件view
function EliteGridModel:updateEventView()
	if tonumber(self.gridStatus) == FuncEliteMap.GRID_STATUS.EVENT_CLEAR then
		self:clearEventModel()
	elseif tonumber(self.gridStatus) == FuncEliteMap.GRID_STATUS.EXPLORED then
		if self.eventModel then
			-- local eventView = self:createEventView()
			local callBack = function()
				if self.eventModel and self.eventModel.createEventView  then
					self.eventModel:createEventView()
				end
			end
			-- TODO 根据地图主界面云动画调整延迟时间或修改方案
			self.myView:delayCall(c_func(callBack),0.3)
		end
	end
end

-- 开启作弊
function EliteGridModel:setCheatStatus(isCheat)
	self.isCheatMode = isCheat
	
	if self.myView then
		if isCheat then
			self.myView:setOpacity(TowerConfig.CHEAT_GRID_OPACITY)
		else
			self.myView:setOpacity(255)
		end
	end

	if self.eventModel then
		self.eventModel:setCheatStatus(isCheat)
	end
end

-- 根据场景中是否有警戒怪设置可探索的格子的颜色
function EliteGridModel:setIsHasSceneAlertMonsterStatus(event)
	if event and event.params then
		if (self.gridStatus ~= self.GRID_STATUS.CAN_EXPLORE) then
			return 
		end
		local isHasSceneAlertMonster = event.params.isHas
		if self.isHasSceneAlertMonster ~= isHasSceneAlertMonster then
			self.isHasSceneAlertMonster = isHasSceneAlertMonster
			if self.isHasSceneAlertMonster then
				self:updateGridView(self.isHasSceneAlertMonster)
			else
				self:updateGridView()
			end
		end
	end
end

-- 清空事件
function EliteGridModel:clearEventModel()
	if self.eventModel then
		self.eventModel:clear()
		self.eventModel = nil
	end
end

function EliteGridModel:getGridStatus()
	return self.gridStatus
end

-- 更新格子视图
function EliteGridModel:updateGridView(isHasSceneAlertMonster,callBack)
	if self.myView and not tolua.isnull(self.myView) then
		self.myView:removeFromParent()
		self.myView = nil
	end
	
	self:initView(self.viewCtn,self.pos.x,self.pos.y,self.pos.z,isHasSceneAlertMonster)
	self:setZOrder(self.zorder)

	if SHOW_CLICK_POS or SHOW_CLICK_RECT then
		self.myView:setTouchedFunc(function()
			
		end)
	end
	
	-- TODO 调试用作弊开关
	self:setCheatStatus(self.OPEN_CHEAT or false)

	if self.isCheatMode then
		self.myView:setOpacity(TowerConfig.CHEAT_GRID_OPACITY)
	end
	if callBack then
		callBack()
	end
end


-- 响应格子事件
function EliteGridModel:onGridResponse()
	local eventModel = self.eventModel
	if eventModel then
		if self:canCostEvent(true) then
			-- 根据事件类型处理
			-- WindowControler:globalDelayCall(function ()
			-- 	eventModel:onEventResponse()
			-- end,0.15)
			eventModel:onEventResponse()
		else
			echo("EliteGridModel:onGridResponse 事件不可处理")
		end
	else
		echo("当前格子没有事件.")
		self.controler.isHandlingEvent = false
		EliteMainModel.isHandlingEvent = false
	end
end

-- 强制打开格子
function EliteGridModel:forceOpen(index)
	-- 如果自动开格子时切换了章,self.myView为空
	if not self.myView then
		return
	end
	
	self.gridInfo[FuncEliteMap.GRID_BIT.STATUS] = FuncEliteMap.GRID_BIT_STATUS.EXPLORED
	local data = {}
	data[self.xIdx.."_"..self.yIdx] = {
		["status"] = FuncEliteMap.GRID_BIT_STATUS.EXPLORED,
	}
	-- 注意要先打开格子再更新数据
	-- 否则造成状态先更新 在格子刷新时检测到状态没有变化 于是不再创建新的视图
	self:onOpenGridSuccess(index)
	EliteMainModel:updateData(data)
	
	-- 发送更新格子消息
	EventControler:dispatchEvent(TowerEvent.TOWEREVENT_UPDATE_GRIDS)
end

function EliteGridModel:quickOpen(index)
	self.gridInfo[FuncEliteMap.GRID_BIT.STATUS] = FuncEliteMap.GRID_BIT_STATUS.EXPLORED
	local data = {}
	data[self.xIdx.."_"..self.yIdx] = {
		["status"] = FuncEliteMap.GRID_BIT_STATUS.EXPLORED,
	}
	EliteMainModel:updateData(data)
end

-- 打开格子成功
function EliteGridModel:onOpenGridSuccess(index,raidId)
	local function callBack()
		if self.eventModel then
			if raidId then
				self.eventModel:setEventId( raidId )
			end
			self.eventModel:onAfterOpenGrid()
		end
	end
	self:playOpenGridAnim(index or 1,callBack)
end

-- 播放打开格子动画
function EliteGridModel:playOpenGridAnim(index,callBack)
	local anim = nil
	if self:hasMonterEvent() then
		anim = self.controler:getOpenMonsterGridAnim(index)
	else
		anim = self.controler:getOpenGridAnim(index)
	end

	anim:setVisible(true)
	anim:pos(self.pos.x,self.pos.y)
	-- +1 防止被新创建的地板盖住动画
	anim:zorder(self.zorder+1)
	self.myView:setVisible(false)

	anim:startPlay(false)
	if callBack then
		callBack()
	end
end

-- 是否有怪事件
function EliteGridModel:hasMonterEvent()
	if self.eventModel and self.eventModel:getEventType() == FuncEliteMap.GRID_BIT_TYPE.MONSTER then
		return true
	else
		return false
	end
end

-- 高亮显示
function EliteGridModel:showFlight()
	if self.myView then
		self.isFight = true
		FilterTools.setFlashColor(self.myView,"spaceHighLight")
	end
end

-- 取消高亮显示
function EliteGridModel:clearFlight()
	if self.isFight and self.myView then
		FilterTools.clearFilter(self.myView)
	end
end

-- 显示被警戒的view
function EliteGridModel:showAlertedView(visible)
	if visible then
		if self.alertedView then
			return
		else
			self.alertedView = self.controler.ui:createUIArmature("UI_suoyaota","UI_suoyaota_yigejingshi", 
								self.viewCtn, true, GameVars.emptyFunc);
			self.alertedView:zorder(self.zorder)
			self.alertedView:scale(0.9)
			self.alertedView:pos(self.pos.x,self.pos.y)
			self.alertedView:startPlay(true)
		end
	else
		if self.alertedView then
			self.alertedView:removeFromParent()
			self.alertedView = nil
		end
	end
end

function EliteGridModel:deleteMe()
	if self.eventModel then
		self.eventModel:deleteMe()
	end

	if self.alertedView then
		self.alertedView:removeFromParent()
		self.alertedView = nil
	end

	EliteGridModel.super.deleteMe(self)
end

-- 查找相邻的可通过格子
function EliteGridModel:findSurroundPassGrid()
	local grids = self.controler:getSurroundGrids(self)
	for k,v in pairs(grids) do
		if v:canPass() then
			return true
		end
	end

	return false
end

-- 查找相邻的空格子
function EliteGridModel:findSurroundEmptyGrid()
	local grids = self.controler:getSurroundGrids(self)
	for k,v in pairs(grids) do
		if v:isEmpty() then
			return true
		end
	end

	return false
end

-- TODO 命名不规范，写法有问题，重写这个方法
function EliteGridModel:isTuLingFuEmpty()
	local gridStatus = self.gridInfo[FuncEliteMap.GRID_BIT.STATUS]
	local grudType = self.gridInfo[FuncEliteMap.GRID_BIT.TYPE]
	if tonumber(gridStatus) == 0 and tonumber(grudType) == 0 then
		if self:isGuarded() then
			return false
		else
			return true
		end
	end
	return false
end

-- 点击格子效果
function EliteGridModel:showBtnEffect()
	local eventModel = self.eventModel
	if eventModel then
		if self:canCostEvent() then
			-- 根据事件类型处理
			EliteMapModel:saveOnClick(eventModel)
			eventModel:showEventBtnEffect()
		else
			EliteMapModel:saveOnClick(false)		
		end
	end
end

-- 点击格子按下效果
function EliteGridModel:showBtnDownEffect()
	local eventModel =  EliteMapModel:getOnClick()

	if eventModel then
		eventModel:showEventDownBtnEffect()
	end	
end

-- 获取不能探索的提醒
function EliteGridModel:getCanNotExploreTip()
	-- 进度不足，无法探索
	local tip = GameConfig.getLanguage("#tid_tower_prompt_107")
	if not self:canClick() then
		-- 已被锁定不可移动
		tip = GameConfig.getLanguage("#tid_tower_prompt_109")
		return tip
	end

	if self:isGuarded() then
		-- "击杀附近敌人后可探索"
		tip = GameConfig.getLanguage("#tid_tower_prompt_110")
		return tip
	end

	return tip
end

return EliteGridModel
