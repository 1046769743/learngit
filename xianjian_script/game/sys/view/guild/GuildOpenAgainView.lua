-- GuildOpenAgainView.lua
-- Author: Wk
-- Date: 2017-09-29
-- 公会宝箱再一次兑换界面
local GuildOpenAgainView = class("GuildOpenAgainView", UIBase);

function GuildOpenAgainView:ctor(winName,boxID)
    GuildOpenAgainView.super.ctor(self, winName);
    echo("=====宝箱ID====",boxID)
    self.boxID = boxID
end

function GuildOpenAgainView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:freshCostData()
end 

function GuildOpenAgainView:registerEvent()
	-- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
end


--初始化数据
function GuildOpenAgainView:initData()
	self:registClickClose("out")
	self.UI_1.btn_close:setTouchedFunc(c_func(self.press_btn_close, self),nil,true);
	self.UI_1.mc_1:setVisible(false)
	self.btn_2:setTouchedFunc(c_func(self.press_btn_close, self),nil,true);
	self.btn_1:setTouchedFunc(c_func(self.againButton, self),nil,true);
	self.panel_xxx:setTouchedFunc(c_func(self.showRewardData,self),nil,true);
end

function GuildOpenAgainView:showRewardData()
	local rewardID = FuncGuild.getExchangeRewardData(self.boxID)
	local rewardData = FuncItem.getRewardData(rewardID)
	local newReward = {}
	for i=1,#rewardData.info do
		local data = string.split(rewardData.info[i],",")
		newReward[i] = data[2]..","..data[3]..","..data[4]

	end
	local _table = {
		title = "奖励预览",
		des = "",
		reward = newReward,
		callback = nil,--回调函数
		isPickup = nil,--是否可领取  -- 0 --预览不可领取  1领取   2已领取 --nil不显示
		parameter = nil,
	}
	WindowControler:showWindow("GuildBlessingRewardView",_table);
end

	
--在买一次
function GuildOpenAgainView:againButton()
	local count = GuildModel.boxExchangCount
	local againData = FuncGuild.getagainRewardData(self.boxID)
	if count == 0 then
		count = 1
	end
	echo("=======购买次数=========",count)
	if count > table.length(againData) then
		WindowControler:showTips(FuncGuild.Tranlast[4])
		return 
	end

	local resStr = againData[count]
	if resStr ~= nil then
		local needNum,hasNum,isEnough ,resType,resId =  UserModel:getResInfo( resStr )
		if not isEnough then
			WindowControler:showTips(FuncGuild.Tranlast[5])	
		else
			local function _callback(result)
				if result.result ~= nil then
					dump(result.result,"RMB兑换成功返回数据======")
					GuildModel:boxExchanreCountAdd()
					local itemArray = result.result.data.reward
					EventControler:dispatchEvent(GuildEvent.GUILD_SHOUJI_LIST_REFRESH)
					WindowControler:showWindow("RewardSmallBgView", itemArray,c_func(self.freshCostData,self));
				end
			end
			local params = {
				boxId = self.boxID
			}
			GuildServer:sendRmbExchangeBoxData(params,_callback)
		end
	end

end

--刷新
function GuildOpenAgainView:freshCostData()
	local count = GuildModel.boxExchangCount
	local againData = FuncGuild.getagainRewardData(self.boxID)
	if count >= table.length(againData) then
		count = table.length(againData)
	else
		if count == 0 then
			count = 1
		end
	end
	local resStr = againData[count]
	echo("==========购买的次数 ========count===",count,resStr)
	if resStr ~= nil then
		local needNum,hasNum,isEnough ,resType,resId =  UserModel:getResInfo( resStr )
		local iconpath = FuncRes.iconRes(resType,resId)
		local icon = display.newSprite(iconpath)
		icon:setScale(0.4)
		icon:setPosition(cc.p(15,-15))
		if isEnough then
			self.mc_yu:showFrame(1)
			local panel = self.mc_yu:getViewByFrame(1)
			panel.ctn_icon:removeAllChildren()
			panel.ctn_icon:addChild(icon)
			panel.txt_1:setString(needNum)
		else
			self.mc_yu:showFrame(2)
			local panel = self.mc_yu:getViewByFrame(2)
			panel.ctn_icon:removeAllChildren()
			panel.ctn_icon:addChild(icon)
			panel.txt_1:setString(needNum)
		end

	end
end




--在显示一次事件发送
function GuildOpenAgainView:showAgainView()
	
end




function GuildOpenAgainView:press_btn_close()
	self:startHide()
end





return GuildOpenAgainView;
