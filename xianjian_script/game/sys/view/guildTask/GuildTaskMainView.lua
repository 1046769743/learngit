-- GuildTaskMainView
-- Author: Wk
-- Date: 2017-09-30
-- 仙盟任务主界面
local GuildTaskMainView = class("GuildTaskMainView", UIBase);

function GuildTaskMainView:ctor(winName)
    GuildTaskMainView.super.ctor(self, winName);
    self.selectDefault = nil --- 默认选择是从四个选择 第一个
end

function GuildTaskMainView:loadUIComplete()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_res, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_title, UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_wen, UIAlignTypes.LeftTop) 
	

	self.btn_back:setTouchedFunc(c_func(self.press_btn_close, self),nil,true);
	self.btn_wen:setTouchedFunc(c_func(self.clickWen, self),nil,true)


	self:registerEvent()
	self:setTopRes()
	self:initViewArr()
	self:initData()
	self:setButtonRed()




end 

function GuildTaskMainView:setTopRes()
	self.mc_res:showFrame(5)
end

function GuildTaskMainView:registerEvent()
	EventControler:addEventListener(GuildEvent.REFRESH_UI, self.countRefresh, self)
		--创建
	-- self.btn_1:setTouchedFunc(c_func(self.creaGuild, self),nil,true);
	-- --加入
	-- self.btn_2:setTouchedFunc(c_func(self.addGuild, self),nil,true);

	EventControler:addEventListener(UserEvent.USEREVENT_SP_CHANGE, self.setButtonRed, self)
	EventControler:addEventListener(CountEvent.COUNTEVENT_MODEL_UPDATE,self.countRefresh,self)

	EventControler:addEventListener(CountEvent.COUNTEVENT_MODEL_UPDATE,self.countRefresh,self)

	EventControler:addEventListener("COUNT_TYPE_FINISH_GUILD_TIMES",self.refreshWeekCountData,self)

end

function GuildTaskMainView:refreshWeekCountData()
	self:countRefresh()
end



function GuildTaskMainView:countRefresh()

	local _type = self.selectDefault

	if _type == FuncGuild.guildTask_type.ITEM then
		local data = FuncGuild.getDataByType(_type)
		self.viewArr[_type]:initData(data,_type)
	elseif _type == FuncGuild.guildTask_type.SP then
		local data = FuncGuild.getDataByType(_type)
		self.viewArr[_type]:initData(data,_type)
	elseif _type == FuncGuild.guildTask_type.TEAM then
		local data = FuncGuild.getDataByType(_type)
		self.viewArr[_type]:initData(data,_type)
	elseif _type == FuncGuild.guildTask_type.RAINK then
		-- local data = FuncGuild:getguildGloryData()
		self.viewArr[_type]:initData()
	end

	-- self:initButton()
	self:setDoubleAndFinishCount()
	self:setButtonRed()

	local sysName = FuncCommon.SYSTEM_NAME.GUILDTASK
	local isopen = FuncCommon.isSystemOpen(sysName)
	if isopen then
		self:guildTaskOpen()
	end


end

function GuildTaskMainView:refreshUI()

	self:initButton()
	self:setDoubleAndFinishCount()
	self:setButtonRed()
end

function GuildTaskMainView:initViewArr()
	self.viewArr = {
		[1] = self.UI_1,
		[2] = self.UI_1,
		[3] = self.UI_1,
		[4] = self.UI_4,
	}


end



function GuildTaskMainView:initData()
	
	-- self:initLeftData()  稍后处理
	self:initButton()
end


--- 初始化左边的数据
function GuildTaskMainView:initLeftData()

	-- self:historyCallFun()

end



--初始化右边按钮
function GuildTaskMainView:initButton()
	local panel = self.panel_bg
	--历史记录按钮
	panel.btn_1:setTouchedFunc(c_func(self.historyCallFun, self),nil,true);
	--声望排行按钮
	panel.btn_2:setTouchedFunc(c_func(self.renownRanking, self),nil,true);


	local sysName = FuncCommon.SYSTEM_NAME.GUILDTASK
	local isopen = FuncCommon.isSystemOpen(sysName)
	if isopen then
		panel.mc_1:showFrame(1)
		self:guildTaskOpen()
		self:setDoubleAndFinishCount()
		for k,v in pairs(self.viewArr) do
			v:setVisible(false)
		end
		self:inintClick(FuncGuild.guildTask_type.ITEM)
	else
		panel.mc_1:showFrame(2)
		-- self:guildTaskNotOpen()
		
		for k,v in pairs(self.viewArr) do
			v:setVisible(false)
		end
	end

end

--仙盟任务开启
function GuildTaskMainView:guildTaskOpen()
	local panel = self.panel_bg
	local panel_mc =  panel.mc_1:getViewByFrame(1)
	local taskType = FuncGuild.guildTask_type
	local mcArr = {
		[1] = panel_mc.mc_1,
		[2] = panel_mc.mc_2,
		[3] = panel_mc.mc_3,
		[4] = panel_mc.mc_4,
	}
	local button = {
		[1] = "btn_3",
		[2] = "btn_4",
		[3] = "btn_5",
		[4] = "btn_6",
	}

	local name_type = FuncGuild.guildTAsk_type_name
	for k,v in pairs(taskType) do
		local data = FuncGuild.getDataByType(v)
		local upPanel1 = mcArr[v]:getViewByFrame(1)[button[v]]:getUpPanel()
		local downPanel1 = mcArr[v]:getViewByFrame(1)[button[v]]:getDownPanel()
		local upPanel2 = mcArr[v]:getViewByFrame(2)[button[v]]:getUpPanel()
		local downPanel2 = mcArr[v]:getViewByFrame(2)[button[v]]:getDownPanel()

		local up1_txt_1 = upPanel1.txt_1
		local down1_txt_1 = downPanel1.txt_1
		local up2_txt_1 = upPanel2.txt_1
		local down2_txt_1 = downPanel2.txt_1

		up1_txt_1:setString(GameConfig.getLanguage(name_type[v]))
		down1_txt_1:setString(GameConfig.getLanguage(name_type[v]))

		up2_txt_1:setString(GameConfig.getLanguage(name_type[v]))
		down2_txt_1:setString(GameConfig.getLanguage(name_type[v]))

		local upPanel1_txt_2 = upPanel1.txt_2
		local downPanel1_txt_2 = downPanel1.txt_2

		local upPanel2_txt_2 = upPanel2.txt_2
		local downPanel2_txt_2 = downPanel2.txt_2


		if v == FuncGuild.guildTask_type.RAINK then
			local num = GuildModel._baseGuildInfo.weekCounts[tostring(v)] or 0

			local gloryData = FuncGuild:getguildGloryData()
			local count = 0
			for i=1,table.length(gloryData) do
				local data = gloryData[i]
				local rankType = data.rankType
				local plarId = GuildModel:getrenownGlorys(rankType)
				if plarId then
					count = count + 1
				end
			end
			

			upPanel1_txt_2:setString(count.."/"..table.length(gloryData))
			downPanel1_txt_2:setString(count.."/"..table.length(gloryData))
			upPanel2_txt_2:setString(count.."/"..table.length(gloryData))
			downPanel2_txt_2:setString(count.."/"..table.length(gloryData))

			
			-- if num >= table.length(gloryData) then
			-- 	upPanel1_txt_2:setString("完成")
			-- 	downPanel1_txt_2:setString("完成")
			-- 	upPanel2_txt_2:setString("完成")
			-- 	downPanel2_txt_2:setString("完成")
			-- end
		else
			local num = GuildModel._baseGuildInfo.weekCounts[tostring(v)] or 0
			upPanel1_txt_2:setString(num.."/"..data.complete)  --设置次数
			downPanel1_txt_2:setString(num.."/"..data.complete)  --设置次数
			upPanel2_txt_2:setString(num.."/"..data.complete)  --设置次数
			downPanel2_txt_2:setString(num.."/"..data.complete)  --设置次数
			-- if num >= data.complete then
			-- 	upPanel1_txt_2:setString("完成")
			-- 	downPanel1_txt_2:setString("完成")
			-- 	upPanel2_txt_2:setString("完成")
			-- 	downPanel2_txt_2:setString("完成")
			-- end
		end
		mcArr[v]:setTouchedFunc(c_func(self.inintClick,self,v),nil,true);
	end

	self:showWeekButton()
end

function GuildTaskMainView:showWeekButton()
	local panel = self.panel_bg
	local panel_mc =  panel.mc_1:getViewByFrame(1)
	local rank = GuildModel:getWeekReward()
	if rank then
		local rewardId = FuncGuild.getpopularityRankId( rank )
		panel_mc.btn_jl:setVisible(true)
		panel_mc.btn_jl:setTouchedFunc(c_func(self.getWeekReward,self,rewardId),nil,true);
	else
		panel_mc.btn_jl:setVisible(false)
	end
end


function GuildTaskMainView:getWeekReward(rewardId)

	if not GuildControler:touchToMainview() then
		return 
	end

	local function _callback(_param)
		if _param.result then
			dump(_param.result,"=====领取声望排名奖励返回数据====",8)

			local reward = _param.result.data.reward
			WindowControler:showWindow("RewardSmallBgView", reward)
		else
			if _param.error ~= nil then
				local error_code = _param.error.code 
				local tip = GameConfig.getErrorLanguage("#error"..error_code)
				WindowControler:showTips(tip)
			end
		end
		self:showWeekButton()
	end

	local params = {
		id = rewardId
	}

	GuildServer:sendRinkRewardGuildTask(params,_callback)
end


--设置双倍和完成的次数
function GuildTaskMainView:setDoubleAndFinishCount()
	local panel = self.panel_bg
	local panel_mc =  panel.mc_1:getViewByFrame(1)

	local doubleNum = FuncGuild.getGuildTaskDoubleCount()
	local finishMaxNum = FuncGuild.getGuildTaskMaxCount()

	local doubleCount = CountModel:getFinishGuildTaskNum() or 0 
	local finishCount = CountModel:getFinishGuildTaskNum() or 0 

	if finishCount >= doubleNum then
		doubleCount = doubleNum
	end

	panel_mc.txt_1:setString(GameConfig.getLanguage("#tid_guildtask_301")..":"..doubleCount.."/"..doubleNum)
	panel_mc.txt_2:setString(GameConfig.getLanguage("#tid_guildtask_302")..":"..finishCount.."/"..finishMaxNum)



end




function GuildTaskMainView:inintClick(_type)
	if not GuildControler:touchToMainview() then
		return 
	end
		
	if self.selectDefault ~= nil then
		if _type == self.selectDefault then
			return 
		end
		self.viewArr[self.selectDefault]:setVisible(false)
	end
	-- self.UI_2:setVisible(false)
	-- self.UI_3:setVisible(false)
	self.viewArr[_type]:setVisible(true)

	local panel = self.panel_bg
	local panel_mc =  panel.mc_1:getViewByFrame(1)
	for i=1,4 do
		local panel = panel_mc["mc_"..i]
		if _type == i then
			panel:showFrame(2)
		else
			panel:showFrame(1)
		end

	end


	self.selectDefault = _type


	if _type == FuncGuild.guildTask_type.ITEM then
		local data = FuncGuild.getDataByType(_type)
		self.viewArr[_type]:initData(data,_type)
	elseif _type == FuncGuild.guildTask_type.SP then
		local data = FuncGuild.getDataByType(_type)
		self.viewArr[_type]:initData(data,_type)
	elseif _type == FuncGuild.guildTask_type.TEAM then
		local data = FuncGuild.getDataByType(_type)
		self.viewArr[_type]:initData(data,_type)
	elseif _type == FuncGuild.guildTask_type.RAINK then
		-- local data = FuncGuild:getguildGloryData()
		self.viewArr[_type]:initData()
	end




end



--历史记录按钮
function GuildTaskMainView:historyCallFun()
	-- self.UI_1:setVisible(false)
	-- self.UI_2:setVisible(true)
	-- self.UI_3:setVisible(false)
	-- self.UI_4:setVisible(false)
	-- self.selectDefault = nil

	-- self.UI_2:initData()
	WindowControler:showWindow("GuildTaskHistoryView")
end

-- -声望排行
function GuildTaskMainView:renownRanking()
	-- self.UI_1:setVisible(false)
	-- self.UI_2:setVisible(false)
	-- self.UI_3:setVisible(true)
	-- self.UI_4:setVisible(false)
	-- self.selectDefault = nil

	-- self.UI_3:initData()

	WindowControler:showWindow("GuildTaskRankingView")
end



--设置按钮的红点显示
function GuildTaskMainView:setButtonRed()
	local panel = self.panel_bg.mc_1:getViewByFrame(1)
	local redArr = {
		[1] = false,
		[2] = GuildModel:getCostSpRed(),
		[3] = GuildModel:getTeamRed(),
		[4] = false,  
	}
	for i=1, 4 do
		local framePanel = panel["mc_"..i]:getViewByFrame(1)
		local panel_red = framePanel["btn_"..(i+2)]:getUpPanel().panel_red
		if panel_red then
			panel_red:setVisible(redArr[i] or false)
		end
	end

end






--帮助按钮
function GuildTaskMainView:clickWen()
	WindowControler:showWindow("GuildRulseView",FuncGuild.Help_Type.TASK)
end

function GuildTaskMainView:press_btn_close()
	EventControler:dispatchEvent(GuildEvent.REFRESH_TASK_RED_UI)
	self:startHide()
end


return GuildTaskMainView;
