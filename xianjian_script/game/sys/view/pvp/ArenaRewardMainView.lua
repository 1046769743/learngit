--[[
	Author: ZhangYanguang
	Date:2018-05-29
	Description: PVP奖励主界面
]]

local ArenaRewardMainView = class("ArenaRewardMainView", UIBase);

function ArenaRewardMainView:ctor(winName)
    ArenaRewardMainView.super.ctor(self, winName)
    self:initData()
end

function ArenaRewardMainView:initData()
	self.FUNC_TAG = {
		REWARD = 1, --奖励
		EXCHANGE = 2, --兑换
		RANK = 3,    --排名
	}

	self.tagNum = 3
	-- 默认设置
	self.curTag = self.FUNC_TAG.REWARD

	-- tag映射
	self.tagViewMap = {
		{
			viewName = "ArenaRewardScoreView",
			title = GameConfig.getLanguage("tid_pvp_tips_2000"),  --挑战奖励
			view = nil,
		},

		{
			viewName = "ArenaRankExchangeView",
			title = GameConfig.getLanguage("tid_pvp_tips_2001"),  --排名兑换
			view = nil,
		},

		{	viewName = "ArenaRewardRankView",
			title = GameConfig.getLanguage("tid_pvp_tips_2002"),  --排名奖励
			view = nil,
		},
	}
end

function ArenaRewardMainView:registerEvent()
	self.btn_back:setTap(c_func(self.startHide,self))
	-- 奖励
	self.panel_1.mc_yeqian1.currentView:setTouchedFunc(c_func(self.onClickTag,self
		,self.FUNC_TAG.REWARD))
	-- 兑换
	self.panel_1.mc_yeqian2.currentView:setTouchedFunc(c_func(self.onClickTag,self
		,self.FUNC_TAG.EXCHANGE))
	-- 排名
	self.panel_1.mc_yeqian3.currentView:setTouchedFunc(c_func(self.onClickTag,self
		,self.FUNC_TAG.RANK))

	EventControler:addEventListener(UserEvent.USEREVENT_PVP_COIN_CHANGE, self.updateTagRedPoint, self)
end

function ArenaRewardMainView:loadUIComplete()
	self:initViewAlign()
	self:registerEvent()
	self:initView()
end

function ArenaRewardMainView:initView()
	self:updateUI()
end

function ArenaRewardMainView:initViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_res, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.btn_back, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_title, UIAlignTypes.LeftTop)
end

function ArenaRewardMainView:onClickTag(tag)
	echo("tag=",tag)
	if self.curTag == tag then
		return
	end

	self.curTag = tag
	self:updateUI()
end


function ArenaRewardMainView:updateUI()
	self:updateTag()
	self:updateTitle()

	for k,v in pairs(self.tagViewMap) do
		local viewInfo = v
		local view = viewInfo.view
		if k == self.curTag then
			if view then
				view:setVisible(true)
			else
				-- 创建view
				local viewName = viewInfo.viewName
				view = WindowsTools:createWindow(viewName)
				self.ctn_ui:addChild(view)
				view:pos(0,0)
				-- 缓存view
				viewInfo.view = view
			end
		else
			if view then
				view:setVisible(false)
			end
		end
	end
end

-- 更新tag
function ArenaRewardMainView:updateTag()
	for i=1,self.tagNum do
		local mcView = self.panel_1["mc_yeqian" .. i]
		if  i == self.curTag then
			mcView:showFrame(2)
		else
			mcView:showFrame(1)
		end
	end

	self:updateTagRedPoint()
end

-- 更新tag红点状态
function ArenaRewardMainView:updateTagRedPoint()
	for i=1,self.tagNum do
		local mcView = self.panel_1["mc_yeqian" .. i]
		local redPointView = self.panel_1["panel_yeqianred" .. i]

		if not redPointView then
			echoError ("tag index =",i)
			return
		end

		if  i == self.curTag then
			redPointView:setVisible(false)
		else
			-- 判断是否显示红点
			local showRedPoint = false
			if i == self.FUNC_TAG.REWARD then
				showRedPoint = PVPModel:isScoreRewardRedPointShow();
			elseif i == self.FUNC_TAG.EXCHANGE then
				showRedPoint = PVPModel:isRankRedPointShow();
			elseif i == self.FUNC_TAG.RANK then
				showRedPoint = PVPModel:isRankRewardRedPointShow()
			end
			redPointView:setVisible(showRedPoint)
		end
	end
end

-- 更新标题
function ArenaRewardMainView:updateTitle()
	local viewInfo = self.tagViewMap[self.curTag]
	local titleName = viewInfo.title

	self.UI_di.txt_1:setString(titleName)
end

return ArenaRewardMainView
