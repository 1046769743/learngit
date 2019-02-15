--[[
	Author: 张燕广
	Date:2017-07-31
	Description: 精英探索事件基类
]]

local EliteBasicModel = require("game.sys.view.elite.eliteModel.EliteBasicModel")
EliteEventModel = class("EliteEventModel",EliteBasicModel)

function EliteEventModel:ctor( controler,gridModel )
 	EliteEventModel.super.ctor(self,controler)
 	self.grid = gridModel

 	self.isEventValid = true
end

-- 子类重写，当主角运动到格子
function EliteEventModel:onCharArriveTargetGrid(grid)
	
end

function EliteEventModel:initView(ctn,view,xpos,ypos,zpos,size)
	if self.myView then
		return
	end

	-- 为放置笼子,创建一个node
	local eventView = display.newNode()
	eventView:addChild(view)
	EliteEventModel.super.initView(self,ctn,eventView,xpos,ypos,zpos,size)
end

-- 当view创建完成
function EliteEventModel:onInitViewComplete()
	EliteEventModel.super.onInitViewComplete(self)

	if self.controler and not self.controler.UPDATE_FRAME then
		self:updateFrame()
	end
end

--设置viewscale
function EliteEventModel:setViewScale( value )
	self.viewScale = value
	self.myView:setScaleX(self.way*self.viewScale )
	self.myView:setScaleY(self.viewScale)
	self:setViewSize(self.mySize)
end

-- 事件回应，需要子类重写该方法
function EliteEventModel:onEventResponse()
	echo("EliteEventModel:onEventResponse")
end

-- 当格子被打开后，需要子类重写
function EliteEventModel:onAfterOpenGrid()
	echo("EliteEventModel:onAfterOpenGrid")
end

-- 每帧刷新
function EliteEventModel:dummyFrame()
	-- 更新zorder
	if self.grid then
		local zorder = self.grid:getEventZOrder()
		self:setZOrder(zorder)
	end

	-- 更新笼子
	self:updateCage()
end

function EliteEventModel:onAfterCreateView()
	self:updateCage()
end

-- 更新事件的笼子(如果有)
function EliteEventModel:updateCage()
	if self.cageModel then
		self.cageModel:updateFrame()
	end
end

function EliteEventModel:setGrid(grid)
	self.grid = grid
	self.gridInfo = EliteMapModel:getGridInfo(self.grid.xIdx,self.grid.yIdx)
end

function EliteEventModel:getGrid()
	return self.grid
end

-- 子类重写，设置事件Id
function EliteEventModel:setEventId(eventId)
	self.eventId = eventId
end

function EliteEventModel:getEventId()
	return self.eventId
end

function EliteEventModel:setStatus(status)
	self.status = status
end

function EliteEventModel:setEventType(eventType)
	self.eventType = eventType
end

function EliteEventModel:getEventType()
	return self.eventType
end

function EliteEventModel:getStatus()
	return self.status
end

-- 安装一个笼子
function EliteEventModel:setCage(cageModel)
	self.cageModel = cageModel
end

function EliteEventModel:getCage()
	return self.cageModel
end

function EliteEventModel:clear()
	self:deleteMe()
end

function EliteEventModel:isValid()
	return self.isEventValid
end

function EliteEventModel:getEventView()
	return self.myView
end

function EliteEventModel:clearCage()
	if self.cageModel then
		self.cageModel:deleteMe()
		self.cageModel = nil
	end
end

-- 设置是否作弊模式
function EliteEventModel:setCheatStatus(isCheat)
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
function EliteEventModel:playSelectAnim(visible)
	if not self.selectAnim then
		self.selectAnim = self.controler.ui:createUIArmature("UI_suoyaota","UI_suoyaota_jihuo", 
			self.viewCtn, true, GameVars.emptyFunc);
		local zorder = self.grid:getZOrder()
		self.selectAnim:zorder(zorder)
		self.selectAnim:pos(self.pos.x,self.pos.y)

		self.selectAnim:startPlay(true)
	end

	if self.selectAnim and not tolua.isnull(self.selectAnim) then
		self.selectAnim:setVisible(visible)
	end
end

-- 事件点击特效
function EliteEventModel:showEventBtnEffect()
	if self.myView then
		local scale = self:getViewScale() * 1.1
		self.myView:runAction(act.bouncein(act.scaleto(4/GameVars.GAMEFRAMERATE ,scale,scale) ) )
	    FilterTools.flash_easeBetween(self.myView,4,nil,"oldFt","btnlight",false)
	end    
end

-- 事件按下特效
function EliteEventModel:showEventDownBtnEffect()
     if self.myView then
     	local scale = self:getViewScale()
        self.myView:runAction(act.bouncein(act.scaleto(4/GameVars.GAMEFRAMERATE ,scale,scale) ) )
        FilterTools.flash_easeBetween(self.myView,4,nil,"btnlight","oldFt",true)
	end    
end

function EliteEventModel:deleteMyView()
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

function EliteEventModel:deleteMe()
	-- if self.cageModel then
	-- 	self.cageModel:deleteMe()
	-- end
	self:clearCage()
	
	EliteEventModel.super.deleteMe(self)
end

return EliteEventModel
