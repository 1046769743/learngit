--
--Author:      zhuguangyuan
--DateTime:    2018-02-08 11:18:15
--Description: 机关格子 移动格子模型
--

local EliteCubeBasicModel = require("game.sys.view.elite.eliteModel.EliteCubeBasicModel")
EliteCubeMoveModel = class("EliteCubeMoveModel",EliteCubeBasicModel)

function EliteCubeMoveModel:ctor( controler ,xIdx,yIdx,gridInfo)
	EliteCubeMoveModel.super.ctor(self,controler ,xIdx,yIdx,gridInfo)
	self.gridInfo = gridInfo

	self.xIdx = xIdx
	self.yIdx = yIdx
	self.isCanMove = true

    self.cubeWidth = self.controler.cubeWidth
    self.cubeHeight = self.controler.cubeHeight
    self.maxNumX = self.controler.maxNumX
    self.maxNumY = self.controler.maxNumY

	-- 初始化本cube的透光朝向
	-- 注意
	local cubeType = tonumber(self.cubeType)
	if cubeType == FuncEliteMap.ORGAN_MAP_GRID_TYPE.CUBE_WS then
		self.rotationAngle1 = FuncEliteMap.ROTATION_ANGLE.WEST
		self.rotationAngle2 = FuncEliteMap.ROTATION_ANGLE.SOUTH
	elseif cubeType == FuncEliteMap.ORGAN_MAP_GRID_TYPE.CUBE_ES then
		self.rotationAngle1 = FuncEliteMap.ROTATION_ANGLE.EAST
		self.rotationAngle2 = FuncEliteMap.ROTATION_ANGLE.SOUTH
	elseif cubeType == FuncEliteMap.ORGAN_MAP_GRID_TYPE.CUBE_EN then
		self.rotationAngle1 = FuncEliteMap.ROTATION_ANGLE.EAST
		self.rotationAngle2 = FuncEliteMap.ROTATION_ANGLE.NORTH
	elseif cubeType == FuncEliteMap.ORGAN_MAP_GRID_TYPE.CUBE_WN then
		self.rotationAngle1 = FuncEliteMap.ROTATION_ANGLE.WEST
		self.rotationAngle2 = FuncEliteMap.ROTATION_ANGLE.NORTH
	elseif cubeType == FuncEliteMap.ORGAN_MAP_GRID_TYPE.CUBE_SOLID then
		self.rotationAngle1 = FuncEliteMap.ROTATION_ANGLE.NONE
		self.rotationAngle2 = FuncEliteMap.ROTATION_ANGLE.NONE
	end
end

function EliteCubeMoveModel:registerEvent()
	EliteCubeMoveModel.super.registerEvent(self)
end

-- 创建GridModel时，先设置view信息
function EliteCubeMoveModel:setViewInfo(ctn,xpos,ypos,zpos)
	self.viewCtn = ctn
	if xpos and ypos and zpos then
		self:setPos(xpos,ypos,zpos)
	end

	self:showDebugInfo()
end

-- 初始化格子视图
function EliteCubeMoveModel:initView(ctn,_view,xpos,ypos,zpos)
	EliteCubeMoveModel.super.initView(self,ctn,_view,xpos,ypos,zpos,size)
		
	-- 展示光路指针
	self.myView:showFrame(3)
	self.currentView = self.myView:getCurFrameView()
	if self.rotationAngle1 == FuncEliteMap.ROTATION_ANGLE.NONE 
		and self.rotationAngle2 == FuncEliteMap.ROTATION_ANGLE.NONE
	then
		-- self.currentView.panel_light1:visible(false)
		-- self.currentView.panel_light2:visible(false)
		self.myView:showFrame(4)
	else
		self.currentView.panel_light1:visible(false)
		self.currentView.panel_light2:visible(false)
		self.currentView.panel_light1:setRotation(self.rotationAngle1)
		self.currentView.panel_light2:setRotation(self.rotationAngle2)

		self:createLightAni()
	end

	self.myView:setTouchEnabled(true)
	self.myView:setTouchedFunc(
		c_func(self.moveNodeTouchEnd, self), nil, nil,
     	c_func(self.moveNodeTouchStart, self),
     	c_func(self.moveNodeTouchMove, self),nil,
     	c_func(self.moveNodeTouchEnd, self) 
     )
end

-- 创建通光时的特效
function EliteCubeMoveModel:createLightAni()
	-- 东南方向的光线
	if (self.rotationAngle1 == FuncEliteMap.ROTATION_ANGLE.SOUTH 
		or self.rotationAngle2 == FuncEliteMap.ROTATION_ANGLE.SOUTH)  
		and (self.rotationAngle1 == FuncEliteMap.ROTATION_ANGLE.EAST 
		or self.rotationAngle2 == FuncEliteMap.ROTATION_ANGLE.EAST) 
		then
		self.myView.currentView.panel_bg1:setRotation(0)
		self.lightenAni = self.controler.ui:createUIArmature("UI_jiguanbaoxiang","UI_jiguanbaoxiang_lianjie2",self.myView,true,GameVars.emptyFunc)

	-- 东北方向
	elseif (self.rotationAngle1 == FuncEliteMap.ROTATION_ANGLE.NORTH 
		or self.rotationAngle2 == FuncEliteMap.ROTATION_ANGLE.NORTH)  
		and (self.rotationAngle1 == FuncEliteMap.ROTATION_ANGLE.EAST 
		or self.rotationAngle2 == FuncEliteMap.ROTATION_ANGLE.EAST) 
		then
		self.myView.currentView.panel_bg1:setRotation(270)
		self.lightenAni = self.controler.ui:createUIArmature("UI_jiguanbaoxiang","UI_jiguanbaoxiang_lianjie1",self.myView,true,GameVars.emptyFunc)
	-- 西北方向
	elseif (self.rotationAngle1 == FuncEliteMap.ROTATION_ANGLE.NORTH 
		or self.rotationAngle2 == FuncEliteMap.ROTATION_ANGLE.NORTH)  
		and (self.rotationAngle1 == FuncEliteMap.ROTATION_ANGLE.WEST 
		or self.rotationAngle2 == FuncEliteMap.ROTATION_ANGLE.WEST) 
		then
		self.myView.currentView.panel_bg1:setRotation(180)
		self.lightenAni = self.controler.ui:createUIArmature("UI_jiguanbaoxiang","UI_jiguanbaoxiang_lianjie4",self.myView,true,GameVars.emptyFunc)
	-- 西南方向
	elseif (self.rotationAngle1 == FuncEliteMap.ROTATION_ANGLE.SOUTH 
		or self.rotationAngle2 == FuncEliteMap.ROTATION_ANGLE.SOUTH)  
		and (self.rotationAngle1 == FuncEliteMap.ROTATION_ANGLE.WEST 
		or self.rotationAngle2 == FuncEliteMap.ROTATION_ANGLE.WEST) 
		then
		self.myView.currentView.panel_bg1:setRotation(90)
		self.lightenAni = self.controler.ui:createUIArmature("UI_jiguanbaoxiang","UI_jiguanbaoxiang_lianjie3",self.myView,true,GameVars.emptyFunc)
	end
	self:setAniLighten( false )
end

-- 设置特效点亮与否
function EliteCubeMoveModel:setAniLighten( isVisible )
	self.lightenAni:visible(isVisible)
	self.isHasLightPass = isVisible
end

function EliteCubeMoveModel:moveNodeTouchEnd(event)
    local xx = event.x 
    local yy = event.y 

    local params = {
		Idx = self.xIdx,
		Idy = self.yIdx,
		posX = xx,
		posY = yy,
	}
	EventControler:dispatchEvent(EliteEvent.ELITE_GEAR_CUBE_MOVE_END,params)
end

function EliteCubeMoveModel:moveNodeTouchStart(event)
    local xx = event.x 
    local yy = event.y 

    local params = {
		Idx = self.xIdx,
		Idy = self.yIdx,
		posX = xx,
		posY = yy,
	}
	EventControler:dispatchEvent(EliteEvent.ELITE_GEAR_CUBE_MOVE_BEGIN,params)
end
function EliteCubeMoveModel:moveNodeTouchMove(event)
    local xx = event.x 
    local yy = event.y 
	local params = {
		Idx = self.xIdx,
		Idy = self.yIdx,
		posX = xx,
		posY = yy,
    }
	EventControler:dispatchEvent(EliteEvent.ELITE_GEAR_CUBE_MOVING,params)
end

return EliteCubeMoveModel
