--
-- Author: xd
-- Date: 2017-08-01 14:49:27
--
--主要处理 登入之后的一些信息 分担LoginControler压力
local LoginInfoControler = {}
LoginInfoControler.MatchingType = {
    FREE = "1",  --空闲
    MATCHING = "2",  --匹配中
    BATTLE = "3",   --战斗中
    TEAM = "4",     --组队中
    GVESCENE = "6", --GVE战斗场景中
    GVEBATTLE = "7",--GVE战斗中(这个理论上不会出现的)
};
--当登入游戏之后的状态信息 status,状态数据  
--isReLogin 是否是重连上的 
function LoginInfoControler:onBattleStatus( data,isReLogin )
    -- dump(data.battleInfo,"重连数据---222",8)
    if not data.status or data.status.status == LoginInfoControler.MatchingType.FREE  then
        --仙盟gve 判断是否是非空闲
        self:gveReconnection( data,isReLogin)
        return
    end    


    
    if data.status.status == LoginInfoControler.MatchingType.GVESCENE then
        self:gveReconnection( data,isReLogin)
        self:gveBattle(data)
    --如果是在战斗中
    elseif data.status.status ==  LoginInfoControler.MatchingType.BATTLE then
        if BattleControler:isInBattle() then
            -- 已经在战斗中了，不需要重新进战斗
            return
        end
        if not data.battleInfo then
            return
        end
        local battleInfo = data.battleInfo
       
        echo("__掉线重连进战斗")
        ServerRealTime:startConnect( battleInfo,c_func(self.onBattleStart,self)  )
        -- BattleControler:startBattleInfo(battleInfo)


    else

        if not data.status.poolType then
            return
        end
        local poolType = data.status.poolType
        echo(poolType,"_____",GameVars.poolSystem.crossPeak ==poolType )
        if poolType ==  GameVars.poolSystem.trail1 or 
            poolType ==  GameVars.poolSystem.trail2 or
            poolType ==  GameVars.poolSystem.trail3 then
            self:TrialReconNection(data,isReLogin)
        elseif poolType ==  GameVars.poolSystem.crossPeak then
            self:crossPeakReconnection(data,isReLogin)
        end
    end
end

function LoginInfoControler:onBattleStart( event )
    -- echo("battleStart----")
    if not event.result then
        echoWarn("___战斗开始报错")
        Server:sendRequest({},MethodCode.user_resetUserStatus,nil,true,true,false )
        return
    end
    local data = event.result.data
    local serverData = data
    -- serverData.battleLabel = GameVars.battleLabels.crossPeakPvp
    local battleInfo = BattleControler:turnServerDataToBattleInfo(serverData)
    BattleControler:startBattleInfo(battleInfo);
end

-- 注意这里只处理断网重连的情况
-- 客户端重登的情况在loginControler中做了数据缓存 在model中处理了
function LoginInfoControler:gveReconnection( data ,isReLogin)
    if not isReLogin  then
        echo("__ gveReconnection 重登客户端 已在loginControler中处理 ")
        return
    end

    -- dump(data, "_________ gveReconnection 断网重连的数据 _______ ")
    --如果不是仙盟gve , 但是我可能当前的场景是在gve里面的
    if not data or data.status.status ~= LoginInfoControler.MatchingType.GVESCENE then
        -- 如果当前有gve数据  我就需要销毁数据,同时销毁当前的gve场景
        if not GuildActMainModel:isInNewGuide() then
            GuildActMainModel:resetGveStatus()
        end
    else
        echo("________ 同步gve 挑战中 状态 ________ ")
        GuildActMainModel:setReconnectionData(data)
        
    end
end
-- 巅峰竞技场重连
function LoginInfoControler:crossPeakReconnection(data,isReLogin )
    if not data then
        -- 判断是否是在战斗中，需要退出战斗
        return
    end
    local currentState = data.status.status
    if currentState == LoginInfoControler.MatchingType.MATCHING  then   ---匹配
        WindowControler:showWindow("CrosspeakMatchView") 
    end
end

--试炼重连
function LoginInfoControler:TrialReconNection(data,isReLogin)
    if not data then
        return
    end

    local expireTime = data.status.expireTime
    if TimeControler:getServerTime() >= expireTime then
        echo("=================重连 时间到期==============")
        return 
    end
	
    local WindownamesPiPei =  WindowControler:getWindow( "TrialNewFriendPiPeiView" )
    local WindownamesMulti =  WindowControler:getWindow( "TeamFormationMultiView" )
    --关闭当前界面重新进入
    if WindownamesPiPei ~= nil  then
    	WindownamesPiPei:startHide()
    end
    if WindownamesMulti ~= nil  then
    	WindownamesMulti:startHide()
    end
    
    UserModel:saveLoginData(nil)  ---保留的数据至nil
    local currentState = data.status.status
    if currentState == LoginInfoControler.MatchingType.FREE then   --空闲

    elseif currentState == LoginInfoControler.MatchingType.MATCHING  then   ---匹配
    	self:MatchingCallFun(data)
    elseif currentState == LoginInfoControler.MatchingType.BATTLE  then   ---战斗
        local period = data.battleInfo.period 
            if period == tonumber(LoginInfoControler.MatchingType.FREE)  then
                self:TeamCallFun(data)
            else
        	   self:BattleCallFun(data)
            end
    elseif currentState == LoginInfoControler.MatchingType.TEAM  then   ---组队中
        self:MatchingCallFun(data)
    -- elseif currentState == LoginInfoControler.MatchingType.GVESCENE then  --GVE战斗
    --     self:gveBattle(data)
    end

end
--空闲回调函数
function LoginInfoControler:FreeCallFun()
	

end
function LoginInfoControler:MatchingCallFun(data)
	echo("============登入后进入匹配界面===============")
    dump(data, "_________ 登入后进入匹配界面 断网重连的数据 _______ ")
	local poolType = tonumber(data.status.poolType)
    local battleUsers = nil
    local playerinfo = nil
	-- local battletypeId,battleselectid = TrailModel:ByIdgettypeAndIndex(poolType)
    local trialdata = FuncTrail.getTrialDataById(poolType)
    local battlretype = {
        _type =  trialdata.trialType,
        diffic = poolType,
    }
    if data.battleInfo ~= nil then
    	battleUsers = data.battleInfo.battleUsers
    	for k,v in pairs(battleUsers) do
    		if k ~= UserModel:rid() then
    			playerinfo = v
    		end
    	end
    	ChatServer:addTeamPlayer(playerinfo)
	   Windowname:Addplaydata(playerinfo)
    end
    local WindownamesPiPei = WindowControler:showWindow("TrialNewFriendPiPeiView",battlretype);
    if playerinfo ~= nil then
        WindownamesPiPei:Addplaydata(playerinfo)
    end

end
---战斗
function LoginInfoControler:BattleCallFun(data)
	echo("============登入后进入战斗界面===============")
    local  _battleId = tostring(data.status.battleId);
    local poolType = tonumber(data.status.poolType)
    local battletypeId,battleselectid = TrailModel:ByIdgettypeAndIndex(poolType)
    local battleInfo = {}
    battleInfo.battleUsers = data.battleInfo.battleUsers
    battleInfo.randomSeed = data.battleInfo.randomSeed or 1;
    if data.battleInfo == nil or table.length(data.battleInfo) == 0 then
        -- echoError("======data.battleInfo is nil ====")
        return 
    end
    if data.battleInfo.randomSeed == nil then
    	echoError("======战斗随机种子欧式 nil ====")
    end
    -- echo("=====self.battletypeId=============",self.battletypeId)

    local id = TrailModel:getIdByTypeAndLvl(battletypeId,battleselectid);

    local hid = FuncTrail.getTrailData(id, "level2")
    local types = battletypeId
    battleInfo.formation = data.battleInfo.formation
    battleInfo.levelId = hid
    if types == TrailModel.TrailType.ATTACK then 
        battleInfo.battleLabel = GameVars.battleLabels.trailGve1;
    elseif types == TrailModel.TrailType.DEFAND then
        battleInfo.battleLabel = GameVars.battleLabels.trailGve2;
    else
        battleInfo.battleLabel = GameVars.battleLabels.trailGve3;
    end
    battleInfo.battleId = _battleId
    TrailModel.battletypeId = battletypeId
    TrailModel.battleselectid = battleselectid

    -- dump(battleInfo,"战斗数据")
    BattleControler:startBattleInfo(battleInfo);
end

--组队中
function LoginInfoControler:TeamCallFun(data)
	echo("============登入后进入布阵界面===============")
	local poolType = tonumber(data.status.poolType)
	local _trialtype,battleselectid = TrailModel:ByIdgettypeAndIndex(poolType)
	local trailPve = nil
    if _trialtype == TrailModel.TrailType.ATTACK then
        trailPve = FuncTeamFormation.formation.trailPve1;
    elseif _trialtype == TrailModel.TrailType.DEFAND then
        trailPve = FuncTeamFormation.formation.trailPve2;
    else
        trailPve = FuncTeamFormation.formation.trailPve3;
    end
    ChatModel:settematype(nil)
    ChatModel:setChatTeamData(nil)
	TrailModel:setTrailPve(trailPve)
    TrailModel.battletypeId = _trialtype
    TrailModel.battleselectid = battleselectid
    TeamFormationMultiModel:updateData(data.battleInfo)
    TrailModel:setparamsdatabattleUsers(data.battleInfo.battleUsers)
	local multiView =  WindowControler:showWindow("WuXingTeamEmbattleView",trailPve,nil,false,true)
    -- LS:pub():set(UserModel:rid()..StorageCode.trialTime,TimeControler:getServerTime()+sec)
    -- local time =tonumber(LS:pub():get(StorageCode.trialTime,nil))
    -- multiView:setBackGroundTime(TimeControler:getServerTime() - time)
    if data.battleInfo.buildTime ~= nil then
        local time = TimeControler:getServerTime() - (data.battleInfo.buildTime) - 5
        multiView:setBackGroundTime(time)
    end
	EventControler:dispatchEvent("TRIAL_PIPEI_END_CALLBACK")
end

--GVE战斗
function LoginInfoControler:gveBattle(_gveData)
end

return LoginInfoControler