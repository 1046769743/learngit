local AnimDialogControl = { }





---------------------------------------------------- 
local scheduler = require("framework.scheduler") 

function AnimDialogControl:init()
    --回调方法 当某一条内容执行完毕后的灰掉方法
    self.optionBtCallback = nil

    local x,y = WindowControler:getDocLayer():getPosition()
    self.originPosition=cc.p(x,y);

    self.canScroll = true
end  
 

 
-- 优先级,震动，动画
--[[
来这里的入口：
展期那剧情，战后剧情 接收的参数都是 animBone中的ID

现在要增加的是 传入mapID  同时对应Map表是一个二维数组。
]]
function AnimDialogControl:showPlotDialog(id, _callback,raidId,params,onlyStory,needSkipCallBack,showOrder,isBattle)
    echo ("id, _callback,raidId,params,onlyStory,needSkipCallBack,showOrder,isBattle======",id, _callback,raidId,params,onlyStory,needSkipCallBack,showOrder,isBattle)
    self:init()
    --当前的一个定时器，主要用来刷新 震屏信息
    --self.handle = scheduler.scheduleGlobal(handler(self, self.updateFrame), 0.05)
    self.isBattle = isBattle --是否是战斗里调用的剧情

    --当前的章节
    self.raidId = raidId
    -- echoError("sekf.raidId",self.raidId,"====================",id)

    self.params = params
    --这个是选择后的回调
    self.optionBtCallback = _callback
    self.needSkipCallBack = needSkipCallBack

    self.onlyStory = onlyStory
    -- FuncAnimPlot.setPlotID(id)

    --获取对应行对应的所有数据
    self.allData = FuncAnimPlot.getRowData(id)

    --对应的spine文件名字
    self.animName = self.allData["order"]

    self:destoryView()
    --[[
    该spine对应的所有的events
    用于在updateFrame中更新遍历所有的事件。然后执行相应的动作
    ]]
    self.allEvents =FuncAnimPlot.getAllEvents( id )

    if showOrder == "window" then
        self.view = WindowControler:showWindow("AnimDialogView", self)    
    elseif showOrder == "battle" then
        self.view = WindowControler:showBattleWindow("AnimDialogView", self)
    else
        self.view = WindowControler:showTutoralWindow("AnimDialogView", self)    
    end
    self.view:setAnimDialogTime(self.params)
    -- self.view.colorLayer:setPlotLayerSize(GameVars.width+100,GameVars.height+100)
    self.view:setRaidId(raidId)
    self.view:initData(self.allData,self.allEvents)

    self.view:startUpdate()

    -- local rewardData = {"1,5003,4", "3,50000" } --序章 假的奖励
    -- self:animDialogBoxReward( rewardData )
    return self
end 

function AnimDialogControl:animDialogBoxReward( rewards )
    self.animBoxReward = rewards
end
--主角跑到指定位置方法
--[[ x, y :地图中坐标 、callBack回调方法
]]
function AnimDialogControl:moveBodyToPoint(x,y,callBack,isHide)
    if self.view then  
        self.view:onTouchEvent({x=x,y=y-50,callBack = function( )
            self.view:autoMoveBodyEnd()
            if callBack then 
                callBack() 
            end
        end},isHide)
    end
end



function AnimDialogControl:chkRequire()
    if empty(self.mapCfg ) then
        self.mapCfg = require("story.Map")
    end

    if empty(self.npcCfg) then
        self.npcCfg = require("story.Npc")
    end

    if empty(self.sourceCfg) then
        self.sourceCfg = require("level.Source")
    end


end

-- 进入对应的地图 callBack：地图加载完成后回调
function AnimDialogControl:showPlotDialogFormMapAnim(spaceArr,callBack)
    self:chkRequire()
    local spaceData = FuncChapter.getSpaceDataByName(spaceArr[1])
    self.order = tostring(spaceArr[2])
    self:showPlotDialogComplete(spaceData.map,callBack)
end
-- 进入对应地图并且加载完数据后有回调方法
function AnimDialogControl:showPlotDialogComplete(mapId,callBack)
    local animMapComplete = function ( ... )
        self.showMapComplete = nil
        if callBack then
            self.showMapComplete = nil --设置为空否则进入下一个order界面的时候还会再走一次
            self.view:delayCall(function( )
                callBack()
            end,50/GameVars.GAMEFRAMERATE )
        end
    end
    self.showMapComplete = animMapComplete
    self:showPlotDialogFormMap(mapId)
end

function AnimDialogControl:refreshCurrentMap()
    self:showPlotDialogFormMap(self.mapId)
end

function AnimDialogControl:setSpaceName(spaceName)
    -- self.spaceName = spaceName
end
function AnimDialogControl:getSpaceName()
    local spaceName = FuncChapter.getSpaceNameByMapId( self.mapId )
    return spaceName
end

function AnimDialogControl:getMapOrder()
    return self.order or 1
end

function AnimDialogControl:getNameShow()
    return self.showMapName
end

--[[
根据mapID
根据mapID获取对应的 map表中的二维数据
这个的回调是：当传送配置 0的时候执行的操作
fromorder 表示从哪个order进入的
]]
function AnimDialogControl:showPlotDialogFormMap(mapId,callBack,fromorder)
    echo("从地标中进入的操作---------",mapId,"=-=============isAgain=====",self.isAgain)
    self.showMapName = true
    --当前map对应的order
    if not self.order then
        local _order = MissionModel:getMissionOrder( mapId )   
        if _order then
            self.order = _order
        else
            self.order = "1"
        end      
    end
    
    self.mapId = mapId

    self.optionBtCallback = callBack
    
    --map读取出来是一个二维信息
    self:chkRequire()
    --当前的mapData
    self.mapData = self.mapCfg[tostring(mapId)]

    local animId = self.mapData[tostring(self.order)].anim

    self:showPlotDialog(animId, self.optionBtCallback,nil,nil,true,true,"window",nil,missParam)

    -- 先改成直接创建，这样效果要好一些
    self:addTranslateAni()
    -- self.view:delayCall(c_func(self.addTranslateAni,self), 1/GameVars.GAMEFRAMERATE)
    -- 寻找一下地标初始化相关信息
    if not fromorder then fromorder = 0 end
    local default = cc.p(0,0) -- 临时
    local target = nil
    for _,info in ipairs(self.mapData[tostring(self.order)].coordinate or {}) do
        if info.fromorder == fromorder then
            target = cc.p(info.x,info.y)
        end
        default.x,default.y = info.x,info.y
    end
    if not target then target = default end
    self.view:setInitLandMark(target.x,target.y)

    -- -1800,-65,2
    local isMissionOpen = MissionModel:isMissionAnimDialog( self:getSpaceName(),self.order )
    -- TODO判断任务是否已经完成？？
    local finishGoal = MissionModel:checkFinishMissionGoal(self:getSpaceName())
    echo("\n\n----------finishGoal--------",finishGoal)
    if isMissionOpen then
        if not finishGoal then
             --此时有轶事
            -- 1.请求服务器
            -- self.view:setBodysHide(true)
            self:starEnterMission()
        else
            -- 如果战斗后完成了任务，仅检查弹出奖励，不再创建场景npc等
            self:checkShowReward()
        end
    end

    -- 策划需求 轶事中也要显示NPC
    self.view:delayCall(c_func(self.addNpcObject,self),2/GameVars.GAMEFRAMERATE )

    if self.showMapComplete then
        self.showMapComplete()
    end

    -- 注册监听事件 轶事的开启
    EventControler:addEventListener(MissionEvent.MISSIONUI_REFRESH,self.updateMission,self);

    self:setIsInWorldMap(true)
    self:setIsMovingToSpace(false)
end

function AnimDialogControl:checkShowReward()
    local index = MissionModel:getBattleReward()
    -- 还没有弹出奖励
    if index then
        local openMissionMapSpace,missionData = MissionModel:getHasOpenMission(self:getSpaceName())
        if self.view then
            self.view:setMissionOpen(true,missionData,0)
            self.view:missionReward()
        end
    end
end

function AnimDialogControl:setIsInWorldMap(_boolean)
    self.isInWorldMap = _boolean
end

function AnimDialogControl:getIsInWorldMap()
    return self.isInWorldMap
end

function AnimDialogControl:updateMission()
    local isMissionOpen = MissionModel:isMissionAnimDialog( self:getSpaceName(),self.order )
    if isMissionOpen then
        --此时有轶事
        -- 1.请求服务器
        if self.view then
            self.view:setBodysHide(true)
        end
        if not self.openMissionS then
            self.openMissionS = true
            self:starEnterMission(  )
        end
    end
end


function AnimDialogControl:showPlotDialogFormMapAgain()
    self.isAgain = true
    if BattleControler:checkIsMissionPVE( ) then
        self:destoryView()       
        self:showPlotDialogFormMap(self.mapId)
    end
end

-- 六界轶事类型
function AnimDialogControl:starEnterMission(  )
    local openMissionMapSpace,missionData = MissionModel:getHasOpenMission(self:getSpaceName())
    local missionType = FuncMission.getMissionTypeById( missionData.id )
    -- 如果是问答
    if missionType == FuncMission.MISSIONTYPE.QUEST then
        MissionServer:requestQuestActive( {id = missionData.id }, c_func(self.missionQuestCallBack,self) )
    else
        MissionServer:requestUserInfo( {},c_func(self.missionCallBack,self))
    end
end

--[[
当六界轶事开启时，等待服务器返回轶事信息，再进入地图
1.先请求比武切磋的数据
2.请求主角的信息
]]
function AnimDialogControl:missionCallBack(params)
    if params.result then
        local missionNpcData = params.result.data.data
        self:paihangRequest(missionNpcData)
    else
        -- echoError("此时 不对------missionCallBack----------")
        if params.error.code == 550102 then

            WindowControler:showTips(GameConfig.getLanguage("#tid_mission_001"))
        elseif params.error.code == 550701 then 
            WindowControler:showTips(GameConfig.getLanguage("#tid_mission_002"))
        end
        self:destoryDialog()
        -- 发送返回六界通知
        EventControler:dispatchEvent(BattleEvent.BATTLEEVENT_ONEXIT_ANIMDIALOGVIEW, {})
    end
end

function AnimDialogControl:paihangRequest(missionNpcData)
    local openMissionMapSpace,missionData = MissionModel:getHasOpenMission(self:getSpaceName())
    local index = MissionModel:getMissionIndex(missionData.id)
    local params = {
        id = missionData.id,
        index = index
    }
    MissionServer:requestRanK( params, c_func(self.paihangRequestCallBack,self,missionNpcData) )
end

function AnimDialogControl:paihangRequestCallBack(missionNpcData,params)
    if params.result then
        self.missCall = true
        local score = params.result.data.score or 0
        -- 开始刷新view
        if self.view then 
            local openMissionMapSpace,missionData = MissionModel:getHasOpenMission(self:getSpaceName())
            self.view:setMissionOpen(true,missionData,score)
            MissionModel:setMissionKey(missionData.id, missionData.startTime)
            -- 分帧加载轶事中的立绘
            --todo
            EventControler:addEventListener(BattleEvent.BEGIN_BATTLE_FOR_FORMATION_VIEW, self.onTeamFormationComplete, self)
            EventControler:addEventListener(BattleEvent.BATTLEEVENT_BATTLE_CLOSE,self.showPlotDialogFormMapAgain,self) 
            self:addMissionNpcObject(missionNpcData)
            self.view:missionReward()
        end
    else
        self:destoryDialog()
        -- 发送返回六界通知
        EventControler:dispatchEvent(BattleEvent.BATTLEEVENT_ONEXIT_ANIMDIALOGVIEW, {})
    end
end

function AnimDialogControl:missionQuestCallBack( params )
    if params.result then
        dump(params.result, "----------params.result-------- ", 4)
        -- 开始刷新view
        if self.view then 
            local openMissionMapSpace,missionData = MissionModel:getHasOpenMission(self:getSpaceName())
            self.view:setMissionOpen(true,missionData,0)
            MissionModel:setMissionKey(missionData.id, missionData.startTime)
            self:addMissionNpcObject(nil)
            self.view:missionReward()
        end
        local data = params.result.data.members or {}
        -- dump(data, "xxxxxxxxxxx", 5)
        for i,v in pairs(data) do
            if type(v) == "table" then
                v.rid = v._id
                self:addMissionQuestNpc(v)
            end
        end
    else
        if params.error.code == 551701 then
        elseif params.error.code == 551702 then 
        end
        self:destoryDialog()
        -- 发送返回六界通知
        EventControler:dispatchEvent(BattleEvent.BATTLEEVENT_ONEXIT_ANIMDIALOGVIEW, {})
    end
end


--[[
放养角色 靠近法阵后执行的跳转操作
]]
function AnimDialogControl:showPlotDialogByCurrentOrder(ty)

    --echo("需要跳转的",ty,"==================")

    if ty == 0 or tostring(ty) == "0" then
        --echo("返回六界中")
        self:destoryDialog()
        -- 发送返回六界通知
        EventControler:dispatchEvent(BattleEvent.BATTLEEVENT_ONEXIT_ANIMDIALOGVIEW, {})
        return
    end
    local oriOrder = self.order
    self.order = ty
    self.isAddMissionNpc = nil
    self:showPlotDialogFormMap(self.mapId,self.optionBtCallback,oriOrder)
end




--[[
增加一个传送配置的特效
]]
function AnimDialogControl:addTranslateAni()
    --有可能这个时候 被销毁了
    if not self.order then
        return
    end
    --传送动画的配置
    local transferCfg = self.mapData[tostring(self.order)]["transfer"]

    --dump(transferCfg)


    if transferCfg and #transferCfg>0 then
        for k,v in pairs(transferCfg) do 
            local modelTransfer = AnimModelTransfer.new(self,v)
            self.view:addNewAnimModel(modelTransfer,v.x,v.y)

        end
    end
end


--[[
增加npc对象
npc可以有一些点击事件等
]]
function AnimDialogControl:addNpcObject()
    -- echo("增加npc对象")
    --npc对象的配置Id
    if not self.order then
        echoError("已经被删除了,不需要做这个事了")
        return
    end
    local npcCfgIdArr = self.mapData[tostring(self.order)]["npc"] or ""
    --echoError(npcCfgId,"=================================")
    --dump(npcCfgId)
    -- 创建npc的方法
    local function createNPC(npcId, isBiographyNpc)
        --npc对象的配置
        local npcCfg = self.npcCfg[tostring(npcId)]

        local sourceId = npcCfg["source"]

        local sourceCfg = self.sourceCfg[tostring(sourceId)]

        local spineName = sourceCfg.spine

        --echoError("spineName------------",spineName,"==================")
        local spine = ViewSpine.new(spineName,{},nil,spineName,nil,sourceCfg)   --:addto(ctn):pos(0,-50):zorder(-1)

        local posX = npcCfg.location[1].t
        local posY = npcCfg.location[1].v
        local modelNpc = isBiographyNpc and AnimModelBiographyNPC.new(self,spine,sourceCfg,npcCfg) or AnimModelNPC.new(self,spine,sourceCfg,npcCfg)

        modelNpc:playLabel(Fight.actions.action_stand)
        modelNpc:setPositionForMove(posX, posY)
        
        modelNpc:registerClickEvent()

        self.view:addNewAnimModel(modelNpc,posX,posY)

        if isBiographyNpc then
            modelNpc:setChatIcon(4,0,0)
        end
    end

    local hasBiography,biographyNPC = BiographyControler:checkMapHasBiography(self.mapId,self.order)
    local biographyNPCSource = nil
    -- 创建传记的接引NPC
    if hasBiography then
        biographyNPCSource = self.npcCfg[tostring(biographyNPC)]["source"]
        createNPC(biographyNPC,true)
    end

    local npcIds = string.split(npcCfgIdArr, ";")
    if not empty(npcIds) then
        for k,v in pairs(npcIds) do
            -- echo(v)
            if tostring(v) ~= "" then
                echo("\nv=====", v, self._ringNpcId)
                local sourceId = self.npcCfg[tostring(v)]["source"]
                -- 有同id的情况下不创建
                if sourceId ~= biographyNPCSource then
                    createNPC(v)
                end
            end
        end
    end
end

-- 添加六界轶事NPC
function AnimDialogControl:addMissionNpcObject(npcData)
    self.usedLevels = nil
    if self.isAddMissionNpc then
        return
    end

    self.isAddMissionNpc = true
    self.view:removeAllMissionModel()
    
    local missionType = MissionModel:getMissionType( self.mapId)
    -- echoError("self.mapId == ",self.mapId,".... --missionType -- ",missionType)

    local getLevelIdFunc = function ( num,index )
        local openMissionMapSpace,missionData = MissionModel:getHasOpenMission(self:getSpaceName())
        local missionCfg = FuncMission.getMissionDataById( missionData.id )
        local levels = missionCfg.paramStr1
        local levelNum = table.length(levels)
        if not self.usedLevels then
            self.usedLevels = {}
        end
        local usedLevels = self.usedLevels
        local selectLevel = ""
        local selectId = "10002"
        local selectIndex = 1
        if levelNum > num then
            local canUseLevels = {}
            for i,v in pairs(levels) do
                if not table.isValueIn(usedLevels,v) then
                    table.insert(canUseLevels,v)
                end
            end
            index = math.random(1,table.length(canUseLevels))
            selectLevel = canUseLevels[index]
            for i,v in pairs(levels) do
                if v == selectLevel then
                    selectIndex = i
                end
            end
            selectId = missionCfg.paramStr2[selectIndex]
            table.insert(self.usedLevels,selectLevel)
        elseif levelNum == num then 
            selectLevel = levels[index]
            selectId = missionCfg.paramStr2[index]
            selectIndex = index
        else
            index = math.random(1,table.length(levels))
            selectLevel = levels[index]
            selectId = missionCfg.paramStr2[index]
            selectIndex = index
        end
        -- dump(self.usedLevels, "+++++++++", 5)
        -- echo("_________",selectIndex,selectLevel,selectId)
        return selectIndex,selectId
    end

    if missionType and missionType == FuncMission.MISSIONTYPE.HOUZI then
        for i=1,5 do -- 自己构造
            local _addModelFunc = function (  )
                local sId = "10002"
                local sourceCfg = self.sourceCfg[tostring(sId)]
                local spineName = sourceCfg.spine
                local sp = ViewSpine.new(spineName,{},nil,spineName,nil,sourceCfg)
                local modelNpc = AnimModelMission.new(self,sp,sourceCfg,nil)
                modelNpc:playLabel(Fight.actions.action_stand)
                modelNpc:setMissionIndex( getLevelIdFunc(5) )
                local posX = math.random(-1300,100)
                local posY = math.random(-12,-1) * 20
                self.view:addNewAnimModel(modelNpc,posX,posY)
                modelNpc:setChatIcon(2,0,0,function ( ... )
                    modelNpc:stopAction(  )
                    local x = modelNpc:getPositionX()
                    local y = modelNpc:getPositionY()
                    local index = modelNpc:getMissionIndex()
                    MissionModel:setTarget(sId)
                    self:missionClickTap(x,y,index)
                end)
            end
            -- _addModelFunc()
            self.view:delayCall(_addModelFunc, i/GameVars.GAMEFRAMERATE)
        end
    elseif missionType and missionType == FuncMission.MISSIONTYPE.PVP then   
        for i,v in pairs(npcData) do
            local avatar = tostring(v.avatar)
            -- echo(avatar.."==================")
            local garmentId = ""
            if v.userExt and v.userExt.garmentId then
                garmentId = v.userExt.garmentId
            end
            if FuncGarment.garmentIsFinish( v.garments,garmentId ) then
                garmentId = FuncGarment.DefaultGarmentId
            end
            local sId = FuncGarment.getGarmentSource(garmentId, avatar);
            local sourceCfg = self.sourceCfg[tostring(sId)]
            if not sourceCfg then
                sourceCfg = self.sourceCfg[tostring(1)]
                echoError("未找到对应的sourceid，默认使用男主素颜  皮肤id,avatar == ",garmentId,avatar)
            end
            local charData = CharModel:getCharData()
            local sp = FuncGarment.getSpineViewByAvatarAndGarmentId(avatar, garmentId,true,charData)
            local modelNpc = AnimModelMission.new(self,sp,sourceCfg,nil)
            modelNpc:playLabel(Fight.actions.action_stand)
            local openMissionMapSpace,missionData = MissionModel:getHasOpenMission(self:getSpaceName())
            local missionCfg = FuncMission.getMissionDataById( missionData.id )
            local levels = missionCfg.paramStr1
            modelNpc:setMissionIndex(1)
            local posX = math.random(-1300,100)
            local posY = math.random(-12,-1) * 20
            local _addModelFunc = function (  )
                self.view:addNewAnimModel(modelNpc,posX,posY)
                modelNpc:setChatIcon(2,0,0,function ( ... )
                    MissionModel:setTarget(v._id)
                    local x = modelNpc:getPositionX()
                    local y = modelNpc:getPositionY()
                    modelNpc:stopAction(  )
                    local levelId = modelNpc:getMissionIndex()
                    self:missionClickTap(x,y,levelId,2, v)
                end)
            end
            _addModelFunc()
            -- self.view:delayCall(_addModelFunc, i/GameVars.GAMEFRAMERATE)
        end
    elseif missionType and missionType == FuncMission.MISSIONTYPE.QUEST then
        -- 监听轶事答题的推送
        -- 添加轶事答题NPC
        EventControler:addEventListener("notify_mission_quest_enter_body_5522", self.addMissionQuestNpcEvent, self)
        EventControler:addEventListener("notify_mission_quest_quit_body_5524", self.quitMissionQuestEvent, self)
        EventControler:addEventListener("notify_mission_quest_answer_body_5526", self.missionQuestAnswerEvent, self)
        self.missionQuestNpc = {}
        
    elseif missionType and missionType == FuncMission.MISSIONTYPE.BINGDONG then
        for i=1,5 do -- 自己构造
            local selectIndex ,sourceId = getLevelIdFunc(5)
            local sId = sourceId -- 冰冻 
            local sourceCfg = self.sourceCfg[tostring(sId)]
            local spineName = sourceCfg.spine
            local sp = ViewSpine.new(spineName,{},nil,spineName,nil,sourceCfg)
            
            local modelNpc = AnimModelMission.new(self,sp,sourceCfg,sourceCfg,true)
            FilterTools.setViewFilter(modelNpc,FilterTools.colorMatrix_ice,10)
            modelNpc:playLabel(Fight.actions.action_stand)
            modelNpc:stop()
            modelNpc:setMissionIndex( selectIndex )
            modelNpc:addBingdongEffect(  )
            local posX = math.random(-1300,100)
            local posY = math.random(-12,-1) * 20
            local _addModelFunc = function (  )
                self.view:addNewAnimModel(modelNpc,posX,posY)
                modelNpc:setChatIcon(2,0,0,function ( ... )
                    local x = modelNpc:getPositionX()
                    local y = modelNpc:getPositionY()
                    MissionModel:setTarget(sId)
                    -- modelNpc:stopAction( )
                    local index = modelNpc:getMissionIndex()
                    self:missionClickTap(x,y,index)
                end)
            end
            _addModelFunc()
            -- self.view:delayCall(_addModelFunc, i/GameVars.GAMEFRAMERATE)
        end
    elseif missionType and missionType == FuncMission.MISSIONTYPE.BAOZHA then
        for i=1,5 do -- 自己构造
            local levelIndex ,sourceId = getLevelIdFunc(5,i)
            local sId = sourceId -- 爆炸怪 
            local sourceCfg = self.sourceCfg[tostring(sId)]
            -- local sp = FuncGarment.getSpineViewByAvatarAndGarmentId("104", "",true)
            local spineName = sourceCfg.spine
            local sp = ViewSpine.new(spineName,{},nil,spineName,nil,sourceCfg)
            
            local modelNpc = AnimModelMission.new(self,sp,sourceCfg,nil)
            modelNpc:playLabel(Fight.actions.action_stand)
            modelNpc:setMissionIndex( levelIndex)
            local posX = math.random(-1300,100)
            local posY = math.random(-12,-1) * 20
            local _addModelFunc = function (  )
                self.view:addNewAnimModel(modelNpc,posX,posY)
                modelNpc:setChatIcon(2,0,0,function ( ... )
                    local x = modelNpc:getPositionX()
                    local y = modelNpc:getPositionY()
                    MissionModel:setTarget(sId)
                    modelNpc:stopAction(  )
                    local index = modelNpc:getMissionIndex()
                    self:missionClickTap(x,y,index)
                end)
            end
            _addModelFunc()
            -- self.view:delayCall(_addModelFunc, i/GameVars.GAMEFRAMERATE)
        end
    end
end
-- 添加轶事答题NPC
function AnimDialogControl:addMissionQuestNpcEvent(event)
    if event.error == nil then
        local data = event.params.params.data
        dump(data, "---------===轶事答题添加NPC 推送", 5)
        local num = 0
        for i,v in pairs(self.missionQuestNpc) do
            if v:getModelVisible() then
                num = num + 1
            end
        end
        if num < 9 then
            self:addMissionQuestNpc(data )
        else
            echo("此时有10人正在答题")
        end
        
    end
end
function AnimDialogControl:addMissionQuestNpc(data )
    -- local avatar = tostring(data.avatar)
    -- -- echo(avatar.."==================")
    -- local garmentId = ""
    -- if data.userExt and data.userExt.garmentId then
    --     garmentId = data.userExt.garmentId
    -- end
    dump(data, "---------=yyy------------", 5)
    if not self.missionQuestNpc[data.rid] then
        local garmentId = ""
        if data.userExt and data.userExt.garmentId then
            garmentId = data.userExt.garmentId
        end
        local avatar = data.avatar
        local sId = FuncGarment.getGarmentSource(garmentId, avatar);
        local sourceCfg = self.sourceCfg[tostring(sId)]
        local charData = CharModel:getCharData()
        local sp = FuncGarment.getSpineViewByAvatarAndGarmentId(avatar, garmentId,true,charData)
        local modelNpc = AnimModelMission.new(self,sp,sourceCfg,nil,true)
        modelNpc:setModelVisible( true )
        modelNpc:playLabel(Fight.actions.action_stand)
        modelNpc:setAnimMissionView(self.view)
        self.view:addNewAnimModel(modelNpc,228,-188)
        modelNpc:questAnswerAction( 0 )
        self.missionQuestNpc[data.rid] = modelNpc
    else
        self.missionQuestNpc[data.rid]:setModelVisible( true )
    end
    
    
end
-- 退出轶事答题NPC
function AnimDialogControl:quitMissionQuestEvent(event)
    if event.error == nil then
        local data = event.params
        -- dump(data, "---------===轶事答题删除NPC 推送", 5)
        local rid = data.params.data.rid
        if self.missionQuestNpc[rid] then
            self.missionQuestNpc[rid]:setModelVisible( false )
        end
    end
end
-- 答题广播
function AnimDialogControl:missionQuestAnswerEvent(event)
    if event.error == nil then
        local data = event.params
        dump(data, "PPPPPP-----------轶事答题 广播 推送", 5)
        local rid = data.params.data.rid
        local _type = data.params.data.answer
        if self.missionQuestNpc[rid] then
            self.missionQuestNpc[rid]:questAnswerAction( _type )
        end
    end
end

-- 六界轶事中NPC的点击
function AnimDialogControl:missionClickTap(posX,posY,index,missionType,inforData)
    local autoBody = self.view.moveBody
    local autoX = autoBody:getPositionX()
    local autoY = autoBody:getPositionY()
    local x = 0
    if autoX - posX > 50 then
        x = posX + 75
    elseif autoX - posX < -50 then
        x = posX - 75
    else
        x = posX
    end
    local missionType = MissionModel:getMissionType( self.mapId)
    local openMissionMapSpace,missionData = MissionModel:getHasOpenMission(self:getSpaceName())
    self:moveBodyToPoint(x,posY+50,function ( ... )
        autoBody:playLabel(Fight.actions.action_stand)


        local formationType
        -- 1为打猴子  2为比武   4为琼华封妖  5为天雷绝杀   3为六界答题不进入战斗
        if missionType == 1 then
            formationType = FuncTeamFormation.formation.missionBattleMonkey
        elseif missionType == 2 then
            formationType = FuncTeamFormation.formation.missionBattlePvp
        elseif missionType == 4 then
            formationType = FuncTeamFormation.formation.missionBattleFengYao
        elseif missionType == 5 then
            formationType = FuncTeamFormation.formation.missionBattleTianLei
        end


        local funcTZ = function (  )
            -- local formationType = FuncTeamFormation.formation.missionBattlePvp
            self.selectMissionIndex = index
            
            local params = {}
            if formationType ~= FuncTeamFormation.formation.missionBattlePvp then
                local levelId = FuncMission.getMissionLevelId(missionData.id, self.selectMissionIndex)
                params[formationType] = {
                    raidId = levelId,
                }
            else
                dump(inforData, "\n\ninforData====")
                inforData.isMissionPvp = true
                params = inforData
            end
            
            WindowControler:showWindow("WuXingTeamEmbattleView", formationType, params)
        end
        if missionType and missionType == 2 then
            WindowControler:showWindow("MissionPVPInforView",inforData,funcTZ)
        else
            funcTZ()
        end
    end,true)
end

-- 布阵完成，进入战斗初始化函数
function AnimDialogControl:onTeamFormationComplete(event)
    -- echoError("布阵完成 ，开始初始化战斗信息-----------")
    local params = event.params
    local sysId = params.systemId
    local openMissionMapSpace,missionData = MissionModel:getHasOpenMission(self:getSpaceName())
    if openMissionMapSpace then
        if sysId == FuncTeamFormation.formation.missionBattlePvp 
            or sysId == FuncTeamFormation.formation.missionBattleMonkey 
            or sysId == FuncTeamFormation.formation.missionBattleFengYao 
            or sysId == FuncTeamFormation.formation.missionBattleTianLei then
            local formation = params.formation
            local index = self.selectMissionIndex
            local params = { 
                id = missionData.id,
                target = MissionModel:getTarget(),
                formation = formation,
                missionBattle = {index = index},
            }

            dump(params, "------______0000_______", 6)
            local missionType = FuncMission.getMissionTypeById( missionData.id )
            MissionModel:setDoingMissionId(missionData.id)
            if tonumber(missionType) == FuncMission.MISSIONTYPE.HOUZI then
                MissionServer:requestActive(params,c_func(self.enterBattleCallBack,self))
            elseif tonumber(missionType) == FuncMission.MISSIONTYPE.PVP then
                MissionServer:requestPvpActive(params,c_func(self.enterBattleCallBack,self))
            elseif tonumber(missionType) == FuncMission.MISSIONTYPE.QUEST then
                
            elseif tonumber(missionType) == FuncMission.MISSIONTYPE.BINGDONG then
                MissionServer:requestActive(params,c_func(self.enterBattleCallBack,self))
            elseif tonumber(missionType) == FuncMission.MISSIONTYPE.BAOZHA then
                MissionServer:requestActive(params,c_func(self.enterBattleCallBack,self))
            end
        end
    end
end

function AnimDialogControl:enterBattleCallBack(event)
    if event.result ~= nil then
        self.battleId = event.result.data.battleInfo.battleId
        -- 发送 关闭布阵界面 消息
        EventControler:dispatchEvent(BattleEvent.CLOSE_TEAM_FORMATION_FOR_BATTLE)
        self:destoryView()
        if event.result.data then
            local serviceData = event.result.data.battleInfo
            -- dump(serviceData,"战斗数据=====")
            -- serviceData.battleLabel = GameVars.battleLabels.missionBattlePve
            local battleInfo = BattleControler:turnServerDataToBattleInfo(serviceData)
            BattleControler:startBattleInfo(battleInfo)
            self.isAddMissionNpc = nil           
        else
            echoError("没有数据===")
        end
    end
end

--[[
    打开宝箱
]]
function AnimDialogControl:doOpenExtraBox(openBoxCallBack  )
    -- echoError("self.raidId--------------",self.raidId)
    -- local hasUsedBox = WorldModel:hasUsedExtraBox(self.raidId)
    if self:hasUsedExtraBox() then
        self.openBoxCallBack = openBoxCallBack
        self:doOpenExtraBoxCallBack()
    else
        local isXuzhang = PrologueUtils:showPrologue()
        if isXuzhang then --and not self.getbaoxiang
        -- if true then
            -- self.getbaoxiang = true
            local rewardData = {"1,5003,8", "3,100000","4,200" } --序章 假的奖励
            self.animBoxReward = rewardData
            WindowControler:showTutoralWindow("CompScrollReward", rewardData,openBoxCallBack)
            if self.view then
                self.view:xuzhangBox( )
            end
        else
            WindowControler:showTips(GameConfig.getLanguage("#tid_reward_geted_1"))
            openBoxCallBack()
        end
        -- local rewardData = {"1,5003,4", "3,50000" }
        -- WindowControler:showTutoralWindow("CompScrollReward", rewardData,openBoxCallBack)
    end
end

--剧情额外宝箱
function AnimDialogControl:hasUsedExtraBox()
    if self.animBoxReward then
        return true
    else
        return false
    end
end

--[[
    打开宝箱回调
]]
function AnimDialogControl:doOpenExtraBoxCallBack(  )
    local rewardData = self.animBoxReward
    if table.length(rewardData) > 0 then
         dump(rewardData,"rewardData = = = = = = =")
         local subType_id
         for k,v in pairs(rewardData) do
            local data = string.split(v,",")
            if tonumber(data[1]) == 1 then
                if FuncItem.getItemData(data[2]).subType == 403 then
                    subType_id = FuncItem.getItemData(data[2]).subType_display
                end
            end
         end
         if subType_id ~= nil then
            self.openBoxCallBack()
            if self.view then
                self.view:setForceLock(true)
            end
            WindowControler:showTutoralWindow("MemoryView",subType_id,function()
                if self.view then
                    self.view:setForceLock(false)
                end
            end)
        else
            WindowControler:showTutoralWindow("CompScrollReward", rewardData,self.openBoxCallBack)
        end
    else
        echoError("章节宝箱奖励没配  == ",self.raidId)
        self.openBoxCallBack()
    end
    EventControler:dispatchEvent(WorldEvent.WORLDEVENT_OPEN_EXTRA_BOXES,{raidId = self.raidId})
end

-- 点击屏幕回调 注意点击按钮是否和该事件重叠
function AnimDialogControl:onTouchEvent(step)

end 

function AnimDialogControl:plotInfoCompleteAni()
    self.preAniVer = self.pdata.afterAni or { }
    self.aniIndex = #self.preAniVer or 0
    self.curAniIdx = 1
    self:aniCompleteCallBack()
end 

function AnimDialogControl:playAniView(_enterAni, dir)

end 

function AnimDialogControl:updateFrame(dt)
 
    self:sceneShake()

    if self.plotDialogState == PLOT_DIALOG_STATE.C then

    elseif self.plotDialogState == PLOT_DIALOG_STATE.D then

    end
end 

function AnimDialogControl:destoryView()
     --echo("销毁PlotDilogView=-===================")
    if self.handle ~= nil then
        scheduler.unscheduleGlobal(self.handle)
        self.handle = nil
    end

    -- self.optionBtCallback( { step = - 1, index = - 1 })
    
    if self.view and (not tolua.isnull(self.view) ) then
        self.view:stopAllActions()
        self.view.stopUpdate = true
        self.view:startHide()
        self.view = nil
    end
    self:setIsInWorldMap(false)
end

--在同一地标中再跳转到该地标中调用该方法
function AnimDialogControl:destoryViewAndResetStatus()   
    self:destoryView() 
    self.order = nil
    self.isAddMissionNpc = nil     
end
--获取当前的回调函数
function AnimDialogControl:getOptionBtCallback()
    return self.optionBtCallback
end

--在不同的地标中跳转 调用该方法 传入spacename
function AnimDialogControl:destoryViewByGameType(_spaceName, _type)
    self:destoryView() 
    if _spaceName then
        self.order = nil
        self.isAddMissionNpc = nil
        self.isAgain = nil
        self:doOptionBtCallBack(_spaceName)
        -- if self.optionBtCallback then
        --     self.optionBtCallback(_spaceName)
        -- end
        if _type == FuncCommon.SYSTEM_NAME.MISSION then
            EventControler:dispatchEvent(WorldEvent.WORLDEVENT_ENTER_ONE_MISSION,{spaceName=_spaceName})
        end          
    end      
end

--[[
销毁整个立绘对话框的操作
]]
function AnimDialogControl:destoryDialog(noCallBack)
    self.showMapName = false
    --需要停止所有的动画
    if self.view and (not tolua.isnull(self.view)) then
        self.view:stopAllActions()
    end
    if self.optionBtCallback and ( (not noCallBack) or self.needSkipCallBack) then
        local function overCall()
            self:destoryView()
            -- self.optionBtCallback()
            self:doOptionBtCallBack()
        end
        if self.isBattle then
            self.isBattle = false
            self.view:addAnim2Battle(overCall)
        else
            -- 这一个关卡要强行弹一下充值界面
            -- 10205关卡剧情，非剧情回顾，非战前
            -- 未领取过首充奖励
            if self.raidId 
                and tostring(self.raidId) == "10205" 
                and not self.onlyStory
                and not ActivityFirstRechargeModel:haveGetFirstGift()
            then
                -- 弹充值界面关闭后退出
                WindowControler:setSpWindowRoot("top")
                WindowControler:showWindow("ActivityFirstRechargeView",{closeCall = function()
                    WindowControler:setSpWindowRoot(nil)
                    overCall()
                end})
            else
                -- 在传记任务中，且人物正常完成了(当前没有任务则是完成了)
                if BiographyControler:isInBiograpTask() and not BiographyModel:isHasTaskInHand() then
                    self.view:showBiographyTaskFinish(overCall)
                else
                    overCall()
                end
            end
        end
    else
        self:destoryView()
    end
    EventControler:dispatchEvent(NewLoveEvent.NEWLOVEEVENT_PLOT_FINISHED)
        ---除弹幕界面的事件
    EventControler:dispatchEvent(BarrageEvent.REMOVE_BARRAGE_UI)
    self:clear()
end 
   
-- 震屏
function AnimDialogControl:shake(frame, range, shakeType)

    range = range and range or 2
    frame = frame and frame or 6
    shakeType = shakeType and shakeType or "xy"
    self.shakeInfo = {
        frame = frame,
        shakeType = shakeType
    }
    if shakeType == "x" then
        self.shakeInfo.range = { range, 0 }
    elseif shakeType == "y" then
        self.shakeInfo.range = { 0, range }
    else
        self.shakeInfo.range = { range, range }
    end
    local shakeLayer = WindowControler:getDocLayer()

    if self.oldPos then
        shakeLayer:pos(self.oldPos[1], self.oldPos[1])
    else
        self.oldPos = { shakeLayer:getPosition() }
    end
end

--[[
从当前的代码中看  updateFrame只是执行了震屏操作
执行震屏操作  在 updateFrame中进行更新
在sceneShake中就是每帧刷新屏幕的位置
而且当前的press_skip_button 不可用

]]
function AnimDialogControl:sceneShake()
    if not self.shakeInfo then
        return
    end
    local shakeLayer = WindowControler:getDocLayer()
    self.shakeInfo.frame = self.shakeInfo.frame - 1

    local oldXpos = self.oldPos[1] or 0
    local oldYpos = self.oldPos[2] or 0
    local pianyi =(self.shakeInfo.frame % 2 * 2 - 1)
    echo("----------zhen ping shi jian --------------------------------")
    shakeLayer:pos(oldXpos + pianyi * self.shakeInfo.range[1], oldYpos + pianyi * self.shakeInfo.range[2])

    if self.shakeInfo.frame == 0 then
        self.shakeInfo = nil
        shakeLayer:pos(oldXpos, oldYpos)
        self.oldPos = nil
    end
    if (self.press_skip_button)then
            self.press_skip_button=nil;
            shakeLayer:setPosition(self.originPosition);
    end
end

-- 使用转场
function AnimDialogControl:useChangeEff(changemapEffectType, animName, callBack)
    if self.view then
        self.view:useChangeEff(changemapEffectType, animName, callBack)
    else
        if callBack then callBack() end
    end
end

-- 封装一下跳帧等事件
function AnimDialogControl:getLabelAndFrame()
    if self.view then
        return self.view:getLabelAndFrame()
    end
end

function AnimDialogControl:doJumpFrame(lbl,frame)
    if self.view then
        self.view:doJumpFrame(lbl, frame)
    end
end

function AnimDialogControl:setCanScroll(flag)
    self.canScroll = flag
end

function AnimDialogControl:isCanScroll()
    return self.canScroll
end

function AnimDialogControl:clear()
    --销毁事件
    EventControler:clearOneObjEvent( self )
    self.order = nil
    self.usedLevels = nil
    self.isAddMissionNpc = nil
    self.showMapComplete = nil
    self.animBoxReward = nil
    self.isAgain = nil
end 

function AnimDialogControl:setIsMovingToSpace(_boolean)
    self.isMovingToSpace = _boolean
end

function AnimDialogControl:getIsMovingToSpace()
    return self.isMovingToSpace
end

function AnimDialogControl:disabledUIClick()
    if self.view then
        self.view:disabledUIClick()
    end
end

function AnimDialogControl:resumeUIClick()
    if self.view then
        self.view:resumeUIClick()
    end
end

function AnimDialogControl:doOptionBtCallBack(params  )
    local func = self.optionBtCallback
    self.optionBtCallback = nil
    if func then
        func(params)
    end
end


return AnimDialogControl 
