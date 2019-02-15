--幸运转盘  10个以下获得奖励弹窗
local LuckyGuyRewardView = class("LuckyGuyRewardView", UIBase);
--type  转一次或者五次
function LuckyGuyRewardView:ctor(winName, itemArray, type, callBack)  
    LuckyGuyRewardView.super.ctor(self, winName);
    dump(itemArray, "\n\n---itemArray---");
    self._itemArray = itemArray;
    self._type = type
    self._callback = callBack or GameVars.emptyFunc;
end

function LuckyGuyRewardView:loadUIComplete()
    self:registerEvent();
    self.mc_1:setVisible(false)
    self:initUI();
    AudioModel:playSound(MusicConfig.s_com_reward);
end 

function LuckyGuyRewardView:registerEvent()
    LuckyGuyRewardView.super.registerEvent();
    EventControler:addEventListener(TimeEvent.TIMEEVENT_HAS_OVER_DAY,self.clickOk,self)
end

--初始化界面
function LuckyGuyRewardView:initUI()
    local itemViewArr = {}
    local effectPos = {}
    local allRewardsList = FuncLuckyGuy.getRewardList()
    local showItem = function ()
        if not self._itemArray then
            echoError("__没有传入道具",self._itemArray )
            return
        end
        
        local itemNum = table.length(self._itemArray);

        if itemNum > 10 then 
            echo("warning!!!  LuckyGuyRewardView:initUI() itemNum is more then 10!!!");
        end

        self.mc_1:setVisible(true)
        self.mc_1:showFrame(itemNum);

        for i = 1, itemNum do
            local itemCommonUI = nil
            local itemPanel = self.mc_1:getCurFrameView()["panel_" .. tostring(i)]

            itemCommonUI = itemPanel.UI_1
            itemCommonUI:setResItemData(
                {reward = self._itemArray[i]});
            itemCommonUI:showResItemName(true, true);
            itemCommonUI:showResItemNameWithQuality()

            --奖励上面加光效 start
            local tmp1 = self._itemArray[i][2]
            local tmp2
            for k,v in pairs(allRewardsList) do
                tmp2 = string.split(v[1],",")
                -- 奖励id相等  并且  有加特效的字段
                -- 生成一个坐标table 记录哪个道具要加特效
                if tonumber(tmp1) == tonumber(tmp2[2]) and tonumber(v[4]) and tonumber(v[4]) == 1 then
                    table.insert(effectPos,i,i)
                end
            end
            -- dump(effectPos,"effectPos ========= ")
            self:updateItemEffect(self._itemArray[i],effectPos,itemPanel,i)
            -- end

            local _reward = self._itemArray[i]
            
            local rewardType = nil
            local rewardNum = nil
            local rewardId = nil
            local rewardStr = nil

            if type(_reward) == "table" then
                rewardType = _reward[1]
                rewardNum = _reward[table.length(_reward)]
                rewardId = _reward[table.length(_reward) - 1]
                if table.length(_reward) > 2 then
                    rewardStr = string.format("%s,%s,%s",_reward[1],_reward[2],_reward[3])
                else
                    rewardStr = string.format("%s,%s",_reward[1],_reward[2])
                end
            else
                local reward_table = string.split(_reward, ",")
                rewardType = reward_table[1]
                rewardNum = reward_table[table.length(reward_table)]
                rewardId = reward_table[table.length(reward_table) - 1]
                rewardStr = _reward
            end
            

            FuncCommUI.regesitShowResView(itemCommonUI, rewardType, rewardNum, rewardId, rewardStr, true, true)
            itemCommonUI:setTouchSwallowEnabled(true)

            if itemPanel then
                -- itemCommonUI:setVisible(false)
                itemViewArr[#itemViewArr+1] = itemPanel
            end
        end

        -- 播放通用动画效果
        -- 坐标偏移值用于调整动画位置效果
        local ofssetX = 11
        local offsetY = -7
        FuncCommUI.playCommonRewardAnim(self,itemViewArr,ofssetX,offsetY)
    end
    -- echo("self._type = = = = == = == = == = = ",self._type)
    local sprint = display.newSprite(FuncRes.icon( "res/tanbaofu.png" ))
    sprint:setScale(0.4)
    if self._type == FuncLuckyGuy.PLAYTYPE.PLAY_FREE or self._type == FuncLuckyGuy.PLAYTYPE.PLAY_ONE then
        self.mc_2:showFrame(2)
        self.mc_2:getCurFrameView().btn_2:setBtnStr("探宝1次","txt_1")
        self.mc_2:getCurFrameView().btn_2:setTap(c_func(self.playAgain,self,FuncLuckyGuy.PLAYTYPE.PLAY_ONE))
        self.mc_2:getCurFrameView().txt_1:setString(tostring(FuncDataSetting.getDataByConstantName("RouletteOnceCost")))
        if FuncLuckyGuy.getIsEnough(FuncLuckyGuy.PLAYTYPE.PLAY_ONE) then
            self.mc_2:getCurFrameView().txt_1:setColor(cc.c3b(0,255,0))
        else
            self.mc_2:getCurFrameView().txt_1:setColor(cc.c3b(255,0,0))
        end
        self.mc_2:getCurFrameView().ctn_1:addChild(sprint)
    elseif self._type == FuncLuckyGuy.PLAYTYPE.PLAY_FIVE then
        self.mc_2:showFrame(1)
        self.mc_2:getCurFrameView().btn_2:setBtnStr("探宝5次","txt_1")
        self.mc_2:getCurFrameView().btn_2:setTap(c_func(self.playAgain,self,FuncLuckyGuy.PLAYTYPE.PLAY_FIVE))
        self.mc_2:getCurFrameView().txt_1:setString(tostring(FuncDataSetting.getDataByConstantName("RouletteFiveCost")))
        if FuncLuckyGuy.getIsEnough(FuncLuckyGuy.PLAYTYPE.PLAY_FIVE) then
            self.mc_2:getCurFrameView().txt_1:setColor(cc.c3b(0,255,0))
        else
            self.mc_2:getCurFrameView().txt_1:setColor(cc.c3b(255,0,0))
        end
        self.mc_2:getCurFrameView().ctn_1:addChild(sprint)
    end

    self.btn_1:setTap(c_func(self.clickOk,self))
    self.mc_2:setVisible(false)
    self.btn_1:setVisible(false)
    EventControler:dispatchEvent(LuckyGuyEvent.LUCKYGUY_PLAY_SUCCESS_EVENT)
    -- 奖品特效
    local anim = FuncCommUI.addCommonBgEffect(self.ctn_1, FuncCommUI.EFFEC_TTITLE.GONGXIHUODE, c_func(showItem), true, true, -85)
    -- local anim = FuncCommUI.playSuccessArmature(self.UI_1, 
    --     FuncCommUI.SUCCESS_TYPE.GET, 2, true);

    -- FuncCommUI.addBlackBg(self.widthScreenOffset,self._root);

    anim:registerFrameEventCallFunc(30, 1, function ( ... )
        -- self:registClickClose(nil, function ( ... )
        --     self._callback();
            -- self:startHide();
        -- end);
        -- self:registClickClose();
        self.mc_2:setVisible(true)
        self.btn_1:setVisible(true)
    end);
    
end

function LuckyGuyRewardView:playAgain( type )
    if type then
        if FuncLuckyGuy.getIsEnough(type) then
            if type == FuncLuckyGuy.PLAYTYPE.PLAY_ONE then ----再开一次 
                EventControler:dispatchEvent(LuckyGuyEvent.LUCKYGUY_PLAY_AGAIN_ONE_EVENT)
            elseif type == FuncLuckyGuy.PLAYTYPE.PLAY_FIVE then ----再开五次
                EventControler:dispatchEvent(LuckyGuyEvent.LUCKYGUY_PLAY_AGAIN_FIVE_EVENT)
            end
        else
            WindowControler:showWindow("LuckyguyNotEnough")
        end
    end
    self:startHide();
end

--添加item上的闪光特效
function LuckyGuyRewardView:updateItemEffect(itemData, effectPos, panel, index)
    local ctnUp = panel.ctn_jianglitexiaoshang
    local ctnDown = panel.ctn_jianglitexiaoxia
    if effectPos then
        if effectPos[index] and tonumber(index) == tonumber(effectPos[index]) then
            -- 需要特效且该特效不存在时才新建特效
            -- if not ctnUp:getChildByName("ani1") then
            ctnUp:removeAllChildren()
            ctnDown:removeAllChildren()
            local ani1, ani2 = self:addAnimation(itemData, ctnUp, ctnDown)
                -- ani1:setName("ani1")
                -- ani2:setName("ani2")
            -- end
            -- ctnUp:getChildByName("ani1"):setVisible(true)
            -- ctnDown:getChildByName("ani2"):setVisible(true)

        else
            -- if ctnUp:getChildByName("ani1") then
                ctnUp:removeAllChildren()
                ctnDown:removeAllChildren()
                -- ctnUp:getChildByName("ani1"):setVisible(false)
                -- ctnDown:getChildByName("ani2"):setVisible(false)
            -- end                           
        end
    else
        ctnUp:removeAllChildren()
        ctnDown:removeAllChildren()
        -- if ctnUp:getChildByName("ani1") then
        --     ctnUp:getChildByName("ani1"):setVisible(false)
        --     ctnDown:getChildByName("ani2"):setVisible(false)
        -- end
    end
end

function LuckyGuyRewardView:addAnimation(reward, ctnUp, ctnDown)
    local _effectType = {
        [1] = {
            down = "UI_shop_fangxiaceng",
            up = "UI_shop_fangshangceng",
        },
        [2] = {
            down = "UI_shop_yuanxiaceng",
            up = "UI_shop_yuanshangceng",
        },
        [3] = {
            down = "UI_shop_lenxiaceng",
            up = "UI_shop_lenshangceng",
        },
    }
    local frame = FuncCommon.getShapByReward(reward)
    -- echo("\nreward==", reward, frame)
    local ani1 = self:createUIArmature("UI_shop", _effectType[frame].up, ctnUp, true, nil)
    local ani2 = self:createUIArmature("UI_shop", _effectType[frame].down, ctnDown, true, nil)
    ani1:setScale(1)
    ani1:pos(1, 0)
    ani2:setScale(0.8)
    ani2:pos(1, 0)
    return ani1, ani2
end

function LuckyGuyRewardView:clickOk(  )
    self:startHide();
end

return LuckyGuyRewardView;