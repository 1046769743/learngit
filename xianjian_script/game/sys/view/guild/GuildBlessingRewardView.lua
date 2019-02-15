-- GuildBlessingRewardView
-- Author: Wk
-- Date: 2017-10-11
-- 公会创加入通用cell界面
local GuildBlessingRewardView = class("GuildBlessingRewardView", UIBase);
--[[
	local _table = {
		title = "奖励预览",
		des = "",
		reward = {
			[1] = ,
			[2] = ,
			[3] = ,
		},
		callback = ,--回调函数
		isPickup = ,--是否可领取  -- 0 --预览不可领取  1领取   2已领取 --nil不显示
		parameter = ,
	}
]]

function GuildBlessingRewardView:ctor(winName,_table)
    GuildBlessingRewardView.super.ctor(self, winName);
    self._table = _table
end

function GuildBlessingRewardView:loadUIComplete()
	self.btn_close:setTouchedFunc(c_func(self.press_btn_close, self),nil,true);
	self:registClickClose(-1, c_func( function()
        self:press_btn_close()
    end , self))
    self:initData()
end 

function GuildBlessingRewardView:registerEvent()
	-- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
		--创建
	-- self.btn_1:setTouchedFunc(c_func(self.creaGuild, self),nil,true);
	-- --加入
	-- self.btn_2:setTouchedFunc(c_func(self.addGuild, self),nil,true);
end

function GuildBlessingRewardView:initData()

	self.txt_1:setString(self._table.title or GameConfig.getLanguage("#tid_guild_014")) 
	self.mc_1:setVisible(false)
	local sumreward = self._table.reward
	if #sumreward == 0 then
		echo("======奖励为空=======")
		return 
	end

	local frame = #sumreward
	self.mc_1:showFrame(frame)
	self.mc_1:setVisible(true)
	for i=1,frame do
		local rewardUI = self.mc_1:getViewByFrame(frame)["UI_"..i]
		local reward = string.split(sumreward[i],",")
		local rewardType = reward[1];
		local rewardNum = reward[table.length(reward)];
		local rewardId = reward[table.length(reward) - 1];
        rewardUI:visible(true)

        -- dump(reward,"22222222222222222")
        rewardUI:setResItemData({reward = sumreward[i]})
        -- rewardUI:showResItemName(false)
        FuncCommUI.regesitShowResView(rewardUI,
        	rewardType,rewardNum,rewardId,sumreward[i],true,true)
	end


	if self._table.isPickup == 0 then
		self.mc_2:showFrame(1)
		local str = self._table.des
		if str == nil then
			str = ""
		end
		self.mc_2:getViewByFrame(1).txt_2:setString(str)

	elseif self._table.isPickup == 1 then
		self.mc_2:showFrame(2)
		self.mc_2:getViewByFrame(2).btn_1:setTouchedFunc(c_func(self.pickupbutton, self),nil,true);
	elseif self._table.isPickup == 2 then
		self.mc_2:showFrame(3)
	else
		self.mc_2:setVisible(false)
	end

end

function GuildBlessingRewardView:pickupbutton()
	if not GuildControler:touchToMainview() then
		return 
	end

	local function _callback(_param)
		dump(_param.result,"宝箱列表数据",8)
		if _param.result then
			local reward = _param.result.data.reward
			EventControler:dispatchEvent(GuildEvent.GUILD_REFRESH_BOX_EVENT)
			WindowControler:showWindow("RewardSmallBgView", reward)
			self:press_btn_close()
		else
			--错误的情况

		end
	end 


	local id = self._table.parameter[2]
	local params = {
		id = id,
	}

	GuildServer:sendPrayRewawrd(params,_callback)


end


function GuildBlessingRewardView:press_btn_close()
	
	self:startHide()
end


return GuildBlessingRewardView;
