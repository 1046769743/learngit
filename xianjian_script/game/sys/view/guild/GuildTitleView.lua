-- GuildTitleView
-- Author: Wk
-- Date: 2017-11-17
local GuildTitleView = class("GuildTitleView", UIBase);

function GuildTitleView:ctor(winName,builgID)
    GuildTitleView.super.ctor(self, winName);
    self.builgID = builgID
end

function GuildTitleView:loadUIComplete()



	
	self:initData()
end 
function GuildTitleView:initData()
	local allData =  FuncGuild.getguildBuildAllData()
	local buildData = allData[tostring(self.builgID)]
	local name = buildData.name

	self.panel_1.txt_1:setString(GameConfig.getLanguage(name))
end




return GuildTitleView;
