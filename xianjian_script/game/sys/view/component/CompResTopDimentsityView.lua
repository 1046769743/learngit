--[[
	Author: ZhangYanguang
	Date:2017-08-11
	Description: 锁妖塔魔石
]]

local CompResTopDimentsityView = class("CompResTopDimentsityView", UIBase);

function CompResTopDimentsityView:ctor(winName)
    CompResTopDimentsityView.super.ctor(self, winName)
end

function CompResTopDimentsityView:loadUIComplete()
	self:registerEvent()
	self:updateUI()
end 

function CompResTopDimentsityView:registerEvent()
	CompResTopDimentsityView.super.registerEvent(self);
	EventControler:addEventListener(UserEvent.USEREVENT_DIMENSITY_CHANGE, self.updateUI, self)

	self.btn_xianyujiahao:setTap(c_func(self.clickAddDimensity,self))

	EventControler:addEventListener(UserEvent.USEREVENT_DIMENSITY_CHANGE, self.updateUI, self)
end

function CompResTopDimentsityView:clickAddDimensity()
	WindowControler:showWindow("GetWayListView",FuncDataResource.RES_TYPE.DIMENSITY)
end

function CompResTopDimentsityView:updateUI()
	self.txt_xianyu:setString(UserModel:getDimensity())
end

function CompResTopDimentsityView:deleteMe()
	CompResTopDimentsityView.super.deleteMe(self);
end

return CompResTopDimentsityView;
