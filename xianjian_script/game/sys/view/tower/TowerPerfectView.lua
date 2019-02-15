--[[
	Author: caocheng
	Date:2017-09-29
	Description:  完美通关动画
]]

local TowerPerfectView = class("TowerPerfectView", UIBase);

function TowerPerfectView:ctor(winName)
    TowerPerfectView.super.ctor(self, winName)
end

function TowerPerfectView:loadUIComplete()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:registerEvent()
	self:updateUI()
end 

function TowerPerfectView:registerEvent()
	TowerPerfectView.super.registerEvent(self);
	self:registClickClose("out",c_func(self.closeView,self))
end

function TowerPerfectView:initData()
	local curFloor = TowerMainModel:getCurrentFloor() or "1"
	local rewardId = FuncTower.getPerfectPassReward(curFloor)
	self.rewardData = TowerMainModel:getPerfactReward() 
	if not self.rewardData or table.length(self.rewardData) == 0 then
		self.rewardData =  {
	        "30,1000,1",
	        "3,100000,1",
	        "1,5023,10,1",
	    }
	end
	TowerMainModel:savePerfactReward(nil)
end

function TowerPerfectView:initView()
	dump(self.rewardData, "完美通关奖励 === self.rewardData")
	local numOfReward = #self.rewardData
	echo("_____numOfReward_____________",numOfReward)
	if numOfReward == 0 then
		echoError("奖品数据为空numOfReward=",numOfReward)
		return
	end

	self.mc_11:showFrame(numOfReward)
	self.txt_1:setString(GameConfig.getLanguage("tid_tower_ui_102"))
	self.txt_1:opacity(0)
	local currentView = self.mc_11:getCurFrameView()
	for i=1,numOfReward do
		currentView["panel_"..i].UI_1:visible(false)
	end
	-- 创建spine动画
	local spineName = "UI_wanmeitongguan"
	local bossView = ViewSpine.new(spineName, {}, spineName.."export"):addto(self.ctn_1)
	bossView:anchor(0.5,0.5)
	bossView:pos(0,-GameVars.gameResHeight/6)
	bossView:playLabel("UI_wanmeitongguan_chuxian", false)

	local _delayFrame = bossView:getLabelFrames("UI_wanmeitongguan_chuxian" )
	local function playXunHuan()
		bossView:playLabel("UI_wanmeitongguan_xunhuan", true)
	end
	self:delayCall(c_func(playXunHuan), _delayFrame/GameVars.GAMEFRAMERATE)

	local function delayShowReward()
		local i = 0
		for k,v in pairs(self.rewardData) do
			i = i + 1
			local rewardData = {}
			rewardData.reward = v

			local function delayShowOneReward( _currentView,index,_reward )
				_currentView["panel_"..index]:visible(true)
				self:createAniFunc(_currentView["panel_"..index],_reward)
				-- _currentView["panel_"..index]:visible(true)
				-- _currentView["panel_"..index].UI_1:setRewardItemData(rewardData)
			end
			self:delayCall(c_func(delayShowOneReward,currentView,i,v), (8*(i)/GameVars.GAMEFRAMERATE))
		end

		local function delayShowOneTxt(_view)
			local secTime = 2
			local act = cc.Sequence:create(act.fadein(secTime))
			_view:runAction(act)
			_view:setTouchedFunc(c_func(self.closeView,self))
		end
		self:delayCall(c_func(delayShowOneTxt,self.txt_1), (8*(i+1)/GameVars.GAMEFRAMERATE))
	end
	self:delayCall(c_func(delayShowReward), 45/GameVars.GAMEFRAMERATE)
end

function TowerPerfectView:createAniFunc(_itemView,_reward)
    local view = _itemView
    view.showAni = self:createUIArmature("UI_zhandoujiesuan","UI_zhandoujiesuan_chutubiao",view.ctn_1, false, GameVars.emptyFunc)    
    local itemNode = view.UI_1
    itemNode:visible(true):pos(5,-5)
    local rwd = {reward = _reward}
    itemNode:setRewardItemData(rwd)
    FuncArmature.changeBoneDisplay(view.showAni,"node1",itemNode)
    local needNum, hasNum, isEnough, resType, resId = UserModel:getResInfo(rwd.reward)
    FuncCommUI.regesitShowResView(itemNode, resType, needNum, resId, rwd.reward, true, true)
    itemNode:setTouchSwallowEnabled(true)
end

function TowerPerfectView:initViewAlign()
	-- TODO
end

function TowerPerfectView:updateUI()
	-- TODO
end

function TowerPerfectView:closeView()
	EventControler:dispatchEvent(TowerEvent.TOWEREVENT_AUTO_OPEN_LEFT_GRIDS)
	self:startHide()
end

function TowerPerfectView:deleteMe()
	-- TODO

	TowerPerfectView.super.deleteMe(self);
end

return TowerPerfectView;
