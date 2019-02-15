--
-- Author: ZhangYanguang
-- Date: 2016-06-12
-- 战斗loading控制器


local BattleLoadingControler = BattleLoadingControler or {}

BattleLoadingControler.battleLoadingType = {
	LOADING_TYPE_PVE = 1,
	LOADING_TYPE_GVE = 2,
}

function BattleLoadingControler:init()
	-- loading 全部加载完毕
    EventControler:addEventListener(LoadEvent.LOADEVENT_BATTLELOADCOMP,self.loadAllUsersComplete,self)
end

function BattleLoadingControler:showBattleLoadingView(loadingId,sigleFlag,gameType)
	self.loadingId = loadingId
	self.loadingType = self.battleLoadingType.LOADING_TYPE_PVE
    self.gameType = gameType
    
    echo("\n\nloadingId==",loadingId,"sigleFlag==",sigleFlag, "gameType==", gameType, "====加载界面")
    --默认为单人
    if sigleFlag ~=2 then
        sigleFlag =1
    end
    self.sigleFlag= sigleFlag
    if sigleFlag == 1 then
        echo("展示单人战斗loadingView--------------")

        self:showPVEBattleLoadingView()
    end

end

-- PVE单机战斗loading
function BattleLoadingControler:showPVEBattleLoadingView()
	
    local initPercent = RandomControl.getOneRandomInt(10, 25)
    local initTweenPercentInfo = {percent = initPercent,frame=20}

    local leftPercent = 100 - initPercent - 10
    local actionFuncs = {percent=leftPercent, frame = 100, action = nil}

    local processActions = {actionFuncs}

    self.loadingView =  nil

    if BattleControler._battleInfo.withStory then
        -- 告知战斗加载完不要开始
        BattleControler:setWaitLoadingAni(true)
        -- 层级需要高于弹幕
        self.loadingView = WindowControler:showTopWindow("RaidLoadingView",BattleControler._battleInfo.raidId)
    else
        local loadingNumber = NewLoadingControler:getLoadingNumberByTypeAndLevelId(self.gameType, false, self.loadingId)
        echo("\n\nloadingNumber====", loadingNumber)
        self.loadingView = WindowControler:showTopWindow("CompNewLoading", loadingNumber, initTweenPercentInfo, processActions)
        -- self.loadingView = WindowControler:showBattleWindow("CompLoading",initTweenPercentInfo, processActions)
    end
end

-- loading全部加载完成
function BattleLoadingControler:loadAllUsersComplete(data)
    -- if BattleControler.__gameMode == Fight.gameMode_pvp then
    --     return
    -- end
    --声音播放的位置修改
    echo("开始播放声音")
    AudioModel:setCacheMusic(AudioModel:getCurrentMusic())
    

    if self.loadingView == nil or tolua.isnull(self.loadingView) then
        --echo("收到事件  但是    不处理--------")
        return 
    end


    --echo("BattleLoadingControler:loadAllUsersComplete-------------------------")
    dump(data.params)
	if data.params ~= nil then
        local result = data.params.result
        if result ~= nil and tonumber(result) == 1 then
        	-- 单机loading
            --if self.sigleFlag==1 self.loadingType == self.battleLoadingType.LOADING_TYPE_PVE then
            echo("self.sigleFlag == ",self.sigleFlag)
            if self.sigleFlag==1 and ( not BattleControler._battleInfo.withStory ) then
				local loadingCompleteCallBack = function()
                    --echoError("-----关闭loadingView")
					self.loadingView:startHide()
                    self.loadingType = nil
                    self.loadingView = nil
				end

				delayFrame = 0.2 * GameVars.GAMEFRAMERATE
				self.loadingView:finishLoading(delayFrame,c_func(loadingCompleteCallBack))
            elseif self.sigleFlag == 1 and BattleControler._battleInfo.withStory then
                    --echo("执行关闭方法=------------")
                    self.loadingView:loadComplete() -- 通知加载完毕
                    self.loadingType = nil
                    self.loadingView = nil
			end
        else
            WindowControler:showTips(GameConfig.getLanguage("#tid_battle_loading_1"))
        end
    else
        echoError("全部加载完成,没有收到参数")
        -- self:closeLoadingView()
        self.loadingView:startHide()
        self.loadingType = nil
        self.loadingView = nil


    end    



    
end

BattleLoadingControler:init()

return BattleLoadingControler