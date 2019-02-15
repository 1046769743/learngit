--
--Author:      zhuguangyuan
--DateTime:    2018-02-08 11:16:38
--Description: 机关格子 边界格子模型
--


local EliteCubeBasicModel = require("game.sys.view.elite.eliteModel.EliteCubeBasicModel")
EliteCubeBorderModel = class("EliteCubeBorderModel",EliteCubeBasicModel)

function EliteCubeBorderModel:ctor( controler ,xIdx,yIdx,gridInfo)
	EliteCubeBorderModel.super.ctor(self,controler ,xIdx,yIdx,gridInfo)
	self.gridInfo = gridInfo

	self.xIdx = xIdx
	self.yIdx = yIdx
	self.isCanMove = false
end

function EliteCubeBorderModel:registerEvent()
	EliteCubeBorderModel.super.registerEvent(self)
end


-- 创建GridModel时，先设置view信息
function EliteCubeBorderModel:setViewInfo(ctn,xpos,ypos,zpos)
	self.viewCtn = ctn
	if xpos and ypos and zpos then
		self:setPos(xpos,ypos,zpos)
	end

	self:showDebugInfo()
end

-- 初始化格子视图
function EliteCubeBorderModel:initView(ctn,_view,xpos,ypos,zpos)
	EliteCubeBorderModel.super.initView(self,ctn,_view,xpos,ypos,zpos,size)
	self.myView:showFrame(3)
	local currentView = self.myView:getCurFrameView() 
	currentView.panel_light1:setVisible(false)
	currentView.panel_light2:setVisible(false)
	currentView:visible(false)
end

return EliteCubeBorderModel
