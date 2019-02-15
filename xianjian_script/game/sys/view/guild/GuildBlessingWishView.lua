-- GuildBlessingWishView
-- Author: Wk
-- Date: 2017-10-11
-- 公会心愿界面
local GuildBlessingWishView = class("GuildBlessingWishView", UIBase);

function GuildBlessingWishView:ctor(winName)
    GuildBlessingWishView.super.ctor(self, winName);
end

function GuildBlessingWishView:loadUIComplete()
	self:registerEvent()
	-- self:setButton()
	self:initData()
end 

function GuildBlessingWishView:registerEvent()
	EventControler:addEventListener(GuildEvent.REFRESH_WISH_LIST_EVENT, self.initData, self)
	EventControler:addEventListener(GuildEvent.REFRESH_TREASURE_MAIN_VIEW, self.initData, self)
		--创建
	-- self.btn_1:setTouchedFunc(c_func(self.creaGuild, self),nil,true);
	-- --加入
	-- self.btn_2:setTouchedFunc(c_func(self.addGuild, self),nil,true);
end

function GuildBlessingWishView:sortTime(arrdata)
	table.sort(arrdata,function(a,b)
        local rst = false
        if a._time > b._time then
            rst = true
        else
        	rst = false
        end
        return rst
    end)
	return arrdata

end



function GuildBlessingWishView:initData()
	GuildControler:getWishList()
	self.celldata = {}

	local alldata  =  GuildModel:getAllWishList()  ---服务数据

	alldata = self:sortTime(alldata)
	self.panel_1:setVisible(false)
	if #alldata ~= 0 then
		self.txt_zwxy:setVisible(false)
	else
		self.txt_zwxy:setVisible(true)
	end


	local createCellFunc = function ( itemData )
        local view = UIBaseDef:cloneOneView(self.panel_1);
        self:updateItem(view,itemData)
        return view        
    end

    local function updateCellFunc( itemData, view )
		self:updateItem(view, itemData)
	end
	local params =  {
        {
            data = alldata,  ---alldata
            createFunc = createCellFunc,
            -- updateCellFunc = updateCellFunc,
            perNums = 1,
            offsetX = 2,
            offsetY = 0,
            widthGap = 0,
            heightGap = 5,
            itemRect = {x = 0, y = -145, width = 913, height =145},
            perFrame = 1,
        }
        
    }
    self.scroll_1:cancleCacheView();
	self.scroll_1:styleFill(params)

	self.recordtime = 1
	self:scheduleUpdateWithPriorityLua(c_func(self.updateFrame, self) ,0)

	self:setButton()

end

function GuildBlessingWishView:updateFrame()
	self.recordtime = self.recordtime + 1
	if math.fmod(self.recordtime, 30) == 0 then
		for i=1,#self.celldata do
			local cell = self.celldata[i]
			if cell ~= nil then
				local servetime = TimeControler:getServerTime()
				local expireTime = cell.itemData._time
				local shenyuitems = expireTime - servetime 
				-- echo("========shenyuitems=========",shenyuitems,expireTime,servetime)
				if shenyuitems ~= 0  then
					local panel = cell.view.panel_1
					-- panel.txt_3:setVisible(true)
					local loacltime = self:timeToHouse(shenyuitems)
					panel.txt_3:setString(loacltime)
				else
					GuildModel:removeWish(cell.itemData)
					self.celldata = {}
					self:initData()
				end
			end
		end
		if self.cdTime ~= nil and self.cdTime ~= 0 then
			-- echo("========self.cdTime========",self.cdTime)
			local times = self.cdTime - TimeControler:getServerTime()
			if times >= 0 then
				local time = self:timeToHouse(times)
				self.btn_wodxy:getUpPanel().txt_1:setString(time)
			else 
				self.btn_wodxy:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_guild_015"))
				self.btn_wodxy:setTouchedFunc(c_func(self.mydesire, self),nil,true);
				FilterTools.clearFilter(self.btn_wodxy);
			end
		end
	end
end


--[[
	local itemdata = {
		partnerID = partnerID,  ---伙伴ID
		playerName = item.name,
		PartnerName = PartnerName,
		guildID = item.guildtype or 1, 
		_time = item._time,  ---发送时间
		hasnum = item.hasnum or 0,
		position = item.position,
	}
]]

function GuildBlessingWishView:updateItem(view,itemData)
	local itemdata = {
		view = view,
		itemData = itemData,
	}
	table.insert(self.celldata,itemdata)
	-- dump(itemData,"控件数据",8)
	local panel = view.panel_1
	local name = itemData.playerName  --玩家名字
	-- local _type = FuncGuild.guildType[itemData.guildID]
	local sendtime = itemData._time  --"9:00"
	local partnername = itemData.ItemName--"碎片名字"
	local _partnerId = itemData.ItemID--  --碎片ID
	local guildID = itemData.guildID
	local position = itemData.position

	local num = ItemsModel:getItemNumById(_partnerId)  ---拥有碎片个数
	local guildname = FuncGuild.byIdAndPosgetName(guildID,position)

	panel.txt_1:setString(name)
	panel.txt_2:setString(guildname)


	local servetime = TimeControler:getServerTime()


	local loacltime = self:timeToHouse(sendtime - servetime)
	panel.txt_3:setString(loacltime)


	view.txt_1:setString(partnername)
	local _str = string.format(GameConfig.getLanguage("#tid_guild_016"), tostring(num))  
	view.txt_2:setString(_str)
	local reward = self:screenData(_partnerId)
	view.UI_1:setResItemData({reward = reward })

	self:setnum(view,itemData)

	if itemData._id == UserModel:rid() then
		FilterTools.setGrayFilter(view.btn_1);
		FilterTools.clearFilter(self.btn_wodxy);
		view.btn_1:setTouchedFunc(c_func(self.myselfSendItem, self,itemData),nil,true);
		-- view.txt_2:setVisible(true)
	else
		-- view.txt_2:setVisible(false)
	end

end

---- 返回这个碎片id在哪个cost组
function GuildBlessingWishView:screenData( ItemID )
	local alldata = {}
	for i = 1,table.length(FuncGuild.getAllExchangeData()) do
		for j = 1,table.length(FuncGuild.getAllExchangeData()[i].cost) do
			local reward = FuncGuild.getAllExchangeData()[i].cost[j]
			local data = string.split(reward,",")
			if ItemID == data[2] then
				return reward
			end
		end
	end
end

function GuildBlessingWishView:setnum(view,itemData)

	local guildLevel = GuildModel:getGuildLevel()
	local guildLvdata = FuncGuild.getGuildLevelByPreserve(guildLevel)
	-- local neednum = tonumber(guildLvdata.blessingNum)  ---需要几个
	local neednum = 1
	local hasnum = itemData.hasnum ---现在捐献几个

	view.panel_progress.txt_1:setString(hasnum.."/"..neednum)
	if hasnum >= neednum then
		FilterTools.setGrayFilter(view.btn_1);
		view.btn_1:setTouchedFunc(c_func(self.isfullgiveawaybutton, self,itemData),nil,true);
	else
		FilterTools.clearFilter(view.btn_1);
		view.btn_1:setTouchedFunc(c_func(self.giveawaybutton, self,itemData,view),nil,true);
	end
	local percent = self:getpercent(hasnum,neednum)
	view.panel_progress.progress_1:setPercent(percent)
end


function GuildBlessingWishView:myselfSendItem()
	if not GuildControler:touchToMainview() then
		return 
	end 
	WindowControler:showTips(GameConfig.getLanguage("#tid_guild_017"))

end

function GuildBlessingWishView:timeToHouse(time)
	local h = math.floor(time/3600)
    local s = math.floor((time-h*3600)/60)
    local m = math.fmod(time,60)
    local timestring = ""
    if  string.len(m) ~= 2 then
        m = "0"..m
    end
    if  string.len(s) ~= 2 then
        s = "0"..s
    end
    if h ~= 0 then
        if  string.len(h) ~= 2 then
            h = "0"..h
        end
        if s ~= 0 then
            timestring = h..":"..s..":"..m
        end
    else
        if s ~= 0 then
            timestring = s..":"..m
        else
            timestring = m
        end
    end
    return timestring
end





function  GuildBlessingWishView:FormatChatTime(_time)
    -- echo("_time ===============",_time)
       local    _format;
       _format=os.date("%X",_time)--//string.format("%02d:%02d",math.floor(_time/3600),math.floor(_time%3600/60));
       local timeData = os.date("*t",_time)
       return _format  --timeData.month.."-"..timeData.day.." ".._format;
end

function GuildBlessingWishView:getpercent(hasnum,neednum)
	local percent = (hasnum*100)/neednum
	return percent
end

function GuildBlessingWishView:isfullgiveawaybutton()
	if not GuildControler:touchToMainview() then
		return 
	end
	WindowControler:showTips(GameConfig.getLanguage("#tid_guild_018")) 
end

function GuildBlessingWishView:giveawaybutton(itemData)
	if not GuildControler:touchToMainview() then
		return 
	end
	-- echo("=======赠送按钮======")
	-- dump(itemData,"需要的赠送数据",8)
	local itemId = itemData.ItemID
	local num = ItemsModel:getItemNumById(itemId)
	if num == nil or num == 0 then 
		WindowControler:showTips(GameConfig.getLanguage("#tid_guild_019"))
		return
	else
		self:sendGivingOP(itemData)
	end

end
function GuildBlessingWishView:sendGivingOP(itemData)
	
	local function _callback(_param)
		if _param.result then
			dump(_param.result,"赠送返回数据返回",8)

			itemData.hasnum = itemData.hasnum + 1
			local _cell = self.scroll_1:getViewByData(itemData);
			self:setnum(_cell,itemData)
			-- GuildModel:setWishAppconut(itemData)
			local  ctn_texiao = _cell.ctn_texiao
			local aockAni= self:createUIArmature("UI_xianmeng", "UI_xianmeng_zengsong" ,ctn_texiao, false,function ()
				ctn_texiao:removeAllChildren()
			end)
			-- aockAni:setPosition(cc.p())

			local _partnerId = itemData.ItemID--"5001"  --伙伴ID
			local num = ItemsModel:getItemNumById(_partnerId)  ---拥有碎片个数
			local _str = string.format(GameConfig.getLanguage("#tid_guild_016"), tostring(num))
			_cell.txt_2:setString(_str) 
			WindowControler:showTips(GameConfig.getLanguage("#tid_guild_020"))
			
			-- local datares = FuncDataSetting.getDataByHid("BlessChivalrous")
			-- if datares ~= nil then
			-- 	if datares.num ~= nil then
			-- 		local rewards = "17,"..datares.num  ---赠送侠义值
			-- 		if rewards ~= nil then
			-- 			FuncCommUI.startRewardView({rewards})
			-- 		end
			-- 	end
			-- end
		else
			--错误和没查找到的情况
		end
	end 
	local params = {
		trid = itemData._id
	}

	GuildServer:sendHelpWish(params,_callback)
end


function GuildBlessingWishView:setButton()
	self.btn_lsjl:setTouchedFunc(c_func(self.historicalrecords, self),nil,true);


	local file ,time = GuildModel:getPleaseAddCount()
	if file == false then
		FilterTools.setGrayFilter(self.btn_wodxy);
		self.btn_wodxy:setTouchedFunc(c_func(self.buttonsetGray, self),nil,true);
		self.cdTime = time
	else
		FilterTools.clearFilter(self.btn_wodxy);
		self.btn_wodxy:setTouchedFunc(c_func(self.mydesire, self),nil,true);
	end

end

function GuildBlessingWishView:buttonsetGray()
	WindowControler:showTips(GameConfig.getLanguage("#tid_guild_021")) 
end

--历史记录
function GuildBlessingWishView:historicalrecords()
	if not GuildControler:touchToMainview() then
		return 
	end
	echo("=======历史记录======")
	GuildControler:getWishEvent()
	-- WindowControler:showWindow("GuildHistorRecView")
end

--我的心愿
function GuildBlessingWishView:mydesire()
	if not GuildControler:touchToMainview() then
		return 
	end
	echo("=======我的心愿======")
	local wishSign = true
	local count = GuildModel:isTodaySendWish()
	if count == 0 then
		WindowControler:showWindow("GuildShouJiListView",1,wishSign)
	else
		WindowControler:showTips("今天已经完成心愿")
	end

end

function GuildBlessingWishView:press_btn_close()
	
	self:startHide()
end


return GuildBlessingWishView;
