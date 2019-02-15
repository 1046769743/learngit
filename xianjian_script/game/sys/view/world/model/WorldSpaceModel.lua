-- Author: ZhangYanguang
-- Date: 2017-05-15
-- 六界地标model

local WorldBuildingModel = require("game.sys.view.world.model.WorldBuildingModel")
WorldSpaceModel = class("WorldSpaceModel",WorldBuildingModel)

function WorldSpaceModel:ctor( controler,viewCtn,spaceName,info)
	WorldSpaceModel.super.ctor(self,controler)
	self.viewCtn = viewCtn
	self.spaceName = spaceName
	self.spaceInfo = info

	-- 挂机任务状态
	self.DELEGATE_TASK_STATUS = {
		NO_TASK = 0,  	--没有任务
		CAN_TAKE = 1, 	--可以接任务
		GET_REWARD = 2,	--可以领取奖励
	}

	self:initData()
	self:initPos(self.spaceInfo)
end

function WorldSpaceModel:initData()
	self.offsetInfo = cc.p(0,0)
	local spaceData = FuncChapter.getSpaceDataByName(self.spaceName)
	if spaceData and spaceData.offsetInfo then
		-- 主角进入地标时的偏移值
		self.offsetInfo = cc.p(spaceData.offsetInfo[1],spaceData.offsetInfo[2])
	end

	-- 默认点击偏移
	self.clickOffsetW = 1.0
	self.clickOffsetH = 1.0

	-- 默认点击Y坐标修正值,正数表示从上边减少，负数表示从下边减少
	self.clickMinusY = 0

	if spaceData then
		if spaceData.clickOffset then
			self.clickOffsetW = spaceData.clickOffset[1]
			self.clickOffsetH = spaceData.clickOffset[2]
		elseif spaceData.clickMinusY then
			self.clickMinusY = tonumber(spaceData.clickMinusY)
		end
	end
end

-- 获取主角进入地标的点
function WorldSpaceModel:getEnterPoint()
	local point = {}
	point.x = self.pos.x + self.offsetInfo.x
	point.y = self.pos.y + self.offsetInfo.y

	return point
end

function WorldSpaceModel:initPos(spaceInfo)
	-- 导出的地标sprite原点是中心
	local width = spaceInfo.width
	local height = spaceInfo.height
	local x = spaceInfo.x

	-- spine原点是脚下中心
	local y = spaceInfo.y
	self:setPos(x,y,0)
end

function WorldSpaceModel:createModelView()
	if self.myView then
		return
	end

	-- echo("创建建筑........self.spaceName=",self.spaceName)

	local spaceInfo = self.spaceInfo
	local spaceName = self.spaceName
	local ctn = self.viewCtn

	-- 导出的地标sprite原点是中心
	local width = spaceInfo.width
	local height = spaceInfo.height
	local x = spaceInfo.x

	-- spine原点是脚下中心
	local yOffset =   height / 2 - 20
	local y = spaceInfo.y - yOffset

	local spaceSize = cc.size(width,height)
	if not self.controler.is3DMode then
		local spaceImg = FuncRes.iconWorldSpace(spaceName)
		local sprite = display.newSprite(spaceImg)
		self:initView(spaceName,ctn,sprite,x,y,0,spaceSize)
	end

	local spineName = self.spaceInfo.fullName
	local spine = ViewSpine.new(spineName)
	spine:playLabel("animation")

	local spineCtn = display.newNode()
	spine:pos(0,yOffset)
	spineCtn:addChild(spine)

	self:initView(spaceName,ctn,spineCtn,x,y,0,spaceSize)
end

function WorldSpaceModel:initView(spaceName,...)
	WorldSpaceModel.super.initView(self,...)
	self.myView:anchor(0.5,0.5)

	self.spaceName = spaceName
	self:createLockTip()
	self:setClickFunc()
end

function WorldSpaceModel:registerEvent()
	WorldSpaceModel.super.registerEvent(self)
	EventControler:addEventListener(WorldEvent.WORLDEVENT_MAP_UI_TOUCH,self.onTouchMap,self)
	EventControler:addEventListener(WorldEvent.WORLDEVENT_MAP_TOUCH,self.onTouchMap,self)
	EventControler:addEventListener(WorldEvent.WORLDEVENT_CLICK_ONE_NPC,self.onTouchMap,self)
end

function WorldSpaceModel:onTouchMap()
	self:setIsClicked(false)
end

function WorldSpaceModel:getSpaceName()
	return self.spaceName
end

function WorldSpaceModel:createLockTip()
	self.lockTip = display.newSprite(FuncRes.iconPVE("world_img_suo"))
	self.lockTip:anchor(0,1)
	self.lockTip:pos(self.pos.x + self.mySize.width / 2 ,self.pos.y - self.mySize.height)
	self.viewCtn:addChild(self.lockTip,1)
end

function WorldSpaceModel:dummyFrame()
	WorldSpaceModel.super.dummyFrame(self)

	-- if self.updateCount % 30 ~= 0 then
	-- 	return
	-- end

	if self.lockTip then
		self:updateLockTip()
	end

	self:updateTouchNodePos()
end

function WorldSpaceModel:checkHit()
	if not self.isClicked then
		return
	end

	local spaceSize = self.mySize
	local spaceX = self.pos.x
	local spaceY = self.pos.y

	local spaceCenterX = spaceX + self.offsetInfo.x
	local spaceCenterY = spaceY + self.offsetInfo.y
	
	local charX = self.controler.charModel.pos.x
	local charY = self.controler.charModel.pos.y

	local spaceMeetDis = self.controler.spaceMeetDis

	if math.abs(charX - spaceCenterX) < spaceMeetDis and math.abs(charY - spaceCenterY) < spaceMeetDis then
		if not self.controler.hasEnterSpace then
			self.controler.hasEnterSpace = true
			self.controler:onEnterSpace(self.spaceName)
		end
	end
end

function WorldSpaceModel:updateLockTip()
	if WorldModel:canEnterSpace(self.spaceName) then
		self.lockTip:setVisible(false)
	else
	 	self.lockTip:setVisible(true)
	end 
end

function WorldSpaceModel:setClickFunc()
	local touchNode = display.newNode()
	local color = color or cc.c4b(255,0,0,120)

	-- TODO 临时解决3d坐标导致的点击问题
	local size = cc.size(self.mySize.width*self.clickOffsetW,self.mySize.height*self.clickOffsetH + self.clickMinusY)
	
	--[[
	-- 测试代码
  	local layer = cc.LayerColor:create(color)
    touchNode:addChild(layer)
    touchNode:setTouchEnabled(true)
    touchNode:setTouchSwallowEnabled(true)
    layer:setContentSize(size)
	--]]
	
	touchNode:setContentSize(size)
    touchNode:pos(-size.width / 2,-self.clickMinusY)
	touchNode:addto(self.myView,1)
	touchNode:setTouchedFunc(c_func(self.onClickSpaceEnd,self),nil, true,c_func(self.onClickSpaceBegin,self),c_func(self.onClickSpaceMove,self))

	self.touchNode = touchNode
	self.touchSize = size
	if not self.controler.is3DMode then
		self.myView:setTouchedFunc(c_func(self.onClickSpaceEnd,self),nil, true,c_func(self.onClickSpaceBegin,self),c_func(self.onClickSpaceMove,self),true,c_func(self.onClickSpaceGlobalEnd,self))
	end
end

-- TODO 临时解决bug
-- NPC在左侧时，左半身点不中，点击区域偏右，同理在右侧也一样
function WorldSpaceModel:updateTouchNodePos()
	if self.touchNode and self.touchSize then
		local offsetX = 0
		local worldPoint = self:getWorldPos()
		offsetX = (worldPoint.x - display.width/2) / display.width/2 * 500
		self.touchNode:setPositionX(-self.touchSize.width/2+offsetX)
	end
end

function WorldSpaceModel:onClickSpaceBegin()
	if TutorialManager.getInstance():isNpcInWorldHalt() then
		return
	end

	FilterTools.setFlashColor(self.myView,"spaceHighLight")
end

function WorldSpaceModel:onClickSpaceMove()
	if TutorialManager.getInstance():isNpcInWorldHalt() then
		return
	end

	FilterTools.clearFilter(self.myView)
end

function WorldSpaceModel:onClickSpaceGlobalEnd()
	if TutorialManager.getInstance():isNpcInWorldHalt() then
		return
	end
	
	FilterTools.clearFilter(self.myView)
end

function WorldSpaceModel:setIsClicked(isClicked)
	self.isClicked = isClicked
end

function WorldSpaceModel:onClickSpaceEnd()
	echo("\nWorldSpaceModel:onClickSpaceEnd")
	FilterTools.clearFilter(self.myView)
	-- TODO 新手引导中地标点击事件屏蔽
	echo("点击地标 WorldMapControler:onClickSpace 是否引导中 ",TutorialManager.getInstance():isNpcInWorldHalt())
	if TutorialManager.getInstance():isNpcInWorldHalt() then
		return
	end

	if WorldModel:canEnterSpace(self.spaceName) then
		self.isClicked = true
		self.controler:onClickSpace(self)
	else
		local levelLimit = WorldModel:getSpaceLevelLimit(self.spaceName)
		WindowControler:showTips(GameConfig.getLanguageWithSwap("tid_story_10019",levelLimit))
		self.controler:onClickSpace(self)
	end
end

-- 获取view边界信息
function WorldSpaceModel:getBorderInfo()
	local offsetY = 660
	local offsetX = 0
	
	local info = WorldSpaceModel.super.getBorderInfo(self)
	info.minY = info.minY - offsetY
	info.maxY = info.maxY + offsetY

	info.minX = info.minX - offsetX
	info.maxX = info.maxX + offsetX

	return info
end

function WorldSpaceModel:deleteMyView()
	-- echo("删除地标........self.spaceName=",self.spaceName)
	WorldSpaceModel.super.deleteMyView(self)
	self.touchNode = nil
	self.touchSize = nil
end

-- 进入地标
function WorldSpaceModel:enterSpace()
	-- 模拟地标点击操作
	self:onClickSpaceEnd()
end

function WorldSpaceModel:deleteMe()
	WorldSpaceModel.super.deleteMe(self)
	if self.lockTip then
		self.lockTip:removeFromParent()
	end

	if self.delegateTaskTipView then
		self.delegateTaskTipView:removeFromParent()
	end
end

return WorldSpaceModel
