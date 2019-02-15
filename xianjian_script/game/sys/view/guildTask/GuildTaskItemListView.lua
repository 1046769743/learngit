-- GuildTaskItemListView
-- Author: Wk
-- Date: 2017-09-30
-- 仙盟任务上交材料界面
local GuildTaskItemListView = class("GuildTaskItemListView", UIBase);

function GuildTaskItemListView:ctor(winName)
    GuildTaskItemListView.super.ctor(self, winName);
    self.selectType = 1 --默认选择 1
end

function GuildTaskItemListView:loadUIComplete()
	
	self:initData()
	self:registerEvent()
end 

function GuildTaskItemListView:registerEvent()
	-- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
		--创建
	-- self.btn_1:setTouchedFunc(c_func(self.creaGuild, self),nil,true);
	-- --加入
	-- self.btn_2:setTouchedFunc(c_func(self.addGuild, self),nil,true);
	self:registClickClose("-1")

	self.UI_1.btn_close:setTouchedFunc(c_func(self.press_btn_close, self),nil,true);
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_guild_task_3005")) --"上交材料")#tid_guild_task_3005
	self.UI_1.mc_1:showFrame(1)
	self.UI_1.mc_1:getViewByFrame(1).btn_1:setTouchedFunc(c_func(self.sureButton, self),nil,true);

end

function GuildTaskItemListView:sureButton()
	
	-- dump(self.data[self.selectType],"  ============= 选中的数据 ======")
	local reward = self.data[self.selectType].condition[1]
	local  needNum,hasNum,isEnough ,resType,resId = UserModel:getResInfo(reward)
	-- echo("========11111======",needNum,hasNum,isEnough ,resType,resId)
	if not isEnough then
		WindowControler:showTips(GameConfig.getLanguage("#tid_guild_task_3004")) --"资源不足,不能提交")
		return 
	end

	local isok = GuildModel:taskFanishIsAll()
	if isok then
		WindowControler:showTips(GameConfig.getLanguage("#tid_guild_task_3001"))  --"当日任务数量已到最大值")
		return
	end	



	local function _callback(_param)
		if _param.result then
			dump(_param.result,"任务完成返回数据===111==",8)
			local _type = FuncGuild.guildTask_type.ITEM
			GuildModel:setWeekCountNum(_type,1)

			local reward = _param.result.data.reward
			WindowControler:showWindow("RewardSmallBgView", reward)

			local eventchat = {
				param1 =  UserModel:rid(),
				param2 = self.data[self.selectType].id,
				time   = TimeControler:getServerTime(),
				type   = 13,
			}
			GuildModel:insertDataToList(eventchat)


			local  complete = self.data[self.selectType].complete
			local num = GuildModel._baseGuildInfo.weekCounts[tostring(_type)] or 0
			if num == complete then
				local woodnums =  GuildModel:getWoodCount()
				GuildModel:setWoodCount(woodnums + self.data[self.selectType].guildWood or 100)
				EventControler:dispatchEvent(GuildEvent.GUILD_REFRESH_WOOD_EVENT)
			end


			WindowControler:showTips(GameConfig.getLanguage("#tid_guild_task_3003")) --"资源提交成功")
			EventControler:dispatchEvent(GuildEvent.REFRESH_UI)
		else
			if _param.error ~= nil then
				local error_code = _param.error.code 
				local tip = GameConfig.getErrorLanguage("#error"..error_code)
				WindowControler:showTips(tip)
			end
		end
	end


	local params = {
		id = self.data[self.selectType].id
	}

	GuildServer:sendFinishGuildTask(params,_callback)




	-- 发送协议
end

function GuildTaskItemListView:initData()
	local _type = FuncGuild.guildTask_type.ITEM
	local allData = FuncGuild.ClassguildTask()
	self.data = allData[_type]

	local function sortFunc(a, b)
		if a.id < b.id then
			return true
		else
			return false
		end
	end
	table.sort(self.data, sortFunc)

	for i=1,3 do
		self["panel_"..i]:setVisible(false)
		self["panel_"..i]:setTouchedFunc(c_func(self.setSelect, self,i),nil,true);
	end

	for i=1,#self.data do
		if self["panel_"..i] then
			self["panel_"..i]:setVisible(true)
			self["panel_"..i].panel_2:setVisible(false)
			if self.selectType == i then
				self["panel_"..i].panel_2:setVisible(true)
			end
			local reward = self.data[i].condition[1]
			local view = self["panel_"..i]["UI_"..i]
			view:setResItemData({reward = reward})
			view:showResItemNum(true)
			view:showResItemName(true)
			-- local  needNum,hasNum,isEnough ,resType,resId = UserModel:getResInfo(reward)
   --      	FuncCommUI.regesitShowResView(view, resType, needNum, resId,reward,true,true)
		end
	end

end

function GuildTaskItemListView:setSelect(_type)
	if _type == self.selectType then
		return 
	end
	self["panel_".._type].panel_2:setVisible(true)
	self["panel_"..self.selectType].panel_2:setVisible(false)
	self.selectType = _type
end



function GuildTaskItemListView:press_btn_close()
	
	self:startHide()
end


return GuildTaskItemListView;
