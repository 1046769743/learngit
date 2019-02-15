--[[
	Author: TODO
	Date:2018-01-19
	Description: TODO
]]

local EndlessFloorBaseView = class("EndlessFloorBaseView", UIBase);

function EndlessFloorBaseView:ctor(winName, _floorId)
    EndlessFloorBaseView.super.ctor(self, winName)
    -- self.floorId = EndlessModel:getHistoryEndlessFloorAndSection()
    self.floorId = _floorId
end

function EndlessFloorBaseView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function EndlessFloorBaseView:registerEvent()
	EndlessFloorBaseView.super.registerEvent(self);
	-- EventControler:addEventListener(EndlessEvent.ENDLESS_DATA_CHANGED, self.updateUI, self)
end

function EndlessFloorBaseView:initData()
	self.initFloor = EndlessModel:getInitFloor()
end

function EndlessFloorBaseView:initView()
	
end

function EndlessFloorBaseView:initViewAlign()
	-- TODO
end

function EndlessFloorBaseView:updateUI()
	self.panel_zhu1:setVisible(false)
	self.panel_zhu2:setVisible(false)
	--第一重和最后一重需要特殊处理
	if self.floorId == 1 then
		-- local bgRight = display.newSprite(FuncRes.iconBg("wdsy_bg_02.png"))
		-- bgRight:addto(self.ctn_land)
		-- bgRight:pos(1136, 0)
		local landSprite1 = display.newSprite(FuncRes.iconBg("endless_bg_01.png"))
		landSprite1:addto(self.ctn_land)
		landSprite1:pos(1136, 0)
	elseif self.floorId == 60 then
		-- local bgLeft = display.newSprite(FuncRes.iconBg("wdsy_bg_01.png"))
		-- bgLeft:addto(self.ctn_land)
		-- bgLeft:pos(-1136, 0)
		local landSprite2 = display.newSprite(FuncRes.iconBg("endless_bg_01.png"))
		landSprite2:addto(self.ctn_land)
		landSprite2:pos(-1136, 0)	
	end
	
	--通过配表来控制每一层显示什么背景和land
	-- local bgPath = FuncRes.iconBg(FuncEndless.getFloorBgById(self.floorId))
	-- local bgSprite = display.newSprite(bgPath)
	-- bgSprite:addto(self.ctn_land)
	local landPath = FuncRes.iconBg(FuncEndless.getFloorLandById(self.floorId))
	local landSprite = display.newSprite(landPath)
	landSprite:addto(self.ctn_land)
	-- self:delayCall(c_func(self.updateCharSpine, self), 0.5)
	self.UI_xg1:setVisible(false)	
	if self.initFloor == self.floorId then
		self:updateSpine()
	else
		self:delayCall(c_func(self.updateSpine, self), 0.5)
	end
	
end

function EndlessFloorBaseView:updateSpine()
	--测试position
	-- local position = {
	-- 	{x = 730, y = -390},
	-- 	{x = 820, y = -160},
	-- 	{x = 500, y = -57},
	-- 	{x = 168, y = -185},
	-- 	{x = 395, y = -310}
	-- }
	self.bossIds = FuncEndless.getBossIdsByFloorId(self.floorId)
	self.bossNum = #self.bossIds
	for i = 1, self.bossNum, 1 do		
		local bossView = UIBaseDef:cloneOneView(self.UI_xg1)
		local pos = FuncEndless.getBossPositionByEndlessId(self.bossIds[i])
		bossView:addto(self._root)
		bossView:pos(tonumber(pos[1]), tonumber(pos[2]))
		bossView:setBossId(self.bossIds[i])
		bossView:setVisible(false)
		-- bossView:setVisible(true)
		local updateFunc = function (bossView)
			bossView:updateUI()
			bossView:setVisible(true)
		end 
		self:delayCall(c_func(updateFunc, bossView), 0.1 * i)
	end 
end

function EndlessFloorBaseView:setEndlessLand()
	
end

function EndlessFloorBaseView:deleteMe()
	-- TODO

	EndlessFloorBaseView.super.deleteMe(self);
end

return EndlessFloorBaseView;
