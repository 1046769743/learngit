-- ArtifactLCMainCardView
-- Author: Wk
-- Date: 2017-11-8
-- 神器抽卡单独UI
local ArtifactLCMainCardView = class("ArtifactLCMainCardView", UIBase);

function ArtifactLCMainCardView:ctor(winName,_type,reward)
    ArtifactLCMainCardView.super.ctor(self, winName);
    self._type = _type
    self.reward = reward
end

function ArtifactLCMainCardView:loadUIComplete()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back, UIAlignTypes.RightTop)
   	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_shop, UIAlignTypes.Right)
   	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_title, UIAlignTypes.LeftTop)
   	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_guize, UIAlignTypes.LeftTop)
   	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_jinzhi, UIAlignTypes.MiddleBottom)
   	self.btn_back:setTouchedFunc(c_func(self.clickButtonBack, self),nil,true);
   	self.panel_title:setVisible(false)
   	self.btn_guize:setVisible(false)
	self:registerEvent()
	self:initData()
end 

function ArtifactLCMainCardView:registerEvent()
	-- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
end


function ArtifactLCMainCardView:initData()
	local BuyItems = FuncArtifact.todayBuyItems() - ArtifactModel:getBuyItems()
	local _str = string.format(GameConfig.getLanguage("#tid_shenqi_019"),tostring(BuyItems))
	self.panel_1.rich_1:setString(_str)

	local mustGetGood = FuncArtifact.getBuyitemsGetGoods() - ArtifactModel:getBuyItems()
	local ys = math.fmod(UserExtModel:cimeliaTotalTimes(),20)  --整数
	local num = FuncArtifact.getBuyitemsGetGoods() - ys
	local _str1 = string.format(GameConfig.getLanguage("#tid_shenqi_019"),tostring(num))
	self.panel_jinzhi.rich_1:setString(_str1)
	self.UI_1:initData(self._type,self.reward)

end
	

function ArtifactLCMainCardView:clickButtonBack()
	EventControler:dispatchEvent(ArtifactEvent.CLOSE_TO_UI)
	self:startHide()
end


return ArtifactLCMainCardView;
