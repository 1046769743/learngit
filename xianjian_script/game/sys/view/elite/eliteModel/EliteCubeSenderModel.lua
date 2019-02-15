--
--Author:      zhuguangyuan
--DateTime:    2018-02-08 11:19:05
--Description: 机关格子 发射器模型
--


local EliteCubeBasicModel = require("game.sys.view.elite.eliteModel.EliteCubeBasicModel")
EliteCubeSenderModel = class("EliteCubeSenderModel",EliteCubeBasicModel)

function EliteCubeSenderModel:ctor( controler ,xIdx,yIdx,gridInfo)
	EliteCubeSenderModel.super.ctor(self,controler ,xIdx,yIdx,gridInfo)
	self.gridInfo = gridInfo
	
	self.xIdx = xIdx
	self.yIdx = yIdx
	self.cubeType = FuncEliteMap.ORGAN_MAP_GRID_TYPE.SENDER
	
	self.isCanMove = false
	
	-- 初始化发射器的朝向
	if tonumber(self.xIdx) == 1 then
		self.rotationAngle1 = FuncEliteMap.ROTATION_ANGLE.WEST
	elseif tonumber(self.xIdx) == self.controler.maxNumX then
		self.rotationAngle1 = FuncEliteMap.ROTATION_ANGLE.EAST
	elseif tonumber(self.yIdx) == 1 then
		self.rotationAngle1 = FuncEliteMap.ROTATION_ANGLE.SOUTH
	elseif tonumber(self.yIdx) == self.controler.maxNumY then
		self.rotationAngle1 = FuncEliteMap.ROTATION_ANGLE.NORTH
	end	
end

function EliteCubeSenderModel:registerEvent()
	EliteCubeSenderModel.super.registerEvent(self)
end

-- 创建GridModel时，先设置view信息
function EliteCubeSenderModel:setViewInfo(ctn,xpos,ypos,zpos)
	self.viewCtn = ctn
	if xpos and ypos and zpos then
		self:setPos(xpos,ypos,zpos)
	end

	self:showDebugInfo()
end

-- @TEST 显示debug信息
function EliteCubeSenderModel:showDebugInfo()
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

function EliteCubeSenderModel:initView(ctn,_view,xpos,ypos,zpos)
	EliteCubeSenderModel.super.initView(self,ctn,_view,xpos,ypos,zpos,size)
end


return EliteCubeSenderModel
