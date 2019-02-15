--
--Author:      zhuguangyuan
--DateTime:    2018-02-08 11:30:33
--Description: 机关控制器
--

local EliteGridModelClazz = require("game.sys.view.elite.eliteModel.EliteGridModel")
local EliteCharModelClazz = require("game.sys.view.elite.eliteModel.EliteCharModel")
local EliteMonsterModelClazz = require("game.sys.view.elite.eliteModel.EliteMonsterModel")
local EliteBoxModelClazz = require("game.sys.view.elite.eliteModel.EliteBoxModel")
local EliteEndPointClazz = require("game.sys.view.elite.eliteModel.EliteEndPointModel")


-- 相关类
local EliteGearMapTools = require("game.sys.view.elite.eliteGearMap.EliteGearMapTools")
local EliteGearMapClazz = require("game.sys.view.elite.eliteGearMap.EliteGearMap")
local EliteGearPathControlerClazz = require("game.sys.view.elite.eliteGearMap.EliteGearPathControler")

local EliteCubeLightClazz = require("game.sys.view.elite.eliteModel.EliteCubeLightModel")
local EliteCubeMoveClazz = require("game.sys.view.elite.eliteModel.EliteCubeMoveModel")
local EliteCubeSenderClazz = require("game.sys.view.elite.eliteModel.EliteCubeSenderModel")
local EliteCubeReceiverClazz = require("game.sys.view.elite.eliteModel.EliteCubeReceiverModel")
local EliteCubeBorderClazz = require("game.sys.view.elite.eliteModel.EliteCubeBorderModel")


EliteGearMapControler = class("EliteGearMapControler")

function EliteGearMapControler:ctor(ui,boxId,curEliteGearId)
	self.ui = ui
	self.boxId = boxId
	-- 机关id
	self.curEliteGearId = curEliteGearId

	self:registerEvent()
	self:initData()
	self:initMap()
end

function EliteGearMapControler:initData()

	-- 机关数据
	self.organData = FuncEliteMap.getOneEliteOrganMapData(self.curEliteGearId)
	self.maxNumX = table.length(self.organData)
	self.maxNumY = table.length(self.organData["1"])
	-- dump(self.organData, "机关表数据 self.organData ")

	-- 所有格子 vector
	self.allCubeVector = {} 
	self.lightCubeVector = {} 
	self.moveCubeVector = {} 
	self.senderCubeVector = {} 
	self.receiverCubeVector = {} 
	self.borderCubeVector = {} 
	-- 格子宽高及所有格子的坐标
	-- self.cubeWidth = (GameVars.width)/GameVars.gameResWidth * 100
	-- self.cubeHeight = (GameVars.height)/GameVars.gameResHeight * 86

	self.cubeWidth = 86.7
	self.cubeHeight = 86.7

	self.allGridPos = {}

	-- echo("_____初始化方块的大小 self.cubeWidth,self.cubeHeight __________",self.cubeWidth,self.cubeHeight)
	-- 格子排列初识位置
	-- self.initGridPosX = GameVars.gameResWidth - 70 + (GameVars.width-GameVars.gameResWidth)/2
	-- self.initGridPosY = (GameVars.height-GameVars.gameResHeight)/8
	self.initGridPosX = 1048 --+(GameVars.width-GameVars.gameResWidth)/2
	self.initGridPosY = -13---(GameVars.height-GameVars.gameResHeight)/2

	self.animFlaName = "UI_suoyaota"

	-- 所有格子的数组
	self.gridArr = {}
    -- 所有格子ID映射map，根据ID可以快速找到gridModel
    self.gridIdMap = {}
    -- TODO所有事件model数组，暂未用到
    self.eventModelArr = {}
    -- 道具的数组
    self.itemModelArr = {}

	self.gearMapData = EliteMapModel:getEliteMapData(self.curEliteGearId)
	-- dump(self.gearMapData, "======= self.gearMapData")

	-- 格子状态
	self.GRID_STATUS = FuncEliteMap.GRID_STATUS

	-- 格子状态对应的panel
	self.GRID_PANELS = FuncEliteMap.GRID_PANELS

	self.charSize = {width=180,height=180}
	self.charScale = 0.8

	-- self.charOffsetY = self.charSize.height * self.charScale / 2
	self.charOffsetY = 0

	-- TODO计算格子排列时的宽高
	self.gridWidth = 168
	self.gridHeight = 75

	self.xNum = table.length(self.gearMapData)
	self.yNum = table.length(self.gearMapData["1"])

	self.firstXIdx = 1
	self.firstYIdx = 2

	self.eventScale = 0.8
	self.boxScale = 0.8
	self.gridYOffset = 20

	-- 是否每帧刷新开关
	self.UPDATE_FRAME = true
end

-- 初始化所有地图上的cube
function EliteGearMapControler:initAllCubeView()
	for k,v in pairs(self.organData) do
		local row = tonumber(k)
		self.rectVector = {}
		for kk,vv in pairs(v) do
			local column = tonumber(kk)

			-- 初始化数据
			local cubeType1 = vv.info
			local d11,d22 = nil,nil--self:getDirectionByCubeType(cubeType1)
			-- local x1,y1 = self:getGridPos(k,kk)

			local itemData = {
				Idx = row,
				Idy = column,
				d1 = d11,
				d2 = d22,
				cubeType = cubeType1,
			}
			self.rectVector[row.."_"..column] = itemData

			-- 初始化光view
			if row == 1 or row == self.maxNumX 
				or column == 1 or column == self.maxNumY 
			then
				-- 初始化发射器
				if vv.info == FuncEliteMap.ORGAN_MAP_GRID_TYPE.SENDER then
					local senderItemView = UIBaseDef:cloneOneView(self.ui.mc_block)
					-- local oneSenderCube = EliteCubeSenderClazz.new(itemData,senderItemView,self)
					-- local oneSenderCube = EliteCubeSenderClazz.new(self,k,kk,itemData,senderItemView)
					local oneSenderCube = EliteCubeSenderClazz.new(self,k,kk,itemData)
					oneSenderCube:initView(nil,senderItemView)
					self.senderCubeVector[row.."_"..column] = oneSenderCube
					self.allCubeVector[row.."_"..column] = oneSenderCube

				-- 初始化接收器
				elseif vv.info == FuncEliteMap.ORGAN_MAP_GRID_TYPE.RECEIVER then
					local receiverItemView = UIBaseDef:cloneOneView(self.ui.mc_block)
					-- local oneReceiverCube = EliteCubeReceiverClazz.new(itemData,receiverItemView,self)
					-- local oneReceiverCube = EliteCubeReceiverClazz.new(self,k,kk,itemData,receiverItemView)
					local oneReceiverCube = EliteCubeReceiverClazz.new(self,k,kk,itemData)
					oneReceiverCube:initView(nil,receiverItemView)
					self.receiverCubeVector[row.."_"..column] = oneReceiverCube
					self.allCubeVector[row.."_"..column] = oneReceiverCube
				
				-- 初始化边界cube
				else
					local borderItemView = UIBaseDef:cloneOneView(self.ui.mc_block)
					-- local oneBorderCube = EliteCubeBorderClazz.new(itemData,borderItemView,self)
					-- local oneBorderCube = EliteCubeBorderClazz.new(self,k,kk,itemData,borderItemView)
					local oneBorderCube = EliteCubeBorderClazz.new(self,k,kk,itemData)
					oneBorderCube:initView(nil,borderItemView)
					self.borderCubeVector[row.."_"..column] = oneBorderCube
					self.allCubeVector[row.."_"..column] = oneBorderCube
				end
			else
				local lightItemView = UIBaseDef:cloneOneView(self.ui.panel_route_1_1)
				-- local onelightCube = EliteCubeLightClazz.new(itemData,lightItemView,self)
				-- local onelightCube = EliteCubeLightClazz.new(self,k,kk,itemData,lightItemView)
				local onelightCube = EliteCubeLightClazz.new(self,k,kk,itemData)
				onelightCube:initView(nil,lightItemView)
				self.lightCubeVector[row.."_"..column] = onelightCube
				self.allCubeVector[row.."_"..column] = onelightCube
			end

			-- 初始化可移动块
			if vv.info == FuncEliteMap.ORGAN_MAP_GRID_TYPE.CUBE_WS
				or vv.info == FuncEliteMap.ORGAN_MAP_GRID_TYPE.CUBE_ES
				or vv.info == FuncEliteMap.ORGAN_MAP_GRID_TYPE.CUBE_EN
				or vv.info == FuncEliteMap.ORGAN_MAP_GRID_TYPE.CUBE_WN
				or vv.info == FuncEliteMap.ORGAN_MAP_GRID_TYPE.CUBE_SOLID
			then
				local moveItemView = UIBaseDef:cloneOneView(self.ui.mc_block)
				-- local oneMoveCube = EliteCubeMoveClazz.new(itemData,moveItemView,self)
				-- local oneMoveCube = EliteCubeMoveClazz.new(self,k,kk,itemData,moveItemView)
				local oneMoveCube = EliteCubeMoveClazz.new(self,k,kk,itemData)
				oneMoveCube:initView(nil,moveItemView)
				
				self.moveCubeVector[row.."_"..column] = oneMoveCube
				self.allCubeVector[row.."_"..column] = oneMoveCube
			end
		end
	end
end

-- 更新所有光路和格子
function EliteGearMapControler:updateLightRouteView()
	-- self.lightCubeVector = {} 
	-- self.moveCubeVector = {} 
	-- self.senderCubeVector = {} 
	-- self.receiverCubeVector = {} 
	-- echo("\n\n______ 更新光路... ___________")
	local senderNum = 0
	local hasSucceedNum = 0

	for k,receiverCubeModel in pairs(self.receiverCubeVector) do
		receiverCubeModel.isSucceed = false
	end
	for k,senderCubeModel in pairs(self.senderCubeVector) do
		senderNum = senderNum + 1
		local stop,hasFind = false,false
		local _direction = senderCubeModel.rotationAngle1
		local Idx,Idy = senderCubeModel.xIdx,senderCubeModel.yIdx

		local traverseNum = 0
		-- echo("\n\n______ 光 k 寻路开始... ___________",k)
		while not stop and not hasFind do
			local nextCube = self:getNextCubeByDirection(Idx,Idy,_direction)
			if not nextCube then
				-- echo("___ 寻路结束!!! not nextCube _Idx,Idy,_direction__",Idx,Idy,_direction)
				stop = true
				break
			end
			traverseNum = traverseNum + 1
			-- echo("\n_______ 第 traverseNum 个格子 _________",traverseNum)

			if self.lightCubeVector[Idx.."_"..Idy] then
				self.lightCubeVector[Idx.."_"..Idy].hasTraverse = true
			end

			-- 遇到边界或者不透光格子寻路结束
			if (nextCube.isCanMove and (nextCube.cubeType == FuncEliteMap.ORGAN_MAP_GRID_TYPE.CUBE_SOLID))
				or (not nextCube.isCanMove) and (nextCube.cubeType ~= FuncEliteMap.ORGAN_MAP_GRID_TYPE.RECEIVER) 
			then
				-- echo("___ 遇到边界或者不透光格子寻路结束 ___")
				stop = true

			-- 遇到接收器 寻路成功
			elseif nextCube.cubeType == FuncEliteMap.ORGAN_MAP_GRID_TYPE.RECEIVER then
				-- echo("___ 遇到接收器 ___")
				-- dump(nextCube, "遇到接收器", 2)
				hasSucceedNum = hasSucceedNum + 1
				nextCube.isSucceed = true
				hasFind = k
				stop = true
				break

			-- 无障碍,继续前进
			elseif nextCube.cubeType == FuncEliteMap.ORGAN_MAP_GRID_TYPE.EMPTY then
				local r1 = _direction
				local r2 = _direction - 180
				if r2 < 0 then
					r2 = r2 + 360 
				end

				if nextCube.hasTraverse then
					-- echo("_________ 已经有光路通过 _________")
					nextCube:updateLightRotation2(r1,r2)
				else
					nextCube:updateLightRotation(r1,r2)
					nextCube:updateLightRotation2()
				end
				Idx,Idy = nextCube.xIdx,nextCube.yIdx
				-- echo("___光线直行... r1,r2 __",r1,r2)
				-- echo("___下一个indx... Idx,Idy __",Idx,Idy)

			-- 遇到可能改变光方向的cube
			else
				-- echo("___ 遇到可能改变光方向的cube ___")
				local isRotatison1 = _direction - nextCube.rotationAngle1
				local isRotatison2 = _direction - nextCube.rotationAngle2
				if (isRotatison1 == 180) or (isRotatison1 == -180) then
					isRotatison1 = true
					_direction = nextCube.rotationAngle2
					Idx,Idy = nextCube.xIdx,nextCube.yIdx
					nextCube:setAniLighten( true )
					-- echo("___ 遇到可能改变光方向的cube _111__")
					-- echo("___下一个indx... Idx,Idy,_direction __",Idx,Idy,_direction)

				elseif (isRotatison2 == 180) or (isRotatison2 == -180) then
					isRotatison2 = true
					_direction = nextCube.rotationAngle1
					Idx,Idy = nextCube.xIdx,nextCube.yIdx
					nextCube:setAniLighten( true )

					-- echo("___ 遇到可能改变光方向的cube __222_")
					-- echo("___下一个indx... Idx,Idy,_direction __",Idx,Idy,_direction)
				else
					stop = true
					Idx,Idy = nextCube.xIdx,nextCube.yIdx
					if nextCube.lightenAni then
						if self.moveCubeVector[Idx.."_"..Idy] and self.moveCubeVector[Idx.."_"..Idy].hasTraverse and nextCube.isHasLightPass then
						else
							nextCube:setAniLighten( false )
						end
					end
					-- echo("___ 遇到可能改变光方向的cube _ 停止!!!__")
				end
				if self.moveCubeVector[nextCube.xIdx.."_"..nextCube.yIdx] then
					self.moveCubeVector[nextCube.xIdx.."_"..nextCube.yIdx].hasTraverse = true
				end
				if self.lightCubeVector[nextCube.xIdx.."_"..nextCube.yIdx] then
					self.lightCubeVector[nextCube.xIdx.."_"..nextCube.yIdx].hasTraverse = false
				end
			end
		end
	end

	-- 刷新其他的光格子
	-- 若对应光格子下有移动块格子 则根据其是否已被遍历及是否有光通过特效 
	-- 决定是否隐藏其光通过特效
	for k,v in pairs(self.lightCubeVector) do
		if (not v.hasTraverse) 
			or self.moveCubeVector[k] 
		then
			v:updateLightRotation()
			v:updateLightRotation2()
			if self.moveCubeVector[k] then
				if self.moveCubeVector[k].lightenAni and not self.moveCubeVector[k].hasTraverse then
					self.moveCubeVector[k]:setAniLighten( false )
				end
				self.moveCubeVector[k].hasTraverse = false
			end
		end
		v.hasTraverse = false
	end
	-- 刷新光接收器状态
	for k,v in pairs(self.receiverCubeVector) do
		v:onOneRouteThough(v.isSucceed)
	end
	if senderNum == hasSucceedNum then
		-- WindowControler:showTips("机关解锁成功,弹出奖励界面")
		-- self.ui.panel_tg:zorder(100)
		-- self.ui.panel_tg:visible(true)
		local function delayCallFunc( ... )
			EventControler:dispatchEvent(EliteEvent.ELITE_OPEN_BOX_CONDITION_MET,{Id = self.boxId} )
			self.ui:startHide()
			self:deleteMe()
		end
		self.ui:delayCall(delayCallFunc,1)
	end
end

-- 根据格子Idx,Idy获取在地图中的摆放坐标
function EliteGearMapControler:getGridPos( Idx,Idy )
	local x,y = tonumber(Idx),tonumber(Idy)
	if not self.cubeWidth then 
		-- self.cubeWidth  = 100
			self.cubeWidth = (GameVars.width)/GameVars.gameResWidth * 100
	end 
	if not self.cubeHeight then
		-- self.cubeHeight = 88
	self.cubeHeight = (GameVars.height)/GameVars.gameResHeight * 86

	end

	x = self.initGridPosX - x*self.cubeWidth
	y = self.initGridPosY - y*self.cubeHeight
	if not self.allGridPos[Idx.."_"..Idy] then
		self.allGridPos[Idx.."_"..Idy] = {x,y}
	end
	return x,y
end

-- 根据当前idx,idy 和光运动方向获取下一个光 cube
function EliteGearMapControler:getNextCubeByDirection( Idx,Idy,_direction )
	local xIdx = Idx
	local xIdy = Idy
	if _direction == FuncEliteMap.ROTATION_ANGLE.NORTH then
		xIdy = xIdy - 1
		if xIdy > self.maxNumY then
			return false
		end
	elseif _direction ==  FuncEliteMap.ROTATION_ANGLE.SOUTH then
		xIdy = xIdy + 1
		if xIdy < 1 then
			return false
		end
	elseif _direction ==  FuncEliteMap.ROTATION_ANGLE.EAST then
		xIdx = xIdx - 1
		if xIdx < 1 then
			return false
		end
	elseif _direction == FuncEliteMap.ROTATION_ANGLE.WEST then
		xIdx = xIdx + 1
		if xIdx > self.maxNumX then
			return false
		end
	end

	-- echo("___寻找下一个cube Idx,Idy,_direction,xIdx,xIdy ______",Idx,Idy,_direction,xIdx,xIdy)
	if self.senderCubeVector[xIdx.."_"..xIdy] then
		-- echo("____ 遇到发射器 _______")
		return self.senderCubeVector[xIdx.."_"..xIdy]

	elseif self.receiverCubeVector[xIdx.."_"..xIdy] then
		-- echo("____ 遇到接受器 _______")
		return self.receiverCubeVector[xIdx.."_"..xIdy]

	elseif self.borderCubeVector[xIdx.."_"..xIdy] then
		-- echo("____ 遇到边界块 _______")
		return self.borderCubeVector[xIdx.."_"..xIdy]

	elseif self.moveCubeVector[xIdx.."_"..xIdy] then
		-- echo("____ 遇到移动块 _______")
		return self.moveCubeVector[xIdx.."_"..xIdy]

	elseif self.lightCubeVector[xIdx.."_"..xIdy] then
		-- echo("____ 遇到 透光 _______")
		return self.lightCubeVector[xIdx.."_"..xIdy]
	end
end


function EliteGearMapControler:registerEvent()
	-- cube移动
    EventControler:addEventListener(EliteEvent.ELITE_GEAR_CUBE_MOVE_BEGIN,self.onOneCubeMoveBegin,self)
    EventControler:addEventListener(EliteEvent.ELITE_GEAR_CUBE_MOVING,self.onOneCubeMoving,self)
    EventControler:addEventListener(EliteEvent.ELITE_GEAR_CUBE_MOVE_END,self.onOneCubeMoveEnd,self)
end

function EliteGearMapControler:onOneCubeMoveBegin( event )
	local data = event.params 
	dump(data, "一个cube 移动开始 == ")
    self.xIdxOld,self.yIdxOld = data.Idx,data.Idy
    self.lastPosX,self.lastPosY = self:getGridPos(self.xIdxOld,self.yIdxOld)
end

function EliteGearMapControler:onOneCubeMoving( event )
	local data = event.params 
	self:handleOneCubeMoving(data)
end

-- 判断Idx,Idy 的当前移动位置可不可达
function EliteGearMapControler:checkIfCanMove( Idx,Idy,curPosX,curPosY )
	local direction1 = curPosX - self.lastPosX
	local direction2 = curPosY - self.lastPosY
	local isCanMoveX,isCanMoveY = false,false
	local nextIdx,nextIdy = Idx,Idy

	if direction1 > 0 then 
		direction1 = FuncEliteMap.ROTATION_ANGLE.EAST
	else
		direction1 = FuncEliteMap.ROTATION_ANGLE.WEST
	end

	local nextCube1 = self:getNextCubeByDirection(Idx,Idy,direction1)
	if nextCube1 and nextCube1.cubeType and 
		(nextCube1.cubeType == FuncEliteMap.ORGAN_MAP_GRID_TYPE.RECEIVER 
		or nextCube1.cubeType == FuncEliteMap.ORGAN_MAP_GRID_TYPE.SENDER
		or nextCube1.cubeType == FuncEliteMap.ORGAN_MAP_GRID_TYPE.CUBE_SOLID
		or nextCube1.cubeType == FuncEliteMap.ORGAN_MAP_GRID_TYPE.CUBE_WS
		or nextCube1.cubeType == FuncEliteMap.ORGAN_MAP_GRID_TYPE.CUBE_ES
		or nextCube1.cubeType == FuncEliteMap.ORGAN_MAP_GRID_TYPE.CUBE_EN
		or nextCube1.cubeType == FuncEliteMap.ORGAN_MAP_GRID_TYPE.CUBE_WN
		or nextCube1.cubeType == FuncEliteMap.ORGAN_MAP_GRID_TYPE.CUBE_BORDER)
	then
		-- echo("_____ Idx,Idy x轴方向 direction1 不可移动 !!!_________",Idx,Idy,direction1)
	else
		isCanMoveX = true
		if nextCube1 and nextCube1.xIdx then
			nextIdx = nextCube1.xIdx
		end
		-- echo("_____ x轴方向可移动_nextIdx________",nextIdx)
	end

	if direction2 > 0 then 
		direction2 = FuncEliteMap.ROTATION_ANGLE.NORTH
	else
		direction2 = FuncEliteMap.ROTATION_ANGLE.SOUTH
	end
	local nextCube2 = self:getNextCubeByDirection(Idx,Idy,direction2)
	if nextCube2 and nextCube2.cubeType and 
		(nextCube2.cubeType == FuncEliteMap.ORGAN_MAP_GRID_TYPE.RECEIVER 
		or nextCube2.cubeType == FuncEliteMap.ORGAN_MAP_GRID_TYPE.SENDER
		or nextCube2.cubeType == FuncEliteMap.ORGAN_MAP_GRID_TYPE.CUBE_SOLID
		or nextCube2.cubeType == FuncEliteMap.ORGAN_MAP_GRID_TYPE.CUBE_WS
		or nextCube2.cubeType == FuncEliteMap.ORGAN_MAP_GRID_TYPE.CUBE_ES
		or nextCube2.cubeType == FuncEliteMap.ORGAN_MAP_GRID_TYPE.CUBE_EN
		or nextCube2.cubeType == FuncEliteMap.ORGAN_MAP_GRID_TYPE.CUBE_WN
		or nextCube2.cubeType == FuncEliteMap.ORGAN_MAP_GRID_TYPE.CUBE_BORDER)
	then
		-- echo("_____Idx,Idy y轴方向 direction2 不可移动 !!!_________",Idx,Idy,direction2)
	else
		isCanMoveY = true
		if nextCube2 and nextCube2.yIdx then
			nextIdy = nextCube2.yIdx
		end 
		-- echo("_____ y轴方向可移动___nextIdy______",nextIdy)
	end

	-- echo("_____ 东西方向,南北方向,",FuncEliteMap.ROTATION_NAME[tostring(direction1)],FuncEliteMap.ROTATION_NAME[tostring(direction2)])
	-- echo("_____ isCanMoveX,isCanMoveY ________",isCanMoveX,isCanMoveY)

	return isCanMoveX,isCanMoveY,nextIdx,nextIdy
end

-- 根据坐标判断改点落在哪个格子
function EliteGearMapControler:getGridIdxyByPos( curPosX,curPosY )
	local Idx,Idy = 1,1
	-- echo("_____根据坐标判断改点落在哪个格子 传入的 x,y____",curPosX,curPosY)
	for k,pos in pairs(self.allGridPos) do
		local xx,yy = pos[1],pos[2]
		if (curPosX > (xx - self.cubeWidth/2 + 3)) and (curPosX < (xx + self.cubeWidth/2 +3)) 
			and (curPosY > (yy - self.cubeHeight/2 + 3)) and (curPosY < (yy + self.cubeHeight/2 +3)) 
		then
			-- echo("_____坐标x,y对应格子id=__________",k)
			local kArr = string.split(k,"_")
			Idx,Idy = kArr[1],kArr[2]
			break
		end
	end
	return Idx,Idy
end


function EliteGearMapControler:onOneCubeMoveEnd( event )
	local data = event.params 
	self:handleOneCubeMoving(data)
end

function EliteGearMapControler:handleOneCubeMoving( _data )
	local data = _data
	local transFormPos = self.ui:convertToNodeSpaceAR(cc.p(data.posX,data.posY))
	data.posX,data.posY = transFormPos.x,transFormPos.y
	
	-- 检测能不能移动
	self.lastIdx,self.lastIdy = self:getGridIdxyByPos(self.lastPosX,self.lastPosY)
	local isCanMoveX,isCanMoveY,Idx,Idy = self:checkIfCanMove(self.lastIdx,self.lastIdy,data.posX,data.posY)

	local oldx,oldy = self.lastIdx,self.lastIdy
    if isCanMoveX and (math.abs(data.posX - self.lastPosX) > self.cubeWidth/2) then
    	self.lastIdx = Idx
    end
    if isCanMoveY and (math.abs(data.posY - self.lastPosY) > self.cubeHeight/2) then
    	self.lastIdy = Idy
    end

    -- 本位 不需移动
    if (oldx == self.lastIdx) and (oldy == self.lastIdy) then
    	return 
    end

    -- 限定只能有一个方向移动,防止侧方移动的bug
    if (oldx ~= self.lastIdx) and (oldy ~= self.lastIdy) then
    	if (math.abs(data.posX - self.lastPosX) > math.abs(data.posY - self.lastPosY)) then
    		self.lastIdy = oldy
    	else
			self.lastIdx = oldx
    	end
    end

    -- 移动位置并更新移动对象的model数组
	self.lastPosX,self.lastPosY = self:getGridPos(self.lastIdx,self.lastIdy)
	local nextIdx,nextIdy = self.lastIdx,self.lastIdy
    local tempModel = self.moveCubeVector[data.Idx.."_"..data.Idy]
    self.moveCubeVector[nextIdx.."_"..nextIdy] = tempModel
    -- if tempModel and tolua.isnull(tempModel) then
    	tempModel:updateGridInfo( nextIdx,nextIdy)
    -- end
    -- if tempModel and tempModel.myView and tolua.isnull(tempModel.myView) then
    	tempModel.myView:pos(self.lastPosX,self.lastPosY)
    -- end

    self.moveCubeVector[data.Idx.."_"..data.Idy] = nil
    self:updateLightRouteView()
end


function EliteGearMapControler:deleteMe()
	EventControler:clearOneObjEvent(self)
	
	self:deleteGrids()
	
	if self.gearMap then
		self.gearMap:deleteMe()
	end

	if self.pathControler then
		self.pathControler:deleteMe()
	end

	self.ui:unscheduleUpdate()
end

function EliteGearMapControler:deleteGrids()
	for k,v in pairs(self.gridArr) do
		v:deleteMe()
	end

	self.gridArr = {}
end


function EliteGearMapControler:initMap()
	self.gearMap = EliteGearMapClazz.new(self.gearMapData,self)
	self.gearMap:initMap()
	self.ui:scheduleUpdateWithPriorityLua(c_func(self.updateFrame,self),0)
	-- 寻路管理器
	self.pathControler = EliteGearPathControlerClazz.new(self)
end

function EliteGearMapControler:getGearMap()
	return self.gearMap
end

-- 每帧刷新方法
function EliteGearMapControler:updateFrame(dt)
	if self.UPDATE_FRAME and self.isMovingCube then
		self:updateLightRoute()
	end
end


return EliteGearMapControler
