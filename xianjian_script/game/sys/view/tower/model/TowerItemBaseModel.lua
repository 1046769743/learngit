--[[
	Author: 张燕广
	Date:2017-07-31
	Description: 锁妖塔道具基类
]]

local TowerEventModel = require("game.sys.view.tower.model.TowerEventModel")
TowerItemBaseModel = class("TowerItemBaseModel",TowerEventModel)

function TowerItemBaseModel:ctor( controler,gridModel)
	TowerItemBaseModel.super.ctor(self,controler,gridModel)
	-- 动画类别
	self.ANIM_TYPE = {
		-- 通用特效
		COMMON = 1,
		-- 特有特效，用特效代替icon
		SPECIAL = 2,
		-- 没有特效，显示icon
		NONE = 3,
	}

	-- 通用特效名字
	self.comAnimName = "UI_suoyaota_baowuxuanfu"

	-- 左下角背包中的道具没有grid对象
	if self.grid then
		local gridInfo = self.grid:getGridInfo()
		local itemId = gridInfo[FuncTowerMap.GRID_BIT.TYPE_ID]
		self:setEventId(itemId)
	end

	self:initData()
end

-- 子类继承重写
function TowerItemBaseModel:initData()
	
end

--实时刷新
function TowerItemBaseModel:dummyFrame()
	TowerItemBaseModel.super.dummyFrame(self)
	self:checkSkipStatus()
	-- 更新跳过状态视图
	self:updateSkipView()
end

function TowerItemBaseModel:registerEvent()
	TowerItemBaseModel.super.registerEvent(self)
	-- 当主角运动到目标格子
	EventControler:addEventListener(TowerEvent.TOWEREVENT_CHAR_ARRIVE_TARGET_GIRD, self.onCharArriveTargetGrid,self)
	-- 确认拾取道具
	EventControler:addEventListener(TowerEvent.TOWEREVENT_CHOOSE_GET_ITEM,self.onConfirmGetItem,self)
	-- 确认使用道具
	EventControler:addEventListener(TowerEvent.TOWEREVENT_CLICK_USE_ITEM,self.doUseItem,self)
	-- 使用道具成功
	EventControler:addEventListener(TowerEvent.TOWEREVENT_USE_ITEM_SUCCESS,self.onUseItemSuccess,self)
	-- 使用道具失败
	EventControler:addEventListener(TowerEvent.TOWEREVENT_USE_ITEM_FAIL,self.onUseItemFail,self)
end

-- 道具事件回应(在地图格子上捡道具时的响应方法)
function TowerItemBaseModel:onEventResponse()
	echo("道具TowerItemBaseModel:onEventResponse")
	self:checkSkipStatus()
	if self.isOverlapWithChar then
		echo("与主角重叠")
		return
	end
	-- local goodsNum = TowerMainModel:getGoodsNum()
	-- if goodsNum >= TowerMainModel:getMaxOwnItemNum() then
	-- 	local tip = GameConfig.getLanguage("tid_tower_prompt_103")
	-- 	WindowControler:showTips(tip)
	-- 	return
	-- end
	local posParams = {}
	posParams.x = self.grid.xIdx
	posParams.y = self.grid.yIdx
    
	-- 捡道具界面
	WindowControler:showWindow("TowerUseItemView",self.itemData.id,nil,posParams,true)
end

function TowerItemBaseModel:checkCanUseItem(itemId,itemTime)
	if self:isTargetItem(itemId,itemTime) then
		return true
	end

	return false
end

-- 子类重写，确认使用道具
function TowerItemBaseModel:doUseItem(event)
	if not self:checkEventParams(event) then
		return
	end

	local itemId = event.params.itemId
	local itemTime = event.params.itemTime
	if self:checkCanUseItem(itemId,itemTime) then
		echo("道具确认使用TowerItemBaseModel:doUseItem,itemId=",itemId,itemTime)
		EventControler:dispatchEvent(TowerEvent.TOWEREVENT_BEGIN_USE_ITEM,{itemId=itemId,goodsTime=self.itemTime})
	end
end

function TowerItemBaseModel:checkEventParams(event)
	if not event or not event.params then
		echoError("道具使用参数错误,eventId=",self.eventId)
		return false
	end

	return true
end

-- 子类重写，主角运动到了目标格子
function TowerItemBaseModel:onCharArriveTargetGrid(event)

end

-- 子类重写，使用道具成功
function TowerItemBaseModel:onUseItemSuccess(event)
	if self:checkItemId(event) then
		self.controler.charModel:setCharItem(nil)
		
		local itemId = event.params.itemId
		echo("道具使用成功TowerItemBaseModel:onUseItemSuccess,itemId=",itemId)

		-- 通用的处理方式
		-- 1.先更新数据
		self:updateServerData(event)
		-- 2.再发送消息
		self:sendUpdateItemEvent()
	end
end

function TowerItemBaseModel:onUseItemFail(event)
	if self:checkItemId(event) then
		self.controler.charModel:setCharItem(nil)
	end
end

-- 更新服务器数据
function TowerItemBaseModel:updateServerData(event)
	if event and event.params then
		local serverData = event.params.serverData
		if serverData then
			TowerMainModel:updateData(serverData)
		end
	end
end

-- 发送更新道具消息
function TowerItemBaseModel:sendUpdateItemEvent()
	EventControler:dispatchEvent(TowerEvent.TOWEREVENT_USE_ITEM_UPDATE,{itemId=self.eventId})
end

-- 设置事件ID
function TowerItemBaseModel:setEventId(eventId)
	TowerItemBaseModel.super.setEventId(self,eventId)
	self.itemData = table.copy(FuncTower.getGoodsData(eventId))
end

-- 创建视图
function TowerItemBaseModel:createEventView()
	local itemData = self.itemData
	local animType = itemData.animType

	local viewCtn = self.grid.viewCtn
	-- 创建道具动画
	local itemView = self:createAnim(animType)
	if itemView == nil or animType == self.ANIM_TYPE.COMMON then
		local iconName = itemData.img
		local iconPath = FuncRes.iconTowerEvent(iconName)
		local iconSprite = display.newSprite(iconPath)
		--通用特效，需要换装
		if animType == self.ANIM_TYPE.COMMON then
			FuncArmature.changeBoneDisplay(itemView,"node",iconSprite)
		else
			itemView = iconSprite
		end
	end
	
	local offsetY = 20
	local x = self.grid.pos.x
	local y = self.grid.pos.y + offsetY
	local z = 0

	self:initView(viewCtn,itemView,x,y,z)
	local zorder = self.grid:getZOrder() + 1
	self:setZOrder(zorder)
end

-- 捡道具请求回调方法
function TowerItemBaseModel:getItemCallBack(event)
	if event.result and event.result.data then
		TowerMainModel:updateData(event.result.data)
		echo("拾道具成功self.eventId=",self.eventId)
		WindowControler:showTips(GameConfig.getLanguage("#tid_tower_ui_002")) 
		EventControler:dispatchEvent(TowerEvent.TOWEREVENT_GET_ITEM_SUCCESS,{itemId = self.eventId,tempGrid =self.grid})
	else
		echo("拾道具失败")
	end
end

-- 创建道具动画
function TowerItemBaseModel:createAnim(animType)
	local anim = nil
	if animType == self.ANIM_TYPE.NONE then
		return anim
	elseif animType == self.ANIM_TYPE.SPECIAL then
		local animName = self.itemData.anim
		anim = self.controler.ui:createUIArmature(self.controler.animFlaName,animName,nil, true, GameVars.emptyFunc)
	elseif animType == self.ANIM_TYPE.COMMON then
		anim = self.controler.ui:createUIArmature(self.controler.animFlaName,self.comAnimName,nil, true, GameVars.emptyFunc)
	end
	anim:startPlay(true)
	return anim
end

function TowerItemBaseModel:isTargetItem(itemId,itemTime)
	local targetItemModel = self.controler:findTargetItemById(itemId,itemTime)
	return self == targetItemModel
end

--确认拾取道具
function TowerItemBaseModel:onConfirmGetItem(event)
	local xIdx = event.params.x
	local yIdx= event.params.y
	local itemId = event.params.itemId
	if self.eventId == itemId and self.grid~=nil then
		if  xIdx == self.grid.xIdx and yIdx == self.grid.yIdx  then
			TowerServer:getItem(xIdx,yIdx,c_func(self.getItemCallBack,self))
		end	
	end
end

function TowerItemBaseModel:checkSkipStatus(event)
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

function TowerItemBaseModel:updateSkipView()
	if self.myView then
		if self.isOverlapWithChar then
			self.myView:opacity(100)
		else
			self.myView:opacity(255)
		end
	end
end

function TowerItemBaseModel:isOverlapChar()
	return self.isOverlapWithChar
end

-- 背包中的道具才会设置道具时间
-- 设置item获取时间
function TowerItemBaseModel:setItemTime(itemTime)
	self.itemTime = itemTime
end

function TowerItemBaseModel:getItemTime()
	return self.itemTime
end

-- 释放道具时点击了格式时，是否激活格子(是否触发格子回应方法)
function TowerItemBaseModel:checkActiveGrid()
	return true
end

-- event 网络交互后的消息传给的值
function TowerItemBaseModel:checkItemId(event)
	if event and event.params then
		local itemId = event.params.itemId
		local goodsKey = nil
		if event.params.serverData then
			goodsKey = event.params.serverData.goodsKey
		end

		if itemId == self.eventId and goodsKey and tostring(self.itemTime) == tostring(goodsKey) then
			return true
		end
	end
	return false
end

return TowerItemBaseModel
