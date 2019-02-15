--[[
	Author: TODO
	Date:2018-05-15
	Description: TODO
]]

local WuXingLookOverView = class("WuXingLookOverView", UIBase);

function WuXingLookOverView:ctor(winName, _levelId, _secondLevelId, params)
    WuXingLookOverView.super.ctor(self, winName)
    self.levelId = _levelId
    self.secondLevelId = _secondLevelId
    self.params = params
end

function WuXingLookOverView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function WuXingLookOverView:registerEvent()
	WuXingLookOverView.super.registerEvent(self);

	local coverLayer = WindowControler:createCoverLayer(nil, nil, cc.c4b(0,0,0,0), false):addto(self.ctn_bg, 0)
    coverLayer:pos(-GameVars.width / 2,  GameVars.height / 2)
    -- coverLayer:setTouchedFunc(c_func(self.needHideDetailView, self))
    coverLayer:setTouchSwallowEnabled(true)
    self.ctn_bg:zorder(-1)
    
	self.btn_fanhuibuzhen:setTouchedFunc(c_func(self.hideLookOverView, self))
	self.btn_topback:setTouchedFunc(c_func(self.closeTeamView, self))
end

function WuXingLookOverView:hideLookOverView()
	EventControler:dispatchEvent(TeamFormationEvent.CLOSE_LOOK_OVER_VIEW)
end

function WuXingLookOverView:closeTeamView()
	EventControler:dispatchEvent(TeamFormationEvent.CLICK_LOOKOVER_BACK_EVENT)
end

function WuXingLookOverView:setElementVisible(isVisible)
	self.btn_fanhuibuzhen:setVisible(isVisible)
	self.btn_topback:setVisible(isVisible)
	-- self.UI_backhome:setVisible(isVisible)
	self.panel_title:setVisible(isVisible)
end

function WuXingLookOverView:initData()
	self.mc_zhenwei:setVisible(false)
	self.panel_1:setVisible(false)
	if self.levelId and not self.secondLevelId then
		local levelData = FuncTeamFormation.getLevelDataByLevelId(self.levelId)
		local waves = table.length(levelData)
		self.mc_zhenwei:showFrame(waves)
		if waves == 1 then
			self.mc_zhenwei.currentView.UI_1:updateEnemyView(levelData["1"])
			self.mc_zhenwei.currentView.panel_power:setVisible(false)
		else
			self.mc_zhenwei.currentView.UI_1:updateEnemyView(levelData["1"])
			self.mc_zhenwei.currentView.UI_2:updateEnemyView(levelData["2"])
			self.mc_zhenwei.currentView.panel_power1:setVisible(false)
			self.mc_zhenwei.currentView.panel_power2:setVisible(false)
		end
		self.mc_zhenwei:setVisible(true)
	elseif self.levelId and self.secondLevelId then
		local levelData1 = FuncTeamFormation.getLevelDataByLevelId(self.levelId)
		local levelData2 = FuncTeamFormation.getLevelDataByLevelId(self.secondLevelId)
		self.mc_zhenwei:showFrame(2)
		self.mc_zhenwei.currentView.UI_1:updateEnemyView(levelData1["1"])
		self.mc_zhenwei.currentView.UI_2:updateEnemyView(levelData2["1"])
		self.mc_zhenwei.currentView.panel_power1:setVisible(false)
		self.mc_zhenwei.currentView.panel_power2:setVisible(false)
		self.mc_zhenwei:setVisible(true)
	elseif self.params then
		self.mc_zhenwei:showFrame(1)
		self.mc_zhenwei.currentView.panel_power:setVisible(false)
		if self.params.isPvpAttack then
			if self.params.isRobot then			
				self.mc_zhenwei.currentView.UI_1:updateEnemyView(nil, self.params)
				self.mc_zhenwei:setVisible(true)
			else
				PVPServer:requestPlayerDetail(self.params.rid, c_func(self.onPlayerDetailView,self))
			end
		elseif self.params.isMissionPvp then
			self.mc_zhenwei.currentView.UI_1:updateEnemyView(nil, self.params)
			self.mc_zhenwei:setVisible(true)
		end					
	end
end

function WuXingLookOverView:onPlayerDetailView(_event)
	if _event.result ~= nil then
        local _playerInfo = _event.result.data
        _playerInfo.rank = self.params.rank --将排名数据增加进去,后面要用到
        _playerInfo.ability = self.params.ability
        _playerInfo.rid_back = self.params.rid
        _playerInfo.name = self.params.name ~= "" and  self.params.name or FuncCommon.getPlayerDefaultName()
        _playerInfo.types  = self.params.type
        _playerInfo.star = self.params.star
        _playerInfo.isPvpAttack = true
        self.mc_zhenwei.currentView.UI_1:updateEnemyView(nil, _playerInfo)
		self.mc_zhenwei:setVisible(true)
    end
end

function WuXingLookOverView:initView()
	self.topItems = {self.btn_topback, self.panel_title}
	self.moveOffsetX = 300
    self.moveOffsetY = 300
    for i,v in ipairs(self.topItems) do
    	v:runAction(act.moveby(0, 0, self.moveOffsetY))
    end
    local x, y = self.__bgView:getPosition()
    self.__bgView:setScaleX(-1)
    self.__bgView:pos(GameVars.gameResWidth - x, y)
end

function WuXingLookOverView:moveBackItemsView(_isVisible)
	local setVisibleFunc = function (_view, isVisible)
        _view:setVisible(isVisible)
    end

	for i, v in ipairs(self.topItems) do
		v:runAction(act.sequence(act.callfunc(c_func(setVisibleFunc, v, _isVisible)), act.moveby(0.2, 0, -self.moveOffsetY)))
	end
	self:delayCall(function ()
	            self.btn_fanhuibuzhen:setVisible(_isVisible)
	        end, 0.2)
	
end

function WuXingLookOverView:moveOutItemsView(_isVisible)
	local setVisibleFunc = function (_view, isVisible)
        _view:setVisible(isVisible)
    end

	for i, v in ipairs(self.topItems) do
		v:runAction(act.sequence(act.moveby(0.2, 0, self.moveOffsetY), act.callfunc(c_func(setVisibleFunc, v, _isVisible))))
	end
	self.btn_fanhuibuzhen:setVisible(_isVisible)
end


function WuXingLookOverView:initViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.btn_fanhuibuzhen, UIAlignTypes.Right)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.btn_topback, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_1, UIAlignTypes.MiddleTop)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset, self.txt_chakandiqing, UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_title, UIAlignTypes.LeftTop)	
	-- FuncCommUI.setViewAlign(self.widthScreenOffset, self.UI_backhome, UIAlignTypes.LeftTop)
end

function WuXingLookOverView:updateUI()
	-- TODO
end

function WuXingLookOverView:deleteMe()
	-- TODO

	WuXingLookOverView.super.deleteMe(self);
end

return WuXingLookOverView;
