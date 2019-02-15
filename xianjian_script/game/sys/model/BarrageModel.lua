-- BarrageModel
-- Author wk
-- time 2018/01/30


local BarrageModel = class("BarrageModel", BaseModel);

BarrageModel.ISOPEN = true

function BarrageModel:init(data)
    BarrageModel.super.init(self, data)
    self:registerEvent()
    self.showBarrageArr = {}
    self:getLocalShowBarrage()
    --提前获取公会信息
    ChatShareControler:getGuildNotlineData()
end

function BarrageModel:registerEvent()
	-- EventControler:addEventListener(TowerEvent.TOWEREVENT_ENTER_NEXTFLOOR_COMPLETE,self.sjsjsla, self)
end

-- function BarrageModel:sjsjsla( ... )
-- 	echo("-----------测试回调用法-----------")
-- end


function BarrageModel:getNextTowerRankData(cellfunc)
		-- 寻找bossId

	local function callback()
		if cellfunc then
			cellfunc()
		end
	end

	local floor = TowerMainModel:getCurrentFloor() 
	local monsterId = TowerMapModel:findBossMonsterId( floor ) -- self:findBossMonsterId(floor)
	local arrayData = {
		systemName = FuncCommon.SYSTEM_NAME.TOWER,---系统名称
		diifID = monsterId,  --关卡ID
		flagCommentOnly = 1,
	}
	BarrageControler:getRankAndCommentsData(arrayData,false,callback)
end

----------------------------------剧情----------------------------------------
--[[
data = {
	comment = "",--聊天信息
	istouch = false,--是否可以点击
	praiseNum = 100,--赞的数量‘
	myPraise = true,false---自己是否赞过
}
]]

---获取所有剧情的数据
function BarrageModel:getPlotCommentData(plotData,callback)

	local function cellfunc(data)
		-- dump(data,"剧情获得所有数据==000===")
		if data == nil then
			callback({})
			self.allPlotData  = nil
			return
		end
		if callback then  
			local newcomment = {}
			-- callback(data)
			local comment =  data.comments
			if comment ~= nil then
				for i=1,#comment do
					local newdata = {
						comment = comment[i].comment or "仙剑情缘",--聊天信息
						istouch = false,--是否可以点击
						praiseNum = comment[i].likeCount or 0,--赞的数量‘
						myPraise = comment[i].doILike or 0,--false---自己是否赞过
						order = comment[i].order or 1,
						systemName = "plot",
						diifID = plotData.plotID or plotData[1],
						postId = comment[i].id,
						time = comment[i].time or TimeControler:getServerTime(), 
					}
					newcomment[i] = newdata
				end
				self.allPlotData = self:plotDataSort(newcomment)
				callback(self.allPlotData)
			else
				callback({})
			end
		end
	end

	local arrayData = {
		systemName = "plot",
		plotID = plotData.plotID or plotData[1],
		flagCommentOnly = 1,
	}
	self:getRankAndCommentAllData(arrayData,cellfunc)

end

function BarrageModel:plotDataSort(data)
	
	local plot_table_sort = function (a,b)
        if a.praiseNum > b.praiseNum then
            return true
        else
        	if a.praiseNum == b.praiseNum then
	            if a.time < b.time then
	            	return true
	            else
	            	return false
	            end
	        else
	        	return false
	        end
        end
    end

    table.sort(data,plot_table_sort)
    return data
end



--------------------------------------------------------------------------------



---------------------------------巅峰竞技场------------------------------------------------
--[[
data = 
{	comment = "",--聊天信息
	istouch = false,--是否可以点击
}
]]  ----私聊相关数据 处理  --巅峰竞技场 
function BarrageModel:getPrivateChatCommentData(player_rid)
	local commentData = {}
	-- local rid = player_rid
	-- if rid ~= nil then
	--  	local allCommentData =  ChatModel:getPrivateDataByRid(rid)
	-- 	if allCommentData ~= nil and #allCommentData ~= 0 then
	-- 		for i=1,#allCommentData do
	-- 			commentData[i] = {
	-- 				comment = allCommentData[i].comment,
	-- 				istouch = false,
	-- 			}
	-- 		end
	-- 	end
	-- end
	return commentData
end

----------------------------------------------------------------------------------


--------------------------------六界---聊天----------------------------------------------------
--[[
data = {
	comment = "",--聊天信息
	istouch = false,--是否可以点击
	callback = ,--可点击跳转显示的东西--暂不需要
	titleType = ,--聊天的标题
	isvoice = true, 聊天中，是不是语音聊天
	voiceTime = ,--语音时间
	voiceID = , --语音ID
}
]]  ---获取聊天相关的数据
-- local  data = {
--     param1 = GameConfig.getLanguage("#tid_Talk_101"),
--     param2 = nil,
--     time   = TimeControler:getServerTime(),
--     chattype   = 9,
-- }
function BarrageModel:getWorldChatData(_type)
	local systemMessage =  ChatModel:getSystemMessage()  --系统的数据
	local worldMessage = ChatModel:getWorldMessage()   --世界数据
	local leagueMessage = ChatModel:getLeagueMessage() --仙盟数据
	-- local loveMessage = {}--ChatModel:getLoveMessage() --缘伴数据

	local alldata = {}
	if _type == nil then
		if systemMessage ~= nil  then
			alldata = self:setdataByChatComment(1,systemMessage,alldata)
		end
		if worldMessage ~= nil  then
			alldata = self:setdataByChatComment(2,worldMessage,alldata)
		end
		if leagueMessage ~= nil  then
			alldata = self:setdataByChatComment(3,leagueMessage,alldata)
		end
	elseif _type == "guild" then 
		if leagueMessage ~= nil  then
			alldata = self:setdataByChatComment(3,leagueMessage,alldata)
		end
	end
	-- if loveMessage ~= nil  then
	-- 	alldata = self:setdataByChatComment(4,loveMessage,alldata)
	-- end
		
	local sortFunc = function (h1,h2)
		if h1.time > h2.time then
			return true
		else
			return false
		end

	end

	table.sort(alldata,sortFunc)
	
	return alldata
end

function BarrageModel:setdataByChatComment(_type,olddata,newdata)
	if olddata ~= nil then
		for i=1,#olddata do
			local comment = nil
			local isvoice = false
			local voiceID = nil
			local voiceTime = nil
			if _type == 1 then
				comment = ChatModel:setSyetemdataStr(olddata[i])
				-- comment = olddata[i].param1 or olddata[i].content
			else
				comment = olddata[i].content
				if olddata[i].type == FuncChat.EventEx_Type.voice then
					local content = json.decode(olddata[i].content)
					isvoice = true
					voiceTime = content.time
					voiceID = content.fileID
				elseif  olddata[i].type == FuncChat.EventEx_Type.guildinvite then
					comment = nil
				elseif  olddata[i].type == FuncChat.EventEx_Type.shareArtifact then
					comment = nil
				elseif  olddata[i].type == FuncChat.EventEx_Type.shareTreasure then
					comment = nil
				end
			end

			if comment ~= nil then
				local  data = {
					comment = comment ,--leagueMessage[i].param1 or "仙剑",--聊天信息
					istouch = false,--是否可以点击
					callback = nil,--可点击跳转显示的东西--暂不需要
					titleType = _type,--聊天的标题
					isvoice = isvoice or false, --聊天中，是不是语音聊天
					voiceTime = voiceTime or 0,--语音时间
					voiceID = voiceID or nil, --语音ID
					time = olddata[i].time,
				}
				table.insert(newdata,data)
			end
		end
	end
	return newdata
end

------------------------锁妖塔数据--------------------------------
--[[
data = {
	comment = "",--聊天信息
	istouch = false,--是否可以点击
}
]]  ----锁妖塔数据 处理
function BarrageModel:gettowerCommentData()
	local commentData = {}
 	local allCommentData =  RankAndcommentsModel:getAllCommentsInfoData()
 	allCommentData = self:towerSort(allCommentData)
 	-- dump(allCommentData,"00000000000000")
	if allCommentData ~= nil and #allCommentData ~= 0 then
		for i=1,#allCommentData do
			commentData[i] = {
				comment = allCommentData[i].comment,
				istouch = false,
			}
		end
	end
	return commentData
end
function BarrageModel:towerSort(data)
	local tower_table_sort = function (a,b)
        if a.likeCount > b.likeCount then
            return true
        else
        	if a.likeCount == b.likeCount then
	            if a.time <= b.time then
	            	return true
	            else
	            	return false
	            end
	        else
	        	return false
	        end
        end
    end

    table.sort(data,tower_table_sort)
    return data


end
--------------------------------------------------------------




function BarrageModel:setAllData(_type,oldData,newData)

	if _type == FuncBarrage.SystemType.plot then
		oldData = self:setplotMyselfData(oldData ,newData)
	elseif _type == FuncBarrage.SystemType.crosspeak then
		oldData = self:setcrosspeakData(oldData ,newData)
	elseif _type ==  FuncBarrage.SystemType.tower then
		oldData = self:setTextData(oldData ,newData)
	elseif _type ==  FuncBarrage.SystemType.world then
		self:setWorldData(oldData ,newData)
	end
	return oldData
end

function BarrageModel:setplotMyselfData(oldData ,newData)
	-- dump(newData,"44444444=========")
	if oldData  ~= nil then
		table.insert(oldData,newData)
	end

	return oldData
end

function BarrageModel:setWorldData(oldData ,newData)
	-- dump(newData,"1111111111111111========")

end

function BarrageModel:setcrosspeakData(oldData,data)
	local oldData = oldData
	if oldData  ~= nil then
		local commentData = {
			comment = data.params.data.content,
			istouch = false,
		}
		table.insert(oldData,commentData)
	end
	return oldData

end




--锁妖塔的村文本弹幕
function BarrageModel:setTextData(oldData ,data)
	local oldData = oldData
	if oldData  ~= nil then
		local commentData = {
			comment = data.comment,
			istouch = false,
		}
		table.insert(oldData,commentData)
	end
	return oldData
end

--处理弹幕是否显示
function BarrageModel:getoffAndONBysystem(system)
	local isshow = true
	if system == FuncBarrage.SystemType.plot then
		isshow = self:getIsShowByType(FuncBarrage.BarrageSystemName.plot)
	elseif system == FuncBarrage.SystemType.crosspeak then
		isshow = self:getIsShowByType(FuncBarrage.BarrageSystemName.crossPeak)
	elseif system ==  FuncBarrage.SystemType.tower then
		isshow = self:getIsShowByType(FuncBarrage.BarrageSystemName.comments)
	elseif system ==  FuncBarrage.SystemType.world then
		isshow = self:getIsShowByType(FuncBarrage.BarrageSystemName.world)
	end
	return isshow
end
--根据系统名来判断是否显示弹幕
 function BarrageModel:bySystemShowBarrage(system)
 	local _type = nil
 	if system == FuncBarrage.SystemType.crosspeak then
 		_type = FuncBarrage.BarrageSystemName.crossPeak
	elseif system == FuncBarrage.SystemType.plot then
		_type = FuncBarrage.BarrageSystemName.plot
	elseif system == FuncBarrage.SystemType.tower then
		_type = FuncBarrage.BarrageSystemName.comments
	elseif system == FuncBarrage.SystemType.world then
		_type = FuncBarrage.BarrageSystemName.world
	end
	return _type
 end



--=获取所有评论的数据
function BarrageModel:getRankAndCommentAllData(arrayData,cellfunc)
	if arrayData ~= nil then
		if arrayData.plotID ~= nil then
			local function _callback(param)
		        if param.result ~= nil then
		        	-- dump(param.result,"=======剧情=获取所有评论的数据======")
		        	local data = param.result.data
		        	
		        	if cellfunc then
		        		cellfunc(data)
		        	end
				end
		    end
		    local params = {
				system = arrayData.systemName,
				systemInnerIndex = arrayData.plotID,
				flagCommentOnly = arrayData.flagCommentOnly or 0,
			}
			RankAndcommentsServer:getDataBySystemName(params, _callback)
		end
	end
end

--[[
local arrData = {
	plotID = ,--剧情ID
	_text = "",--剧情评论
	order = ,---剧情的第几段

}
]]
--=====发送评论到服务器===
function BarrageModel:sendContentToServer(arrData,callfun)
	-- echo("=====发送评论到服务器===",_text)
	dump(arrData,"=====发送评论到服务器===")
	local function _callback(param)
        if param.result ~= nil then
			local data = param.result.data
			-- dump(param.result,"=====发送评论到服务器===")
			local arrData = {
			    comment = arrData._text or "",--聊天信息
		        istouch = false,--是否可以点击
		        praiseNum = 0,--赞的数量‘
		        myPraise = 0,---自己是否赞过
		        systemName = "plot",
				diifID = arrData.plotID,
				postId = data.postId,
				time = TimeControler:getServerTime(),
			}
			if callfun then
				callfun()
			end
			WindowControler:showTips("发送成功")
			EventControler:dispatchEvent(BarrageEvent.BARRAGE_SEND_PLOT_MYSELF_EVENT,arrData)
		end
    end

	local params = {
		system = "plot",
		systemInnerIndex  = arrData.plotID, --剧情ID
		content = arrData._text, --剧情评论
		order = arrData.order,  ---剧情的第几段
	}

	RankAndcommentsServer:addCommentsToserver(params, _callback)

end

---根据剧情ID获得剧情评论
function BarrageModel:getPlotData(allData,plotData)
	-- dump(allData ,"====显示弹幕发送界面的数据===")
	-- dump(plotData ,"====显的数据===")
	local plotID = nil
	local order = 1
	local newData = {}
	if plotData ~= nil then
		if plotData.plotData ~= nil then
			plotID = plotData.plotData.plotID
			order = plotData.plotData.order or 1
		end
	else
		return newData
	end

	
	local plotAllData = nil
	if allData ~= nil then
		plotAllData = allData
	end
	local index = 1
	if plotAllData ~= nil then
		if #plotAllData ~= 0 then
			for i=1,#plotAllData do
				if plotAllData[i].order ~= nil then
					if tonumber(plotAllData[i].order) == tonumber(order) then
						newData[index] = plotAllData[i]
						index = index + 1
					end
				end
			end
		end
	end
	if plotID ~= nil then
		local barragelanguage =	FuncBarrage.getBarrageSystemDataByPlotID(plotID)
		if barragelanguage ~= nil then
			for k,v in pairs(barragelanguage) do
				if tonumber(v.order) == tonumber(order) then
					local data = {
					    comment   = GameConfig.getLanguage(v.translateId),
					    istouch   = false,
					    myPraise  = 0,
					    order     = v.order,
					    praiseNum = v.prise,
					}
					table.insert(newData,data)
				end
			end
		end
	end
	return newData
end

--设置本地弹幕显示问题
function BarrageModel:setshowBarrage(_type,isshow)
	echo("======_type_type_type========",_type,isshow)
	LS:prv():set(StorageCode.barrage_type.._type,isshow)
end

--获取本地弹幕是否显示
function BarrageModel:getshowBarrage(_type)
	local isshow = LS:prv():get(StorageCode.barrage_type.._type)
	if isshow == nil then
		isshow = true
	end
	if type(isshow) == "string" then
		if isshow == "false" then
			isshow = false
		else
			isshow = true
		end
		
	end
	return isshow
end


--获取本地显示弹幕的数据
function BarrageModel:getLocalShowBarrage()
	local barrageType = FuncBarrage.BarrageSystemName
	for k,v in pairs(barrageType) do
		self.showBarrageArr[k] = self:getshowBarrage(v)
	end
end

---设置self.的数据是否显示
function BarrageModel:setbarrageModeData(_type,isshow)
	if self.showBarrageArr ~= nil then
		self.showBarrageArr[_type] = isshow
	end
	self:setshowBarrage(_type,isshow)
end

---根据系统来获取是不是显示弹幕
function BarrageModel:getIsShowByType( _type )

	if self.showBarrageArr[_type] ~= nil then
		return self.showBarrageArr[_type]
	end
	return true
end


---设置弹幕语音类型
function BarrageModel:setVoiceTypeAndData(data,_type)
	self.voiceData = data
	self.voiceType = _type
end

--获取弹幕语音类型  巅峰和 剧情
function BarrageModel:getVoiceType()
	return self.voiceType,self.voiceData 
end


function BarrageModel:sendPlotChatToServe(data ,callfun)

    local arrData = {
        plotID = data.plotID, ---self.alldata.plotData.plotID,
        _text = data._text,
        order = data.order, --self.alldata.plotData.order or 1,
    }
    BarrageModel:sendContentToServer(arrData,callfun)
end

function BarrageModel:sendCrosspeakToServe(playerData,_text,cellFun)
	   local function callback(param)
        if(param.result~=nil)then--//没有其他操作

        	WindowControler:showTips("发送成功");
        	if cellFun then
        		cellFun(param)
        	end
            
        end
    end
	local isbadword,_text = Tool:checkIsBadWords(_text)
	if isbadword == true then
	  	_tipMessage = GameConfig.getLanguage("tid_friend_ban_word_1004");
	  	WindowControler:showTips(_tipMessage);
	else
	    local _rid = playerData._player.rid or playerData._player._id
	    local  _param={};
	    _param.type = 1
	    _param.target=_rid;
	    _param.content=_text;
	    ChatServer:sendPrivateMessage(_param,callback);
	end
end


-- BarrageModel:init()
return BarrageModel;
