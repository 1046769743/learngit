-- GuildExploreSurpriseView.lua
--[[
	Author: wk
	Date:2018-07-010
	Description: 资源特效
]]

local GuildExploreSurpriseView = class("GuildExploreSurpriseView", UIBase);

function GuildExploreSurpriseView:ctor(winName,reward)
    GuildExploreSurpriseView.super.ctor(self, winName)
    self.reward = reward
end

function GuildExploreSurpriseView:loadUIComplete()
	self:registerEvent()

	self:initData()
	self:addBgeff()
	
end 
function GuildExploreSurpriseView:registerEvent()
	self:registClickClose("-1")
end

function GuildExploreSurpriseView:initData()
	local res = string.split(self.reward[1], ",")
	local num = 0
	if res[1] == FuncGuildExplore.guildExploreResType then
		local keyData =  FuncGuildExplore.getCfgDatas( "ExploreResource",res[2] )
		local image   =  keyData.icon
		icon = FuncRes.getIconResByName(image)
		num = res[3]
	else
		if #res == 2 then
			local iconName = FuncDataResource.getIconPathById(res[1])
			icon = FuncRes.getIconResByName(iconName)
			num = res[2]
		else
			icon = FuncRes.iconItem(res[2])
			num = res[3]
		end
	end
	local sprite = display.newSprite(icon)
	sprite:size(35,35)
	sprite:addTo(self.panel_1.ctn_2)
	self.txt_2:setString(num)
end


function GuildExploreSurpriseView:addBgeff()
	self.ctn_1:removeAllChildren()
	local startAni = self:createUIArmature("UI_xianmengtansuo", "UI_xianmengtansuo_yqbp",self.ctn_1, false,function  ()
	end)
	-- startAni:setAllChildAniPlayOnce(  )
	FuncArmature.changeBoneDisplay(startAni, "node01", self.panel_1)  --替换
	FuncArmature.changeBoneDisplay(startAni, "node02", self.txt_2)  --替换
	-- startAni:startPlay(true, true )
	-- startAni:gotoAndPlay(30)
	startAni:registerFrameEventCallFunc(25,1,function () 
		startAni:pause()
		self:delayCall(function()
			self:startHide()
		end,1.5)
	end)




end

function GuildExploreSurpriseView:runaction()
	-- body
end


function GuildExploreSurpriseView:deleteMe()
	GuildExploreSurpriseView.super.deleteMe(self);
end

return GuildExploreSurpriseView;
