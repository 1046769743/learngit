--
--Author:      zhuguangyuan
--DateTime:    2018-02-08 11:17:24
--Description: 机关格子 光路模型
--


local EliteCubeBasicModel = require("game.sys.view.elite.eliteModel.EliteCubeBasicModel")
EliteCubeLightModel = class("EliteCubeLightModel",EliteCubeBasicModel)

function EliteCubeLightModel:ctor( controler ,xIdx,yIdx,gridInfo)
	EliteCubeLightModel.super.ctor(self,controler ,xIdx,yIdx,gridInfo)
	self.gridInfo = gridInfo

	self.xIdx = xIdx
	self.yIdx = yIdx
	self.cubeType = FuncEliteMap.ORGAN_MAP_GRID_TYPE.EMPTY
	self.isCanMove = true
	self.rotationAngle1 = nil
	self.rotationAngle2 = nil
	self.rotationAngle3 = nil
	self.rotationAngle4 = nil
end

function EliteCubeLightModel:registerEvent()
	EliteCubeLightModel.super.registerEvent(self)
end


function EliteCubeLightModel:getEventModel()
	return self.eventModel
end

-- 创建GridModel时，先设置view信息
function EliteCubeLightModel:setViewInfo(ctn,xpos,ypos,zpos)
	self.viewCtn = ctn
	if xpos and ypos and zpos then
		self:setPos(xpos,ypos,zpos)
	end

	self:showDebugInfo()
end

-- 初始化格子视图
function EliteCubeLightModel:initView(ctn,_view,xpos,ypos,zpos)
	EliteCubeLightModel.super.initView(self,ctn,_view,xpos,ypos,zpos,size)

	if not self.lightAni1 then
		self.lightAni1 = self.controler.ui:createUIArmature("UI_jiguanbaoxiang","UI_jiguanbaoxiang_lianjie5",self.myView,true,GameVars.emptyFunc)
		self.lightAni1:visible(false)
	end
	if not self.lightAni2 then
		self.lightAni2 = self.controler.ui:createUIArmature("UI_jiguanbaoxiang","UI_jiguanbaoxiang_lianjie5",self.myView,true,GameVars.emptyFunc)
		self.lightAni2:setRotation(90)
		self.lightAni2:visible(false)
	end
	-- self.myView:showFrame(3)
	-- self.currentView = self.myView:getCurFrameView()
end

-- 更新光路
function EliteCubeLightModel:updateLightRotation(r1,r2)
	-- echo("_________r1,r2___________",r1,r2)
	if r1 then
		self.rotationAngle1 = r1
		self.myView.panel_light1:visible(true)
		self.myView.panel_light1:setRotation(self.rotationAngle1)
	else
		self.myView.panel_light1:visible(false)
	end
	if r2 then
		self.rotationAngle2 = r2
		self.myView.panel_light2:visible(true)
		self.myView.panel_light2:setRotation(self.rotationAngle2)
	else
		self.myView.panel_light2:visible(false)
	end

	-- 东西方向
	if (r1 == FuncEliteMap.ROTATION_ANGLE.WEST 
		or r2 == FuncEliteMap.ROTATION_ANGLE.WEST)  
		and (r1 == FuncEliteMap.ROTATION_ANGLE.EAST 
		or r2 == FuncEliteMap.ROTATION_ANGLE.EAST) 
		then
		self.lightAni1:visible(true)
		self.lightAni2:visible(false)
	-- 东北方向
	elseif (r1 == FuncEliteMap.ROTATION_ANGLE.NORTH 
		or r2 == FuncEliteMap.ROTATION_ANGLE.NORTH)  
		and (r1 == FuncEliteMap.ROTATION_ANGLE.SOUTH 
		or r2 == FuncEliteMap.ROTATION_ANGLE.SOUTH) 
		then
		self.lightAni1:visible(false)
		self.lightAni2:visible(true)
	else 
		self.lightAni1:visible(false)
		self.lightAni2:visible(false)
	end
end

-- 更新光路2
function EliteCubeLightModel:updateLightRotation2(r3,r4)
	-- echo("_________r3,r4___________",r3,r4)
	if r3 then
		self.rotationAngle3 = r3
		self.myView.panel_light3:visible(true)
		self.myView.panel_light3:setRotation(self.rotationAngle3)
	else
		self.myView.panel_light3:visible(false)
	end
	if r4 then
		self.rotationAngle4 = r4
		self.myView.panel_light4:visible(true)
		self.myView.panel_light4:setRotation(self.rotationAngle4)
	else
		self.myView.panel_light4:visible(false)
	end

	-- 东西方向
	if (r3 == FuncEliteMap.ROTATION_ANGLE.WEST 
		or r4 == FuncEliteMap.ROTATION_ANGLE.WEST)  
		and (r3 == FuncEliteMap.ROTATION_ANGLE.EAST 
		or r4 == FuncEliteMap.ROTATION_ANGLE.EAST) 
		then
		self.lightAni1:visible(true)
	-- 东北方向
	elseif (r3 == FuncEliteMap.ROTATION_ANGLE.NORTH 
		or r4 == FuncEliteMap.ROTATION_ANGLE.NORTH)  
		and (r3 == FuncEliteMap.ROTATION_ANGLE.SOUTH 
		or r4 == FuncEliteMap.ROTATION_ANGLE.SOUTH) 
		then
		self.lightAni2:visible(true)
	end
end

return EliteCubeLightModel
