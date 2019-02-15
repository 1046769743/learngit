--
-- Author: xd
-- Date: 2016-01-09 11:28:10

BattleControler = BattleControler or {}
BattleControler.__poolType = nil
BattleControler.__levelHid = nil
BattleControler.__gameMode = nil
BattleControler.gameControler = nil
BattleControler.levelInfo = nil
BattleControler.__gameResult = nil
BattleControler.__battleLoseJumpType = nil --当战斗失败的时候，跳转对应的type
BattleControler.battleLabel = nil --战斗标签
BattleControler._myTeamCamp = 1 --巅峰竞技场中我方属于哪个team
BattleControler._toTeamCamp = 2
BattleControler.__battleNotFinish = nil
BattleControler._maxOperation = 0 --最大的操作数[仙界对决查看战报跳过用]
BattleControler._waitLoadingAni = false -- 等待loading动画
--[[
    battleInfo  
    {
        userRid = UserModel:rid()          --必须要带userRid  否则没法知道我改操作谁 ,战斗中应该禁止使用UserModel:rid()
                                            --因为纯跑逻辑时可能需要用到rid  但是实际上是没有UserModel:rid()是空的
        
        battleId = 0        --必须要配置这个参数
        levelId 战斗关卡id  战斗回放需要配这个参数
        battleUsers = { {玩家A信息.,team =1,formation = ...},{玩家B信息..,team =2},..  }, -- team 是必须有的字段,可以为1或者2,可以都为 1
        formation = {}.         阵容,针对 gve
        randomSeed = 100,   --随机种子
        battleLabel = GameVars.battleLabels.worldPve 战斗标签.用来接受消息时候的 参数 必须有,没有就报错

        --额外添加 的buff,比如爬塔,需要把这这些buff 在站前添加进去,目前只有爬塔系统有这个属性
        buffInfo = {buffid1,buffid2,...}
        
        --加法宝额外威能信息,是一个table,num表示按数值增加多少,per表示按百分比增加多少 ,目前是爬塔有这个需求
        powerInfo = {num =120,per = 50}
        
        --如果是战斗回放或者复盘的 需要的信息
        operation, 
        {
            
        }
        replayGame  2表示是回放,空或者0表示非回放
        
    }
]]


--[[
剧情回顾

]]
function BattleControler:startReplay(storyId)

    --raidId  燕广给接口获取raidId 
    --local raidId
    --self.curRaidId = raidId
    local raidId = FuncChapter.getRaidIdByStoryId(storyId,1)
    self:startReplayRaidId(raidId)
end



--[[
获取下一个有剧情的raidId
如果没有则返回为 对应的剧情播放动画
]]
function BattleControler:getNextRaidIdWithStory( raid )
    local levelCfg = require("level.Level")
    local raidData = FuncChapter.getRaidDataByRaidId(raid)
    local level = raidData.level
    local levelData = levelCfg[level]
    local storys = levelData["1"].storyPlot
    while empty(storys) do
        raid = WorldModel:getNextRaidInStory(raid)
        if  raid then
            raidData = FuncChapter.getRaidDataByRaidId(raid)
            level = raidData.level
            local levelData = levelCfg[level]
            storys = levelData["1"].storyPlot
        else
            break
        end
    end
    if not empty(storys) then
        return raid
    else
        return nil
    end
end



--获取BattleControler stroy
function BattleControler:getRaidStory( raid,level )
    local levelCfg = require("level.Level")
    local levelData = levelCfg[level]

    local storys = levelData["1"].storyPlot

    --这里要遍历取最后一关的剧情对话
    local afterLevelData = levelData["3"]
    if not afterLevelData then
        afterLevelData = levelData["2"]
    end

    if not afterLevelData then
        afterLevelData = levelData["1"]
    end

    local afterStorys  = afterLevelData.storyPlot

    local curRaidStory = {}
    --这里只判定战前剧情对话，战后剧情对话
    if storys then
        for k,v in pairs(storys) do
             if v.time == 1 then
                curRaidStory.beforeAnim = v
                curRaidStory.raid = raid
             end
        end
    end

    if afterStorys then
        for k,v in pairs(afterStorys) do
            if v.time == 3 then
                curRaidStory.afterAnim = v
                curRaidStory.raid = raid
            end
        end
    end
    
    if (not storys) and (not afterStorys ) then
        curRaidStory = nil
    end

    return curRaidStory
end


--[[
加载需要需要播放的动画
]]
function BattleControler:startReplayRaidId( raid )

    local raid = self:getNextRaidIdWithStory( raid )
    if not raid then
        WindowControler:showTips( GameConfig.getLanguage("#tid_battle_3") )
        return 
    end
    self.curRaidId = raid
    self.raidData = FuncChapter.getRaidDataByRaidId(self.curRaidId)
    --dump(self.raidData)
    self.level = self.raidData.level
    -- --self.fromWorld = true
    -- local levelCfg = require("level.Level")
    -- local levelData = levelCfg[self.level]
    -- --dump(levelData)
    -- local storys = levelData["1"].storyPlot
    -- local curRaidStory = {}
    -- --这里只判定战前剧情对话，战后剧情对话
    -- for k,v in pairs(storys) do
    --     if v.time == 1 then
    --         curRaidStory.beforeAnim = v
    --         curRaidStory.raid = raid
    --     end
    --     if v.time == 3 then
    --         curRaidStory.afterAnim = v
    --         curRaidStory.raid = raid
    --     end
    -- end
    -- self.curRaidStory = curRaidStory
    self.curRaidStory = self:getRaidStory(raid,self.level)
    self:startStory()
end





--[[
开始剧情
]]
function BattleControler:startStory(  )
    if self.curRaidStory.beforeAnim then
        AnimDialogControl:showPlotDialog(self.curRaidStory.beforeAnim.plotid, c_func(self.storyCallBack,self),self.curRaidStory.raid,nil,true)
        self.curRaidStory.beforeAnim = nil
    else
        AnimDialogControl:showPlotDialog(self.curRaidStory.afterAnim.plotid, c_func(self.storyCallBack,self),self.curRaidStory.raid,nil,true)
        self.curRaidStory.afterAnim = nil
    end
end

--[[
剧情播放完成回调
]]
function BattleControler:storyCallBack(  )
    --echo("剧情播放完成回调--=------------------")
    if self.curRaidStory.afterAnim then
        --直接播放下一个
        --echoError("播放战后剧情--------")
        self:startStory()
    else
        --检查下一个剧情的情况 开始播放
        local nextRaid = WorldModel:getNextRaidInStory(self.curRaidId)
        echo(nextRaid,"nextRaidnextRaidnextRaidnextRaid")
        if  nextRaid then
            --echoError("播放下个关卡的剧情--------")
            self:startReplayRaidId( nextRaid )
        end
    end
end





--获取



--[[
从六界中进入战斗
storyId 为空  则表示是回顾 isReplaytrue 配合使用

]]
function BattleControler:startBattleFormWorld(raidId,isPreloading)
    -- 是否是预加载战斗(加载完成后暂停战斗)
    self.isPreloading =  isPreloading
    echoWarn("开始StartBattleFormWorld-----------------------",raidId,WindowControler:isNeedJumpToHome())

    --[[
    2017.8.5
    某一章没结束时不跳出进行引导，跳出的相关判断在外面做了，这里暂时注掉
    if WindowControler:isNeedJumpToHome() then
        WindowControler:closeWindow("WorldMainView")
        WindowControler:showWindow("HomeMainView")
        --echoError("关闭进入主城============")
        return
    --else
        --echoError("----------------------------")
    end
    ]]

    --关卡是否通关
    --echo("-----------",raidId,"===============")
    local isRaidPass = WorldModel:isPassRaid(raidId)  
    local isHasBox = WorldModel:hasExtraBox(raidId)
    local hasUsedBox = WorldModel:hasUsedExtraBox(raidId)
    self.curRaidId = raidId
    self.raidData = FuncChapter.getRaidDataByRaidId(self.curRaidId)
    self.level = self.raidData.level
    self.storyId =  FuncChapter.getStoryIdByRaidId(raidId)

    --这里还要判断是直接 战前剧情  战斗，还是战后剧情

    --self.fromWorld = true

    local levelCfg = require("level.Level")
    self.levelData = levelCfg[self.level]
    --self:doBattleAction()


    if isRaidPass and isHasBox and hasUsedBox == false and (not PrologueUtils:showPrologue()) then
        curRaidStory = self:getRaidStory(raidId,self.level)
        if not empty(curRaidStory) then
            local nextRaid = WorldModel:getNextRaidInStory(raidId)

            local callBack
            callBack = function (  )

                if WindowControler:isNeedJumpToHome() then
                    WindowControler:closeWindow("WorldMainView")
                    WindowControler:showWindow("HomeMainView")
                    --echoError("关闭进入主城============")
                    return
                --else
                    --echoError("----------------------------")
                end
            end

            local func = callBack --GameVars.emptyFunc
            if  nextRaid then
                --echo("当前的nextRaid====",nextRaid,"=======","回调方法是自身===")
                func = c_func(self.startBattleFormWorld,self,nextRaid)
            end

            if not curRaidStory.afterAnim then
                echoError("找策划,配置问题,没有配置对应波数的战后对话,raidId:%s,levelid:%s",raidId,self.level)
                func()
            else
                AnimDialogControl:showPlotDialog(curRaidStory.afterAnim.plotid, func,raidId)
            end

            
            --self.curRaidStory.afterAnim = nil
        else
            local nextRaid = WorldModel:getNextRaidInStory(raidId)
            if  nextRaid then
                self:startBattleFormWorld(nextRaid)
            else
                echoError("_没有找到下一个raidid,当前id",raidId)
            end
        end
    else


        --[[
        是不是序章
        是不是序章的第一关
        第二关
        第三关
        ]]
        if PrologueUtils:showPrologue() then
            --这里判定是序章 
            local battleInfo = self:getXuZhangBattleInfo(self.curRaidId)
            self:startBattleInfo(battleInfo)
        else 
            self:doBattleAction()
        end
        --if self.curRaidId == "" 
        
    end

end
--[[
获取序章的战斗数据
]]
function BattleControler:getXuZhangBattleInfo(raidId)
    local raidData = FuncChapter.getRaidDataByRaidId(raidId)
    local level = raidData.level

    local battleInfo = { }
    battleInfo.battleUsers = { }
    local defaultHero = ObjectCommon:getServerData()
    for i = 1, #defaultHero do
        table.insert(battleInfo.battleUsers, defaultHero[i])
    end
    battleInfo.levelId = level
    battleInfo.raidId = raidId
    battleInfo.randomSeed = 100
    battleInfo.battleId = "101"
    battleInfo.withStory = true
    --这是pve
    battleInfo.battleLabel =  GameVars.battleLabels.worldPve
   -- BattleControler:startBattleInfo(battleInfo)

   return battleInfo
end








--[[
剧情播放完成  检查是否进入下一个 
]]
-- function BattleControler:checkNextBattleFormWorld(raidId)

-- end




--[[
获取当前的战斗前剧情是否播放过了
]]
function BattleControler:saveCurRaidJuQingFinished()
    local raidId = self.curRaidId
    if (not self.isDebugBattle) and (not Fight.isDummy)  then
        LS:prv():set("user__Finished__"..tostring(raidId),"1")
    end
end

function BattleControler:chkCurRaidJuQingFinshed()
    if self.isDebugBattle then
        return false
    end
    local isFinished = LS:prv():get("user__Finished__"..tostring(self.curRaidId),"0")
    if isFinished == "1" then
        --echoError("序章关卡战前剧情已经跑过------")
        return true
    end
    return false
end





--[[
执行战斗的网络请求
]]
function BattleControler:doBattleAction()
    WorldServer:enterPVEStage(self.curRaidId,c_func(self.doBattleActionCallBack,self),TeamFormationModel:getFormation(FuncTeamFormation.formation.pve,self.curRaidId))
end


--[[
战斗请求的网络回调

]]
function BattleControler:doBattleActionCallBack(event)
    if event.result ~= nil then
        self.battleId = event.result.data.battleInfo.battleId

        self.betweenAction = true

        local battleInfo = {}
        battleInfo = BattleControler:turnServerDataToBattleInfo(event.result.data.battleInfo)
        battleInfo.withStory = true
        self.userLevel = false
        battleInfo.raidId = self.curRaidId
        
        -- dump(battleInfo.battleUsers)

        -- 缓存用户数据
        UserModel:cacheUserData()

        -- 保存当前战斗信息，战斗结算会用到
        local cacheBattleInfo = {}
        cacheBattleInfo.raidId = self.curRaidId
        cacheBattleInfo.battleId = self.battleId
        cacheBattleInfo.level = self.level
        -- 主角加经验(等于体力消耗)
        cacheBattleInfo.spCost = self.raidData.spCost
        -- 伙伴加经验
        cacheBattleInfo.heroAddExp = self.raidData.expPartner or 0

        WorldModel:resetDataBeforeBattle()
        WorldModel:setCurPVEBattleInfo(cacheBattleInfo)
        

         -- 初始化PVE战斗结果
        local cacheData = {
            battleRt = Fight.result_lose,
            raidId = self.curRaidId,
            -- 缓存关卡成绩
            raidScore = WorldModel:getBattleStarByRaidId(self.curRaidId)
        }

        WorldModel:setPVEBattleCache(cacheData)

        self:startPVE(battleInfo)
        --LogsControler:writeDumpToFile(battleInfo,8,8)
        --self:startHide()
    end


end

 









--直接根据数据开启游戏
function BattleControler:startBattleInfo( battleInfo)
    local t1,t2 = nil,nil
    if Fight.isDummy and not DEBUG_SERVICES then
        t1 = TimeControler:getTempTime()
    end
    if (not Fight.isDummy)  and PrologueUtils:showPrologue() then
        echo("存储  序章 的进度  raidId",self.curRaidId)
        PrologueUtils:setPrologueBattleRaidId(self.curRaidId)
    end
    
    -- echo("=============================")
    -- dump(battleInfo)
    -- echo("=============================")
    --这里增加一种战斗方式
    self.fromWorld = false

    self:setBattleLabel(battleInfo)
    local label = self:getBattleLabel()
    if label == GameVars.battleLabels.worldPve or
    self:checkIsTrialPve() or self:checkIsTower() or
    self:checkIsLovePVE() or self:checkIsShareBossPVE() or
    self:checkIsExploreBattle() or
    label == GameVars.battleLabels.guildGve or
    label == GameVars.battleLabels.missionMonkeyPve or 
    label == GameVars.battleLabels.missionBattlePve or
    label == GameVars.battleLabels.wonderLandPve or
    label == GameVars.battleLabels.endlessPve or
    label == GameVars.battleLabels.missionIcePve or
    label == GameVars.battleLabels.missionBombPve or
    label == GameVars.battleLabels.guildBossPve or
    label == GameVars.battleLabels.crossPeakPve or
    label == GameVars.battleLabels.biographyPve
    then
        self:startPVE(battleInfo)
    elseif label == GameVars.battleLabels.kindGve or
     label == GameVars.battleLabels.guildBossGve then
        self:startGVE(battleInfo)
    elseif self:checkIsPVP() or label == GameVars.battleLabels.crossPeakPvp or
        label == GameVars.battleLabels.crossPeakPvp2 then
        self:startPVP(battleInfo)
    else
        echoWarn("wrong battleLabel:",label)
    end
    if Fight.isDummy and not DEBUG_SERVICES then
        t2 = TimeControler:getTempTime()
        echo("dummy run cost time:",t2 - t1)
    end
end
function BattleControler:setBattleLabel(battleInfo)
    if not battleInfo.battleLabel then
        echoError("这个战斗没有传入battleLabel:",mode)
        battleInfo.battleLabel = GameVars.battleLabels.worldPve
        -- return
    end
    self.battleLabel = battleInfo.battleLabel
end


function BattleControler:startPVP(battleInfo)
    --dump(battleInfo)
    -- self.__gameMode = Fight.gameMode_pvp
    -- battleInfo.gameMode = Fight.gameMode_pvp
    -- echo("竞技场的数据=-=-======================")
    -- dump(battleInfo)
    -- echo("竞技场的数据=-=-======================")
    self:setCampData(Fight.gameMode_pvp,battleInfo )
end


--副本关卡
function BattleControler:startPVE(battleInfo)

    -- dump(battleInfo,"----副本关卡")
    --讲pve战斗的battleInfo写入日志文件
    --LogsControler:writeDumpToFile(battleInfo,8,8)

    --发送完了网络请求


    -- self.__gameMode = Fight.gameMode_pve
    -- battleInfo.gameMode = Fight.gameMode_pve
    self:setCampData(Fight.gameMode_pve,battleInfo )
end



-- GVE(匹配进入的接口)
function BattleControler:startGVE(battleInfo)
    -- self.__gameMode = Fight.gameMode_gve
    -- battleInfo.gameMode = Fight.gameMode_gve
    self:setCampData(Fight.gameMode_gve,battleInfo )
end


-- 回放
function BattleControler:replayLastGame(battleInfo,skilClearView)
    --dump(battleInfo)
    -- 目前先用PVP做例子
    --如果有controler
    self:resetTeamCamp()

    if self.gameControler then
        self.__resControler = self.gameControler.resControler
    end
    battleInfo.replayGame = 2
    self:resetBattleData()
    -- 获取一下战报
    if BattleControler:checkIsCrossPeak() then
        self:setMaxOperation()
    end

    ViewSpine:clearSpineCache()
    self.__gameMode = battleInfo.gameMode
    self:setBattleLabel(battleInfo)
    self:setCampData(battleInfo.gameMode,battleInfo,skilClearView)
end

--校验战斗服版本是否正确
function BattleControler:checkBattleVersionIsOld( battleInfo )
    local  version = AppInformation:getVersion()
    if not battleInfo.scriptVersion  then
        return false
    end
    local scriptTag = VersionControler:getScriptTag(  )
    if battleInfo.scriptVersion ~= scriptTag  then
        echoWarn("战斗版本过期,当前脚本版本:%s,传入的脚本tag:%s",scriptTag,tostring(battleInfo.scriptVersion) )
        WindowControler:showTips(GameConfig.getLanguage("#tid_battle_4"))
        return true
    end
    local configVersion = VersionControler:getConfigVersion(  )
    if battleInfo.configVersion  ~= configVersion then
        echoWarn("战斗版本过期,当前配表版本:%s,传入的配表:%s",configVersion,tostring(battleInfo.configVersion) )
        WindowControler:showTips(GameConfig.getLanguage("#tid_battle_4"))
        return true
    end
    return false
end



--[[
hid level表中的关卡表示
sigleFlag 1 单人，sigleFlag 2 多人
]]
function BattleControler:setLevelId(hid,sigleFlag)
    self.__levelHid = hid
    --local loadId = FuncLoading.getLoadingId(hid)
    --如果是loading界面 那么不加载loading
    if Fight and Fight.isDummy then
        return
    end

    --如果是第一场序章战斗 那么需要显示 root
    if hid == Fight.xvzhangParams.xuzhang then
        echo("__这是序章1战斗")
        WindowControler:getScene():showAllRoot()
        return
    end

    self:setLoadingId(hid,1)
end


--[[
loadId  levelId
sigleFlag == 1表示单人
sigleFlag == 2表示多人
]]
function BattleControler:setLoadingId(loadId,sigleFlag)
    if self:checkIsPVP() and LoginControler:isLogin() then
        local enemyCamp = self._battleInfo.battleUsers[2]
        local playerCamp = self._battleInfo.battleUsers[1]
        -- echoError("__显示竞技场loading---------------")
        WindowControler:showBattleWindow("ArenaBattleLoading", enemyCamp, playerCamp)
    elseif BattleControler:checkIsCrossPeak() and LoginControler:isLogin()  then
        -- local enemyCamp = self._battleInfo.battleUsers[2]
        -- local playerCamp = self._battleInfo.battleUsers[1]
        -- -- echoError("__显示竞技场loading---------------")
        -- WindowControler:showBattleWindow("ArenaBattleLoading", enemyCamp, playerCamp)
        local otherCamp
        for k,v in pairs(self._battleInfo.battleUsers) do
            if v.rid ~= self._battleInfo.userRid then
                otherCamp = v
                break
            end
        end
        if not otherCamp then
            echoError("没有获取到敌方的数据")
            otherCamp = self._battleInfo.battleUsers[1]
        end
        -- local otherCamp = self._battleInfo.battleUsers[self:getOtherCamp()]
        WindowControler:showBattleWindow("CrosspeakMatchView", FuncCrosspeak.MATCHTYPE.LOADING, otherCamp)
    else
        local gameType = FuncLoadingNew.getGameTypeByBattleLabel(self.battleLabel, self._battleInfo.levelId)
        BattleLoadingControler:showBattleLoadingView(loadId, sigleFlag, gameType)
    end
    
end


--设置是否是调试战斗
function BattleControler:setIsDebugBattle( value )
    self.isDebugBattle = value
end

function BattleControler:getLevelId()
    return self.__levelHid
end


function BattleControler:reConnectBattle(battleId,poolType)
    echo("___________________重连进入战斗_",battleId,poolType)

    self.__poolType = poolType

    GameLuaLoader:loadGameBattleInit()
    BattleServer:quitBattle(battleId)
end


-- 获得poolType
function BattleControler:getPoolType()
    return self.__poolType
end

function BattleControler:getPoolSystem()
    if self.__poolType then 
        return FuncMatch.getPoolSystem(self.__poolType)
    end
    return nil
end



-- 掉落排序
local function funDropOrder( item1,item2 )
    if item1[5] < item1[5] then
        return true
    end
    return false
end

-- 整理掉落信息
function BattleControler:checkBattleDrop(drop)
    local dropArr = {}
    for i=1,#drop do
        local tmpTb = {}
        tmpTb = string.split(drop[i],",")
        tmpTb[3] = tonumber(tmpTb[3])
        tmpTb[4] = 0
        tmpTb[5] = FuncItem.getItemPropByKey(tmpTb[2],"drop")
        if tmpTb[1] == "1" then
            table.insert(dropArr,tmpTb)
        else
            echo("______传来的掉落物品是非物品")
            dump(tmpTb)
        end
    end
    -- 排序
    table.sort(dropArr,funDropOrder)
    return dropArr
end



--[[
   battleInfo = {
        campArr_1 = { {{
                    rid="a", hid = "10001",armature = "taiyihongluan",lv = 1, energy=0,maxenergy=5,hp =100,maxhp =100,atk =20,def = 1,crit = 1,resist = 1,hit=10,dodge=0,critR=0,
                    treasure =  {
                                    {hid="101",state = 1,star = 1,strengthen = 2},
                                }, 
                },}          }
        campArr_2,
        randomseed,
    }
]]

-- 计算英雄的属性,并复制默认属性
function BattleControler:setDefaultAttr(mode,hero,battleLabel)
    --dump(hero)
    local avatar = tonumber(hero.avatar) or 101
    hero.hid   = tostring(avatar)
    hero.treasures[tostring(avatar-100)] = {
                    level       = 1,
                    star        = 1,
                    state       = 1,
                    status      = 1,
                    treaType = "base", -- 出场时带的法宝
                }
    
    battleLabel = battleLabel or self.battleLabel

    local tmp = FuncBattleBase.createBattleData( hero, hero.treasures, battleLabel)


    if Fight.all_high_hp then

        tmp.hp = 1000000
        tmp.maxhp = 1000000
    end

    return tmp
end


--- 解析掉落信息 1为类型,2掉落物品id 3 数目 4位0  5读取drop属性进行排序
--local encDefault = numEncrypt:encodeObject( defaultData )
function BattleControler:checkTeam(mode,battleInfo)
    -- 关卡
    local levelObj = ObjectLevel.new( self.__levelHid,mode,battleInfo )
    levelObj.randomSeed = battleInfo.randomSeed

    --计算掉落
    if battleInfo.inBattleDrop then 
        levelObj.dropArr = self:checkBattleDrop(battleInfo.inBattleDrop)
    end

    -- 因为levelObj 加密不了,所有直接赋值过去
    self.gameControler:initGameData(levelObj)
end



--[[
]]
function BattleControler:setCampData(mode, battleInfo, skipClearView )
    self._isNoNeedCheck = false
    -- local t1 = TimeControler:getTempTime()
    if not battleInfo.restartIdx then
        battleInfo.restartIdx = 0
    end
    -- 纯跑逻辑时没有缓存
    if not Fight.isDummy then
        if battleInfo.restartIdx == 0 then
            --缓存进战斗时的纹理状态
            TextureControler:noteOneTextureState("Battle")
        end
    end
    if not Fight.isDummy then
        collectgarbage("collect")
    end
    
    self.userLevel = false

    local info,op = nil,nil
    if Fight.use_operate_info then
        battleInfo= GameStatistics:getLogsBattleInfo( Fight.statistic_file )
        -- 复盘 withStory 置为false
        battleInfo.withStory = false
        if Fight.use_operate_info then
            -- 仙界对决复盘问题时候需要转换一次
            if battleInfo.battleLabel == GameVars.battleLabels.crossPeakPvp2 then
                battleInfo = BattleControler:turnServerDataToBattleInfo(battleInfo)
            end
            -- 复盘查问题时需要转换
            -- 不一定全兼容转换格式
            -- battleInfo = BattleControler:turnServerDataToBattleInfo(battleInfo)
        end
        
        if not battleInfo.restartIdx then
            battleInfo.restartIdx = 0
        end

        if battleInfo.gameMode then
            mode = battleInfo.gameMode
        end
        --强制回放
        battleInfo.replayGame = true
    end
    if not battleInfo.gameMode then
        battleInfo.gameMode = mode 
    end
    self.__gameMode = battleInfo.gameMode
    self._battleInfo = battleInfo
    local battleLabels = battleInfo.battleLabel
    --设置是否是调试模式
    self:setIsDebugBattle(battleInfo.isDebug)

    -- print(TimeControler:getTempTime() - t1,"______初始化数据时间-----")
    -- t1 = TimeControler:getTempTime()

    local _getUserRid = function( )
        for k,v in pairs(self._battleInfo.battleUsers) do
            if (v.team and v.team == Fight.camp_1) or tonumber(k) == 1 then
                local rid = v._id or v.rid
                return rid
            end
        end
        return "1"
    end
    if not self._battleInfo.userRid then
        if not DEBUG_SERVICES then
            self._battleInfo.userRid = UserModel:rid()
            if Fight.use_operate_info then
                self._battleInfo.userRid = _getUserRid()
            end
            -- self._battleInfo.userRid = "dev9_9926"
            -- self._battleInfo.userRid = "dev14_8133" --"dev14_8133",--"dev14_8154"(阵营1)
        else
            self._battleInfo.userRid = "1"--UserModel:rid()
            self._battleInfo.userRid = _getUserRid()
            -- if self._battleInfo.battleUsers and #self._battleInfo.battleUsers > 0 and self._battleInfo.battleUsers[1]._id then
            --     self._battleInfo.userRid = self._battleInfo.battleUsers[1]._id
            -- end
        end
    end
    echo ("userRid---",self._battleInfo.userRid)

    local randomInzi = battleInfo.randomSeed or 100 --os.time()%10000
    if DEBUG_SERVICES  then
        randomInzi = randomInzi 
        BattleRandomControl.setOneRandomYinzi(randomInzi,10)
    else
        --如果是固定种子
        if  Fight.fixRandomSeed then
            BattleRandomControl.setOneRandomYinzi(randomInzi,10)
        else
            echo(battleInfo.randomSeed,"____battleInfo.randomSeed",randomInzi)
            if battleInfo.randomSeed then
                --todo
            else
                battleInfo.randomSeed = TimeControler:getServerTime()
            end
            BattleRandomControl.setOneRandomYinzi(battleInfo.randomSeed,10)
        end
    end
    -- echoError("战斗类型-----------",battleLabels,"===========================",self.battleLabel)
    self:setBattleLabel(battleInfo)

    -- echo(randomInzi)
   

    -- 战报统计
    if Fight.game_statistic and not Fight.use_operate_info then
        GameStatistics:init()
        
        -- 直接将levelId 存入
        if not battleInfo.levelId then
            battleInfo.levelId = self.__levelHid
        end

    end

    if not Fight.isDummy then
        if self._battleInfo.restartIdx ==0 then
            --进入战斗之前移除没有使用的texture
            WindowControler:clearUnusedTexture(true)
        end
    end
    if self._battleInfo.restartIdx > 0 then
        -- 让随机数跳过几个数
        BattleRandomControl.gotoTargetStep(self._battleInfo.restartIdx)
    end

    if not battleInfo.levelId then
        battleInfo.levelId = Fight.default_level_id 
        self.__levelHid = Fight.default_level_id 
        echo("___________没有设置levelId,默认为",mode,self.__levelHid)
    end
    self:setLevelId(battleInfo.levelId)



    self._battleInfo = battleInfo

    if DEBUG_SERVICES then
        -- 判断是否需要校验
        local needCheck =  BattleCheckControler:checkBattleResut(battleInfo)
        if not needCheck then
            --那么不需要校验
            self._isNoNeedCheck = true
            return
        end
    end
    
    --进入战斗
    self:onEnterBattle()

   --这个暂时注释掉  使用pve来模拟pvp
    -- if mode ==Fight.gameMode_pvp then
    --     self.__levelHid = "103"
    -- end
   
    self:checkTeam(mode,battleInfo)
    --暂时关闭 草纸
    -- battleInfo.operation = nil

    --判断是否有操作
    if battleInfo.operation then
        --如果是字符串换
        if type(battleInfo.operation) == "string" then
            battleInfo.operation = json.decode(battleInfo.operation)
        end

        -- echo("the battleInfo.operation length < 3, is" ,#battleInfo.operation)
        -- if #battleInfo.operation < 3 then
        --     for i=#battleInfo.operation +1,3 do
        --         battleInfo.operation[i] = {}
        --     end
            
        -- end
        self.gameControler.logical.handleOperationInfo = battleInfo.operation
        -- echo(#self.gameControler.logical.handleOperationInfo,"__handleOperationInfo_")
    end

    --如果是回放的
    if battleInfo.replayGame then
        echo("___-回放战斗----------是")
        self.gameControler.replayGame = 2
    end
    -- battleInfo.randomSeed = 100

    echo("__________________到底是哪一个关卡",self.__levelHid,battleInfo.randomSeed)
    
    -- local taa1 = TimeControler:getTempTime()
    local onClearCompelet = function (  )
        -- echo(TimeControler:getTempTime()- taa1,"____销毁ui纹理耗时------")
        self.gameControler:checkLoadTexture()
    end
    
    if not Fight.isDummy then
        if not skipClearView  then
            WindowControler:onEnterBattle(onClearCompelet)
        else
            onClearCompelet()
        end
        
    else
        onClearCompelet()
    end
    -- dump(self._battleInfo.battleUsers,"s--------ssssss")

    return self.gameControler
end


-- 创建gameControler 通过战斗类型
function BattleControler:createGameControler(root)

    self.gameControler =  GameControlerEx.new(root)

    self.gameControler.gameMode = self.__gameMode
    --初始化统计
    StatisticsControler:init(self.gameControler)
end

--进入游戏
function BattleControler:onEnterBattle(  )


    if  DEBUG_SERVICES  then
        self:createGameControler(nil)
    else

        EventControler:dispatchEvent(BattleEvent.BATTLEEVENT_ONBATTLEENTER)
        local scene = WindowControler:getCurrScene()
        local battleRoot = scene:getBattleRoot()

        -- 执行预加载战斗逻辑
        self:doPreLoadLogic()
        self:createGameControler(battleRoot)      
        --显示root    
        --AudioModel:playMusic(MusicConfig.m_scene_battle, true)
    end
end

--[[
    执行预加载战斗逻辑
]]
function BattleControler:doPreLoadLogic()
    local scene = WindowControler:getCurrScene()
    -- 序章第一场战斗会设置预加载
    if self.isPreloading then
        -- 设置不隐藏UI root
        scene:showBattleRoot(true)
        -- 隐藏battleRoot
        scene:setBattleRootVisiable(false)
    else
        scene:showBattleRoot()
    end
end

--游戏退出 
function BattleControler:onExitBattle( result )
    -- echoError ("___________战斗退出, onExitBattle",result)
    ViewSpine:disableCtor(false)
    if not Fight.isDummy then
        ServerRealTime:handleClose()--关闭连接
    end
    self.__resControler = nil
    self:resetTeamCamp()
    if not Fight.isDummy then
        -- 关闭多人语音
        if self:getBattleLabel() == GameVars.battleLabels.guildBossGve then
            ChatShareControler:quitRealTimeRoom(self._battleInfo.battleId)
        end
    end
    if not self.gameControler then
        return
    end

    local poolType = self.gameControler.__poolType
    
    if not Fight.isDummy then
        collectgarbage("collect")
    end
    
    if not Fight.isDummy then
        WindowControler:clearUnusedTexture( true )
        -- 如果isJumpWorld则不跳主城
        local onLoadingEndFunc = function ( isJumpToHome, isJumpWorld )
             
            if self.gameControler then
                self.gameControler:deleteMe()
                self.gameControler = nil
            end
            -- 这个需要销毁一下，不然上一关的内容会一直都在内存中
            self.curRaidId = nil
            if not Fight.isDummy then
                --ui复原
                WindowControler:onResumeComplete()
            end
            local scene = WindowControler:getCurrScene()  
            -- echoError("查找错误，不是错误----------------------")
            --必须不是回放的
            if not self._battleInfo.replayGame then
                echo("发出了战斗关闭的消息 =====================")
                EventControler:dispatchEvent(BattleEvent.BATTLEEVENT_BATTLE_CLOSE)
            end

            -- 序章特殊
            if PrologueUtils:showPrologue() then
                -- 序章的引导用这里判断过关
                EventControler:dispatchEvent(TutorialEvent.TUTORIAL_FINISH_BATTLE,{result = Fight.result_win})
                -- 序章发这个消息只为告诉序章系统战斗结束了
                EventControler:dispatchEvent(TutorialEvent.TUTORIAL_FINISH_PROLOGUE_BATTLE)
            end
            
            scene:showRoot()
            
            echo("查看跳转参数=======",isJumpToHome,isJumpWorld)
            if isJumpToHome and not isJumpWorld then
                -- WindowControler:closeWindow("WorldMainView")
                -- WindowControler:showWindow("HomeMainView")
                WindowControler:goBackToHomeView(true)
                echo("去主城======================")
            else
                if self.__battleLoseJumpType then
                    BattleControler:jumpToAppointWindows("CharMainView")
                end
            end

             --self:checkExitBattle(result)

            
            
        end

        -- 2017.8.5 当有下一个剧情关卡时不因引导跳出到主城
        local nextRaid = nil
        if self._battleInfo.withStory then
            nextRaid = WorldModel:getNextRaidInStory(self.curRaidId)
        end
        echo("新手引导跳出剧情log",WindowControler:isNeedJumpToHome(),nextRaid == nil,result == Fight.result_win,TutorialManager.getInstance():isFinishForceGuide())
        -- 强制引导的时候有需要就跳/非强制引导阶段最后一关才跳中间不去跳（按照这个逻辑线写一个）/3-3也要跳
        -- 强制引导的时候有需要就跳/非强制引导当前引导步骤需要跳
        -- 写死10206去六界
        -- local isJumpWorld = false
        -- if tostring(self.curRaidId) == "10206" then
        --     isJumpWorld = true
        -- end

        local tutorialManager = TutorialManager.getInstance()
        if WindowControler:isNeedJumpToHome() then
            -- echoError("\n\n______WindowControler:isNeedJumpToHome()______")
            if not tutorialManager:isFinishForceGuide() 
                or nextRaid == nil 
                or tutorialManager:isCurStepFirstStep() and tutorialManager:isCurUnlockJump()
                -- or tostring(self.curRaidId) == "10303" and result == Fight.result_win 
            then
                -- 跳的操作，用的以前的
                local processActions = WindowControler:onExitBattle()
                if #processActions ==0 then
                    -- onLoadingEndFunc()
                    onLoadingEndFunc(true,isJumpWorld)
                else
                    local gameType = FuncLoadingNew.getGameTypeByBattleLabel(BattleControler:getBattleLabel(), self._battleInfo.levelId)
                    loadingNumber = NewLoadingControler:getLoadingNumberByTypeAndLevelId(gameType, self._battleInfo.withStory, self._battleInfo.levelId) 
                    WindowControler:showTopWindow("CompNewLoading", loadingNumber, {percent=10,frame =10}, processActions, c_func(onLoadingEndFunc,true,isJumpWorld),true)
                    -- WindowControler:showTopWindow("CompLoading", {percent=10,frame =10}, processActions, c_func(onLoadingEndFunc,true),true)
                end 
                return
            end
        end
        -- 需要跳主城（如果一章还没结束就不跳出，强制引导结束才如此）
        -- if WindowControler:isNeedJumpToHome() and nextRaid == nil and result == Fight.result_win and not TutorialManager.getInstance():isFinishForceGuide() then
        --     local processActions = WindowControler:onExitBattle()
        --     if #processActions ==0 then
        --         onLoadingEndFunc()
        --         onLoadingEndFunc(true)
        --     else
        --         WindowControler:showTopWindow("CompLoading", {percent=10,frame =10}, processActions, c_func(onLoadingEndFunc,true),true)
        --     end 
        --     return  
        -- end

        if self._battleInfo.withStory then
            -- echoError("带有故事情节--------")

            -- echoError("\n\n________withStory___________")
            --echoError("self.curRaidId","980行",self.curRaidId)
            if PrologueUtils:isFirstRaidId(self.curRaidId) 
            then
                echo("第一个序章，要退出，第二个序章也要退出")
                onLoadingEndFunc(false)
                return
            end

            --if PrologueUtils:showPrologue() and (not )



            local nextRaid =  WorldModel:getNextRaidInStory(self.curRaidId)



            if nextRaid ~= nil and result == Fight.result_win then
                --echo("开始下一个战斗-------------")
                --清楚上一个战斗的内容
                -- if not Fight.isDummy then
                --     WindowControler:onResumeComplete()
                -- end
                if self.gameControler then
                    self.gameControler:deleteMe()
                    self.gameControler = nil
                end
                if PrologueUtils:showPrologue() then
                    EventControler:dispatchEvent(BattleEvent.BATTLEEVENT_BATTLE_CLOSE,poolType)
                end

                self:startBattleFormWorld(nextRaid)
            elseif nextRaid == nil and result == Fight.result_win then
                --echoError("这个是没有章节的内容 需要播放章节结束动画")
                local processActions = WindowControler:onExitBattle()
                if #processActions == 0 then
                    --echo("=======================直接结束")
                    onLoadingEndFunc()
                else
                    -- echoError("显示StoryLoadingView----------")
                    -- if PrologueUtils:isLastRaidId(self.curRaidId) then
                    -- 这个方法已经被删掉了
                    if false then 
                        onLoadingEndFunc(false)
                    else
                        local gameType = FuncLoadingNew.getGameTypeByBattleLabel(BattleControler:getBattleLabel(), self._battleInfo.levelId)
                        local loadingNumber = NewLoadingControler:getLoadingNumberByTypeAndLevelId(gameType, self._battleInfo.withStory, self._battleInfo.levelId)
                        WindowControler:showTopWindow("CompNewLoading", loadingNumber, {percent=10,frame =10}, processActions, onLoadingEndFunc, true)
                        -- WindowControler:showTopWindow("StoryLoadingView",self.storyId, processActions, onLoadingEndFunc,true)    
                    end
                end

            else
                -- echoError("战斗失败了=--------isStoryExit___", BattleControler.isStoryExit)

                --战斗失败了
                --直接加载loading条 
                local processActions = WindowControler:onExitBattle()
                if #processActions == 0 then
                    --echoError("直接结束================")
                    onLoadingEndFunc()
                else
                    --echoError("loading 然后结束---------")
                    local gameType = FuncLoadingNew.getGameTypeByBattleLabel(BattleControler:getBattleLabel(), self._battleInfo.levelId)
                    local loadingNumber
                    if self.isStoryExit then
                        loadingNumber = NewLoadingControler:getLoadingNumberByTypeAndStoryId(gameType, self.storyId)
                    else                       
                        loadingNumber = NewLoadingControler:getLoadingNumberWhileLose(gameType)
                    end                    
                    
                    WindowControler:showTopWindow("CompNewLoading", loadingNumber, {percent=10,frame =10}, processActions, onLoadingEndFunc, true)
                    -- WindowControler:showTopWindow("CompLoading", {percent=10,frame =10}, processActions, onLoadingEndFunc,true)    
                    --WindowControler:showTopWindow("RaidLoadingView",self._battleInfo.raidId, processActions, onLoadingEndFunc)
                end        
            end
        else
            -- 如果是无底深渊、并且战斗胜利、不弹战斗结算及loading 直接退出战斗
            if self:getBattleLabel() == GameVars.battleLabels.endlessPve and
                self._battleInfo.battleParams.wave == FuncEndless.waveNum.FIRST and
                 result == Fight.result_win then
                if self.gameControler then
                    self.gameControler:deleteMe()
                    self.gameControler = nil
                end
                EventControler:dispatchEvent(BattleEvent.BATTLEEVENT_BATTLE_CLOSE)
                return
            end
            --echoError("不带故事情节的")
            --直接loading条结束   一般的战斗不带剧情的
                local processActions = WindowControler:onExitBattle()
                if #processActions ==0 then
                    onLoadingEndFunc()
                else
                    local gameType = FuncLoadingNew.getGameTypeByBattleLabel(BattleControler:getBattleLabel(), self._battleInfo.levelId)
                    local loadingNumber 
                    if result == Fight.result_win then
                        echo("\n\n________胜利___________")    
                        loadingNumber = NewLoadingControler:getLoadingNumberByTypeAndLevelId(gameType, self._battleInfo.withStory, self._battleInfo.levelId)
                    else
                        loadingNumber = NewLoadingControler:getLoadingNumberWhileLose(gameType)
                    end  
                    WindowControler:showTopWindow("CompNewLoading", loadingNumber, {percent=10,frame =10}, processActions, onLoadingEndFunc, true)
                    -- WindowControler:showTopWindow("CompLoading", {percent=10,frame =10}, processActions, onLoadingEndFunc,true)
                    --WindowControler:showTopWindow("RaidLoadingView",self._battleInfo.raidId, processActions, onLoadingEndFunc)
                end   
        end
    else
        self.gameControler:deleteMe()
        self.gameControler = nil

    end
    
    self.__levelHid = nil
    self.__gameMode = nil

    self.__gameResult = nil
    
    self.__poolType = nil
end

function BattleControler:saveBattleInfo( isCheck)
    if DEBUG_SERVICES and (not IS_LOCAL_RUN_BATTLE) then
        return
    end
    --存储战报
    -- if not self._battleInfo.isSaveData   then
        self._battleInfo.isSaveData = true 
        self._battleInfo.operation = self.gameControler.logical.handleOperationInfo
        self._battleInfo.dataString =  self.gameControler.verifyControler:encrypt()
        echo("保存战斗信息")
        GameStatistics:saveBattleInfo(self._battleInfo,isCheck)

    -- end
end

-- 判断是否在战斗中
function BattleControler:isInBattle()
    if self.gameControler then
        return true
    else
        return false
    end
end

-- 判断是否在mini战斗中
function BattleControler:isInMiniBattle()
    return false
end

--[[
是否在发送请求开始和发送请求结束之间
]]
function BattleControler:isRealInBattle()
    if self.betweenAction then
        return true
    else
        return false
    end
end


-- 获取出战的伙伴id
function BattleControler:getPartnerIds( )
    local pTbl = {}
    for k,v in pairs(self._battleInfo.battleUsers) do
        local uId = v.rid or v._id
        if uId == self._battleInfo.userRid and v.partners then
            for m,n in pairs(v.partners) do
                if (not n.isEmployee) and (not FuncWonderland.isWonderLandNpc(m)) then
                    table.insert(pTbl,m)
                end
            end
        end
    end
    -- dump(pTbl,"===========")
    return pTbl
end

-- 检查是否是试炼、>0 是试炼
function BattleControler:checkIsTrail( )
    if (self.battleLabel == GameVars.battleLabels.trailPve or 
        self.battleLabel == GameVars.battleLabels.trailGve1) then
        return Fight.trail_shanshen
    end

    if (self.battleLabel == GameVars.battleLabels.trailPve2 or 
        self.battleLabel == GameVars.battleLabels.trailGve2) then
        return Fight.trail_huoshen
    end

    if (self.battleLabel == GameVars.battleLabels.trailPve3 or 
        self.battleLabel == GameVars.battleLabels.trailGve3) then
        return Fight.trail_daobaozhe
    end
    return Fight.not_trail
end
-- 检查是否是试炼PVE
function BattleControler:checkIsTrialPve( )
    if self.battleLabel == GameVars.battleLabels.trailPve or 
        self.battleLabel == GameVars.battleLabels.trailPve2 or
        self.battleLabel == GameVars.battleLabels.trailPve3 then
        return true
    else
        return false
    end
end

-- -- 检查是否是试炼GVE
-- function BattleControler:checkIsTrialGVE(  )
--     if self.battleLabel == GameVars.battleLabels.trailGve1 or 
--         self.battleLabel == GameVars.battleLabels.trailGve2 or
--         self.battleLabel == GameVars.battleLabels.trailGve3 then
--         return true
--     else
--         return false
--     end
-- end
-- 检测是否是锁妖塔战斗
function BattleControler:checkIsTower( )
    if self.battleLabel == GameVars.battleLabels.towerPve or
        self.battleLabel == GameVars.battleLabels.towerBossPve or
        self.battleLabel == GameVars.battleLabels.towerNpc then
        return true
    else
        return false
    end
end
-- 检测是否是锁妖塔NPC战斗
function BattleControler:checkIsTowerNpc( )
    if self.battleLabel == GameVars.battleLabels.towerNpc then
        return true
    end
    return false
end
-- 检查是否是锁妖塔boss战
function BattleControler:checkIsTowerBossPVE( )
    if self.battleLabel == GameVars.battleLabels.towerBossPve then
        return true
    end
    return false
end
-- 检查是否是PVP战斗
function BattleControler:checkIsPVP( )
    if self.battleLabel == GameVars.battleLabels.pvp then
        return true
    end
    return false
end
-- 检查是否是六界战斗
function BattleControler:checkIsWorldPVE( ... )
    if self.battleLabel == GameVars.battleLabels.worldPve then
        return true
    end
    return false
end
-- 检查是否是共享副本战斗
function BattleControler:checkIsShareBossPVE( )
    if self.battleLabel == GameVars.battleLabels.shareBossPve then
        return true
    end
    return false
end
-- 检查是否是情缘战斗
function BattleControler:checkIsLovePVE( )
    if self.battleLabel == GameVars.battleLabels.lovePve then
        return true
    end
    return false
end
-- 检测是否是六界轶事玩法
function BattleControler:checkIsMissionPVE( )
   if self.battleLabel == GameVars.battleLabels.missionMonkeyPve or 
        self.battleLabel == GameVars.battleLabels.missionBattlePve or 
        self.battleLabel == GameVars.battleLabels.missionIcePve or 
        self.battleLabel == GameVars.battleLabels.missionBombPve 
        then
        return true
    end
    return false
end
-- 检测是否是仙界对决
function BattleControler:checkIsCrossPeak( )
    if self.battleLabel == GameVars.battleLabels.crossPeakPvp or 
        self.battleLabel == GameVars.battleLabels.crossPeakPve or 
        self.battleLabel == GameVars.battleLabels.crossPeakPvp2 
        then
        return true
    end
    return false
end
-- 是否是仙界对决BP玩法
function BattleControler:checkIsCrossPeakModeBP( ... )
    if self:checkIsCrossPeak() then
        if self._battleInfo.battleParams.battleMode == Fight.crosspeak_mode_bp then
            return true
        end
    end
    return false
end

--判断是否是实时多人战斗
function BattleControler:checkIsMultyBattle(  )
    local result = false
    if self.battleLabel == GameVars.battleLabels.crossPeakPvp or
        self.battleLabel == GameVars.battleLabels.trailGve1 or
        self.battleLabel == GameVars.battleLabels.trailGve2 or
        self.battleLabel == GameVars.battleLabels.trailGve3 or
        self.battleLabel == GameVars.battleLabels.crossPeakPvp2 or 
        self.battleLabel == GameVars.battleLabels.guildBossGve
        then
        result = true
    end
    return  result
end
-- 是否是仙盟探索玩法
function BattleControler:checkIsExploreBattle(  )
    if self.battleLabel == GameVars.battleLabels.exploreMonster or
        self.battleLabel == GameVars.battleLabels.exploreElite or
        self.battleLabel == GameVars.battleLabels.exploreMine or
        self.battleLabel == GameVars.battleLabels.exploreBuild
        then
            return true
    end
    return false
end

-- 判断是否是奇侠传记的战斗
function BattleControler:cheIsBiographyBattle()
    return self.battleLabel == GameVars.battleLabels.biographyPve
end

--获取当前的战斗标签
function BattleControler:getBattleLabel()
    return self.battleLabel
end

--获取战斗结果 和开始战斗的参数结构一模一样
function BattleControler:getBattleDatas( isSkip )
    -- 赋个值
    local battleInfo 
    --如果是不需要战斗校验的
    if self._isNoNeedCheck and self._battleInfo.battleResultClient then
        battleInfo = self._battleInfo.battleResultClient
        return battleInfo
    else
        battleInfo = {
            --结束帧数
            rt = self.gameControler._gameResult,
            operation = self.gameControler.logical.handleOperationInfo ,
            star = self.gameControler._battleStar,
            battleLabel = self.battleLabel,
            -- levelId = self.__levelHid,
            -- battleUsers = self._battleInfo.battleUsers,
            -- fragment = "",
            -- frame = self.gameControler.updateCount,
            -- gameMode = self.gameMode,
            battleId = self._battleInfo.battleId,
            -- randomSeed = self._battleInfo.randomSeed,
            -- userRid = self._battleInfo.userRid,
            isPauseOut = 0, --是否是暂停退出
            restartIdx = 0,--重新开始次数(默认为0)
            -- 出手次数
            handleCount = StatisticsControler:getHandleCount(Fight.camp_1),
            logsInfo = self.gameControler.verifyControler:encrypt(),-- 校验信息
            round = math.ceil(self.gameControler:getCurrRound()/2),--战斗回合数
        }

    end

    if isSkip then
        battleInfo.isSkip = 1
    end
    -- 跳过战斗服校验(锁妖塔不能跳过战斗服校验)
    if IS_SKIP_SERVICE and not BattleControler:checkIsTower() then
        battleInfo.isSkip = 1
    end
    -- 是否是暂停退出游戏
    if self.gameControler._isPauseOut then
        battleInfo.isPauseOut = 1
        battleInfo.rt = Fight.result_handOut
    end
    -- 如果是重新开始的战斗、则需要添加随机数跳转
    battleInfo.restartIdx = self._battleInfo.restartIdx

    -- 返还一下可能没用到的怒气
    self.gameControler.energyControler:returnEnergyByCamp()

    -- if battleInfo.star == 0 
    --     and (self.battleLabel == GameVars.battleLabels.trailPve or self.battleLabel == GameVars.battleLabels.trailPve2
    --             or self.battleLabel == GameVars.battleLabels.trailGve1 or self.battleLabel == GameVars.battleLabels.trailGve2
    --         ) then
    --     --echoWarn("试炼关卡星级是0了","_aaaaaa__")
    --     battleInfo.star = 1
    -- end
    --echo( battleInfo.star,"___ battleInfo.star")
    battleInfo.battleResultParams = {}
    if self:checkIsTower() then
        local tpInfo = self.gameControler:getPartnersInfo()
        battleInfo.battleResultParams.partnersInfo = tpInfo.partnersInfo
        battleInfo.battleResultParams.employeeInfo = tpInfo.employeeInfo
        battleInfo.battleResultParams.towerInfo = self.gameControler:getMonsterInfoParams()
        -- 战斗失败、并且不是中途退出的，将血量直接置为0
        if battleInfo.rt == Fight.result_lose and battleInfo.isPauseOut == 0 then
            for k,v in pairs(battleInfo.battleResultParams.partnersInfo) do
                v.hpPercent = 0
            end
            for k,v in pairs(battleInfo.battleResultParams.employeeInfo) do
                v.hpPercent = 0
            end
        end
    end
    local bLabel = BattleControler:getBattleLabel()

    -- 仙盟探索传血量值(精英怪不需要传)
    if self:checkIsExploreBattle() then
        if bLabel ~= GameVars.battleLabels.exploreElite then
            local tpInfo = self.gameControler:getPartnersInfo()
            battleInfo.battleResultParams.unitInfo = tpInfo.partnersInfo
            -- 战斗失败、并且不是中途退出的，将血量直接置为0
            if battleInfo.rt == Fight.result_lose and battleInfo.isPauseOut == 0 then
                for k,v in pairs(battleInfo.battleResultParams.unitInfo) do
                    v.hpPercent = 0
                end
            end
        else
            battleInfo.battleResultParams.unitInfo = {}
        end
        battleInfo.battleResultParams.explore = self.gameControler:getMonsterInfoParams()
    end

    if self:checkIsShareBossPVE() then
        battleInfo.battleResultParams.shareBossInfo = self.gameControler:getShareBossInfoParams()
    end
    if bLabel == GameVars.battleLabels.guildBossPve or
    bLabel == GameVars.battleLabels.guildBossGve then
        battleInfo.battleResultParams.guildBossInfo = self.gameControler:getGuildBossInfoParams()
    end

    if bLabel == GameVars.battleLabels.missionBattlePve or
        bLabel == GameVars.battleLabels.missionIcePve
     then
        if battleInfo.rt == Fight.result_win then
            battleInfo.score = 1
        else
            battleInfo.score = 0
        end
    end
    if bLabel == GameVars.battleLabels.missionMonkeyPve then
        battleInfo.score = self.gameControler.logical.missionNum
    end
    if bLabel == GameVars.battleLabels.missionBombPve then
        battleInfo.score = self.gameControler.logical.missionNum
    end
    if bLabel == GameVars.battleLabels.endlessPve then
        battleInfo.battleResultParams.endlessId = self._battleInfo.battleParams.endlessId
    end
    
    if BattleControler:checkIsCrossPeak() then
        battleInfo.battleResultParams = self.gameControler.cpControler:getCrossPeakParams()
    end
    if BattleControler:checkIsTrail() ~= Fight.not_trail then
        battleInfo.battleResultParams = self.gameControler:getTrialResult()
        dump("试炼结算数据===",battleInfo.battleResultParams)
        if battleInfo.star == 0 then
            -- echoError ("试炼关卡星级是0了")
            battleInfo.star = 1
        end
    end

    -- dump(battleInfo.battleResultParams,"战报数据-----")
    -- 战报修改
    if BattleControler:checkIsMultyBattle() then
        local params = {}
        params.rt = battleInfo.rt
        params.logsInfo = battleInfo.logsInfo
        params.star = battleInfo.star
        params.battleResultParams = battleInfo.battleResultParams
        params.battleId = battleInfo.battleId
        battleInfo = {}
        battleInfo = params
    end
    return battleInfo
end

-- 可能会提前收到战斗结束的消息
-- function BattleControler:recvGameResult( params )
--     self.__gameResult = true
-- end

-- function BattleControler:setIsUpgrade( value )
--     self._isUpGrade = value
-- end



--[[
    --此接口是 通知游戏打开战斗结束界面 
    战斗结束界面关闭以后 会发送一个 游戏关闭的 消息
    BattleEvent.BATTLEEVENT_BATTLE_CLOSE,不会附带参数 因为结果 分系统自己知道
    参数说明
    {
        reward = {"1,101,1","3,100" }, 通用奖励格式 数组  如果为空  表示没奖励 
        result = 1,  战斗结果  1表示胜利 2表示失败
        star = 1,       星级 pvp  pve需要这个值
        addExp = 10,      加了多少经验 默认为0 消耗体力的副本需要传这个值
        preExp = 30,    --升级之前的经验值
        preLv  = 10,     --升级之前的等级
        
        heroAddExp = 30,

        

        damages=
        {
            camp1 = 
            {
                [1]={
                    hid = "5001",
                    damage = 100,
                    name = "张三",
                    star = 1,
                    lv = 10,
                    preLv = 9,
                    addExp = 100,
                    preExp = 1000,
                    quality = 1,
                    maxExp = 10000,
                    isMainHero = true     --可空  空 表示 不是主角
                },
                ...
            },
            camp2 = {
                 [2] = {
                    hid = "5001",
                    damage = 100,
                    icon = "lixiaoyao"     --这个可不要，可以从配置表中读取
                    star = 1,
                    lv = 10,
                    addExp = 100,
                    preExp = 1000,
                    maxExp = 10000,
                    quality = 1,
                    isMainHero = true,

                },
                ...
            }
        },        
        }
        
    }
]]

function BattleControler:showReward( battleResultData)
    -- echo("_____battleResultData_______")
    -- dump(battleResultData)
    -- echo("_____battleResultData_______")
    if self.userLevel then
        return
    end
    --echoError("-----------")
    

    -- echo("self._battleInfo==================================")
    -- dump(self._battleInfo)
    -- echo("self._battleInfo==================================")

    -- local times = WorldModel:getDropTimes()
    -- echo("翻倍次数------",times)
    -- local open,actTaskId = WorldModel:isOpenDropActivity()
    -- echo("活动是否开启，",open,"活动id",actTaskId,"===========")
    
    -- echoError("------------------------------")


    --echo("battleResultData=======================================")
    --dump(battleResultData)
    --echo("battleResultData=======================================")
    --echoError("------------------------------------")
    -- if self._battleInfo.replayGame  then
    --     FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CLOSE_REWARD)
    --     return
    -- end


    if self:checkIsPVP() then
        --echo("是否------------------------------")
        local pvpResult = {}
        pvpResult.result = battleResultData.result
        pvpResult.reward = battleResultData.reward
        pvpResult.battleLabels = self._battleInfo.battleLabel
        pvpResult.historyTopRank = self._battleInfo.historyTopRank
        pvpResult.lastHistoryTopRank = self._battleInfo.lastHistoryTopRank
        pvpResult.historyRank = self._battleInfo.historyRank  --PVPModel:getHistoryTopRank()
        pvpResult.userRank = self._battleInfo.userRank or 0
        EventControler:dispatchEvent(BattleEvent.BATTLEEVENT_BATTLE_REWARD, pvpResult )
        return
    end


    local addExp = battleResultData.heroAddExp
    battleResultData.gameMode = self.__gameMode
    battleResultData.addExp = battleResultData.addExp or 0
    battleResultData.preExp = battleResultData.preExp or 0
    battleResultData.preLv  = battleResultData.preLv  or UserModel:level()
    battleResultData.star   = battleResultData.star   or -1
    battleResultData.lv = UserModel:level()
    battleResultData.battleLabels = self.battleLabel

    
    --self._battleInfo
    --如果是pve   并且已经登录的情况下
    if (self.battleLabel == GameVars.battleLabels.worldPve or 
        self.battleLabel == GameVars.battleLabels.lovePve or 
        self.battleLabel == GameVars.battleLabels.guildGve and
        (not self.isDebugBattle)) then
        battleResultData.damages = {}
        battleResultData.damages.camp1 = {}
        --遍历infomation  拿对应伙伴的当前经验去构造数据

        --如果想排序，在这里按照位置进行排序就可以了
        local formation = self._battleInfo.battleUsers[1].formation
        local partners = self._battleInfo.battleUsers[1].partners
        if formation ~= nil and formation.partnerFormation then
            for k,v in pairs(formation.partnerFormation) do

                local hid = v.partner.partnerId
                --echo("aaaaaaaaaaaaaaaaaa",hid)
                if tostring(hid) ~= "0" then
                    local npcData = {}
                    if tostring(hid) == "1" then
                    else
                        --echo("2222222222222222222")
                        local data = PartnerModel:getPartnerDataById(hid)
                        local p = nil 
                        if partners then
                            p = partners[tostring(hid)]
                        end
                        if data ~= nil and p ~= nil then
                            local npcCfg = FuncPartner.getPartnerById(hid)
                            local maxExp = FuncPartner.getMaxExp( hid,data.level )
                            if maxExp == nil then
                                maxExp = data.exp
                            end
                            npcData.hid = hid    
                            npcData.name = GameConfig.getLanguage(npcCfg.name)
                            npcData.star = data.star
                            npcData.lv = data.level
                            npcData.preLv = p.level
                            npcData.quality = data.quality
                            npcData.maxExp = maxExp
                            npcData.icon = npcCfg.icon
                            npcData.garmentId = p.skin 
                            npcData.isMainHero = false
                            npcData.addExp = addExp
                            npcData.exp = data.exp
                            npcData.preExp = p.exp
                            npcData.order = TeamFormationModel:getPartnerPos(formation,hid)
                            npcData.damage = 100
                        end
                    end
                    if next( npcData) ~= nil then
                        table.insert(battleResultData.damages.camp1 , npcData)
                    end

                end
            end
        end
        battleResultData.damages.camp2 = {}

        --这里使用假数据
        battleResultData.damages.camp2 = battleResultData.damages.camp1

    end

    -- if self.battleLabel == GameVars.battleLabels.shareBossPve then
    --     battleResultData = battleResultData
    -- end
    -- dump(battleResultData, "\n\nbattleResultData")
    self.gameControler._gameResult = tonumber(battleResultData.result)
    EventControler:dispatchEvent(BattleEvent.BATTLEEVENT_BATTLE_REWARD, battleResultData )
    -- 序章不在这里发
    if not PrologueUtils:showPrologue() then
        -- 发给引导一个消息
        EventControler:dispatchEvent(TutorialEvent.TUTORIAL_FINISH_BATTLE, battleResultData)
    end
end


function BattleControler:setjumpType(jType,pId)
    self.__battleLoseJumpType = jType
    self.__partnerId = pId
end
-- 跳转指定界面.
function BattleControler:jumpToAppointWindows()
    local wInfo = Fight:getJumpInfoByType(self.__battleLoseJumpType)
    if wInfo then
        WindowControler:showWindow(wInfo.viewName,wInfo.idx,self.__partnerId)
    end
    self.__battleLoseJumpType = nil
    self.__partnerId = nil
end



--通过服务器回来的数据结构转化战斗信息
function BattleControler:turnServerDataToBattleInfo( serverData )
    if not serverData.battleParams then
        return serverData
    end
    local battleLabel = tostring(serverData.battleLabel)
    local battleParams = serverData.battleParams
    --主要是确认levelId 和特殊信息
    local levelId,levelRevise
    local gameMode  = Fight.gameMode_pve 
    --根据battleLabel找对应的关卡id
    if battleLabel == GameVars.battleLabels.worldPve then
        -- 写死sb逻辑
        if (tonumber(battleParams.stageId) == 10205 or tonumber(battleParams.stageId) == 10206)
            and tonumber(battleParams.levelId) ~= 0
        then
            levelId = battleParams.levelId
        else
            levelId = FuncChapter.getLevelIdByRaidId(battleParams.stageId)
        end
    elseif battleLabel == GameVars.battleLabels.lovePve then
        
    --pvp竞技场
    elseif battleLabel == GameVars.battleLabels.pvp then
        levelId = Fight.default_level_id
        gameMode = Fight.gameMode_pvp
    elseif battleLabel == GameVars.battleLabels.crossPeakPvp or 
        battleLabel == GameVars.battleLabels.crossPeakPvp2 then
        levelId = self:getCrossPeakLevelId(serverData)
        gameMode = Fight.gameMode_pvp
    elseif battleLabel == GameVars.battleLabels.crossPeakPve then
        levelId = self:getCrossPeakLevelId(serverData)
    --3个试炼pve
    elseif battleLabel == GameVars.battleLabels.trailPve or battleLabel == GameVars.battleLabels.trailPve2 or
        battleLabel == GameVars.battleLabels.trailPve3 
        then
        levelId = FuncTrail.getLevelIdByTrialId(battleParams.trialId,1)
    --3个试炼gve
    elseif  battleLabel == GameVars.battleLabels.trailGve1 or
        battleLabel == GameVars.battleLabels.trailGve2 or battleLabel == GameVars.battleLabels.trailGve3 
        then
        levelId = FuncTrail.getLevelIdByTrialId(battleParams.trialId,2)

    --爬塔pve 需要根据分系统判定
    elseif battleLabel == GameVars.battleLabels.towerPve or battleLabel == GameVars.battleLabels.towerBossPve or
        battleLabel == GameVars.battleLabels.towerNpc
        then
        -- 如果是NPC的话需要获取npc事件对应的id
        if battleLabel == GameVars.battleLabels.towerNpc then
            levelId = FuncTower.getLevelIdByNpcEventId(battleParams.eventId)
        else
            levelId,levelRevise = FuncTower.getLevelIdByMonster(battleParams.monsterId,battleParams.star)
        end
        -- serverData.towerInfo = battleParams.towerInfo
        -- serverData.partnersInfo = battleParams.unitInfo --其实这样子battleParams.unitInfo这个就不需要访问了

        if levelRevise then
            -- echo("星级怪难度修正系数-----",levelRevise)
            serverData.towerLevelRevise = levelRevise
        end
    elseif battleLabel == GameVars.battleLabels.shareBossPve then
        -- 共享副本处理
        -- levelId = "70301" --暂时使用这个测试测试关卡
        levelId = FuncShareBoss.getLevelIdById(tostring(battleParams.shareBossInfo.bossId))
        serverData.shareBossInfo = battleParams.shareBossInfo
        -- echo("共享副本处理====",levelId)
    elseif battleLabel == GameVars.battleLabels.guildGve then
        levelId = FuncGuildActivity.getFoodFightByMonsterId(tostring(battleParams.monsterInfo.monsterId)).foodLevelId
        -- echoError("llll=======",levelId)
        -- dump({levelId},"哪个关卡")
        -- 这里对怪物的属性值未设置
    elseif battleLabel == GameVars.battleLabels.missionBattlePve or
        battleLabel == GameVars.battleLabels.missionMonkeyPve or 
        battleLabel == GameVars.battleLabels.missionBombPve or 
        battleLabel == GameVars.battleLabels.missionIcePve 
         then
         -- dump(battleParams,"battleParams=====")
         local id = tostring(battleParams.id)
         local index = tonumber(battleParams.missionBattle.index)
        levelId = FuncMission.getMissionLevelId(id,index)
    elseif battleLabel == GameVars.battleLabels.wonderLandPve then
        levelId = FuncWonderland.getLevelIdByfloor(battleParams.bossType,battleParams.floor)
        serverData.wonderLand = {}
        serverData.wonderLand.tags = FuncWonderland.getTagsByfloor(battleParams.bossType,battleParams.floor)
        serverData.wonderLand.buffs = FuncWonderland.getBuffsByfloor(battleParams.bossType,battleParams.floor)
    elseif battleLabel == GameVars.battleLabels.guildBossPve then 
        levelId = FuncGuildBoss.getLevelIdById(tostring(battleParams.guildBossInfo.bossId))
        serverData.guildBossInfo = battleParams.guildBossInfo
    elseif battleLabel == GameVars.battleLabels.guildBossGve then 
        gameMode = Fight.gameMode_gve
        levelId = FuncGuildBoss.getLevelIdById(tostring(battleParams.guildBossInfo.bossId))
        serverData.guildBossInfo = battleParams.guildBossInfo
        if not Fight.isDummy then
            -- 多人的时候开启语音
            ChatShareControler:joinRealTimeRoom(serverData.battleId)
        end
    elseif battleLabel == GameVars.battleLabels.endlessPve then
        -- 无底深渊
        if battleParams.wave == FuncEndless.waveNum.FIRST then
            levelId = FuncEndless.getFirstLevelIdById(battleParams.endlessId)
        else
            levelId = FuncEndless.getSecondLevelIdById(battleParams.endlessId)
        end
    elseif battleLabel == GameVars.battleLabels.biographyPve then
        levelId = FuncBiography.getBiographyEventValueByKey(battleParams.eventId, "param2")
    elseif battleLabel == GameVars.battleLabels.exploreMonster or
        battleLabel == GameVars.battleLabels.exploreElite or
        battleLabel == GameVars.battleLabels.exploreMine or
        battleLabel == GameVars.battleLabels.exploreBuild
        then
        -- dump(serverData,"s===")
        levelId,levelRevise = FuncGuildExplore.getBattleLevelIdByType(serverData.battleParams)
        if levelRevise then
            serverData.towerLevelRevise = levelRevise
        end
    end
   
    serverData.levelId = tostring(levelId)
    serverData.gameMode = gameMode
    
    if serverData.operation then
        local idx = 0
        local key = table.getFirstKey(serverData.operation)
        -- 检查这些key是数组的话需要转换为p..index 处理
        if key and tonumber(key) then
            local tmp = {}
            for k,v in pairs(serverData.operation) do
                tmp["p"..v.index] = v
                if v.index > idx then
                    idx = v.index
                end
            end
            serverData.operation = tmp
            self._maxOperation = idx
        else
            if battleLabel == GameVars.battleLabels.crossPeakPve then
                self:setMaxOperation(serverData.operation)
            end
        end
    end
    -- dump(serverData,"转换后进战斗数据=====")
    return serverData

end

-- 获取跑环任务对应的levelId 
function BattleControler:getRingTaskLevelId( serverData )
    local sType = tonumber(serverData.battleParams.subtype)
    local rData = FuncRingTask.getTaskDataByTaskId(serverData.battleParams.ringId)
    local levelId,levelRevise
    if sType == FuncRingTask.TASK_SUBTYPE.BATTLE_CRITTER or
        sType == FuncRingTask.TASK_SUBTYPE.BATTLE_BOSS then
        levelId = serverData.battleParams.levelId
    elseif sType == FuncRingTask.TASK_SUBTYPE.BATTLE_MIRROR then
        levelId = rData.level
    elseif sType == FuncRingTask.TASK_SUBTYPE.BATTLE_NPC then
        levelId = FuncRingTask.getNpcLevelByNpcId(serverData.battleParams.enemyId)
    end
    if #serverData.battleUsers > 0 and  rData.parameter and #rData.parameter > 0 then
        local lv = serverData.battleUsers[1].level
        local a,b,c,d = rData.parameter[1],rData.parameter[2],rData.parameter[3],rData.parameter[4]
        if a and b and c and d and lv then
            levelRevise = (a*lv*lv*lv - b*lv*lv + c*lv + d)/10000
        end
    end
    return levelId,levelRevise
end

-- 设置最大操作序列
function BattleControler:setMaxOperation(operation)
    operation = operation or self._battleInfo.operation
    local idx = 1
    for k,v in pairs(operation) do
        if v.index > idx then
            idx = v.index
        end
    end
    self._maxOperation = idx
end

-- 获取最大的操作数
function BattleControler:getOperationCount()
    return self._maxOperation
end
-- 根据最大积分信息获取对应的地图
function BattleControler:getCrossPeakLevelId(serverData)
    local maxScore = 0
    for k,u in pairs(serverData.battleUsers) do
        local score
        if u.userBattleType == Fight.battle_type_robot then
            score = FuncCrosspeak.getRobotDataById(u.rid).score
        else
            score = u.crossPeak.score
        end
        if score and score > maxScore then
            maxScore = score
        end
    end
    local seg = FuncCrosspeak.getCurrentSegment(maxScore)
    return FuncCrosspeak.getSegmentLevelId(seg)
end

-- 战斗结算之前对本场战斗做战斗校验
-- 当战斗结束的时候，根据战斗IS_CHECK_DUMMY开关，是否做一次前端纯跑逻辑，校验是否一致
function BattleControler:checkBattleDummy(operation,logs)
    self:updateBattleCheckStatus(true)
    self.__oldLog = logs
    local bInfo = table.deepCopy(self._battleInfo)
    local OLD_IS_IGNORE_LOG = IS_IGNORE_LOG
    IS_IGNORE_LOG = true
    bInfo.operation = operation
    self:startBattleInfo(bInfo)
    IS_IGNORE_LOG = OLD_IS_IGNORE_LOG
end
-- 更新战斗校验
function BattleControler:updateBattleCheckStatus(value )
    if not value then
        -- 不取消校验的情况下才会发信息
        local logsInfo = self.gameControler.verifyControler:encrypt()
        if not self.gameControler:isCancelCheck() and self.__oldLog ~= logsInfo then
            self:saveBattleInfo(true)
            
            echoError("战斗校验不一致")
            local info = self._battleInfo
            local str = json.encode(info) .."\n viewLog:\n"..self.__oldLog .."\n dummyLog:\n"..logsInfo

            ClientActionControler:sendErrorLogToWebCenter(ClientActionControler.LOG_ERROR_TYPE.TYPE_LUA,ClientTagData.battleCheckError..tostring(self:getBattleLabel()),str)

        end

        if self.gameControler then
            self.gameControler:deleteMe()
            self.gameControler = nil
        end
        self:resetTeamCamp()
    end
    Fight.isDummy = value
end
-- 重新开始战斗
function BattleControler:restartBattle( )
    -- 先将resControler 暂时缓存下来
    self.__resControler = self.gameControler.resControler
    local bInfo = self._battleInfo
    bInfo.restartIdx = bInfo.restartIdx + 1
    -- self._battleInfo.restartIdx = bInfo.restartIdx
    if self.gameControler then
        self.gameControler:deleteMe()
        self.gameControler = nil
    end
    ViewSpine:clearSpineCache()
    self:setBattleLabel(bInfo)
    self:setCampData(bInfo.gameMode,bInfo)
end
function BattleControler:getResControler(  )
    return self.__resControler
end
-- 获取是否是重新开始的战斗
function BattleControler:getIsRestart( )
    if self._battleInfo.restartIdx > 0 then
        return true
    elseif self._battleInfo.replayGame and self.__resControler then
        return true
    else
        return false
    end
end
-- 设置巅峰竞技场我方归属类型,如果是我方rid team2 里面需要做战斗反向、战斗结束后重置回来
function BattleControler:setTeamCamp(camp)
    echo("我方的阵营归属=====",camp)
    self._myTeamCamp = camp
    self._toTeamCamp = camp == Fight.camp_1 and Fight.camp_2 or Fight.camp_1
    if not Fight.isDummy then
        if self._myTeamCamp ~= Fight.camp_1 then
            self._oldCameraWay = Fight.cameraWay
            Fight.cameraWay = Fight.cameraWay * (-1)
        end
    end
end
function BattleControler:getTeamCamp( )
    return self._myTeamCamp
end
function BattleControler:getOtherCamp( ... )
    return self._toTeamCamp
end
-- 重置的时候需要将镜头也重置回来、否则接下来战斗镜头会不对
function BattleControler:resetTeamCamp( )
    if self._myTeamCamp ~= Fight.camp_1 then
        self._myTeamCamp = Fight.camp_1
        self._toTeamCamp = Fight.camp_2
        if not Fight.isDummy and self._oldCameraWay then
            Fight.cameraWay = self._oldCameraWay
            self._oldCameraWay = nil
        end

    end
end
-- 是否是从剧情过来的
function BattleControler:chkIsXuQing( )
    return self.__isXuQing
end
function BattleControler:setXuQing(value)
    self.__isXuQing = value
end

--判断战斗服错误
function BattleControler:checkBattleServerError( errorInfo )
    --必须是正在战斗中的
    if not self.gameControler then
        return
    end
    local code = tonumber(errorInfo.code)
    --如果是战斗中错误
    if code == ErrorCode.battle_server_error or code == ErrorCode.battle_result_error  
        or code == ErrorCode.battle_star_error 
        then
        local battleId = self._battleInfo.battleId
        local info = self._battleInfo
        local str = "battlId:"..battleId.."\nbattleData:\n" .. json.encode(info) .."\n viewLog:\n"..self.gameControler.verifyControler:encrypt()
        --发送一个战斗服错误信息
        ClientActionControler:sendErrorLogToWebCenter(ClientActionControler.LOG_ERROR_TYPE.TYPE_LUA,ClientTagData.battleServerError..tostring(self:getBattleLabel()),str)
        
    end

end

-- 重置battlecontroller相关的值(主要战斗服用)
function BattleControler:resetBattleData( )
    self._myTeamCamp = Fight.camp_1
    self._toTeamCamp = Fight.camp_2
    self.__levelHid = nil
    self.__gameMode = nil 
    self.__gameResult = nil
    self.__battleNotFinish = nil
    self._maxOperation = 0
    if self.gameControler then
        -- print("播战报会走这里")
        self.gameControler:deleteMe()
        self.gameControler = nil
    end
end

-- 这是战斗错误code
function BattleControler:setMultyBattleNotFinish( )
    self.__battleNotFinish = true
end
function BattleControler:getMultyErrorCode( )
    return self.__battleNotFinish
end

--[[
    恢复序章战斗
]]
function BattleControler:resumePrologueBattle()
    if BattleControler.isPreloading then
        BattleControler.isPreloading = false
    end

    if self.gameControler then
        self.gameControler:realInitFirst()
    end

    local scene = WindowControler:getCurrScene()
    scene:showBattleRoot(true)
end

-- 设置等待loading动画
function BattleControler:setWaitLoadingAni(flag)
    self._waitLoadingAni = flag
end

-- 返回是否等待loading动画
function BattleControler:isWaitLoadingAni()
    return self._waitLoadingAni
end

-- 由loading调用负责在使用开门动画的时候开始战斗/动画流程
function BattleControler:loadAniComplete()
    if self._waitLoadingAni then
        self:setWaitLoadingAni(false)
        if self.gameControler then
            self.gameControler:beforeCreateStep()
        end
    end
end

return BattleControler