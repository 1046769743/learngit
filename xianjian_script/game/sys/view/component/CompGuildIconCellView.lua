-- CompGuildIconCellView
-- Author: Wk
-- Date: 2017-09-29
-- 公会通用图标view
local CompGuildIconCellView = class("CompGuildIconCellView", UIBase);

function CompGuildIconCellView:ctor(winName)
    CompGuildIconCellView.super.ctor(self, winName);
end

function CompGuildIconCellView:loadUIComplete()
	-- self:registerEvent()
end 

function CompGuildIconCellView:registerEvent()
	-- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
end
function CompGuildIconCellView:initData(icondata)
	if icondata == nil then
		icondata = {}
	end
	-- dump(GuildModel.guildIcon,"图标数据1111",8)
	local icondata = {
		borderid = icondata.borderId or GuildModel.guildIcon.borderId,
		bgid = icondata.bgId or GuildModel.guildIcon.bgId ,
		iconId = icondata.iconId or GuildModel.guildIcon.iconId ,
	}

	-- dump(icondata,"图标数据",8)


	local mc_di = self.panel_4.mc_di
	local mc_kuang = self.panel_4.mc_kuang
	local mc_tu = self.panel_4.mc_tu


	mc_di:showFrame(icondata.bgid)
	mc_kuang:showFrame(icondata.borderid)
	mc_tu:showFrame(icondata.iconId)

	mc_di:getViewByFrame(icondata.bgid).mc_1:showFrame(icondata.borderid)

end



return CompGuildIconCellView;
