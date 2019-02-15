local MissionMainView = class("MissionMainView", UIBase)

function MissionMainView:ctor(winName)
	MissionMainView.super.ctor(self, winName)
end

function MissionMainView:setAlignment()
    --设置对齐方式
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back, UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_title, UIAlignTypes.LeftTop);
end

function MissionMainView:registerEvent()
    MissionMainView.super.registerEvent();
    
    self.btn_back:setTap(c_func(self.onBtnBackTap, self));
    self.UI_1.btn_1:visible(false)
    self.btn_left:setTap(c_func(self.onBtnMoveTap, self,-1));
    self.btn_right:setTap(c_func(self.onBtnMoveTap, self,1));
    self:registClickClose()
    self:registClickClose("out");

    EventControler:addEventListener(MissionEvent.MISSIONUI_REFRESH,self.updateUI,self);
    EventControler:addEventListener(MissionEvent.BOX_REFRENSH,self.updateBox,self)
end

function MissionMainView:onBtnMoveTap( moveType )
    local totalNum = #self.missionDatas
    local index = self.selectIndex + moveType
    if index < 1 or index > totalNum then
        return
    end
    self.selectIndex = index
    self.list:gotoTargetPos(index,1,0,0.3)
    self:selectKuang()
    self:updateReward()
    self:updateMissionJindu()
end

function MissionMainView:loadUIComplete()
    self:setAlignment()
    self:registerEvent()
    -- 任务列表数据
    self.missionDatas = MissionModel:getMissionData()
    self.selectIndex = MissionModel:getMissionPosition( )
    self:initUI( )
    self.currentFrame = 0
    self.frame = 0
    self:scheduleUpdateWithPriorityLua(c_func(self.updateFrame,self), 0)
end

function MissionMainView:updateUI()
    self.missionDatas = MissionModel:getMissionData()
    self.selectIndex = MissionModel:getMissionPosition( )

    self.list = self.scroll_1
    self.missionPanel = self.panel_renx


    self:initList()
    self.list:refreshCellView(1)
    self:updateBox()
    self:updateReward()
    self:updateMissionJindu()
end

function MissionMainView:initUI( )
    self.list = self.scroll_1
    self.missionPanel = self.panel_renx
    self.UI_1.txt_1:visible(false)
    self.UI_1.panel_1:visible(false)

    self:initList()
    self:updateBox()
    self:updateReward()
    self:updateMissionJindu()
end

function MissionMainView:initList()
    local itemPanel = self.missionPanel
    itemPanel:visible(false)
    local createItemFunc = function ( itemData )
        local view = UIBaseDef:cloneOneView(itemPanel)
        self:updateItem(view, itemData)
        return view
    end
    local updateCellFunc = function (itemData, view)
        self:updateItem(view, itemData,true)
        return view;  
    end

    local _scrollParams = {
            {
                data = self.missionDatas,
                createFunc = createItemFunc,
                updateCellFunc = updateCellFunc,
                offsetX =0,
                offsetY =100,
                itemRect = {x=-85,y= -210,width=185,height = 210},
                widthGap = 10,
                heightGap = 0,

            }
        }
    self.list:styleFill(_scrollParams);
    self.list:hideDragBar()
    self.list:gotoTargetPos(self.selectIndex,1,0)
end

function MissionMainView:updateItem(view,data)
    local panelRenwu = view.panel_renwu
    -- 任务 name
    local name = FuncMission.getMissionName(data.id)
    -- 任务 地点
    local space = FuncMission.getMissionSpaceName(data.id)

    local ctn = panelRenwu.ctn_1
    ctn:removeAllChildren()
    local iconSpr = nil
    -- 任务状态
    local missionState,leftTime = MissionModel:getMissionState(data)
    if missionState == MissionModel.missionState.Doing then
        panelRenwu.mc_1:showFrame(2)
        panelRenwu.mc_1.currentView.txt_1:setString(name)
        panelRenwu.mc_1.currentView.txt_2:setString(space)
        view.mc_1:showFrame(3)
        
        iconSpr = FuncMission.getMissionSpaceIcon2(data.id)
        local leftTime = fmtSecToHHMMSS(leftTime)
        view.mc_1.currentView.txt_2:setString(leftTime)

        iconSpr:setTouchedFunc(c_func(self.shuangji,self,data))
        
    elseif missionState == MissionModel.missionState.Finish then
        panelRenwu.mc_1:showFrame(1)
        panelRenwu.mc_1.currentView.txt_1:setString(name)
        panelRenwu.mc_1.currentView.txt_2:setString(space)

        view.mc_1:showFrame(1)
        local statePanel = view.mc_1.currentView
        local startTime = fmtSecToHHMM(data.startTime)
        local finishTime = fmtSecToHHMM(data.finishTime)
        statePanel.txt_2:setString(startTime.."-"..finishTime)
        iconSpr = FuncMission.getMissionSpaceIcon1(data.id)
    elseif missionState == MissionModel.missionState.Coming then
        panelRenwu.mc_1:showFrame(1)
        panelRenwu.mc_1.currentView.txt_1:setString(name)
        panelRenwu.mc_1.currentView.txt_2:setString(space)

        view.mc_1:showFrame(2)
        local statePanel = view.mc_1.currentView
        local startTime = fmtSecToHHMM(data.startTime)
        local finishTime = fmtSecToHHMM(data.finishTime)
        statePanel.txt_2:setString(startTime.."-"..finishTime)
        iconSpr = FuncMission.getMissionSpaceIcon2(data.id)
    end
    ctn:addChild(iconSpr)
    -- 判断是否是选中状态
    local ctnS = panelRenwu.ctn_xuan
    if self.selectIndex == data.index then
        local xuanSpr = FuncMission.getMissionSpaceSelecctIcon()
        ctnS:addChild(xuanSpr)
    else
        ctnS:removeAllChildren()
    end

    -- 注册点击事件
    view:setTouchedFunc(c_func(self.itemClickTap,self,data))
end

-- 双击
function MissionMainView:shuangji(data)
    if self.xuanzhongIndex and self.xuanzhongIndex ~= data.index then
        self.firstTime = nil
        self.xuanzhongIndex = data.index
        return
    end
    self.xuanzhongIndex = data.index
    if not self.firstTime then
        self.firstTime = self.frame
    else
        local currentTime = self.frame
        local jiange = currentTime - self.firstTime
        echo("jian ge shijian ==== ",jiange)
        if jiange > 0 and jiange <= 10 then
            self:gotoMission(data)
        end
        self.firstTime = nil
    end
end

function MissionMainView:updateFrame(  )
    self.frame = self.frame + 1
    self.currentFrame = self.currentFrame + 1
    if self.currentFrame >= 30 then
        self.currentFrame = 0
        for i,v in pairs(self.missionDatas) do
            local itemView = self.list:getViewByData(v)
            if itemView then
                local missionState,leftTime = MissionModel:getMissionState(v)
                if missionState == MissionModel.missionState.Doing then
                    itemView.mc_1:showFrame(3)
                    local leftTime = fmtSecToHHMMSS(leftTime)
                    itemView.mc_1.currentView.txt_2:setString(leftTime)
                end
            end
        end
    end
end

-- 点击事件
function MissionMainView:itemClickTap(data)
    self.selectIndex = data.index
    self:selectKuang()
    self:updateReward(  )
    self:updateMissionJindu()
end

-- 选中框逻辑
function MissionMainView:selectKuang()
    for i,v in pairs(self.missionDatas) do
        local itemView = self.list:getViewByData(v)
        if itemView then
            local panelRenwu = itemView.panel_renwu
            local ctnS = panelRenwu.ctn_xuan
            ctnS:removeAllChildren()
            if v.index == self.selectIndex then
                local xuanSpr = FuncMission.getMissionSpaceSelecctIcon()
                ctnS:addChild(xuanSpr)
            end
        end
    end
end

-- 前往
function MissionMainView:gotoMission(data)
    local missionId = data.id
    local missCfg = FuncMission.getMissionDataById( missionId )
    self:onBtnBackTap()
    -- echoError("missCfg.space == ",missCfg.space.." missionId == "..missionId)
    local spaceT = string.split(missCfg.space[1],",")
    -- dump(spaceT,"555555555",4)
    MissionModel:setMapOrder( spaceT[1],spaceT[2] )
    if AnimDialogControl:getIsInWorldMap() then
        if AnimDialogControl:getSpaceName() == spaceT[1] then
            self:startHide()
        else
            AnimDialogControl:destoryViewByGameType(spaceT[1], FuncCommon.SYSTEM_NAME.MISSION) 
        end       
    else
        EventControler:dispatchEvent(WorldEvent.WORLDEVENT_ENTER_ONE_MISSION,{spaceName=spaceT[1]})
    end  
end

function MissionMainView:getBoxAnim()
    local anim = self:createUIArmature("UI_xunxian","UI_xunxian_xingjibaoxiang",nil, true, GameVars.emptyFunc)
    return anim
end

-- 更新三个宝箱
function MissionMainView:updateBox()
    local maxBoxNum = 3
    local finishNum = 0
    for i=1,maxBoxNum do
        local state = MissionModel:getBoxState(i)
        -- echoError("state ===== ",state,"----- i ===",i)
        local mc_box = self["mc_"..i] 
        self["ctn_box"..i]:removeAllChildren()
        if MissionModel.boxStatus.CanGet == state then
            mc_box:visible(false)
            mc_box = UIBaseDef:cloneOneView(self["mc_"..i])
            mc_box:showFrame(1)
            local boxAnim = self:getBoxAnim()
            FuncArmature.changeBoneDisplay(boxAnim,"node",mc_box.currentView)
            -- if i == 2 then
            --     mc_box.currentView:pos(-20,34)
            if i == maxBoxNum then 
                mc_box.currentView:pos(30,-51)
            else
                mc_box.currentView:pos(30,-49)
            end
            self["ctn_box"..i]:addChild(boxAnim)
            finishNum = finishNum + 1
            -- echoError("3333333333")
        elseif MissionModel.boxStatus.NotCanGet == state then
            mc_box:showFrame(1)
            mc_box:visible(true)
        elseif MissionModel.boxStatus.Getted == state then
            mc_box:showFrame(3)
            mc_box:visible(true)
            finishNum = finishNum + 1
        end
        -- 注册宝箱的点击事件
        local nodetouch = FuncRes.a_white( 60,60)
        self["ctn_box"..i]:addChild(nodetouch)
        nodetouch:opacity(0)
        nodetouch:setTouchedFunc(c_func(self.boxClickTap,self,i))
    end

    -- 进度条
    local peecent = finishNum / 3 * 100
    local progressBar = self.panel_progress.progress_1:setPercent(peecent)
end

function MissionMainView:boxClickTap( index )
    WindowControler:showWindow("MissionBoxView",index) 
end

-- 可能获得奖励
function MissionMainView:updateReward(  )
    local max_reward = 5
    for i=1,max_reward do
        self["UI_x"..i]:visible(false)
    end
    local _rewards = MissionModel:getMissionReward(self.missionDatas[self.selectIndex].id)
    if _rewards == nil then
        echoError ("_rewards is nil")
        return
    end

    -- 获取需要的格式
    for i,v in pairs(_rewards) do
        local strT = string.split(v,",")
        local str = v
        local data = {}
        data.reward = str
        local itemView = self["UI_x"..i]
        itemView:visible(true)
        itemView:setRewardItemData(data)
        -- itemView:showResItemName(true)
        itemView:showResItemNum(false)
        -- 注册点击事件
        FuncCommUI.regesitShowResView(itemView,strT[1],0,strT[2],str,true,true)
    end
end

-- 当前轶事进度
function MissionMainView:updateMissionJindu( )
    local missionData = self.missionDatas[self.selectIndex]
    local missionState,leftTime = MissionModel:getMissionState(missionData)
    local data = FuncMission.getMissionDataById( missionData.id )
    if missionState == MissionModel.missionState.Doing then
        
        local jindu = MissionModel:getMissionJindu(missionData.id,missionData.startTime)
        
        local total = data.goalParam
        if tonumber(jindu) >= tonumber(total) then
            self.rich_1:setString(GameConfig.getLanguage("#tid_mission_005")) 
        else
            self.rich_1:setString(GameConfig.getLanguage("#tid_mission_006")..jindu.."/"..total)
        end
        

        self.btn_qianwang:setTap(c_func(self.gotoMission,self,missionData))

        self.rich_1:visible(true)
        self.btn_qianwang:visible(true)
    else
        self.rich_1:visible(false)
        self.btn_qianwang:visible(false)
    end

    -- 玩法描述
    local miaoshu = GameConfig.getLanguage(data.describe1)
    self.txt_miaoshu:setString(miaoshu)
end

function MissionMainView:onBtnBackTap()
    self:startHide()
end

return MissionMainView