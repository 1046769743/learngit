--[[
	Author: 张燕广
	Date:2018-07-26
	Description: 小游戏基类
]]

local GameBaseView = class("GameBaseView", UIBase);

function GameBaseView:ctor(winName,gameData)
    GameBaseView.super.ctor(self, winName)

    self.gameData = gameData
end

--[[
	对外接口-设置游戏监听器，必须调用该接口
	listenerObj:lua table
	必须实现的接口有：
	onGameOver:lua function

	可能的其他接口(根据具体游戏玩法实现自己的接口)
	比如：getNextRoundData


	示例：
	local listenerObj = {}
	listenerObj.onGameOver = function(gameResult)
		
	end
]]
function GameBaseView:setGameListener(listenerObj)
	self.gameListener = listenerObj
end

function GameBaseView:loadUIComplete()
	self:registerEvent()
	self:initGameData()
	self:initGameView()
	self:initViewAlign()
end 

function GameBaseView:registerEvent()
	GameBaseView.super.registerEvent(self);
end

--[[
	子类重写initData
]]
function GameBaseView:initGameData()
	-- 根据小游戏的不同需求扩展游戏状态
	self.GAME_STATUS = {
		PREPARE = 1,	--准备阶段
		START = 2, 		--游戏开始
		PLAYING = 3, 	--进行中
		ROUND_OVER = 4, --一轮结束
		OVER_SHOW = 5, --游戏结束前表现阶段
		OVER = 6,  		--游戏结束
		RESTART = 7,    --重新开始
	}

	-- 游戏结果
	self.GAME_RESULT = FuncGame.GAME_RESULT
end

--[[
	子类重写initView
]]
function GameBaseView:initGameView()
	
end

function GameBaseView:initViewAlign()
	
end

--[[
	设置游戏状态
]]
function GameBaseView:updateGameStatus(status, ...)
	if self.curGameStatus == status then
		return
	end

	self.curGameStatus = status
	self:updateGameView(...)
end

--[[
	更新游戏
]]
function GameBaseView:updateGameView(...)
	if self.curGameStatus == self.GAME_STATUS.PREPARE then
		self:onGamePrepare(...)
	elseif self.curGameStatus == self.GAME_STATUS.START then
		self:onGameStart(...)
	elseif self.curGameStatus == self.GAME_STATUS.PLAYING then
		self:onGamePlaying(...)
	elseif self.curGameStatus == self.GAME_STATUS.ROUND_OVER then
		self:onGameRoundOver(...)
	elseif self.curGameStatus == self.GAME_STATUS.OVER_SHOW then
		self:onGameOverShow(...)
	elseif self.curGameStatus == self.GAME_STATUS.OVER then
		self:onGameOver(...)
	elseif self.curGameStatus == self.GAME_STATUS.RESTART then
		self:onGameRestart(...)
	end
end

--[[
	当游戏准备中
]]
function GameBaseView:onGamePrepare()

end

--[[
	当游戏开始
]]
function GameBaseView:onGameStart()

end

--[[
	当游戏进行中
]]
function GameBaseView:onGamePlaying()

end

--[[
	当游戏结束前表现阶段
]]
function GameBaseView:onGameOverShow()

end

--[[
	当游戏一局结束
]]
function GameBaseView:onGameRoundOver()

end

--[[
	当游戏重新开始
]]
function GameBaseView:onGameRestart()

end

--[[
	设置游戏结束后的数据
	gameResultData:lua table
]]
function GameBaseView:setGameResultData(gameResultData)
	self.gameResultData = gameResultData
end

--[[
	当游戏结束
	gameResultData:lua table
]]
function GameBaseView:onGameOver()
	if not self.gameResultData then
		self.gameResultData = {}
	end

	if self.gameListener and self.gameListener.onGameOver then
		self.gameListener.onGameOver(self.gameResultData)
	end
end

function GameBaseView:deleteMe()
	GameBaseView.super.deleteMe(self);
end

return GameBaseView;
