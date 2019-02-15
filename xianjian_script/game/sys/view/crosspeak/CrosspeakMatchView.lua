local CrosspeakMatchView = class("CrosspeakMatchView", UIBase)
local TipsTable = {
    [1] = "#tid_crosspeak_teasing_4001",
    [2] = "#tid_crosspeak_teasing_4002",
    [3] = "#tid_crosspeak_teasing_4003",
    [4] = "#tid_crosspeak_teasing_4004",
    [5] = "#tid_crosspeak_teasing_4005",
    [6] = "#tid_crosspeak_teasing_4006",
    [7] = "#tid_crosspeak_teasing_4007",
}
local lihuiScale = 0.7
local lihuiOffsetX = 0
function CrosspeakMatchView:ctor(winName,_type,data)
	CrosspeakMatchView.super.ctor(self, winName)
    self.matchType = _type or FuncCrosspeak.MATCHTYPE.MATCHTYPEING
    self.data = data
end
function CrosspeakMatchView:setAlignment()
    --设置对齐方式
end

function CrosspeakMatchView:registerEvent()
    CrosspeakMatchView.super.registerEvent();
    -- self:registClickClose("out")


    -- 匹配成功消息
    EventControler:addEventListener(CrossPeakEvent.CROSSPEAK_MATCH_SUCCEED_EVENT,self.matchSucceed, self);
    -- 匹配失败消息
    EventControler:addEventListener(CrossPeakEvent.CROSSPEAK_MATCH_FAILED_EVENT,self.matchFailed, self);
    -- 战斗资源加载完
    -- EventControler:addEventListener(LoadEvent.LOADEVENT_BATTLELOADCOMP,self.loadingDRAction, self);
    -- EventControler:addEventListener(LoadEvent.LOADEVENT_BATTLELOADCOMP,self.loadingMyAction, self);
    -- EventControler:addEventListener(LoadEvent.LOADEVENT_USERCOMPLETE,self.loadingMyAction, self);
    -- 仙界对决选牌开始
    FightEvent:addEventListener(BattleEvent.BATTLEEVENT_ENTER_CROSSPEAK_BATTLE,self.loadingMyAction, self);
    
    --断网处理
    EventControler:addEventListener(CrossPeakEvent.CROSSPEAK_CLOSE_MATCH_UI_EVENT,self.serverClose, self);
end

function CrosspeakMatchView:setMatchType()
    
end
function CrosspeakMatchView:loadingFinish(event)
    local data = event.params.result
    echo("------CrosspeakMatchView:loadingFinish-----------")
    -- dump(event.params,"============",4)
    if data == 1 then
        self:closeUI( )
    else
        echo("--------------44444444444444--------------")
    end 

end

function CrosspeakMatchView:loadUIComplete()
    self:registerEvent()
    if self.matchType == FuncCrosspeak.MATCHTYPE.MATCHTYPEING then
        self:initUI()
        self.btn_qx:visible(true)
    elseif self.matchType == FuncCrosspeak.MATCHTYPE.LOADING then
        self:updateUI(self.data)
        self.btn_qx:visible(false)
    end
    self.btn_qx:setTap(c_func(self.quxiaoMatch,self))

    self.panel_1.panel_zongpower:visible(false)
    self.panel_2.panel_zongpower:visible(false)
end
function CrosspeakMatchView:initUI( )

    self.mc_zbks:showFrame(1)

    -- 主角自己
    -- 立绘
    local avatar = UserModel:avatar()
    local garmentID = GarmentModel:getOnGarmentId()
    local charSp = self:makeLihui( avatar,garmentID,true,true )  
    self.ctn_2:removeAllChildren()
    self.ctn_2:addChild(charSp)

    --主角名字
    local name = UserModel:name()
    self.panel_2.txt_name:setString(name)
    --服务器名
    local sname = LoginControler:getServerName()
    local smark = LoginControler:getServerMark()
    self.panel_2.txt_fwq:setString("【"..string.format("%s%s", smark, sname).."】")
    --战力
    local charPower = TeamFormationModel:getTempAbility(FuncTeamFormation.formation.crossPeak)
    self.panel_2.panel_zongpower.UI_number:setPower(charPower)
    -- 主角段位
    self.mc_wz2:showFrame(1)
    local zpanel2 = self.mc_wz2.currentView.panel_g2
    local currentSegmentId = CrossPeakModel:getCurrentSegment()
	local currentScore = CrossPeakModel:getCurrentScore()
	local segmentIcon = FuncCrosspeak.getSegmentIcon( currentSegmentId )
	zpanel2.txt_1:setString(currentScore)
	local iconPath = FuncRes.crossSegmentIcon( segmentIcon )
	local icon = display.newSprite(iconPath)
    zpanel2.ctn_1:removeAllChildren()
    zpanel2.ctn_1:addChild(icon)
    icon:scale(0.5)

    -- 对方的信息
    -- 立绘
    local avatar1 = UserModel:avatar()
    local garmentID1 = "" -- 暂时没有皮肤
    local charSp1 = self:makeLihui( avatar1,garmentID1,false,false )  
    self.ctn_1:removeAllChildren()
    self.ctn_1:addChild(charSp1)

    -- 隐藏信息
    self.panel_1:visible(false)
    -- 段位信息
    self.mc_wz1:showFrame(1)
    local epanel1 = self.mc_wz1.currentView.panel_g1
    local currentSegmentId1 = CrossPeakModel:getCurrentSegment()
	local segmentIcon1 = FuncCrosspeak.getSegmentIcon( currentSegmentId1 )
	epanel1.txt_1:setString("????")
	local iconPath1 = FuncRes.crossSegmentIcon( segmentIcon1 )
	local icon1 = display.newSprite(iconPath1)
    epanel1.ctn_1:removeAllChildren()
    epanel1.ctn_1:addChild(icon1)
    FilterTools.setGrayFilter(icon1);
    icon1:scale(0.5)
    self.time = 0
    self.addTime = 0.5
    self:delayCall(c_func(self.matchAction,self),self.addTime)
    self.startMatchT = 0;
    self.mc_zbks.currentView.txt_1:setString(GameConfig.getLanguage("#tid_crosspeak_017").."0 S") 
    -- self:scheduleUpdateWithPriorityLua(c_func(self.updateTime,self), 0)
    self.panel_xh:visible(true)
    self:tipsAction( )
    self:delayCall(c_func(self.tipsAction,self),1.5)
end
-- 开始模拟匹配
function CrosspeakMatchView:matchAction( )
    -- 对手立绘
    -- 随机男女 -- 随机时装
    local avatar1 = "101"
    local garmentID1 = ""
    math.randomseed(os.time())
    local avatarIndex = math.random(1,2)
    if avatarIndex == 1 then
        avatar1 = "101"
    elseif avatarIndex == 2 then
        avatar1 = "104"
    end
    if self.matchAvatar == avatar1 and avatar1 == "101" then
        avatar1 = "104"
    elseif self.matchAvatar == avatar1 and avatar1 == "104" then
        avatar1 = "101"
    end

    local garmData = FuncGarment.getAllGarmentByAvatar(avatar1)
    local garmentIndex = math.random(1,#garmData)

    garmentID1 = garmData[garmentIndex].id

    
    local charSp1 = self:makeLihui( avatar1,garmentID1,false,false )  
    self.ctn_1:removeAllChildren()
    self.ctn_1:addChild(charSp1)

    self.matchAvatar = avatar1
    -- 隐藏信息
    self.panel_1:visible(false)

    -- 段位信息
    self.mc_wz1:showFrame(1)
    local epanel1 = self.mc_wz1.currentView.panel_g1

    local segmentIndex = math.random(1,FuncCrosspeak.getAllSegmentNum( ))

    local currentSegmentId1 = tostring(segmentIndex)
    local segmentIcon1 = FuncCrosspeak.getSegmentIcon( currentSegmentId1 )
    epanel1.txt_1:setString("????")
    local iconPath1 = FuncRes.crossSegmentIcon( segmentIcon1 )
    local icon1 = display.newSprite(iconPath1)
    epanel1.ctn_1:removeAllChildren()
    epanel1.ctn_1:addChild(icon1)
    icon1:setScale(0.5)
    FilterTools.setGrayFilter(icon1);


    self:delayCall(c_func(self.matchAction,self),self.addTime)
    self:updateTime()
end
-- 取消匹配
function CrosspeakMatchView:quxiaoMatch(  )
    CrossPeakServer:quxiaoMatchServer(function(  )
        self:closeUI()
    end)
end
function CrosspeakMatchView:quxiaoMatchCallBack( event )
    if event.error then
        self:closeUI()
    end
end
-- 提示
function CrosspeakMatchView:tipsAction( )
    math.randomseed(os.time())
    local _index = math.random(1,6)

    local tipsStr = GameConfig.getLanguage(TipsTable[_index])  
    self.panel_xh.txt_1:setString(tipsStr)
    self:delayCall(c_func(self.tipsAction,self),1.5)
end


-- 计时开始
function CrosspeakMatchView:updateTime()
    if self.matchType == FuncCrosspeak.MATCHTYPE.MATCHTYPEING  then
        self.startMatchT = self.startMatchT + self.addTime
        local miao= math.floor(self.startMatchT)
        self.mc_zbks.currentView.txt_1:setString(GameConfig.getLanguage("#tid_crosspeak_017")..miao.." S")
        local maxTime = FuncDataSetting.getCrosspeakMatchMaxTime() + 1
        if miao >= maxTime then
            --todo
            self:closeUI( )
            WindowControler:showTips(GameConfig.getLanguage("#tid_crosspeak_tips_2028"))
        end
    end 
end
function CrosspeakMatchView:requestCloseUICallBack( event )
    -- body
end

function CrosspeakMatchView:matchSucceed(event)
    if self.matchType == FuncCrosspeak.MATCHTYPE.MATCHTYPEING then
        self:closeUI()
    end
end
function CrosspeakMatchView:matchFailed(event)
    WindowControler:showTips(GameConfig.getLanguage("#tid_crosspeak_003"))
    self:closeUI()
end

function CrosspeakMatchView:updateUI(data)
    -- 进战斗之前的loading
    self.mc_zbks:showFrame(2)
    -- 对方玩家信息显示
    local enemyData = data
    -- 名字、立绘、时装、积分、段位、战力
    local rName,rAvatar,rGarmentId,rScore,rSeg
    if data.userBattleType == Fight.battle_type_robot then
        local robotData = FuncCrosspeak.getRobotDataById(data.rid)
        rName = GameConfig.getLanguage(robotData.robotName)
        rAvatar = robotData.avatar
        rGarmentId = "" --这个地方貌似有问题
        rScore = robotData.score
        rSeg = FuncCrosspeak.getCurrentSegment(rScore)
    else
        rName = enemyData.name
        rAvatar = enemyData.avatar
        rGarmentId = enemyData.userExt.garmentId
        rSeg = enemyData.crossPeak.currSegment
        rScore = enemyData.crossPeak.score
    end

    -------对手---------
    -- 立绘
    local charSp = self:makeLihui(rAvatar,rGarmentId,false,true)
    self.ctn_1:removeAllChildren()
    self.ctn_1:addChild(charSp)
    --段位
    self.mc_wz1:showFrame(2)
    local epanel1 = self.mc_wz1.currentView.panel_g1
    local segmentIcon = FuncCrosspeak.getSegmentIcon( rSeg )
    epanel1.txt_1:setString(rScore)
    local iconPath = FuncRes.crossSegmentIcon( segmentIcon )
    local icon = display.newSprite(iconPath)
    epanel1.ctn_1:removeAllChildren()
    epanel1.ctn_1:addChild(icon)
    icon:setScale(0.5)

    self.panel_1:visible(true)
    --主角名字
    self.panel_1.txt_name:setString(rName)
    --服务器名
    local sname = LoginControler:getServerName()
    local smark = LoginControler:getServerMark()
    self.panel_1.txt_fwq:setString("【"..string.format("%s%s", smark, sname).."】")
    --战力
    self.panel_1.panel_zongpower.UI_number:visible(false)--战力不再需要了
    -- self.panel_1.panel_zongpower.UI_number:setPower(rAbility)

    -------主角---------
     -- 主角自己
    -- 立绘
    local avatar1 = UserModel:avatar()
    local zgarmentID = GarmentModel:getOnGarmentId()
    local charSp = self:makeLihui(avatar1,zgarmentID,true,true)  
    self.ctn_2:removeAllChildren()
    self.ctn_2:addChild(charSp)

    --主角名字
    local name = UserModel:name()
    self.panel_2.txt_name:setString(name)
    --服务器名
    local sname = LoginControler:getServerName()
    local smark = LoginControler:getServerMark()
    self.panel_2.txt_fwq:setString("【"..string.format("%s%s", smark, sname).."】")
    --战力
    self.panel_2.panel_zongpower.UI_number:visible(false)
    -- local charPower = TeamFormationModel:getTempAbility(FuncTeamFormation.formation.crossPeak)
    -- self.panel_2.panel_zongpower.UI_number:setPower(charPower)
    -- 段位
    self.mc_wz2:showFrame(2)
    local zpanel2 = self.mc_wz2.currentView.panel_g2
    local currentSegmentId = CrossPeakModel:getCurrentSegment()
    local currentScore = CrossPeakModel:getCurrentScore()
    local segmentIcon = FuncCrosspeak.getSegmentIcon( currentSegmentId )
    zpanel2.txt_1:setString(currentScore)
    local iconPath = FuncRes.crossSegmentIcon( segmentIcon )
    local icon = display.newSprite(iconPath)
    zpanel2.ctn_1:removeAllChildren()
    zpanel2.ctn_1:addChild(icon)
    icon:scale(0.5)

    self:loadingMyAction( )
    self:loadingDRAction( )

    self.panel_xh:visible(false)
end

function CrosspeakMatchView:loadingMyAction( event )
    -- 自己的
    echo("------------自己的资源进度----------------------")
    self.mc_wz2:showFrame(2)
    local myLoadPanel = self.mc_wz2.currentView.panel_progress
    myLoadPanel.progress_1:setPercent(0)
    myLoadPanel.txt_1:setString("0%")
    self:loadingAction(myLoadPanel,90,event )
end
function CrosspeakMatchView:loadingDRAction( event )
    echo("------------敌人的资源进度----------------------")
    self.mc_wz1:showFrame(2)
    local loadPanel = self.mc_wz1.currentView.panel_progress
    loadPanel.progress_1:setPercent(0)
    loadPanel.txt_1:setString("0%")
    self:loadingAction(loadPanel,100,nil )
end
function CrosspeakMatchView:loadingAction(loadPanel,persent,data )
    local _persent = persent
    math.randomseed(os.time())
    local offSet = math.random(1,10)
    local _time = 0.5 + offSet

    if data and data.params then
        local result = data.params.result
        if result == 1 then
            _persent = 100
            _time = 0.1
            self:delayCall(c_func(self.closeUI,self),0.2)
        end
    end
    local updateFunc = function (  )
        local per = loadPanel.progress_1:getPercent()
        per = math.ceil(per)
        loadPanel.txt_1:setString(per.."%")
    end
    self:updatePerFunc( loadPanel,_persent)
    loadPanel.progress_1:tweenToPercent(_persent,_time*10,updateFunc)
end
function CrosspeakMatchView:updatePerFunc( loadPanel,persent)
    local per = loadPanel.progress_1:getPercent()
    per = math.ceil(per)
    loadPanel.txt_1:setString(per.."%")
    if per < persent then
        self:delayCall(c_func(self.updatePerFunc,self,loadPanel,persent),0.05)
    end
end

function CrosspeakMatchView:makeLihui( avatar,garmentID,isZhujue,isShow )
    local charSp = FuncPartner.getPartnerOrCgarLiHui(avatar,garmentID,"ui")
    local offsetS1 = 1
    local offsetX1 = 0
    if FuncGarment.isDefaultGarmentId(garmentID) then
        if isZhujue then
            offsetS1 = -1
            offsetX1 = -lihuiOffsetX
        else
            offsetS1 = 1
            offsetX1 = lihuiOffsetX*2
        end
    else
        if not isZhujue then
            offsetS1 = -1
            offsetX1 = lihuiOffsetX*1
        end
    end

    charSp:setScaleX(lihuiScale*offsetS1)
    charSp:setScaleY(lihuiScale)
    if isZhujue then
        charSp:setPositionX(-50)
    else
        charSp:setPositionX(50)
    end
    if isShow then
        FilterTools.clearFilter(charSp);
    else
        FilterTools.setGrayFilter(charSp);
    end
    -- local kuan = 870
    -- if isZhujue then
    --     kuan = 750
    -- end
    local maskNode = FuncRes.a_white( 870,500)
    maskNode:anchor(0.5,0)
    local spritesico = FuncCommUI.getMaskCan(maskNode,charSp)

    return spritesico
end

function CrosspeakMatchView:serverClose(event )
    self:startHide()
end

function CrosspeakMatchView:closeUI( )
    self:startHide()
end

return CrosspeakMatchView
