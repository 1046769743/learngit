-- CompChongZhiShowUI
-- Author: Wk
-- Date: 2017-10-10
-- 充值返利展示界面
local CompChongZhiShowUI = class("CompChongZhiShowUI", UIBase);

function CompChongZhiShowUI:ctor(winName,_callFunc)
    CompChongZhiShowUI.super.ctor(self, winName);
    self._callFunc = _callFunc
end

function CompChongZhiShowUI:loadUIComplete()
	if self.btn_close then
		self.btn_close:setTouchedFunc(c_func(self.press_btn_close, self),nil,true);
	end

	self:setUIText()
end 
function CompChongZhiShowUI:setUIText()
	local text = GameConfig.getLanguage("#tid_welfare_feedback_001")
	self.panel_1.txt_1:setString(text)

	self.btn_1:setTouchedFunc(c_func(self.travelToChongZhi, self),nil,true);

	self.panel_tips.rich_1:setStringByAutoSize(GameConfig.getLanguage("#tid_welfare_feedback_002"))
	self.panel_tips:opacity(0)
	self.btn_2:setTouchedFunc(c_func(self.showChongZhiTips, self), nil, true)
end

function CompChongZhiShowUI:showChongZhiTips()
	if not self.coverLayer then
		self.coverLayer = WindowControler:createCoverLayer(nil, nil, cc.c4b(0,0,0,0), true):addto(self._root, 0)
		-- self.coverLayer:pos(-GameVars.width / 2,  GameVars.height / 2)
		self.coverLayer:setTouchedFunc(c_func(self.needHideChongZhiTips, self))
		self.coverLayer:setTouchSwallowEnabled(false)
	else
		self.coverLayer:setVisible(true)
	end
	
	self.panel_tips:fadeIn(0.2)
end

function CompChongZhiShowUI:needHideChongZhiTips()
	if self.coverLayer then
		self.coverLayer:setVisible(false)
	end
	self.panel_tips:fadeOut(0.2)
end

--前往充值
function CompChongZhiShowUI:travelToChongZhi()
	-- echo("========前往充值========")
	WindowControler:showWindow("MallMainView",FuncShop.SHOP_CHONGZHI)
	-- self:press_btn_close()
end

function CompChongZhiShowUI:press_btn_close()
	self:startHide()
	if self._callFunc then
		self._callFunc()
	end
end


return CompChongZhiShowUI;
