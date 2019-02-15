-- GuildControler
local GuildControler = GuildControler or {}

function GuildControler:showTowerMainView()

	-- local iscd =GuildModel:closeGuildTime()
	-- if not iscd then
		local isaddGuild = GuildModel:isInGuild()
		if isaddGuild then
			-- self:getGuildInfoData()
			self:getMemberList(1)
		else 
			--跳转到创建加入界面
			-- FuncCommon.openSystemToView("guild")
			WindowControler:showWindow("GuildCreateAndAddView");
		end
	-- else
	-- 	WindowControler:showTips("退盟后12小时内无法再次加入")
	-- end
	-- WindowControler:showWindow("GuildPlayerInfoView")
end


function GuildControler:touchToMainview()
	local isaddGuild = GuildModel:isInGuild()
	if not isaddGuild then
		EventControler:dispatchEvent(GuildEvent.CLOSE_ALL_VIEW_UI)
		
		WindowControler:showTips(GameConfig.getLanguage("#tid_group_xianmeng_001"))--FuncGuild.TipStr)
		return false
	end
	return true
end


function GuildControler:getGuildInfoData(_type)

	-- local guildId = UserModel:guildId()

	-- local function _callback(_param)
		-- dump(_param.result,"搜索自己的公会数据",8)
	-- 	if _param.result then
	-- 		local infodata = _param.result.data.guild
	-- 		GuildModel:setbaseGuildInfo(infodata)
	-- 	else
	-- 		GuildModel:setbaseGuildInfo({})
	-- 	end
		self:getMemberList(_type or 1)
	-- end 
	-- echo("======guildId========",guildId)
	-- local params = {
	-- 	id = tostring(guildId)
	-- };
	-- GuildServer:findGuild(params,_callback)
	
end

function GuildControler:getAddGuildDataList(_type)
	-- WindowControler:showWindow("GuildAddView");
	local function _callback(_param)
		-- dump(_param.result,"公会列表数据",8)
		if _param.result then
			local datalist = _param.result.data.guild
			GuildModel:setguildAllList(datalist)
			if _type ~= nil then
				WindowControler:showWindow("GuildAddView");
			else
				WindowControler:showWindow("GuildOtherGuildListView");
			end
		end
	end

	local params = {
		page = 1,
		all = 1,
	};
	GuildServer:listGuild(params,_callback)
end


function GuildControler:getAppList(callfun)
	local isaddGuild = GuildModel:isInGuild()
	if not isaddGuild then
		return 
	end
	local function _callback(_param)
		-- dump(_param.result,"申请列表",8)
		if _param.result then
			local datalist = _param.result.data.data
			GuildModel:setguildApplyList( datalist )
			-- WindowControler:showWindow("GuildApplyView");
		else
			--错误的情况

		end
		if callfun then
			callfun()
		end
	end 
	local params = {
		id = GuildModel:isInGuild(),
	}
	GuildServer:getApplyList(params,_callback) 
end

--获得公会成员列表
function GuildControler:getMemberList(_file,_callfun)
	local isaddGuild = GuildModel:isInGuild()
	if not isaddGuild then
		if _callfun then
			_callfun()
		end
		return false
	end

	local function _callback(_param)
		-- dump(_param.result," ===================== 公会数据",8)
		if _param.result then
			local infodata = _param.result.data.guild
			local datalist = _param.result.data.members
			local voteslist = _param.result.data.votes
			GuildModel:setbaseGuildInfo(infodata)
			GuildModel:setGuildMembersInfo(datalist)
			GuildModel:setvotes( voteslist )
		else
			--错误的情况
			GuildModel:setGuildMembersInfo({})
			UserModel._data.guildId = ""
			WindowControler:showTips(GameConfig.getLanguage("#tid_group_xianmeng_001"))
			WindowControler:showWindow("GuildCreateAndAddView");
			return
		end
		if _file == 1 then
			WindowControler:showWindow("GuildInFoView");
			GuildBossModel:enterGuildBossMainView()
		elseif _file == 2 then
			WindowControler:showWindow("GuildMainView")
			if _callfun then
				_callfun()
			end
		elseif _file == 3 then
			WindowControler:showWindow("GuildMainBuildView")
			
		elseif _file == "" then
			echo("________ gve活动邀请在主城的玩家 信息准备__________")
			if _callfun then
				_callfun()
			end
		else
			self:getOnLine()
			-- WindowControler:showWindow("GuildMemberListView");
			EventControler:dispatchEvent(GuildEvent.REFRESH_MEMBERS_LIST_EVENT)
		end
		
	end 
	-- local params = {
	-- 	id = UserModel:guildId(),
	-- }
	GuildServer:getMembers({},_callback)

end
function GuildControler:getOnLine()
	    local function _callback(_param)
        -- dump(_param,"在线数据111111",8)
        GuildModel:setOnLinePlayer(_param)
    end
    GuildServer:sendMotched(_callback)
end
--查看心愿列表
function GuildControler:getEvent(callback)
	local function _servercallback(_param)
		-- dump(_param.result,"查看公会事件件列表",8)
		if _param.result then
			local datalist = _param.result.data.data
			GuildModel:setchatEventData(datalist)
			callback()
		else
			--错误的情况
		end
	end 
	local allevent = GuildModel.allchatEventData
	local num =  table.length(allevent) 
	local low = math.floor(num/20)
	local line = math.fmod(num, 20)
	local page = 1
	if low ~= 0 then
		if line ~= 0 then
			page = low + 1
		end
	end

	local params = {
		page = page,
	}

	GuildServer:sendGetEvent(params,_servercallback)
end


--查看心愿历史事件
function GuildControler:getWishEvent()
	local function _callback(_param)
		-- dump(_param.result,"查看心愿历史事件列表",8)
		if _param.result then
			local datalist = _param.result.data.data
			local memberList = GuildModel:getGuildMembersInfo()
			local dataList = {}
			for k,v in pairs(datalist) do     ---- 判断这两个成员是否同时在一个仙盟里
				if memberList[v.receive] and memberList[v.send] then
					dataList[#dataList+1] = v
				end
			end
			GuildModel:setAllHistorRec( dataList )
		else
			--错误的情况
		end
		WindowControler:showWindow("GuildHistorRecView");
	end 


	GuildServer:sendGetWishEvent(_callback)
end

--获得祈福列表
function GuildControler:getWishList()
	local function _callback(_param)
		-- dump(_param.result,"查看心愿列表",8)
		if _param.result then
			local datalist = _param.result.data.data
			GuildModel:setAllWishList(datalist)
		else
			--错误的情况
		end
		-- WindowControler:showWindow("GuildBlessingView");
	end 

	-- WindowControler:showWindow("GuildBlessingView");
	-- WindowControler:showWindow("GuildWelfareMainView")

	local params = {
		page = 1,
	}
	GuildServer:sendWishList(params,_callback)
end



function GuildControler:notpermissions()
	local isboos = GuildModel:judgmentIsForZBoos()   --是否是盟主 or 副盟主
	if isboos == false then
		WindowControler:showTips(GameConfig.getLanguage("#tid_group_xianmeng_002"))
	end
	return false
end


--显示共闯秘境相关的
function GuildControler:showGuildBossUI()
	-- GuildBossModel.hasInitData = false
	
	-- local showView = --创建的视图
	
	local function initDataBack()
		local serveTime = TimeControler:getServerTime()
		local isonTime = FuncGuildBoss.isOnTime(serveTime)
		echo("=====isonTime====开启时间=======",isonTime)
		if isonTime then
			--时间到了 --跳转到详情界面
			WindowControler:showWindow("GuildBossInfoView")
		else
			--还没到时间  --跳转到预约开启界面
			WindowControler:showWindow("GuildBossOpenView")
		end
	end
	GuildBossModel:enterGuildBossMainView(initDataBack)

end

--显示红包详情界面
function GuildControler:showRedPacketInfoView(packetData)

	local function _callback(event)
		if event.result then
			dump(event.result,"======详情红包返回数据========")
			local data = event.result.data.details
			data.packetId = packetData.packetId
			data._id = packetData._id
			data.rid = packetData.rid
			WindowControler:showWindow("GuildHongBaoInfoView",data);
		end
	end

	local params = {
		id = packetData._id,
	}
	GuildServer:getRedPacketInFoLast(params,_callback)
end


return GuildControler