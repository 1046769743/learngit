-- GuildExploreGetResView
--[[
	Author: TODO
	Date:2018-07-04
	Description: TODO
]]

local GuildExploreGetResView = class("GuildExploreGetResView", UIBase);
-- local data = {resId = ,num= }
function GuildExploreGetResView:ctor(winName,reward)
    GuildExploreGetResView.super.ctor(self, winName)
    self.reward = reward
end

function GuildExploreGetResView:loadUIComplete()
	self:registClickClose("out")
	self:delayCall(function ()
		self:button_close()
	end,1.0)
	self:initData()
end 

-- local reward = {
-- 	"2" = qwi
-- }
---setRewardInfo
function GuildExploreGetResView:initData()
	
	local resID  = nil
	local count = 0
	for k,v in pairs(self.reward) do
		resID = k
		count = v
	end

	local icon = self:getFuncData( resID,"icon" )
	local iconPath = FuncRes.getIconResByName(icon)
	local sprite = display.newSprite(iconPath)
	sprite:size(35,35)
	self.ctn_2:addChild(sprite)
	self.txt_2:setString(count)

end


function GuildExploreGetResView:getFuncData( resID,key )
	local cfgsName = "ExploreResource"
	local id = resID
	local keyData = FuncGuildExplore.getCfgDatasByKey(cfgsName,id,key)
	return keyData
end


function GuildExploreGetResView:button_close()
	self:startHide()
end






return GuildExploreGetResView;
