local MissionMiaoshuView = class("MissionMiaoshuView", UIBase)

function MissionMiaoshuView:ctor(winName,missionData)
	MissionMiaoshuView.super.ctor(self, winName)
    self.missionId = missionData.id 
    self.missionData = missionData
    if not self.missionId then
        echoError("传入的missionid 为空 暂时用 100 代替")
        self.missionId = "100"
    end
end

function MissionMiaoshuView:setAlignment()
    --设置对齐方式
end

function MissionMiaoshuView:registerEvent()
    MissionMiaoshuView.super.registerEvent();
    self.panel_1.mc_yeqian1:setTouchedFunc(function( ... )
        if self.currentLabel ~= 1 then
            self.currentLabel = 1
            self:updateUI( )
            self:updateLabel( )
        end
    end)
    self.panel_1.mc_yeqian2:setTouchedFunc(function( ... )
        if self.currentLabel ~= 2 then
            self.currentLabel = 2
            self:updateUI( )
            self:updateLabel( )
        end
    end)
    -- TODO 隐藏第二个页签
    self.panel_1.mc_yeqian2:setVisible(false)

    self.panel_1.btn_back:setTap(c_func(self.onBtnBackTap,self))
    -- self:registClickClose()
    EventControler:addEventListener(MissionEvent.MISSIONUI_OVER, self.onBtnBackTap, self)
end

function MissionMiaoshuView:loadUIComplete()
    self:registerEvent()
    self:registClickClose("out")
    self.currentLabel = 1

    self.rankData = nil

    self:updateUI( )
    self:updateLabel( )
end

function MissionMiaoshuView:updateLabel()
    local label1 = self.panel_1.mc_yeqian1
    local label2 = self.panel_1.mc_yeqian2
    -- 描述
    if self.currentLabel == 1 then
        label1:showFrame(2)
        label2:showFrame(1)

        -- 判断是否是必得奖励
        local reward = FuncMission.getConfirmReward(self.missionId)
        if reward ~= nil then
            self.panel_1.mc_1.currentView.mc_1:showFrame(2)
        else
            self.panel_1.mc_1.currentView.mc_1:showFrame(1)
        end
    -- 排行
    else
        label1:showFrame(1)
        label2:showFrame(2)
    end
end

function MissionMiaoshuView:updateUI( )
    local dataCfg = FuncMission.getMissionDataById( self.missionId )
    local maxRewardNum = 5

    if self.currentLabel == 1 then
        self.panel_1.mc_1:showFrame(1)
        local panel = self.panel_1.mc_1.currentView
        -- 任务描述
        local desStr = FuncMission.getMissionDes(self.missionId)
        panel.txt_ms2:setString(desStr)
        -- 任务目标
        local jindu = MissionModel:getMissionJindu(self.missionId,self.missionData.startTime)
        panel.txt_mb2:setString(FuncMission.getMissionGoal(self.missionId,jindu))

        -- 可能获得
        for i=1,maxRewardNum do
            panel["UI_x"..i]:visible(false)
        end

        -- 暂时隐藏难度
        panel.btn_left:visible(false)
        panel.panel_nandu:visible(false)
        panel.btn_right:visible(false)
        
        local _rewards = MissionModel:getMissionReward(self.missionId)
        -- 获取需要的格式
        for i,v in pairs(_rewards) do
            local strT = string.split(v,",")
            local str = v

            local data = {}
            data.reward = str
            
            local itemView = panel["UI_x"..i]
            if itemView then
                itemView:visible(true)
                itemView:setRewardItemData(data)
                -- itemView:showResItemName(true)
                -- itemView:showResItemNum(false)
                -- 注册点击事件
                FuncCommUI.regesitShowResView(itemView,strT[1],0,strT[2],str,true,true)
            end
        end
    else
        self:paihangRequest()
    end 
end

-- 排名请求
function MissionMiaoshuView:paihangRequest()
    local index = MissionModel:getMissionIndex(self.missionId)
    local params = {
        id = self.missionId,
        index = index
    }
    MissionServer:requestRanK( params, c_func(self.paihangRequestCallBack,self) )
end

function MissionMiaoshuView:paihangRequestCallBack( params )
    echo("排名回去返回---------------")
    if params.result then
        dump(params.result, "服务器返排名", 3)
        local data = {}
        for i,v in pairs(params.result.data.list) do
            table.insert(data,v)    
        end
        table.sort(data,function (a,b)
            if a.rank < b.rank then
                return true 
            end
            return false
        end) 
        local rank = params.result.data.rank or 0
        local score = params.result.data.score or 0
        self:updatePaiHang(data,rank,score)
    end
end

-- 刷新排行榜
function MissionMiaoshuView:updatePaiHang(data,rank,score)
    self.panel_1.mc_1:showFrame(2)
    local panel = self.panel_1.mc_1.currentView
    local itemPanel = panel.panel_2
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
                data = data,
                createFunc = createItemFunc,
                updateCellFunc = updateCellFunc,
                offsetX =3,
                offsetY =0,
                itemRect = {x=0,y= -52,width=357,height = 52},
                widthGap = 0,
                heightGap = 0,

            }
        }
    panel.scroll_1:styleFill(_scrollParams);
    panel.scroll_1:hideDragBar()

    -- 刷新自己
    local _d = {}
    _d.rank = rank 
    _d.name = UserModel:name()
    _d.level = UserModel:level()
    _d.score = score
    self:updateItem(itemPanel,_d)
    itemPanel.panel_ziji:visible(true)
    itemPanel.mc_di:showFrame(3)
end

function MissionMiaoshuView:updateItem(view,data)
    local panel = view
    -- 排名
    local paiming = data.rank or 0
    if paiming%2 == 0 then
        panel.mc_di:showFrame(1)
    else
        panel.mc_di:showFrame(2)
    end
    if paiming < 4 and paiming > 0 then
        panel.mc_1:showFrame(paiming)
    else
        panel.mc_1:showFrame(4)
        local txt = panel.mc_1.currentView.txt_1
        if paiming == 0 then
            -- 未上榜
            paiming = GameConfig.getLanguage("#tid_mission_014")
        end
        txt:setString(paiming)
    end
    -- 名称
    panel.txt_name:setString(data.name)
    -- 等级
    panel.txt_lv:setString(data.level)
    -- 积分
    panel.txt_jifen:setString(data.score)
    
    panel.panel_ziji:visible(false)
    -- 点击事件玩家详情
    if UserModel:name() ~= data.name then
        panel:setTouchedFunc(function( ... )
            WindowControler:showWindow("CompPlayerDetailView",data,nil,3);
        end)
    end
end

function MissionMiaoshuView:onBtnBackTap()
    self:startHide()
end

return MissionMiaoshuView
