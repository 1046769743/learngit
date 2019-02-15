--
--Author:      zhuguangyuan
--DateTime:    2017-10-21 15:41:43
--Description: 仙盟GVE活动 网络交互类
--

local GuildActivityServer = class("GuildActivityServer")

-- 服务器推送信息接收及处理
function GuildActivityServer:init()
    -- 战斗离开
    EventControler:addEventListener(BattleEvent.BATTLEEVENT_USER_LEAVE,self.onBattleLeave,self)
    -- 战斗结束
    EventControler:addEventListener(BattleEvent.BATTLEEVENT_BATTLE_RESULT,self.onBattleComplete,self)

    -- 战斗系统关闭
    EventControler:addEventListener(BattleEvent.BATTLEEVENT_BATTLE_CLOSE,self.onBattleClose,self)

end

--------------------------------------------------------------------------
-------------------------- 侦听处理   ------------------------------------
--------------------------------------------------------------------------
-- 战斗离开
function GuildActivityServer:onBattleLeave(data)
    local battleResultData = data.params
    if (battleResultData.battleLabel ~= GameVars.battleLabels.guildGve) then
        return
    end
    self.battleResult = battleResultData.rt
    self:reportBattleResult(battleResultData,c_func(self.onReportBattlResultCallBack,self))

    -- dump(data.params,"战斗离开gamecontrol返回的数据")
    -- local cacheData = UserModel:getCacheUserData()
    -- echo("________战斗结果_ battleResultData.rt _________",battleResultData.rt)


    -- local rewardData = {}
    -- rewardData.preLv = cacheData.preLv
    -- rewardData.preExp = cacheData.preExp
    -- rewardData.reward = {}
    -- rewardData.result = battleResultData.rt


    -- BattleControler:showReward(rewardData)
end

-- 战斗结束回调
function GuildActivityServer:onBattleComplete(data)
    local battleResultData = data.params
    if (battleResultData.battleLabel ~= GameVars.battleLabels.guildGve) then
        return
    end
    self.battleResult = battleResultData.rt
    if not GuildActMainModel:isInNewGuide() then
        self:reportBattleResult(battleResultData,c_func(self.onReportBattlResultCallBack,self))
    else
        -- 新手引导所需特殊处理
        local cacheData = UserModel:getCacheUserData()
        local rewardData = {}
        rewardData.preLv = cacheData.preLv
        rewardData.preExp = cacheData.preExp
        rewardData.result = self.battleResult
        rewardData.reward = {}
        -- 展示结算界面
        BattleControler:showReward(rewardData)
        if self.battleResult == Fight.result_win then
            local serverData = {
                params = {
                    params = {
                        data = {
                            index = GuildActMainModel:getCurChooseMonsterGridIndex()
                        },
                    },
                },
            }
            GuildActMainModel:onSomeoneDefeatOneMaster( serverData )
        end
        if not GuildActMainModel.newGuideBattleCount then
            GuildActMainModel.newGuideBattleCount = 1
        else
            GuildActMainModel.newGuideBattleCount = GuildActMainModel.newGuideBattleCount + 1
        end
    end
end

-- GVE&PVE战斗界面关闭
function GuildActivityServer:onBattleClose(event)
end


-- 报告战斗结果回调
function GuildActivityServer:onReportBattlResultCallBack(event)
    if event.error then
        if event.error.code == 567302 then
            WindowControler:showTips( GameConfig.getLanguage("#tid_guildAct_009"),3);
        end
    end
    dump(event.result,"gve战报上传,服务器返回的数据")
    -- self.currentRaidId
    -- --如果是玩家点击离开
    -- if BattleControler.userLevel then
    --     return
    -- end
    local cacheData = UserModel:getCacheUserData()
    local rewardData = {}
    rewardData.preLv = cacheData.preLv
    rewardData.preExp = cacheData.preExp

    if event.result ~= nil then
        local serverData = event.result
        local battleWinOrNotResult = self.battleResult
        rewardData.reward = {}
        rewardData.result = battleWinOrNotResult
    else
        rewardData.result = Fight.result_lose
    end

    -- 展示结算界面
    BattleControler:showReward(rewardData)
end



--=================================================================================
-- 客户端和服务端交互接口
--=================================================================================
-- 开启GVE定时活动 
function GuildActivityServer:openActivity(_guildId,_callBack)
    echo(" _________ 发送 开启活动 请求 _______________ ")
    local params = {
        guildId = _guildId
    }
    Server:sendRequest(params, MethodCode.guildAct_openActivity_5601, _callBack )
end

-- 获取房间列表
function GuildActivityServer:getTeamList(_guildId,_callBack)
    echo(" _________ 发送 获取队伍列表 请求 _______________ ")
    local params = {
        guildId = _guildId
    }
    Server:sendRequest(params, MethodCode.guildAct_getTeamList_5605, _callBack )
end

-- 创建队伍
function GuildActivityServer:createTeam(_guildId,_callBack)
    echo(" _________ 发送 创建队伍 请求 _______________ ")
    local params = {
        guildId = _guildId
    }
    Server:sendRequest(params, MethodCode.guildAct_createTeam_5607, _callBack )
end

-- 加入队伍
function GuildActivityServer:joinTeam(_guildId,_teamId,_callBack)
    echo(" _________ 发送 加入队伍 请求  _______________ ")
    local params = {
        guildId = _guildId,
        teamId = _teamId
    }
    Server:sendRequest(params, MethodCode.guildAct_joinTeam_5609, _callBack )
end

-- 离开队伍
function GuildActivityServer:leaveTeam(_guildId,_teamId,_callBack)
    echo(" _________ 发送 离开队伍 请求 _______________ ")
    local params = {
        guildId = _guildId,
        teamId = _teamId
    }
    Server:sendRequest(params, MethodCode.guildAct_leaveTeam_5613, _callBack )
end

-- 踢人
function GuildActivityServer:kickOutOnePerson(_guildId,_teamId,_trid,_callBack)
    echo(" _________ 发送 踢人 请求 _______________ ")
    local params = {
        guildId = _guildId,
        teamId = _teamId,
        trid = _trid
    }
    Server:sendRequest(params, MethodCode.guildAct_kickOutOnePerson_5615, _callBack )
end

-- 邀请盟友
function GuildActivityServer:inviteAllies(_guildId,_teamId,_trids,_callBack)
    echo(" _________ 发送 邀请盟友 请求 _______________ ")
    local params = {
        guildId = _guildId,
        teamId = _teamId,
        trids = _trids
    }
    Server:sendRequest(params, MethodCode.guildAct_inviteAllies_5617, _callBack )
end

-- 队伍挑战开始
function GuildActivityServer:startChallenge(_guildId,_teamId,_callBack)
    echo(" _________ 发送 队伍挑战开始 请求 _______________ ")
    local params = {
        guildId = _guildId,
        teamId = _teamId
    }
    Server:sendRequest(params, MethodCode.guildAct_startChallenge_5621, _callBack )
end

-- 队伍挑战结束
function GuildActivityServer:quitChallenge(_guildId,_teamId,_callBack)
    echo(" _________ 发送 队伍挑战结束 请求 _______________ ")
    local params = {
        guildId = _guildId,
        teamId = _teamId
    }
    Server:sendRequest(params, MethodCode.guildAct_quitChallenge_5625, _callBack )
end

-- 标记怪
function GuildActivityServer:markMonster(_guildId,_teamId,_index,_round,_callBack)
    echo(" _________ 发送 标记怪 请求 _______________ ")
    local params = {
        guildId = _guildId,
        teamId = _teamId,
        index = _index,
        round = _round
    }
    Server:sendRequest(params, MethodCode.guildAct_markMonster_5629, _callBack )
    -- GuildActMainModel:setMonsterStatus( _index, GuildActMainModel.monsterStatus.MARKED )
    -- GuildActMainModel:setMonsterStatus( _index, 1 )
    -- echo("标记后状态为===",GuildActMainModel:getMonsterStatus( _index ))
end

-- 取消标记怪
function GuildActivityServer:markMonsterCancel(_guildId,_teamId,_index,_round,_callBack)
    echo(" _________ 发送 取消标记怪 请求 _______________ ")
    local params = {
        guildId = _guildId,
        teamId = _teamId,
        index = _index,
        round = _round
    }
    Server:sendRequest(params, MethodCode.guildAct_markMonsterCancel_5633, _callBack )
    -- GuildActMainModel:setMonsterStatus( _index, GuildActMainModel.monsterStatus.NOT_MARKED )
    -- GuildActMainModel:setMonsterStatus( _index, 0 )
    -- echo("取消标记后状态为===",GuildActMainModel:getMonsterStatus( _index ))
end

-- 打包子，战斗请求
function GuildActivityServer:beatMonster(_guildId,_teamId,_index,_round,_formation,_callBack)
    echo(" _________ 发送 打包子请求 请求 _______________ ")
    local params = {
        guildId = _guildId,
        teamId = _teamId,
        index = _index,
        round = _round,
        formation = _formation
    }
    -- Server:sendRequest(params, MethodCode.guildAct_beatMonster_5637, _callBack )
    Server:sendRequest(params, MethodCode.guildAct_beatMonster_5671, _callBack )

end

-- 一轮战斗结算
function GuildActivityServer:settleOneRoundAccounts(_guildId,_teamId,_round,_callBack)
    echo(" _________ 发送 一轮战斗结算 请求 _______________ ")
    local params = {
        guildId = _guildId,
        teamId = _teamId,
        round = _round
    }
    Server:sendRequest(params, MethodCode.guildAct_settleOneRoundAccounts_5641, _callBack )
end

-- 投入食材
function GuildActivityServer:putInMaterials(_guildId,_foodItems,_callBack)
    echo(" _________ 发送 投入食材 请求 _______________ ")
    local params = {
        guildId = _guildId,
        foodItems = _foodItems    
    }
    Server:sendRequest(params, MethodCode.guildAct_putInMaterials_5647, _callBack )
end

-- 领取积分奖励
function GuildActivityServer:getAccumulateReward(_guildId,_rewardIds,_callBack)
    echo(" _________ 发送 领取积分奖励 请求 _______________ ")
    dump(_rewardIds, "_rewardIds")
    local params = {
        guildId = _guildId,
        rewardIds = _rewardIds
    }
    Server:sendRequest(params, MethodCode.guildAct_getAccumulateReward_5649, _callBack )
end

-- 获得没有加入队伍的其他仙盟内成员
function GuildActivityServer:getCanInviteMembers(_guildId,_callBack)
    echo(" _________ 发送 获得没有加入队伍的其他仙盟内成员 请求 _______________ ")
    local params = {
        guildId = _guildId
    }
    Server:sendRequest(params, MethodCode.guildAct_putInMaterials_5651, _callBack )
end

-- 服务器存储的一些活动相关信息
function GuildActivityServer:getGVEData(_guildId,_callBack)
    echo(" _________ 发送 获取仙盟gve相关信息 请求 _______________ ")
    local params = {
        guildId = _guildId
    }
    Server:sendRequest(params, MethodCode.guildAct_getGVEData_5653, _callBack )
end

-- 服务器存储的一些活动相关信息
function GuildActivityServer:sentCurPosition(_guildId,_teamId,_posX,_posY,_callBack)
    echo(" _________ 发送 当前玩家走动到的坐标  _______________ ")
    local params = {
        guildId = _guildId,
        teamId = _teamId,
        posX = _posX,
        posY = _posY,
    }
    Server:sendRequest(params, MethodCode.guildAct_sync_player_pos_5663, _callBack )
end

-- 发送倒计时开始请求
function GuildActivityServer:sentStartCountDown(_guildId,_teamId,_round,_callBack)
    echo(" _________ 发送 倒计时开始  _______________ ")
    local params = {
        guildId = _guildId,
        teamId = _teamId,
        round = _round,
    }
    Server:sendRequest(params, MethodCode.guildAct_start_countDown_5667, _callBack )
end

-- 上传战报
function GuildActivityServer:reportBattleResult(battleParams,callBack)
    local params = {
        battleResultClient = battleParams
    }
    Server:sendRequest(params,MethodCode.guildAct_report_battleResult_5673 , callBack)
end

-- 领取100仙玉新手引导奖励
function GuildActivityServer:hasFinishedGuide(params,callBack)
    -- if callBack then
    --     callBack()
    --     return 
    -- end
    Server:sendRequest(params,MethodCode.guildAct_has_finished_guide_5675 , callBack)
end

GuildActivityServer:init()
return GuildActivityServer