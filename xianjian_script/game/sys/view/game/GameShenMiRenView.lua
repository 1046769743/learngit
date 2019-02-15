--[[
	Author: 张燕广
	Date:2018-07-26
	Description: 神秘人小游戏——猜奇侠玩法

	使用示例:

	local gameData = {gameId = "1"}
    local gameView = WindowControler:showWindow("GameShenMiRenView",gameData)

    local gameListener = {}
    gameListener.onGameOver = function(gameResultData)
        dump(gameResultData,"gameResultData---------")
    end

    gameView:setGameListener(gameListener)
]]

local GameBaseView = require("game.sys.view.game.GameBaseView")

local GameShenMiRenView = class("GameShenMiRenView", GameBaseView);

function GameShenMiRenView:ctor(winName,gameData)
    GameShenMiRenView.super.ctor(self, winName,gameData)
end

function GameShenMiRenView:loadUIComplete()
	GameShenMiRenView.super.loadUIComplete(self)

	-- 初始化为准备阶段，点击开始按钮后才开始游戏
	self:updateGameStatus(self.GAME_STATUS.PREPARE)
end 

function GameShenMiRenView:registerEvent()
	GameShenMiRenView.super.registerEvent(self);

	self.UI_1.btn_close:setTap(c_func(self.startHide,self))
end

--[[
	子类重写initData
]]
function GameShenMiRenView:initGameData()
	GameShenMiRenView.super.initGameData(self);
	
	-- 配表中的ID
	self.gameId = self.gameData.gameId
	self.gameDataCfg = FuncGame.getShenMiRenDataById(self.gameId)
	-- 备选奇侠
	self.partnerArr = RandomControl.getNumsByGroup(self.gameDataCfg.riddler_partner,3)
	-- 随机出的目标奇侠
	self.correctIndex = math.random(1,#self.partnerArr) 
	self.correctPartnerId = self.partnerArr[self.correctIndex]
	echo("正确伙伴 id_________",self.correctPartnerId)
	self.partnerData = FuncPartner.getPartnerById(self.correctPartnerId)

	-- 游戏时间
	self.gameTime = self.gameDataCfg.riddler_time[3]

	-- dump(self.gameDataCfg,"self.gameDataCfg-----------")

	-- 游戏失败等级
	self.gameFailGrade = 4
end

function GameShenMiRenView:initGameView()
	-- 隐藏掉无用的UI
	self.UI_1.mc_1:setVisible(false)

	local titleName = GameConfig.getLanguage("tid_game_100")
	self.UI_1.txt_1:setString(titleName)
end

function GameShenMiRenView:initViewAlign()
	
end

--[[
	当游戏准备
]]
function GameShenMiRenView:onGamePrepare()
	GameShenMiRenView.super.onGamePrepare(self)
	self.mc_btn:showFrame(1)

	-- 初始化npc图像
	local sprite = display.newSprite(FuncRes.iconGame(self.gameDataCfg.png))
	self.ctn_1:removeAllChildren()
	self.ctn_1:addChild(sprite)

	-- 初始化对话
	self:updateDialog(self.gameDataCfg.dialog[1])

	-- 点击开始游戏
	self.mc_btn.currentView.btn_1:setTap(function()
		self:updateGameStatus(self.GAME_STATUS.START)
	end)
end

function GameShenMiRenView:updateDialog(dialogTid)
	local dialogContent = GameConfig.getLanguage(dialogTid)
	self.panel_qipao.txt_1:setString(dialogContent)
end

--[[
	更新奇侠
]]
function GameShenMiRenView:updatePartners(gameResult,grade,selectedIndex,correctIndex)
	local btnContentView = self.mc_btn:getCurFrameView()
	for k,partnerId in pairs(self.partnerArr) do
		local partnerName = FuncPartner.getPartnerName(partnerId)
		
		btnContentView["panel_"..k].btn_1:setBtnStr(partnerName,"txt_1")
		btnContentView["panel_"..k].btn_1:setTap(function()
			self.selectedIndex = k
			self.costTime = TimeControler:getServerTime() - self.gameStarTime
			self.movingActNode:stopAllActions()
			self:updateGameStatus(self.GAME_STATUS.OVER_SHOW)
		end)

		if gameResult ~= nil then
			if gameResult == self.GAME_RESULT.WIN then
				if correctIndex == k then
					btnContentView["panel_"..k].mc_txt:visible(true)
					btnContentView["panel_"..k].mc_txt:showFrame(tonumber(grade))
				else
					btnContentView["panel_"..k].mc_txt:visible(false)
				end
			else
				-- 标记处正确的答案
				if correctIndex == k then
					btnContentView["panel_"..k].mc_txt:visible(true)
					btnContentView["panel_"..k].mc_txt:showFrame(5)
				elseif selectedIndex == k then
					-- 显示当前的错误选项
					btnContentView["panel_"..k].mc_txt:visible(true)
					btnContentView["panel_"..k].mc_txt:showFrame(tonumber(grade))
				else
					btnContentView["panel_"..k].mc_txt:visible(false)
				end
			end
		else
			btnContentView["panel_"..k].mc_txt:visible(false)
		end
	end
end

--[[
	当游戏开始
]]
function GameShenMiRenView:onGameStart()
	self.gameStarTime = TimeControler:getServerTime()
	local partnerContentView = self.mc_1:getCurFrameView()

	-- 奇侠头像
	local _spriteIcon = FuncPartner.getPartnerIconByIdAndSkin(self.correctPartnerId,"")
	local headMaskSprite = display.newSprite(FuncRes.iconOther("partner_bagmask"))
    headMaskSprite:anchor(0.5,0.5)
    headMaskSprite:pos(-1,0)
    headMaskSprite:setScale(0.99)
    _spriteIcon = FuncCommUI.getMaskCan(headMaskSprite,_spriteIcon)
    partnerContentView.UI_1.ctn_1:removeAllChildren()
    partnerContentView.UI_1.ctn_1:addChild(_spriteIcon)
    partnerContentView.UI_1.panel_lv:visible(false)
    partnerContentView.UI_1.mc_dou:visible(false)
    _spriteIcon:scale(1.2)

    -- 移动遮罩
	self.movingActNode = partnerContentView.panel_hei
	local actArr = {act.scaleto(self.gameTime,1,0)}
	local seqAct = act.sequence(unpack(actArr))
	self.movingActNode:runAction(seqAct)

	-- 更新按钮、显示奇侠名称
	self.mc_btn:showFrame(2)
	self:updatePartners()
end

--[[
	当游戏结束表现阶段
]]
function GameShenMiRenView:onGameOverShow()
	self:disabledUIClick()
	self.mc_btn:showFrame(2)
	-- 隐藏遮罩
	self.movingActNode:visible(false)

	-- 4 代表失败
	self.grade = self.gameFailGrade
	self.gameResult = self.GAME_RESULT.FAIL

	if tonumber(self.selectedIndex) == tonumber(self.correctIndex) then
		self:updateDialog(self.gameDataCfg.dialog[3])

		if self.costTime < (tonumber(self.gameDataCfg.riddler_time[1])) then
			self.grade = 1
		elseif self.costTime < (tonumber(self.gameDataCfg.riddler_time[2])) then
			self.grade = 2
		else
			self.grade = 3
		end

		self.gameResult = self.GAME_RESULT.WIN
	else
		self:updateDialog(self.gameDataCfg.dialog[4])
		self.grade = self.gameFailGrade
	end

	-- 更新奇侠
	self:updatePartners(self.gameResult,self.grade,self.selectedIndex,self.correctIndex)

	-- 游戏结束
	local callBack = function()
		self:updateGameStatus(self.GAME_STATUS.OVER)
	end
	-- 3秒后游戏正式结束
	self:delayCall(c_func(callBack),3)

	echo("______ 选中的,正确的 __________",self.selectedIndex,self.correctIndex,self.costTime)
end

--[[
	当游戏结束，返回的数据结构:
	gameResultData = {
		rt = self.gameResult,
		grade = self.grade,
		reward = reward
    }
]]
function GameShenMiRenView:onGameOver()
	self:resumeUIClick()
	-- 显示出完整奇侠
	self.mc_1:showFrame(2)
	-- 显示领取奖励按钮
	self.mc_btn:showFrame(3)

	local rewardArr = self.gameDataCfg.reward
	local reward = rewardArr[self.grade]
	
	-- 将奖励字符串转为对象
	local rewardObj = FuncCommUI.turnOneRewardStr(reward)

	local rewardUI = self.mc_1:getCurFrameView().UI_1
    rewardUI:visible(true)
    rewardUI:setResItemData({reward = rewardObj.str})
    rewardUI:showResItemName(false)
    FuncCommUI.regesitShowResView(rewardUI,rewardObj.type,rewardObj.num,rewardObj.id,rewardObj.str,true,true)

    -- 游戏结束
    local gameOverCallBack = function()
    	local gameResultData = {
    		rt = self.gameResult,
    		grade = self.grade,
    		reward = reward
    	}

    	self:setGameResultData(gameResultData)
    	GameShenMiRenView.super.onGameOver(self)

    	self:startHide()
	end

    self.mc_btn:getCurFrameView().btn_1:setTap(c_func(gameOverCallBack))
end

return GameShenMiRenView;
