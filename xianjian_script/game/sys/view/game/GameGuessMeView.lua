--[[
	Author: 张燕广
	Date:2018-07-27
	Description: 下游戏玩法-猜猜我是谁

	使用示例:

	local gameData = {gameId = "1"}
    local gameView = WindowControler:showWindow("GameGuessMeView",gameData)

    local gameListener = {}
    gameListener.onGameOver = function(gameResultData)
        dump(gameResultData,"gameResultData---------")
    end

    gameView:setGameListener(gameListener)
]]

local GameBaseView = require("game.sys.view.game.GameBaseView")
local GameGuessMeView = class("GameGuessMeView", GameBaseView);

function GameGuessMeView:ctor(winName,gameData)
    GameGuessMeView.super.ctor(self, winName,gameData)
end

function GameGuessMeView:loadUIComplete()
	GameGuessMeView.super.loadUIComplete(self)

	-- 初始化为准备阶段，点击开始按钮后才开始游戏
	self:updateGameStatus(self.GAME_STATUS.START)
end 

function GameGuessMeView:registerEvent()
	GameGuessMeView.super.registerEvent(self);
	self.UI_1.btn_close:setTap(c_func(self.onCloseClick,self))
end

function GameGuessMeView:initGameView()
	-- 隐藏掉无用的UI
	self.UI_1.mc_1:setVisible(false)

	-- 猜猜我是谁
	local titleName = GameConfig.getLanguage("tid_game_201")
	self.UI_1.txt_1:setString(titleName)

	-- 描述文本
	local gameDes = GameConfig.getLanguage("tid_game_202")
	self.txt_1:setString(gameDes)
end

--[[
	子类重写initData
]]
function GameGuessMeView:initGameData()
	GameGuessMeView.super.initGameData(self);

	self.oneGroupPartnerNum = 4

	-- 配表中的ID
	self.gameId = self.gameData.gameId
	self.gameDataCfg = FuncGame.getGuessMeDataById(self.gameId)
	-- 奇侠库
	self.riddlerPartnerArr = self.gameDataCfg.riddler_partner

	self.usedPartnerList = {}
	self.unsedPartnerList = table.copy(self.riddlerPartnerArr)

	self:refreshGameData()
end

--[[
	当游戏开始
]]
function GameGuessMeView:onGameStart()
	-- 更新头像
	for i=1,#self.partnerArr do
		self["panel_dui"..i]:setVisible(false)
		self["panel_cuo"..i]:setVisible(false)

		local partnerId = self.partnerArr[i]
		-- 奇侠头像
		local spriteIcon = FuncPartner.getPartnerIconByIdAndSkin(partnerId,"")

		local panel = self["panel_"..i]
		local ctn = panel.ctn_1
		ctn:removeAllChildren()
		ctn:addChild(spriteIcon)

		panel:setTouchedFunc(c_func(self.onClickHeadIcon,self,i))

		local partnerName = FuncPartner.getPartnerName(partnerId)
		panel.txt_1:setString(partnerName)
	end

	local targetPartnerId = self.targetPartnerId
	local souceId = FuncPartner.getSourceId(targetPartnerId)
	-- spine动画
	local sourceData = FuncTreasure.getSourceDataById(souceId)
    local spine = FuncRes.getSpineViewBySourceId(souceId,nil,true,sourceData) 

    self.partnerSpine = spine
    self.ctn_1:removeAllChildren()
    self.ctn_1:addChild(spine)
    FilterTools.setViewFilter(spine,FilterTools.colorTransform_lowLight3)
end

function GameGuessMeView:onClickHeadIcon(index)
	self.selectIndex = index
	
	local rt = self.GAME_RESULT.FAIL
	if self.correctIndex == self.selectIndex then
		rt = self.GAME_RESULT.WIN
	end

	self.gameResult = rt
	self.gameResultData = {
		rt = rt
	}

	self:updateGameStatus(self.GAME_STATUS.OVER_SHOW)
end

--[[
	当游戏结束表现阶段
]]
function GameGuessMeView:onGameOverShow()
	self:disabledUIClick()
	FilterTools.clearFilter(self.partnerSpine)

	for i=1,#self.partnerArr do
		self["panel_dui"..i]:setVisible(false)
		self["panel_cuo"..i]:setVisible(false)
	end

	-- 更新头像
	if self.gameResult == self.GAME_RESULT.WIN then
		self["panel_dui"..self.selectIndex]:setVisible(true)
	elseif self.gameResult == self.GAME_RESULT.FAIL then
		self["panel_cuo"..self.selectIndex]:setVisible(true)
		self["panel_dui"..self.correctIndex]:setVisible(true)
	end

	-- 游戏结束
	local callBack = function()
		self:updateGameStatus(self.GAME_STATUS.OVER)
	end
	-- 游戏正式结束
	self:delayCall(c_func(callBack),1.2)
end

--[[
	当游戏结束，返回的数据结构:
	gameResultData = {
		rt = self.gameResult,
    }
]]
function GameGuessMeView:onGameOver()
	self:resumeUIClick()

	if self.gameResult == self.GAME_RESULT.WIN then
		GameGuessMeView.super.onGameOver(self)
		self:startHide()
	elseif self.gameResult == self.GAME_RESULT.HANDOUT then
		GameGuessMeView.super.onGameOver(self)
		self:startHide()
	else
		self:updateGameStatus(self.GAME_STATUS.RESTART)
	end
end

--[[
	重启游戏
]]
function GameGuessMeView:onGameRestart()
	self:refreshGameData()
	self:updateGameStatus(self.GAME_STATUS.START)
end

--[[
	刷新一次游戏的数据
]]
function GameGuessMeView:refreshGameData()
	if #self.unsedPartnerList < self.oneGroupPartnerNum then
		self.usedPartnerList = {}
		self.unsedPartnerList = table.copy(self.riddlerPartnerArr)
	end

	self.partnerArr = self:randomOneGroupPartners()

	-- 正确的奇侠index
	self.correctIndex = math.random(1,#self.partnerArr)

	local targetPartnerId = self.partnerArr[self.correctIndex]
	self.targetPartnerId = targetPartnerId

	self.usedPartnerList[#self.usedPartnerList+1] = targetPartnerId
	table.removebyvalue(self.unsedPartnerList,targetPartnerId)
end

function GameGuessMeView:randomOneGroupPartners()
	-- 备选奇侠
	local partnerArr = RandomControl.getNumsByGroup(self.unsedPartnerList
		,self.oneGroupPartnerNum)

	return partnerArr
end

-- 点关闭
function GameGuessMeView:onCloseClick()
	self.gameResult = FuncGame.GAME_RESULT.HANDOUT
	self.gameResultData = {
		rt = FuncGame.GAME_RESULT.HANDOUT,
	}
	self:updateGameStatus(self.GAME_STATUS.OVER)
end

-- 屏蔽关闭
function GameGuessMeView:hideCloseBtn()
	self.UI_1.btn_close:visible(false)
end

return GameGuessMeView;

