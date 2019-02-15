local CompResTopToolView = class("CompResTopToolView", UIBase);
--仙盟铲子

function CompResTopToolView:ctor(winName)
    CompResTopToolView.super.ctor(self, winName);
end

function CompResTopToolView:loadUIComplete()
	self:registerEvent();
	self:initData()
end

function CompResTopToolView:registerEvent()
	CompResTopToolView.super.registerEvent();
	EventControler:addEventListener(GuildEvent.REFRESH_DIGTOOLNUM, self.updateUI, self)
	self.btn_tilijiahao:setTap(c_func(self.onAddTap, self));
end

function CompResTopToolView:onAddTap()
	WindowControler:showWindow("GetWayListView", FuncDataResource.RES_TYPE.TOOL,nil,self.toolnum)
end

function CompResTopToolView:initData(  )
	self.toolNum = GuildModel:getToolMaxNum()
end

function CompResTopToolView:updateUI(event)
	if event then
		self.toolnum = event.params.digTool
		self.txt_tili:setString(tostring(self.toolnum).."/" .. tostring(self.toolNum))
	end
end


return CompResTopToolView;
