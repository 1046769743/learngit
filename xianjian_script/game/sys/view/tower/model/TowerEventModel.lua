--[[
	Author: 张燕广
	Date:2017-07-31
	Description: 锁妖塔事件基类
]]

local TowerBasicModel = require("game.sys.view.tower.model.TowerBasicModel")
TowerEventModel = class("TowerEventModel",TowerBasicModel)

function TowerEventModel:ctor( controler,gridModel )
 	TowerEventModel.super.ctor(self,controler)
 	self.grid = gridModel

 	self.isEventValid = true
end

-- 子类重写，当主角运动到格子
function TowerEventModel:onCharArriveTargetGrid(grid)
	
end

function TowerEventModel:initView(ctn,view,xpos,ypos,zpos,size)
	if self.myView then
		return
	end

	-- 为放置笼子,创建一个node
	local eventView = display.newNode()
	eventView:addChild(view)
	view:pos(0,0)
	
	TowerEventModel.super.initView(self,ctn,eventView,xpos,ypos,zpos,size)
end

-- 当view创建完成
function TowerEventModel:onInitViewComplete()
	TowerEventModel.super.onInitViewComplete(self)

	if self.controler and not self.controler.UPDATE_FRAME then
		self:updateFrame()
	end
end

--设置viewscale
function TowerEventModel:setViewScale( value )
	self.viewScale = value
	self.myView:setScaleX(self.way*self.viewScale )
	self.myView:setScaleY(self.viewScale)
	self:setViewSize(self.mySize)
end

-- 事件回应，需要子类重写该方法
function TowerEventModel:onEventResponse()
	echo("TowerEventModel:onEventResponse")
end

-- 当格子被打开后，需要子类重写
function TowerEventModel:onAfterOpenGrid()
	echo("TowerEventModel:onAfterOpenGrid")
end

-- 每帧刷新
function TowerEventModel:dummyFrame()
	-- 更新zorder
	if self.grid then
		local zorder = self.grid:getEventZOrder()
		self:setZOrder(zorder)
	end

	-- 更新笼子
	self:updateCage()
end

function TowerEventModel:onAfterCreateView()
	self:updateCage()
end

-- 更新事件的笼子(如果有)
function TowerEventModel:updateCage()
	if self.cageModel then
		self.cageModel:updateFrame()
	end
end

function TowerEventModel:setGrid(grid)
	self.grid = grid
	self.gridInfo = TowerMapModel:getGridInfo(self.grid.xIdx,self.grid.yIdx)
end

function TowerEventModel:getGrid()
	return self.grid
end

-- 子类重写，设置事件Id
function TowerEventModel:setEventId(eventId)
	self.eventId = eventId
end

function TowerEventModel:getEventId()
	return self.eventId
end

function TowerEventModel:setStatus(status)
	self.status = status
end

function TowerEventModel:setEventType(eventType)
	self.eventType = eventType
end

function TowerEventModel:getEventType()
	return self.eventType
end

function TowerEventModel:getStatus()
	return self.status
end

-- 安装一个笼子
function TowerEventModel:setCage(cageModel)
	self.cageModel = cageModel
end

function TowerEventModel:getCage()
	return self.cageModel
end

function TowerEventModel:clear()
	self:deleteMe()
end

function TowerEventModel:isValid()
	return self.isEventValid
end

function TowerEventModel:getEventView()
	return self.myView
end

function TowerEventModel:clearCage()
	if self.cageModel then
		self.cageModel:deleteMe()
		self.cageModel = nil
	end
end

-- 设置是否作弊模式
function TowerEventModel:setCheatStatus(isCheat)
	self.isCheatMode = isCheat

	if isCheat then
		if not self.myView then
			self:createEventView()
		end

		if self.myView then
			self.myView:setOpacity(TowerConfig.CHEAT_EVENT_OPACITY)
		end
	else
		-- 作弊结束时，如果格子被探索了
		if self.grid:hasExplored() then
			if self.myView then
				self.myView:setOpacity(255)
			end
		else
			self:deleteMyView()
		end
	end
end

-- 播放选择动画
function TowerEventModel:playSelectAnim(visible)
	if not self.selectAnim then
		self.selectAnim = self.controler.ui:createUIArmature("UI_suoyaota","UI_suoyaota_jihuo", 
			self.viewCtn, true, GameVars.emptyFunc);
		self.selectAnim:pos(self.pos.x,self.pos.y)
		self.selectAnim:startPlay(true)
	end

	if self.selectAnim and not tolua.isnull(self.selectAnim) then
		local zorder = self:getZOrder()
		if not zorder then
			zorder = self.grid:getZOrder()
		end
		self.selectAnim:zorder(zorder)
		self.selectAnim:setVisible(visible)
	end
end

-- 事件点击特效
function TowerEventModel:showEventBtnEffect()
	if self.myView then
		local scale = self:getViewScale() * 1.1
		self.myView:runAction(act.bouncein(act.scaleto(4/GameVars.GAMEFRAMERATE ,scale,scale) ) )
	    FilterTools.flash_easeBetween(self.myView,4,nil,"oldFt","btnlight",false)
	end    
end

-- 事件按下特效
function TowerEventModel:showEventDownBtnEffect()
     if self.myView then
     	local scale = self:getViewScale()
        self.myView:runAction(act.bouncein(act.scaleto(4/GameVars.GAMEFRAMERATE ,scale,scale) ) )
        FilterTools.flash_easeBetween(self.myView,4,nil,"btnlight","oldFt",true)
	end    
end

function TowerEventModel:deleteMyView()
	if self.myView and  (not tolua.isnull(self.myView) ) then
		FilterTools.clearFilter( self.myView  )
		if self.myView.deleteMe then
			self.myView:deleteMe()
		else
			self.myView:clear()
		end

		self.myView = nil
	end

	if self.shade then
		self.shade:deleteMe()
	end
end

function TowerEventModel:deleteMe()
	-- if self.cageModel then
	-- 	self.cageModel:deleteMe()
	-- end
	self:clearCage()
	
	TowerEventModel.super.deleteMe(self)
end

return TowerEventModel
