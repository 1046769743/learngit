--[[
    Author: 张燕广
    Date:2017-10-25
    Description: 公会小游戏小怪类
]]

local GuildMoveModel = require("game.sys.view.guildActivity.model.GuildMoveModel")
GuildMonsterModel = class("GuildMonsterModel",GuildMoveModel)

function GuildMonsterModel:ctor(controler,params)
	GuildMonsterModel.super.ctor(self,controler)
	self.index = params.index
	self.monsterId = params.monsterId
end

function GuildMonsterModel:initView(...)
	GuildMonsterModel.super.initView(self,...)
	self:setClickFunc()
end

function GuildMonsterModel:setIndex( _index )
	self.index = _index
end
function GuildMonsterModel:initFlag()
	self.panelList = self.controler.map:getCachePanel()
	-- 初始化绿色小标
	self.markView = UIBaseDef:cloneOneView(self.panelList[1].panel_da)
    self.markView:anchor(0.5,0.5)
    self.markView:pos(20,110)
    self.markView:scale(0.7)
    self.markView:parent(self.frontCtn)
    --dump(GuildActMainModel.markArr, "\n\n_______ GuildActMainModel.markArr ____")
    if GuildActMainModel.markArr[self.index] then
    	-- echo("____ 初始化 设置绿色小标可见 ______")
		self.markView:setVisible(true)
	else
    	-- echo("____ 初始化 设置绿色小标 不不不 可见 ______")
		self.markView:setVisible(false)
	end
	-- 初始化点击弹出面板
	self.flagmcView = UIBaseDef:cloneOneView(self.panelList[1].mc_liangzhen)
    self.flagmcView:anchor(0.5,0.5)
    self.flagmcView:pos(0,160)
    self.flagmcView:scale(0.7)
    self.flagmcView:parent(self.frontCtn)
	self.flagmcView:setVisible(false)

	-- 初始化非食材怪弹出气泡
	local monsterType = FuncGuildActivity.getMonsterTypeByMonsterId( self.monsterId )
	if monsterType ~= FuncGuildActivity.monsterType.food then
		self.bubbleView = UIBaseDef:cloneOneView(self.panelList[3])
		self.bubbleView:parent(self.frontCtn,1000)
    	self.bubbleView:pos(0,100)
		self:popUpBubble(self.bubbleView)
	end

	-- 显示怪名字
	self.txt_monsterName = UIBaseDef:cloneOneView(self.panelList[5])
	self.txt_monsterName:parent(self.frontCtn)
	self.txt_monsterName:pos(-20,20)
	if self.monsterId then
		local monsterData = ObjectCommon.getPrototypeData( "level.EnemyInfo",self.monsterId )
		local monsterName = GameConfig.getLanguage(monsterData.name)
		self.txt_monsterName:visible(true)
		self.txt_monsterName:setString(monsterName)
	end
end

-- 弹出怪物对话气泡
function GuildMonsterModel:popUpBubble(_view)
	-- local delaytime_1 = act.delaytime(0.2)
	local scaleto_1 = act.scaleto(0.1,1.2,1.2)
	local scaleto_2 = act.scaleto(0.05,1.0,1.0)
	local delaytime_2 = act.delaytime(5)
 	local scaleto_3 = act.scaleto(0.1,0)
 	local delaytime_3 = act.delaytime(2)
 	local callfun = act.callfunc(function ()
 		self:changeBubbleWords(_view)
 	end)
	local seqAct = act.sequence(act.spawn(callfun,scaleto_1),scaleto_2,delaytime_2,scaleto_3,delaytime_3)
	self.bubbleView:runAction(act._repeat(seqAct))
end

function GuildMonsterModel:changeBubbleWords(_view)
	if not self.monsterId then
		if _view then
			_view:visible(false)
			return
		end
	else
		local words = FuncGuildActivity.getMonsterBubbleByMonsterId( self.monsterId )
		words = GameConfig.getLanguage(words)
		self.bubbleView.rich_1:setString(words)
	end
end

-- 更新显示绿色小标
function GuildMonsterModel:updateFlag( _isMark )
	if self.markView then
		echo("_________ 设置绿色小标可见否",_isMark)		
		self.markView:setVisible(_isMark)
	end
	self.isShowingMarkFlag = _isMark
end
function GuildMonsterModel:updateClickFlag( _isMark )
	if self.flagmcView then
		self.flagmcView:setVisible(_isMark)
	end
end
--给怪注册点击事件
function GuildMonsterModel:setClickFunc( )
	local nd = display.newNode()
	
	local size = self:getContentSize()
    nd:setContentSize(size)
    nd:pos(-size.width/2,0)
	
	nd:addto(self.myView,1)
	nd:setTouchSwallowEnabled(true)
	nd:setTouchedFunc(c_func(self.onClickMonster,self),nil,true)
end
function GuildMonsterModel:onClickMonster()
	echo("—————————————————— 点击怪 self.index __________ ",self.index)
	self.controler:setOneMonsterSelected( self.index )
	self:showFlag(self.index)
end
function GuildMonsterModel:showFlag(_gridIdx)
	-- if self.bubbleView then
	-- 	self.bubbleView:stopAction()
	-- end
	
	local curRound = GuildActMainModel:getChallengeRound()
	if GuildActMainModel.frozenRid == UserModel:rid() then
		return
	end
	-- 最后一轮怪不能选中战斗
	if not curRound then  
		WindowControler:showTips(GameConfig.getLanguage("#tid_guild_089"))
		return 
	end
	local cdName = GuildActMainModel.eventName_oneRoundTimer..curRound
	local leftTime = TimeControler:getCdLeftime(cdName)
	local configTime = FuncDataSetting.getOneAccountTime()
	if leftTime>configTime then
		WindowControler:showTips(GameConfig.getLanguage("#tid_guild_090"))
		return 
	end
	if GuildActMainModel:getIsInCombo() == true then
		echo("-- 碰撞中不能打怪")
		return 
	end

	self.flagmcView:setVisible(true)
	if not GuildActMainModel.markArr[_gridIdx] and not self.isShowingMarkFlag then
		self.flagmcView:showFrame(2)
		flagView = self.flagmcView:getCurFrameView()
		flagView.panel_2:setTouchSwallowEnabled(true)
	    flagView.panel_2.btn_1:setTap(function()
	    	echo("开打")
	    	GuildActMainModel:goTeamFormationView()
	    	GuildActMainModel:setCurChooseMonsterGridIndex( _gridIdx )
	    	local pos = self.controler.map:getMapPos()
	        GuildActMainModel:saveMapPos(pos)
	    	self.flagmcView:setVisible(false)
	    end)
	    flagView.panel_2.btn_2:setTap(function()
	    	echo("队友来打")
	    	self.round = GuildActMainModel:getChallengeRound()
	    	if GuildActMainModel:isInNewGuide() then
	    		self:updateFlag( true )
	    	else
	    		GuildActMainModel:markMonster(_gridIdx)
	    	end
	    	self.flagmcView:setVisible(false)
	    end)
	else
		self.flagmcView:showFrame(1)
		flagView = self.flagmcView:getCurFrameView()
		flagView.panel_1:setTouchSwallowEnabled(true)
	    flagView.panel_1.btn_1:setTap(function()
	    	echo("打")
	    	GuildActMainModel:goTeamFormationView()
	    	GuildActMainModel:setCurChooseMonsterGridIndex( _gridIdx )
	    	self.flagmcView:setVisible(false)
	    end)
	    flagView.panel_1.btn_2:setTap(function()
	    	echo("取消")
	    	if GuildActMainModel:isInNewGuide() then
	    		self:updateFlag( false )
	    	else
	    		self.round = GuildActMainModel:getChallengeRound()
	    		GuildActMainModel:markMonsterCancel(_gridIdx)
	    	end
	    	self.flagmcView:setVisible(false)
	    end)
	end
end

-- 移动到下一个格子
function GuildMonsterModel:moveToNextGrid( _nextGridPosition )
	self:moveToPoint(_nextGridPosition)
end


function GuildMonsterModel:deleteMe()
	self.monsterId = nil
	self._myTeamId = nil
	self.round = nil
	self:updateFlag( false )
	self:updateClickFlag( false )

	if self.frontCtn then
		self.frontCtn:removeAllChildren()
	end
	-- self.flagmcView = nil
	-- self.markView = nil
	-- self.bubbleView = nil
	-- self.txt_monsterName = nil

	-- if self.bubbleView then
	-- 	self.bubbleView:visible(false)
	-- end
	-- if self.txt_monsterName then
	-- 	self.txt_monsterName:visible(false)
	-- end
    GuildMonsterModel.super.deleteMe(self)
end

-- 重写父类移动函数
function GuildMonsterModel:moveToPoint(targetPoint, speed,moveType )
    self.myView:playLabel("run")
	GuildMonsterModel.super.moveToPoint(self,targetPoint, speed,moveType)
end

-- 移动到点后停止跑动
function GuildMonsterModel:stopRuning( ... )
	if self.myView and not tolua.isnull(self.myView) then
    	self.myView:playLabel("stand")
	end
end

return GuildMonsterModel
