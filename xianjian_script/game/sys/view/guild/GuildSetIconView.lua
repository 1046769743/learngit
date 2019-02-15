-- GuildSetIconView
-- Author: Wk
-- Date: 2017-09-29
-- 公会设置通用图标view
local GuildSetIconView = class("GuildSetIconView", UIBase);

function GuildSetIconView:ctor(winName)
    GuildSetIconView.super.ctor(self, winName);
    self.borderId = 1   --标志框
	self.bgId = 1 		--背景颜色
	self.iconId = 1		--图标
end

function GuildSetIconView:loadUIComplete()
	self:registerEvent()
	self:initData()
end 

function GuildSetIconView:registerEvent()
	-- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
end

function GuildSetIconView:initData()

	self:selectborderId(self.borderId)
	self:selectbgId(self.bgId)
	self:selectIconId(self.iconId)
	self:initButton()

	
	local name = GuildModel.guildName.name
	local _type = GuildModel.guildName._type
	echo("========仙盟名称=======",name)
	local data = FuncGuild.getguildType()
	local namestid  = data[tostring(_type)].afterName
	local _typenames = GameConfig.getLanguage(namestid)
	self.txt_name2:setString(name.._typenames)

end

function GuildSetIconView:initButton()
	for i=1,#FuncGuild.guildIconType.BORDERTYPE do
		self.panel_1["panel_"..i]:setTouchedFunc(c_func(self.selectborderId, self,i),nil,true);
	end
	for i=1,#FuncGuild.guildIconType.BGTYPE do
		self.panel_2["panel_"..i]:setTouchedFunc(c_func(self.selectbgId, self,i),nil,true);
	end
	for i=1,#FuncGuild.guildIconType.ICONTYPE do
		self.panel_3["panel_"..i]:setTouchedFunc(c_func(self.selectIconId, self,i),nil,true);
	end

	self.btn_1:setTouchedFunc(c_func(self.nextButton, self,i),nil,true);

end
function GuildSetIconView:nextButton()
	EventControler:dispatchEvent(GuildEvent.GUILD_REFRESH_ICON)
	self.cellBack()
end

--回调函数
function GuildSetIconView:setCellFun( cellBack )
	self.cellBack = cellBack
end

--选择边框类型
function GuildSetIconView:selectborderId(_index)
	self.borderId = _index
	local panel = self.panel_1["panel_".._index]
	self:setDuiPos(panel,self.panel_1,self.panel_1)

end

--选择背景框类型
function GuildSetIconView:selectbgId(_index)
	self.bgId = _index
	local panel = self.panel_2["panel_".._index]
	self:setDuiPos(panel,self.panel_2,self.panel_2)
end

--选择图标
function GuildSetIconView:selectIconId(_index)
	self.iconId = _index
	local panel = self.panel_3["panel_".._index]
	self:setDuiPos(panel,self.panel_3)
end

function GuildSetIconView:setDuiPos(panel,followview)
	local _x = panel:getPositionX()
	local _y = panel:getPositionY()
	local size = panel:getContainerBox()
	followview.panel_dui:setPosition(cc.p(_x + size.width/2 + 15 ,_y - size.height/2 -5))

	self:rightCommIConData()

end

--最右边数据更新
function GuildSetIconView:rightCommIConData()
	local icondata = {
		borderId = self.borderId,
		bgId = self.bgId,
		iconId = self.iconId,
	}
	-- dump(icondata,"选中的数据")
	self.UI_1:initData(icondata)
	GuildModel:setIconData(icondata)
end


return GuildSetIconView;
