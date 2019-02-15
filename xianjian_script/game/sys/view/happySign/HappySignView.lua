local HappySignView = class("HappySignView", UIBase);


--isLoadingShow ---是不是登入显示的条件  --wk
function HappySignView:ctor(winName,isLoadingShow)
    HappySignView.super.ctor(self, winName);
    self.selectInfo = nil
    self.isLoadingShow = isLoadingShow 
end

function HappySignView:loadUIComplete()
     -- FuncArmature.loadOneArmatureTexture("UI_shop", nil, true)
    self:registerEvent()

    --[[
        特别注意： 这里的奇侠id都是写死在这的  
        如果七登策划更改奇侠奖励这里需要做对应的修改
        self.rewardId  对应的是第二，三，七天登陆可领取的奇侠
        self.action_order 后来第七天改成可选 三选一 所以第三天后需要轮流播放立绘 这里是播放顺序
        self.posAndScale 这里是创建spine时需要的参数 位置，缩放比，以及翻转系数
    ]]
    self.rewardId = {
        LINYUERU = 5023,
        YUNTIANHE = 5027,
        TANGXUEJIAN = 5015,
    }

    self.action_order = {
        [1] = 5026,
        [2] = 5005,
        [3] = 5015 
    }

    --七天后固定显示 小蛮  
    self.sevenDayId = 5019

    self.posAndScale = {
        ["5023"] = {x = 280, y = 13, scale = 0.88, rotation = 0},
        ["5027"] = {x = 280, y = 0, scale = 0.8, rotation = 0},
        ["5015"] = {x = 230, y = 30, scale = 0.8, rotation = 0},
        ["5026"] = {x = 150, y = 70, scale = 0.8, rotation = -180},
        ["5005"] = {x = 100, y = 30, scale = 0.8, rotation = -180},
        ["5019"] = {x = 260, y = 10, scale = 0.8, rotation = -180},
    }
    self:updateUI()
    --分辨率适配
    --关闭按钮右上
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_fanhui,UIAlignTypes.RightTop) 
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_shipei,UIAlignTypes.Left) 
 --    FuncCommUI.setScale9Align(self.widthScreenOffset,self.panel_1.ctn_san,UIAlignTypes.Left)
 --    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_baolaoer,UIAlignTypes.Left)

    self.panel_1:setVisible(false)   --隐藏 已经做到特效里了
    self.panel_2:setVisible(false)   --隐藏已经做到特效 只需要替换进名字

    self.rich_1:setVisible(false)
    self.panel_lxhbao:setVisible(false)
    self.panel_baolaoer:setVisible(false)
    self.panel_shipei:setVisible(false)
    self.panel_shipei.btn_hong:setVisible(false)
    self.rich_1:pos(0, 38)
    self.ctn_san:pos(-65, -413)
    self.btn_fanhui:pos(-29, 15)
    self.panel_shipei:pos(0, 0)
    self.panel_shipei.btn_hong:pos(-60, 35)
	-- --初始化更新ui
    -- self.panel_baoxxx:setVisible(false)
    self.showAni = self:createUIArmature("UI_qiandao","UI_qiandao_shujuan", self._root, true)
    -- self.showAni:setPosition(self.showAni:getPositionX() - 272, self.showAni:getPositionY() - 294)

    FuncArmature.changeBoneDisplay(self.showAni, "node3", self.btn_fanhui)
    FuncArmature.changeBoneDisplay(self.showAni, "node", self.panel_shipei)
    FuncArmature.changeBoneDisplay(self.showAni, "node_juese", self.ctn_san)
    FuncArmature.changeBoneDisplay(self.showAni, "node_mingzi", self.rich_1)
    FuncArmature.changeBoneDisplay(self.showAni, "node4", self.panel_shipei.btn_hong)

    self.leftDayAnim = self.showAni:getBoneDisplay("node_day")
    self.leftDayAnim:playWithIndex(self.showFrame - 1)

    self.saoguang = self.showAni:getBoneDisplay("layer1a")
    self.saoguangAnim = self.saoguang:getBoneDisplay("day")
    self.saoguangAnim:playWithIndex(self.showFrame - 1)

    self.saoguang1 = self.showAni:getBoneDisplay("layer1b")
    self.saoguangAnim1 = self.saoguang1:getBoneDisplay("day")
    self.saoguangAnim1:playWithIndex(self.showFrame - 1)

    self.leftDayBone = self.showAni:getBone("node_day")
    self.leftTipsBone = self.showAni:getBone("zi")
    self.leftDiBone = self.showAni:getBone("di")
    self.saoguangBone = self.showAni:getBone("layer1a")
    self.saoguangBone1 = self.showAni:getBone("layer1b")
    self.layer2_copy = self.showAni:getBone("layer2_copy")
    self.layer2b = self.showAni:getBone("layer2b")
    self.btn_node = self.showAni:getBone("node4")
    if HappySignModel:getOnlineDays() >= 7 then
        self:hideSaoGuangAnim()
    end

    self.btn_node:setVisible(false)
    self.showAni:startPlay(false, false)
    self.showAni:runEndToNextLabel(0, 1, true)
    self.showAni:registerFrameEventCallFunc(13, 1, function ()
            self.btn_node:setVisible(true)
        end)
end

function HappySignView:hideSaoGuangAnim()
    self.leftDayBone:setVisible(false)
    self.leftTipsBone:setVisible(false)
    self.leftDiBone:setVisible(false)
    -- self.saoguang:setVisible(false)
    -- self.saoguang1:setVisible(false)
    self.saoguangBone:setVisible(false)
    self.saoguangBone1:setVisible(false)
    -- self.layer2_copy:setVisible(false)
    -- self.layer2b:setVisible(false)
end

function HappySignView:registerEvent()
    HappySignView.super.registerEvent();
    --全屏特效 没法注册点击外部关闭事件
    -- self:registClickClose("out")
    self.btn_fanhui:setTap(c_func(self.press_btn_close, self))
    EventControler:addEventListener(HappySignEvent.ONLINED_DAYS_CHANGED_EVENT, self.updateUIByOnlineDay, self)
    EventControler:addEventListener(HappySignEvent.GET_HAPPYSIGN_OPTION_REWARD, self.getOptionReward, self)
end

function HappySignView:press_btn_close()
    if self.isLoadingShow then
        self:startHide()
        EventControler:dispatchEvent(HomeEvent.SHOW_CHONGZHI_UI_EVENT)
        return
    end
    self:startHide()
end

function HappySignView:updateUIByOnlineDay()
    if HappySignModel:isHappySignFinish() then
        self:startHide()
    else
        self:updateUI()
    end  
end

function HappySignView:initData()
    local allDatas = HappySignModel:getSortItems()
    self.allDatas = allDatas
    for i, v in ipairs(allDatas) do
        if v.isSign == false then           
            self.index = i
            self.selectInfo = allDatas[self.index]
            break
        end        
    end    
    if self.index == nil then
        self.index = table.length(allDatas)
        self.selectInfo = allDatas[self.index]
    end
end

--刷新sign列表
function HappySignView:updateUI()
    self:initData()
    HappySignModel:checkShowRed()
    
    self.panel_shipei.panel_baoxxx.panel_zhong:setVisible(false)
    self:updateScrollList()
    self:initView() 
end

function HappySignView:updateScrollList()
    local createFunc = function (itemData, itemIndex)
        local view = UIBaseDef:cloneOneView(self.panel_shipei.panel_baoxxx.panel_zhong)
        self:updateItem(view, itemData)
        return view
    end
    local reuseUpdateCellFunc = function (itemData, view, itemIndex)
        self:updateItem(view, itemData)
        return view 
    end
    
    local _scrollParams = {
            {
                data = self.allDatas,
                createFunc= createFunc,
                perFrame = 1,
                offsetX = 15,
                offsetY = 14,
                itemRect = {x = 0, y = -425, width = 155, height = 425},
                heightGap = 0,
                perNums = 1,
                updateCellFunc = reuseUpdateCellFunc,
            }
        }
    self.panel_shipei.panel_baoxxx.scroll_1:styleFill(_scrollParams)
    self.panel_shipei.panel_baoxxx.scroll_1:hideDragBar()
    self.panel_shipei.panel_baoxxx.scroll_1:refreshCellView(1)
    self.panel_shipei.panel_baoxxx.scroll_1:gotoTargetPos(self.index, 1, 1, 0)
end


function HappySignView:initView()
    if self.selectInfo.isSign then
        self.panel_shipei.btn_hong:setVisible(true)
    else
        self.panel_shipei.btn_hong:setVisible(true)
        if HappySignModel:canHappySign(tonumber(self.selectInfo.hid)) then
            -- FilterTools.clearFilter( self.panel_shipei.btn_hong)
            if not self.ani then
                self.ani = self:createUIArmature("UI_common","UI_common_saoguang", self.panel_shipei.btn_hong:getUpPanel(), true);
                self.ani:setPosition(self.ani:getPositionX() + 75, self.ani:getPositionY() - 35)
                self.ani:setScaleX(0.8)
                self.ani:setScaleY(0.72)
            else
                self.ani:setVisible(true)
            end
        else
            -- FilterTools.setGrayFilter(self.panel_shipei.btn_hong)
            if self.ani then
                self.ani:setVisible(false)
            end
       end
    end

    self.panel_shipei.btn_hong:setTouchedFunc(c_func(self.clickGetReward, self, self.selectInfo))
    local signId = HappySignModel:getSignId()
    local canSignNum = HappySignModel:getOnlineDays()
    local signedNum = 1
    for k,v in pairs(signId) do
        if v == 1 then
            signedNum = signedNum + v
        end
    end

    local partnerId = nil
    local maskSprite = display.newSprite(FuncRes.iconOther("activity_bg_zhezhao"))
    maskSprite:anchor(0, 0)
    if canSignNum <= 1 then
        partnerId = self.rewardId.LINYUERU          
    elseif canSignNum <= 2 then
        partnerId = self.rewardId.YUNTIANHE     
    else
        if canSignNum > 7 and signedNum >= 7 then
            self.ctn_san:stopAllActions()
            partnerId = self.sevenDayId
        else
            partnerId = self.rewardId.TANGXUEJIAN
            if not self.hasPlayed then
                self:delayCall(c_func(self.startOneAction, self), 3)
                self.hasPlayed = true
            end
        end
    end

    local params = self.posAndScale[tostring(partnerId)]
    local spine = FuncPartner.getPartnerOrCgarLiHui(partnerId)
    spine:setPosition(params.x, params.y)
    spine:setRotationSkewY(0)
    spine:setScale(params.scale)
    local partnerName = FuncPartner.getPartnerName(partnerId)

    self.rich_1:setString(partnerName)  
    self.showFrame = canSignNum
    if self.showFrame >= 3 and self.showFrame < 7 then
        self.showFrame = 7 - self.showFrame
    else
        self.showFrame = 1
    end

    spine = FuncCommUI.getMaskCan(maskSprite, spine)
    self.ctn_san:removeAllChildren()
    self.ctn_san:addChild(spine)
    -- self.ctn_san:setPosition(-3, -553)

    if self.leftDayAnim then
        self.leftDayAnim:playWithIndex(self.showFrame - 1)
    end

    if self.saoguangAnim then
        self.saoguangAnim:playWithIndex(self.showFrame - 1)
    end
    -- self.panel_shipei.mc_denglusong:showFrame(showFrame)
    -- self.panel_1.panel_1.mc_1:showFrame(showFrame)
    -- if canSignNum >= 7 then
    --     self.panel_1.panel_1:setVisible(false)
    -- else
    --     self.panel_1.panel_1:setVisible(true)
    -- end
    if self.leftDayBone and HappySignModel:getOnlineDays() >= 7 then
        self:hideSaoGuangAnim()
    end
    self.panel_shipei.panel_shengtian.mc_num:showFrame(signedNum)
end

--第三天后轮流播放三选一礼包里的奇侠立绘
function HappySignView:startOneAction()
    self.order = 1
    local actFunc = function ()
        if self.order > 3 then
            self.order = 1
        end

        self.ctn_san:removeAllChildren()
        local maskSprite = display.newSprite(FuncRes.iconOther("activity_bg_zhezhao"))
        maskSprite:anchor(0, 0)
        local spine = FuncPartner.getPartnerOrCgarLiHui(self.action_order[self.order])
        local params = self.posAndScale[tostring(self.action_order[self.order])]
        spine:setPosition(params.x, params.y)
        spine:setRotationSkewY(params.rotation)
        spine:setScale(params.scale)
        local partnerName = FuncPartner.getPartnerName(self.action_order[self.order])
        local spine = FuncCommUI.getMaskCan(maskSprite, spine)
        self.ctn_san:addChild(spine)
        self.rich_1:setString(partnerName)
        self.order = self.order + 1
    end

    local sequenceActs = act.sequence(act.fadeout(0.5), act.callfunc(actFunc), act.fadein(0.5), act.delaytime(2))
    self.ctn_san:runAction(cc.RepeatForever:create(sequenceActs))
end

function HappySignView:updateTagStatus(_info)
    if self.selectInfo == _info then
        return
    else
        -- dump(self.selectInfo, "\n\nself.selectInfo===", 5)
        -- dump(_info, "\n\n_info====", 5)
        local lastView = self.panel_shipei.panel_baoxxx.scroll_1:getViewByData(self.selectInfo)
        if lastView then
            lastView.panel_xuanzhong:removeAllChildren()
            lastView.panel_xuanzhong:setVisible(false)
            lastView.mc_di:showFrame(1)
        end               
        self.selectInfo = _info
        local curView = self.panel_shipei.panel_baoxxx.scroll_1:getViewByData(self.selectInfo)
        curView.panel_xuanzhong:setVisible(true)
        curView.mc_di:showFrame(2)
        self:creatAnim(curView)
    end

    if self.selectInfo.isSign then
        self.panel_shipei.btn_hong:setVisible(true)
    else
        self.panel_shipei.btn_hong:setVisible(true)
        if HappySignModel:canHappySign(tonumber(self.selectInfo.hid)) then
            -- FilterTools.clearFilter(self.panel_shipei.btn_hong )
            if self.ani then
                self.ani:setVisible(true)
            end           
        else
            -- FilterTools.setGrayFilter(self.panel_shipei.btn_hong)
            if self.ani then
                self.ani:setVisible(false)
            end
        end
        self.panel_shipei.btn_hong:setTouchedFunc(c_func(self.clickGetReward, self, self.selectInfo))
    end

end

function HappySignView:clickGetReward(info)
    if self.selectInfo.isSign then
        WindowControler:showTips("该奖励已领取")
    else
        if HappySignModel:canHappySign(tonumber(info.hid)) then
            self:pressLingquBtn(info) 
            -- self.panel_shipei.btn_hong:setTouchEnabled(false)
        else
            -- 条件不足 
            WindowControler:showTips(string.format(GameConfig.getLanguage("#tid_sign_1010"),HappySignModel:willSignDayNums(info.hid)))
        end
    end  
end

function HappySignView:creatAnim(view)
    view.panel_xuanzhong:removeAllChildren()
    local xuanAni = self:createUIArmature("UI_qiandao","UI_qiandao_zhuanguang", view.panel_xuanzhong, true)
    xuanAni:setPosition(xuanAni:getPositionX() - 15, xuanAni:getPositionY() - 108)
    xuanAni:setVisible(true)
end
--signItem信息
function HappySignView:updateItem(view, info)    
    local rewardNum = #info.reward
    local effectPos = info.position
    if self.selectInfo == info and HappySignModel:isHappySignFinish() == false then
        view.panel_xuanzhong:setVisible(true)
        view.mc_di:showFrame(2)
        self:creatAnim(view)
    else
        view.panel_xuanzhong:setVisible(false)
        view.mc_di:showFrame(1)
    end

    if info.isSign then
        view.panel_ylq:setVisible(true)
    else
        view.panel_ylq:setVisible(false)
    end
    
    local firstReward = string.split(info.reward[1], ",")
    if firstReward and tostring(firstReward[1]) == FuncDataResource.RES_TYPE.OPTION then
        view.mc_huo:showFrame(2)
        local optionId = firstReward[2]
        local optionRewards = FuncItem.getOptionInfoById(optionId)
        local items_panel = view.mc_huo.currentView
        for i = 1, 4 do
            local index = i
            local itemData = optionRewards[index]
            local panel = items_panel["panel_"..index]
            if itemData then
                panel:setVisible(true)
                if index > 1 then
                    items_panel["txt_"..(index - 1)]:setVisible(true)
                end
                local itemRewardView = panel.UI_1
                itemRewardView:setResItemData({reward = itemData})
                itemRewardView:showResItemName(false)

                --注册点击事件 弹框
                local  needNum,hasNum,isEnough ,resType,resId = UserModel:getResInfo(itemData)
                FuncCommUI.regesitShowResView(itemRewardView, resType, needNum, resId,itemData,true,true)

                self:updateItemEffect(itemData, effectPos, panel, index) 
            else
                panel:setVisible(false)
                if index > 1 then
                    items_panel["txt_"..(index - 1)]:setVisible(false)
                end
            end
        end
    else
        view.mc_huo:showFrame(1)
        for i = 1, 4 do
            local index = i
            local itemData = info.reward[i]
            local data = string.split(itemData, ",")
            local rewardType = data[1]
            local itemRewardView 
            local panel = view.mc_huo.currentView["panel_"..i]
            if i <= rewardNum then
                panel:setVisible(true)            
                itemRewardView = panel.UI_1
            
                itemRewardView:setResItemData({reward = itemData})
                itemRewardView:showResItemName(false)

                --注册点击事件 弹框
                local  needNum,hasNum,isEnough ,resType,resId = UserModel:getResInfo(itemData)
                FuncCommUI.regesitShowResView(itemRewardView, resType, needNum, resId,itemData,true,true)

                -- 给需要添加特效的物品添加特效  位置对应effectPos  (info.position)
                -- local aniCtn = itemRewardView:getAnimationCtn() 
                self:updateItemEffect(itemData, effectPos, panel, index)            
            else
                panel:setVisible(false)
            end           
        end
    end

    --第几天
    view.mc_number:showFrame(tonumber(info.hid) + 1)
    -- view:setTouchedFunc(c_func(self.updateTagStatus, self, info))
end

--添加item上的闪光特效
function HappySignView:updateItemEffect(itemData, effectPos, panel, index)
    local ctnUp = panel.ctn_shang
    local ctnDown = panel.ctn_xia
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

function HappySignView:clickItemView(view)
    -- body
end
-- 服务器返回结果
function HappySignView:requestMailBack(event)

    --如果请求失败 
    if not event.result then
        return
    end
    -- 签到成功

    -- set signId 
    HappySignModel:setHappySignId(self.selectInfo.hid)
    -- EventControler:dispatchEvent(HappySignEvent.SIGN_CHANGED)
    --展示 获得的奖励
    self.isPartnerReward = false
    local reward = self.selectInfo.reward
    local firstReward = string.split(reward[1], ",")
    if tostring(firstReward[1]) == FuncDataResource.RES_TYPE.OPTION and self.rewardIndex then
        local optionId = firstReward[2]
        local optionRewards = FuncItem.getOptionInfoById(optionId)
        reward = {optionRewards[tonumber(self.rewardIndex)]}
        local reward_str = string.split(optionRewards[tonumber(self.rewardIndex)])

        if tonumber(self.selectInfo.hid) == 7 then 
            if tostring(reward_str[1]) == FuncDataResource.RES_TYPE.PARTNER then    
                self.rewardId.TANGXUEJIAN = reward_str[2]
                self.isPartnerReward = true
            end
        end
        
        EventControler:dispatchEvent(HappySignEvent.HAPPYSIGN_OPTION_REWARD_CALLBACK)
    end

    self:showRewardLogic(reward)
end

function HappySignView:handleReward(reward)
    local handledReward = {}
    for i,v in ipairs(reward) do
        local str_arr = string.split(v, ",")
        if tostring(str_arr[1]) == FuncDataResource.RES_TYPE.PARTNER and PartnerModel:isHavedPatnner(str_arr[2]) then
            local debrisNum = FuncPartner.getSameCardDebrisById(str_arr[2])
            handledReward[i] = string.format("%d,%d,%d", FuncDataResource.RES_TYPE.ITEM, str_arr[2], debrisNum)
        else
            handledReward[i] = v
        end
    end
    return handledReward
end

function HappySignView:showRewardLogic(reward)
    if self.needHandled then
        reward = self:handleReward(reward)
    end

    local hid = self.selectInfo.hid
    local onlineDay = HappySignModel:getOnlineDays()
    if not HappySignModel:isFirstPeriodFinish() then
        if tonumber(hid) == 1 then
            FuncCommUI.startFullScreenRewardView(reward, c_func(self.clickCallBack, self))
        elseif tonumber(hid) == 2 then
            local param = {
                id = self.rewardId.LINYUERU,
                skin = "1",
            }

            WindowControler:showWindow("PartnerSkinFirstShowView", param, function ()
                    FuncCommUI.startFullScreenRewardView(reward, c_func(self.clickCallBack, self))
                end)
        elseif tonumber(hid) <= 6 then
            if tonumber(hid) == 3 then
                local param = {
                    id = self.rewardId.YUNTIANHE,
                    skin = "1",
                }

                WindowControler:showWindow("PartnerSkinFirstShowView", param, function ()
                        FuncCommUI.startFullScreenRewardView(reward, c_func(self.clickCallBack, self))
                    end)
            else
                FuncCommUI.startFullScreenRewardView(reward, c_func(self.clickCallBack, self))
            end
        elseif tonumber(hid) <= 7 then
            if self.isPartnerReward then
                local param = {
                    id = self.rewardId.TANGXUEJIAN,
                    skin = "1",
                }


                WindowControler:showWindow("PartnerSkinFirstShowView", param, function ()
                            FuncCommUI.startFullScreenRewardView(reward, c_func(self.clickCallBack, self))
                        end)
            else
                FuncCommUI.startFullScreenRewardView(reward, c_func(self.clickCallBack, self))  
            end
        else
            FuncCommUI.startFullScreenRewardView(reward, c_func(self.clickCallBack, self))    
        end
    else
        FuncCommUI.startFullScreenRewardView(reward, c_func(self.clickCallBack, self))
    end
end

function HappySignView:clickCallBack()
    local hid = self.selectInfo.hid
    local onlineDay = HappySignModel:getOnlineDays()
    if not HappySignModel:isFirstPeriodFinish() then
        if tonumber(hid) == 1 then
            WindowControler:showWindow("HappySignShowView1")
        elseif tonumber(hid) == 2 then
            WindowControler:showWindow("HappySignShowView2")
        elseif tonumber(hid) <= 6 then
            WindowControler:showWindow("HappySignShowView3", tonumber(hid))
        end
    end

    local allDatas = HappySignModel:getSortItems()
    for i, v in ipairs(allDatas) do
        if v.isSign == false then
            self.selectInfo = allDatas[i]
            self.index = i
            break
        end        
    end
    if self.index == nil then
        self.index = table.length(allDatas)
    end

    EventControler:dispatchEvent(UserEvent.BUTTON_REFRESH_EVENT) 
    self:updateUI()
end

--领取一条奖励
function HappySignView:pressLingquBtn(itemInfo)
    if FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.HAPPYSIGN) then
        local firstReward = string.split(itemInfo.reward[1], ",")
        if tostring(firstReward[1]) == FuncDataResource.RES_TYPE.OPTION then
            local optionId = firstReward[2]
            -- local optionRewards = FuncItem.getOptionInfoById(optionId)
            local params = {
                optionId = optionId,
                isHappySign = true
            }
            WindowControler:showWindow("ItemOptionView", nil, nil, params)
        else
            self.needHandled = self:setNeedHandledStatus(itemInfo)
            HappySignServer:mark(tonumber(itemInfo.hid),c_func(self.requestMailBack, self));
        end       
    end
end

function HappySignView:addAnimation(reward, ctnUp, ctnDown)
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
    ani1:setScale(0.8)
    ani1:pos(-2.5, 1)
    ani2:setScale(0.8)
    ani2:pos(-4, 1)
    return ani1, ani2
end

function HappySignView:getOptionReward(event)
    self.rewardIndex = event.params.index
    self.needHandled = self:setNeedHandledStatus(self.selectInfo, self.rewardIndex)
    HappySignServer:mark(tonumber(self.selectInfo.hid),c_func(self.requestMailBack, self), self.rewardIndex)
end

function HappySignView:setNeedHandledStatus(itemInfo, index)
    if not index then
        for i,v in ipairs(itemInfo.reward) do
            local str_arr = string.split(v, ",")
            if tostring(str_arr[1]) == FuncDataResource.RES_TYPE.PARTNER and PartnerModel:isHavedPatnner(str_arr[2]) then
                return true
            end
        end
    else
        local reward = itemInfo.reward
        local firstReward = string.split(reward[1], ",")
        if tostring(firstReward[1]) == FuncDataResource.RES_TYPE.OPTION and index then
            local optionId = firstReward[2]
            local optionRewards = FuncItem.getOptionInfoById(optionId)
            reward = {optionRewards[tonumber(index)]}
            local str_arr = string.split(optionRewards[tonumber(index)], ",")
            if tostring(str_arr[1]) == FuncDataResource.RES_TYPE.PARTNER and PartnerModel:isHavedPatnner(str_arr[2]) then
                return true
            end
        end
    end
    
    return false
end

return HappySignView;
