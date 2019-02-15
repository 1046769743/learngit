-- GuildDonationView
-- Author: Wk
-- Date: 2017-10-11
-- 公会捐献界面
local GuildDonationView = class("GuildDonationView", UIBase);

function GuildDonationView:ctor(winName)
    GuildDonationView.super.ctor(self, winName);
end

function GuildDonationView:loadUIComplete()
	self:registerEvent()
	self.updatetime = 0
	-- self:scheduleUpdateWithPriorityLua(c_func(self.bubbles, self) ,0)
end 

function GuildDonationView:registerEvent()
	EventControler:addEventListener(UserEvent.USEREVENT_TEQUAN_CHANGE, self.surplusCount, self)

    -- EventControler:addEventListener(MonthCardEvent.MONTH_CARD_RECHARGE_SUCCESS_EVENT, 
    --     self.initData, self)

    -- EventControler:addEventListener(MonthCardEvent.MONTH_CARD_TIME_OVER_EVENT, 
    --     self.initData, self)


end

function GuildDonationView:updateMonthCardTxt()
	self:delayCall(function()
		self:surplusCount()
	end,0.5)
end

function GuildDonationView:initData()
	-- self:bubbles()
	self:pushText()
	self:threeDonationInfo()
	self:surplusCount()
	-- self:addbubblesRunaction()
end


--[[
function GuildDonationView:addbubblesRunaction()
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
-- function GuildDonationView:bubbles()
-- 	-- local ischampions = false  --是否是盟主
-- 	local _str =  "为了仙盟正常的运转、提高实力，大家都多贡献自己的一份力啊"   --测试用
-- 	local panel = self.panel_qipao
-- 	panel.txt_story2:setString(_str)

-- end
--气泡
function GuildDonationView:bubbles()
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
function GuildDonationView:filtrateList(eventlist)
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

function GuildDonationView:sortTime(arrdata)
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
function GuildDonationView:pushText()
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
 --    if #self.strData >= 4 then
	--     for i=1,#self.strData do
	--     	table.insert(newstrData,self.strData[i])
	--     end
	-- end
	-- echo(#newstrData,"_____newstrData-")
	-- echo(#newstrData,"_____newstrData-")
	-- echo(#newstrData,"_____newstrData-")
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


function GuildDonationView:onMyListScroll(event)
    -- dump(event,"滚动监听事件")
    if event.name == "scrollEnd" then

    elseif event.name == "moved" then

    end
end
	
function GuildDonationView:updateItem(view,itemData)

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

function GuildDonationView:threeDonationInfo()
	local typeNum = 3
	for i=1,typeNum do
		local data = FuncGuild.getGuildDonate(i)
		self:setDonationShowData(data,i)
	end
end
function GuildDonationView:setDonationShowData(data,_type)
	self["mc_".._type]:showFrame(_type)
	local mc = self["mc_".._type]:getViewByFrame(_type)
	-- data.cost
	mc.txt_2:setString(data.guildWood)
	mc.txt_3:setString(data.guildCoin)	
	-- dump(data,"111111111111111")

	local table = string.split(data.cost[1],",")
	-- dump(table,"222222222")

	-- mc.txt_4:setString(table[2])

	mc.btn_jianshe:getUpPanel().txt_4:setString(table[2])


	mc.btn_jianshe:setTouchedFunc(c_func(self.donationButton, self,data,_type),nil,true);
end

function GuildDonationView:donationButton( data,_type )
	if not GuildControler:touchToMainview() then
		return 
	end
	local sumcount = tonumber(FuncGuild.getDonationNumber())

	local privilegeData = UserModel:privileges() 
    local additionType = FuncCommon.additionType.addition_guild_donateTimes
    local curTime = TimeControler:getServerTime()
    local isHas,value,subType = FuncCommon.checkHasPrivilegeAddition( privilegeData,additionType,curTime,nil ) 
	if isHas then
		sumcount = sumcount + value
		local count = CountModel:getGuildDonationCount()
		if count >= sumcount then
			WindowControler:showTips(GameConfig.getLanguage("#tid_guild_026")) 
			return 
		end
	else
		local count = CountModel:getGuildDonationCount()
		if count >= sumcount then
			WindowControler:showTips(GameConfig.getLanguage("#tid_group_Event_117")) 
			-- WindowControler:showWindow("MonthCardMainView",FuncMonthCard.CARDYEQIAN["3"])
			return 
		end
	end

	

	local table = string.split(data.cost[1],",")
	if table[1] == FuncDataResource.RES_TYPE.COIN then
		local  coin= UserModel:getCoin();
		if coin < tonumber(table[2]) then
			WindowControler:showTips(GameConfig.getLanguage("natal_coin_not_enough_1011")) 
			return 
		end
	elseif table[1] == FuncDataResource.RES_TYPE.DIAMOND then
		local  gold=UserModel:getGold();
		if gold < tonumber(table[2]) then
			-- WindowControler:showTips(GameConfig.getLanguage("tid_common_1001")) 
			if not UserModel:tryCost(FuncDataResource.RES_TYPE.DIAMOND, tonumber(table[2]), true) then
		        return
		    end
			return 
		end

	end


	self:sendServer(_type)
end


function GuildDonationView:sendServer(_type)
-- 
	if _type == 1 then
		echo("普通捐献")
	elseif _type ==  2  then
		echo("高级捐献")
	else
		echo("至尊捐献")
	end

	local function _callback(_param)
		if _param.result then
			-- dump(_param.result,"捐献返回数据",8)
			local num = _param.result.data.wood
			-- GuildModel:setWoodCount(num)
			GuildModel:updateGuildResource(_param.result.data)
			self:surplusCount()
			local eventchat = {
				param1 =  UserModel:rid(),
				param2 = _type,
				time   = TimeControler:getServerTime(),
				type   = 9,
			}
			
			GuildModel:insertDataToList(eventchat)
			-- local rewards = _param.result.data.rewards
 
			self:pushText()
			EventControler:dispatchEvent(GuildEvent.REFRESH_GUILD_WOOD_EVENT, {currentShopId = FuncShop.SHOP_TYPES.GUILD_SHOP})
			EventControler:dispatchEvent(GuildEvent.REFRESH_GUILD_RESOURCE_EVENT, {currentShopId = FuncShop.SHOP_TYPES.GUILD_SHOP})
			local ctn_texiao = self["ctn_texiao".._type]
			local aockAni= self:createUIArmature("UI_xianmeng", "UI_xianmeng_juanxian" ,ctn_texiao, false,function ()
				ctn_texiao:removeAllChildren()
				WindowControler:showTips(GameConfig.getLanguage("#tid_guild_027")) 
			end)
		end
	end 
	local params = {
		id = _type,
	}

	GuildServer:sendDonate(params,_callback)
end


--剩余次数
function GuildDonationView:surplusCount()
	local str = "今日剩余捐献次数:"
	local sumcount = FuncGuild.getDonationNumber()
	-- 特权添加的次数
	local privilegeData = UserModel:privileges() 
    local additionType = FuncCommon.additionType.addition_guild_donateTimes
    local curTime = TimeControler:getServerTime()
    local isHas,value,subType = FuncCommon.checkHasPrivilegeAddition( privilegeData,additionType,curTime,nil ) 
    -- dump(privilegeData,"xxxx=====xx",6)
    -- echoError("isHas,value,subType === ",isHas,value,subType)
    
    if isHas then
    	sumcount = sumcount + value
    	local count = sumcount - CountModel:getGuildDonationCount()
		self.txt_cishu:setString(str..count.."/"..sumcount )

		self.mc_kaitong:showFrame(2)

    else
    	local count = sumcount - CountModel:getGuildDonationCount()
		self.txt_cishu:setString(str..count.."/"..sumcount )

		self.mc_kaitong:showFrame(1)
		local btn_go = self.mc_kaitong.currentView.btn_kaitong
		btn_go:setTap(function ()
			WindowControler:showWindow("MonthCardMainView", FuncMonthCard.CARDYEQIAN[FuncMonthCard.card_caishen] )
		end)
    end
    local x =self.txt_cishu:getPositionX()
	self.txt_cishu:setPositionX(x)
end


function GuildDonationView:press_btn_close()
	
	self:startHide()
end


return GuildDonationView;
