--
--Author:      zhuguangyuan
--DateTime:    2018-04-20 18:12:30
--Description: 太清殿页签 -- 玄盒
--

local GuildUseBoxView = class("GuildUseBoxView", UIBase);

function GuildUseBoxView:ctor(winName)
    GuildUseBoxView.super.ctor(self, winName);
end

function GuildUseBoxView:loadUIComplete()
	self:registerEvent()
	self.Updatetime = 0
	-- self:scheduleUpdateWithPriorityLua(c_func(self.bubbles, self) ,0)
end 

function GuildUseBoxView:registerEvent()
	-- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
		--创建
	-- self.btn_1:setTouchedFunc(c_func(self.creaGuild, self),nil,true);
	-- --加入
	-- self.btn_2:setTouchedFunc(c_func(self.addGuild, self),nil,true);
	EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE, self.initData, self)

end

function GuildUseBoxView:initData()
	-- self:bubbles()
	self:pushText()
	self:threeDonationInfo()
	self:surplusCount()
	-- self:addbubblesRunaction()
end


--[[
function GuildUseBoxView:addbubblesRunaction()
	-- local delaytime_1 = act.delaytime(0.2)
	local scaleto_1 = act.scaleto(0.1,1.2,1.2)
	local scaleto_2 = act.scaleto(0.05,1.0,1.0)
	local delaytime_2 = act.delaytime(4.4)
 	local scaleto_3 = act.scaleto(0.1,0)
 	local delaytime_3 = act.delaytime(0.5)
 	local callfun = act.callfunc(function ()
 		self:bubbles()
 	end)
	local seqAct = act.sequence(act.spawn(callfun,scaleto_1),scaleto_2,delaytime_2,scaleto_3,delaytime_3)
	self.panel_qipao:runAction(act._repeat(seqAct))

end

-- --气泡
-- function GuildUseBoxView:bubbles()
-- 	-- local ischampions = false  --是否是盟主
-- 	local _str =  "为了仙盟正常的运转、提高实力，大家都多贡献自己的一份力啊"   --测试用
-- 	local panel = self.panel_qipao
-- 	panel.txt_story2:setString(_str)

-- end
--气泡
function GuildUseBoxView:bubbles()
	local sumtime = FuncGuild.getBoundsTime() 
	-- if self.Updatetime == 0 or math.fmod(self.Updatetime, sumtime) == 0 then
		local ischampions = GuildModel:judgmentIsForZBoos()  --是否是盟主
		local strtable = nil
		if ischampions then
			strtable =  {
				[1] = "#tid_group_qipao_101",
				[2] = "#tid_group_qipao_102",
				[3] = "#tid_group_qipao_103",
				[4] = "#tid_group_qipao_104",
				[5] = "#tid_group_qipao_105",
			} 
		else
			strtable =  {
				[1] = "#tid_group_qipao_103",
				[2] = "#tid_group_qipao_104",
				[3] = "#tid_group_qipao_105",
			} 
		end

		local idex = math.random(1,#strtable)
		local str = GameConfig.getLanguage(strtable[idex])
		local panel = self.panel_qipao
		panel.txt_story2:setString(str)
	-- end
	-- self.Updatetime = self.Updatetime + 1

end
]]

function GuildUseBoxView:filtrateList(eventlist)
	local newcevent = {}
	local index = 1
	for i=1,table.length(eventlist) do
		if eventlist[i] ~= nil then
			if eventlist[i].type == 9 or eventlist[i].type == 12 then
				newcevent[index] = eventlist[i]
				index = index + 1
			end
		end
	end
	return newcevent

end

function GuildUseBoxView:sortTime(arrdata)
	table.sort(arrdata,function(a,b)
        local rst = false
        if a.time < b.time then
            rst = true
        else
        	rst = false
        end
        return rst
    end)
	return arrdata

end
function GuildUseBoxView:pushText()
	self.strData = nil
	local event = GuildModel.allchatEventData
	self.strData = self:filtrateList(event) ---获得的推送的消息数据
	self.panel_xinxi:setVisible(false)
	self.strData = self:sortTime(self.strData)
	local createCellFunc = function ( itemData )
        local view = UIBaseDef:cloneOneView(self.panel_xinxi);
        self:updateItem(view,itemData)
        return view        
    end
    local newstrData = table.copy(self.strData)
	local updateCellFunc = function ( itemData ,itemView)
		self:updateItem(itemView,itemData)
	end
	local params =  {
        {
            data = newstrData,  ---alldata
            createFunc = createCellFunc,
            updateCellFunc = updateCellFunc,
            perNums = 1,
            offsetX = 20,
            offsetY = 0,
            widthGap = 0,
            heightGap = 2,
            itemRect = {x = 0, y = -40, width = 570, height = 40},
            perFrame = 0,
        }
        
    }
    self.scroll_1:cancleCacheView();
    self.scroll_1:initDragBarVisible(false);
	self.scroll_1:styleFill(params);
	self.scroll_1:hideDragBar()
	self.scroll_1:setCanScroll(false)
	self.scroll_1:gotoTargetPos(tonumber(#newstrData),1);
	-- self.scroll_1:onScroll(c_func(self.onMyListScroll, self))

  	self.oneindexcell = 1
    self.twoindexcell = 1
    self.updatetime = 1
    self.twoeTestindes = false
    if not self.luaframe then
    	-- self.luaframe = self:scheduleUpdateWithPriorityLua(c_func(self.updateFrame, self) ,0)
    end
end


function GuildUseBoxView:onMyListScroll(event)
    -- dump(event,"滚动监听事件")
    if event.name == "scrollEnd" then

    elseif event.name == "moved" then

    end
end
	
function GuildUseBoxView:updateItem(view,itemData)

	dump(itemData,"捐献返回数据",8)
	local str = GuildModel:paramGuildEvent(itemData) 
	local iconsize = {
		width = 25,
		height = 15,
		scale = 0.3
	}
	view.rich_1:setString(str,iconsize)
	-- local donation = itemData.donation or 100
	-- view.rich_2:setString(donation)
end

function GuildUseBoxView:threeDonationInfo()
	local typeNum = 3
	for i=1,typeNum do
		local data = FuncGuild.getGuildDonateBoxData(i)
		self:setDonationShowData(data,i)
	end
end
function GuildUseBoxView:setDonationShowData(data,_type)
	self["mc_".._type]:showFrame(_type)
	local mc = self["mc_".._type]:getViewByFrame(_type)
	if _type == 3 then
		mc:setVisible(false)
	end

	-- 展示捐献玄盒能获得的奖励
	-- 限定仙盟能获得回报的捐献上限
	-- 若超过上限则不再获得 资源奖励 目的是为了提示玩家不要捐得太多
	local boxId = tostring(_type)
	local hasDonateTotalNum = GuildModel:getHasDonateTotalNumByBoxId(boxId)
	local hasRewardDonateLimits = FuncDataSetting.getDataByConstantName("GuildMaxDonateBox") 
	echo("________hasDonateTotalNum < hasRewardDonateLimits ",boxId,hasDonateTotalNum,hasRewardDonateLimits )
	if hasDonateTotalNum < hasRewardDonateLimits then
		mc.mc_1:showFrame(1)
		local localMc = mc.mc_1:getViewByFrame(1)
		local costSomething = data.guildWood or data.guildStone or data.guildJade
		localMc.txt_2:setString(costSomething)
		localMc.txt_3:setString(data.coin)	
	else
		mc.mc_1:showFrame(2)
		local localMc = mc.mc_1:getViewByFrame(2)
		localMc.txt_3:setString(data.coin)	
	end

	-- 捐献耗费玄盒数量
	local table = string.split(data.cost[1],",")
	-- mc.btn_jianshe:getUpPanel().txt_4:setString(table[3])
	mc.btn_jianshe:getUpPanel().txt_4:setString("缴纳")

	-- 玩家当前拥有的玄盒数量 
	local itemId = table[2]
	local curHasBoxNum = ItemsModel:getItemNumById(itemId)
	mc.txt_5:setString(curHasBoxNum)

	-- mc.txt_ti:setString(FuncItem.getItemName(itemId))
	mc.panel_red:visible(false)
	mc.btn_jianshe:setTouchedFunc(c_func(self.donationButton, self,data,_type),nil,true);
end

function GuildUseBoxView:donationButton( data,_type )
	if not GuildControler:touchToMainview() then
		return 
	end

	local table = string.split(data.cost[1],",")
	local itemId = table[2]
	local needNum = table[3]
	local hasNum = ItemsModel:getItemNumById(itemId)
	echo("_______ 判断能不能缴纳 hasNum,needNum ___________",hasNum,needNum,itemId)
	if tonumber(hasNum) < tonumber(needNum) then
		WindowControler:showWindow("GetWayListView",itemId)
		-- WindowControler:showTips(GameConfig.getLanguage("#tid_guild_skill_1"))
		return 
	end
	self:sendServer(_type)
end


function GuildUseBoxView:sendServer(_type)
	if _type == 1 then
		echo("灵木玄盒")
	elseif _type ==  2  then
		echo("星石玄盒")
	else
		echo("陨玉玄盒")
	end

	local function _callback(_param)
		if _param.result then
			dump(_param.result,"捐box返回数据",8)
			local num = _param.result.data.wood
			-- GuildModel:setWoodCount(num)
			GuildModel:updateGuildResource(_param.result.data)
			GuildModel:updateGuildBox(_param.result.data)
			self:surplusCount()
			local eventchat = {
				param1 =  UserModel:rid(),
				param2 = _type,
				time   = TimeControler:getServerTime(),
				type   = 12,
			}
			
			GuildModel:insertDataToList(eventchat)
			-- local rewards = _param.result.data.rewards
 
	 		local typeData = FuncGuild.getGuildDonateBoxData(_type)
			self:setDonationShowData(typeData,_type)

			self:pushText()
			EventControler:dispatchEvent(GuildEvent.REFRESH_GUILD_WOOD_EVENT, {currentShopId = FuncShop.SHOP_TYPES.GUILD_SHOP})
			EventControler:dispatchEvent(GuildEvent.REFRESH_GUILD_RESOURCE_EVENT, {currentShopId = FuncShop.SHOP_TYPES.GUILD_SHOP})
			local ctn_texiao = self["ctn_texiao".._type]
			local aockAni= self:createUIArmature("UI_xianmeng", "UI_xianmeng_juanxian" ,ctn_texiao, false,function ()
				ctn_texiao:removeAllChildren()
				WindowControler:showTips(GameConfig.getLanguage("#tid_guild_skill_21")) 
			end)
		else
			--错误的情况
		end
	end 

	local donateId = _type
	GuildServer:donateBox(donateId,_callback)
end


--剩余次数
function GuildUseBoxView:surplusCount()
	-- local str = "今日剩余捐献次数:"
	-- local sumcount = FuncGuild.getDonationNumber()
	-- local count = sumcount - CountModel:getGuildDonationCount()
	-- echo("=====捐献次数==count==========",count)
	-- local x =self.txt_cishu:getPositionX()
	-- self.txt_cishu:setPositionX(x)
	-- self.txt_cishu:setString(str..count.."/"..sumcount)

	self.txt_cishu:setString(GameConfig.getLanguage("#tid_guild_skill_8"))
	
end


function GuildUseBoxView:press_btn_close()
	
	self:startHide()
end


return GuildUseBoxView;
