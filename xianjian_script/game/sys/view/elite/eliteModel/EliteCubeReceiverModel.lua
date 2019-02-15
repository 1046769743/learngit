--
--Author:      zhuguangyuan
--DateTime:    2018-02-08 11:18:39
--Description: 机关格子 接收器模型
--


local EliteCubeBasicModel = require("game.sys.view.elite.eliteModel.EliteCubeBasicModel")
EliteCubeReceiverModel = class("EliteCubeReceiverModel",EliteCubeBasicModel)

function EliteCubeReceiverModel:ctor( controler ,xIdx,yIdx,gridInfo)
	EliteCubeReceiverModel.super.ctor(self,controler ,xIdx,yIdx,gridInfo)
	self.gridInfo = gridInfo

	self.xIdx = xIdx
	self.yIdx = yIdx
	self.cubeType = FuncEliteMap.ORGAN_MAP_GRID_TYPE.RECEIVER
	self.isCanMove = false

	-- 是否有光线到达
	self.isSucceed = false
end

function EliteCubeReceiverModel:registerEvent()
	EliteCubeReceiverModel.super.registerEvent(self)
end

function EliteCubeReceiverModel:getEventModel()
	return self.eventModel
end

-- 创建GridModel时，先设置view信息
function EliteCubeReceiverModel:setViewInfo(ctn,xpos,ypos,zpos)
	self.viewCtn = ctn
	if xpos and ypos and zpos then
		self:setPos(xpos,ypos,zpos)
	end

	self:showDebugInfo()
end

-- 初始化格子视图
function EliteCubeReceiverModel:initView(ctn,_view,xpos,ypos,zpos)
	EliteCubeReceiverModel.super.initView(self,ctn,_view,xpos,ypos,zpos,size)
	self.myView:showFrame(2)
	self.currentView = self.myView:getCurFrameView()
	self.currentView.panel_dui:visible(false)
end

-- function CubeReceiver:registerEvent()
-- 	-- 监听光线是否贯通
-- 	EventControler:addEventListener(EliteEvent.ELITE_GEAR_CUBE_ONE_ROUTE_THROUGH, self.onOneRouteThough, self)
-- end

-- 光线贯通
function EliteCubeReceiverModel:onOneRouteThough(isVisible)
	-- echo("设置已着凉 ")
	self.currentView.panel_dui:setVisible(isVisible)
end

return EliteCubeReceiverModel
