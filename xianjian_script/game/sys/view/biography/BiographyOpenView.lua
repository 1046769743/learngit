--[[
	奇侠传记开启View
	author: lcy
	add: 2018.8.22
]]

local BiographyOpenView = class("BiographyOpenView", UIBase)

function BiographyOpenView:ctor(winName, params)
	BiographyOpenView.super.ctor(self, winName)

	self._partnerId = params.partnerId
	self._nodeId = params.nodeId
	self._callBack = params.callBack

	self._animFinish = false -- 动画播完
end

function BiographyOpenView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end

function BiographyOpenView:registerEvent()
	-- 任意位置关闭
	self:registClickClose(999,c_func(self.onClickBack,self))
end

function BiographyOpenView:initData()

end

function BiographyOpenView:initViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_1, UIAlignTypes.MiddleBottom)
end

function BiographyOpenView:initView()
	-- body
end

function BiographyOpenView:updateUI()
	-- 立绘
	local sp = FuncPartner.getPartnerOrCgarLiHui(self._partnerId):addTo(self.ctn_1)
	-- 奇侠名
	local partnerName = FuncPartner.getPartnerName(self._partnerId)
	self.panel_banzi.txt_name:setString(partnerName)
	-- 获取描述
	-- self.panel_banzi.rich_name:setString()
	-- 做动画
	-- 标题飞入
	self.panel_zjkq:opacity(0)
	self.panel_zjkq:scale(1.5)
	self.panel_zjkq:runAction(cc.Spawn:create({
		cc.FadeIn:create(0.2),
		self.panel_zjkq:getScaleAnimByPos(0.2,1,1,false),
	}))

	self.panel_djjx:opacity(0)
	self.panel_banzi.rich_name:startPrinter(GameConfig.getLanguageWithSwap(FuncBiography.getBiographyValueByKey(self._nodeId, "describe3"), partnerName),10)
	self.panel_banzi.rich_name:registerCompleteFunc(function()
		self._animFinish = true
		self.panel_djjx:runAction(cc.FadeIn:create(0.1))
	end)
end

function BiographyOpenView:onClickBack()
	if self._animFinish then
		local func = self._callBack
		self._callBack = nil
		if func then
			func()
		end
		-- 动画已经播完关闭
		self:startHide()
	else
		-- 动画没播完，直接刷出来
		self.panel_banzi.rich_name:skipPrinter()
	end
end

return BiographyOpenView