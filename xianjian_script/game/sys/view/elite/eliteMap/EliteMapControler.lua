--
--Author:      zhuguangyuan
--DateTime:    2018-02-08 11:31:52
--Description: 精英场景地图控制器
--


local EliteMapTools = require("game.sys.view.elite.eliteMap.EliteMapTools")
local EliteMapClazz = require("game.sys.view.elite.eliteMap.EliteMap")
local ElitePathControlerClazz = require("game.sys.view.elite.eliteMap.ElitePathControler")

local EliteGridModelClazz = require("game.sys.view.elite.eliteModel.EliteGridModel")
local EliteCharModelClazz = require("game.sys.view.elite.eliteModel.EliteCharModel")
local EliteMonsterModelClazz = require("game.sys.view.elite.eliteModel.EliteMonsterModel")
local EliteBoxModelClazz = require("game.sys.view.elite.eliteModel.EliteBoxModel")
local EliteEndPointClazz = require("game.sys.view.elite.eliteModel.EliteEndPointModel")


EliteMapControler = class("EliteMapControler")

function EliteMapControler:ctor(ui,storyId,curEliteChapter)
	self.ui = ui
	self.storyId = storyId
	-- 塔索引
	self.curEliteChapter = curEliteChapter
	local curEliteStoryId = FuncChapter.getStoryIdByChapter(FuncChapter.stageType.TYPE_STAGE_ELITE,curEliteChapter)
	self.isPassStory = WorldModel:isPassStory(curEliteStoryId)

	self:registerEvent()
	self:initData()
	self:initStatus()
	self:initMap()
end

function EliteMapControler:initData()
	self.animFlaName = "UI_suoyaota"

	-- 所有格子的数组
	self.gridArr = {}
    -- 所有格子ID映射map，根据ID可以快速找到gridModel
    self.gridIdMap = {}
    -- TODO所有事件model数组，暂未用到
    self.eventModelArr = {}
    -- 道具的数组
    self.itemModelArr = {}

	self.mapData = EliteMapModel:getEliteMapData(self.curEliteChapter)
	-- dump(self.mapData, "======= self.mapData")

	-- 格子状态
	self.GRID_STATUS = FuncEliteMap.GRID_STATUS

	-- 格子状态对应的panel
	self.GRID_PANELS = FuncEliteMap.GRID_PANELS

	self.charSize = {width=180,height=180}
	self.charScale = 0.8

	-- self.charOffsetY = self.charSize.height * self.charScale / 2
	self.charOffsetY = 0

	-- TODO计算格子排列时的宽高
	self.gridWidth = 150
	self.gridHeight = 75

	self.xNum = table.length(self.mapData)
	self.yNum = table.length(self.mapData["1"])

	self.firstXIdx = 1
	self.firstYIdx = 2

	self.eventScale = 0.8
	self.boxScale = 0.8
	self.gridYOffset = 20

	-- 是否每帧刷新开关
	self.UPDATE_FRAME = false
end

-- 初始化格子动画
function EliteMapControler:createGridAnim(index)
	local gameMiddleLayer = self.map:getGameMiddleLayer()
	local openGridAnim = self.ui:createUIArmature("UI_suoyaota","UI_suoyaota_fangkuaibaozha", 
			gameMiddleLayer, false, GameVars.emptyFunc);
	local griView = self:getGridView(FuncEliteMap.GRID_STATUS.CAN_EXPLORE)
	griView:pos(0,0)
	FuncArmature.changeBoneDisplay(openGridAnim,"node",griView)
	openGridAnim:setVisible(false)

	self.openGridAnimArr[index] = openGridAnim
end

-- 初始化开出怪动画
function EliteMapControler:createMonsterGridAnim(index)
	local gameMiddleLayer = self.map:getGameMiddleLayer()
	local openGridAnim = self.ui:createUIArmature("UI_suoyaota","UI_suoyaota_guawuchuxian", 
			gameMiddleLayer, false, GameVars.emptyFunc);
	local griView = self:getGridView(FuncEliteMap.GRID_STATUS.CAN_EXPLORE)
	griView:pos(0,0)
	FuncArmature.changeBoneDisplay(openGridAnim,"node",griView)
	openGridAnim:setVisible(false)

	self.openMonsterGridAnimArr[index] = openGridAnim
end

-- 初始化新手引导格子动画
function EliteMapControler:createGuideAnim(index)
	local gameMiddleLayer = self.map:getGameMiddleLayer()
	local guideAnim = self.ui:createUIArmature("UI_xianyaojie","UI_xianyaojie_1", 
			gameMiddleLayer, false, GameVars.emptyFunc);
	-- local griView = self:getGridView(FuncEliteMap.GRID_STATUS.CAN_EXPLORE)
	-- griView:pos(0,0)
	-- FuncArmature.changeBoneDisplay(guideAnim,"node",griView)
	guideAnim:setVisible(false)
	guideAnim:setScaleX(1.2)
	guideAnim:setScaleY(0.8)
	self.guideAnimArr[index] = guideAnim
end


function EliteMapControler:initAnimCache()
	self.openGridAnimArr = {}
	self.openMonsterGridAnimArr = {}
	self.guideAnimArr = {}
	self.ui:delayCall(c_func(self.createGridAnim,self,1), 1 / GameVars.GAMEFRAMERATE)
	self.ui:delayCall(c_func(self.createMonsterGridAnim,self,1), 1 / GameVars.GAMEFRAMERATE)
	self.ui:delayCall(c_func(self.createGuideAnim,self,1), 1 / GameVars.GAMEFRAMERATE)
end

-- 初始化状态
function EliteMapControler:initStatus()
	-- 是否正在选择事件目标
	self.isSelectTargetEvent = false
end

function EliteMapControler:setSelectTargetEvent(isSelect,notFindTarget)
	self.isSelectTargetEvent = isSelect
end

function EliteMapControler:registerEvent()
	-- 当数据变更时
	EventControler:addEventListener(EliteEvent.ELITE_GRID_DATA_UPDATE, self.updateData,self)
	-- 自动打开剩余的格子
	EventControler:addEventListener(EliteEvent.ELITE_AUTO_OPEN_LEFT_GRIDS, self.playPerfectAnim,self)
end

function EliteMapControler:initMap()
	-- 场景map皮肤
	local sceneSkin = EliteMapModel:getTowerMapSceneSkin(EliteMainModel:getCurrentChapter())

	self.map = EliteMapClazz.new(self.mapData,self)
	self.map:initMap()

	local backLayer = self.map.backLayer
	-- local backLayer = display.newNode()
	local frontLayer = self.map.frontLayer
	-- self.sceneControler = MapControler.new(backLayer, frontLayer, sceneSkin, false);
	-- self.sceneControler:updatePos(0,0)

	self.ui:scheduleUpdateWithPriorityLua(c_func(self.updateFrame,self),0)

	-- 寻路管理器
	self.pathControler = ElitePathControlerClazz.new(self)

	-- 精英配置的格子只有一屏 且不让拖动
	-- local pos = EliteMapModel:getMapPos()
	-- self:moveMap(pos)

	-- 初始化动画缓存
	self:initAnimCache()

	if not self.UPDATE_FRAME then
		self:updateGrids()
	end
end

-- 移动地图
function EliteMapControler:moveMap(pos)
	if pos then
		self.map:moveMap(pos.x,pos.y)
	end
end

function EliteMapControler:getOpenGridAnim(index)
	if not index then
		return self.openGridAnimArr[1]
	end
	
	if not self.openGridAnimArr[index] then
		self:createGridAnim(index)
	end

	return self.openGridAnimArr[index]
end

function EliteMapControler:getOpenMonsterGridAnim(index)
	if not index then
		return self.openMonsterGridAnimArr[1]
	end
	
	if not self.openMonsterGridAnimArr[index] then
		self:createMonsterGridAnim(index)
	end

	return self.openMonsterGridAnimArr[index]
end

-- 获取新手引导路径动画
function EliteMapControler:getGuideAnim(index)
	if not index then
		return self.guideAnimArr[1]
	end
	
	if not self.guideAnimArr[index] then
		self:createGuideAnim(index)
	end

	return self.guideAnimArr[index]
end

function EliteMapControler:getEliteMap()
	return self.map
end

-- 将路径点转换为主角运动点，去掉未探索的点
function EliteMapControler:pathToPointArr(startPoint,pointList,clickGridModel)
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
function EliteMapControler:getPathMaxZorder(pointArr)
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
function EliteMapControler:getMaxGridZorder()
	local zorder = self:getGridZOrder(self.xNum, self.yNum)
	return zorder
end

-- 移动主角到指定格子数组
function EliteMapControler:moveCharToGrid(gridArr)
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
function EliteMapControler:moveChar(pointArr)
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
		-- local maxZorder = self:getMaxGridZorder()
		-- self.charModel:setZOrder(maxZorder)

		-- 打印路径
		self:testPringPath(pointArr)
		self.charModel:moveByPointArr(pointArr)
		self.charModel:setIsCharMoving(true)
	else
		echo("EliteMapControler:moveChar 已无路可走...")
		self:onCharArriveTargetGrid()
	end
end

-- TODO Test 测试方法，打印路径
function EliteMapControler:testPringPath(pointArr)
	echo("路径如下--------------------")
	local pathStr = ""
	for k,v in pairs(pointArr) do
		pathStr = pathStr .. "(" .. v.xIdx .. "," .. v.yIdx .. ")->"
	end

	echo("pathStr=",pathStr)
end

-- 获取主角移动速度
function EliteMapControler:getCharSpeed(length)
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
function EliteMapControler:resetGrids()
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

function EliteMapControler:playPerfectAnim()
	self.ui:playPerfectAnim(c_func(self.autoOpenLeftGrids,self))
end

-- 自动打开剩余的格子
function EliteMapControler:autoOpenLeftGrids()
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

	local hasExploreGrids = {}
	for i=1,#keysArr do
		local xIdx = keysArr[i]
		local gridYArr = gridGroupMap[xIdx]
		local gridsNum = #gridYArr

		for j=1,#gridYArr do
			local yIdx = gridYArr[j]
			local grid = self:findGridModel(xIdx,yIdx)
			
			hasExploreGrids[xIdx.."_"..yIdx] = {
				["status"] = FuncEliteMap.GRID_BIT_STATUS.EXPLORED,
			}
			local delayTime = i * 0.5 + j * 0.2
			self.map:delayCall(c_func(grid.forceOpen,grid,j), delayTime)
		end
	end
	EliteMapModel:quickSetData( hasExploreGrids )
end

-- 获取剩余的未探索的所有格子
function EliteMapControler:getLeftGrids()
	local grids = {}
	for k, v in pairs(self.gridArr) do
		if not v:hasExplored() then
			grids[#grids+1] = v
		end
	end

	return grids
end

-- 按照X分组然后按照Y降序排序
function EliteMapControler:groupGridsByXIdx(grids)
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
function EliteMapControler:clearGridFlight()
	for k, v in pairs(self.gridArr) do
		v:clearFlight()
	end
end

-- 检查是否可通过
function EliteMapControler:checkCanPass(xIdx,yIdx,isTryFindPath)
	local gridModel = self:findGridModel(xIdx, yIdx)
	local canPass,hasNotExplore = false,false
	canPass,hasNotExplore = gridModel:canPass(isTryFindPath)

	if canPass then
		return true,hasNotExplore
	else
		return false
	end
end

-- 地图点击事件
function EliteMapControler:onClickMapBegin(pos)
	if self.charModel:isCharMoving() then
		echo("主角正在运动中...........")
		return
	end

	local gridModel = EliteMapTools:getGridPosByWordPos(pos,self.gridArr)
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

function EliteMapControler:onClickMapMove()
	self:clearGridFlight()
	if self.clickEvent then
		self.nowNewGrid:showBtnDownEffect()
		self.clickEvent = false
	end	
end

-- 地图点击事件
function EliteMapControler:onClickMapEnd(pos)
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
	local gridModel = EliteMapTools:getGridPosByWordPos(pos,self.gridArr)
	if gridModel then
		self:onClickGrid(gridModel)
	end
end

function EliteMapControler:getGridModelByPos(pos)
	local gridModel = EliteMapTools:getGridPosByWordPos(pos,self.gridArr)
	return gridModel
end

-- 是否是相邻的grid model
function EliteMapControler:isSurroundGrid(startGrid,endGrid)
	local startPoint = cc.p(startGrid.xIdx,startGrid.yIdx)
	local endPoint = cc.p(endGrid.xIdx,endGrid.yIdx)
	return self.pathControler:isSurroundPoint(startPoint,endPoint)
end

-- 两个grid间是否有路径
function EliteMapControler:hasPath(startGrid,endGrid)
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
function EliteMapControler:checkActiveGrid(grid)
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
function EliteMapControler:onClickGrid(gridModel)
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
	
	-- 如果不激活格子响应事件
	if not self:checkActiveGrid(gridModel) then
		echo("不激活格子")
		return
	else
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
function EliteMapControler:onCharArriveGrid()
	EventControler:dispatchEvent(EliteEvent.ELITE_CHAR_ARRIVE_GIRD)
end

-- 主角运动到了目标格子
function EliteMapControler:onCharArriveTargetGrid()
	-- 修正主角朝向
	self:adjustCharView()
	if not self.UPDATE_FRAME then
		-- 更新格子
		self:updateGrids()
	end

	local charGridPos = self.charModel:getCurGrid()
	-- 精英探索功能的探索进度数据 是保存在本地的
	-- 保存在关闭场景界面的时候进行 主角的位置也需要同步在那里保存 
	-- 不然会造成主角位置错误 
	-- EliteMapModel:saveCharGridPos(charGridPos.x,charGridPos.y,self.curEliteChapter)

	-- 主角绕过怪时，该变量该nil
	if not self.clickedGridModel then
		return
	end

	local gridModel = self.clickedGridModel
	echo("\n--------主角运动到了目标格子gridModel=",gridModel.xIdx,gridModel.yIdx)
	echo("格子状态=",gridModel:getGridStatus())

	EventControler:dispatchEvent(EliteEvent.ELITE_CHAR_ARRIVE_GIRD,{grid=gridModel})
	-- 点击的是已经打开的格子
	if gridModel:hasExplored() then
		self.isHandlingEvent = true
		self.ui:disabledUIClick()
		-- EliteMainModel.isHandlingEvent = true
		local function resetIsHandlingEvent( ... )
			self.isHandlingEvent = false
			self.ui:resumeUIClick()
			-- EliteMainModel.isHandlingEvent = false
		end
		self.ui:delayCall(c_func(resetIsHandlingEvent), 0.3) --1 / GameVars.GAMEFRAMERATE
		gridModel:onGridResponse()
	else
		local xIdx  = gridModel.xIdx
		local yIdx = gridModel.yIdx
		echo("正在打开格子...")
		self.isOpenGrid = true
		self:onOpenGridCallBack(xIdx,yIdx)
	end
end

-- 修正主角朝向
function EliteMapControler:adjustCharView()
	-- 修正主角朝向
	self.charModel:adjustViewAction()
	self.charModel:adjustZOrder()
end

-- 打开格子成功回调
function EliteMapControler:onOpenGridCallBack(xIdx,yIdx)
	local data = {}
	data[xIdx.."_"..yIdx] = {
		["status"] = FuncEliteMap.GRID_BIT_STATUS.EXPLORED,
	}

	local info = EliteMapModel:getGridInfo(xIdx,yIdx)
	if info then
	    -- 如果是怪 则确定怪id
		if (tostring(info[FuncEliteMap.GRID_BIT.TYPE])  == FuncEliteMap.GRID_BIT_TYPE.MONSTER) then
			local section = EliteMapModel:getNextSectionByChapter()
			local curChapterMaxSection = FuncChapter.getMaxSectionByStoryId(self.storyId)
			if section <= curChapterMaxSection then
				echo("______ 确定怪id ___________")

				local toDoRaidId = FuncChapter.getRaidIdByStoryId(self.storyId,section)
				data[xIdx.."_"..yIdx]["typeId"] = toDoRaidId 
				if self.willExploreGrid then
					self.willExploreGrid:onOpenGridSuccess(nil,toDoRaidId)
				end
			else
				-- 配表配置的怪位置多于本章关卡数量 的容错处理
				data[xIdx.."_"..yIdx]["status"] = FuncEliteMap.GRID_BIT_STATUS.CLEAR 
			end
		else
			if self.willExploreGrid then
				self.willExploreGrid:onOpenGridSuccess(nil)
			end
		end
	else
		-- dump(info, "格子信息")
		-- echoError("_____ xIdx,yIdx ________",xIdx,yIdx)
	end
	EliteMainModel:updateData(data)

	self.isOpenGrid = false
	self.willExploreGrid = nil
end

function EliteMapControler:findGridByMonsterId(monsterId)
	for k, v in pairs(self.gridArr) do
		if v.eventModel and v.eventModel:getEventType() == FuncEliteMap.GRID_BIT_TYPE.MONSTER
			and v.eventModel:getEventId() == monsterId then
			return v
		end
	end

	return nil
end

-- 查找gridModel
function EliteMapControler:findGridModel(xIdx,yIdx)
	local gridId = EliteMapModel:gridPosToId(xIdx, yIdx)
	local gridIdx = self.gridIdMap[gridId]
	if not gridIdx then
		return nil
	end

	local gridModel = self.gridArr[gridIdx]
	return gridModel
end

-- 找gridModel周围的格子
function EliteMapControler:getSurroundGrids(gridModel)
	local grids = {}
	local targetPoint = {x=gridModel.xIdx,y=gridModel.yIdx}
	local points = FuncEliteMap.getSurroundPoints(targetPoint)

	for k,v in pairs(points) do
		local curGridModel = self:findGridModel(v.x,v.y)
		if curGridModel  then
			grids[#grids+1] = curGridModel
		end
	end

	return grids
end

-- 判断指定gridModel周围是否有空的格子
function EliteMapControler:hasEmptyNeighbor(gridModel)
	local targetPoint = {x=gridModel.xIdx,y=gridModel.yIdx}
	local points = FuncEliteMap.getSurroundPoints(targetPoint)

	for k,v in pairs(points) do
		local curGridModel = self:findGridModel(v.x,v.y)
		if curGridModel and curGridModel:isEmpty() then
			return true
		end
	end
	return false
end

-- 找到守护gridModel的那些格子
function EliteMapControler:getGuardMeGrids(gridModel)
	local grids = {}

	local targetPoint = {x=gridModel.xIdx,y=gridModel.yIdx}
	local points = FuncEliteMap.getGuardMePoints(targetPoint)

	for k,v in pairs(points) do
		local curGridModel = self:findGridModel(v.x,v.y)
		if curGridModel and not curGridModel:isEmpty() then
			grids[#grids+1] = curGridModel
		end
	end

	return grids
end

-- 是否有警戒状态的怪
function EliteMapControler:hasAlertMonster()
	if not self.hasSceneAlertMonster then
		self.hasSceneAlertMonster = false
	end
	for k, v in pairs(self.gridArr) do
		if v:hasAlertMonster() then
			if not self.hasSceneAlertMonster then
				self.hasSceneAlertMonster = true
				EventControler:dispatchEvent(EliteEvent.ELITE_IS_HAS_ALERT_MONSTER_CHANGE, {isHas = self.hasSceneAlertMonster})
			end
			return true
		end
	end
	if self.hasSceneAlertMonster then
		self.hasSceneAlertMonster = false
		EventControler:dispatchEvent(EliteEvent.ELITE_IS_HAS_ALERT_MONSTER_CHANGE, {isHas = self.hasSceneAlertMonster})
	end
	return false
end

-- ================================== 刷新类方法 ================================== 
function EliteMapControler:updateData()
	self:updateGrids()
end


-- 根据道具ID,从获得的道具列表中查找道具
function EliteMapControler:findTargetItemById(itemId,itemTime)
	for i=1,#self.itemModelArr do
		local itemModel = self.itemModelArr[i]
		if itemModel:getEventId() == itemId and itemModel:getItemTime() == itemTime then
			return itemModel
		end
	end

	return nil
end

-- 更新所有格子
function EliteMapControler:updateGrids()
	local updateFunc = function()
		for k,v in pairs(self.gridArr) do
			v:updateFrame()
		end
	end
	
	updateFunc()
	self.map:delayCall(c_func(updateFunc), 1/GameVars.GAMEFRAMERATE)
end

function EliteMapControler:sortGrids()
	for k,v in pairs(self.gridArr) do
		local zorder = self:getGridZOrder(v.xIdx,v.yIdx)
		v:setZOrder(zorder)
	end
end

-- 每帧刷新方法
function EliteMapControler:updateFrame(dt)
	if self.UPDATE_FRAME then
		self:updateGrids()
	end
	
	self:sortGrids()
	
	if self.charModel then
		self.charModel:updateFrame()
		-- 已经初始化了所有状态
		if not self.hasInitAllStatus then
			self.hasInitAllStatus = true
		end
	end

	if self.curEliteChapter > 1 or self.isPassStory then
		return
	end
	
	-- 更新新手移到路径动画
	local lightenArr = {}
	local charGrid = self.charModel:getCurGrid()
	local startPoint = {x=charGrid.x,y=charGrid.y}
    local endPoint = self:getNextMonsterPosGrid(startPoint)
    if not endPoint then
	    return
	end
    local _,pathArr = self.pathControler:findPath(startPoint,endPoint,true)
    pathArr[#pathArr + 1] = table.deepCopy(endPoint)
    -- dump(pathArr, "pathArr", nesting)
    -- 如果有警戒怪 则隐藏所有引导路径
    if self:hasAlertMonster() or 
    	(startPoint.x == endPoint.x and startPoint.y == endPoint.y) then
    	pathArr = {}
    end
  	-- echo("主角寻路(" .. startPoint.x .. "," ..  startPoint.y .. ")")
    local lastPoint = startPoint
    for k,v in ipairs(pathArr) do
    	local nextPoint = {x=v.x,y=v.y}
    	local rotation = self:calculateRotation(lastPoint,nextPoint)
    	local index = lastPoint.x.."_"..lastPoint.y
    	lightenArr[#lightenArr + 1] = index
    	local lastAnim = self:getGuideAnim(index)
    	local pos = EliteMapTools:getGridPos( lastPoint.x,lastPoint.y )
		lastAnim:pos(pos.x,pos.y)
		if (rotation > 55 and rotation < 65) then
			lastAnim:setScaleX(0.7)
		elseif (rotation > -125 and rotation < -115) then
			lastAnim:setScaleX(0.9)
			-- lastAnim:pos(pos.x+10,pos.y+10)
		elseif (rotation > -5 and rotation < 5) then
			lastAnim:setScaleX(1.3)
		end
		lastAnim:setRotation(180-rotation)
		-- +1 防止被新创建的地板盖住动画
		local zOrder = self:getGridZOrder(lastPoint.x,lastPoint.y)
		local zOrder2 = self:getGridZOrder(nextPoint.x,nextPoint.y)
		if zOrder < zOrder2 then
			zOrder = zOrder2
		end
		lastAnim:zorder(zOrder+3)
    	lastAnim:setVisible(true)
	    -- FuncArmature.setArmaturePlaySpeed(lastAnim,1.3)
	    lastPoint = nextPoint
	    -- echo("--rotation__ "..rotation.." __-->(" .. nextPoint.x .. "," .. nextPoint.y .. ")")
    end 
	-- echo("\n\n")
    -- 隐藏非路径上的特效
    for k,v in pairs(self.guideAnimArr) do
    	if not table.isValueIn(lightenArr,k) then
    		v:setVisible(false)
    	end
    end
end

function EliteMapControler:calculateRotation(lastPoint,nextPoint)
	local lastPos = EliteMapTools:getGridPos(lastPoint.x,lastPoint.y)
	local nextPos = EliteMapTools:getGridPos(nextPoint.x,nextPoint.y)
	local dx = nextPos.x - lastPos.x
	local dy = nextPos.y - lastPos.y
	local radian = math.atan2(dy, dx)
	return radian * 180 / math.pi
end

-- 获取下一个怪怪位置的x_y坐标
-- 只有探索完一个怪之后才需要更新,此时传入isForceUpgrade
-- 由于每次通关某关卡都需进战斗,且进战斗会将场景及本控制器删除,再次进入时重新走了这个函数
-- 所以无需传入参数
function EliteMapControler:getNextMonsterPosGrid(startPoint)
	if self.curEliteChapter > 1 then
		return
	end
	-- if not self.targetPoint then
		local gridArr = EliteMapModel:getAllToExploreGrids()
		local charGrid = self.charModel:getCurGrid()
		self.targetPoint = {x=tonumber(charGrid.x),y=tonumber(charGrid.y)}
		local lastPathLen = 1000
		for k,v in pairs(gridArr) do
			local endPoint = {x=tonumber(v.x),y=tonumber(v.y)}
	    	local _,pathArr = self.pathControler:findPath(startPoint,endPoint,true)
			if #pathArr < lastPathLen then
				lastPathLen = #pathArr
				self.targetPoint = endPoint
			end
		end
	-- end
	-- dump(self.targetPoint, "下一个目标点", nesting)
	return self.targetPoint
end
-- ================================== 创建类方法 ================================== 
-- 创建一个格子model
function EliteMapControler:createGridModel(xIdx,yIdx)
	local gridInfo = EliteMapModel:getGridInfo(xIdx,yIdx)
	local gameBackLayer = self.map:getGameMiddleLayer()

	-- 计算出格子坐标
	local pos = EliteMapTools:getGridPos(xIdx,yIdx)
	local xpos,ypos = pos.x,pos.y
	local zpos = 0
	-- echo("----------------------xIdx,yIdx,x,y=",xIdx,yIdx,xpos,ypos)

	local gridModel = EliteGridModelClazz.new(self,xIdx,yIdx,gridInfo)
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
function EliteMapControler:getGridZOrder(xIdx,yIdx)
	return xIdx+yIdx * 10
end

-- 根据格子状态，创建对应的view
function EliteMapControler:getGridView(gridStatus)
	local view = nil
	if gridStatus == self.GRID_STATUS.CAN_EXPLORE then
		view = self.ui:createUIArmature("UI_xianyaojie","UI_xianyaojie_dikuaizong",nil,true,GameVars.emptyFunc)
		view:setScale(1.2)
	else
		local cacheList = self.map:getGridPanelCacheList()
		local cachePanel = cacheList[gridStatus]
		view = UIBaseDef:cloneOneView(cachePanel)
	end

	return view
end

-- 创建主角
function EliteMapControler:createChar()
	local charOffsetY = self.charOffsetY

	local gameMiddleLayer = self.map:getGameMiddleLayer()

	local xIdx,yIdx = EliteMapModel:getCharGridPos(self.curEliteChapter)
	echo("_____xIdx,yIdx_________",xIdx,yIdx)

	-- 主角zorder
	local zorder = self:getGridZOrder(xIdx,yIdx) + 1

	local pos = EliteMapTools:getGridPos(xIdx,yIdx)
	local xpos = pos.x
	local ypos = pos.y - charOffsetY
	local zpos = 0

	local charSex = nil
	if PrologueUtils:showPrologue() then
		charSex = FuncChar.getCharSex(LoginControler:getLocalRoleId())
	else
		charSex = UserModel:sex()
	end

	local charModel = EliteCharModelClazz.new(self,charSex)
	local playerSpine = self:getCharSpine(charSex)
   
    charModel:initView(gameMiddleLayer,playerSpine,xpos,ypos,zpos,self.charSize)
    charModel:setViewScale(self.charScale)
    charModel:setZOrder(zorder)
    charModel:setCurGrid(cc.p(xIdx,yIdx))

    self.charModel = charModel
end

-- 查找指定类型的事件对象的格子
function EliteMapControler:findGridsByType(eventType)
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
function EliteMapControler:findEventModelsByType(eventType)
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
function EliteMapControler:findNotExploredGrids()
	local gridsArr = {}
	for k,v in pairs(self.gridArr) do
		if not v:hasExplored() then
			gridsArr[#gridsArr+1] = v
		end
	end

	return gridsArr
end

-- 创建事件对象模型
function EliteMapControler:createEventModels(gridModel)
	local gridInfo = gridModel:getGridInfo()
	-- dump(gridInfo, "创建事件模型获取格子info")

	-- 网格事件类型
	local gridType = gridInfo[FuncEliteMap.GRID_BIT.TYPE]
	local eventModel = nil
	-- 空格子
	if gridType == FuncEliteMap.GRID_BIT_TYPE.EMPTY then
		-- 不做处理
	-- 怪
	elseif gridType == FuncEliteMap.GRID_BIT_TYPE.MONSTER then
		local raidId = gridInfo[FuncEliteMap.GRID_BIT.TYPE_ID]
		eventModel = EliteMonsterModelClazz.new(self,gridModel,raidId)
	-- 宝箱
	elseif gridType == FuncEliteMap.GRID_BIT_TYPE.BOX then
		eventModel = self:createBox(gridModel)
	-- 结束点
	elseif gridType == FuncEliteMap.GRID_BIT_TYPE.EXIT then
		eventModel = EliteEndPointClazz.new(self,gridModel)
	else
	end

	if eventModel then
		eventModel:setEventType(gridType)
		eventModel:setGrid(gridModel)
	end

	return eventModel
end

-- 创建宝箱
function EliteMapControler:createBox(gridModel)
	local gridInfo = gridModel:getGridInfo()

	-- 如果已经领取,则不再创建宝箱
	if gridInfo[FuncEliteMap.GRID_BIT.STATUS] == FuncEliteMap.GRID_BIT_STATUS.CLEAR then
		return nil
	end	

	local boxModel = EliteBoxModelClazz.new(self,gridModel)
	return boxModel
end

-- -- 地图上创建道具
-- function EliteMapControler:createItem(gridModel)
-- 	local gridInfo = gridModel:getGridInfo()
-- 	local itemId = gridInfo[FuncEliteMap.GRID_BIT.TYPE_ID]
-- 	local itemClazz = self:getItemScriptClazz(itemId)

-- 	local itemModel = itemClazz.new(self,gridModel)
-- 	return itemModel
-- end

-- 背包中创建道具
function EliteMapControler:createItemById(itemId)
	local itemClazz = self:getItemScriptClazz(itemId)
	local itemModel = itemClazz.new(self)
	itemModel:setEventId(itemId)

	return itemModel
end

function EliteMapControler:getItemScriptClazz(itemId)
	local modelPath = "game.sys.view.tower.model."
	local itemData = FuncTower.getGoodsData(itemId)
	local itemScript = itemData.script
	if itemScript == nil then
		itemScript = "TowerItemBaseModel"
	end

	local itemClazz = require(modelPath .. itemScript)
	return itemClazz
end

-- -- 创建笼子
-- function EliteMapControler:createCage(xIdx,yIdx)
-- 	local cageModel = nil
-- 	local gridInfo = EliteMapModel:getGridInfo(xIdx,yIdx)
	
-- 	local cageId = gridInfo[FuncEliteMap.GRID_BIT.CAGE]
-- 	if cageId and cageId ~= FuncEliteMap.GRID_BIT_CAGE.NO_CAGE then
-- 		cageModel = TowerCageModelClazz.new(self)
-- 		cageModel:setCageId(cageId)
-- 	end

-- 	return cageModel
-- end

-- -- 创建商店
-- function EliteMapControler:createShop(gridModel)
-- 	local gridInfo = gridModel:getGridInfo()
-- 	local shopInfo = gridInfo.ext
	
-- 	local shopModel = TowerShopModelClazz.new(self,gridModel)
--     return shopModel
-- end

-- -- 创建npcId spine动画
-- function EliteMapControler:createNpcSpineById(npcId)
-- 	local npcSourceData = FuncTreasure.getSourceDataById(npcId)

-- 	local npcAnimName = npcSourceData.spine
--     local npcAnimLabel = npcSourceData.stand

--     local npcNode = nil
--     local npcAnim = nil
--     if npcId == nil or npcAnimName == nil or npcAnimLabel == nil then
--         echoError("npcId =",npcId,",npcAnimName=",npcAnimName,",npcAnimLabel=",npcAnimLabel)
--     else
--         local spbName = npcAnimName .. "Extract"
--         npcAnim = ViewSpine.new(spbName, {}, nil,npcAnimName);
--         npcAnim:playLabel(npcAnimLabel);
--         npcAnim:setScale(1.0)
--     end

--     return npcAnim
-- end

-- 创建主角spine动画
function EliteMapControler:getCharSpine(sex)
	local playerSpine = GarmentModel:getCharGarmentSpine()
	return playerSpine
end

-- 是否是主角的格子
function EliteMapControler:isCharGrid(gridModel)
	return self.charModel:getGridModel() == gridModel
end

function EliteMapControler:deleteMe()
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

function EliteMapControler:deleteGrids()
	for k,v in pairs(self.gridArr) do
		v:deleteMe()
	end

	self.gridArr = {}
end

function EliteMapControler:findEmptyGrid()
	local temptorrent = math.random(2,10)
	local tempNum = math.random(1,temptorrent)
	if tempNum < 1 then
		tempNum = 1
	end
	dump(tempNum,"飞行的次数")
	local hasNum = 0
	local tempGridData = nil
	for k, v in pairs(self.gridArr) do
		if v:isTuLingFuEmpty()  then
			if hasNum < tempNum then
				tempGridData = v
			else
				break
			end
			hasNum = hasNum + 1
		end
	end

	if tempGridData == nil then
		for k, v in pairs(self.gridArr) do
			if v:isEmpty()  then
				if hasNum < tempNum then
					tempGridData = v
				else
					break	
				end
				hasNum = hasNum + 1
			end
		end
	end	
	return tempGridData
end


--设置主角的位置
function EliteMapControler:setHeroPos(pointArr)
	local pos = EliteMapTools:getGridPos(pointArr.x,pointArr.y)
	local xpos = pos.x
	local ypos = pos.y
	local zpos = 0
	local zorder = self:getGridZOrder(pointArr.x,pointArr.y) + 1
	self.charModel:setZOrder(zorder)
	self.charModel:setPos(xpos,ypos,zpos)
	self.charModel:setCurGrid(cc.p(pointArr.x,pointArr.y))
end

function EliteMapControler:quickOpenGrids()
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


return EliteMapControler
