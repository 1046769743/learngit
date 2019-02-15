local MissionQuestView = class("MissionQuestView", UIBase)

function MissionQuestView:ctor(winName)
	MissionQuestView.super.ctor(self, winName)
end
function MissionQuestView:setAlignment()
    --设置对齐方式
end

function MissionQuestView:registerEvent()
    MissionQuestView.super.registerEvent();

end

function MissionQuestView:loadUIComplete()
    self:registerEvent()
    self.aaa = {}
end
function MissionQuestView:initData()
    local missionData = self.parentView.missionData
    local questData = MissionModel:getMissionQuest(missionData)
    self.currentQuestId = questData.id
    self.totalTime = 15
    self.currentFrame = 0
    self.currentMiao = 0
    self.jiesuanMiao = 0
    self.timerSwitch = false
end

function MissionQuestView:setParent( parent )
    self.parentView = parent
end
function MissionQuestView:updateUI()
    self:refreshScoreAndQuest( )
    local missionData = self.parentView.missionData
    -- 开启倒计时
    local time1 = MissionModel:getTimeShow( missionData )
    if time1 > 0 then
        self.timerSwitch = true
    else
        self.timerSwitch = false
    end
    self.totalTime = time1
    self.panel_ti.txt_time:setString(self.totalTime)
    self.handle = self:scheduleUpdateWithPriorityLua(c_func(self.updateFrame,self), 0)
    
end
function MissionQuestView:refreshScoreAndQuest( )
    local questData = FuncMission.getMissionQuestById( self.currentQuestId )
    -- 问题
    local questTxt = GameConfig.getLanguage(questData.name1)
    self.panel_ti.txt_1:setString(questTxt)
    -- 答案
    local missionData = self.parentView.missionData
    local randSeed = MissionModel:getRandomSeed( missionData )
    math.randomseed(randSeed)
    table.insert(self.aaa, randSeed)
    local answerIndex = math.random(1,30) -- 随机出左边是否是正确答案
    local zuoTxt = ""
    local youTxt = ""
    self.rightAnswer = "zuo"
    if answerIndex >= 15 then
        zuoTxt = GameConfig.getLanguage(questData.name2)
        youTxt = GameConfig.getLanguage(questData.name3)
        self.rightAnswer = "zuo"
        echo("左边是正确答案")
    else
        zuoTxt = GameConfig.getLanguage(questData.name3)
        youTxt = GameConfig.getLanguage(questData.name2)
        self.rightAnswer = "you"
        echo("右边是正确答案")
    end
    self.panel_ti.txt_2:setString(GameConfig.getLanguage("#tid_mission_007")..zuoTxt) 
    self.panel_ti.txt_3:setString(GameConfig.getLanguage("#tid_mission_008")..youTxt)
    

    -- 积分
    self.panel_jifen:visible(false)
    -- local missionData = self.parentView.missionData
    -- local score = MissionModel:getAllMissionQuestScore()
    -- self.panel_jifen.txt_2:setString("得分:"..score)

    -- local allAnswerNum = MissionModel:getMissionQuestNum()
    -- local rightNum = MissionModel:getMissionQuestRightNum()
    -- self.panel_jifen.txt_3:setString("答对:"..rightNum.." 答错:"..(allAnswerNum - rightNum))

    self.panel_ti.txt_time:setString(self.totalTime)
end
-- 倒计时
function MissionQuestView:updateFrame( )
    local missionData = self.parentView.missionData
    local lastTime = MissionModel:getTimeShow( missionData )
    if lastTime > 0 then
        self.timerSwitch = true
    end
    if self.timerSwitch then
        self.currentFrame = self.currentFrame + 1
        if self.currentFrame == GameVars.GAMEFRAMERATE then 
            self.currentFrame = 0
            
            self.currentMiao = lastTime
            if not self.timerPosSwitch then
                self.jiesuanMiao = self.jiesuanMiao + 1
            end
            self.panel_ti.txt_time:setString(lastTime)
            if lastTime == 0 then
                self.currentFrame = 0
                self.currentMiao = 0
                self.jiesuanMiao = 0
                self.timerSwitch = false
                -- 开始结算
                self:jiesuan(true)
            else
                -- echo("--------------------------",self.jiesuanMiao)
                if self.jiesuanMiao >= 5 or true then
                    self.jiesuanMiao = 0
                    self:jiesuan(false)
                end
            end
        end
    else
        self.currentFrame = 0
    end
end
function MissionQuestView:checkCurrentAnswer( )
    return self:checkBodyAnswer(self.parentView.moveBody) 
end

-- 判断是否在椭圆内
function MissionQuestView:checkoutInTuoyuan( pos )
    -- 两个焦点
    local a = {x = 40,y = -83}
    local b = {x = 426,y = -83}
    -- 长轴
    local c = 406

    local lineDis = function (pos1,pos2 )
        local x = pos1.x - pos2.x
        local y = pos1.y - pos2.y
        local dis = math.sqrt(x*x + y*y)
        return dis
    end
    local dis = lineDis(pos,a) + lineDis(pos,b)
    if dis >= c then
        return false
    else
        return true
    end
end

function MissionQuestView:checkBodyAnswer( body )
    if not body then
        return -1,0
    end
    local bodyPosX,bodyPosY = self.parentView:autoMoveBodyPos()
    local panelZuo = self.panel_zuo
    local panelYou = self.panel_you
    local zuoPoint = body:convertLocalToNodeLocalPos(panelZuo,cc.p(0,0))
    local youPoint = body:convertLocalToNodeLocalPos(panelYou,cc.p(0,0))

    local isInZuo = self:checkoutInTuoyuan( zuoPoint )
    local isInYou = self:checkoutInTuoyuan( youPoint )

    local result = -1
    local questPos = -1
    if isInZuo then
        if self.rightAnswer == "zuo" then
            result = 1
        else
            result = 0
        end
        questPos = 1
    elseif isInYou then
        if self.rightAnswer == "you" then
            result = 1
        else
            result = 0
        end
        questPos = 2
    else
        result = -1
        questPos = 0
    end

    return result,questPos
end


function MissionQuestView:jiesuan(isJiesuan)
    local result,questPos = self:checkCurrentAnswer( )
    local missionId = self.parentView.missionData.id
    local questRight
    if result == 1 then
        questRight = true
    else
        questRight = false
    end
    local params
    local currentTime = TimeControler:getServerTime()
    if isJiesuan then
        if result >= 0 then
            self.questRight = result
            params = {answer = questPos,correct = result,id = missionId}
            
            echo("=====提交结算=============",currentTime)
            MissionServer:tijiaoQuestActive( params, c_func(self.tijiaoQuestCallBack,self) )
        else
            self:finishQuestTime(5)
        end
        self:otherModelJiesuan( )
    else
        if self.questPos == nil or self.questPos ~= questPos then
            echo("self.questRight ~= questRight",self.questPos, questPos)
            self.questPos = questPos
            params = {answer = questPos,correct = -1,id = missionId}
            self.timerPosSwitch = true
            MissionServer:tijiaoQuestActive( params, c_func(self.tijiaoQuestPosCallBack,self))
        end 
    end
end
-- 其他玩家答题
function MissionQuestView:otherModelJiesuan( )
    local missionQuestNpc = self.parentView.controler.missionQuestNpc
    echo("\n\n ----其他玩家的数量---",table.length(missionQuestNpc))
    for i,v in pairs(missionQuestNpc) do
        local _,posType = self:checkBodyAnswer(v)
        echo("posType ,self.rightAnswer ==== ",posType ,self.rightAnswer)
        if self.rightAnswer == "zuo" then
            if posType == 1 then
                --答对
                v:setEmoi("aimu01")
            elseif posType == 2 then
                --答错
                v:setEmoi("wuyun")
            end
        elseif self.rightAnswer == "you" then
            if posType == 1 then
                --答错
                v:setEmoi("wuyun")
            elseif posType == 2 then
                --答对
                v:setEmoi("aimu01")
            end
        end
    end
end

-- 倒计时结束
function MissionQuestView:finishQuestTime( delayTime )
    self:delayCall(function ( ... )
        self.timerSwitch = true
        self:initData()
        self:updateUI()
    end,delayTime)
end
function MissionQuestView:tijiaoQuestCallBack(event)
    if event.result then
        -- echo("-------jiludati============",self.questRight)
        -- dump(event.result,"--------------",8)
        local missionData = self.parentView.missionData
        MissionModel:addMissionQuestNum(missionData.startTime)
        if self.questRight > 0 then
            MissionModel:addMissionQuestRightNum(missionData.startTime)
            self.parentView.moveBody:setEmoi("aimu01")
        else
            self.parentView.moveBody:setEmoi("wuyun")
        end
        self:finishQuestTime( 5 )
        
        local index = event.result.data.index
        if index >= 0 then
            WindowControler:showTutoralWindow("MissionRewardView", index,missionData.id)
            -- 关闭答题
            EventControler:dispatchEvent(MissionEvent.CLOSE_MISSION_QUEST_VIEW)
        end
        EventControler:dispatchEvent(MissionEvent.MISSIONUI_REFRESH_DATI_NUM)
         
    else
        if event.error.code == 551901 then
            echo("答题间隔小于5秒")
        elseif event.error.code == 551701 then
            self.parentView:doExitBack1()
        elseif event.error.code == 551702 then
        end
        self:finishQuestTime( 5 )
    end
end

function MissionQuestView:tijiaoQuestPosCallBack(event)
    self.timerPosSwitch = false
end

function MissionQuestView:onBtnBackTap()
    self:startHide()
end

function MissionQuestView:initQuyu(  )
    local mainNode = self.parentView.mainNode
    local off = 80
    local panelZuoPos = self.panel_zuo:convertLocalToNodeLocalPos(mainNode,cc.p(0,0))
    self.zuoMin = panelZuoPos.x + off
    self.zuoMax = panelZuoPos.x + 465 -off

    local panelYouPos = self.panel_you:convertLocalToNodeLocalPos(mainNode,cc.p(0,0))
    self.youMin = panelYouPos.x + off
    self.youMax = panelYouPos.x + 465 -off

    self.gaoMin = panelZuoPos.y - 167 + off
    self.gaoMax = panelZuoPos.y - off

    local posT = {}
    posT["zuo"] = {x1 = self.zuoMin,x2 = self.zuoMax}
    posT["you"] = {x1 = self.youMin,x2 = self.youMax}
    posT["gao"] = {y1 = self.gaoMin,y2 = self.gaoMax}
    return posT
end


return MissionQuestView
