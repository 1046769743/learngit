--[[
	Author: lcy
	Date: 2018.07.30
	des: 答题游戏

	ex:

	local gameData = {gameId = "1"}
    local gameView = WindowControler:showWindow("GameQuestionView",gameData)
	
	local gameListener = {}
	gameListener.onGameOver = function(gameResultData)
	    dump(gameResultData,"gameResultData---------")
	end

	gameView:setGameListener(gameListener)
]]

local GameBaseView = require("game.sys.view.game.GameBaseView")
local GameQuestionView = class("GameQuestionView", GameBaseView)

local TITLE_TID = "#tid_game_101"

function GameQuestionView:ctor(winName, gameData)
	GameQuestionView.super.ctor(self, winName, gameData)
end

function GameQuestionView:registerEvent()
	GameQuestionView.super.registerEvent(self)
	self.UI_1.btn_close:setTap(c_func(self.onCloseClick,self))
end

function GameQuestionView:loadUIComplete()
	GameQuestionView.super.loadUIComplete(self)

	-- 初始化为准备阶段，点击开始按钮后才开始游戏
	self:updateGameStatus(self.GAME_STATUS.START)
end

-- 子类重写initData
function GameQuestionView:initGameData()
	GameQuestionView.super.initGameData(self)

	self.gameId = self.gameData.gameId
	-- 所有题
	self.gameDataCfg = FuncGame.getQuestionsById(self.gameId)

	-- 重置题目
	self:resetQuestion()
end

-- 重置题目
function GameQuestionView:resetQuestion()
	-- 未使用的题目
	self.unuseQuestion = table.copy(self.gameDataCfg)
end

-- 获取一道题
function GameQuestionView:getOneQuestion()
	if #self.unuseQuestion == 0 then
		self:resetQuestion()
	end

	local idx = RandomControl.getOneRandomInt(#self.unuseQuestion+1,1)
	local data = self.unuseQuestion[idx]
	table.remove(self.unuseQuestion, idx)

	-- 处理题目
	local question = {
		q = data.question, -- 题干
		a = RandomControl.randomOneGroupArr({1,2,3,4}),-- 答案1
		right = 1,
	}

	for i=1,4 do
		local idx = question.a[i]
		if idx == 1 then question.right = i end
		question.a[i] = data["option"..idx]
	end

	return question
end

-- 游戏开始
function GameQuestionView:onGameStart()
	self.UI_1.mc_1:visible(false)

	local question = self:getOneQuestion()

	self.UI_1.txt_1:setString(GameConfig.getLanguage(TITLE_TID))
	self.txt_1:setString(GameConfig.getLanguage(question.q))

	for i=1,4 do
		-- 按钮
		self["btn_"..i]:setBtnStr(GameConfig.getLanguage(question.a[i]),"txt_1")
		self["btn_"..i]:setTap(c_func(self.selectAnswer, self, i, question.right))
		-- 选项
		self["panel_dui"..i]:visible(false)
		self["panel_cuo"..i]:visible(false)
	end
end

-- 选择答案
function GameQuestionView:selectAnswer(curIdx, rightIdx)
	self.gameResult = curIdx == rightIdx and self.GAME_RESULT.WIN or self.GAME_RESULT.FAIL
	self.gameResultData = {
		rt = self.gameResult
	}

	self:updateGameStatus(self.GAME_STATUS.OVER_SHOW, curIdx, rightIdx)
end

-- 游戏结束表现阶段
function GameQuestionView:onGameOverShow(curIdx, rightIdx)
	self:disabledUIClick()

	-- 正确答案
	self["panel_dui" .. rightIdx]:visible(true)
	-- 错误答案
	self["panel_cuo" .. curIdx]:visible(curIdx ~= rightIdx)

	-- 游戏结束
	local callBack = function()
		self:updateGameStatus(self.GAME_STATUS.OVER)
	end
	-- 游戏正式结束
	self:delayCall(c_func(callBack),1.2)
end

-- 游戏结束阶段
function GameQuestionView:onGameOver()
	self:resumeUIClick()

	if self.gameResult == self.GAME_RESULT.WIN then
		GameQuestionView.super.onGameOver(self)
		self:startHide()
	elseif self.gameResult == self.GAME_RESULT.HANDOUT then
		GameQuestionView.super.onGameOver(self)
		self:startHide()
	else
		self:updateGameStatus(self.GAME_STATUS.RESTART)
	end
end

--[[
	重启游戏
]]
function GameQuestionView:onGameRestart()
	self:updateGameStatus(self.GAME_STATUS.START)
end

-- 点关闭
function GameQuestionView:onCloseClick()
	self.gameResult = FuncGame.GAME_RESULT.HANDOUT
	self.gameResultData = {
		rt = FuncGame.GAME_RESULT.HANDOUT,
	}
	self:updateGameStatus(self.GAME_STATUS.OVER)
end

-- 屏蔽关闭
function GameQuestionView:hideCloseBtn()
	self.UI_1.btn_close:visible(false)
end

return GameQuestionView