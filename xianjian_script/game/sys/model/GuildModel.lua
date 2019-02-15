--guan
--2016.1.12

--[[
	这里的数据没有走自动更新逻辑, 所有数据必须进一次公会才能取到
]]

local GuildModel = class("GuildModel",BaseModel);



function GuildModel:ctor()

end

function GuildModel:init()
	echo("________GuildModel:ctor_______");

	-- self:initbaseGuildInfo()
	--只有改这些key是合法的
	-- self._baseInfoKey = {
	-- 	["_id"] = true,
	-- 	["level"] = true,
	-- 	["exp"] = true,
	-- 	["icon"] = true,
	-- 	["needApply"] = true,
	-- 	["desc"] = true,
	-- 	["notice"] = true,
	-- };

	--[[
	self._membersInfo =
	{
		_id = {
		    /* 成员ID */
		    optional string _id = 1;
		    /* 权限 */
		    optional int32 right = 2;
		    /* 名称 */
		    optional string name = 3;
		    /* 等级 */
		    optional int32 level = 4;
		    /* 境界 */
		    optional int32 state = 5;
		    /* vip */
		    optional int32 vip = 6;
		    /* 头像 */
		    optional int32 avatar = 7;
		    /* 战力 */
		    optional int32 ability = 8;
		    /* 离线时间 */
		    optional int32 logoutTime = 9;
		    /* 累积贡献 */
		    optional int32 guildCoin = 10;
		} , ……
	}
	]]
	
	--接受事件 todo

	self.guildName = {    ----仙盟名称和类型
		name = 1,
		_type = 1,
	}
	self.guildIcon = {   ----仙盟图标
		borderId = 1,
		bgId = 1,
		iconId = 1,
	}

	self.iscreateGuild = false
	self.appAddnum = 0 ---记入
	self._baseGuildInfo = {}
	self._membersInfo = {};   ---成员数据
	self.selectAddGuildType = 0   ---入盟是否需要申请   0 不需要  1 需要
	self.selectShowAll = 1   ----0是未选中 1 --是选中  显示所有公会
	self.allWishDataList = {}  ---仙盟中心愿的玩家
	self._guildcharinfo = {}   ---盟主的数据 
	self.chatEventData = {} --仙盟事件 
	self.allchatEventData = {}  --所有的仙盟事件列表
	self.inviteDataList = {}   ---推荐邀请的玩家数据列表
	self.guildAllList = {}  ---所有可以加入的仙盟
	self.guildApplyList = {}  ---所有申请入会的列表
	self.invitedToList = {}  ---受邀玩家数据列表
	self.sendHisListText = {} ---赠送心愿的历史记录
	self.bonusList = {} ---红利列表
	self.prayReList = {}  ---祈福列表
	self.MySelfGuildDataList = {} ---自身公会的数据
	self.del_membersInfo = {}

	self.eventchatIndexsaver  = {}  ---捐献文本记录下表
	self.onLinePlayer = {}

	self.rankDataList = {}   --仙盟任务完成排行数据

	self:registerEvent()

	self:initEventListener()
	-- self:getguildpeopleData()


	self.boxExchangCount = 0 --记入宝箱兑换的次数


	-- self:appToMe()

	self:getRankAllData()

	-- WindowControler:globalDelayCall(function ()
	-- 	self:sendHomeMainViewRed()
 -- 	end,1)
end


function GuildModel:registerEvent()
	EventControler:addEventListener(GuildEvent.CREATE_GUILD_OK_EVENT, self.sendHomeMainViewRed, self)
	EventControler:addEventListener(GuildEvent.REFRESH_SIGN_EVENT, self.sendHomeMainViewRed, self)
	EventControler:addEventListener(GuildEvent.REFRESH_BOUNS_EVENT, self.sendHomeMainViewRed, self)
	EventControler:addEventListener(GuildEvent.GET_QIFU_REWARD, self.sendHomeMainViewRed, self)
	EventControler:addEventListener(GuildEvent.CLOSE_ADD_GUILD_VIEW_EVENT, self.sendHomeMainViewRed, self)
	EventControler:addEventListener(GuildEvent.GUILD_REFRESH_invite_EVENT, self.sendHomeMainViewRed, self)
	EventControler:addEventListener(GuildEvent.GUILD_ONTIME_REFRESH_UI, self.toTimeDeleteWood, self)
	EventControler:addEventListener("notify_guild_remove_player_1356",self.removeGuildID, self)
	EventControler:addEventListener("notify_guild_add_1330",self.addGuildNotify, self)

	EventControler:addEventListener("notify_guild_reject_1358",self.isrejectApp, self)

	--其他玩家发送申请
	EventControler:addEventListener("notify_guild_beapp_1378",self.appToMe, self)

	

	EventControler:addEventListener(GuildEvent.GUILD_ACTIVITY_REDPOINT_CHANGED, self.sendHomeMainViewRed, self)
	EventControler:addEventListener("COUNT_TYPE_FINISH_GUILD_TIMES",self.refreshWeekCountData,self)
end


	
function GuildModel:refreshWeekCountData()
	echo("======到达刷新时间======")
	local serveTime = TimeControler:getServerTime()
    local dataTime = os.date("%w", serveTime)
    if dataTime == "1" then
    	self._baseGuildInfo.weekCounts = {}
    	self.refreshgetRank = true
    end
    EventControler:dispatchEvent(GuildEvent.REFRESH_UI)
    
end

function GuildModel:appToMe()


	local isaddGuild = GuildModel:isInGuild()
	if not isaddGuild then
		return 
	end

	
	local callfun = function ()
		self:sendHomeMainViewRed()
		EventControler:dispatchEvent(GuildEvent.REFRESH_SIGN_EVENT)
	end
	GuildControler:getAppList(callfun)
	
end

function GuildModel:isrejectApp(event)
	-- dump(event.params,"拒绝申请返回数据")
	local data =  event.params.params.data
	local playerid = data.id


	-- dump(UserModel._data,"所有人身上的数据")
	local guildExt = UserModel._data.guildExt--().applys
	if guildExt ~= nil then
		local applys  = guildExt.applys
		if applys ~= nil then
			for k,v in pairs(applys) do
				if k == playerid then
					UserModel._data.guildExt.applys[k] = 1  --1 没申请 -- 非1是申请
				end
			end
		end
	end
	
end


function GuildModel:addGuildNotify(event)
	-- dump(event.params,"加入公会书数据")
	local data =  event.params.params.data

	UserModel._data.guildId = data.id
	GuildControler:getMemberList()

end

function GuildModel:removeGuildID(event)
	-- local guild =  UserModel:guildId() 
	-- dump(event.params,"被剔除返回数据")
	local data =  event.params.params.data
	local playerid = data.id

	echo("==========逐出仙盟队伍=========")
	local guild =  UserModel:guildId()
	local guildExt = UserModel._data.guildExt--().applys
	if guildExt ~= nil then
		local applys  = guildExt.applys
		if applys ~= nil then
			for k,v in pairs(applys) do
				if k == playerid then
					UserModel._data.guildExt.applys[k] = 1  --1 没申请 -- 非1是申请
				end
			end
		end
	end
	
	self.iscreateGuild = false
	UserModel._data.guildId = ""
	EventControler:dispatchEvent(GuildEvent.GUILD_QUILT_EVENT)
	EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
				{ redPointType = HomeModel.REDPOINT.DOWNBTN.GUILD, isShow = false})
end


--主城上红点的显示
function GuildModel:sendHomeMainViewRed()
	local isSignred = self:signShowRed()
	local isBonusred = self:bonusListRed() or GuildRedPacketModel:grabRedPacketRed() or GuildRedPacketModel:sendRedPacketRed()
	local isblessred = self:blessingRed()
	local isdonationRed = self:donationRed() 
	local isGVEbossred  = self:isShowGuildActRedPoint()
	local isapplyred = self:applysDataRed()
	-- local isapplyred = GuildModel:applysDataRed()
	local isTaskRed =  self:getTaskRed()
	local isred = GuildExploreModel:getEntranceRed()
	local isaddGuild = self:isInGuild()

	if isaddGuild then

		EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
				{ redPointType = HomeModel.REDPOINT.DOWNBTN.GUILD, isShow = isSignred or isBonusred or isblessred or isdonationRed or isGVEbossred or isapplyred or  isTaskRed or isred})
	else
		EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
				{ redPointType = HomeModel.REDPOINT.DOWNBTN.GUILD, isShow = false})

	end

end
function GuildModel:getbuildRedTable()
	local red = {
		[2] = self:bonusListRed(),
		[3] = self:blessingRed(),
	}
	return red
end

--判断祈福红点
function GuildModel:blessingRed()
	--  祈福次数
	local count = CountModel:getGuildPrayCount()
	--  心愿次数
	local num = self:getPleaseAddCount()
	if count == nil or count == 0 then
		return true
	end
	if num == nil or num == 0 then
		local partnerdata = GuildModel:getAllPartnerData()
		if #partnerdata ~= 0 then
			return true
		end
	end

	local alldata = FuncGuild.getAllExchangeData()
	for k,v in pairs(alldata) do
		local isred = GuildModel:boxExchanegIsShowRed(k)
		if isred then
			return true
		end
	end

	--有可以领取的宝箱
	-- local level = self._baseGuildInfo.level
	-- local data = FuncGuild.getGuildLevelByPreserve(tostring(level))
	-- local percentpeople = self._baseGuildInfo.prayCount or 0   --祈福人数
	-- local prayReCount = self:getPrayReCount()
	-- for i=1,3 do
	-- 	local sum = data["paryNum"..i]   --5  10  15
	-- 	if percentpeople >= sum then
	-- 		if prayReCount[i] ~= 2 then
	-- 			return true
	-- 		end
	-- 	end
	-- end
	

	return false
end


--判断签到是否显示红点
function GuildModel:signShowRed()
	-- local count =  CountModel:getGuildSignCount()
	-- if count == nil or count == 0 then
	-- 	return true
	-- end
	return false
end

--判断红利红包  账房
function GuildModel:bonusListRed()
	local bonusList = self:getbonusList()
	for i=1,#bonusList do
		if bonusList[i] == nil or bonusList[i] == 0 then
			return true
		end
	end
	return false
end

--公会红利。账房红点
function GuildModel:getbonusList()
	local count = CountModel:getGuildbonusOneCount()
	local _counttable = FuncGuild.byCountTypeGetTable(count)

	self.bonusList = {
		[1] = _counttable[1],--CountModel:getGuildbonusOneCount(),
		[2] = _counttable[2], --CountModel:getGuildbonusTowCount(),
		[3] = _counttable[3],--CountModel:getGuildbonusThreeCount(),
	}	
	return self.bonusList
end



function GuildModel:getPrayReCount()
	local count = CountModel:getGuildPrayReOneCount()
	local _counttable = FuncGuild.byCountTypeGetTable(count)
	-- echo("=======count============",count)
	-- dump(_counttable,"2222222222222222")


	local one = _counttable[1]--CountModel:getGuildPrayReOneCount()
	local two = _counttable[2]--CountModel:getGuildPrayReTowCount()
	local three = _counttable[3]--CountModel:getGuildPrayReThreeCount()
	-- local count = CountModel:getGuildPrayCount()
	if one == 0 then
		one = 1
	else
		one = 2
	end
	if two == 0 then
		two = 1
	else
		two = 2
	end
	if three == 0 then
		three = 1
	else
		three = 2
	end

	self.prayReList = {
		[1] = one,
		[2] = two,
		[3] = three,
	}
	return self.prayReList
end

function GuildModel:initEventListener()
	EventControler:addEventListener("notify_guild_app_1328", self.guildAppAddList, self);
end
function GuildModel:guildAppAddList(_param)
	dump(_param.params,"推送邀请给我的数据",7)
	-- GuildControler:getGuildInfoData()
	local data = _param.params.params.data
	data._id = data.guildId
	table.insert(self.invitedToList,data)
	dump(self.invitedToList,"邀请给我的数据")
	EventControler:dispatchEvent(GuildEvent.GUILD_invite_EVENT)
	EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
				{ redPointType = HomeModel.REDPOINT.DOWNBTN.GUILD, isShow = true})
end

function GuildModel:removeinvitedToList(itemdata)
	dump(self.invitedToList,"邀请给我的数据======")
	for i=1,#self.invitedToList do
		if self.invitedToList[i] then
			if self.invitedToList[i]._id == itemdata._id then
				table.remove(self.invitedToList,i)
			end
		end
	end
	dump(self.itemdata,"邀请给我的数据")
end
--[[
	"推送邀请给我的数据" = {
    "method" = 1328
    "params" = {
        "data" = {
            "guildId"    = "1008"
            "leaderName" = "斧风云物语"
            "level"      = 1
            "name"       = "自行车"
        }
        "serverTime" = 1508798078678
    }
}


]]

---设置申请入会的列表
function GuildModel:setguildApplyList( datalist )
	self.guildApplyList = datalist
end
--删除申请同意和拒绝的玩家数据
function GuildModel:removeAppData(appID)
	dump(self.guildApplyList,"4444444444444 =====11111")
	for k,v in pairs(self.guildApplyList) do
		if appID == v._id then
			table.remove(self.guildApplyList,k)
		end
	end
	dump(self.guildApplyList,"4444444444444 =====22222")
end

function GuildModel:setInviteDataList(datalist)
	self.inviteDataList = datalist
end


function GuildModel:setceshi()
	self.ceshi = true
end

--获取仙盟群号
function GuildModel:getGroupID()
	return self._baseGuildInfo.groupID
end

--获取仙盟群号
function GuildModel:setGroupID(groupID)
	self._baseGuildInfo.groupID = groupID
end

function GuildModel:setbaseGuildInfo(infodata)
	--prayExpireTime" = 1509566400

	-- dump(infodata,"111111111111111111111111")

	self._baseGuildInfo =	{
	    -- /* 公会ID */
		_id = infodata._id,
		-- 公会显示ID
		markId = infodata.markId,
	    -- /* 创建时间 */
	    ctime = infodata.ctime,
	    -- /* 名称 */
	    name = infodata.name,
	    -- /* 等级 */
	    level = infodata.level,
	    -- /* 经验 */
	    exp = infodata.exp,
	    -- /* 图标 */
	    icon = infodata.icon,
	    -- /* 需要审核 */
	    needApply = infodata.needApply,
	    -- /* 会长ID */
	    leaderId = infodata.leaderId,
	    -- /* 宣言 */
	    desc = infodata.desc or FuncGuild.getdefaultDec(),
	    -- /* 成员数 */
	    members = infodata.members,
	    -- /* 公告 */ 
	    notice  =  infodata.notice or FuncGuild.getdefaultNotice(),
	    -- /* 类型 */
	    _type = infodata.afterName,
	    -- 祈福人数
	    prayCount = infodata.prayCount or 0,
	    prayExpireTime = infodata.prayExpireTime or 0,

	    groupID = infodata.qqGroup or "88888888",

	    wood = infodata.wood or 0,
	    jade = infodata.jade or 0,
	    stone = infodata.stone or 0,

	    woodCostTime = infodata.woodCostTime,
	    ---建筑升级推送
	    votes = {
	    	[1] = 0,
			[2] = 0,
			[3] = 0,
			[4] = 0,
			[6] = 0,
		},	

	    builds = {
	    	[1] = infodata.builds[tostring(1)],
	    	[2] = infodata.builds[tostring(2)],
	    	[3] = infodata.builds[tostring(3)],
	    	[4] = infodata.builds[tostring(4)] or 1,
	    	[5] = infodata.builds[tostring(4)] or 1,
	    	[6] = infodata.builds[tostring(6)] or 1,
	    	
		},  
		lastGveTime = infodata.lastGveTime or nil,
		food  = infodata.food  or {},
		gveMembers  = infodata.gveMembers  or {},
		gveTeams  = infodata.gveTeams  or {},
		applys = infodata.applys or {},
		--
		guildBoss = infodata.guildBoss or {},  --历史数据
		guildBossCount = infodata.guildBossCount or 0,
		guildBossCountExpireTime = infodata.guildBossCountExpireTime ,
		guildBossId = infodata.guildBossId or 0,
		counts = infodata.counts or {},  -- 当天仙盟内各种玄盒已经捐献的数量
		skillGroups = infodata.skillGroups or {},   -- 仙盟内某个主题的技能精研等级(解锁才有)
		weekCounts =  infodata.weekCounts or {},
		renownGlorys = infodata.renownGlorys or {},
	}
	-- dump(infodata.votes,"444444444444")
	-- if infodata.votes then
	-- 	self._baseGuildInfo.votes = {
	-- 		[1] = infodata.votes[tostring(1)],
	--     	[2] = infodata.votes[tostring(2)],
	--     	[3] = infodata.votes[tostring(3)],
	-- 	}
	-- end
	-- dump(self._baseGuildInfo.votes,"33333333333333")

	if infodata.notice == nil or infodata.notice == "" then
		self._baseGuildInfo.notice =  FuncGuild.getdefaultNotice()
	end

	local leftTime =  FuncCommon.byTimegetleftTime(TimeControler:getServerTime())
	TimeControler:startOneCd( GuildEvent.GUILD_ONTIME_REFRESH_UI,leftTime )

	self.allchatEventData ={}
	if infodata.events ~= nil then
		local index = 1
		for k,v in pairs(infodata.events) do
			self.allchatEventData[index] = v
			index = index + 1
		end
	end

	self.guildName = {    ----仙盟名称和类型
		name = infodata.name,
		_type = infodata.afterName,
	}
	self.guildIcon = {   ----仙盟图标
		borderId = infodata.logo or 1,
		bgId = infodata.color or 1,
		iconId = infodata.icon or 1,
	}

	self.memberExts = infodata.memberExts or {}

	self.selectAddGuildType = infodata.needApply or 0
	UserModel._data.guildName = infodata.name

	self.refreshgetRank = true
end


function GuildModel:setWeekCountNum(_type,num)
	local arr = self._baseGuildInfo.weekCounts[tostring(_type)]
	if arr == nil then
		self._baseGuildInfo.weekCounts[tostring(_type)] = 1
	else
		self._baseGuildInfo.weekCounts[tostring(_type)] = arr + 1
	end

	dump(self._baseGuildInfo.weekCounts,"222222222222")
end

--寻仙问道的数据
function GuildModel:getrenownGlorys(_type)
	
	local renownGlorys = self._baseGuildInfo.renownGlorys
	local playId = renownGlorys[tostring(_type)]
	if playId then
		return playId
	end
	return nil
end

function GuildModel:setrenownGlorys(data)
	-- local renownGlorys = self._baseGuildInfo.renownGlorys
	for k,v in pairs(data) do
		if self._baseGuildInfo.renownGlorys ~= nil then
			self._baseGuildInfo.renownGlorys[tostring(k)] = v
		end
	end
end





--获取创建仙盟时间
function GuildModel:getcreateguildtime()
	local createtime = self._baseGuildInfo.ctime
	local time = FuncGuild.getCreateTime( createtime )
	return time
end
 
 --获取仙盟boss 相关数据
function GuildModel:getGuildBossData()
	local guildBossData = {
	   guildBossMaxPassId = self._baseGuildInfo.guildBossId,
	   guildBoss = self._baseGuildInfo.guildBoss,
	   guildBossCount           = self._baseGuildInfo.guildBossCount,
	   guildBossCountExpireTime = self._baseGuildInfo.guildBossCountExpireTime,
	}
	return guildBossData
end

--仙盟申请数据
function GuildModel:applysDataRed()
	local data =  self.guildApplyList  --self._baseGuildInfo.applys
	if table.length(data) ~= 0 then
		return true
	end
	return  false
end

function GuildModel:setbaseInfoapplys(rid)
	local applysData =self._baseGuildInfo.applys
	for k,v in pairs(applysData) do
		if k == rid then
			applysData[k] = nil
		end
	end
end

function GuildModel:setvotes( infodata )
	if infodata then
		for k,v in pairs(infodata) do
			self._baseGuildInfo.votes[tonumber(k)] = v
			--  {
			-- 	[1] = infodata.votes[tostring(1)],
		 --    	[2] = infodata.votes[tostring(2)],
		 --    	[3] = infodata.votes[tostring(3)],
			-- }
		end
	end
end

----设置审核数据
function GuildModel:setneedApply(needApply)
	self._baseGuildInfo.needApply = needApply
	self.selectAddGuildType = needApply
end

--获取建议某个建筑升级的数量
function GuildModel:getBuildsVotes()
	return self._baseGuildInfo.votes or {}
end

--获得建筑相关数据
function GuildModel:getBuildsLevel()
	return self._baseGuildInfo.builds or {}
end

function GuildModel:setBuildsLevel(builddata)
	for k,v in pairs(builddata) do
		self._baseGuildInfo.builds[tonumber(k)] = v
	end
	self._baseGuildInfo.level = self._baseGuildInfo.builds[1] or 1
end

---设置灵木的数量
function GuildModel:setWoodCount(num)
	self._baseGuildInfo.wood = num
end
--获取灵木
function GuildModel:getWoodCount()
	return self._baseGuildInfo.wood or 0
end



-- 更新仙盟 一天时间内所有成员捐献的玄盒数量
-- 隔天会清0
function GuildModel:updateGuildBox(data)
	if not data or not data.counts then
		return 
	end
	if data.counts then
		self._baseGuildInfo.counts = data.counts
	end
end

---更新仙盟资源 石材 星石 陨玉的数量
function GuildModel:updateGuildResource(data)
	if not data then
		return 
	end

	if data.stone then
		self._baseGuildInfo.stone = data.stone
	end

	if data.wood then
		self._baseGuildInfo.wood = data.wood
	end

	if data.jade then
		self._baseGuildInfo.jade = data.jade
	end
end

-- 更新仙盟技能组提升到的阶段
function GuildModel:updateSkillGroupsData( data )
	-- dump(data, "=================       desciption")
	if data.skillGroups then
		for skillId,level in pairs(data.skillGroups) do
			if not self._baseGuildInfo.skillGroups[tostring(skillId)] then
				self._baseGuildInfo.skillGroups[tostring(skillId)] = 0 
			end
			self._baseGuildInfo.skillGroups[tostring(skillId)] = level
		end
	end	
end
--- 获取拥有的木材
function GuildModel:getOwnGuildWoodNum()
	return self._baseGuildInfo.wood or 0
end
--- 获取拥有的陨玉
function GuildModel:getOwnGuildJadeNum()
	return self._baseGuildInfo.jade or 0
end
-- 获取拥有的星石
function GuildModel:getOwnGuildStoneNum()
	return self._baseGuildInfo.stone or 0
end

-- 获取盟内成员已经捐献的玄盒数量
function GuildModel:getHasDonateTotalNumByBoxId( boxId )
	if not boxId then
		return 0
	end
	if self._baseGuildInfo and self._baseGuildInfo.counts then
		for type1,value in pairs(self._baseGuildInfo.counts) do
			if tostring(type1) == tostring(boxId) then
				return value.count
			end
		end
	end
	return 0
end

-- 获取仙盟的某个主题的精研等级
-- 默认为1
function GuildModel:getSkillGroupsStagesByGroupId( themeId )
	if not themeId then
		return 
	end
	if self._baseGuildInfo and self._baseGuildInfo.skillGroups then
		for groupId,stageId in pairs(self._baseGuildInfo.skillGroups) do
			if tostring(groupId) == tostring(themeId) then
				return stageId
			end
		end
	end
end








--设置公告文字
function GuildModel:setnotice(str)
	self._baseGuildInfo.notice = str
end
--设置宣言文字
function GuildModel:setdesc(str)
	self._baseGuildInfo.desc = str
end


--是否已经加入公会
function GuildModel:isInGuild()
	return UserModel:guildId() ~= ""
end

--已经申请了的公会
--[[
	{
		"dev_6" = 13123,
		"dev_6" = 13123,
	}
]]
function GuildModel:applyingGuild()
	return UserModel:guildExt().applys;
end

--公会基础信息
function GuildModel:setGuildBaseInfo(baseInfo)
	self._baseGuildInfo = baseInfo;
end

-- function GuildModel:updateBaseInfo(key, value)
-- 	if self._baseInfoKey[key] ~= true then 
-- 		echo("warning:updateBaseInfo key not exist.");
-- 		return;
-- 	else 
-- 		self._baseGuildInfo[key] = value;
-- 	end 
-- end

--获得公会的所有基础信息
function GuildModel:getGuildBaseInfo()
	return self._baseGuildInfo;
end

--公会成员信息
function GuildModel:setGuildMembersInfo(members)
	self._membersInfo = {}
	for k, v in pairs(members) do
		self._membersInfo[k] = v; 
		self._membersInfo[k]._id = k
		if v._id == UserModel:rid() then
			self:setMyselfData(v)
		end
	end
	self:setguildcharinfo()
end

function GuildModel:setMyselfData(data)
	self.MySelfGuildDataList = data
end
function GuildModel:setmembersInfo_right(_id,right)
	if  self._membersInfo[_id] ~= nil then
		self._membersInfo[_id].right = right
	end
end

--设置旧的盟主位置
function GuildModel:setLeaderIdInLose()
	if self._membersInfo  ~= nil then
		for k,v in pairs(self._membersInfo) do
			if v.right == FuncGuild.MEMBER_RIGHT.LEADER then
				v.right = FuncGuild.MEMBER_RIGHT.PEOPLE
			end
		end
	end
end


function GuildModel:gettMyselfpos()
	local id = UserModel:rid()
	if  self._membersInfo[id] ~= nil then
		return  self._membersInfo[id].right
	else
		return 4
	end

end

--成员排序
function GuildModel:membersPaiXuData()
	local index = 1
	local newTable = {}
	for k,v in pairs(self._membersInfo) do
		newTable[index] = v
		index = index + 1
	end

	newTable = self:tableSort(newTable)

	return newTable
end
function GuildModel:tableSort(arrdata)

   	table.sort(arrdata,function(a,b)

                local rst = false
                if a.right < b.right then
                    rst = true
                elseif a.right == b.right then
                    -- if a.ability > b.ability then
                    --     rst = true
                    -- elseif a.ability == b.ability then
                        if a.level > b.level then
                            rst = true
                        elseif a.level == b.level then
                            --todo
                            if a.logoutTime < b.logoutTime then
                                rst = true
                            else
                                rst = false
                            end
                        else
                            rst = false
                        end
                    -- else
                    --     rst = false
                    -- end
                else
                    rst = false
                end 
                return rst
        end)
   return arrdata
end



function GuildModel:getGuildMembersInfo()
	return self._membersInfo;
end

function GuildModel:addMembersInfo(member)
	if member ~= nil then 
		self._membersInfo[member._id] = member;
	else
		echo("warning:addMembersInfo member is nil.");
	end 
end

function GuildModel:delMembersInfo(id)
	self.del_membersInfo[id] = self._membersInfo[id]
	self._membersInfo[id] = nil;
	if GuildModel._baseGuildInfo ~= nil then
		if GuildModel._baseGuildInfo.members ~= nil then
			GuildModel._baseGuildInfo.members = GuildModel._baseGuildInfo.members - 1
		end
	end
	if GuildModel._baseGuildInfo.members <= 0 then
		GuildModel._baseGuildInfo.members = 0
	end

end

function GuildModel:getMemberInfo(id)
	return self._membersInfo[id];
end

--我自己的公会信息
function GuildModel:getMyMembersInfo()
	local myId = UserModel:_id();
	return self._membersInfo[myId];
end

--自己是什么职位
function GuildModel:getMyRight()
	return self:getMyMembersInfo().right;
end

function GuildModel:isAppliedTheGuild(searchId)
	local ids = self:applyingGuild() or {};
	for id, time in pairs(ids) do
		if searchId == id then 
			return true 
		end 
	end
	return false;
end

function GuildModel:getMaxMemberNum()
	local level = self._baseGuildInfo.level;
	return FuncGuild.getGroudLvData(level, "nop");
end
--公会名字以及类型存储
function GuildModel:setGuildName(guildName)
	self.guildName = {
		name = guildName.name,  --仙盟名字
		_type = guildName._type,--图标类型
	}
end
function GuildModel:getGuildName()
	return self.guildName
end

--设置群号
function GuildModel:setGuildGroup(groupID)
	self.guildName.groupID = groupID  --群号
end

--公会Icon存储
function GuildModel:setIconData(guildIcon)
	self.guildIcon = {
		borderId = guildIcon.borderId,
		bgId = guildIcon.bgId,
		iconId = guildIcon.iconId,
	}
end
function GuildModel:getIconData()
	return self.guildIcon
end
--清除初始化的数据
function GuildModel:removelInitCreateguildData()
	self.guildName = {
		name = 1,
		_type = 1,
	}
	self.guildIcon = {
		borderId = 1,
		bgId = 1,
		iconId = 1,
	}
end

--0是未选中 1 --是选中
function GuildModel:addViewShowSelectAllGuild()
	return self.selectShowAll
end

--获得所有可以加入的仙盟
function GuildModel:getAddGuildData()
	local data = self.guildAllList
	return data
end
--设置所有仙盟数据
function GuildModel:setguildAllList(datalist)
	self.guildAllList = {}
	for k,v in pairs(datalist) do
		table.insert(self.guildAllList,v)
	end
end

--筛选可以加入的公会
function GuildModel:filtrateList(_type) 
	local datalist = {}
	if _type == 0 then     ---部分显示  申请和可加入的
		for k,v in pairs(self.guildAllList) do
			local data = v--self.guildAllList[i]
			local level = data.level
			local guilddata = FuncGuild.getGuildLevelByPreserve(level)
			local sumpeoplenum =  tonumber(guilddata.nop)
			if data.members < sumpeoplenum then
				table.insert(datalist,v)
			end
		end
		local data = UserModel:guildExt().applys
		local newtable = {}
		if data ~= nil then
			for i=1,#datalist do
				local app = false
				for k,v in pairs(data) do
					if datalist[i]._id ==  k then
						app = true
					end
				end
				if app then
					table.insert(newtable,1,datalist[i])
				else
					table.insert(newtable,datalist[i])
				end
			end
			datalist = newtable
		end
		
	else  ---全部显示
		datalist = self.guildAllList
	end
	return datalist
end



--判断可以加入的仙盟，仙盟里面的人数是否可以加入  --false  是已满  true 是未满
function GuildModel:judgmentAddGuildData()
	-- local alldata = self:getAddGuildData()
	-- if #alldata ~= 0 then
	-- 	return false
	-- end
	for i=1,#self.guildAllList do
		local data = self.guildAllList[i]
		local level = data.level
		local guilddata = FuncGuild.getGuildLevelByPreserve(level)
		local sumpeoplenum =  tonumber(guilddata.nop)
		if data.members < sumpeoplenum then
			return false
		end
	end

	return true
end

--获得仙盟等级
function GuildModel:getGuildLevel()
	return self._baseGuildInfo.level or 1
end

---获取所有伙伴数据
function GuildModel:getAllPartnerData()
	local alldata = PartnerModel:getAllPartner()
	local partner = {}
	for k,v in pairs(alldata) do
		table.insert(partner,v)
	end
	return partner
end

--获得所有历史记录文本
function GuildModel:getAllHistorRec()
	local alldes = self.sendHisListText
	return alldes
end
--设置所有历史记录文本
function GuildModel:setAllHistorRec( datalist )
	self.sendHisListText = datalist
end

function GuildModel:setAllWishList(itemdata)
	self.allWishDataList = {}
	local index = 1
	for k,v in pairs(itemdata) do

		--[[
			{
 -                 "_id"        = "dev6_4151"
 -                 "ability"    = 2270
 -                 "avatar"     = 104
 -                 "level"      = 55
 -                 "logoutTime" = 0
 -                 "name"       = "荒爆炎蛊"
 -                 "right"      = 1
 -                 "vip"        = 5
 -             }

		]]
		if self._membersInfo[k] ~=  nil then
			local ItemID = v.itemId 
			local ItemInfo = FuncItem.getItemData(ItemID)
			local ItemName = GameConfig.getLanguage(ItemInfo.name)
			local playerData = self._membersInfo[k]
			local guildID = self.guildName._type
			local itemdata = {
				ItemID = v.itemId,  ---伙伴ID
				playerName = playerData.name,
				ItemName = ItemName,
				guildID = guildID or 1, 
				_time = v.expireTime,  ---发送时间
				hasnum = v.count or 0,
				position = playerData.right,
				_id = k,
			}

			self.allWishDataList[index] = itemdata
			index = index + 1
		end
	end

	-- dump(self.allWishDataList,"333333333333333")

end
function GuildModel:setAllWishCount(playerID)
	for k,v in pairs(self.allWishDataList) do
		if v._id == playerID then
			v.hasnum = v.hasnum + 1
		end
	end
end

function GuildModel:setMySelfWishList(item)
	-- dump(item,"item = = = = = ")
	local ItemID = item.ItemID 
	local ItemInfo = FuncItem.getItemData(ItemID)
	-- dump(ItemInfo,"ItemInfo = = = = = ")
	local ItemName = GameConfig.getLanguage(ItemInfo.name)
	local guildID = self.guildName._type
	local itemdata = {
		ItemID = ItemID,  ---伙伴ID
		playerName = item.name,
		ItemName = ItemName,
		guildID = guildID or 1, 
		_time = item._time,  ---发送时间
		hasnum = item.hasnum or 0,
		position = item.position,
		_id = item._id,
	}

	table.insert(self.allWishDataList,1,itemdata)
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
---获得所有心愿所需的数据
function GuildModel:getAllWishList()
	local datalist = self.allWishDataList
	local guildLevel = GuildModel:getGuildLevel()
	-- echo("guildLevel = = = = ",guildLevel)
	local guildLvdata = FuncGuild.getGuildLevelByPreserve(guildLevel)
	-- dump(datalist,"datalist = = == = = = ")
	-- local neednum = tonumber(guildLvdata.blessingNum)  ---需要几个
	local neednum = 1
	local newdatalist = {}
	local index = 1
	for i=1,#datalist do
		local data = datalist[i]
		if data ~= nil then
			-- echo("hasnum = = = = = = neednum",data.hasnum,neednum)
			if data.hasnum <  neednum then
				newdatalist[index] = data
				index = index + 1
			end
		end
	end
	return newdatalist
end
function GuildModel:setWishAppconut(itemdata)
	for i=1,#self.allWishDataList do
		if 	self.allWishDataList[i]._id == itemdata._id then
			self.allWishDataList[i].hasnum = self.allWishDataList[i].hasnum + 1
		end
	end
end

function GuildModel:removeWish(itemdata)
	for i=1,#self.allWishDataList do
		local data = self.allWishDataList[i]
		if data._id == itemdata._id then
			table.remove(self.allWishDataList,i)
		end
	end
end

--获得每天可求赠的时间是否到了没
function GuildModel:getPleaseAddCount()
	local time = 0
	for i=1,#self.allWishDataList do
		local peopledata  = self.allWishDataList[i]
		if peopledata._id == UserModel:rid() then
			time = peopledata._time
		end
	end


	local sum = FuncGuild.getWishTime()   ---22个小时

-- echoError("====time========",time+sum,TimeControler:getServerTime())
	if time == 0 or TimeControler:getServerTime() >= time then
		return true
	end
	return false , time 
end

--判断是否是盟主
function GuildModel:judgmentIsBoos()
	local leaderId = self._baseGuildInfo.leaderId
	if leaderId == UserModel:rid() then
		return true
	end
	for k,v in pairs(self._membersInfo) do
		if k == UserModel:rid() then
			if v.right == 1 then
				return true
			end
		end
	end

	return false
end

-- 判断是否为盟主或者副盟主
function GuildModel:judgmentIsForZBoos()
	local leaderId = self._baseGuildInfo.leaderId
	if leaderId == UserModel:rid() then
		return true
	end
	for k,v in pairs(self._membersInfo) do
		if k == UserModel:rid() then
			if v.right == 1 or v.right == 2 then
				return true
			end
		end
	end
	return false
end


function GuildModel:getguildpeopleData()
	local guildID = UserModel:guildId()

	if guildID == "" then
		return 
	end
	local function _callback(_param)
		if _param.result then
			local members = _param.result.data.members
			local infodata = _param.result.data.guild
			self:setbaseGuildInfo(infodata)
			self:setGuildMembersInfo(members)
		else
			--错误的情况

		end
	end 
	local params = {
		id = UserModel:guildId(),
	}

	GuildServer:getMembers({},_callback)

end

function GuildModel:setguildcharinfo()
	self._guildcharinfo = {}
	local members = self._membersInfo
	local leaderId = self._baseGuildInfo.leaderId

	for k,v in pairs(members) do
		if k == leaderId then
			self._guildcharinfo = v
		end
	end
end

function GuildModel:setchatEventData(datalist)
	self.chatEventData = {}
	local index = 1
	for i=1,#datalist do
		local itemData =  datalist[i]
		local str =  self:paramGuildEvent(itemData)
		if str ~= "" then
			self.chatEventData[index] = itemData
			index = index + 1
		end
	end
end
function GuildModel:insertDataToList(itemdata)
	table.insert(self.allchatEventData,itemdata)
end

--木头是否满足
function GuildModel:isWoodFull()
	-- local wood = self._baseGuildInfo.wood
	-- local level = GuildModel:getGuildLevel()   ---获得服务器的仙盟等级
	-- local data = FuncGuild.getGuildLevelByPreserve(level)
	-- -- panelcost.txt_2:setString(data.maintainCost)  ---每日扣除维护费

	-- if wood < data.maintainCost then
	-- 	-- WindowControler:showTips("灵木不足")
	-- 	-- WindowControler:showWindow("GuildLapseView")
	-- 	-- return  false
	-- end
	return  true
end

function GuildModel:toTimeDeleteWood()
	local level = GuildModel:getGuildLevel()   ---获得服务器的仙盟等级
	local data = FuncGuild.getGuildLevelByPreserve(level)
	local maintainCost = data.maintainCost  ---每日扣除维护费
	if self._baseGuildInfo.woodCostTime ~= nil then
		local day = (TimeControler:getServerTime() - self._baseGuildInfo.woodCostTime)%(24*3600)
		if day == 0 or day == nil then
			day = 1
		end
		local wood = self._baseGuildInfo.wood
		echo("========当前灵木数量=====",wood)
		if wood ~= nil then
			if wood >= day*maintainCost then
				-- self._baseGuildInfo.wood = self._baseGuildInfo.wood - day*maintainCost
				self._baseGuildInfo.woodCostTime = TimeControler:getServerTime()
			end
		end
		echo("========每日扣除维护费de灵木数量=====",self._baseGuildInfo.wood)
		EventControler:dispatchEvent(GuildEvent.GUILD_REFRESH_WOOD_EVENT)
	end
end


--维护费用是否扣除
function GuildModel:isFullmaintenanceCost()
	local wood = self._baseGuildInfo.wood
	local woodCostTime = self._baseGuildInfo.woodCostTime
	local guildlevel = self._baseGuildInfo.level
	local data = FuncGuild.getGuildLevelByPreserve(guildlevel)
	local maintainCost = data.maintainCost  --每日维护

	-- local time_ = os.date("*t", woodCostTime)
	local time_sever = os.date("*t", TimeControler:getServerTime())

	local time = TimeControler:getServerTime() - woodCostTime 

	if wood - maintainCost * 1 >= 0 then
		return true
	else
		local isok  =  self:timePanDuan(woodCostTime)
		return isok
	end

	return false
end

function GuildModel:timePanDuan(_time)
	local time_ = os.date("*t", _time)
	local time_sever = os.date("*t", TimeControler:getServerTime())
	if time_.year == time_sever.year and
		time_.month == time_sever.month and
		time_.day == time_sever.day and
		time_.hour >= 4 then
		return true
	else
		local toforeTime =  FuncCommon.byTimegetleftTime(_time)   ---到四点的时间
		local sumtime  =  _time + toforeTime
		if TimeControler:getServerTime() >= sumtime then
			return false
		else
			return true
		end
	end
	return false
end


function GuildModel:toDoInLoseView()
	local backfile = self:isFullmaintenanceCost()
	if not backfile then
		WindowControler:showWindow("GuildLapseView")
	end
end

--申请加入公会的次数
function GuildModel:getUserModelguildExt()
	local data = UserModel:guildExt().applys
	-- dump(UserModel:guildExt(),"22222222222")
	if data ~= nil then
		local num = table.length(data)
		return num
	end
	return 0
end

--是否在退出公会的CD中
function GuildModel:closeGuildTime()
	local quitTime = UserModel:guildExt().quitTime
	dump(UserModel:guildExt(),"退出仙盟的时间数据")
	if  quitTime ~= nil then
		if TimeControler:getServerTime() >= quitTime + FuncGuild.closeGuildTime() then
			return false
		else
			return true
		end
	end
	return false
end
--[[
 "申请加入的数据返回" = {
     "data" = {
         "dirtyList" = {
             "u" = {
                 "_id"      = "dev6_4209"
                 "guildExt" = {
                     "applys" = {
                         "1013" = 1508530210
                     }
                 }
             }
         }
     }
     "serverInfo" = {
         "serverTime" = 1508530210077
     }
 }
]]


function GuildModel:paramGuildEvent(itemData) 
	local eventType = tonumber(itemData.type)
	-- echo("=======eventType=====",eventType)
	local data = FuncGuild.getGuildEvent(eventType)
	local translate = data.translate

	local param1 = itemData.param1
	local param2 = itemData.param2
	local param3 = itemData.param3
	local paramtable = {
		[1] = param1,
		[2] = param2,
		[3] = param3,
	}
	-- dump(itemData,"3333333333333333",9)
	local str = translate[1]
	local num = 1
	if param2 ~= nil then
		num = 2 
	end
	if param3 ~= nil then
		num = 3
	end
	if eventType == 1 then
		local data = self._membersInfo[paramtable[1]] 
		if data ~= nil then 
			local name =  self._membersInfo[paramtable[1]].name or "少侠"
			paramtable[1] = name 
		else
			return ""
		end
	elseif eventType == 2  then
		return ""
	elseif eventType == 3  then
		local plardata = self.del_membersInfo[paramtable[1]]
		if plardata == nil then
			return ""
		else
			paramtable[1] = plardata.name 
		end
	elseif eventType == 4  then
		local data = self._membersInfo[paramtable[1]] 
		if data ~= nil then
			local name =  self._membersInfo[paramtable[1]].name
			paramtable[1] = name
		else
			return ""
		end
		paramtable[2] = FuncGuild.MEMBER_NAME[tonumber(paramtable[2])]
		paramtable[3] = FuncGuild.MEMBER_NAME[tonumber(paramtable[3])]
	elseif eventType == 5  then
		local name =  self._membersInfo[paramtable[1]].name or "少侠"
		paramtable[1] = name
	elseif  eventType == 6   then
		local data = self._membersInfo[paramtable[1]] 
		if data ~= nil then
			local name =  self._membersInfo[paramtable[1]].name
			paramtable[1] = name
		else
			return ""
		end
	elseif eventType == 8 then
		local tid = FuncGuild.guildBuildName[tonumber(paramtable[1])]
		paramtable[1] = GameConfig.getLanguage(tid)

	---捐献
	elseif eventType == 9 then
		local translatetable = translate
		local strlist = translatetable[tonumber(paramtable[2])]
		local data = self._membersInfo[paramtable[1]] 
		if data ~= nil then
			local name =  self._membersInfo[paramtable[1]].name
			paramtable[1] = name
		else
			return ""
		end
		local data  = FuncGuild.getGuildDonate(paramtable[2])
		local cost = data.cost
		local newstrtable = string.split(strlist, ",");
		local rewRes = string.split(cost[1], ",");
		local count = rewRes[2]
		local index = nil
		if self.eventchatIndexsaver[paramtable[1]] == nil then
			index = math.random(1,2)
			self.eventchatIndexsaver[paramtable[1]] = index
		else
			index = self.eventchatIndexsaver[paramtable[1]]
		end
		str = newstrtable[index]
		-- paramtable[1] = name
		paramtable[2] = count or 0
	-- 捐献玄盒
	elseif eventType == 12 then
		local translatetable = translate
		local strlist = translatetable[tonumber(paramtable[2])]
		local data = self._membersInfo[paramtable[1]] 
		if data ~= nil then
			local name =  self._membersInfo[paramtable[1]].name
			paramtable[1] = name
		else
			return ""
		end
		str = strlist 

		local data = FuncGuild.getGuildDonateBoxData(paramtable[2])
		local guildWood = data.guildWood
		local guildStone = data.guildStone
		local guildJade = data.guildJade
		-- paramtable[1] = name
		paramtable[2] = guildWood or guildStone or guildJade or 0
	-- 精研成功
	elseif eventType == 10 then
		paramtable[1] = FuncGuild.themeName[tonumber(paramtable[1])].." "
		paramtable[2] = FuncGuild.stageName[tonumber(paramtable[2])].."段"
		str = translate[1]
	elseif eventType == 15 then
		local data1 = self._membersInfo[paramtable[1]] 
		local data2 = self._membersInfo[paramtable[2]]
		if data1 and data2 then
			local name1 =  data1.name
			local name2 =  data2.name
			paramtable[1] = name2
			paramtable[2] = name1
		else
			return ""
		end
	elseif eventType == 13 then
		
		local data = FuncGuild.getGuildTaskDataById(paramtable[2])
		str = FuncGuild.guildTAsk_Event_list[tonumber(paramtable[2])]
		local playData = self._membersInfo[paramtable[1]]
		local name = "少侠"
		if playData then
			name = playData.name
		end
		paramtable[1] = name
		paramtable[2] = data.popularity
	end

	-- dump(paramtable,"2222222",9)
	str = GameConfig.getLanguage(str)
	-- echo("=====str=========",str)
	for i=1,num do
		local _th = "#"..tostring(i)
		str = string.gsub(str, _th, paramtable[i]);	
	end
	return str
end


---每日维护
function GuildModel:dailyCost()
	local level = self:getGuildLevel()   ---获得服务器的仙盟等级
	local data = FuncGuild.getGuildLevelByPreserve(level)
	return data.maintainCost
end


---还原最原始的数据
function GuildModel:reductionInitData()
	self._membersInfo = {};   ---成员数据
	self.selectAddGuildType = 0   ---入盟是否需要申请   0 不需要  1 需要
	self.selectShowAll = 1   ----0是未选中 1 --是选中  显示所有公会
	self.allWishDataList = {}  ---仙盟中心愿的玩家
	self._guildcharinfo = {}   ---盟主的数据 
	self.chatEventData = {} --仙盟事件

	self.inviteDataList = {}   ---推荐邀请的玩家数据列表
	self.guildAllList = {}  ---所有可以加入的仙盟
	self.guildApplyList = {}  ---所有申请入会的列表
	self._baseGuildInfo = {}
end

--权限不足
function GuildModel:notPermissions()
	echo("修改公告按钮")
	local declaration = FuncGuild.getGroupRightData(GuildModel:getMyRight(),"declaration")
	if declaration == 1 then
		return true
	else
		WindowControler:showTips(GameConfig.getLanguage("#tid_guild_001"))
		return false
	end
end

function GuildModel:appointeliteNum()
	local num = 0
	for k,v in pairs(self._membersInfo) do
		if v.right == FuncGuild.MEMBER_RIGHT.MASTER then
			num = num + 1
		end
	end
	local level = self:getGuildLevel()
	local data = FuncGuild.getGuildLevelByPreserve(level)
	local  noe = data.noe
	if num >= noe then
		WindowControler:showTips(GameConfig.getLanguage("#tid_guild_002"))
		return true
	else
		return false
	end
end

function GuildModel:appointchampionsNum()
	local num = 0
	for k,v in pairs(self._membersInfo) do
		if v.right == FuncGuild.MEMBER_RIGHT.SUPER_MASTER then
			num = num + 1
		end
	end
	local level = self:getGuildLevel()
	local data = FuncGuild.getGuildLevelByPreserve(level)
	local  nobe = data.nobe
	if num >= nobe then
		WindowControler:showTips(GameConfig.getLanguage("#tid_guild_002"))
		return true
	else
		return false
	end
end


function GuildModel:outofFilsTime(playerId)
	local data = self._membersInfo[playerId]
	if data then 
		local logoutTime = data.logoutTime
		local day = 24* 3600
		local time = math.floor((TimeControler:getServerTime() - logoutTime)/day)
		if time >= FuncGuild.outofGuildTime() then
			if logoutTime ~= 0 then
				return true
			end
		else
			return false
		end
	end
	return false

end 


--盟主每天踢人次数到最大
function GuildModel:guildpeopleNum()
	local count = CountModel:getGuildCountPeople()
	if count < FuncGuild.getDayGuildOutPeople() then
		return true
	else
		WindowControler:showTips(GameConfig.getLanguage("#tid_guild_003"))
		return false
	end
end

function GuildModel:demiseFun(playerId)
	local playerId = playerId
	local data = self._membersInfo[playerId]
	local logoutTime = data.logoutTime
	local day = 24 * 3600
	if logoutTime == 0 then
		return false
	end

	local time = math.floor((TimeControler:getServerTime() - logoutTime)/day)
	if time >= 3 then
		-- WindowControler:showTips( data.name.."离线超过3天，不可禅让")
		return true
	else
		return false
	end
end

function GuildModel:setOnLinePlayer(data)
	self.onLinePlayer = {}
	for i=1,#data do
		self.onLinePlayer[data[i]] = true
	end
end

--最后一次开启gve时间戳
function GuildModel:getlastGveTime()
	return self._baseGuildInfo.lastGveTime or nil
end

--   /* 公会煮菜信息 */
function GuildModel:getGvefood()
	return self._baseGuildInfo.food or {}
end

-- /* 参加公会gve活动成员信息 */
function GuildModel:getGveMembers()
	return self._baseGuildInfo.gveMembers or {}
end

--/* 组队列表 */
function GuildModel:getGveTeams()
	return self._baseGuildInfo.gveTeams or {}
end

--发送世界仙盟邀请
function GuildModel:sendWorldInvite()
	local xuanyan  = self._baseGuildInfo.desc or FuncGuild.getdefaultDec()
	local function callback(_param)
		-- dump(_param.result,"公会邀请数据",8)
		if _param.result then
			WindowControler:showTips(GameConfig.getLanguage("#tid_guild_004"))
		end
	end
	local  param={};
	local guild =  UserModel:guildId()
	local name = self.guildName.name
	local guildlevel =  self._baseGuildInfo.level
	local info = {
		desc = xuanyan,
		id = guild,
		name = name ,
		level = guildlevel,
	}
	local content = json.encode(info)
	param.content = content
	param.type = 6
	-- WindowControler:showTips(GameConfig.getLanguage("#tid_Talk_101"))
	ChatServer:sendWorldMessage(param,callback);
end
GuildModel.BuildPosTAble = {
	[1] = cc.p(104.1,121),
	[2] = cc.p(116.1,164),
	[3] = cc.p(69.2,174),
	[4] = cc.p(53.1,157),
	[5] = cc.p(90,177),
	[6] = cc.p(58.1,94),
	[7] = cc.p(68,184),
}

function GuildModel:addMapTitle(_ctn,buildID)

	local buildname =  WindowsTools:createWindow("GuildTitleView",buildID)
	buildname:setPosition(GuildModel.BuildPosTAble[tonumber(buildID)])
	_ctn:addChild(buildname,1000)

	return buildname
end


function GuildModel:addBuildSpin(_ctn)
	local node = display.newNode()
	node:size(243,287)
	node:anchor(0.5, 0.5)
	node:setPosition(cc.p(243/2,287/2))
	node:addTo(_ctn)
    local npcAnimName = "eff_liliange_zhu"
    local npcAnimLabel = "eff_liliange_zhu"
    local spine = ViewSpine.new(npcAnimName)
    spine:playLabel(npcAnimLabel);
    node:addChild(spine)
    
    return node
end

--主城建筑的红点数据
function GuildModel:buildRedData()

	local isSignred = self:signShowRed()
	local isBonusred = self:bonusListRed() or GuildRedPacketModel:grabRedPacketRed() or GuildRedPacketModel:sendRedPacketRed()
	local isblessred = self:blessingRed()
	local isGVEbossred  = self:isShowGuildActRedPoint() or GuildExploreModel:getEntranceRed()
	local isdonationRed = self:donationRed() or self:userBosRed()
	local isTaskRed = self:getTaskRed()
	-- echo("______eeeeeeeeeee____________",isGVEbossred)
	local redata = {
		[1] = isdonationRed,
		[2] = isBonusred,
		[3] = isblessred,
		[4] = false,
		[5] = false,
		[6] = false,
		[7] = isGVEbossred,
		[8] = isTaskRed,
	}
	return redata
end

--缴纳红点
function GuildModel:userBosRed()
	local item1 = "3012"
	local item2 = "3013"
	local num1 = ItemsModel:getItemNumById(item1)
	local num2 = ItemsModel:getItemNumById(item2)
	if num1 ~= 0 or num2 ~= 0 then
		return true
	end
	return false
end


function GuildModel:donationRed()
	local sumcount = FuncGuild.getDonationNumber()
	local count = sumcount - CountModel:getGuildDonationCount()
	if count > 0 then
		return true
	end
	return false
end
-- 展示gve红点或者副本红点
function GuildModel:isShowGuildActRedPoint()
	local isShowGve =  GuildActMainModel:isShowGuildActRedPoint()
    local isShowEctype = false--GuildBossModel:isShowGuildBossRedPoint()
    echo("_________ isShowGve,isShowEctype ____________",isShowGve,isShowEctype)
    return (isShowEctype or isShowGve)
end

---宝箱是佛可以兑换
function GuildModel:boxExchaneIsOk(boxID)
	local costdata =  FuncGuild.getExchangeCostData(boxID)
	for i=1,#costdata do
		local  reward = costdata[i]
		local data = string.split(reward,",")
		local itemID = data[2]
		local needNum = tonumber(data[3])
		local haveNum = ItemsModel:getItemNumById(itemID)
		if haveNum < needNum then
			return false
		end
	end
	return true
end


--兑换宝箱显示红点
function GuildModel:boxExchanegIsShowRed(boxID)
	local isshow =  self:boxExchaneIsOk(boxID)
	return isshow
end

--默认选择有红点相关的兑换
function GuildModel:defaultSelectRedBoxID()
	local alldata = FuncGuild.getAllExchangeData()
	local isshored = false
	for k,v in pairs(alldata) do
		local isred = self:boxExchanegIsShowRed(k)
		if isred then
			return k
		end
	end
	return nil
end

---宝箱兑换次数加一
function GuildModel:boxExchanreCountAdd()
	self.boxExchangCount = self.boxExchangCount + 1
end

--重置宝箱兑换次数
function GuildModel:resetBoxExchanreCount()
	self.boxExchangCount = 1
end

function GuildModel:getEcxhangeListData(cellfun)
	
	local function _callback(event)
		local data = {}
		if event.result then
			dump(event.result,"所有兑换的列表 ====")
			data = event.result.data.data
			self:initExchangeData(data)
		end
		if cellfun then
			cellfun()
		end
	end
	GuildServer:getGuildExchangeList(_callback)
end


function GuildModel:getMemberDataByRid(playrid)
	local dataArr = nil
	local playerdata = self._membersInfo[playrid]
	if playerdata then
		local garmentId = playerdata.garmentId
		if garmentId and garmentId == 0 then
			garmentId = nil
		end
		dataArr = {
			name = playerdata.name or UserModel:name(),
			avatar = playerdata.avatar or UserModel:avatar(),
			garmentId = garmentId ,
			id = playerdata._id or UserModel:rid(),
			isexchange = true,  ---是否发起交换
			hasExchange = nil,  --兑换的道具			---后面那个
			needExchang = nil,	--用来替换兑换的道具  --前面那个
			right = playerdata.right or 4,
		}
	end
	return dataArr
end

--处理仙盟成员兑换列表
function GuildModel:initExchangeData(data)
	self.exchangAlldData = {} ---仙盟兑换的所有数据

	-- dump(data,"4444444444")

	if data ~= nil then
		if table.length(data) ~= 0 then
			local myself = false
			for k,v in pairs(data) do
				local playerdata = self:getMemberDataByRid(k)
				if playerdata then
					playerdata.hasExchange = v.need
					playerdata.needExchang = v.have
					if k == UserModel:rid() then
						myself = true
						table.insert(self.exchangAlldData,1,playerdata)
					else
						table.insert(self.exchangAlldData,playerdata)
					end
				end
			end
			if not myself then
				local data = self:getMemberDataByRid(UserModel:rid())
				local playerdata = {
					name = UserModel:name(),
					avatar =  UserModel:avatar(),
					garmentId = UserExtModel:garmentId() ,
					id = UserModel:rid(),
					isexchange = false,  ---是否发起交换
					hasExchange = nil,  --兑换的道具			---后面那个
					needExchang = nil,	--用来替换兑换的道具  --前面那个
					right = data.right or 4,
				}
				table.insert(self.exchangAlldData,1,playerdata)
			end

		else
			--自己的数据
			local data = self:getMemberDataByRid(UserModel:rid())
			self.exchangAlldData[1] = {
				name = UserModel:name(),
				avatar = UserModel:avatar(),
				garmentId = UserExtModel:garmentId(),
				id = UserModel:rid(),
				isexchange = false,  ---是否发起交换
				hasExchange = nil,  --兑换的道具			---后面那个
				needExchang = nil,	--用来替换兑换的道具  --前面那个
				right = data.right or 4,
			}
		end
	end
end

--获取所有兑换列表的数据
function GuildModel:getExchallengAllData()

	local newArr = {[1]  = {},[2]= {},[3] = {},[4] = {}}

	for k,v in pairs(self.exchangAlldData) do
		local otherNeedID = v.needExchang
		local otherhasID = v.hasExchange
		local isneed = GuildModel:getItemIsMyNeedById(otherNeedID)
		local count = ItemsModel:getItemNumById(otherhasID)
		if count > 0 then
			if isneed then
				table.insert(newArr[1],v)
			else
				table.insert(newArr[2],v)
			end
		else
			if isneed then
				table.insert(newArr[3],v)
			else
				table.insert(newArr[4],v)
			end
		end
	end

	self.exchangAlldData = {}
	for i=1,#newArr do
		for x=1,#newArr[i] do
			if newArr[i][x].id == UserModel:rid() then
				table.insert(self.exchangAlldData,1,newArr[i][x])
			else
				table.insert(self.exchangAlldData,newArr[i][x])
			end
		end
	end

	-- dump(self.exchangAlldData,"444444444444444444")

	return self.exchangAlldData
end



---根据ID获得自己是否发起匹配
function GuildModel:getMyselfSendExchange(myselfID)
	if self.exchangAlldData then
		for k,v in pairs(self.exchangAlldData) do
			if v.id == myselfID then
				if v.isexchange then
					return true,v
				else
					return false,v
				end
			end
		end
	end
	return false
end


function GuildModel:setExchangeListData(_type,itemID)
	if _type == FuncGuild.Exchange_Type.Out_Item then  ---换出
		for k,v in pairs(self.exchangAlldData) do
			if v.id == UserModel:rid() then
				v.needExchang = itemID
			end
		end
	elseif  _type == FuncGuild.Exchange_Type.Into_Item then   --换入
		for k,v in pairs(self.exchangAlldData) do
			if v.id == UserModel:rid() then
				v.hasExchange = itemID
			end
		end
	end
	EventControler:dispatchEvent(GuildEvent.GUILD_EXCHANGE_LIST_FRESH)
end


function GuildModel:setIsexchangeData(playerId,isok)
	for k,v in pairs(self.exchangAlldData) do
		if v.id == playerId then
			v.isexchange = isok
			if not isok then
				v.hasExchange = nil
				v.needExchang = nil
			end
		end
	end
end


--根据道具ID判断是不是我需要的
function GuildModel:getItemIsMyNeedById(itemID)
	local alldata = FuncGuild.getAllExchangeData()
	for k,v in pairs(alldata) do
		local costdata =  v.cost
		for i=1,#costdata do
			local  reward = costdata[i]
			local data = string.split(reward,",")
			local needNum = tonumber(data[3])
			if tonumber(data[2]) == tonumber(itemID) then
				local haveNum = ItemsModel:getItemNumById(data[2])
				if haveNum >= needNum then
					return false
				else
					return true
				end
			end
		end
	end
	return false
end


--删除一交换的数据
function GuildModel:removeExchangData(playerID)
	dump(self.exchangAlldData,"删除前的数据=====")
	for k,v in pairs(self.exchangAlldData) do
		echo("==========playerID==========",v.id,playerID)
		if v.id == playerID then
			table.remove(self.exchangAlldData,k)
		end
	end
	dump(self.exchangAlldData,"删除后的数据=====")
end

-- ==================================  仙盟科技用到的函数 begin ==============================================
-- 根据主题id 获取玩家当前已经修炼的技能id
-- 如果没有修炼 返回nil
function GuildModel:getHasLigntenSkillId( themeId )
	if not themeId then
		return
	end
	local guildSkillData = UserModel:guildSkills() or {}
	for skillGroupId,hasLightenId in pairs(guildSkillData) do
		if tostring(themeId) == skillGroupId then
			return hasLightenId
		end
	end
end

-- 根据主题id 获取将要点亮的技能id 
-- 如果返回空 则表示已经圆满
-- 主题id 为1~6 
function GuildModel:getToLigntenSkillId( themeId )
	local hasLightendId = self:getHasLigntenSkillId( themeId )
	local toLightendId

	if hasLightendId then
		toLightendId = tostring(tonumber(hasLightendId) + 1)
	end

	-- echo("______hasLightendId,toLightendId,themeId ",hasLightendId,toLightendId,themeId)

	if not toLightendId then 
		return themeId.."01"
	else
		if not self.oneThemeAllSkillIds then
			self.oneThemeAllSkillIds = FuncGuild.initAllThemeAndTheirSkills()
		end
		if not self.oneThemeAllSkillIds[tostring(themeId)] then
			echoError("______ 主题初始化错误 themeId________",themeId)
		end
		-- dump(self.oneThemeAllSkillIds["1"], "self.oneThemeAllSkillIds")
		if self.oneThemeAllSkillIds[tostring(themeId)][tostring(toLightendId)] then
			return toLightendId
		end
	end
end

-- 获取玩家已经修炼的最新skill 所在 的stage
function GuildModel:getCurStageAboutPlayer( themeId )
	local skillId = self:getHasLigntenSkillId( themeId )
	return FuncGuild.getSkillStage( skillId )
end

-- 获取玩家将要点亮的技能所在阶段
function GuildModel:getNextSkillStageAboutPlayer( themeId )
	local skillId = self:getToLigntenSkillId( themeId )
	echo("_________将要点亮的技能 skillId ___________",skillId)
	if skillId then
		return FuncGuild.getSkillStage( skillId )
	end
end

-- =================================================================
-- 获取仙盟的某个主题的阶段(精研等级,默认为1)
function GuildModel:getCurStageInGuild( themeId )
	if not themeId then
		return 
	end
	if self._baseGuildInfo and self._baseGuildInfo.skillGroups then
		for groupId,stageId in pairs(self._baseGuildInfo.skillGroups) do
			if tostring(groupId) == tostring(themeId) then
				return stageId
			end
		end
	end
end

-- 获取仙盟的某个主题 当前阶段的下一个阶段
-- 如果返回为空 则本阶段已达到最大阶段
function GuildModel:getNextStageInGuild( themeId )
	local curStage = self:getCurStageInGuild( themeId )
	if not curStage then
		curStage = 0
	end
	local nextStage = curStage + 1
	local themeData = FuncGuild.getGroupDataByGroupAndStageId( themeId,nextStage )
	if themeData then
		return nextStage
	end
end

-- 判断某个主题下的某个阶段是否解锁
function GuildModel:checkIsUnlock( themeId,stageId )
	local buildingId = "6"
	local infinitePavilionLevel = self._baseGuildInfo.builds[buildingId] or 1

	local themeData = FuncGuild.getGroupDataByGroupAndStageId( themeId,stageId )
	local openConditionLevel = tonumber(themeData.buildLv or 1)
	if infinitePavilionLevel < openConditionLevel then
		return false
	else
		local curGuildStage = 1 -- 本公会数据 获取当前themeid 下的stageId
		if stageId > curGuildStage then
			return false
		end
	end
end

-- 判断是否达到新的阶段
function GuildModel:checkIfReachNewStage(themeId)
	local curStage = self:getCurStageAboutPlayer( themeId )
	local nextStage = self:getNextSkillStageAboutPlayer( themeId )
	if not curStage or not nextStage then
		return false,curStage
	end
	if tonumber(curStage) < tonumber(nextStage) then
		return true,curStage
	end
end

-- FuncGuild.countFinalAttrForShow/
-- 初始化已经获得的技能点 对应的属性数据
function GuildModel:initGuildPropertiesDataByType(effectZoneType)
    -- 实际属性计算用
    if not self._calculateData then
    	self._calculateData = {
    		[tostring(FuncGuild.effectZoneType.GLOBAL)] = {},
    		[tostring(FuncGuild.effectZoneType.PVP)] = {},
    		[tostring(FuncGuild.effectZoneType.SHAREBOSS)] = {},
    		[tostring(FuncGuild.effectZoneType.GUILDBOSS)] = {},
    		[tostring(FuncGuild.effectZoneType.WONDERLAND)] = {},
    		[tostring(FuncGuild.effectZoneType.ENDLESS)] = {},
    	}

    	self._showData = {
    		[tostring(FuncGuild.effectZoneType.GLOBAL)] = {},
    		[tostring(FuncGuild.effectZoneType.PVP)] = {},
    		[tostring(FuncGuild.effectZoneType.SHAREBOSS)] = {},
    		[tostring(FuncGuild.effectZoneType.GUILDBOSS)] = {},
    		[tostring(FuncGuild.effectZoneType.WONDERLAND)] = {},
    		[tostring(FuncGuild.effectZoneType.ENDLESS)] = {},
    	}
    end
    -- if not self._showData[tostring(effectZoneType)] or table.length(self._showData[tostring(effectZoneType)]) <=0 then
	    self._calculateData[tostring(effectZoneType)] = FuncGuild.getCalculatePropertyData(UserModel:guildSkills(),effectZoneType)
	    self._showData[tostring(effectZoneType)].char 		= FuncGuild.countFinalAttrForShow(FuncGuild.appendTarget.CHAR,self._calculateData[tostring(effectZoneType)].char)
	    self._showData[tostring(effectZoneType)].offensive 	= FuncGuild.countFinalAttrForShow(FuncGuild.appendTarget.OFFENSIVE,self._calculateData[tostring(effectZoneType)].offensive)
	    self._showData[tostring(effectZoneType)].defensive 	= FuncGuild.countFinalAttrForShow(FuncGuild.appendTarget.DEFENSIVE,self._calculateData[tostring(effectZoneType)].defensive)
	    self._showData[tostring(effectZoneType)].assisted 	= FuncGuild.countFinalAttrForShow(FuncGuild.appendTarget.ASSISTED,self._calculateData[tostring(effectZoneType)].assisted)

	    if FuncGuild.isDebug then
	        dump(self._showData[tostring(effectZoneType)].char, "self._showData[tostring(effectZoneType)].char")    
	        dump(self._showData[tostring(effectZoneType)].offensive, "self._showData[tostring(effectZoneType)].offensive")    
	        dump(self._showData[tostring(effectZoneType)].defensive, "self._showData[tostring(effectZoneType)].defensive")    
	        dump(self._showData[tostring(effectZoneType)].assisted, "self._showData[tostring(effectZoneType)].assisted")    
	    end
	    return self._showData[tostring(effectZoneType)] 
	-- end
end


-- 根据作用区域获取显示属性
function GuildModel:getShowPropertyDataByType(effectZoneType)
	-- if self._showData and table.length(self._showData[tostring(effectZoneType)])>0 then
	-- 	return self._showData[tostring(effectZoneType)] 
	-- else
		return self:initGuildPropertiesDataByType(effectZoneType)
	-- end
end


-- -- 初始化已经获得的技能点 对应的属性数据
-- function GuildModel:initGuildAffectResourceData()
--     -- 实际属性计算用
--     self._showData.amount_produce_increase 		= FuncGuild.countFinalResourceAttrForShow("玩法增量",self._calculateData.amount_produce_increase)
--     self._showData.amount_cost_reduce 	= FuncGuild.countFinalResourceAttrForShow("消耗减少",self._calculateData.amount_cost_reduce)
--     if FuncGuild.isDebug then
--         dump(self._showData.amount_produce_increase, "self._showData.amount_produce_increase")    
--         dump(self._showData.amount_cost_reduce, "self._showData.amount_cost_reduce")    
--     end
--     return self._showData[tostring(effectZoneType)] 
-- end


-- 根据玩法类型 判断是否有对应的仙盟加成(产出量增加或者耗费量减少)
-- 返回 isHas,value,subType
function GuildModel:checkIsHaveAdditionByZone( amountType )
	local isHas,value,subType = false,0,1
	local guildPrivilegeData = UserModel:privileges() 
	dump(guildPrivilegeData, "usermodel下的数据=========")
	if not guildPrivilegeData or table.length(guildPrivilegeData)<=0 then
		guildPrivilegeData = {
			[1] = {
				-- "1001",
				-- "1007",
				-- "1008",
			},
			[2] = {
				-- "1002",
			},
			[7] = {
				-- "1009",
				-- "1016",
			},
		}
	end
	echo("_________amountType ",amountType)
	dump(guildPrivilegeData, "desciption")
	for type,additionIdArr in pairs(guildPrivilegeData) do
		for additionId,changeMode in pairs(additionIdArr) do
			local additionData = FuncCommon.getAdditionDataByAdditionId( additionId )
			-- dump(additionData, "descipti666666666666666on")	
			if additionData.from == FuncCommon.additionFromType.GUILD and 
				additionData.type == tonumber(amountType) then
				isHas = true
				value = value + additionData.subNumber
				subType = additionData.subType
			end
		end
	end
	echo("______________isHas,value,subType __________",isHas,value,subType)
	return isHas,value,subType
end

function GuildModel:selectedSkillThemeId()
	return self.curThemeId or tonumber(LS:prv():get("user__guildWUJI__lastChooseThemeId","1"))
end

function GuildModel:recordSelectedSkillThemeId(themeId,isRecord)
	self.curThemeId = themeId
	if isRecord then
		LS:prv():set("user__guildWUJI__lastChooseThemeId",themeId)
	end
end
-- ==================================  仙盟科技用到的函数 end ==============================================

--仙盟任务的红点
function GuildModel:getTaskRed()
	local sysName = FuncCommon.SYSTEM_NAME.GUILDTASK
	local isopen = FuncCommon.isSystemOpen(sysName)
	if not isopen then
		return false
	end

	
	local isRed1 = self:getCostSpRed()
	local isRed2 = self:getTeamRed()
	local isRed3 = self:getWeekRewardRed()

	echo("====isRed1=======",isRed1,isRed2,isRed3)

	return isRed1 or isRed2 or isRed3 or  false

end

---消耗体力的红点
function GuildModel:getCostSpRed()
	local finishMaxNum = FuncGuild.getGuildTaskMaxCount()
	local finishCount = CountModel:getFinishGuildTaskNum() or 0 
	if finishCount >= finishMaxNum then
		return false
	end


	local _type = FuncGuild.guildTask_type.SP
	local data = FuncGuild.getDataByType(_type)
	local finishcondition =  math.abs(CountModel:getGuildTaskCostSPNum())
	local condition = tonumber(data.condition[1])
	if finishcondition >= condition then
		return true
	end
	return false

end

--组队的红点
function GuildModel:getTeamRed()
	local finishMaxNum = FuncGuild.getGuildTaskMaxCount()
	local finishCount = CountModel:getFinishGuildTaskNum() or 0 
	if finishCount >= finishMaxNum then
		return false
	end
	
	local _type = FuncGuild.guildTask_type.TEAM
	local data = FuncGuild.getDataByType(_type)
	local finishcondition =  math.abs(CountModel:getGuildTaskTeamNum())
	local condition = tonumber(data.condition[1])
	if finishcondition >= condition then
		return true
	end
	return false
end



function GuildModel:getEventListByType(_type)
	local newcevent = {}
	local event = self.allchatEventData
	local index = 1
	for i=1,table.length(event) do
		if event[i] ~= nil then
			if event[i].type == _type then
				newcevent[index] = event[i]
				index = index + 1
			end
		end
	end

	table.sort(newcevent,function(a,b)
		if a.time < b.time then
			return true
		else
			return false
		end

	end)
	return newcevent
end


--任务是否全部完成
function GuildModel:taskFanishIsAll()
	local count = CountModel:getFinishGuildTaskNum()
	local num = FuncGuild.getGuildTaskMaxCount()
	return count >= num
end

function GuildModel:getWeekRewardRed()
	local rank =  self:getWeekReward()
	if rank then
		return true
	end
	return false
end

--获取上周是否可以领取奖励
function GuildModel:getWeekReward()
	local getCount =  CountModel:getMagicEventFinishCount()

	echo("====获取上周=getCount=========",getCount)

	if getCount ~= 0 then
		return
	end

	-- dump(self.rankDataList,"5555555555555")
	if self.refreshgetRank then
		local guildId = UserModel:guildId()
		for k,v in pairs(self.rankDataList) do
			if tostring(k) == tostring(guildId) then
				return v.rank
			end
		end
	end
	return
end

--获取所有排行数据
function GuildModel:getRankAllData(_CallBack)
	local isaddGuild = GuildModel:isInGuild()
	if not isaddGuild then
		return
	end

	local function callBack(_param)
        if _param.result ~= nil then
        	-- dump(_param.result,"声望获取排行===2222==",8)
        	self.rankDataList = _param.result.data.list
        	if _CallBack then
        		_CallBack()
        	end
        end
    end

	local rankType = 42   --仙盟任务完成排行类型
	local beginRank = 1 
	local endRank = 50
	RankServer:getRankList(rankType,beginRank,endRank,callBack)
end


function GuildModel:getRinkGuildTaskData()

	local sysName = FuncCommon.SYSTEM_NAME.GUILDTASK
	local isopen = FuncCommon.isSystemOpen(sysName)
	if not isopen then
		return
	end
	local function _callback(_param)
		if _param.result then
			-- dump(_param.result,"==获取寻仙问道的数据排行数据===",8)
			self.allData = _param.result.data
			GuildModel:setrenownGlorys(self.allData)
		end
	end
	GuildServer:sendRinkGuildTask({},_callback)
end


function GuildModel:getGuildDigListData(cellfun)
	
	local function _callback(event)
		local data = {}
		if event.result then
			dump(event.result,"所有兑换的列表 ====")
			data = event.result.data.data
			self:initExchangeData(data)
		end
		if cellfun then
			cellfun()
		end
	end
	GuildServer:getGuildExchangeList(_callback)
end

-- 挖宝的铲子总数
function GuildModel:getToolMaxNum()
	local buildtable = self:getBuildsLevel()
	local level = buildtable[tonumber(2)]
	if not level then
		level = 1
	end
	local alldata = FuncGuild.getguildBuildUpAllData()
	local toolNum = alldata[tostring(2)][tostring(level)].toolsNumber

	return toolNum
end

-- 挖宝的铲子领取时间间隔
function GuildModel:getToolTimeInterval(  )
	local buildtable = self:getBuildsLevel()
	local level = buildtable[tonumber(2)]
	if not level then
		level = 1
	end
	local alldata = FuncGuild.getguildBuildUpAllData()
	local toolTimeInterval = alldata[tostring(2)][tostring(level)].toolsTime

	return toolTimeInterval
end

---点击宝箱兑换物品  new
function GuildModel:clickExchange(rewardID)
	local function _callback(event)
		if event.result ~= nil then
			GuildModel:resetBoxExchanreCount()
			dump(event.result,"兑换成功返回数据======")	
			local itemArray = event.result.data.reward
			EventControler:dispatchEvent(GuildEvent.REFRESH_TREASURE_MAIN_VIEW)
			WindowControler:showWindow("GuildDigRewardView", itemArray, FuncGuild.guildDig_Reward_From.DUIHUAN, rewardID);
		end
	end
	local params = {
		boxId  = rewardID
	}

	GuildServer:sendExchangeBoxData(params,_callback)
end

--仙盟宝物宝箱再开一次
function GuildModel:clickAgainExchange( rewardID )
	local function _callback(event)
		if event.result ~= nil then
			GuildModel:boxExchanreCountAdd()
			dump(event.result,"兑换成功返回数据======")	
			local itemArray = event.result.data.reward
			EventControler:dispatchEvent(GuildEvent.REFRESH_TREASURE_MAIN_VIEW)
			WindowControler:showWindow("GuildDigRewardView", itemArray, FuncGuild.guildDig_Reward_From.DUIHUAN, rewardID);
		end
	end
	local params = {
		boxId  = rewardID
	}
	GuildServer:sendRmbExchangeBoxData(params,_callback)
end

--宝库宝物一级页签红点刷新
function GuildModel:refreshGuildBaoKuRed()
	local data = FuncGuild.getAllExchangeData()
	local num = table.length(data)
	for i = 1,num do
		if self:boxExchaneIsOk(i) then
			return true
		end
	end
	return false
end

function GuildModel:isTodaySendWish()
	local count = CountModel:getCountByType(FuncCount.COUNT_TYPE.COUNT_TYPE_GUILD_WISH_TIMES)
    if count == nil then 
        count = 0
    end

    return count
end

return GuildModel;


