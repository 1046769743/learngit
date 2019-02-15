--
--Author:      zhuguangyuan
--DateTime:    2018-02-05 09:38:22
--Description: 宝箱事件model
--

local EliteEventModel = require("game.sys.view.elite.eliteModel.EliteEventModel")
EliteBoxModel = class("EliteBoxModel",EliteEventModel)

function EliteBoxModel:ctor( controler,gridModel)
	EliteBoxModel.super.ctor(self,controler,gridModel)
	self:initData()
	self:registerEvent()
end

function EliteBoxModel:initData()
	-- 动画类别
	self.ANIM_TYPE = {
		-- 通用特效
		COMMON = 1,
		-- 特有特效，用特效代替icon
		SPECIAL = 2,
		-- 没有特效，显示icon
		NONE = 3,
	}

	-- 宝箱暂时没有通用类型特效
	-- 通用特效名字
	self.comAnimName = ""

	local gridInfo = self.grid:getGridInfo()
	local boxId = nil
	if gridInfo.ext ~= nil then
		boxId= gridInfo.ext.boxId
	else	
		boxId= gridInfo[FuncEliteMap.GRID_BIT.TYPE_ID]
	end
	self:setEventId(boxId)
end


function EliteBoxModel:registerEvent()
	EventControler:addEventListener(EliteEvent.ELITE_OPEN_BOX_CONDITION_MET,self.meetOpenBoxCondition,self)
end

-- 打开宝箱,弹出奖励,删除场景中的宝箱view
function EliteBoxModel:meetOpenBoxCondition( event )
	local boxId = event.params.Id
	echo("_____ 收到消息 boxId___________",boxId)

	local function callBack( serverData )
		if serverData.result and serverData.result.data.reward then
			dump(serverData.result.data.reward, "领取宝箱服务返回")
			local boxRewardData = table.deepCopy(serverData.result.data.reward) -- FuncElite.getBoxReward( boxId )
			-- WindowControler:showWindow("RewardSmallBgView", boxRewardData)

			-- 更新数据
			local data = {}
			data[self.grid.xIdx.."_"..self.grid.yIdx] = {
				["status"] = FuncEliteMap.GRID_BIT_STATUS.CLEAR,
				["isBox"] = boxId,
			}
			EliteMainModel:updateData(data)
			EventControler:dispatchEvent(EliteEvent.ELITE_OPEN_BOX_SUCCEED,{Id = self.boxId} )
			self.grid:clearEventModel()
			self:deleteMe()
			WindowControler:showWindow("RewardSmallBgView", boxRewardData)
		else

		end
	end
	if tostring(boxId) == tostring(self.eventId) then
		if EliteMapModel:checkUsedBox(self.controler.storyId,boxId) then
			echoError("宝箱已被领取boxId=",boxId)
			local boxStatusMap = WorldModel:data()
			dump(boxStatusMap,"boxStatusMap---------------")
			local gridData = self.grid.gridInfo
			dump(gridData,"gridData------------------------")
		else
			WorldServer:openExtraBox(self.controler.storyId,boxId,callBack)
		end
	end
end

function function_name( ... )
	-- body
end
function EliteBoxModel:onAfterOpenGrid()
	echo("_______ 格子已经打开 是时候创建宝箱了 _________")
	if not self.myView then
		-- self:createEventView()
	end
end

-- 宝箱事件响应
function EliteBoxModel:onEventResponse()
	local params = {x=self.grid.xIdx,y=self.grid.yIdx}

	local boxId = self.eventId
	echo("点击了宝箱 boxId=",boxId)
	-- 机关宝箱 答题宝箱 无条件领取宝箱
	if self.boxType == FuncElite.BOX_TYPE.ORGAN then
		local organTableName = self.boxData.organ
		WindowControler:showWindow("EliteGearView",boxId,organTableName) 
	elseif self.boxType == FuncElite.BOX_TYPE.POETRY then
		WindowControler:showWindow("ElitePoetryView",boxId)
	elseif self.boxType == FuncElite.BOX_TYPE.GUESS then
		local gameId = self.boxData.game_id
		local gameData = {gameId = gameId}
	    local gameView = WindowControler:showWindow("GameGuessMeView",gameData)

	    local gameListener = {}
	    -- 游戏结束回调
	    gameListener.onGameOver = function(gameResultData)
	        if gameResultData and gameResultData.rt == FuncGame.GAME_RESULT.WIN then
	        	EventControler:dispatchEvent(EliteEvent.ELITE_OPEN_BOX_CONDITION_MET,{Id = boxId} )
	        end
	    end

	    gameView:setGameListener(gameListener)
	else
		EventControler:dispatchEvent(EliteEvent.ELITE_OPEN_BOX_CONDITION_MET,{Id = boxId} )
	end
end

-- 设置事件ID
function EliteBoxModel:setEventId(eventId)
	EliteBoxModel.super.setEventId(self,eventId)
	self.boxData = FuncElite.getBoxProperty( eventId )
	dump(self.boxData, " === 宝箱数据 ===")
	self.boxType = self.boxData.type
end

-- 创建宝箱事件视图
function EliteBoxModel:createEventView()
	echo("________创建宝箱事件视图___self.eventId______")
	local boxId = self.eventId
	local boxData = self.boxData
	local animType = self.ANIM_TYPE.NONE --    self.boxData.animType
	local viewCtn = self.grid.viewCtn
	-- 创建宝箱动画
	local boxView = self:createAnim(animType)

	if boxView == nil or animType == self.ANIM_TYPE.COMMON then
		local iconName = boxData.png
		local iconPath = FuncRes.iconTowerEvent(iconName)
		local iconSprite = display.newSprite(iconPath)
		-- 通用特效，需要换装
		if animType == self.ANIM_TYPE.COMMON then
			FuncArmature.changeBoneDisplay(boxView,"node",iconSprite)
		else
			boxView = iconSprite
		end
	end
	
	local x = self.grid.pos.x
	local y = self.grid.pos.y
	local z = 0
	local tempX,tempY = boxView:getPosition()

	boxView:setPosition(tempX,tempY+15)
	boxView:setScale(0.9)
	
	self:initView(viewCtn,boxView,x,y,z)
	local zorder = self.grid:getZOrder() + 1
	self:setZOrder(zorder)
end

-- 创建宝箱动画
function EliteBoxModel:createAnim(animType)
	local ui = self.controler.ui

	local anim = nil
	if animType == self.ANIM_TYPE.NONE then
		return anim
	elseif animType == self.ANIM_TYPE.SPECIAL then
		local animName = self.boxData.anim
		anim = ui:createUIArmature(self.controler.animFlaName,animName,nil, false, GameVars.emptyFunc)
	elseif animType == self.ANIM_TYPE.COMMON then
		anim = ui:createUIArmature(self.controler.animFlaName,self.comAnimName,nil, false, GameVars.emptyFunc)
	end
	anim:startPlay(true)
	return anim
end

return EliteBoxModel
