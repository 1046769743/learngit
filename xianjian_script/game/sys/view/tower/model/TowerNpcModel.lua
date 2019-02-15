--[[
	Author: 张燕广
	Date:2017-07-31
	Description: 锁妖塔NPC事件类
]]

local TowerEventModel = require("game.sys.view.tower.model.TowerEventModel")
TowerNpcModel = class("TowerNpcModel",TowerEventModel)

function TowerNpcModel:ctor( controler,gridModel)
	TowerNpcModel.super.ctor(self,controler,gridModel)
	self:initData()
end

function TowerNpcModel:initData()
	local gridInfo = self.grid:getGridInfo()
	local npcId = gridInfo[FuncTowerMap.GRID_BIT.TYPE_ID]
	self:setEventId(npcId)
end

-- NPC事件回应
function TowerNpcModel:onEventResponse()
	echo("NPCTowerBoxModel:onEventResponse")

	self:checkSkipStatus()
	if self.isOverlapWithChar then
		echo("与主角重叠")
		return
	end

	local params = {x=self.grid.xIdx,y=self.grid.yIdx}
	TowerControler:chooseTowerNpcView(self.eventId,params)
end

function TowerNpcModel:isOverlapChar()
	return self.isOverlapWithChar
end



function TowerNpcModel:checkSkipStatus(event)
	self.gridInfo = TowerMapModel:getGridInfo(self.grid.xIdx,self.grid.yIdx)

	-- 判断道具与主角是否重叠
	local charModel = self.controler.charModel
	local charGrid = charModel:getGridModel()

	-- 主角走到了怪的身上
	if charGrid.xIdx == self.grid.xIdx and charGrid.yIdx == self.grid.yIdx then
		self.isOverlapWithChar = true
	else
		self.isOverlapWithChar = false
	end
end


-- 设置事件ID
function TowerNpcModel:setEventId(eventId)
	TowerNpcModel.super.setEventId(self,eventId)
	self.npcData = FuncTower.getNpcData(eventId)
end
                        
function TowerNpcModel:createEventView()
	local npcId = self.eventId
	local npcData = self.npcData

	local spineId = npcData.spine
	local spine = self.controler:createNpcSpineById(spineId)
	local npcSourceData = FuncTreasure.getSourceDataById(spineId)
	local size = cc.size(npcSourceData.viewSize[1],npcSourceData.viewSize[2])

	local viewCtn = self.grid.viewCtn
	local x = self.grid.pos.x
	local y = self.grid.pos.y
	local z = 0

	self:initView(viewCtn,spine,x,y,z,size)
	local zorder = self.grid:getZOrder() + 1
	self:setZOrder(zorder)

	return spine
end

-- 每帧刷新
function TowerNpcModel:dummyFrame()
	TowerNpcModel.super.dummyFrame(self)
	self:checkAlertStatus()

	self:checkSkipStatus()
	-- 更新跳过状态视图
	self:updateSkipView()
end

function TowerNpcModel:updateSkipView()
	if self.myView then
		if self.isOverlapWithChar then
			self.myView:opacity(100)
		else
			self.myView:opacity(255)
		end
	end
end

-- 检查警戒状态,劫匪会锁住主角
function TowerNpcModel:checkAlertStatus()
	if self:isRobber() then
		self:playAlertAnim(true)
	else
		self:playAlertAnim(false)
	end
end

-- 是否是警戒怪
function TowerNpcModel:isRobber()
	local eventData = FuncTower.getNpcEvent(self.npcData.event[1])
	if (eventData.type == FuncTowerMap.NPC_EVENT_TYPE.ROB_TREASURE)
		or (eventData.type == FuncTowerMap.NPC_EVENT_TYPE.ROB_WOMAN)
		or (eventData.type == FuncTowerMap.NPC_EVENT_TYPE.ROB_STONE)
	then
		return true
	else
		return false
	end
end

-- 更新警戒动画,劫财劫色的npc 会锁定主角
function TowerNpcModel:playAlertAnim(visible)
	if not self.myView then
		return
	end

	if not visible and not self.alertAnim then
		return
	end

	if not self.alertAnim then
		self.alertAnim = self.controler.ui:createUIArmature("UI_suoyaota","UI_suoyaota_gantaohao", 
			self.viewCtn, true, GameVars.emptyFunc);
		local zorder = self.grid:getZOrder()
		self.alertAnim:zorder(zorder+10)
		self.alertAnim:pos(self.grid.pos.x+40,self.grid.pos.y+self.mySize.height - 10)
		self.alertAnim:startPlay(true)
	end

	if self.alertAnim then
		self.alertAnim:setVisible(visible)
	end
end

function TowerNpcModel:deleteMe()
	self:deleteMyView()
	TowerNpcModel.super.deleteMe(self)
end

function TowerNpcModel:deleteMyView()
	if self.alertAnim and not tolua.isnull(self.alertAnim) then
		self.alertAnim:removeFromParent()
	end

	TowerNpcModel.super.deleteMyView(self)
end

return TowerNpcModel