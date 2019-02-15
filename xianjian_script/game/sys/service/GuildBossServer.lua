--
--Author:      zhuguangyuan
--DateTime:    2018-01-19 17:20:12
--Description: 仙盟副本网络交互类
--

local GuildBossServer = class("GuildBossServer")

function GuildBossServer:init()
	-- PVE 战斗结束
    EventControler:addEventListener(BattleEvent.BATTLEEVENT_BATTLE_RESULT, self.onPVEBattleComplete,self)
end

-- 获取开启状态的副本的相关数据
function GuildBossServer:getOpenBossData(_callBack)
    local params = {
    }
    Server:sendRequest(params, MethodCode.guildBoss_getGuildBossList_6201, _callBack)
end

-- 开启一个boss副本
function GuildBossServer:openOneEctype(_bossId,_callBack)
	local params = {
        bossId = _bossId,
	}
	Server:sendRequest(params, MethodCode.guildBoss_openGuildBoss_6203, _callBack)
end

-- 挑战boss
function GuildBossServer:attackGuildBoss(_formation,_callBack)
    local params = {
        formation = _formation,
    }
    Server:sendRequest(params, MethodCode.guildBoss_attackGuildBoss_6205, _callBack)
end

-- 挑战结算
function GuildBossServer:reportBattleResult(battleParams,callBack)
    local params = {
        battleResultClient = battleParams
    }
    Server:sendRequest(params,MethodCode.guildBoss_finishGuildBoss_6207 , callBack)
end


-- =============================================================================
-- =============================================================================
-- 监听到本地跑战斗 结束
function GuildBossServer:onPVEBattleComplete(data)
	local battleResult = data.params
    if battleResult.battleLabel == GameVars.battleLabels.guildBossPve then
        self:reportBattleResult(battleResult,c_func(self.onReportBattlResultCallBack,self))
    end
end

-- 上传战报服务器返回
function GuildBossServer:onReportBattlResultCallBack(event)

    if event.result ~= nil then
        local result = event.result.data
        result.result = 1 --共享副本永远是战斗胜利的
        BattleControler:showReward(result)
    elseif event.error then
        if event.error.code == 620501 then
            WindowControler:showTips(GameConfig.getLanguage("#tid_guildBoss_002"))
            -- local result 
            -- BattleControler:showReward(result)
            BattleControler.gameControler:showShareBossEnd(function( )
                   BattleControler:onExitBattle()           
            end)
        end
    end
    -- 更新model数据
    local _forceRefresh = true 
    GuildBossModel:getAllUnlockEctypes(_forceRefresh)
end




--获得共闯秘境排行榜
function GuildBossServer:getGuildBossRank(params,_callback)
    Server:sendRequest(params, MethodCode.guildBoss_rank_6227,_callback);
end

--共闯秘境 邀请加入
function GuildBossServer:inviteGuildBossInvite(params,_callback)
    Server:sendRequest(params, MethodCode.guildBoss_Invite_6215,_callback);
end

--共闯秘境创建队伍
function GuildBossServer:createGuildBossTeam(params,_callback)
    Server:sendRequest(params, MethodCode.guildBoss_create_team_6213,_callback);
end


--共闯秘境  加入队伍
function GuildBossServer:addGuildBoss(params,_callback)
    Server:sendRequest(params, MethodCode.guildBoss_add_team_6217,_callback);
end

--共闯秘境  离开队伍
function GuildBossServer:leaveGuildBoss(params,_callback)
    Server:sendRequest(params, MethodCode.guildBoss_leave_team_6219,_callback);
end

--共闯秘境  踢出队伍
function GuildBossServer:kickOutGuildBoss(params,_callback)
    Server:sendRequest(params, MethodCode.guildBoss_out_team_6221,_callback);
end


--共闯秘境  进入单人占战斗
function GuildBossServer:doingSingleBattleGuildBoss(params,_callback)
    Server:sendRequest(params, MethodCode.guildBoss_single_battle_6225,_callback);
end


--共闯秘境 获取邀请列表
function GuildBossServer:getInvitedList(params,_callback)
    Server:sendRequest(params, MethodCode.guildBoss_get_invited_6237,_callback);
end



--开始战斗
function GuildBossServer:startBattle(params,_callback)
    Server:sendRequest(params, MethodCode.guildBoss_more_battle_6223,_callback);
    
end


GuildBossServer:init()
return GuildBossServer