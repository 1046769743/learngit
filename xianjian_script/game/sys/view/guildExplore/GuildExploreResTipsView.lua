-- GuildExploreResTipsView
--[[
	Author: TODO
	Date:2018-07-04
	Description: TODO
]]

local GuildExploreResTipsView = class("GuildExploreResTipsView", InfoTipsBase);

function GuildExploreResTipsView:ctor(winName,mineID)
    GuildExploreResTipsView.super.ctor(self, winName)
    self.mineID = mineID
end

function GuildExploreResTipsView:loadUIComplete()
	

	for i=1,3 do
		self:initData(i)
	end

end 



function GuildExploreResTipsView:initData(index)

	local res = nil
	local resArr =  self:getFuncData( "timeYield" )
	local num = 0
	if resArr then  
		local reward = resArr[index]
		res = string.split(reward, ",")

		if res[2] == FuncGuildExplore.guildExploreResType then
			local keyData = FuncGuildExplore.getCfgDatas("ExploreResource",res[3])
			iconPath = FuncRes.getIconResByName(keyData.icon)
			num = res[4]
		else
			local icon =  FuncDataResource.getIconPathById( res[2] )
			iconPath = FuncRes.getIconResByName(icon)
			num = res[3]
		end
	else
		resArr =  self:getFuncData( "timeYield2" )
		local reward = resArr[index]
		res = string.split(reward, ",")
		local iconName = FuncDataResource.getIconPathById( res[1] )
		iconPath = FuncRes.getIconResByName(iconName)
	end
	self["ctn_"..index]:removeAllChildren()
	local sprite = display.newSprite(iconPath)
	sprite:size(35,35)
	self["ctn_"..index]:addChild(sprite)

	-- local res = string.split(reward, ",")
	if tonumber(res[1]) == 1 then
		-- text:setString(num.."/分钟")
		self["txt_"..(4*index)]:setString(num..GameConfig.getLanguage("#tid_Explore_des_104"))
	else
		-- text:setString(num.."/"..res[1].."分钟")
		self["txt_"..(4*index)]:setString(num.."/"..res[1].."分钟")--res[3]..GameConfig.getLanguage("#tid_Explore_des_104"))
	end

	

end


function GuildExploreResTipsView:getFuncData( key )
	local cfgsName = "ExploreMine"
	local id = self.mineID
	local keyData = FuncGuildExplore.getCfgDatasByKey(cfgsName,id,key)
	return keyData
end






return GuildExploreResTipsView;
