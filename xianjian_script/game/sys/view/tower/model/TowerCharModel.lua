--[[
	Author: 张燕广
	Date:2017-07-28
	Description: 锁妖塔主角类
]]

local TowerMoveModel = require("game.sys.view.tower.model.TowerMoveModel")
TowerCharModel = class("TowerCharModel",TowerMoveModel)

function TowerCharModel:ctor( controler)
	TowerCharModel.super.ctor(self,controler)
	
	--方位对应的动作 左边是动作,右边是sc
	self.charRunFaceAction = {
        --右 
        {"run",1,},
        -- 右上
        {"run",1},
        -- 左上
        {"run",-1},
        -- 左
        {"run",-1},
        -- 左下
        {"run",-1},  
        --右下
        {"run",1},
    }

   self.charStandFaceAction = {
        --右 
        {"stand",1,},
        -- 右上
        {"stand",1},
        -- 左上
        {"stand",-1},
        -- 左
        {"stand",-1},
        -- 左下
        {"stand",-1},  
        --右下
        {"stand",1},
    }

	self.mySize = {width = 180,height = 180}
	-- 主角是否被锁定，锁定后不可移动
    self.isLock = false
end

function TowerCharModel:registerEvent()
	TowerCharModel.super.registerEvent(self)
	-- 当主角运动到一个格子
	EventControler:addEventListener(TowerEvent.TOWEREVENT_CHAR_ARRIVE_GIRD, self.onCharArriveGrid,self)
	-- 绕过怪成功
	EventControler:addEventListener(TowerEvent.TOWEREVENT_SKIP_MONSTER,self.onSkipMonster,self)
	-- 使用道具后数据更新
	EventControler:addEventListener(TowerEvent.TOWEREVENT_USE_ITEM_UPDATE, self.onUseItemSuccess, self)
end

function TowerCharModel:initView(...)
	TowerCharModel.super.initView(self,...)
	-- 默认站立朝向
	self:mapViewAction(160)
	self:setClickFunc()
end

-- 当主角运动到一个格子
function TowerCharModel:onCharArriveGrid()
	if self.myView then
		FilterTools.clearFilter(self.myView)
	end
end

-- 每帧刷新
function TowerCharModel:dummyFrame()
	-- 检查锁定状态
	self:checkLockStatus()

	if self:isCharMoving() then
		local gridModel = self.controler:getGridModelByPos(self.pos)
		if gridModel then
			local eventZOrder = gridModel:getEventZOrder()
			local newZOrder = eventZOrder+2
			if newZOrder ~= self:getZOrder() then
				self:setZOrder(newZOrder)
			end
		end
	end
end

function TowerCharModel:moveToPoint(targetPoint, speed,moveType )
	if self:isCharLock() then
		return
	end

	targetPoint.y = targetPoint.y - self.controler.charOffsetY
	TowerCharModel.super.moveToPoint(self,targetPoint, speed,moveType)
	--映射view的视图
	self:mapViewAction(self.angle)
	-- if targetPoint.xIdx and targetPoint.yIdx then
-- 	self.controler:onCharMoveOnGrid(targetPoint.xIdx,targetPoint.yIdx)
	-- end
	self:rePlayAction(true)
end

-- 绕过怪成功，主角移动到怪的位置
function TowerCharModel:onSkipMonster(event)
	if event and event.params then
		local params = event.params
		local monsterId = params.monsterId
		local xIdx = params.x
		local yIdx = params.y

		local grid = self.controler:findGridModel(xIdx,yIdx)
		-- 如果怪跟主角不在同一个格子
		if grid ~= self.gridModel then
			self.controler:moveCharToGrid({grid})
		end
	end
end

function TowerCharModel:setTargetGrid(gridModel)
	self.targetGrid = gridModel
end

function TowerCharModel:isCharMoving()
	return self.isMoving
end

function TowerCharModel:setIsCharMoving(isMoving)
	self.isMoving = isMoving
	if isMoving then
		self.controler.ui:disabledUIClick()
	else
		self.controler.ui:resumeUIClick()
	end
end

-- 当主角移动到了目标点
function TowerCharModel:onMoveToPointCallBack(isEnd)
	self.controler:onCharArriveGrid()
	if isEnd then
		self:rePlayAction(false)
		self:setIsCharMoving(false)
		self:setCurGrid(cc.p(self.targetGrid.xIdx,self.targetGrid.yIdx))

		self.controler:onCharArriveTargetGrid()
		self.targetGrid = nil

		self:onCharArriveTargetGrid()
	end
end

--[[
	当主角到达目标格子
]]
function TowerCharModel:onCharArriveTargetGrid()
	if self.gridModel then
		local eventZOrder = self.gridModel:getEventZOrder()
		self:setZOrder(eventZOrder+1)
	end
end


-- 修正主角朝向
function TowerCharModel:adjustViewAction()
	local clickGridModel = self.controler.clickedGridModel

	if clickGridModel ~= nil and clickGridModel ~= self.gridModel then
		local targetPoint = clickGridModel.pos
		local ang = self:calAngle(targetPoint)
		self:mapViewAction(ang)
	end
end

-- 修正主角zrder
function TowerCharModel:adjustZOrder()
	local zorder = self.gridModel:getZOrder()
	self:setZOrder(zorder+1)
end

function TowerCharModel:getGridModel()
	return self.gridModel
end

function TowerCharModel:getCurGrid()
	return self.curGrid
end

function TowerCharModel:setCurGrid(gridPos)
	self.curGrid = gridPos
	self.gridModel = self.controler:findGridModel(self.curGrid.x,self.curGrid.y)
end

-- 是否是主角相邻的格子
function TowerCharModel:isNeighbor(gridModel)
	if self.gridModel == nil then
		echoError("TowerCharModel:isNeighbor gridModel is nil")
		return false
	else
		local grids = self.controler:getSurroundGrids(gridModel)
		for k,v in pairs(grids) do
			if v == self.gridModel then
				return true
			end
		end
	end

	return false
end

function TowerCharModel:setClickFunc( )
	local nd = display.newNode()
	
	--[[
	-- 测试代码
	local color = color or cc.c4b(255,0,0,120)
  	local layer = cc.LayerColor:create(color)
    nd:addChild(layer)
    nd:setTouchEnabled(true)
    nd:setTouchSwallowEnabled(true)
    layer:setContentSize(cc.size(self.charWidth,self.charHeight) )
	]]
    nd:setContentSize(self.mySize)
    nd:pos(-self.mySize.width / 2,self.mySize.height / 2)
	
	-- nd:setContentSize(cc.size(figure,figure) )
	nd:addto(self.myView,1)
	-- nd:setTouchedFunc(c_func(self.onClickChar,self),nil,true)
end

function TowerCharModel:onClickChar(  )
	echo("点击了主角")
end

--根据角色map方位 rotation 是 角度 不是弧度
function TowerCharModel:mapViewAction( ang )
	-- ang  是-180 到+180之间的数 就是 math.atan2(dy,dx) * 180 /math.pi
    -- local index = math.ceil( (ang +180) / 60)
    local index = self:getActionIndex(ang)

    -- echo("_____ang",index,ang,ang - 180)

    if index > #self.charStandFaceAction then
        index = #self.charStandFaceAction
    end
    if index < 1 then
        index = 1
    end
    
    local action = nil
    local scaleX = 1
    action = self.charStandFaceAction[index][1]
	scaleX = self.charStandFaceAction[index][2]

    self.myView.currentAni:setScaleX(scaleX * self.viewScale)
    self.myView:playLabel(action)

    --当前动作标签
 	self.label = action
 	--当前方位 只分左右
 	self.way = scaleX
 	--当前角度
 	self.rotation = ang

 	self.charFace = action
 	self.charScaleX = scaleX
    self.index = index
end

function TowerCharModel:rePlayAction(isMoving)
	-- 设置为站立动作
	local action = self.charStandFaceAction[self.index][1]
	local faceActinArr = nil

	if isMoving then
		faceActinArr = self.charRunFaceAction
	else
		faceActinArr = self.charStandFaceAction
	end

	action = faceActinArr[self.index][1]
	scaleX = faceActinArr[self.index][2]

	self.myView.currentAni:setScaleX(scaleX * self.viewScale)
    self.myView:playLabel(action)
end

function TowerCharModel:onUseItemSuccess(event)
	if event and event.params then
		local itemId = event.params.itemId
		if itemId then
			local buffDes = TowerMainModel:getBuffDesByItemId(itemId)
			if buffDes then
				self:playBuffAnim(buffDes)
			end
		end
	end
end

-- 播放buff动画
function TowerCharModel:playBuffAnim(buffDes)
	if self.myView then
		if not self.buffCtn then
			self.buffCtn = display.newNode()
			self.buffCtn:pos(0,110)
			self.myView:addChild(self.buffCtn)
		end

		local text = {buffDes}
		FuncCommUI.playNumberRunaction(self.buffCtn, {
			        text = text,
			    })
	end
end

-- 播放buff动画
function TowerCharModel:playBuffAnim_old(buffDes)
	local buffAnim = self.controler.ui:createUIArmature("UI_suoyaota","UI_suoyaota_buff_shangsheng", 
			self.myView, false, GameVars.emptyFunc);

	local buffTxt = UIBaseDef:createPublicComponent( "UI_tower_grid","txt_buff")
	FuncArmature.changeBoneDisplay(buffAnim,"a",buffTxt)
	buffTxt:pos(-150,30)
	buffAnim:pos(0,self.mySize.height - 30)

	buffTxt:setString(buffDes)
	buffAnim:setVisible(true)
	buffAnim:startPlay(false)
	buffAnim:doByLastFrame(false,true)
end

-- 播放buff动画
function TowerCharModel:playRecoveryEnergyAni()
	echo("________ 播放回怒特效 ________________")
	-- eff_mannuqi

	local targetGrid = self.gridModel
	local spbName = "eff_mannuqi"
    local huluAnim = ViewSpine.new(spbName, {}, nil,spbName);
    huluAnim:playLabel("eff_mannuqi_zishen");
    huluAnim:pos(targetGrid.pos.x,targetGrid.pos.y)
    huluAnim:setIsCycle(false)

	local zorder = targetGrid:getZOrder() + 1
	huluAnim:zorder(zorder)

	local viewCtn = targetGrid.viewCtn
	viewCtn:addChild(huluAnim)

	if callBack then
		self.controler.ui:delayCall(callBack,huluAnim:getCurrentAnimTotalFrame() / GameVars.GAMEFRAMERATE)
	end
end

-- 播放buff动画
function TowerCharModel:playRecoveryBloodAni(targetGrid)
	echo("________ 播放回血特效 ________________")

	local targetGrid = self.gridModel
	local spbName = "eff_buff_jiaxue"
    local huluAnim = ViewSpine.new(spbName, {}, nil,spbName);
    huluAnim:playLabel("eff_buff_jiaxue");
    huluAnim:pos(targetGrid.pos.x,targetGrid.pos.y)
    huluAnim:setIsCycle(false)

	local zorder = targetGrid:getZOrder() + 1
	huluAnim:zorder(zorder)

	local viewCtn = targetGrid.viewCtn
	viewCtn:addChild(huluAnim)

	if callBack then
		self.controler.ui:delayCall(callBack,huluAnim:getCurrentAnimTotalFrame() / GameVars.GAMEFRAMERATE)
	end
end


function TowerCharModel:getActionIndex(ang)
	local index = nil
	-- 角度做一个修正，解决坐上/下角度刚好超过边界值的问题
	local offset = -1
	ang = ang + offset
	if ang >=-30 and ang <=30 then
		index = 1
	elseif ang >30 and ang <=90 then
		index = 2
	elseif ang >90 and ang <=150 then
		index = 3
	elseif ang >150 or ang <-150 then
		index = 4
	elseif ang >-150 and ang <=-90 then
		index = 5
	elseif ang >-90 and ang <=-30 then
		index = 6
	end

	return index
end

function TowerCharModel:checkLockStatus()
	if self.controler:hasAlertMonster() then
		self:setIsCharLock(true)
	else
		self:setIsCharLock(false)
	end
end

function TowerCharModel:setIsCharLock(isLock)
	self.isLock = isLock
end

function TowerCharModel:isCharLock()
	return self.isLock
end

function TowerCharModel:setCharItem(itemModel)
	self.itemModel = itemModel
end

function TowerCharModel:getCharItem()
	return self.itemModel
end

function TowerCharModel:checkGiveItemSkill()
	return self.itemModel ~= nil
end

function TowerCharModel:getIndex()
	return self.index
end

-- 检查主角是否中毒
function TowerCharModel:checkBePoisoned()
	if TowerMainModel:hasPoisonBuff() then
		return false
	else
		-- 主角踩在毒格子上
		local eventType = nil
		if self.gridModel then
			local eventModel = self.gridModel:getEventModel()
			if eventModel then
				eventType = eventModel:getEventType()
				if eventType == FuncTowerMap.GRID_BIT_TYPE.POISON then
					return true
				end
			end
		end
	end
	
	return false
end

function TowerCharModel:deleteMe()
	TowerCharModel.super.deleteMe(self)
	-- 如果在进入下一层的瞬间点击了其他位置导致主角移动(主角在model可能在移动到目的地前会被删除)
	if self:isCharMoving() then
		self.controler.ui:resumeUIClick()
	end
end

return TowerCharModel
