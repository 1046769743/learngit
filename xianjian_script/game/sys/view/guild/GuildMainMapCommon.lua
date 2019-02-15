-- GuildMainMapCommon
-- Author: Wk
-- Date: 2017-09-30
-- 公会主城地图
local GuildMainMapCommon = class("GuildMainMapCommon", UIBase);

function GuildMainMapCommon:ctor(winName)
    GuildMainMapCommon.super.ctor(self, winName);
end

function GuildMainMapCommon:loadUIComplete()

end 

function GuildMainMapCommon:registerEvent()
	-- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
end



function GuildMainMapCommon:press_btn_close()
	self:startHide()
end


return GuildMainMapCommon;
