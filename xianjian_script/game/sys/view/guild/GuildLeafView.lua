-- GuildLeafView
-- Author: Wk
-- Date: 2017-09-29
-- 公会创建界面d的叶签
local GuildLeafView = class("GuildLeafView", UIBase);
local _selecttype = {
	[1] = 1,  --起名
	[2] = 2,  --图标
	-- [3] = 3,  --加QQ群
	[3] = 4,  --创建完成
}
function GuildLeafView:ctor(winName)
    GuildLeafView.super.ctor(self, winName);
end

function GuildLeafView:loadUIComplete()
	-- self:registerEvent()
	self:initData()
end 

function GuildLeafView:registerEvent()
	-- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
end
function GuildLeafView:initData()
	-- body
end

--选择叶签
function GuildLeafView:setdefaultSelect(_selectID)
	-- self._selectID = _selectID
	self:selectNextIcon(_selectID)
end

--暂时不用
function GuildLeafView:setCellfun(cellfunTable)
	self.cellfunTable = cellfunTable
end

--跳转到下一个叶签
function GuildLeafView:selectNextIcon(_selectID)
	_selectID =tonumber(_selectID)
	for i=1,#_selecttype do
		self["mc_"..i]:showFrame(1)
	end
	if self["mc_".._selectID]  ~= nil then
		self["mc_".._selectID]:showFrame(2)
	else
		self["mc_"..(#_selecttype)]:showFrame(2)
	end
end


return GuildLeafView;
