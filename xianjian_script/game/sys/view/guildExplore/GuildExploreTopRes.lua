-- GuildExploreTopRes
--[[
	Author: wk
	Date:2018-07-010
	Description: 顶部资源处理
]]

local GuildExploreTopRes = class("GuildExploreTopRes", UIBase);

function GuildExploreTopRes:ctor(winName)
    GuildExploreTopRes.super.ctor(self, winName)
end

function GuildExploreTopRes:loadUIComplete()
	self:registerEvent()
	self:initData()
	
end 
function GuildExploreTopRes:registerEvent()
	EventControler:addEventListener(GuildExploreEvent.RES_EXCHANGE_REFRESH, self.initData, self)
end



function GuildExploreTopRes:initData()
	local num1 =  GuildExploreModel:getResCount(FuncGuildExplore.guildExploreResType,FuncGuildExplore.resType.guildLiuli)
	local num2 =  GuildExploreModel:getResCount(FuncGuildExplore.guildExploreResType,FuncGuildExplore.resType.guildTianhe)
	local num3 =  GuildExploreModel:getResCount(FuncGuildExplore.guildExploreResType,FuncGuildExplore.resType.guildZijing)
	local num4 =  GuildExploreModel:getResCount(FuncGuildExplore.guildExploreResType,FuncGuildExplore.resType.guildLingmeng)

	--彩色琉璃
	self.panel_1.txt_1:setString(num1)
	--天河石
	self.panel_2.txt_1:setString(num2)
	--紫晶石
	self.panel_4.txt_1:setString(num3)
	--菱锰石
	self.panel_3.txt_1:setString(num4)

	if IS_EXPLORE_GM_RES  then
		self:setButton()
	end

end
function GuildExploreTopRes:setButton()


	self.panel_1:setTouchedFunc(c_func(function ()
		GuildExploreModel:getResGM(FuncGuildExplore.resType.guildLiuli)
	end),nil,true);
	self.panel_2:setTouchedFunc(c_func(function ()
		GuildExploreModel:getResGM(FuncGuildExplore.resType.guildTianhe)
	end),nil,true);
	self.panel_4:setTouchedFunc(c_func(function ()
		GuildExploreModel:getResGM(FuncGuildExplore.resType.guildZijing)
	end),nil,true);
	self.panel_3:setTouchedFunc(c_func(function ()
		GuildExploreModel:getResGM(FuncGuildExplore.resType.guildLingmeng)
	end),nil,true);

	
end


function GuildExploreTopRes:initView()
	

end



function GuildExploreTopRes:updateUI()
	


end





function GuildExploreTopRes:deleteMe()
	-- TODO

	GuildExploreTopRes.super.deleteMe(self);
end

return GuildExploreTopRes;
