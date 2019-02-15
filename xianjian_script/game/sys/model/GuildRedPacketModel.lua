-- GuildRedPacketModel.lua
local GuildRedPacketModel = class("GuildRedPacketModel", BaseModel)



-- 条件类型(1=累积充值,2=通关主线关卡,3=首次获得X星奇侠,4=登仙台排名,
-- 	5=锁妖塔完美通关,6=须臾仙境最高层数,7=无底深渊到达第几重,
-- 	8=仙界对决段位,9=激活神器数量，10=登仙台结算排名,
-- 	11=每日充值,12=每日任务完成数量,13=每日参与X次仙界对决)

GuildRedPacketModel.JUMP_VIEW = {
	--累积充值
	["1"] = {funName = function ()
					WindowControler:showTips("暂时没有充值界面")
				-- FuncCommUI.showWorldView(WorldModel.stageType.TYPE_STAGE_MAIN, targetRaid);
			end}, 
	--通关主线关卡
	["2"] =  {funName = function (packetId)
				--关卡id
				local targetRaid = FuncGuild.getRedPacketType(packetId,"condition")
				FuncCommUI.showWorldView(WorldModel.stageType.TYPE_STAGE_MAIN, targetRaid);
			end},
	-- 首次获得X星奇侠
	["3"] =  {funName = function ()
				WindowControler:showWindow("PartnerView");
			end}, 
	--=登仙台排名,
	["4"] =  {funName = function ()
				WindowControler:showWindow("ArenaMainView");
			end}, 
	--锁妖塔完美通关
	["5"] =  {funName = function ()
				
				local sysName = FuncCommon.SYSTEM_NAME.TOWER
				local open = FuncCommon.isSystemOpen(sysName)
				if open then
					WindowControler:showWindow("TowerMainView");
				else
					WindowControler:showTips( GameConfig.getLanguage("tid_common_2002"));
				end
			end}, 
	--须臾仙境层数
	["6"] =  {funName = function ()
				
				local sysName = FuncCommon.SYSTEM_NAME.WONDERLAND
				local open = FuncCommon.isSystemOpen(sysName)
				if open then
					WindowControler:showWindow("WonderlandMainView");
				else
					WindowControler:showTips( GameConfig.getLanguage("tid_common_2002"));
				end
			end}, 
	--底深渊到达第几重,
	["7"] =  {funName = function ()
				local sysName = FuncCommon.SYSTEM_NAME.ENDLESS
				local open = FuncCommon.isSystemOpen(sysName)
				if open then
					EndlessControler:enterEndlessMainView()
				else
					WindowControler:showTips( GameConfig.getLanguage("tid_common_2002"));
				end
				
			end}, 
	--仙界对决段位
	["8"] =  {funName = function ()
				local sysName = FuncCommon.SYSTEM_NAME.CROSSPEAK
				local open = FuncCommon.isSystemOpen(sysName)
				if open then
					CrossPeakModel:openCrossPeakUI()
				else
					WindowControler:showTips( GameConfig.getLanguage("tid_common_2002"));
				end
			end},  
	--激活神器数量
	["9"] =  {funName = function ()
				local sysName = FuncCommon.SYSTEM_NAME.CIMELIA
				local open = FuncCommon.isSystemOpen(sysName)
				if open then
					WindowControler:showWindow("ArtifactMainView");
				else
					WindowControler:showTips( GameConfig.getLanguage("tid_common_2002"));
				end
			end}, 
	--登仙台结算排名
	["10"] =  {funName = function ()
				WindowControler:showWindow("ArenaMainView");
			end}, 
	--每日充值
	["11"] =  {funName = function ()
				-- WindowControler:showTips("暂时没有充值界面")
				-- WindowControler:showWindow("ChatMainView");
			end},  
	-- 每日任务完成数量
	["12"] =  {funName = function ()
				WindowControler:showWindow("QuestMainView");
			end}, 
	-- 每日参与X次仙界对决
	["13"] = { funName = function ()
				local sysName = FuncCommon.SYSTEM_NAME.CROSSPEAK
				local open = FuncCommon.isSystemOpen(sysName)
				if open then
					CrossPeakModel:openCrossPeakUI()
				else
					WindowControler:showTips( GameConfig.getLanguage("tid_common_2002"));
				end
			end}, 
};


function GuildRedPacketModel:init()
	-- GuildRedPacketModel.super.init(self, d)

	self.ui_select = false
	self:registerEvent()
	self.allRedPacketData = {}
	self.notifyPacketArr = {}  --推送来的红包
	self.grabPacketData = {}

end

--获取仙盟红包数据
function GuildRedPacketModel:sendServeAllData()
	self:getServeData()
end


function GuildRedPacketModel:registerEvent()
	EventControler:addEventListener("notify_guild_red_packet_6410",self.haveCommOnRedPacket, self)
end

--有红包来了
function GuildRedPacketModel:haveCommOnRedPacket(event)
	local isaddGuild = GuildModel:isInGuild()
	if not isaddGuild then
		return 
	end

	dump(event.params,"有红包来了")
	local data = event.params.params.data
	if data ~=  nil and table.length(data) ~= 0  then
		if table.length(data) > 1 then
			self:updataRedPacketData(data)
			local arr = {"GuildRedPacketCellView","GuildWelfareMainView"}
			local save = nil 
			for k,v in pairs(arr) do
				local Windownames = WindowControler:checkCurrentViewName( v )
				if Windownames then
					save = true
				end
			end
			if not save then
				for i=1,table.length(data) do
					-- table.insert(self.grabPacketData,data[i])
					if data[i].rid ~= UserModel:rid() then
						table.insert(self.notifyPacketArr,data[i])  ---插入到推送来的红包列表
					end
				end
			end
			EventControler:dispatchEvent(GuildEvent.GUILD_REDPACKET_SHOW)
		else
			local packetData = data[1]
			self.allRedPacketData[packetData._id] = packetData
			table.insert(self.grabPacketData,packetData)
			local Windownames = WindowControler:checkCurrentViewName( "GuildWelfareMainView" )
			if not Windownames then
				if data[1].rid ~= UserModel:rid() then
					table.insert(self.notifyPacketArr,data[1])  ---插入到推送来的红包列表
				end
			end
		end
	end

	local isok =  self:countIsOk()
	if not isok then
		return
	end 
	local Windownames =  WindowControler:checkCurrentViewName( "GuildWelfareMainView" ) 
	-- local Windownames = WindowControler:getWindow( "GuildWelfareMainView" )
	if not Windownames then
		--显示到主城和战斗界面	
		if self.redPacketView == nil then
			self.redPacketView = WindowControler:createWindowNode("GuildMianPacketView")
			self.redPacketView:setName("redPacketView")
			local scene = display.getRunningScene()
			scene._topRoot:addChild(self.redPacketView)
			self:setMove(self.redPacketView)
		end
		if not self.sendRedPacketIndex then
			self.redPacketView:setVisible(true)
		else
			self.redPacketView:setVisible(false)
		end
		self.redPacketView:initData()
		local posData = LS:pub():get(StorageCode.red_packet_pos)
		local  panelPosx,panelPosy =  self:gettopRootIsHaveView()
		local x = GameVars.width/2 
		local y = 200
		if posData ~= nil then
			local data = string.split(posData,",")
			x = tonumber(data[1])
			y = tonumber(data[2])

			if panelPosx then
				if x >= panelPosx[1] and x <= panelPosx[2] and y >= panelPosy[1] and y <= panelPosy[2] then
					if x >= GameVars.height/2  then
						x = panelPosx[1] - 35 
					else
						x = panelPosx[2] + 35 
					end
					if y >= GameVars.height/2  then
						y = panelPosy[1] - 35 
					else
						y = panelPosy[2] + 35 
					end 
				end
			else
	    		if x >= GameVars.width -100 then
	    			x = GameVars.width - 100
	    		elseif x <= 0 then
	    			x = 20
	    		end
	    		if y >= GameVars.height - 20 then
	    			y = GameVars.height - 20
	    		elseif y <= 100 then
	    			y = 100
	    		end
	    	end
		end
		self.redPacketView:setPosition(cc.p(x,y))

	end
end

--判断_topRoot 上有没有共闯秘境的控件， 有返回位置 pos 
function GuildRedPacketModel:gettopRootIsHaveView()
	local scene = display.getRunningScene()
	local panel = scene._topRoot:getChildByName("redPacketView")
	if panel then
		local posx = panel:getPositionX()
		local posy = panel:getPositionY()
		-- local box = panel.:getContainerBox()
		return  {posx - 30,posx + 30},{posy - 30,posy + 30}
	end
	return
end

function GuildRedPacketModel:setMove(view)
	local scene = display.getRunningScene()
	-- local redPacketView = scene._topRoot:getChildByName("redPacketView") 
		

	local function onTouchBegan(touch, event)
			-- dump(touch,"开始 ======")
			self.repacketMove = false
            return true
        end

        local function onTouchMove(touch, event)
        	-- dump(touch,"移动 ======")
        	self.repacketMove = true
        	if self.redPacketView then
        		local x = touch.x
        		local y = touch.y
        		local  panelPosx,panelPosy =  self:gettopRootIsHaveView()
				if panelPosx then
					if x >= panelPosx[1] and x <= panelPosx[2] and y >= panelPosy[1] and y <= panelPosy[2] then
						return
					end
				end
        		if x >= GameVars.width -100 then
        			x = GameVars.width - 100
        		elseif x <= 0 then
        			x = 20
        		end
        		if y >= GameVars.height - 20 then
        			y = GameVars.height - 20
        		elseif y <= 100 then
        			y = 100
        		end

        		self.redPacketView:setPosition(cc.p(x,y))

        	end
        end

        local function onTouchEnded(touch, event)  
        	-- dump(touch,"结束 ======")
        	if not self.repacketMove then
        		self:openRedPacket()
        	else
        		LS:pub():set(StorageCode.red_packet_pos,touch.x..","..touch.y)
        	end
        	-- if self.redPacketView then
        	-- 	self.redPacketView:setPosition(cc.p(touch.x,touch.y))
        	-- end
        	
        end

        view:setTouchedFunc(GameVars.emptyFunc, nil, true, 
        onTouchBegan, onTouchMove,
         GameVars.emptyFunc, onTouchEnded)

       -- view:setTouchedFunc(onTouchEnded, nil, true, 
       --          onTouchBegan, onTouchMove);
end

function GuildRedPacketModel:openRedPacket()

	local Windownames =  WindowControler:getWindow( "GuildRedPacketCellView" )
	if Windownames then
		return 
	end

	local isok =  self:countIsOk()
	if not isok then
		if self.redPacketView then
			self.redPacketView:initData()
		end
		return
	end



	local data = self.notifyPacketArr
	local count = 0
	if data ~= nil then
		count = table.length(data)
	end
	local packetData = data[count]

	if packetData  then
	-- dump(packetData,"======主城界面红包点击获取=======")
		local function cellback()
			GuildRedPacketModel:removeMainRedPacket(packetData)
			self.redPacketView:initData()
		end
		
		WindowControler:showTopWindow("GuildRedPacketCellView",packetData,cellback,true)
	else
		WindowControler:showTips(GameConfig.getLanguage("#tid_group_guild_1508"));
	end

end

---刷新红包数据
function GuildRedPacketModel:updataRedPacketData(data)
	local isaddGuild = GuildModel:isInGuild()

	if not isaddGuild then
		return 
	end

	self.allRedPacketData = {}--所有红包数据
	local newArr = {}
	for k,v in pairs(data) do
		-- v.id = k
	 	self.allRedPacketData[v._id] = v
	end
	-- dump(self.allRedPacketData,"---------2222222-------------")

	self.sendPacketData = {}  --发送红包的数据

	self.grabPacketData = {}  --抢的红包的数据

	local index = 1
	local index_2 = 1
	local alldata = UserModel:redPackets()

	for k,v in pairs(data) do
		-- v.id = k
		if v.expireTime == 0 then
			if v.rid == UserModel:rid() then
				self.sendPacketData[index] = v
				index = index + 1
			-- else
			-- 	self.grabPacketData[index_2] = v
			-- 	index_2 = index_2 + 1
			end
		else
			self.grabPacketData[index_2] = v
			index_2 = index_2 + 1
		end
	end


	local function sortFunc(a, b)
		if tonumber(a.packetId) < tonumber(b.packetId) then
			return true
		else
			return false
		end
	end
	if table.length(self.sendPacketData) ~= 0 then
		table.sort(self.sendPacketData, sortFunc)
	end
	if table.length(self.grabPacketData) ~= 0 then
		table.sort(self.grabPacketData, sortFunc)
	end
end

--标记抢过的红包
function GuildRedPacketModel:tagGrabPacketDataById(alldata,packetId)
	local num = 0
	for k,v in pairs(alldata) do
		if type(v) == "table" then
			if v.rid == UserModel:rid() then
				num = v.num
			end
		end
	end
	local data = {
		name = UserModel:name(),
		num = num,
		rid  = UserModel:rid(),
	}
	-- dump(self.grabPacketData,"=======抢红包数据 0000========")
	-- dump(alldata,"=======抢红包数据 111111========")
	for k,v in pairs(self.grabPacketData) do
		if v._id == packetId then 
			self.grabPacketData[k].details = alldata
		end
	end
	-- dump(self.grabPacketData,"=======抢红包数据 222222========")
end

--删除发过的红包
function GuildRedPacketModel:removeSendPacketDataById(packetId)
	if self.sendPacketData ~= nil then
		for k,v in pairs(self.sendPacketData) do
			if v.packetId == packetId then
				table.remove(self.sendPacketData,k)
			end
		end
	end
	-- UserModel._data.redPackets[tostring(packetId)] = { status = 0 }
end

---今日领取数量
function GuildRedPacketModel:dailyGetNum()
	-- if self.allRedPacketData ~= nil then
	-- 	for k,v in pairs(self.allRedPacketData) do
	-- 		if v.details ~= nil then
	-- 			for _k,_v in pairs(v.details) do
	-- 				if _v.rid == UserModel:rid() then
	-- 					count = count + 1
	-- 				end
	-- 			end
	-- 		end
	-- 	end
	-- end
	local count = CountModel:getRedPacketNum()
	-- dump(self.allRedPacketData,"---------33333333333-------------")
	return count 
end


--红包的领取状态
function GuildRedPacketModel:getPacketStatus(packetId)
	local grab_type = FuncGuild.redPacket_State_Type.GET
	-- dump(self.allRedPacketData ,"33333333333333====")
	local data = self.allRedPacketData[tostring(packetId)]
	-- dump(data ,"33333333333333====0000")
	if  data ~= nil then
		local id = data.packetId
		local num = FuncGuild.getRedPacketType(id,"num")
		if num ~= nil then
			if data.index ~= nil then
				local isget = false
				if data.details ~= nil then
					for k,v in pairs(data.details) do
						-- echo("======11111111111===========",v.rid,UserModel:rid())
						if type(v) == "table" then
							if v.rid == UserModel:rid() then
								isget = true
								grab_type = FuncGuild.redPacket_State_Type.IN_GET
							end
						end
					end
				end
				if not isget then
					if data.index >= num then
						grab_type = FuncGuild.redPacket_State_Type.IN_GET_ALL
					end
				end
			end
		end
	end
	return 	grab_type
	
end



--获取红包跳转
function GuildRedPacketModel:goToRedPacketPathView(packetId)

	local packetId_type = FuncGuild.getRedPacketType(packetId,"type")
	 local jumpInfo = GuildRedPacketModel.JUMP_VIEW[tostring(packetId_type)];
	if jumpInfo ~= nil then
		if jumpInfo.funName ~= nil  then 
            jumpInfo.funName(packetId)
        end
    end 
end



---获得所有每日和成就红包列表
function GuildRedPacketModel:getPathAllData()
	local dailyQuest,achievementData = FuncGuild.getRedPacketAllList()
	local alldata = UserModel:redPackets()
	-- if table.length(alldata) == 0 then
	-- 	alldata = UserModel:redPackets()
	-- end
	-- dump(alldata,"刷新红包数据 ======= ")
	-- self.allRedPacketData

	-- dump(self.grabPacketData,"======UserModel:redPackets()=======")
	
	local dailyArr = {}
	for k,v in pairs(dailyQuest) do
		local packetId = v.id
		local isok = self:completeConditionsAndCount(packetId)
		local infoData = nil
		for _k,_v in pairs(alldata) do
			if tostring(_k) == tostring(packetId) then
				-- if _v.rid == UserModel:rid() then
					if _k == "1001" or _k == "1301" then
						if _v.expireTime ~= nil then
							local time = _v.expireTime -- - 24*60*60   --知道是什么时候发的
							if TimeControler:getServerTime() <= time then
								isok = true
							end
						end
					end
				-- end
			end
		end
		if not isok then
			table.insert(dailyArr,v)
		end
	end
	
	local achievementArr = {}
	for i=1,#achievementData do
		local v = achievementData[i]
		local _type = tostring(v.type) 
		local id = v.id
		local pre = v.pre
		local isok_1 = false
		if _type == FuncGuild.Conditions_Type.TOWER then
			if alldata[tostring(id)] ~= nil then
				isok_1 = true 
			end
		end
		if not isok_1 then
			if achievementArr[_type] ~= nil then
				if alldata[pre] ~= nil then
					if alldata[tostring(id)] == nil then
						achievementArr[_type][id] = v
					end
				end
			else
				local isok = self:completeConditionsAndCount(pre or id)
				local sour_type = FuncGuild.getRedPacketType(pre or id,"type")
				if _type == FuncGuild.Conditions_Type.TOWER then
					if alldata[tostring(id)] ~= nil then
						isok = true 
					else
						isok = false
					end
				end

				if not isok then
					achievementArr[_type] = {}
					achievementArr[_type][id] = v
				else
					local isok = self:completeConditionsAndCount(id)
					local sour_type = FuncGuild.getRedPacketType(id,"type")
					if sour_type == FuncGuild.Conditions_Type.TOWER then
						if alldata[tostring(id)] ~= nil then
							isok = true
						else
							isok = false
						end
					end
					if not isok then
						achievementArr[_type] = {}
						achievementArr[_type][id] = v
					end
				end
			end
		end
	end

	local newachievementArr = {}
	-- for i=1,#achievementArr do
	for k,v in pairs(achievementArr) do
		for _k,_v in pairs(v) do
			table.insert(newachievementArr,_v)
		end
	end
	local function sortFunc(a, b)
		if a.id < b.id then
			return true
		else
			return false
		end
	end
	table.sort(newachievementArr, sortFunc)

	-- dump(newachievementArr,"22222222222222222222222222")
	return dailyArr,newachievementArr
end




--判断条件是否完成
function GuildRedPacketModel:completeConditionsAndCount(packetId)


	--主线是否完成
	local function isFinishRaid()
		local curRaid = UserExtModel:getMainStageId();
		local targetRaid = FuncGuild.getRedPacketType(packetId, "condition");
		if  tonumber(curRaid) >= tonumber(targetRaid) then
			return  true,1
		else
			return false,0
		end
	end


	--伙伴
	local function isFinishPartnerStar()
		local star = FuncGuild.getRedPacketType(packetId, "condition")
		--获得有几个大于star参数星级的伙伴	
		local haveNum = PartnerModel:partnerNumGreaterThenParamStar(star-1); 
		if haveNum > 0 then
			return true,haveNum
		end
		return  false,haveNum
	end

	local function isArtifactNumFinish()
		local costNeed = tonumber( FuncGuild.getRedPacketType(packetId, "condition"));
		local sumnum,signnum = ArtifactModel:activeArtifactNum()
		if sumnum >= costNeed then
			return true,sumnum;
		else
			return false,sumnum;
		end
	end
	local function isWonderlandFinish()
		local maxFloor = WonderlandModel:getAllMaxFloor()
		local max  = tonumber( FuncGuild.getRedPacketType(packetId, "condition"));
		if maxFloor >= max then
			return true,1
		end
		return false,0
	end

	local function isDailyQuestFinish()
		local num = DailyQuestModel:getDailyQuestCount()
		local maxCount  = tonumber( FuncGuild.getRedPacketType(packetId, "condition"));
		-- echoError("======num=========",num,maxCount)
		if num >= maxCount then
			return true,num
		end

		return false,num
	end

	
	local function isEndlessFinish()
		local maxfloor = EndlessModel:getCurrentTopFloor()
		local needMaxfloor  = tonumber( FuncGuild.getRedPacketType(packetId, "condition"));
		if tonumber(maxfloor) >= tonumber(needMaxfloor) then
			return true,1
		else
			return false,0
		end
	end


	local function isTowerFinish()
		-- local maxfloor = TowerMainModel:getPerfectFloor() or 0
		local needMaxfloor  = tonumber( FuncGuild.getRedPacketType(packetId, "condition"));
		local isok = TowerMainModel:checkIsPerfectPass( needMaxfloor )
		if isok then
			return true,1

		else
			return false,0
		end
	end


	local function isPvpRankFinish()
		local maxRank = PVPModel:pvpPeakRank()
		local needMaxRank  = tonumber( FuncGuild.getRedPacketType(packetId, "condition"));
		if maxRank <= needMaxRank then
			return true,1
		else
			return false,0
		end
	end

	local function isCrossPeakFinish()
		local segment = CrossPeakModel:getMaxSegment( )
		local needSegment  = tonumber( FuncGuild.getRedPacketType(packetId, "condition"));
		if tonumber(segment) >= needSegment then
			return true,1
		else
			return false,0
		end
	end

	local function isCrossPeakCountFinish()
		local count = CountModel:getCrossZhanNum()
		local needCount  = tonumber( FuncGuild.getRedPacketType(packetId, "condition"));
		if tonumber(count) >= needCount then
			return true,count
		else
			return false,count
		end
	end

	local function isGoldCostFinish()
		local cost = UserModel:totalCostGold();
		local costNeed  = tonumber( FuncGuild.getRedPacketType(packetId, "condition"));
		if tonumber( cost) >= tonumber(costNeed) then 
			return true,cost
		else 
			return false,cost
		end 
	end


	local  function pvpRankChalleng()
		local count = CountModel:getPVPChallengeCount()
		local rank = 1000
		local costNeed  = tonumber( FuncGuild.getRedPacketType(packetId, "condition"));
		if tonumber( rank) <= tonumber(costNeed) and count >= 1 then 
			return true,1
		else 
			return false,0
		end 
	end


	
 	local _type = FuncGuild.getRedPacketType(packetId, "type")

 	if _type == FuncGuild.Conditions_Type.TOP_UP then --累积充值,
 		return false,0

 	elseif _type == FuncGuild.Conditions_Type.MAIN_LINE then --通关主线关卡,
 		return isFinishRaid()
 	elseif _type == FuncGuild.Conditions_Type.PARTNER then --首次获得X星奇侠,
 		return isFinishPartnerStar()
 	elseif _type == FuncGuild.Conditions_Type.PVP then --登仙台排名,
 		return isPvpRankFinish()

 	elseif _type == FuncGuild.Conditions_Type.TOWER then --锁妖塔完美通关,
 		return isTowerFinish()

 	elseif _type == FuncGuild.Conditions_Type.WONDERLAND then --须臾仙境最高层数,
 		return isWonderlandFinish()

 	elseif _type == FuncGuild.Conditions_Type.ENDLESS then --无底深渊到达第几重,
 		return isEndlessFinish()

 	elseif _type == FuncGuild.Conditions_Type.CROSSPEAK then --仙界对决段位,
 		return  isCrossPeakFinish()

 	elseif _type == FuncGuild.Conditions_Type.CIMELIA then --激活神器数量
 		return isArtifactNumFinish()

 	elseif _type == FuncGuild.Conditions_Type.PVP_END then --登仙台排名,
 		return false,0--pvpRankChalleng()
 	elseif _type == FuncGuild.Conditions_Type.DAILY_TOP_UP then ---每日充值,
 		return false,0

 	elseif _type == FuncGuild.Conditions_Type.TASK then --每日任务完成数量,

 		return isDailyQuestFinish()
 	elseif _type == FuncGuild.Conditions_Type.DAILY_CROSSPEAK then ---每日参与X次仙界对决
 		return isCrossPeakCountFinish()--isGoldCostFinish() --isCrossPeakCountFinish()

 	end



end


function GuildRedPacketModel:getServeData(cellFunc)
	local isaddGuild = GuildModel:isInGuild()
	if not isaddGuild then
		return 
	end
	local function _callback(event)
		if event.result then
			local data = event.result.data.packets
			self:updataRedPacketData(data)
		end
		if cellFunc then
			cellFunc()
		end
	end
	GuildServer:getRedPacketLast(_callback)
	
end

--有红包和没有红包排序
function GuildRedPacketModel:packetSorthaveAndNot()
	local data = GuildRedPacketModel.grabPacketData or {}

	for k,v in pairs(data) do
		-- local playdata  = GuildModel:getMemberInfo(v.rid)
		-- if playdata then
			local packetId = v.packetId
			local get_type = self:getPacketStatus(v._id)
			if get_type == FuncGuild.redPacket_State_Type.GET then
				v.get = 1
			else
				v.get = 0
			end
		-- end
	end

	local gettable = {}
	local notArrr = {}

	for k,v in pairs(data) do
		if v.get ~= nil then
			if v.get == 1 then
				table.insert(gettable,v)
			else
				table.insert(notArrr,v)
			end
		end
	end

	local function sortFunc(a, b)
		if tonumber(a.expireTime) < tonumber(b.expireTime) then
			return true
		end
		return false
	end
	table.sort(gettable, sortFunc)
	table.sort(notArrr, sortFunc)

	for i=1,#notArrr do
		table.insert(gettable,notArrr[i])
	end


	return gettable

end

function GuildRedPacketModel:countIsOk()
	local count = GuildRedPacketModel:dailyGetNum()
	local maxcount =  FuncGuild.getMaxRedPacketCount()

	if count >= maxcount then
		return false
	end
	return true
end




--抢红包的红点
function GuildRedPacketModel:grabRedPacketRed()
	local isok =  self:countIsOk()
	if not isok then
		return false
	end

	local count = GuildRedPacketModel:dailyGetNum()
	local maxcount =  FuncGuild.getMaxRedPacketCount()
	if count >= maxcount then
		return false
	end

	local alldata = self:packetSorthaveAndNot()
	for k,v in pairs(alldata) do
		local packetId = v._id
		local get_type = GuildRedPacketModel:getPacketStatus(packetId)   --领取状态s
		if get_type == FuncGuild.redPacket_State_Type.GET then
			return true
		end
	end

	return false
end


--发送红包红点
function GuildRedPacketModel:sendRedPacketRed()
	-- local isok =  self:countIsOk()
	-- if not isok then
	-- 	return false
	-- end


	local data = self.sendPacketData or {}
	local count = table.length(data)
	if count == 1 then
		if data[1].nothave then
			return false
		end
	end
	
	if count >= 1  then
		return true
	end
	return false
end



--抢红包
function GuildRedPacketModel:grabRedpacket(itemData,cellFunc,_file)
	echo("===========抢红包ID=========",itemData._id)
	local count = GuildRedPacketModel:dailyGetNum()
	local maxcount =  FuncGuild.getMaxRedPacketCount()

	if count >= maxcount then
		WindowControler:showTips(GameConfig.getLanguage("#tid_guild_redpacket_002"));
		return 
	end
	local function _callback(event)
		if event.result then
			-- dump(event.result,"======抢红包返回的数据======")
			local details = event.result.data.details
			details.packetId = itemData.packetId
			details.rid = itemData.rid
			details._id = itemData._id

			local Windownames =  WindowControler:getWindow( "GuildHongBaoInfoView" )
			if Windownames then
				Windownames:press_btn_close()
			end
			
			local allData =  GuildRedPacketModel.allRedPacketData
			if allData then
				local itemData = allData[details._id]
				if itemData then
					WindowControler:showTopWindow("GuildHongBaoInfoView",details,true);
				end
			end
			if _file == nil then
				self:tagGrabPacketDataById(details,itemData._id)
			end
			-- local decs = GameConfig.getLanguage("#tid_guild_redpacket_007")
			-- WindowControler:showTips(decs)
			if  cellFunc   then
				cellFunc()
			end
		else
			if event.error.code == 640502 then
				WindowControler:showTips(GameConfig.getLanguage("#tid_guild_redpacket_012"))
			elseif event.error.code == 640701 then
				WindowControler:showTips(GameConfig.getLanguage("#tid_guild_redpacket_013"))
			end
			local function callback()
				if  cellFunc   then
					cellFunc()
				end
			end
			self:getServeData(callback)

		end
		
	end

	local params = {
		id = itemData._id
	}

	GuildServer:grabRedPacket(params,_callback)
end


function GuildRedPacketModel:removeMainRedPacket(itemdata)
	local data = self.notifyPacketArr
	if data ~= nil then
		for k,v in pairs(data) do
			if v._id == itemdata._id then
				table.remove(self.notifyPacketArr,k)
			end
		end
	end
end


function GuildRedPacketModel:deleteData(data)
	GuildRedPacketModel.super.deleteData(self, data)

end


function GuildRedPacketModel:setPlayerHead(_ctn,_avatar,_headId, _scale)
    local headId = _headId 
    local scale = _scale or 1
    local icon = FuncUserHead.getHeadIcon(headId,_avatar) 
    icon = FuncRes.iconHero(icon)
    local iconSprite = display.newSprite(icon)
    local artMaskSprite = display.newSprite(FuncRes.iconOther("partner_tou"))
    artMaskSprite:anchor(0.5,0.5)
    local headSprite = FuncCommUI.getMaskCan(artMaskSprite,iconSprite)
    headSprite:setScale(scale)
    _ctn:addChild(headSprite)
  
end

function GuildRedPacketModel:setPlayerFrame(_ctn,headFrameId, _scale)
    local icon = FuncUserHead.getHeadFramIcon(headFrameId)
    local scale = _scale or 1
    icon = FuncRes.iconHero(icon)
    local iconSp = display.newSprite(icon)
    iconSp:anchor(0.5,0.5)
    iconSp:setScale(scale)
    _ctn:addChild(iconSp)
end


--设置标签是否是自己发送的红包
function GuildRedPacketModel:setSendRedPacketIndex(_file)
	self.sendRedPacketIndex = _file
end

GuildRedPacketModel:init()
return GuildRedPacketModel
