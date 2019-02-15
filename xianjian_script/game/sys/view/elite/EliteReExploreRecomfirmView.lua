--
--Author:      zhuguangyuan
--DateTime:    2018-01-31 18:43:33
--Description: 重新探索旧章节二次确认
--

local EliteReExploreRecomfirmView = class("EliteReExploreRecomfirmView", UIBase);

function EliteReExploreRecomfirmView:ctor(winName,params)
    EliteReExploreRecomfirmView.super.ctor(self, winName)
    self.params = params
    dump(self.params, "二次确认界面参数")
end

function EliteReExploreRecomfirmView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function EliteReExploreRecomfirmView:registerEvent()
	EliteReExploreRecomfirmView.super.registerEvent(self);
	self.UI_1.btn_close:setTap(c_func(self.onClose, self))  -- 返回
end

function EliteReExploreRecomfirmView:initData()
	-- TODO
end

function EliteReExploreRecomfirmView:initView()
	self.UI_1.txt_1:setString("确认")
	self.UI_1.mc_1:showFrame(2)
	local currentView = self.UI_1.mc_1:getViewByFrame(2)
	currentView.btn_2:setTap(c_func(self.onClose,self))
	currentView.btn_1:setTap(c_func(self.confirmToGo,self))

	if self.params.viewType == FuncElite.TIPS_VIEW_TYPE.ENTER_SCENE then
		local tips = GameConfig.getLanguage("#tid_elite_tips_1003")
		self.txt_1:setString(tips)

	elseif self.params.viewType == FuncElite.TIPS_VIEW_TYPE.ENTER_NEXT_CHAPTER then
		if self.params.eventType == FuncEliteMap.GRID_BIT_TYPE.ORGAN then
		elseif self.params.eventType == FuncEliteMap.GRID_BIT_TYPE.BOX then
		elseif self.params.eventType == FuncEliteMap.GRID_BIT_TYPE.BOX then
		end
		local tips = GameConfig.getLanguage("#tid_elite_tips_1001")
		self.txt_1:setString(tips)
	end
end

function EliteReExploreRecomfirmView:confirmToGo()
	self:startHide()
	EventControler:dispatchEvent(EliteEvent.ELITE_CONFIRM_TO_GOTO_SCENE,{viewType = self.params.viewType})
end

function EliteReExploreRecomfirmView:initViewAlign()
	-- TODO
end

function EliteReExploreRecomfirmView:updateUI()
	-- TODO
end

function EliteReExploreRecomfirmView:onClose( ... )
	self:startHide()
end

function EliteReExploreRecomfirmView:deleteMe()
	EliteReExploreRecomfirmView.super.deleteMe(self);
end

return EliteReExploreRecomfirmView;
