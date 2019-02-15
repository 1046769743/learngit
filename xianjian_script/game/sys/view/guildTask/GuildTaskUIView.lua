-- GuildTaskUIView
-- Author: Wk
-- Date: 2017-09-30
-- 仙盟任务界面
local GuildTaskUIView = class("GuildTaskUIView", UIBase);

function GuildTaskUIView:ctor(winName)
    GuildTaskUIView.super.ctor(self, winName);
end

function GuildTaskUIView:loadUIComplete()
	self:registerEvent()
end 

function GuildTaskUIView:registerEvent()
	-- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
		--创建
	-- self.btn_1:setTouchedFunc(c_func(self.creaGuild, self),nil,true);
	-- --加入
	-- self.btn_2:setTouchedFunc(c_func(self.addGuild, self),nil,true);
	
end


function GuildTaskUIView:initData(_data,_type)
	self._data = _data
	self._type = _type

	--委托人
	local des2 = self._data.des2
	self.txt_1:setString(GameConfig.getLanguage(des2))

	--任务描述
	local des1 = self._data.des1
	self.rich_1:setString(GameConfig.getLanguage(des1))

	if _type == FuncGuild.guildTask_type.SP then
		local  condition =  self._data.condition[1]
		local myselfData = CountModel:getGuildTaskCostSPNum()
		des1 =  FuncTranslate._getLanguageWithSwap(des1,math.abs(myselfData),condition)
		self.rich_1:setString(des1)
	elseif _type == FuncGuild.guildTask_type.TEAM then
		local  condition =  self._data.condition[1]
		local myselfData = CountModel:getGuildTaskTeamNum()
		des1 =  FuncTranslate._getLanguageWithSwap(des1,myselfData,condition)
		self.rich_1:setString(des1)
	end




	local renown  = self._data.popularity
	self.panel_r.txt_1:setString(renown)
	self.panel_r.panel_1:setVisible(false)
	self.panel_r:setTouchedFunc(c_func(self.showTipe, self),nil,true);

	local reward = self._data.reward
	for i=1,2 do
		self["UI_"..i]:setVisible(false)
		-- setResItemData({reward = itemdata})
		self["panel_double"..i]:setVisible(false)
	end

	for i=1,#reward do
		self["panel_double"..i]:setVisible(true)
		self["UI_"..i]:setVisible(true)
		self["UI_"..i]:setResItemData({reward = reward[i]})
		local  needNum,hasNum,isEnough ,resType,resId = UserModel:getResInfo(reward[i])
        FuncCommUI.regesitShowResView(self["UI_"..i], resType, needNum, resId,reward[i],true,true)
	end

	local doubleNum = FuncGuild.getGuildTaskDoubleCount()
	local doubleCount = CountModel:getFinishGuildTaskNum() or 0 
	if doubleCount >= doubleNum then
		self.panel_double1:setVisible(false)
		self.panel_double2:setVisible(false)
	end
	


	local wood = self._data.guildWood
	local txt_1 =  self.panel_p.panel_qipao.txt_1
	txt_1:setString(wood)
	self:setButton()
	self:setProgressRes()
	-- self:setRewardButton()

end


function GuildTaskUIView:showTipe()
	self.panel_r.panel_1:setVisible(true)
	self:delayCall(function ()
		if self then
			if self.panel_r then
				if self.panel_r.panel_1 then
					self.panel_r.panel_1:setVisible(false)
				end
			end
		end
	end,2.0)
end
---设置finish按钮
function GuildTaskUIView:setButton()
	if self._type == FuncGuild.guildTask_type.ITEM then
		FilterTools.clearFilter(self.btn_1)
		self.btn_1:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_guildtask_116"))
		self.btn_1:setTouchedFunc(c_func(self.itemSubmit, self),nil,true);
	else
		self.btn_1:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_guildtask_117"))
		self.btn_1:setTouchedFunc(c_func(self.finishBtn, self),nil,true);

		local isok = self:panduanFileIsok()
		if isok then
			FilterTools.clearFilter(self.btn_1)
		else
			FilterTools.setGrayFilter(self.btn_1)
		end


	end
end

function GuildTaskUIView:panduanFileIsok()
	
	local _type = self._type
	local data = FuncGuild.getDataByType(_type)

	local finishcondition = 0
	local condition = tonumber(data.condition[1])

	if _type == FuncGuild.guildTask_type.SP then
		finishcondition = math.abs(CountModel:getGuildTaskCostSPNum())
	elseif _type == FuncGuild.guildTask_type.TEAM then
		finishcondition =  math.abs(CountModel:getGuildTaskTeamNum())
	end

	if finishcondition < condition then
		return false
	end

	return true
end


function GuildTaskUIView:finishBtn()

	if not GuildControler:touchToMainview() then
		return 
	end

	local _type = self._type
	local data = FuncGuild.getDataByType(_type)

	local isok = GuildModel:taskFanishIsAll()
	if isok then
		WindowControler:showTips(GameConfig.getLanguage("#tid_guild_task_3001"))  --"当日任务数量已到最大值")
		return
	end
	local isok = self:panduanFileIsok()
	if not isok then
		WindowControler:showTips(GameConfig.getLanguage("#tid_guild_task_3006")) --"任务未完成")
		return 
	end

	local function _callback(_param)
		if _param.result then
			dump(_param.result,"任务完成返回数据==222===",8)
			GuildModel:setWeekCountNum(_type,1)


			local reward = _param.result.data.reward
			WindowControler:showWindow("RewardSmallBgView", reward)

			local eventchat = {
				param1 =  UserModel:rid(),
				param2 = data.id,
				time   = TimeControler:getServerTime(),
				type   = 13,
			}
			
			GuildModel:insertDataToList(eventchat)

			local  complete = self._data.complete
			local num = GuildModel._baseGuildInfo.weekCounts[tostring(self._type)] or 0
			if num == complete then
				local woodnums =  GuildModel:getWoodCount()
				GuildModel:setWoodCount(woodnums + self._data.guildWood or 100)
				EventControler:dispatchEvent(GuildEvent.GUILD_REFRESH_WOOD_EVENT)
			end

			WindowControler:showTips(GameConfig.getLanguage("#tid_guild_task_3007")) --"任务完成")
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
		id = data.id
	}

	GuildServer:sendFinishGuildTask(params,_callback)
end

--道具提交
function GuildTaskUIView:itemSubmit()

	if not GuildControler:touchToMainview() then
		return 
	end

	local isok = GuildModel:taskFanishIsAll()
	if isok then
		WindowControler:showTips(GameConfig.getLanguage("#tid_guild_task_3001")) --"当日任务数量已到最大值")
		return
	end
	WindowControler:showWindow("GuildTaskItemListView")
end


--设置进度条
function GuildTaskUIView:setProgressRes()
	local  complete = self._data.complete
	local num = GuildModel._baseGuildInfo.weekCounts[tostring(self._type)] or 0
	local count = num
	self.panel_p.progress_1:setPercent((count/complete)*100)
	self.panel_p.txt_1:setString(count.."/"..complete)

	-- if count >= complete then
	-- 	self.panel_p.btn_1:getUpPanel().mc_box:showFrame(2)
	-- else
	-- 	self.panel_p.btn_1:getUpPanel().mc_box:showFrame(1)
	-- end
end


--设置宝箱按钮
function GuildTaskUIView:setRewardButton()
	local btn = self.panel_p.btn_1
	self.panel_qipao:setVisible(false)
	btn:setTouchedFunc(function()
		if not self.touchBox  then
			self.touchBox = true
			self.panel_qipao:setOpacity(0)
			self.panel_qipao:setVisible(true)
			local fadeout = act.fadeto( 0.5,0 )
			local fadein = act.fadeto( 0.5,255 )
			local delaytime = act.delaytime(1.0)
			local callfunc = act.callfunc(function ()
				self.touchBox = false
				self.panel_qipao:setVisible(false)
			end)
			local sequence = act.sequence(fadein,delaytime,fadeout,callfunc)
			self.panel_qipao:runAction(sequence)
		end
	end,nil,true);
end


function GuildTaskUIView:press_btn_close()
	
	self:startHide()
end


return GuildTaskUIView;
