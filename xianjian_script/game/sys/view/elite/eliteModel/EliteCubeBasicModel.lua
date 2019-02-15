--
--Author:      zhuguangyuan
--DateTime:    2018-02-08 11:16:38
--Description: 机关格子 格子模型基类
--

local EliteBasicModel = require("game.sys.view.elite.eliteModel.EliteBasicModel")
EliteCubeBasicModel = class("EliteCubeBasicModel",EliteBasicModel)

function EliteCubeBasicModel:ctor( controler ,xIdx,yIdx,gridInfo)
	EliteCubeBasicModel.super.ctor(self,controler)
	self.gridInfo = gridInfo

	self.xIdx = xIdx
	self.yIdx = yIdx
	self.cubeType = self.gridInfo.cubeType

	-- 是否遍历,用于光寻路标记
	self.hasTraverse = false

	-- 光路通透方向
	self.rotationAngle1 = nil
    self.rotationAngle2 = nil

	-- 格子ID，后端设定的规则
	self.gid = xIdx .. "_" .. yIdx

	-- 是否打开调试开关(展示格子id及坐标)
	self.DEBUG = false
end

-- 更新格子数据
function EliteCubeBasicModel:updateGridInfo( xIdx,yIdx,gridInfo )
	if xIdx then
		self.xIdx = xIdx
	end
	if yIdx then
		self.yIdx = yIdx
	end
	if gridInfo and gridInfo.cubeType then
		self.cubeType = gridInfo.cubeType
	end
end
function EliteCubeBasicModel:registerEvent()
	EliteCubeBasicModel.super.registerEvent(self)
end

-- 创建GridModel时，先设置view信息
function EliteCubeBasicModel:setViewInfo(ctn,xpos,ypos,zpos)
	self.viewCtn = ctn
	if xpos and ypos and zpos then
		self:setPos(xpos,ypos,zpos)
	end

	self:showDebugInfo()
end

-- @TEST 显示debug信息
function EliteCubeBasicModel:showDebugInfo()
	if self.DEBUG then
	echo("________ 展示格子坐标信息 ____________")
		local xIdx = self.xIdx
		local yIdx = self.yIdx

		local ttf = display.newTTFLabel({text = "("..xIdx..","..yIdx..")\n =("..self.pos.x..","..self.pos.y..")", size = 18, color = cc.c3b(255,0,0)})
		ttf:anchor(0.5,0.5)
		ttf:pos(self.pos.x,self.pos.y)
		ttf:zorder(100)

		self.ttfView = ttf
		self.viewCtn:addChild(ttf,100)
	end
end

-- 格子模型对应的数据对象
function EliteCubeBasicModel:setGridInfo(gridInfo)
	self.gridInfo = gridInfo
end

function EliteCubeBasicModel:getGridInfo()
	return self.gridInfo
end

-- 初始化格子视图
function EliteCubeBasicModel:initView(ctn,_view,xpos,ypos,zpos)
	local parentCtn = ctn

	-- 如果是移动块 则放到游戏中间层
	-- 相对光路 靠前
	local testClickZone = false
	local upperLevel = false
	if not parentCtn then
		if self.cubeType == FuncEliteMap.ORGAN_MAP_GRID_TYPE.CUBE_WS
			or self.cubeType == FuncEliteMap.ORGAN_MAP_GRID_TYPE.CUBE_ES
			or self.cubeType == FuncEliteMap.ORGAN_MAP_GRID_TYPE.CUBE_EN
			or self.cubeType == FuncEliteMap.ORGAN_MAP_GRID_TYPE.CUBE_WN
			or self.cubeType == FuncEliteMap.ORGAN_MAP_GRID_TYPE.CUBE_SOLID
		then
			parentCtn = self.controler.gearMap.middleLayer
			testClickZone = true
			upperLevel = true
		else
			parentCtn = self.controler.gearMap.middleLayer
		end
	end

	-- 如果没有传入坐标则初始化坐标
	local x,y,z = xpos,ypos,zpos
	if (not x) and (not y) and (not z) then
		x,y = self.controler:getGridPos(self.xIdx, self.yIdx)
		z = 0
	end

	local view = _view --self.controler:getGridView(self.cubeType)
	if not view then

	end

	local viewSize = cc.size(self.controler.cubeWidth,self.controler.cubeHeight)
	EliteCubeBasicModel.super.initView(self,parentCtn,view,x,y,z,viewSize)
	self:showDebugInfo()

	if upperLevel then
		self:setZOrder(5)
	end

	-- 点击区域测试代码
	if self.DEBUG then
		local node1 = display.newNode()	
		local color = cc.c4b(0,255,0,120)
		local layer = cc.LayerColor:create(color)
		node1:addChild(layer)
		node1:setTouchEnabled(false)
		node1:setTouchSwallowEnabled(false)

		node1:addto(parentCtn,100):size(self.controler.cubeWidth-10,self.controler.cubeHeight-10)
		node1:anchor(0.5,0.5)
		node1:pos(x,y)
		-- node1:pos(0,0)
		layer:setContentSize(node1:getContentSize() )

		-- 点击区域测试代码
		if testClickZone then
			local node = display.newNode()	
			local color = cc.c4b(0,0,255,255)
			local layer = cc.LayerColor:create(color)
			node:addChild(layer)
			node:setTouchEnabled(false)
			node:setTouchSwallowEnabled(false)

			node:addto(parentCtn,100):size(self.controler.cubeWidth-10,self.controler.cubeHeight-10)
			node:anchor(0.5,0.5)
			node:pos(x,y)
			-- node:pos(0,0)
			layer:setContentSize(node:getContentSize() )
		end
	end
end

-- 格子ID，可以根据ID快速查找指定格子
function EliteCubeBasicModel:getId()
	return self.gid
end

function EliteCubeBasicModel:deleteMe()
	if self.eventModel then
		self.eventModel:deleteMe()
	end

	EliteCubeBasicModel.super.deleteMe(self)
end

return EliteCubeBasicModel
