
local LuckyGuyMainView = class("LuckyGuyMainView", UIBase)

function LuckyGuyMainView:ctor(winName)
    LuckyGuyMainView.super.ctor(self, winName)
end

function LuckyGuyMainView:loadUIComplete()
    -- 适配
    self:uiAdjust()
    -- 事件注册
    self:registerEvent()
    self:initData()
    self:huluAnimation()
end

function LuckyGuyMainView:uiAdjust()
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back, UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_res, UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_guize, UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_title, UIAlignTypes.LeftTop)
    -- FuncCommUI.setViewAlign(self.widthScreenOffset, self.UI_backhome, UIAlignTypes.LeftTop)
end

function LuckyGuyMainView:registerEvent()
    self.btn_back:setTap(c_func(self.close,self))
    self.btn_guize:setTap(c_func(self.helpbutton,self))
    self:scheduleUpdateWithPriorityLua(c_func(self.updateFrame,self), 1)
    EventControler:addEventListener(TimeEvent.TIMEEVENT_HAS_OVER_DAY,self.initData,self)
    EventControler:addEventListener(LuckyGuyEvent.LUCKYGUY_PLAY_SUCCESS_EVENT, self.initData, self)
    EventControler:addEventListener(LuckyGuyEvent.LUCKYGUY_REFRESH_LUCKNUMBER_EVENT, self.setLucky, self)
    EventControler:addEventListener(LuckyGuyEvent.LUCKYGUY_PLAY_AGAIN_ONE_EVENT,self.clickOneBtn, self)
    EventControler:addEventListener(LuckyGuyEvent.LUCKYGUY_PLAY_AGAIN_FIVE_EVENT,self.clickFiveBtn, self)
    EventControler:addEventListener(LuckyGuyEvent.LUCKYGUY_PLAY_REWARD_EVENT,self.startTime, self)
    EventControler:addEventListener(LuckyGuyEvent.LUCKYGUY_REFRESH_MONEY_TXT,self.refreshMoneyTxt, self)
end

function LuckyGuyMainView:huluAnimation()
    self.ctn_hulu = self.panel_hulu.panel_1.ctn_hulu
    self.panel_hulu.panel_1.progress_1:setPosition(-49, 47)
    self.huluAnim = self:createUIArmature("UI_xingyuntanbao", "UI_xingyuntanbao_zong", self.ctn_hulu, true)
    FuncArmature.changeBoneDisplay(self.huluAnim, "gaoguang", self.panel_hulu.panel_1.progress_1)
    FuncArmature.changeBoneDisplay(self.huluAnim, "hulu", self.panel_hulu.panel_1.progress_1)
end

function LuckyGuyMainView:initData()
    -- 初次进入活动界面，显示的活动详情内容  然后再活动期间就不显示了
    -- 在本地存一个时间戳  判断时间是否在当前活动期间 
    -- 如果在就不弹  不在或者空 就弹
    -- 如果换手机  那这个就完犊子了  肯定弹了
    local time = LS:prv():get(StorageCode.luckyGuy_save)
    local tmp,endTime,actStartTime = FuncLuckyGuy.getSystemHide()
    if time == nil then
        WindowControler:showTopWindow("LuckyGuyRulseView")
    elseif tonumber(time) >= actStartTime and tonumber(time) <= endTime then
    else
        WindowControler:showTopWindow("LuckyGuyRulseView")
    end
    local nowTime = TimeControler:getServerTime()
    LS:prv():set(StorageCode.luckyGuy_save,nowTime)
    -- echo("actStartTime ================= ",actStartTime)
    -- echo("rouletteTime ================= ",UserExtModel:rouletteTime())
    -- dump(UserExtModel:rouletteLucky(),"UserExtModel:rouletteLucky()")

    self.isOverTime = false  --  活动过期标识
    -- 如果活动开始时间 跟服务器给的转盘期数时间不相等  要重置奖励显示和幸运值显示
    if tonumber(actStartTime) ~= tonumber(UserExtModel:rouletteTime()) then
        self.isOverTime = true
    end

    -- 在上层创建一个node  用来点击跳过动画
    self:removeChild(self.node)
    self.node = display.newNode()
    self.node:setContentSize(cc.size(1400,768))
    self.node:pos(-130,-640)
    self.node:anchor(0,0)
    self.node:addto(self,1)
    self.node:setVisible(false)
    self.node:setTouchEnabled(true)
    self.node:setTouchSwallowEnabled(true)
    self.node:zorder(100000)
    self.clickView = false

    --[[
      -- 测试代码
      local color = color or cc.c4b(255,0,0,120)
        local layer = cc.LayerColor:create(color)
        self.node:addChild(layer)
        self.node:zorder(100000000)
        -- self.node:setTouchEnabled(true)
        -- self.node:setTouchSwallowEnabled(true)
        layer:setContentSize(cc.size(1400,768) )
    ]]--

    -- dump(UserExtModel:roulettes(),"---------------reward--------------")

    -- dump(FuncLuckyGuy.getRewardList(),"getRewardList = = = = = =")
    self.rouletteList = FuncLuckyGuy.getRewardList()
    self.time = 1          --- 第几个mc_
    self.circle = 0        --- 第几圈
    self.stopCircle = 3       --- 在第几圈停止
    self.speedStart = 2    --- 初始速度
    self.speedStop = 6     --- 要停止之前的速度
    self:setLucky()
    self:initUI()
    self:setPeopleView()
end

function LuckyGuyMainView:initUI()
    self:setRewardView()
    self:refreshBtnFreeOrOne()
    self:setCoinTxt()
    self.currentFrame = 30
end

--12个道具
function LuckyGuyMainView:setRewardView(  )
    self.panel_ewai:setVisible(false)  --- 隐藏五个奖励
    local bestRewardList
    if self.isOverTime then
        bestRewardList = {}
    else
        bestRewardList = UserExtModel:roulettes()
    end
     
    for k,v in pairs(self.rouletteList) do
        
        local reward = v[1]
        -- echo("reward = = = = = ",reward)
        if v[3] and v[3] == 1 then   ---- 物品列表稀有  给个标识
            self["mc_"..k]:showFrame(2) 
            self["mc_"..k].currentView.ctn_guang:removeAllChildren()
            local anim = self:createUIArmature("UI_xingyuntanbao", "UI_xingyuntanbao_diguang", self["mc_"..k].currentView.ctn_guang, true,GameVars.emptyFunc)
        end
        self["mc_"..k].currentView.panel_m1:setVisible(false)
        if table.length(bestRewardList) ~= 0 then
            for i,j in pairs(bestRewardList) do
                local rewardId = FuncLuckyGuy.getRouletteRewardById( i )
                local id = string.split(v[1],",")
                if rewardId == id[2] then
                    -- echo("id = = = == = ",id[2])
                    self["mc_"..k].currentView.panel_m1:setVisible(true)
                end
            end
        end
        self["mc_"..k].currentView.UI_1:setResItemData({reward = reward})
        -- self["mc_"..k].currentView.txt_1:setVisible(false)
        self["mc_"..k].currentView.UI_1:showResItemName(true);
        local resNum, _, _, resType, resId = UserModel:getResInfo(reward)
        FuncCommUI.regesitShowResView(self["mc_"..k].currentView.UI_1, resType, resNum, resId, reward, true, true)
    end

    self.panel_2:setPosition(self["mc_1"]:getPosition())  -- 初始奖励框位置
end

--人物立绘
function LuckyGuyMainView:setPeopleView()
    local ctn = self.ctn_1
    ctn:removeAllChildren()
    local man = FuncPartner.getPartnerOrCgarLiHui(FuncLuckyGuy.getPartnerId())
    local posArr = string.split(FuncLuckyGuy.getPartnerPos()[1],",")
    man:setPositionX(tonumber(posArr[1]))
    man:setPositionY(tonumber(posArr[2]))
    man:setScale(tonumber(posArr[3]))
    ctn:addChild(man);
    local nameStr = FuncPartner.getPartnerName(FuncLuckyGuy.getPartnerId())
    self.txt_5:setString(nameStr);
    
    self.panel_top2.btn_1:setBtnStr("探宝1次","txt_1")
    self.panel_top2.btn_2:setBtnStr("探宝5次","txt_1")
end

--抽一次的效果
function LuckyGuyMainView:setOneAction()
    if not self.frame then
        self.frame = 0
    end
    self.frame = self.frame + 1

    if self.circle < self.stopCircle then
        if self.frame % self.speedStart == 0 then    ----控制速度
            self.panel_2:setPosition(self["mc_"..self.time]:getPosition())
            self.time = self.time + 1
        end
    else
        if self.circle == self.stopCircle then  --- 第三圈停
            if self.frame % self.speedStop == 0 then    ----控制速度
                self.panel_2:setPosition(self["mc_"..self.time]:getPosition())
                if self.time == self.stopNum_one then    --- 判断在第几个停住
                    self.panel_2:setPosition(self["mc_"..self.time]:getPosition())
                    self.panel_2:runAction(cca.blink(1,5))   --- 闪烁效果
                    ---延迟函数   弹奖励界面
                    self:delayCall(function()
                        if self.status == 0 then
                            echo("111111111111111111")
                            self:showReward()
                            self.status = self.status + 1
                        end
                    end,1)
                end
                if self.time == self.stopNum_one then
                    self.time = self.time
                else
                    self.time = self.time + 1
                end
            end
        end
    end
    
    if self.time == 13 then
        self.circle = self.circle + 1
        -- echo("self.circle = = = = = = = ",self.circle)
        self.time = 1
    end
end

-- 抽五次的效果
function LuckyGuyMainView:setFiveAction()
    if not self.frame then
        self.frame = 0
    end
    self.frame = self.frame + 1
    --抽五次 
    if self.frame % self.speedStart == 0 then    ----控制速度
        -- echo("self.time =========== ",self.time)
        self.panel_2:setPosition(self["mc_"..self.time]:getPosition())
        if self.circle < self.stopCircle then
            self:refreshTime()
        else 
            -- --- 第三圈停
            -- echo("self.time222222222 =========== ",self.time)
            -- echo("stopNum_five_tmp =========== ",self.stopNum_five_tmp[#self.stopNum_five_tmp])
            -- dump(self.five_Arr,"self.five_Arr ====== ")
            self.panel_hulu:setVisible(false) -- 隐藏葫芦
            self.panel_top2:setVisible(false)
            -- 五个奖励   如果下一个奖励跟上一个相等
            -- 要再跑一圈 再进行闪烁和移除的操作  否则会有问题
            if self.stopNum_five_tmp[#self.stopNum_five_tmp] == self.five_Arr[#self.stopNum_five_tmp + 1] then
                -- echo("circleTmp =========== circle ==== ",self.circleTmp,self.circle)
                if (self.circleTmp or self.circle) < self.circle then
                    -- echo("222222222222222222")
                    if self.time == self.stopNum_five_tmp[#self.stopNum_five_tmp] then    --- 判断在第几个停住
                        self.sign = false
                        self:refreshTime()
                        self.panel_2:runAction(cca.blink(0.5,5))   --- 闪烁效果
                        self:delayCall(function()
                            self.sign = true
                        end,0.5)
                        self:refreshTime()
                        table.remove(self.stopNum_five_tmp,#self.stopNum_five_tmp)  -- 把闪烁的移除
                        self.circleTmp = self.circle
                        self.panel_ewai:setVisible(true)
                        for i=1,5 do
                            self.panel_ewai["panel_" .. tostring(i)]:setVisible(false)
                        end
                        for i=1,5 - #self.stopNum_five_tmp do
                            self.panel_ewai["panel_" .. tostring(i)]:setVisible(true)
                        end
                    end
                else
                    -- echo("4444444444444444444444")
                    self.circleTmp = self.circle
                    self:refreshTime()
                end
            else
                -- echo("55555555555555555555")
                if self.time == self.stopNum_five_tmp[#self.stopNum_five_tmp] then    --- 判断在第几个停住
                    self.circleTmp = self.circle
                    self.sign = false
                    self:refreshTime()
                    self.panel_2:runAction(cca.blink(0.5,5))   --- 闪烁效果
                    self:delayCall(function()
                        self.sign = true
                    end,0.5)
                    self:refreshTime()
                    table.remove(self.stopNum_five_tmp,#self.stopNum_five_tmp)  -- 把闪烁的移除
                    self.panel_ewai:setVisible(true)
                    for i=1,5 do
                        self.panel_ewai["panel_" .. tostring(i)]:setVisible(false)
                    end
                    for i=1,5 - #self.stopNum_five_tmp do
                        self.panel_ewai["panel_" .. tostring(i)]:setVisible(true)
                    end
                end
            end
            
            -- echo("====================================")
            if #self.stopNum_five_tmp == 0 then -- 全部显示完 弹出奖励界面
                self.time = self.time
                ---延迟函数   弹奖励界面
                self:delayCall(function()
                    -- self:resumeUIClick()
                    if self.status == 0 then
                        echo("22222222222222222222")
                        self:showReward()
                        self.status = self.status + 1
                    end
                end,0.2)
            end
            self:refreshTime()
        end
    end
    if self.time >= 13 then
        self.circleAddSign = false
        self.circle = self.circle + 1
        -- echo("self.circle = = = = = = = ",self.circle)
        self.time = 1
    end
    
end

function LuckyGuyMainView:refreshTime(  )
    if self.sign then
        self.time = self.time + 1
    else
        self.time = self.time
    end
    
end

--倒计时
function LuckyGuyMainView:updateTimeDown(  )
    if self.currentFrame >= 30 then
        self.currentFrame = 0
        local leftTime = LuckyGuyModel:getActEndTime()
        if leftTime <= 0 then
            WindowControler:showTips("活动已经结束")
            self:startHide()
        end
        self.txt_8:setString(fmtSecToLnDHHMMSS(leftTime))
    end
    self.currentFrame = self.currentFrame + 1
end

--设置幸运值
function LuckyGuyMainView:setLucky(event)
    self.panel_hulu:setVisible(true)
    local luckyNum
    if self.isOverTime then
        luckyNum = 0
    else
        luckyNum = UserExtModel:rouletteLucky()
    end
     
    
    if event and event.params and event.params.num then
        luckyNum = event.params.num
    end
    local luckyValueTable = number.split(luckyNum);
    self:setLuckyNumber(luckyValueTable)
    self:setProgress(luckyNum)
end

function LuckyGuyMainView:setLuckyNumber(number)
    local len = table.length(number);
    self.panel_hulu.UI_1.UI_1.mc_shuzi:showFrame(len);

    for k, v in pairs(number) do
        local mcs = self.panel_hulu.UI_1.UI_1.mc_shuzi:getCurFrameView();
        mcs["mc_" .. tostring(k)]:showFrame(v + 1);
    end
end

--设置进度条
function LuckyGuyMainView:setProgress(number)
    local curLucky = number
    local allLucky = FuncLuckyGuy.getMaxLuck()
    local percent = math.round(curLucky/allLucky*100)
    self.panel_hulu.panel_1.progress_1:setDirection(ProgressBar.d_u)
    self.panel_hulu.panel_1.progress_1:tweenToPercent(percent)
end

function LuckyGuyMainView:refreshMoneyTxt()
    self:refreshBtnFreeOrOne()
    self:setCoinTxt()
end

--刷新是免费一次还是花钱一次
function LuckyGuyMainView:refreshBtnFreeOrOne()
    local count = CountModel:getLuckyGuyFreeTimes()
    local sprint1 = display.newSprite(FuncRes.icon( "res/tanbaofu.png" ))
    local sprint2 = display.newSprite(FuncRes.icon( "res/tanbaofu.png" ))
    sprint1:setScale(0.4)
    sprint2:setScale(0.4)
    self.panel_top2.ctn_2:addChild(sprint1)
    self.panel_top2.ctn_3:addChild(sprint2)
    -- echo("count = = = = = = =",count)
    if count == 0 then  -- 免费
        self.panel_top2.ctn_2:setVisible(false)
        self.panel_top2.txt_6:setString("免费")
        self.panel_top2.txt_6:setColor(cc.c3b(0,255,0))
        self.panel_top2.btn_1:setTap(c_func(self.clickFreeBtn,self))
    else
        self.panel_top2.ctn_2:setVisible(true)
        self.panel_top2.txt_6:setString(tostring(FuncDataSetting.getDataByConstantName("RouletteOnceCost")))
        if FuncLuckyGuy.getIsEnough(FuncLuckyGuy.PLAYTYPE.PLAY_ONE) then
            self.panel_top2.txt_6:setColor(cc.c3b(0,255,0))
        else
            self.panel_top2.txt_6:setColor(cc.c3b(255,0,0))
        end
        self.panel_top2.btn_1:setTap(c_func(self.clickOneBtn,self))
    end
    self.panel_top2.btn_2:setTap(c_func(self.clickFiveBtn,self))
end

--花费
function LuckyGuyMainView:setCoinTxt(  )
    self.panel_top2.txt_7:setString(tostring(FuncDataSetting.getDataByConstantName("RouletteFiveCost")))
    if FuncLuckyGuy.getIsEnough(FuncLuckyGuy.PLAYTYPE.PLAY_FIVE) then
        self.panel_top2.txt_7:setColor(cc.c3b(0,255,0))
    else
        self.panel_top2.txt_7:setColor(cc.c3b(255,0,0))
    end
end

function LuckyGuyMainView:updateFrame()
    self:updateTimeDown()
    if self.startTmp then
        if table.length(self.rewardArr) == 1 then
            self:setOneAction()
        else
            self:setFiveAction()
        end
    end
    if self.clickView then
        -- 点击屏幕  把clickView赋值为true 停止动画  弹出奖励窗
        echo("3333333333333333333")
        self:showReward()
    end
end

-- 开启计时器
function LuckyGuyMainView:startTime(event)
    if event.params then
        self.rewardArr = event.params.reward
        -- dump(self.rewardArr,"rewardArr ========== ")
        -- dump(self.rouletteList,"rouletteList ========== ")
        -- 抽一次
        self.stopNum_five = {}
        self.five_Arr = {}
        if table.length(self.rewardArr) == 1 then
            for k,v in pairs(self.rouletteList) do
                local rewardTmp = string.split(v[1],",")
                if tonumber(self.rewardArr[1][2]) == tonumber(rewardTmp[2]) then
                    self.stopNum_one = k
                end
            end
        else
        -- 抽五次
            for key,val in pairs(self.rewardArr) do
                for k,v in pairs(self.rouletteList) do
                    local rewardTmp = string.split(v[1],",")
                    if tonumber(rewardTmp[2]) == tonumber(val[2]) then
                        self.stopNum_five[#self.stopNum_five + 1] = k
                    end
                end
            end
            -- dump(self.stopNum_five,"========== self.stopNum_five ==========")
            -- self.five_Arr = self.stopNum_five  
            --逆序 方便删除
            local tmp = {}
            for i=1,#self.stopNum_five do
                tmp[i] = table.remove(self.stopNum_five)
            end
            self.stopNum_five_tmp = table.copy(tmp)
            -- self.stopNum_five_tmp = {10,10,10,10,10} -- 测试数组
            self.five_Arr = table.copy(tmp)    -- 临时数组  用于比对
            -- self.five_Arr = {10,10,10,10,10}  -- 测试数组
            self.sign = true

            for i = 1, 5 do
                local itemCommonUI = nil
                local itemPanel = self.panel_ewai["panel_" .. tostring(i)]

                itemCommonUI = itemPanel.UI_1
                itemCommonUI:setResItemData(
                    {reward = self.rewardArr[i]});
                itemCommonUI:showResItemName(true, true);
                itemCommonUI:showResItemNameWithQuality()
            end
        end
        -- echo("stopNum_one =============== ",self.stopNum_one)
        -- dump(self.five_Arr,"--------- five_Arr ---------  ")
        self.startTmp = true  -- 开始动画标识
        self.status = 0       -- 弹出奖励界面标识  只弹一次
        self:disabledUIClick()

        self:delayCall(function()
            self.node:setVisible(true)
            self.node:setTouchEnabled(true)
            self.node:setTouchSwallowEnabled(true)
            self.node:setTouchedFunc(c_func(self.clickViewState,self))
        end,0.3)
        
      --   self:registClickClose(-1, c_func( function()
      --       self:clickViewState()
      -- end , self))
    end
end

function LuckyGuyMainView:clickViewState()
    self.clickView = true
end

--道具奖励展示
function LuckyGuyMainView:showReward()
    -- echo("self.playType = = = = = = = = ",self.playType)
    -- dump(self.rewardArr,"rewardArr ========== ")
    self:resumeUIClick()
    self.startTmp = false
    self.clickView = false
    self.node:setVisible(false)
    self.panel_top2:setVisible(true)

    -- 获得新奇侠
    local haveNewPartner = false
    local partnerId = ""
    for k,v in pairs(self.rewardArr) do
        if v[1] == "18" then
            haveNewPartner = true
            partnerId = v[2]
        end
    end

    if haveNewPartner then
        local param = {
            id = partnerId,
            skin = "1",
        }
        WindowControler:showWindow("PartnerSkinFirstShowView", param, function ()
                WindowControler:showWindow("LuckyGuyRewardView",self.rewardArr,self.playType)
            end)
    else
        WindowControler:showWindow("LuckyGuyRewardView",self.rewardArr,self.playType)
    end
end

function LuckyGuyMainView:getActId()
    local subId,endTime,startTime,actId = FuncLuckyGuy.getSystemHide()
    return actId
end

--免费抽
function LuckyGuyMainView:clickFreeBtn(  )
    local leftTime = LuckyGuyModel:getActEndTime()
    if leftTime <= 0 then
        return
    end
    local count = CountModel:getLuckyGuyFreeTimes()
    if count ~= 0 then
        WindowControler:showTips("免费次数已经用完")
        return
    end
    self.playType = FuncLuckyGuy.PLAYTYPE.PLAY_FREE

    LuckyGuyModel:playAward(FuncLuckyGuy.PLAYTYPE.PLAY_FREE,LuckyGuyMainView:getActId())
end

--抽一次
function LuckyGuyMainView:clickOneBtn(  )
    local leftTime = LuckyGuyModel:getActEndTime()
    if leftTime <= 0 then
        return
    end
    if FuncLuckyGuy.getIsEnough(FuncLuckyGuy.PLAYTYPE.PLAY_ONE) then
        self.playType = FuncLuckyGuy.PLAYTYPE.PLAY_ONE
        -- self:disabledUIClick()
        -- self.btn_1:setVisible(false)
        -- self.btn_2:setVisible(false)
        LuckyGuyModel:playAward(self.playType,LuckyGuyMainView:getActId())
    else
        WindowControler:showWindow("LuckyguyNotEnough")
    end
end

--抽五次
function LuckyGuyMainView:clickFiveBtn(  )
    local leftTime = LuckyGuyModel:getActEndTime()
    if leftTime <= 0 then
        return
    end
    if FuncLuckyGuy.getIsEnough(FuncLuckyGuy.PLAYTYPE.PLAY_FIVE) then
        self.playType = FuncLuckyGuy.PLAYTYPE.PLAY_FIVE
        -- self:disabledUIClick()
        -- self.btn_1:setVisible(false)
        -- self.btn_2:setVisible(false)
        LuckyGuyModel:playAward(self.playType,LuckyGuyMainView:getActId())
    else
        WindowControler:showWindow("LuckyguyNotEnough")
    end
end

function LuckyGuyMainView:helpbutton()
    WindowControler:showWindow("LuckyGuyRulseView")
end

function LuckyGuyMainView:close()
    self:startHide()
end

return LuckyGuyMainView