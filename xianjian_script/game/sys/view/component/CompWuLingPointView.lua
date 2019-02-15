--[[
	Author: TODO
	Date:2017-10-30
	Description: TODO
]]
local ResTopBase = require("game.sys.view.component.CompResTopBase")
local CompWuLingPointView = class("CompWuLingPointView", ResTopBase);

function CompWuLingPointView:ctor(winName)
    CompWuLingPointView.super.ctor(self, winName)
end

function CompWuLingPointView:loadUIComplete()
	CompWuLingPointView.super.loadUIComplete(self)
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function CompWuLingPointView:registerEvent()
	CompWuLingPointView.super.registerEvent(self);
	self.btn_tianfujiahao:setTap(c_func(self.clickAdd,self))
	EventControler:addEventListener(UserEvent.USEREVENT_FIVESOULPOINT_CHANGE, self.updateUI, self)
end

function CompWuLingPointView:clickAdd()
	WindowControler:showWindow("GetWayListView",FuncDataResource.RES_TYPE.WULINGPOINT)
end

function CompWuLingPointView:initData()
	-- TODO
end

function CompWuLingPointView:initView()
	-- TODO
end

function CompWuLingPointView:initViewAlign()
	-- TODO
end

function CompWuLingPointView:updateUI()
	self.txt_tianfu:setString(UserExtModel:fiveSoulPoint())
	local isWuLingType = WuLingModel:checkRedPoint()
   	EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,{redPointType = HomeModel.REDPOINT.DOWNBTN.ARRAY, isShow = isWuLingType})	
end

function CompWuLingPointView:deleteMe()
	-- TODO

	CompWuLingPointView.super.deleteMe(self);
end

return CompWuLingPointView;
