


--[[
阵前站位
基本的网络交互
]]


local TeamFormationServer = class("TeamFormationServer")

function TeamFormationServer:init()
	EventControler:addEventListener("notify_crosspeak_battleOperation", self.notify_crosspeak_battleOperation, self)
end


--[[
执行上阵操作
]]
function TeamFormationServer:doFormation( params,callBack )
    Server:sendRequest(params, MethodCode.formation_doformation_347, callBack )
end






--== =============================================================================================== ==--
-- 									多人布阵的网络交互  可能为临时用 								--
--== =============================================================================================== ==--



--[[
客户端申请加入房间
]]
function TeamFormationServer:doJoinRoom( params,callBack )
	echo("发送消息，加入房间------")
	Server:sendRequest(params, MethodCode.formation_doJoinRoom_4715, callBack )
end




--[[
上阵法宝
]]
function TeamFormationServer:doOnTreasure(params,callBack)
	
	-- dump(params)
	-- echoError("上阵法宝信息-----------错误查找  不是错误")
	--Server:sendRequest(params, MethodCode.formation_onTrea_4701, callBack )
	--
	Server:sendRequest(params, MethodCode.battle_treasure_on_5021, callBack )
end



--[[
上阵伙伴  修改伙伴位置  下阵伙伴都需要修改
]]
function TeamFormationServer:doOnPartner(params,callBack)
	-- dump(params)

	-- -- LogsControler:writeDumpToFile(params, 8, 8)
	-- echoError("上阵伙伴的信息--------------错误查找 不是错误")


	--Server:sendRequest(params, MethodCode.formation_onPartner_4703, callBack )
	--
	Server:sendRequest(params, MethodCode.battle_partner_on_5023, callBack )
end


--[[
多人布阵  发送超时操作
]]
function TeamFormationServer:doTimeOut(params,callBack)
	-- dump(params)
	-- echoError("多人布阵发送超时请求------------错误朝找  不是错误")
	Server:sendRequest(params,MethodCode.battle_formation_timeOut_5029,callBack)
end





--[[
锁定阵型
]]
function TeamFormationServer:doLockFormation(params,callBack)
	Server:sendRequest(params,MethodCode.battle_lock_formation_5027,callBack)
end


--[[
离开房间
]]
function TeamFormationServer:doLevelRoom(params,callBack)
	--Server:sendRequest(params, MethodCode.formation_doLevelRoom_4717, callBack )
	--MethodCode.battle_formation_level_5049
	Server:sendRequest(params, MethodCode.battle_formation_level_5049, callBack )
end


function TeamFormationServer:doChangeWuXing(params,callBack)
	Server:sendRequest(params, MethodCode.battle_setElement_5061, callBack )
end


--[[
多人布阵中的聊天
]]
function TeamFormationServer:doFormationChat(params,callBack)
	
	-- echoError("多人布阵中的聊天 查找错误不是错误")
	-- dump(params)
	Server:sendRequest(params,MethodCode.battle_multi_chat_5025,callBack)
end


function TeamFormationServer:doLineUpPartner(params,callBack)

	Server:sendRequest(params,MethodCode.battle_multi_lineUp_5053,callBack)
end

function TeamFormationServer:changePos(params,callBack)

	Server:sendRequest(params,MethodCode.battle_exchange_5063,callBack)
end

-- ##################### 共闯秘境多人布阵交互
-- 准备连接RealTimeServer(参考CrossPeakModel:matchSucceed()方法)
-- function TeamFormationServer:enterGVEFormation(event)
-- 	ServerRealTime:startConnect( event.params.params.data,c_func(self.onBattleStart,self)  )
-- end
-- function TeamFormationServer:onBattleStart( )
-- 	-- 这里保存batleId
-- 	if event.result then
-- 		local data = event.result.data
-- 		self.battleId = data.battleId
-- 	else
-- 	end
-- end
-- 布阵操作枚举
-- {pid,rid,pos} pid = 1 是主角,rid上阵的角色rid，pos位置
TeamFormationServer.hType_disconnect = 3   --断开ServerRealTime链接
TeamFormationServer.hType_finishBattle = 101   --战斗结束或者退出布阵
TeamFormationServer.hType_upHero = 102 --战前上阵奇侠
TeamFormationServer.hType_exHero = 103 --战前交换奇侠
TeamFormationServer.hType_upWuLing = 104 --战前上阵五灵
TeamFormationServer.hType_exWuLing = 105 --战前交换五灵
TeamFormationServer.hType_finish = 106 --战前布阵结束
TeamFormationServer.hType_upTreasure = 118 --战前更换法宝
TeamFormationServer.hType_enterBattle = 119 --进入战斗
-- 布阵阶段操作推送
function TeamFormationServer:notify_crosspeak_battleOperation(e)
	local netData = e.params.params
	if netData.type == TeamFormationServer.hType_upHero then
		EventControler:dispatchEvent(TeamFormationEvent.MULTI_UP_PARTNER, {params = netData})
	elseif netData.type == TeamFormationServer.hType_exHero then
		EventControler:dispatchEvent(TeamFormationEvent.MULTI_EXCHANGE_PARTNER, {params = netData})
	elseif netData.type == TeamFormationServer.hType_finish then
		EventControler:dispatchEvent(TeamFormationEvent.MULTI_FINISH_TEAM, {params = netData})
	elseif netData.type == TeamFormationServer.hType_upTreasure then
		EventControler:dispatchEvent(TeamFormationEvent.MULTI_UP_TREASURE, {params = netData})
	elseif netData.type == TeamFormationServer.hType_upWuLing then
		EventControler:dispatchEvent(TeamFormationEvent.MULTI_UP_WULING, {params = netData})
	elseif netData.type == TeamFormationServer.hType_exWuLing then
		EventControler:dispatchEvent(TeamFormationEvent.MULTI_EXCHANGE_WULING, {params = netData})
	elseif netData.type == TeamFormationServer.hType_enterBattle then
		GuildBossModel:onBattleStart(netData)
	end
	-- body
end
-- 上阵一个奇侠
function TeamFormationServer:sendPickUpOneHero(info)
	self:sendOneHandle(TeamFormationServer.hType_upHero, info)
end

-- 结束布阵
function TeamFormationServer:sendFinishTeamFormation(info)
	self:sendOneHandle(TeamFormationServer.hType_finish, info)
end

-- 交换阵上奇侠
function TeamFormationServer:sendExchangeHeros(info)
	self:sendOneHandle(TeamFormationServer.hType_exHero, info)
end

-- 更换法宝
function TeamFormationServer:sendExchangeTreasure(info)
	self:sendOneHandle(TeamFormationServer.hType_upTreasure, info)
end

-- 上阵一个五灵
function TeamFormationServer:sendPickUpOneWuLing(info)
	self:sendOneHandle(TeamFormationServer.hType_upWuLing, info)
end

-- 交换阵上五灵
function TeamFormationServer:sendExchangeWuLing(info)
	dump(info, "\n\ninfo=====")
	self:sendOneHandle(TeamFormationServer.hType_exWuLing, info)
end

function TeamFormationServer:sendOneHandle(type,info)
	local handleInfo = {
		type = type,
		rid = UserModel:rid(),
		info = json.encode(info),
		index = 0,
		battleId = self.battleId,
		wave = 1,
		round = 1,
		attackNums = nil,
	}
	ServerRealTime:sendRequest(handleInfo,MethodCode.battle_battleOperation,c_func(self.onSendHandleBack,self),true,true,false )
end
function TeamFormationServer:onSendHandleBack( result )
	if result.error then
		echo("_这里应该直接退出战斗----")
		EventControler:dispatchEvent(TeamFormationEvent.CLOSE_TEAMVIEW)
	end
end

TeamFormationServer:init()
return TeamFormationServer