--[[
	Author: 张燕广
	Date:2018-08-25
	Description: 购买铜钱tipsView
]]

local CompBuyCoinTips = class("CompBuyCoinTips", InfoTipsBase);

function CompBuyCoinTips:ctor(winName)
    CompBuyCoinTips.super.ctor(self, winName)
end

function CompBuyCoinTips:loadUIComplete()
	self:registerEvent()
	self:initView()
end 

function CompBuyCoinTips:registerEvent()
	CompBuyCoinTips.super.registerEvent(self);
end

function CompBuyCoinTips:initView()
	-- 加成倍率(万分比)
    local buyCoinAddition = FuncDataSetting.getDataByConstantName("BuyCoinAddition")
    local totalTimes = UserExtModel:buyCoinTimes()
    local addition = buyCoinAddition / 10000 * totalTimes * 100
    addition = string.format("%.1f",addition)

    local des = GameConfig.getLanguageWithSwap("tid_buycoin_1",totalTimes,addition)
    self.txt_1:setString(des)
end


function CompBuyCoinTips:deleteMe()
	CompBuyCoinTips.super.deleteMe(self);
end

return CompBuyCoinTips;
