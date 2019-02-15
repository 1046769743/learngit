--
--Author:      zhuguangyuan
--DateTime:    2018-01-31 17:43:34
--Description: 精英场景 机关界面
--

local EliteGearMapControlerClazz = require("game.sys.view.elite.eliteGearMap.EliteGearMapControler")

local EliteGearView = class("EliteGearView", UIBase)

function EliteGearView:ctor(winName,boxId,tableName)
    EliteGearView.super.ctor(self, winName)
    self.boxId = boxId
    self.tableName = tableName
    local organIndex = string.split(tableName,"EliteOrgan")[2]
    echo("_______ boxId,tableName,organIndex ________",boxId,tableName,organIndex)
    self.organIndex = organIndex
    self.tableData = FuncEliteMap.getOneEliteOrganMapData(organIndex)
end

function EliteGearView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function EliteGearView:registerEvent()
	EliteGearView.super.registerEvent(self);
	self.panel_bg.btn_close:setTap(c_func(self.startHide,self))
end

function EliteGearView:initData()
	self.maxNumX = table.length(self.tableData)
	self.maxNumY = table.length(self.tableData["1"])
end

function EliteGearView:initView()
	self.panel_tg:visible(false)
	self.mc_block:visible(false)
	self.panel_route_1_1:visible(false)

	self:initMapControl(self.organIndex)
end


-- 初始化地图控制器 及 地图
function EliteGearView:initMapControl( _organIndex )
	self.gearMapControler = EliteGearMapControlerClazz.new(self,self.boxId,_organIndex)
	self.gearMap = self.gearMapControler:getGearMap()
	self._root:addChild(self.gearMap,10) 
	self.gearMapControler:initAllCubeView()
	self.gearMapControler:updateLightRouteView()
end

function EliteGearView:initMap()
	-- self:initLayers()

	self.direction = {
		north = 0,
		south = 180,
		east = 90,
		west = 270,
		none = false,
	}
	self.cubeType = {
		border = 0,
		cube = 1,
		light = 2,
	}
	-- 初始化

	--记录格子状态的 vector
	self.rectVector = {
	}  

	--光路view vector
	self.lightCubeVector = {} 
	self.moveCubeVector = {} 
	self.senderCubeVector = {} 
	self.receiverCubeVector = {} 

	self.cubeVectorView = {}  --方块view vector

	self.senderVector = {} -- 发射器状态
	self.cubeVectorView = {}  --方块view vector
end


function EliteGearView:initLayers()
end

function EliteGearView:getDirectionByCubeType( _cubeType,status )
	local cubeType = tonumber(_cubeType)
	local d1,d2 
	if cubeType == FuncEliteMap.ORGAN_MAP_GRID_TYPE.EMPTY then
	elseif cubeType == FuncEliteMap.ORGAN_MAP_GRID_TYPE.SENDER then
	elseif cubeType == FuncEliteMap.ORGAN_MAP_GRID_TYPE.RECEIVER then
	elseif cubeType == FuncEliteMap.ORGAN_MAP_GRID_TYPE.CUBE_SOLID then
	elseif cubeType == FuncEliteMap.ORGAN_MAP_GRID_TYPE.CUBE_WS then
	elseif cubeType == FuncEliteMap.ORGAN_MAP_GRID_TYPE.CUBE_ES then
	elseif cubeType == FuncEliteMap.ORGAN_MAP_GRID_TYPE.CUBE_EN then
	elseif cubeType == FuncEliteMap.ORGAN_MAP_GRID_TYPE.CUBE_WN then
	elseif cubeType == FuncEliteMap.ORGAN_MAP_GRID_TYPE.CUBE_BORDER then
	end
end
function EliteGearView:getSenderDirection( x,y )
	local direction = ""
	if tonumber(x) == 1 then
		if tonumber(y) > 1 and tonumber(y) < self.maxNumY then
			direction = "West"
		end
	elseif tonumber(x) == self.maxNumX then
		if tonumber(y) > 1 and tonumber(y) < self.maxNumY then
			direction = "East"
		end
	elseif tonumber(y) == 1 then
		if tonumber(x) > 1 and tonumber(x) < self.maxNumX then
			direction = "South"
		end
	elseif tonumber(y) == self.maxNumY then
		if tonumber(x) > 1 and tonumber(x) < self.maxNumX then
			direction = "North"
		end
	end
	return "wrongDirection"
end


function EliteGearView:updateAllRect( _itemDataArr )
	-- 遍历发射光行走路线
	for _gridId,v in pairs(self.senderVector) do
	 	local x,y = self.getGridXY(_gridId)
	 	local stop = false
	 	local findReceive = false
	 	if v.direction == "North" then
	 		local nextX = tonumber(x)
	 		local nextY = tonumber(y) + 1
			while (not stop) and (not findReceive) do
				local tempBlock = self.rectVector[nextX][nextY]
				if tempBlock.status == FuncEliteMap.ORGAN_MAP_GRID_TYPE.EMPTY then
					self.rectVectorView[nextX.."_"..nextY]:showFrame(3)
					local currentView = self.rectVectorView[nextX.."_"..nextY]:getCurFrameView()
					currentView.panel_light1:visible(true)
					currentView.panel_light2:visible(true)
					currentView.panel_light1:setRotation(180)
					currentView.panel_light2:setRotation(0)
					nextY = nextY + 1
				elseif tempBlock.status == FuncEliteMap.ORGAN_MAP_GRID_TYPE.EMPTY then
				end
				if tempBlock.status == FuncEliteMap.ORGAN_MAP_GRID_TYPE.EMPTY then
					currentView.panel_light1:visible(false)
					currentView.panel_light2:visible(false)
					currentView.panel_bg1:visible(false)
				elseif tempBlock.status == FuncEliteMap.ORGAN_MAP_GRID_TYPE.CUBE_SOLID then
					currentView.panel_light1:visible(false)
					currentView.panel_light2:visible(false)
					currentView.panel_bg1:visible(true)
				else
					currentView.panel_light1:visible(true)
					currentView.panel_light2:visible(true)
					currentView.panel_bg1:visible(true)
					if tempBlock.status == FuncEliteMap.ORGAN_MAP_GRID_TYPE.CUBE_WS then
						currentView.panel_light1:setRotation(270)
						currentView.panel_light2:setRotation(180)
					elseif tempBlock.status == FuncEliteMap.ORGAN_MAP_GRID_TYPE.CUBE_ES then
						currentView.panel_light1:setRotation(90)
						currentView.panel_light2:setRotation(180)
					elseif tempBlock.status == FuncEliteMap.ORGAN_MAP_GRID_TYPE.CUBE_EN then
						currentView.panel_light1:setRotation(90)
						currentView.panel_light2:setRotation(0)
					elseif tempBlock.status == FuncEliteMap.ORGAN_MAP_GRID_TYPE.CUBE_WN then
						currentView.panel_light1:setRotation(270)
						currentView.panel_light2:setRotation(0)
					end
				end
			end
	 	elseif v.direction == "South" then
	 	elseif v.direction == "West" then
	 	elseif v.direction == "East" then
	 	end
	end 
end

function EliteGearView:getGridXY( _gridId )
	local gridId = tostring(_gridId)
	local posArr = string.split(gridId,"_")
	return posArr[1],posArr[2]
end


function EliteGearView:initViewAlign()
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_bg.btn_close, UIAlignTypes.RightTop)
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_bg.txt_1, UIAlignTypes.MiddleBottom)
end

function EliteGearView:updateUI()
	-- TODO
end

function EliteGearView:getGridPos( Idx,Idy )
	if not self.gridSizeX then
		local size = self.mc_block:getContainerBox()
		dump(size, "desciption")
		self.gridSizeX = size.width --self.mc_block:getContentSize()
		self.gridSizeY = size.height

		self.initGridPosX = GameVars.width*19/20
		self.initGridPosY = 0--GameVars.height
	end

	-- local posArr = string.split(_gridId,"_")
	local x,y = tonumber(Idx),tonumber(Idy)

	x = self.initGridPosX - x*self.gridSizeX
	y = self.initGridPosY - y*self.gridSizeY
	echo("_____ 计算出来的x,y_________",x,y)
	return x,y
end

function EliteGearView:deleteMe()
	EliteGearView.super.deleteMe(self);
	if self.gearMapControler then
		self.gearMapControler:deleteMe()
	end
end

return EliteGearView;
