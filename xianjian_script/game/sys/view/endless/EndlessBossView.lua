--[[
	Author: TODO
	Date:2018-01-19
	Description: TODO
]]

local EndlessBossView = class("EndlessBossView", UIBase);

function EndlessBossView:ctor(winName)
    EndlessBossView.super.ctor(self, winName)
end

function EndlessBossView:loadUIComplete()
	self:registerEvent()
	-- self:initData()
	-- self:initViewAlign()
	-- self:initView()
	-- self:updateUI()
end 

function EndlessBossView:registerEvent()
	EndlessBossView.super.registerEvent(self);
	-- EventControler:addEventListener(EndlessEvent.ENDLESS_DATA_CHANGED, self.updateUI, self)
	-- self:registClickClose("out")
	EventControler:addEventListener(EndlessEvent.CLOSE_BOSS_DETAIL_VIEW, self.removeClickAnim, self)
end

function EndlessBossView:initData()
	
end

function EndlessBossView:initView()
	
end

function EndlessBossView:initViewAlign()
	-- TODO
end

function EndlessBossView:setBossId(_endlessId)
	self.endlessId = _endlessId
	--获取通过该关卡的好友和盟友数据
	local fastDatas = EndlessModel:getTheFastData()
	local curEndlessDatas = {}
	for i,v in ipairs(fastDatas) do
		if v.endlessId == self.endlessId then
			table.insert(curEndlessDatas, v)
		end
	end
	--按照通关时间排序
	local sortFunc = function (a, b)
		return a.endlessTime < b.endlessTime
	end
	table.sort(curEndlessDatas, sortFunc)
	--获取最快的通关数据
	if #curEndlessDatas > 0 then
		self.fastData = curEndlessDatas[1]
	else
		self.fastData = nil
	end
end

function EndlessBossView:updateUI()
	local panel = self.panel_gouri
	--添加一个node用于添加点击事件  
	local node = display.newNode()
	node:anchor(0.5, 0)
	node:setContentSize(cc.size(150, 180))
	node:addto(self.panel_gouri.ctn_anim)
	node:setTouchedFunc(c_func(self.showBossDetailView, self, self.endlessId))
	self.endlessData = FuncEndless.getLevelDataById(self.endlessId)

	local status = EndlessModel:getStatusByEndlessId(self.endlessId)
	local spineId, scale = FuncEndless.getSpineIdAndScaleByEndlessId(self.endlessId)
	local sourceCfg = FuncTreasure.getSourceDataById(spineId)	
	-- local spineName = sourceCfg.spine
	-- local spineAction = sourceCfg.stand

	local spineView = FuncRes.getSpineViewBySourceId(spineId,nil,false,sourceCfg)
	spineView:addto(panel.panel_bao.ctn_anim)
	local orientation = FuncEndless.getSpineOrientationsByEndlessId(self.endlessId)
	spineView:setScale(scale)
	-- spineView:playLabel(spineAction, true)
	
	if orientation == FuncEndless.Orientations.LEFT then
		spineView:setRotationSkewY(180)
	else
		spineView:setRotationSkewY(0)
	end
	local spineWidth = sourceCfg.viewSize[1] * scale
	local spineHight = sourceCfg.viewSize[2] * scale
	if status == FuncEndless.endlessStatus.NOT_PASS then
		self.mc_star:setVisible(false)
	else
		self.mc_star:setVisible(true)
		self.mc_star:showFrame(3)
		local starPanel = self.mc_star.currentView
		--三星显示完美通关动画  一、二星显示非完美通关特效
		if status == FuncEndless.endlessStatus.THREE_STAR then
			starPanel.mc_1:showFrame(1)
			starPanel.mc_2:showFrame(1)
			starPanel.mc_3:showFrame(1)
		elseif status == FuncEndless.endlessStatus.TWO_STAR then
			starPanel.mc_1:showFrame(1)
			starPanel.mc_2:showFrame(1)
			starPanel.mc_3:showFrame(2)
		else
			starPanel.mc_1:showFrame(1)
			starPanel.mc_2:showFrame(2)
			starPanel.mc_3:showFrame(2)
		end
	end

	panel.mc_jian:setVisible(false)
end

--加载头像以及头像框
function EndlessBossView:updateHeadAndFrame(ctn, avatar, head, frame)
    local iconid = FuncUserHead.getHeadIcon(head, avatar)
    local icon = FuncRes.iconHero(iconid)
    local iconSprite = display.newSprite(icon)
    local frame = frame or ""
    local frameicon = FuncUserHead.getHeadFramIcon(frame)
    local iconK = FuncRes.iconHero(frameicon)
    local frameSprite = display.newSprite(iconK)
    local headMaskSprite = display.newSprite(FuncRes.iconOther("partner_bagmask"))
    headMaskSprite:anchor(0.5,0.5)
    headMaskSprite:pos(0,0)
    local spriteIcon = FuncCommUI.getMaskCan(headMaskSprite, iconSprite)
    spriteIcon:setScale(1.2)
    frameSprite:setScale(1.2)
    ctn:addChild(spriteIcon)
    ctn:addChild(frameSprite)
end

function EndlessBossView:showPlayerInfo(_playerId, playerInfo)
	FriendViewControler:showPlayer(_playerId, playerInfo)
end

--点击显示详情界面
function EndlessBossView:showBossDetailView(_bossId)
	local _floorId = FuncEndless.getFloorAndSectionById(self.endlessId)
	local floorCfg = FuncEndless.getFloorDataById(_floorId)
	local armatureName = FuncEndless.clickAnimName[floorCfg.land]
	self.panel_gouri.ctn_click:removeAllChildren()
	self.clickAnim = self:createUIArmature("UI_guankaxuanzhong", armatureName, self.panel_gouri.ctn_click, true)
	local pos = FuncEndless.clickAnimPos[floorCfg.land]
	self.clickAnim:pos(pos.x, pos.y)
	EventControler:dispatchEvent(EndlessEvent.OPEN_ONE_DETAIL_VIEW, {endlessId = _bossId})
end

function EndlessBossView:removeClickAnim()
	if self.clickAnim then
		self.panel_gouri.ctn_click:removeAllChildren()
	end
end

function EndlessBossView:deleteMe()
	-- TODO

	EndlessBossView.super.deleteMe(self);
end

return EndlessBossView;
