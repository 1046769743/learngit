--TitleMainView
--aouth wk
--time 2017/7/12

local TitleMainView = class("TitleMainView", UIBase);

local titletype = {
	title_cultivate = 1,   --培养
	title_challenge = 2,   --挑战
	title_other = 3,       ---其它
	title_limit = 4,       --限时

}
local titletypename = {
	[1] = "培养",
	[2] = "挑战",
	[3] = "其他",
	[4] = "限时",
}
local Leafsignnumber = 4  --叶签数量
function TitleMainView:ctor(winName,titletype)
    TitleMainView.super.ctor(self, winName);
    self.defaultindex = titletype or 1
    -- self.titletype = titletype
    echo("========titletype========",titletype)
    if titletype == nil then
    	if TitleModel.selectIndex ~= nil then
    		self.defaultindex = TitleModel.selectIndex
    	end
    end
end

function TitleMainView:loadUIComplete()
	self:registerEvent();
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back, UIAlignTypes.RightTop)
 	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_ziyuan, UIAlignTypes.RightTop)
   	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_name, UIAlignTypes.LeftTop)

	self.btn_back:setTouchedFunc(c_func(self.clickButtonBack, self),nil,true);
	self.btn_wen:setVisible(false)
	self.btn_wen:setTouchedFunc(c_func(self.rulesButton, self),nil,true);
	-- self.panel_yeqian  ---叶签

	self:setButtonRedisFalse()
	self:setButtonBack()

	self:clickButtonCallfun(self.defaultindex)
	self:setUIName(self.defaultindex)
	self.panel_yeqian["mc_"..self.defaultindex]:showFrame(2)

	self:updateUI(self.defaultindex)
	self:getPowerChange()
	
end 
function TitleMainView:getPowerChange()
	if  self.oldAbility ~= nil then
        if self.oldAbility ~= UserModel:getcharSumAbility() then
            if self.oldAbility < UserModel:getcharSumAbility() then
                FuncCommUI.showPowerChangeArmature(self.oldAbility or 10, UserModel:getcharSumAbility() or 10,0.8,true,1.8);
                self.oldAbility = UserModel:getcharSumAbility()
            end
        end
    else
    	self.oldAbility = UserModel:getcharSumAbility()
    end
end

function TitleMainView:registerEvent()
	TitleMainView.super.registerEvent();
	-- EventControler:addEventListener(NewSignEvent.SIGN_FINISH_EVENT, self.updateSign, self)
	EventControler:addEventListener(UserEvent.USEREVENT_COIN_CHANGE, self.setButtonRedisFalse, self);
	EventControler:addEventListener(UserEvent.USEREVENT_GOLD_CHANGE, self.setButtonRedisFalse, self);
	EventControler:addEventListener(TitleEvent.REFRESH_POWER_CHANRE_UI,self.getPowerChange,self);
end
function TitleMainView:setButtonBack()
	-- self.panel_yeqian.mc_1:setTouchedFunc(c_func(self.clickButtonCallfun, self, 1));
	-- self.panel_yeqian.mc_2:setTouchedFunc(c_func(self.clickButtonCallfun, self, 2));
	-- self.panel_yeqian.mc_3:setTouchedFunc(c_func(self.clickButtonCallfun, self, 3));
	-- self.panel_yeqian.mc_4:setTouchedFunc(c_func(self.clickButtonCallfun, self, 4));

	for i=1,#titletypename do
		self.panel_yeqian["mc_"..i]:setTouchedFunc(c_func(self.clickButtonCallfun, self, i));
	end

end
function TitleMainView:setButtonRedisFalse()
	local reddata = TitleModel:titletypeRedShow()
	-- dump(reddata,"1111111111111111111111")
	for i=1,Leafsignnumber do
		local showred = reddata[i]
		self.panel_yeqian["mc_"..i]:getViewByFrame(1).panel_hongdian:setVisible(showred)
	end
end
function TitleMainView:rulesButton()
	echo("暂未开启规则")
end
function TitleMainView:clickButtonCallfun(titletypes)
	-- self.panel_yeqian.mc_1
	-- self:disabledUIClick()

	if titletypes == self.defaultindex then
		-- self:resumeUIClick()
		return 
	end
	TitleModel:setSelectYeQian(titletypes)

	-- for i=1,Leafsignnumber do
	-- 	-- local showred = reddata[i]
	-- 	self.panel_yeqian["mc_"..i]:getViewByFrame(1).panel_hongdian:setVisible(showred)
	-- end

	for i=1,Leafsignnumber do
		
		if i == titletypes then
			self.panel_yeqian["mc_"..i]:showFrame(2)
		else
			self.panel_yeqian["mc_"..i]:showFrame(1)
		end
	end
	

	-- self:setButonIntouchInfo(titletypes)
	self.defaultindex = titletypes
	self:setUIName(self.defaultindex)
	-- self:updateUI(titletype)
	-- TitleEvent.TitleEvent_TOUCH_NOTTYPE
	-- self:delayCall(function()
	-- 	self:resumeUIClick()
	-- end,0.4)
	self:setButtonRedisFalse()
	EventControler:dispatchEvent(TitleEvent.TitleEvent_TOUCH_NOTTYPE,titletypes)
end
function TitleMainView:setUIName(titletypes)
	-- echoError("==========titletypes=========",titletypes)
	local str = titletypename[tonumber(titletypes)]
	self.UI_1.txt_1:setString(str)
end
--设置按钮点中状态
function TitleMainView:setButonIntouchInfo(titletypes)

	for i=1,Leafsignnumber do
		if i == titletypes then
			self.panel_yeqian["mc_"..i]:showFrame(2)
		else
			self.panel_yeqian["mc_"..i]:showFrame(1)
		end
	end
end

function TitleMainView:clickButtonBack()
	TitleModel:sendHomeMainViewred()  --向主城发送红点消息
	EventControler:dispatchEvent(TitleEvent.INFOPLAYER_RED_SHOW)
	EventControler:dispatchEvent(UserEvent.USEREVENT_PLAYER_POWER_CHANGE);
    self:startHide();
end



function TitleMainView:updateUI(titletype)
	local viewName = "TitleDataView"
	local viewNames = WindowsTools:createWindow(viewName,titletype);
    self.ctn_1:addChild(viewNames);
end


return TitleMainView;
