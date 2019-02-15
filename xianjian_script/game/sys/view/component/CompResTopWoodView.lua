-- CompResTopWoodView
--木头资源
local CompResTopWoodView = class("CompResTopWoodView", UIBase)

function CompResTopWoodView:ctor(winName)
	CompResTopWoodView.super.ctor(self, winName)
end

function CompResTopWoodView:loadUIComplete()
	self:registerEvent()
	local wood =  GuildModel:getWoodCount()
	self.txt_tianfu:setString(wood)--UserModel:getSoulCopper())
end

function CompResTopWoodView:registerEvent()
	-- self.btn_tianfujiahao:setVisible(false)
	self.btn_tianfujiahao:setTap(c_func(self.onAddTap, self))
	self._root:setTouchedFunc(c_func(self.onAddTap, self))
    EventControler:addEventListener(GuildEvent.REFRESH_GUILD_WOOD_EVENT, self.updateUI, self)
    EventControler:addEventListener(GuildEvent.GUILD_REFRESH_WOOD_EVENT, self.updateUI, self)
    EventControler:addEventListener(GuildEvent.REFRESH_GUILD_RESOURCE_EVENT, self.updateUI, self)
end

function CompResTopWoodView:onAddTap()
	WindowControler:showWindow("GetWayListView", FuncDataResource.RES_TYPE.WOOD)
end

function CompResTopWoodView:updateUI()
	local wood =  GuildModel:getWoodCount()
	self.txt_tianfu:setString(wood)
end

function CompResTopWoodView:close()
	self:startHide()
end

return CompResTopWoodView
