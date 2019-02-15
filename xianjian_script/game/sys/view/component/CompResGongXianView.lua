local CompResGongXianView = class("CompResGongXianView", UIBase);
--仙盟贡献

function CompResGongXianView:ctor(winName)
    CompResGongXianView.super.ctor(self, winName);
end

function CompResGongXianView:loadUIComplete()
	self:registerEvent();

    self:updateUI();
end

function CompResGongXianView:registerEvent()
	CompResGongXianView.super.registerEvent();
	EventControler:addEventListener(UserEvent.USEREVENT_GUILDCOIN_SUCCESS,self.updateUI,self);
	self.btn_xianyujiahao:setTap(c_func(self.onAddTap, self));
end

function CompResGongXianView:onAddTap()
	-- WindowControler:showWindow("GuildMainBuildView",2)
	WindowControler:showWindow("GetWayListView", FuncDataResource.RES_TYPE.GUILDCOIN)
end

function CompResGongXianView:updateUI()
	local  _count = UserModel:getGuildCoin()
	self.txt_xianyu:setString(_count);
end


return CompResGongXianView;
