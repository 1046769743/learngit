-- RankAndcommentsControler.lua  
--[[
	Author: wk
	Date:2018-01-15
]]

local RankAndcommentsControler = RankAndcommentsControler or {}

function RankAndcommentsControler:init()
	self:registEvent()
end

function RankAndcommentsControler:registEvent()
-- 	EventControler:addEventListener(WorldEvent.WORLDEVENT_ENTER_ONE_MISSION,self.moveCharEnterSpace,self)
end

--[[
	local arrayData = {
		systemName = "",---系统名称
		diifID = ,  --关卡ID
	}
	FuncRankAndcomments.SYSTEM  = {
	elite = "elite",
	wonderLand = "wonderLand",
	trial = "trial",
	tower = "tower", --锁妖塔
	endless = "endless",--无底生源
}
]]

-- local arrayData = {
-- 	systemName = "elite",---系统名称
-- 	diifID = "20102",  --关卡ID
--	_type = "" 
-- }
-- RankAndcommentsControler:showUIBySystemType(arrayData)


--根据系统获取关卡攻略
function RankAndcommentsControler:showUIBySystemType(arrayData)
	dump(arrayData, "\n\narrayData===")
	local systemName = arrayData.systemName
	local diifID = arrayData.diifID
	if systemName == FuncRankAndcomments.SYSTEM.elite then  --回魂仙梦
		self:showAllUI(arrayData)
	elseif systemName == FuncRankAndcomments.SYSTEM.wonderLand then --须臾仙境
		self:showAllUI(arrayData)
	elseif systemName == FuncRankAndcomments.SYSTEM.tower then --	锁妖塔 ---仅显示评论
		self:showCommentsUI(arrayData)
	elseif systemName == FuncRankAndcomments.SYSTEM.trial then --试炼窟
		self:showAllUI(arrayData)
	elseif systemName == FuncRankAndcomments.SYSTEM.endless then --无底深渊
		local _type = arrayData._type or 1
		if _type == FuncRankAndcomments.RankAndCommentd_type.rankAndComment then
			self:showAllUI(arrayData)
		elseif _type == FuncRankAndcomments.RankAndCommentd_type.rank then
			self:showRankUI(arrayData)
		end
	elseif systemName == FuncCommon.SYSTEM_NAME.PARTNER then --伙伴
		self:showCommentsUI(arrayData)
	end

end
--	同时有侠士榜+评论功能
function RankAndcommentsControler:showAllUI(arrayData)
	
	local function _callback(param)
		local showView = WindowControler:showWindow("RankAndCommentsView");
        if param.result ~= nil then
        	-- dump(param.result,"========获取==侠士榜+评论功能 的 数据======")
        	local data = param.result.data
        	RankAndcommentsModel:setAllData(data)
        	if showView ~= nil then
        		showView:initData(arrayData)
        	end
        else
        	showView:initData(arrayData)
		end
    end
	local params = {
		system = arrayData.systemName,
		systemInnerIndex = arrayData.diifID,
		flagCommentOnly = arrayData.flagCommentOnly or 0,
	}
	RankAndcommentsServer:getDataBySystemName(params, _callback)
end
--	仅有侠士榜
function RankAndcommentsControler:showRankUI(arrayData)
	
	
	local function _callback(param)
		local showView = WindowControler:showWindow("RankMainView");
        if param.result ~= nil then
        	dump(param.result,"========获取==侠士榜的数据======")
        	local data = param.result.data
        	RankAndcommentsModel:setAllData(data)
        	if showView ~= nil then
        		showView:clickClose(showView)
        		showView:initData(arrayData)
        	end
        else
        	if showView ~= nil then
        		showView:clickClose(showView)
        		showView:initData(arrayData)
        	end
		end
    end
    local params = {
		system = arrayData.systemName,
		systemInnerIndex = arrayData.diifID,
		flagCommentOnly = arrayData.flagCommentOnly or 0,
	}
	RankAndcommentsServer:getDataBySystemName(params, _callback)
end
--	仅有评论
function RankAndcommentsControler:showCommentsUI(arrayData)
	
	local function _callback(param)
		local showView = WindowControler:showWindow("CommentsMainView");
        if param.result ~= nil then
        	-- dump(param.result,"========获取==评论的数据======")
        	local data = param.result.data
        	RankAndcommentsModel:setAllData(data)
        	if showView ~= nil then
        		showView:initData(arrayData)
        		showView:clickClose(showView)
        	end
        else
        	if showView ~= nil then
        		showView:initData(arrayData)
        		showView:clickClose(showView)
        	end
		end
    end
    local params = {
		system = arrayData.systemName,
		systemInnerIndex = arrayData.diifID,
		flagCommentOnly = arrayData.flagCommentOnly or 0,
	}
	RankAndcommentsServer:getDataBySystemName(params, _callback)
end

--	仅有评论  情景卡单独使用
function RankAndcommentsControler:showQingJingCommentsUI(arrayData)
	
	local function _callback(param)
		local showView = WindowControler:showWindow("MemoryPingLunView");
        if param.result ~= nil then
        	-- dump(param.result,"========获取==评论的数据======")
        	local data = param.result.data
        	RankAndcommentsModel:setAllData(data)
        	if showView ~= nil then
        		showView:initData(arrayData)
        		showView:clickClose(showView)
        	end
        else
        	if showView ~= nil then
        		showView:initData(arrayData)
        		showView:clickClose(showView)
        	end
		end
    end
    local params = {
		system = arrayData.systemName,
		systemInnerIndex = arrayData.diifID,
		flagCommentOnly = arrayData.flagCommentOnly or 0,
	}
	RankAndcommentsServer:getDataBySystemName(params, _callback)
end

--=获取所有评论的数据
function RankAndcommentsControler:getRankAndCommentAllData(arrayData,cellfunc)
		local function _callback(param)
        if param.result ~= nil then
        	-- dump(param.result,"========获取所有评论的数据======")
        	local data = param.result.data
        	RankAndcommentsModel:setAllData(data)
        	if cellfunc then
        		cellfunc()
        	end
		end
    end
    local params = {
		system = arrayData.systemName,
		systemInnerIndex = arrayData.diifID,
		flagCommentOnly = arrayData.flagCommentOnly,
	}
	RankAndcommentsServer:getDataBySystemName(params, _callback)
end



RankAndcommentsControler:init()

return RankAndcommentsControler
