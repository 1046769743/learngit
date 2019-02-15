-- CompResTopStoneView
-- 仙盟资源 星石
local CompResTopStoneView = class("CompResTopStoneView", UIBase)

function CompResTopStoneView:ctor(winName)
	CompResTopStoneView.super.ctor(self, winName)
end

function CompResTopStoneView:loadUIComplete()
	self:registerEvent()
	local stoneNum =  GuildModel:getOwnGuildStoneNum()
	self.txt_tianfu:setString(stoneNum)--UserModel:getSoulCopper())
end

function CompResTopStoneView:registerEvent()
	-- self.btn_tianfujiahao:setVisible(false)
	self.btn_tianfujiahao:setTap(c_func(self.onAddTap, self))
	self._root:setTouchedFunc(c_func(self.onAddTap, self))
    EventControler:addEventListener(GuildEvent.REFRESH_GUILD_RESOURCE_EVENT, self.updateUI, self)
end

function CompResTopStoneView:onAddTap()
	WindowControler:showWindow("GetWayListView", FuncDataResource.RES_TYPE.GUILD_STONE)
end

function CompResTopStoneView:updateUI()
	local stoneNum =  GuildModel:getOwnGuildStoneNum()
	self.txt_tianfu:setString(stoneNum)
end

function CompResTopStoneView:close()
	self:startHide()
end

return CompResTopStoneView
