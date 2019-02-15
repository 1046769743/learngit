-- CompResTopJadeView
-- 仙盟资源 陨玉
local CompResTopJadeView = class("CompResTopJadeView", UIBase)

function CompResTopJadeView:ctor(winName)
	CompResTopJadeView.super.ctor(self, winName)
end

function CompResTopJadeView:loadUIComplete()
	self:registerEvent()
	local jadeNum =  GuildModel:getOwnGuildJadeNum()
	self.txt_tianfu:setString(jadeNum)--UserModel:getSoulCopper())
end

function CompResTopJadeView:registerEvent()
	-- self.btn_tianfujiahao:setVisible(false)
	self.btn_tianfujiahao:setTap(c_func(self.onAddTap, self))
	self._root:setTouchedFunc(c_func(self.onAddTap, self))
    EventControler:addEventListener(GuildEvent.REFRESH_GUILD_RESOURCE_EVENT, self.updateUI, self)
end

function CompResTopJadeView:onAddTap()
	WindowControler:showWindow("GetWayListView", FuncDataResource.RES_TYPE.GUILD_JADE)
end

function CompResTopJadeView:updateUI()
	local jadeNum =  GuildModel:getOwnGuildJadeNum()
	self.txt_tianfu:setString(jadeNum)
end

function CompResTopJadeView:close()
	self:startHide()
end

return CompResTopJadeView
