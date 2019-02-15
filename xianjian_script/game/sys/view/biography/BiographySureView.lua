--[[
	奇侠传玩法说明View
	author: lcy
	add: 2018.7.20
]]

local BiographySureView = class("BiographySureView", UIBase)

function BiographySureView:ctor(winName,params)
	BiographySureView.super.ctor(self, winName)
	params = params or {}
	self._sureCall = params.sure
	self._cancelCall = params.cancel
	self._des = params.des or ""
	self._title = params.title or ""
end

function BiographySureView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:updateUI()
end

function BiographySureView:registerEvent()
	self:registClickClose("out",c_func(self.onClickBack,self))
end

function BiographySureView:initData()
	-- body
end

function BiographySureView:initViewAlign()
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back, UIAlignTypes.RightTop)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_title, UIAlignTypes.LeftTop)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_1, UIAlignTypes.LeftTop)

end

function BiographySureView:updateUI()
	self.UI_1.mc_1:visible(false)
	-- 标题
	local title,des = self._title,self._des
	self.UI_1.txt_1:setString(self._title)

	-- 描述
	self.rich_1:setString(self._des)

	-- 确定
	self.btn_2:setTap(function()
		if self._sureCall then
			self._sureCall()
		end
		self:onClickBack()
	end)

	-- 取消
	self.btn_1:setTap(function()
		if self._cancelCall then
			self._cancelCall()
		end
		self:onClickBack()
	end)

	-- 关闭
	self.UI_1.btn_close:setTap(c_func(self.onClickBack,self))
end

function BiographySureView:onClickBack()
	self:startHide()
end

return BiographySureView