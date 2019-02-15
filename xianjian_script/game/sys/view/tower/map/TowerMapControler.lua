--[[
	Author: 张燕广
	Date:2017-07-27
	Description: 锁妖塔地图控制器
]]

local TowerTools = require("game.sys.view.tower.map.TowerTools")
local TowerMapClazz = require("game.sys.view.tower.map.TowerMap")
local TowerPathControlerClazz = require("game.sys.view.tower.map.TowerPathControler")
local TowerGridModelClazz = require("game.sys.view.tower.model.TowerGridModel")
local TowerCharModelClazz = require("game.sys.view.tower.model.TowerCharModel")
local TowerMonsterModelClazz = require("game.sys.view.tower.model.TowerMonsterModel")
local TowerNpcModelClazz = require("game.sys.view.tower.model.TowerNpcModel")

local TowerBoxModelClazz = require("game.sys.view.tower.model.TowerBoxModel")
local TowerShopModelClazz = require("game.sys.view.tower.model.TowerShopModel")
local TowerCageModelClazz = require("game.sys.view.tower.model.TowerCageModel")
local TowerMatrixMethodClazz = require("game.sys.view.tower.model.TowerMatrixMethodModel")
local TowerEndPointClazz = require("game.sys.view.tower.model.TowerEndPointModel")
local TowerSpritPoolClazz = require("game.sys.view.tower.model.TowerSpritPoolModel")
local TowerPoisonClazz = require("game.sys.view.tower.model.TowerPoisonModel")
local TowerObstacleClazz = require("game.sys.view.tower.model.TowerObstacleModel")
local TowerRuneTempleClazz = require("game.sys.view.tower.model.TowerRuneTempleModel")
local TowerDoorClazz = require("game.sys.view.tower.model.TowerDoorModel")


local TowerGearRuneClazz = require("game.sys.view.tower.model.TowerGearRuneModel")

TowerMapControler = class("TowerMapControler")

function TowerMapControler:ctor(ui,towerIndex)
	self.ui = ui
	-- 塔索引
	self.towerIndex = towerIndex

	self:registerEvent()
	self:initData()
	self:initStatus()
	self:initMap()
	self:updateItems()
end

function TowerMapControler:initData()
	self.animFlaName = "UI_suoyaota"

	-- 所有格子的数组
	self.gridArr = {}
    -- 所有格子ID映射map，根据ID可以快速找到gridModel
    self.gridIdMap = {}
    -- TODO所有事件model数组，暂未用到
    self.eventModelArr = {}
    -- 道具的数组
    self.itemModelArr = {}

	self.mapData = TowerMapModel:getTowerMapData(self.towerIndex)

	-- 格子状态
	self.GRID_STATUS = FuncTowerMap.GRID_STATUS
	-- 事件视图映射
	self.GRID_EVENT_VIEW = FuncTowerMap.GRID_EVENT_VIEW

	-- 格子状态对应的panel
	self.GRID_PANELS = FuncTowerMap.GRID_PANELS

	self.charSize = {width=180,height=180}
	self.charScale = 0.8

	-- self.charOffsetY = self.charSize.height * self.charScale / 2
	self.charOffsetY = 0

	-- TODO计算格子排列时的宽高
	self.gridWidth = 156
	self.gridHeight = 75

	self.xNum = table.length(self.mapData)
	self.yNum = table.length(self.mapData["1"])

	-- 废弃变量
	self.gridBeginX = GameVars.width - self.gridWidth / 2
	self.gridBeginY = - (GameVars.height - ((self.xNum) * self.gridHeight) - self.gridHeight / 2)

	self.firstXIdx = 1
	self.firstYIdx = 2

	self.eventScale = 0.8
	self.boxScale = 0.8
	self.gridYOffset = 20

	-- 是否每帧刷新开关
	self.UPDATE_FRAME = false

	echo("GameVars.width,height",GameVars.width,GameVars.height)
	echo("self.gridBeginY==",self.gridBeginY)
end

-- 初始化格子动画
function TowerMapControler:createGridAnim(index)
	local gameMiddleLayer = self.map:getGameMiddleLayer()
	local openGridAnim = self.ui:createUIArmature("UI_suoyaota","UI_suoyaota_fangkuaibaozha", 
			gameMiddleLayer, false, GameVars.emptyFunc);
	local griView = self:getGridView(FuncTowerMap.GRID_STATUS.CAN_EXPLORE)
	griView:pos(0,0)
	FuncArmature.changeBoneDisplay(openGridAnim,"node",griView)
	openGridAnim:setVisible(false)

	self.openGridAnimArr[index] = openGridAnim
end

-- 初始化开出怪动画
function TowerMapControler:createMonsterGridAnim(index)
	local gameMiddleLayer = self.map:getGameMiddleLayer()
	local openGridAnim = self.ui:createUIArmature("UI_suoyaota","UI_suoyaota_guawuchuxian", 
			gameMiddleLayer, false, GameVars.emptyFunc);
	local griView = self:getGridView(FuncTowerMap.GRID_STATUS.CAN_EXPLORE)
	griView:pos(0,0)
	FuncArmature.changeBoneDisplay(openGridAnim,"node",griView)
	openGridAnim:setVisible(false)

	self.openMonsterGridAnimArr[index] = openGridAnim
end

function TowerMapControler:initAnimCache()
	self.openGridAnimArr = {}
	self.openMonsterGridAnimArr = {}
	self.ui:delayCall(c_func(self.createGridAnim,self,1), 1 / GameVars.GAMEFRAMERATE)
	self.ui:delayCall(c_func(self.createMonsterGridAnim,self,1), 1 / GameVars.GAMEFRAMERATE)
end

-- 初始化状态
function TowerMapControler:initStatus()
	-- 是否正在选择事件目标
	self.isSelectTargetEvent = false
end

function TowerMapControler:setSelectTargetEvent(isSelect,notFindTarget)
	self.isSelectTargetEvent = isSelect
	EventControler:dispatchEvent(TowerEvent.TOWEREVENT_CHOOSE_TARGET,{isSelect = isSelect,notFindTarget=notFindTarget})
end

function TowerMapControler:registerEvent()
	-- 刷新格子(商店关闭/)
	EventControler:addEventListener(TowerEvent.TOWEREVENT_UPDATE_GRIDS, self.updateGrids,self)
	-- 当数据变更时
	EventControler:addEventListener(TowerEvent.TOWEREVENT_TOWER_DATA_UPDATE, self.updateData,self)
	-- 自动打开剩余的格子
	EventControler:addEventListener(TowerEvent.TOWEREVENT_AUTO_OPEN_LEFT_GRIDS, self.autoOpenLeftGrids,self)
	EventControler:addEventListener(TowerEvent.TOWEREVENT_OVERTHEGRIDANIMATION, self.quickOpenGrids,self)

	--更新道具
    EventControler:addEventListener(TowerEvent.TOWEREVENT_USE_ITEM_UPDATE,self.updateItems,self)
    -- 拾取道具成功
    EventControler:addEventListener(TowerEvent.TOWEREVENT_GET_ITEM_SUCCESS,self.updateItems,self)
    --丢弃道具成功
    EventControler:addEventListener(TowerEvent.TOWEREVENT_DROP_ITEM_SUCCESS,self.updateItems,self)
    --获得新道具
    EventControler:addEventListener(TowerEvent.TOWEREVENT_HAVE_TOWERITEM,self.updateItems,self)
end

function TowerMapControler:initMap()
	-- 场景map皮肤
	local sceneSkin = TowerMapModel:getTowerMapSceneSkin(TowerMainModel:getCurrentFloor())

	self.map = TowerMapClazz.new(self.mapData,self)
	self.map:initMap()

	local backLayer = self.map.backLayer
	-- local backLayer = display.newNode()
	local frontLayer = self.map.frontLayer
	self.sceneControler = MapControler.new(backLayer, frontLayer, sceneSkin, false);
	self.sceneControler:updatePos(0,0)

	self.ui:scheduleUpdateWithPriorityLua(c_func(self.updateFrame,self),0)

	-- 寻路管理器
	self.pathControler = TowerPathControlerClazz.new(self)

	local xIdx,yIdx = TowerMapModel:getCharGridPos()
	local pos = TowerTools:getGridPos(xIdx,yIdx)
	self.map.focusPos = pos
	
	-- 初始化动画缓存
	self:initAnimCache()

	if not self.UPDATE_FRAME then
		self:updateGrids()
	end
end

-- 移动地图
function TowerMapControler:moveMap(pos)
	if pos then
		self.map:moveMap(pos.x,pos.y)
	end
end

function TowerMapControler:getOpenGridAnim(index)
	if not index then
		return self.openGridAnimArr[1]
	end
	
	if not self.openGridAnimArr[index] then
		self:createGridAnim(index)
	end

	return self.openGridAnimArr[index]
end

function TowerMapControler:getOpenMonsterGridAnim(index)
	if not index then
		return self.openMonsterGridAnimArr[1]
	end
	
	if not self.openMonsterGridAnimArr[index] then
		self:createMonsterGridAnim(index)
	end

	return self.openMonsterGridAnimArr[index]
end

function TowerMapControler:getTowerMap()
	return self.map
end

-- 将路径点转换为主角运动点，去掉未探索的点
function TowerMapControler:pathToPointArr(startPoint,pointList,clickGridModel)
	-- 主角移动路径
	local pointArr = {}
	local length = #pointList
	for i,point in pairs(pointList) do
		local gridModel = self:findGridModel(point.x, point.y)

		-- 最后一个点
		if i == length then
			-- 如果最后一个点是点击的格子，且不是空格子
			if gridModel == clickGridModel and not clickGridModel:canStand() then
				break
			end
		end

		-- 可以通过，且不是起点
		if gridModel:canPass() and not (gridModel.xIdx == startPoint.x and gridModel.yIdx == startPoint.y) then
			local targetPos = {}
			targetPos.speed = self:getCharSpeed(length)
			targetPos.x = gridModel.pos.x
			targetPos.y = gridModel.pos.y
			targetPos.xIdx = point.x
			targetPos.yIdx = point.y

			pointArr[#pointArr+1] = targetPos
		end
	end

	return pointArr
end

--[[
	从主角运动路径中找到最大的zorder，用于动态修改主角zorder
	保证主角在各个不同层级的格子间运动不穿帮
]]
function TowerMapControler:getPathMaxZorder(pointArr)
	local maxZorder = 0
	for k,v in pairs(pointArr) do
		local gridModel = self:findGridModel(v.xIdx, v.yIdx)
		local zorder = gridModel:getZOrder() + 1

		if zorder > maxZorder then
			maxZorder = zorder
		end
	end

	return maxZorder
end

-- 找到地图格子中最大的zorder
function TowerMapControler:getMaxGridZorder()
	local zorder = self:getGridZOrder(self.xNum, self.yNum)
	return zorder
end

-- 移动主角到指定格子数组
function TowerMapControler:moveCharToGrid(gridArr)
	local pointArr = {}
	for i=1,#gridArr do
		local gridModel = gridArr[i]
		local targetPos = {}
		targetPos.speed = self:getCharSpeed(#gridArr)
		targetPos.x = gridModel.pos.x
		targetPos.y = gridModel.pos.y
		targetPos.xIdx = gridModel.xIdx
		targetPos.yIdx = gridModel.yIdx

		pointArr[#pointArr+1] = targetPos
	end

	self:moveChar(pointArr)
end

-- 移动主角
function TowerMapControler:moveChar(pointArr)
	if #pointArr > 0 then
		local gridModel = self:findGridModel(pointArr[#pointArr].xIdx,pointArr[#pointArr].yIdx)
		self.charModel:setTargetGrid(gridModel)

		--[[
		local maxZorder = self:getPathMaxZorder(pointArr)
		if maxZorder > self.charModel:getZOrder() then
			self.charModel:setZOrder(maxZorder)
		end
		]]

		-- 2018.08.11 修改过主角运动中实时计算order by ZhangYanguang
		--[[
		local maxZorder = self:getMaxGridZorder()
		self.charModel:setZOrder(maxZorder)
		]]

		-- 打印路径
		self:testPringPath(pointArr)
		self.charModel:moveByPointArr(pointArr)
		self.charModel:setIsCharMoving(true)
	else
		echo("TowerMapControler:moveChar 已无路可走...")
		self:onCharArriveTargetGrid()
	end
end

function TowerMapControler:getGridModelByPos(pos)
	local gridModel = TowerTools:getGridPosByWordPos(pos,self.gridArr)
	return gridModel
end

-- TODO Test 测试方法，打印路径
function TowerMapControler:testPringPath(pointArr)
	echo("路径如下--------------------")
	local pathStr = ""
	for k,v in pairs(pointArr) do
		pathStr = pathStr .. "(" .. v.xIdx .. "," .. v.yIdx .. ")->"
	end

	echo("pathStr=",pathStr)
end

-- 获取主角移动速度
function TowerMapControler:getCharSpeed(length)
	local gridNum = 4
	local minCharSpeed = 10
	local maxCharSpeed = 20

	local speed = length / gridNum * minCharSpeed
	if speed < minCharSpeed then
		speed = minCharSpeed
	end

	if speed > maxCharSpeed then
		speed = maxCharSpeed
	end

	return speed
end

-- TODO 
-- 测试方法，重置格子状态
function TowerMapControler:resetGrids()
	for k,v in pairs(self.gridArr) do
		v:updateGridStatus(self.GRID_STATUS.CAN_EXPLORE)
		FilterTools.clearFilter(v.myView,"spaceHighLight")

		for k2, v2 in pairs(self.blockList) do
			if v.xIdx == v2.x and v.yIdx == v2.y then
				v:updateGridStatus(self.GRID_STATUS.ALERT)
			end
		end
	end
end

-- 自动打开剩余的格子
function TowerMapControler:autoOpenLeftGrids()
	local count = 0
	local grids = self:getLeftGrids()
	-- 将格子分组
	local gridGroupMap = self:groupGridsByXIdx(grids)

	local keysArr = {}
	for k, v in pairs(gridGroupMap) do
		keysArr[#keysArr+1] = k
		-- table.sortAsc(v)
	end
	-- table.sortAsc(keysArr)
	for i=1,#keysArr do
		local xIdx = keysArr[i]
		local gridYArr = gridGroupMap[xIdx]
		local gridsNum = #gridYArr

		for j=1,#gridYArr do
			local yIdx = gridYArr[j]
			local grid = self:findGridModel(xIdx,yIdx)

			local delayTime = i * 0.5 + j * 0.2
			self.map:delayCall(c_func(grid.forceOpen,grid,j), delayTime)
		end
	end
end

-- 获取剩余的未探索的所有格子
function TowerMapControler:getLeftGrids()
	local grids = {}
	for k, v in pairs(self.gridArr) do
		if not v:hasExplored() then
			grids[#grids+1] = v
		end
	end

	return grids
end

-- 按照X分组然后按照Y降序排序
function TowerMapControler:groupGridsByXIdx(grids)
	local gridsMap = {}
	for k, v in pairs(grids) do
		local xIdx = v.xIdx

		local arr = gridsMap[xIdx]
		if arr == nil then
			arr = {}
			gridsMap[xIdx] = arr
		end

		arr[#arr+1] = v.yIdx
	end

	return gridsMap
end

-- ================================== 交互类方法 ==================================
function TowerMapControler:clearGridFlight()
	for k, v in pairs(self.gridArr) do
		v:clearFlight()
	end
end

-- 检查是否可通过
function TowerMapControler:checkCanPass(xIdx,yIdx)
	local gridModel = self:findGridModel(xIdx, yIdx)
	if gridModel:canPass() then
		return true
	else
		return false
	end
end

-- 地图点击事件
function TowerMapControler:onClickMapBegin(pos)
	if self.charModel:isCharMoving() then
		echo("主角正在运动中...........")
		return
	end

	local gridModel = TowerTools:getGridPosByWordPos(pos,self.gridArr)
	if gridModel then
		if gridModel:hasExplored() and gridModel:hasEventModel() then
			self.clickEvent = true
			self.nowNewGrid = gridModel
			gridModel:showBtnEffect()
		else
			gridModel:showFlight()
		end	
	end
end

function TowerMapControler:onClickMapMove()
	self:clearGridFlight()
	if self.clickEvent then
		self.nowNewGrid:showBtnDownEffect()
		self.clickEvent = false
	end	
end

-- 地图点击事件
function TowerMapControler:onClickMapEnd(pos)
	self:clearGridFlight()

	if self.charModel:isCharMoving() then
		echo("主角正在运动中...")
		-- WindowControler:showTips("主角正在运动中")
		return
	end
	if self.clickEvent then
		self.nowNewGrid:showBtnDownEffect()
		self.clickEvent = false
	end	
	local gridModel = TowerTools:getGridPosByWordPos(pos,self.gridArr)
	if gridModel then
		self:onClickGrid(gridModel)
	end
end

-- 是否是相邻的grid model
function TowerMapControler:isSurroundGrid(startGrid,endGrid)
	local startPoint = cc.p(startGrid.xIdx,startGrid.yIdx)
	local endPoint = cc.p(endGrid.xIdx,endGrid.yIdx)
	return self.pathControler:isSurroundPoint(startPoint,endPoint)
end

-- 两个grid间是否有路径
function TowerMapControler:hasPath(startGrid,endGrid)
	local startPoint = cc.p(startGrid.xIdx,startGrid.yIdx)
	local endPoint = cc.p(endGrid.xIdx,endGrid.yIdx)
	local isFind,pointList = self.pathControler:findPath(startPoint,endPoint)
	if #pointList == 0 and not self:isSurroundGrid(startGrid,endGrid) then
		return false
	else
		return true
	end
end

-- 如果是主角释放道具技能，检查是否激活格子响应
function TowerMapControler:checkActiveGrid(grid)
	if self.charModel:checkGiveItemSkill() then
		local item = self.charModel:getCharItem()
		if item then
			if not item:checkActiveGrid() then
				return false
			else
				if item.checkOptionalGrid then
					if item:checkOptionalGrid(grid) then
						return true
					else
						-- 如果点击的不是备选的格子
						return false
					end
				end
			end
		end
	end

	return true
end

-- 点击了格子
function TowerMapControler:onClickGrid(gridModel)
	-- 是否在开格子中
	if self.isOpenGrid then
		echo("正在打开格子中...")
		return
	end

	-- 是否在处理格子事件
	if self.isHandlingEvent then
		echo("正在处理事件...")
		return
	end

	--格子是否可以点击	
	if not gridModel:canClick() then
		echo("格子不可以点击")
		local tip = gridModel:getCanNotExploreTip()
		WindowControler:showTips(tip)
		return
	end

	-- 是否有选择目标事件
	if self.isSelectTargetEvent then
		self:setSelectTargetEvent(false)
	end

	self.clickedGridModel = gridModel
	
	EventControler:dispatchEvent(TowerEvent.TOWEREVENT_CLICK_GRID,{grid=gridModel})
	-- 如果不激活格子响应事件
	if not self:checkActiveGrid(gridModel) then
		echo("不激活格子响应事件")
		return
	else
		echo("激活格子响应事件")
	end

	local xIdx = gridModel.xIdx
	local yIdx = gridModel.yIdx

	echo("\n\n--------点击了格子--------:",xIdx,yIdx)
	echo("主角位置=",self.charModel.gridModel.xIdx,self.charModel.gridModel.yIdx)

	echo("格子能否探索=", gridModel:canExplore(),gridModel:hasExplored())
	echo("格子状态=",gridModel:getGridStatus())

	local charGrid = self.charModel:getGridModel()
	local startPoint = cc.p(charGrid.xIdx,charGrid.yIdx)
	local endPoint = cc.p(xIdx,yIdx)

	echo("主角寻路(" .. startPoint.x .. "," ..  startPoint.y .. ")---->(" .. xIdx .. "," .. yIdx .. ")")
	echo("结束点(" .. endPoint.x .. "," .. endPoint.y .. ")")

	-- TODO 整理主角移动逻辑及格子响应逻辑
	-- 已经探索	
	if gridModel:hasExplored()  then
		echo("已探索的格子...")
		self.willExploreGrid = nil
		local isFind,pointList = self.pathControler:findPath(startPoint, endPoint)
		-- echo("\n----------isFind=",isFind)
		-- dump(pointList)
		local pointArr = self:pathToPointArr(startPoint,pointList,gridModel)

		--[[
		-- 方案一 :无路径可走不触发grid事件
		if #pointList == 0 and not self.pathControler:isSurroundPoint(startPoint, endPoint) then
			echo("没有路径，不响应事件")
			return
		else
			self:moveChar(pointArr)
		end
		]]
		-- 方案二:无路可走，也会触发grid事件，由grid中事件model来判断如何响应事件
		self:moveChar(pointArr)
	else
		if gridModel:canExplore() then
			echo("开始探索...")
			self.willExploreGrid = gridModel
			-- isFind 是否能到达目标点
			-- pointList最佳路径
			local isFind,pointList = self.pathControler:findPath(startPoint, endPoint)
			-- echo("isFind===",isFind,#pointList)

			if #pointList == 0 and not self.pathControler:isSurroundPoint(startPoint, endPoint) then
				echo("没有路径，不可以探索")
				-- WindowControler:showTips("不可以探索")
				WindowControler:showTips(gridModel:getCanNotExploreTip())
				return
			else
				if #pointList == 0 then
					self:onCharArriveTargetGrid()
				else
				    -- TODO 需要根据需求，判断isFind为false的时候，主角是走过去还是保持不动
					local pointArr = self:pathToPointArr(startPoint,pointList,gridModel)
					self:moveChar(pointArr)
				end
			end
		else
			echo("格子不可以探索")
			WindowControler:showTips(gridModel:getCanNotExploreTip())
		end
	end
end

-- 主角每运动到一个新的格子
function TowerMapControler:onCharArriveGrid()
	EventControler:dispatchEvent(TowerEvent.TOWEREVENT_CHAR_ARRIVE_GIRD)
end

-- 主角运动到了目标格子
function TowerMapControler:onCharArriveTargetGrid()
	-- 修正主角朝向
	self:adjustCharView()
	if not self.UPDATE_FRAME then
		-- 更新格子
		self:updateGrids()
	end

	local charGridPos = self.charModel:getCurGrid()
	TowerMapModel:saveCharGridPos(charGridPos.x,charGridPos.y)

	-- 主角绕过怪时，该变量该nil
	if not self.clickedGridModel then
		return
	end

	local gridModel = self.clickedGridModel
	echo("\n--------主角运动到了目标格子gridModel=",gridModel.xIdx,gridModel.yIdx)
	echo("格子状态=",gridModel:getGridStatus())

	EventControler:dispatchEvent(TowerEvent.TOWEREVENT_CHAR_ARRIVE_TARGET_GIRD,{grid=gridModel})
	-- 点击的是已经打开的格子
	if gridModel:hasExplored() then
		self.isHandlingEvent = true
		self.ui:disabledUIClick()
		echo("\n\n ______ 是否正在响应格子事件 ____________",self.isHandlingEvent)
		local function resetIsHandlingEvent( ... )
			self.isHandlingEvent = false
			self.ui:resumeUIClick()
			echo("\n\n ______ 是否正在响应格子事件 ____________",self.isHandlingEvent)
		end
		self.ui:delayCall(c_func(resetIsHandlingEvent), 0.3) --1 / GameVars.GAMEFRAMERATE
		gridModel:onGridResponse()
	else
		local xIdx  = gridModel.xIdx
		local yIdx = gridModel.yIdx
		echo("正在打开格子...")
		self.isOpenGrid = true
		TowerServer:openGrid(xIdx,yIdx,c_func(self.onOpenGridCallBack,self))
	end
end

-- 修正主角朝向
function TowerMapControler:adjustCharView()
	-- 修正主角朝向
	self.charModel:adjustViewAction()
	self.charModel:adjustZOrder()
end

-- 打开格子成功回调
function TowerMapControler:onOpenGridCallBack(event)
	-- 打开格子成功
	if event and event.result then
		if self.willExploreGrid then
			local gearCacheData = table.deepCopy(event.result.data)
			self.willExploreGrid:onOpenGridSuccess(nil,gearCacheData)
		else
			echoError("self.willExploreGrid is nil")
		end

		dump(event.result.data, "desciption")
		if self.willExploreGrid and self.willExploreGrid.gearModel then
			local curFloorData = event.result.data.towerFloor
			if curFloorData and curFloorData.cells then
				for k,v in pairs(curFloorData.cells) do
					if k == tostring(self.willExploreGrid.gid) then
						local gridNewData = {
							["towerFloor"] ={
								["cells"] ={
									[k] = v
								}
							}
						}
						dump(gridNewData, "打开聚灵格子 及时更新聚灵格子的状态数据,其他数据待聚灵逻辑处理完才更新")
						TowerMainModel:updateData(gridNewData)
						break
					end
				end

			end
		else
			echo("________ 非聚灵格子 直接更新开格子后的数据 ___________")
			TowerMainModel:updateData(event.result.data)
		end
	else
		-- 开格子异常处理
		echo("打开格子失败")
	end 

	self.isOpenGrid = false
	self.willExploreGrid = nil
end

function TowerMapControler:findGridByMonsterId(monsterId)
	for k, v in pairs(self.gridArr) do
		if v.eventModel and v.eventModel:getEventType() == FuncTowerMap.GRID_BIT_TYPE.MONSTER
			and v.eventModel:getEventId() == monsterId then
			return v
		end
	end

	return nil
end

-- 查找gridModel
function TowerMapControler:findGridModel(xIdx,yIdx)
	local gridId = TowerMapModel:gridPosToId(xIdx, yIdx)
	local gridIdx = self.gridIdMap[gridId]
	if not gridIdx then
		return nil
	end

	local gridModel = self.gridArr[gridIdx]
	return gridModel
end

-- 找gridModel周围的格子
function TowerMapControler:getSurroundGrids(gridModel)
	local grids = {}
	local targetPoint = {x=gridModel.xIdx,y=gridModel.yIdx}
	local points = FuncTowerMap.getSurroundPoints(targetPoint)

	for k,v in pairs(points) do
		local curGridModel = self:findGridModel(v.x,v.y)
		if curGridModel  then
			grids[#grids+1] = curGridModel
		end
	end

	return grids
end

-- 判断指定gridModel周围是否有空的格子
function TowerMapControler:hasEmptyNeighbor(gridModel)
	local targetPoint = {x=gridModel.xIdx,y=gridModel.yIdx}
	local points = FuncTowerMap.getSurroundPoints(targetPoint)

	for k,v in pairs(points) do
		local curGridModel = self:findGridModel(v.x,v.y)
		if curGridModel and curGridModel:isEmpty() then
			return true
		end
	end
	return false
end

-- 找到守护gridModel的那些格子
function TowerMapControler:getGuardMeGrids(gridModel)
	local grids = {}

	local targetPoint = {x=gridModel.xIdx,y=gridModel.yIdx}
	local points = FuncTowerMap.getGuardMePoints(targetPoint)

	for k,v in pairs(points) do
		local curGridModel = self:findGridModel(v.x,v.y)
		if curGridModel and not curGridModel:isEmpty() then
			grids[#grids+1] = curGridModel
		end
	end

	return grids
end

-- 是否有警戒状态的怪
function TowerMapControler:hasAlertMonster()
	-- for k, v in pairs(self.gridArr) do
	-- 	if v:hasAlertMonster() then
	-- 		return true
	-- 	end
	-- end

	-- return false

	-- 是否有警戒怪 发生变化的时候
	-- 发消息告诉 格子 高亮格子变暗或者原本可探索的格子由暗变亮
	if not self.hasSceneAlertMonster then
		self.hasSceneAlertMonster = false
	end
	for k, v in pairs(self.gridArr) do
		if v:hasAlertMonster() then
			if not self.hasSceneAlertMonster then
				self.hasSceneAlertMonster = true
				EventControler:dispatchEvent(TowerEvent.TOWER_IS_HAS_ALERT_MONSTER_CHANGE, {isHas = self.hasSceneAlertMonster})
			end
			return true
		end
	end
	if self.hasSceneAlertMonster then
		self.hasSceneAlertMonster = false
		EventControler:dispatchEvent(TowerEvent.TOWER_IS_HAS_ALERT_MONSTER_CHANGE, {isHas = self.hasSceneAlertMonster})
	end
	return false
end

-- ================================== 刷新类方法 ================================== 
function TowerMapControler:updateData()
	self:updateGrids()
end

-- 更新背包列表中的ItemModel
function TowerMapControler:updateItems()
	-- TODO 不要打开openCache，使用道具与丢失道具加goodsTime字段分支合并后才可以打开
	-- 否则多个相同ID道具使用会发生错误
	local openCache = false
	local itemModelArr = {}

	if not openCache then
		if self.itemModelArr then
			for k,v in pairs(self.itemModelArr) do
				if v then
					v:deleteMe()
				end
			end
		end
	end

	local goods = TowerMainModel:getGoodsSortArr()
	for i=1,#goods do
		local itemId = goods[i].id
		local itemTime = goods[i].time

		local itemModel = nil
		if openCache then
			itemModel = self:findTargetItemById(itemId,itemTime)
		end

		if itemModel == nil then 
			itemModel = self:createItemById(itemId)
			itemModel:setItemTime(itemTime)
		end

		itemModelArr[#itemModelArr+1] = itemModel
	end

	self.itemModelArr = itemModelArr
end

-- 根据道具ID,从获得的道具列表中查找道具
function TowerMapControler:findTargetItemById(itemId,itemTime)
	for i=1,#self.itemModelArr do
		local itemModel = self.itemModelArr[i]
		if itemModel:getEventId() == itemId and itemModel:getItemTime() == itemTime then
			return itemModel
		end
	end

	return nil
end

-- 更新所有格子
function TowerMapControler:updateGrids()
	local updateFunc = function()
		for k,v in pairs(self.gridArr) do
			v:updateFrame()
		end
	end
	
	updateFunc()
	self.map:delayCall(c_func(updateFunc), 1/GameVars.GAMEFRAMERATE)
end

function TowerMapControler:sortGrids()
	for k,v in pairs(self.gridArr) do
		local zorder = self:getGridZOrder(v.xIdx,v.yIdx)
		v:setZOrder(zorder)
	end
end

-- 每帧刷新方法
function TowerMapControler:updateFrame(dt)
	if self.UPDATE_FRAME then
		self:updateGrids()
	end
	
	self:sortGrids()
	
	if self.charModel then
		self.charModel:updateFrame()
	end

	local targetPos = self.charModel.myView:getPositionX()
	self.map:easeFollowPlayer(targetPos)
end

-- ================================== 创建类方法 ================================== 
-- 创建一个格子model
function TowerMapControler:createGridModel(xIdx,yIdx)
	local gridInfo = TowerMapModel:getGridInfo(xIdx,yIdx)
	local gameBackLayer = self.map:getGameMiddleLayer()

	-- 计算出格子坐标
	local pos = TowerTools:getGridPos(xIdx,yIdx)
	local xpos,ypos = pos.x,pos.y
	local zpos = 0
	-- echo("----------------------xIdx,yIdx,x,y=",xIdx,yIdx,xpos,ypos)

	local gridModel = TowerGridModelClazz.new(self,xIdx,yIdx,gridInfo)
	local order = self:getGridZOrder(xIdx,yIdx)

	-- gridModel:setGridInfo(gridInfo)
	gridModel:setViewInfo(gameBackLayer,xpos,ypos,zpos)
	gridModel:setZOrder(order)

	-- 保存model
	local index = #self.gridArr + 1
	self.gridArr[index] = gridModel
	self.gridIdMap[gridModel:getId()] = index
end

-- 计算格子zorder
function TowerMapControler:getGridZOrder(xIdx,yIdx)
	return xIdx+yIdx * 10
end

-- 根据格子状态，创建对应的view
function TowerMapControler:getGridView(gridStatus)
	local cacheList = self.map:getGridPanelCacheList()
	local cachePanel = cacheList[gridStatus]
	local panel = UIBaseDef:cloneOneView(cachePanel)
	return panel
end

-- 获取普通障碍物视图
function TowerMapControler:getNormalObstacleView()
	local cacheList = self.map:getGridEventViewCacheList()
	local cacheName = self.GRID_EVENT_VIEW[FuncTowerMap.GRID_BIT_TYPE.OBSTACLE]
	local cachePanel = cacheList[cacheName]
	local panel = UIBaseDef:cloneOneView(cachePanel)
	return panel
end

-- 创建主角
function TowerMapControler:createChar()
	local charOffsetY = self.charOffsetY

	local gameMiddleLayer = self.map:getGameMiddleLayer()

	local xIdx,yIdx = TowerMapModel:getCharGridPos()

	-- 主角zorder(eventModel zorder+1,主角+2)
	local zorder = self:getGridZOrder(xIdx,yIdx) + 2

	local pos = TowerTools:getGridPos(xIdx,yIdx)
	local xpos = pos.x
	local ypos = pos.y - charOffsetY
	local zpos = 0

	local charSex = nil
	if PrologueUtils:showPrologue() then
		charSex = FuncChar.getCharSex(LoginControler:getLocalRoleId())
	else
		charSex = UserModel:sex()
	end

	local charModel = TowerCharModelClazz.new(self,charSex)
	local playerSpine = self:getCharSpine(charSex)
   
    charModel:initView(gameMiddleLayer,playerSpine,xpos,ypos,zpos,self.charSize)
    charModel:setViewScale(self.charScale)
    charModel:setZOrder(zorder)
    charModel:setCurGrid(cc.p(xIdx,yIdx))

    self.charModel = charModel
end

-- 查找指定类型的事件对象的格子
-- 用于 道具使用时寻找目标格子 
function TowerMapControler:findGridsByType(eventType)
	local gridsArr = {}
	for k,v in pairs(self.gridArr) do
		if v:hasExplored() and v:hasEventModel() then
			local curEventType = v.eventModel:getEventType()
			if curEventType == eventType and v:canCostEvent() then
				gridsArr[#gridsArr+1] = v
			end
		end
	end

	return gridsArr
end

-- 查找指定类型的事件对象(可以响应的)
function TowerMapControler:findEventModelsByType(eventType)
	local eventArr = {}
	for k,v in pairs(self.gridArr) do
		if v:hasExplored() and v:hasEventModel() then
			local curEventType = v.eventModel:getEventType()
			if curEventType == eventType and v:canCostEvent() then
				eventArr[#eventArr+1] = v.eventModel
			end
		end
	end

	return eventArr
end

-- 找到所有未探索的格子
function TowerMapControler:findNotExploredGrids()
	local gridsArr = {}
	for k,v in pairs(self.gridArr) do
		if not v:hasExplored() then
			gridsArr[#gridsArr+1] = v
		end
	end

	return gridsArr
end

-- 创建机关事件对象模型
function TowerMapControler:createGearModels(gridModel)
	local gridInfo = gridModel:getGridInfo()
	local xIdx = gridModel.xIdx
	local yIdx = gridModel.yIdx

	-- 网格事件类型
	local runeType = gridInfo[FuncTowerMap.GRID_BIT.D4_TYPE]
	local gearModel = nil

	-- 聚灵格子
	if runeType == FuncTowerMap.GRID_BIT_D4_TYPE.RUNE then
		gearModel = TowerGearRuneClazz.new(self,gridModel)
	end
	if gearModel then
		gearModel:setGearType(runeType)
		gearModel:setGrid(gridModel) 
	end
	
	return gearModel
end

-- 创建事件对象模型
function TowerMapControler:createEventModels(gridModel)
	local gridInfo = gridModel:getGridInfo()
	local xIdx = gridModel.xIdx
	local yIdx = gridModel.yIdx

	-- 网格事件类型
	local gridType = gridInfo[FuncTowerMap.GRID_BIT.TYPE]
	local eventModel = nil
	-- 空格子
	if gridType == FuncTowerMap.GRID_BIT_TYPE.EMPTY then
		-- 不做处理
	-- 怪
	elseif gridType == FuncTowerMap.GRID_BIT_TYPE.MONSTER then
		eventModel = TowerMonsterModelClazz.new(self,gridModel)
	-- 宝箱
	elseif gridType == FuncTowerMap.GRID_BIT_TYPE.BOX then
		eventModel = self:createBox(gridModel)
	-- 道具
	elseif gridType == FuncTowerMap.GRID_BIT_TYPE.ITEM then
		eventModel = self:createItem(gridModel)
	-- npc
	elseif gridType == FuncTowerMap.GRID_BIT_TYPE.NPC then
		eventModel = TowerNpcModelClazz.new(self,gridModel)
	-- 商店
	elseif gridType == FuncTowerMap.GRID_BIT_TYPE.SHOP then
		eventModel = self:createShop(gridModel)
	-- 法阵
	elseif gridType == FuncTowerMap.GRID_BIT_TYPE.MATRIXMETHOD then
		eventModel = TowerMatrixMethodClazz.new(self,gridModel)
	-- 结束点
	elseif gridType == FuncTowerMap.GRID_BIT_TYPE.ENDPOINT then
		eventModel = TowerEndPointClazz.new(self,gridModel)
	-- 五灵池
	elseif gridType == FuncTowerMap.GRID_BIT_TYPE.SPRITPOOL then
		eventModel = TowerSpritPoolClazz.new(self,gridModel)
	-- 毒
	elseif gridType == FuncTowerMap.GRID_BIT_TYPE.POISON then
		eventModel = TowerPoisonClazz.new(self,gridModel)
	-- 障碍物
	elseif gridType == FuncTowerMap.GRID_BIT_TYPE.OBSTACLE then
		eventModel = TowerObstacleClazz.new(self,gridModel)
	-- 散灵法阵
	elseif gridType == FuncTowerMap.GRID_BIT_TYPE.RUNE_TEMPLE then
		eventModel = TowerRuneTempleClazz.new(self,gridModel)
	-- 门(单向通过)
	elseif gridType == FuncTowerMap.GRID_BIT_TYPE.DOOR then
		eventModel = TowerDoorClazz.new(self,gridModel)
	else
		--暂时不做不理
	end

	if eventModel then
		eventModel:setEventType(gridType)
		eventModel:setGrid(gridModel) 
	end

	return eventModel
end

-- 创建宝箱
function TowerMapControler:createBox(gridModel)
	local gridInfo = gridModel:getGridInfo()

	if gridInfo[FuncTowerMap.GRID_BIT.STATUS] == FuncTowerMap.GRID_BIT_STATUS.CLEAR then
		return nil
	end	

	local boxModel = TowerBoxModelClazz.new(self,gridModel)
	return boxModel
end

-- 地图上创建道具model
function TowerMapControler:createItem(gridModel)
	local gridInfo = gridModel:getGridInfo()
	local itemId = gridInfo[FuncTowerMap.GRID_BIT.TYPE_ID]
	local itemClazz = self:getItemScriptClazz(itemId)

	local itemModel = itemClazz.new(self,gridModel)
	return itemModel
end

-- 背包中创建道具model
function TowerMapControler:createItemById(itemId)
	local itemClazz = self:getItemScriptClazz(itemId)
	local itemModel = itemClazz.new(self)
	itemModel:setEventId(itemId)

	return itemModel
end

function TowerMapControler:getItemScriptClazz(itemId)
	local modelPath = "game.sys.view.tower.model."
	local itemData = FuncTower.getGoodsData(itemId)
	local itemScript = itemData.script
	if itemScript == nil then
		itemScript = "TowerItemBaseModel"
	end

	local itemClazz = require(modelPath .. itemScript)
	return itemClazz
end

-- 创建笼子
function TowerMapControler:createCage(xIdx,yIdx)
	local cageModel = nil
	local gridInfo = TowerMapModel:getGridInfo(xIdx,yIdx)
	
	local cageId = gridInfo[FuncTowerMap.GRID_BIT.CAGE]
	if cageId and cageId ~= FuncTowerMap.GRID_BIT_CAGE.NO_CAGE then
		cageModel = TowerCageModelClazz.new(self)
		cageModel:setCageId(cageId)
	end

	return cageModel
end

-- 创建商店
function TowerMapControler:createShop(gridModel)
	local gridInfo = gridModel:getGridInfo()
	local shopInfo = gridInfo.ext
	
	local shopModel = TowerShopModelClazz.new(self,gridModel)
    return shopModel
end

-- 创建npcId spine动画
function TowerMapControler:createNpcSpineById(npcId)
	local npcSourceData = FuncTreasure.getSourceDataById(npcId)

	local npcAnimName = npcSourceData.spine
    local npcAnimLabel = npcSourceData.stand

    local npcNode = nil
    local npcAnim = nil
    if npcId == nil or npcAnimName == nil or npcAnimLabel == nil then
        echoError("npcId =",npcId,",npcAnimName=",npcAnimName,",npcAnimLabel=",npcAnimLabel)
    else
        local spbName = npcAnimName .. "Extract"
        npcAnim = ViewSpine.new(spbName, {}, nil,npcAnimName);
        npcAnim:playLabel(npcAnimLabel);
        npcAnim:setScale(1.0)
    end

    return npcAnim
end

-- 创建主角spine动画
function TowerMapControler:getCharSpine(sex)
	local playerSpine = GarmentModel:getCharGarmentSpine()
	return playerSpine
end

-- 是否是主角的格子
function TowerMapControler:isCharGrid(gridModel)
	return self.charModel:getGridModel() == gridModel
end

function TowerMapControler:deleteMe()
	EventControler:clearOneObjEvent(self)
	
	self:deleteGrids()
	
	if self.map then
		self.map:deleteMe()
	end

	if self.charModel then
		self.charModel:deleteMe()
	end

	-- 删除道具
	for k,v in pairs(self.itemModelArr) do
		v:deleteMe()
	end

	-- if self.sceneControler then
	-- 	self.sceneControler:deleteMe()
	-- end

	if self.pathControler then
		self.pathControler:deleteMe()
	end

	self.ui:unscheduleUpdate()
end

function TowerMapControler:deleteGrids()
	for k,v in pairs(self.gridArr) do
		v:deleteMe()
	end

	self.gridArr = {}
end

-- 寻找土灵符能传送到的格子
-- 优先寻找未探索且无配置事件且没被保护的格子
-- 找不到则找空格子(已探索且无事件)
function TowerMapControler:findTulingFuItemTargetGrid()
	local temptorrent = math.random(2,10)
	local tempNum = math.random(1,temptorrent)
	if tempNum < 1 then
		tempNum = 1
	end
	local hasNum = 0
	local tempGrid = nil
	for k, v in pairs(self.gridArr) do
		if v:checkIsAccessibleByTulingFuItem()  then
			if hasNum < tempNum then
				tempGrid = v
			else
				break
			end
			hasNum = hasNum + 1
		end
	end

	if tempGrid == nil then
		for k, v in pairs(self.gridArr) do
			if v:isEmpty()  then
				if hasNum < tempNum then
					tempGrid = v
				else
					break	
				end
				hasNum = hasNum + 1
			end
		end
	end	
	return tempGrid
end


--设置主角的位置
function TowerMapControler:setHeroPos(pointArr)
	local pos = TowerTools:getGridPos(pointArr.x,pointArr.y)
	local xpos = pos.x
	local ypos = pos.y
	local zpos = 0
	local zorder = self:getGridZOrder(pointArr.x,pointArr.y) + 1
	self.charModel:setZOrder(zorder)
	self.charModel:setPos(xpos,ypos,zpos)
	self.charModel:setCurGrid(cc.p(pointArr.x,pointArr.y))
end

function TowerMapControler:quickOpenGrids()
	local grids = self:getLeftGrids()
	-- 将格子分组
	local gridGroupMap = self:groupGridsByXIdx(grids)

	local keysArr = {}
	for k, v in pairs(gridGroupMap) do
		keysArr[#keysArr+1] = k
	end
	for i=1,#keysArr do
		local xIdx = keysArr[i]
		local gridYArr = gridGroupMap[xIdx]
		local gridsNum = #gridYArr

		for j=1,#gridYArr do
			local yIdx = gridYArr[j]
			local grid = self:findGridModel(xIdx,yIdx)
			grid:quickOpen(j)
		end
	end
end

return TowerMapControler
