-- WonderlandMainView
--须臾仙境主界面
--2017-12-25 10:00
--@Author:WK

local WonderlandMainView = class("WonderlandMainView", UIBase);

local rewardType = {
    challenge = 1,  --挑战
    sweeping = 2,  --扫荡
}

function WonderlandMainView:ctor(winName,checkpoint_type)
    WonderlandMainView.super.ctor(self, winName);
    if checkpoint_type ~= nil then
        self.checkpoint_type = tonumber(checkpoint_type)
    end

    self.selectFloor = 1  --默认值

end

function WonderlandMainView:loadUIComplete()

	self:registerEvent();

	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back, UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_icon, UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_rule, UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_res, UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.scroll_list, UIAlignTypes.Right)   
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_gl, UIAlignTypes.RightBottom) 
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_1, UIAlignTypes.Left)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_2, UIAlignTypes.Left)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_shop, UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_landi, UIAlignTypes.Right)
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_landi.scale9_jiugongge, UIAlignTypes.Right)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_3, UIAlignTypes.MiddleBottom)
    self.lihui_X = self.ctn_lihui:getPositionX()
    self.lihui_Y = self.ctn_lihui:getPositionY()

     local size2 = self.panel_landi.scale9_jiugongge:getContentSize()
    -- self.panel_landi.scale9_jiugongge:size(GameVars.width - 160 - GameVars.toolBarWidth,138)
    self.panel_landi.scale9_jiugongge:setScaleY(GameVars.height/size2.height)
    -- self.panel_landi.scale9_jiugongge:setScaleX(1.)
    local x = self.panel_landi.scale9_jiugongge:getPositionX()
    local y = self.panel_landi.scale9_jiugongge:getPositionY()
    self.panel_landi.scale9_jiugongge:setPosition(cc.p(x,y+ GameVars.UIOffsetY))


	self.btn_back:setTouchedFunc(c_func(self.clickButtonBack, self),nil,true);
    self.btn_rule:setTouchedFunc(c_func(self.helpButton, self),nil,true);
    self.btn_gl:setTouchedFunc(c_func(self.addCustomsClearance, self),nil,true);
    self.btn_shop:setTouchedFunc(c_func(self.showShopView, self),nil,true);
    local selectFloor = WonderlandModel:getSelectBossType()
    if selectFloor ~= nil then
        self.checkpoint_type = selectFloor
    end


    self:setRightListData()
    self:setRightAndLeftButton()

    self:getPaiHangBang(self.checkpoint_type)

    local dayNum = FuncWonderland.isOnTime()  --开服的天数

    echo("======dayNum========",dayNum)


end 

function WonderlandMainView:showShopView()
    local shoptype,level  = FuncCommon.SYSTEM_NAME.WONDER_SHOP
    local isopen = FuncCommon.isSystemOpen(shoptype)
    if isopen then
        WindowControler:showWindow("ShopView",FuncShop.SHOP_TYPES.WONDER_SHOP)
    else
        local _str = string.format(GameConfig.getLanguage("#tid_wonderland_ui_004"),tostring(level))
        WindowControler:showTips(_str); 
    end
end


--通关攻略
function WonderlandMainView:addCustomsClearance()
    local floor = self.selectFloor
    local _type = self.checkpoint_type
    local diifID = FuncWonderland.getLevelIdByfloor(_type,floor)
    local arrayData = {
        systemName = FuncCommon.SYSTEM_NAME.WONDERLAND,---系统名称  --临时用来测试
        diifID = diifID,  --关卡ID
    }
    echo("========关卡ID=========",diifID)
    RankAndcommentsControler:showUIBySystemType(arrayData)

end


function WonderlandMainView:registerEvent()
	WonderlandMainView.super.registerEvent();
	EventControler:addEventListener(WonderlandEvent.WONDERLAND_SWEEP_SUCCESS,self.eventRefreshUI,self)
    EventControler:addEventListener("COUNT_TYPE_WONDERLAND_FIRE_NUM",self.refreshAllUI,self)
     --屏幕旋转回调
    EventControler:addEventListener(PCSdkHelper.EVENT_SCREEN_ORIENTATION ,self.screenRotation,self)
    EventControler:addEventListener(BattleEvent.BEGIN_BATTLE_FOR_FORMATION_VIEW, self.enterBattle, self)
end

function WonderlandMainView:eventRefreshUI()
    self.eventRefreshAllData = true
    self:setRightListData()
    self:middleChallengInit(self.selectFloor)
    
end

function WonderlandMainView:refreshAllUI()
    self.checkpoint_type = nil
    self:setRightListData()
end

--设置右边滚动条数据
function WonderlandMainView:setRightListData()
	self.listdata = FuncWonderland.getdifferTypeData()

    -- dump(self.listdata,"111111111111111111111")
    self.panel_yq:setVisible(false)
	local createRankItemFunc = function(itemData,index)
    	local baseCell = UIBaseDef:cloneOneView(self.panel_yq);
        self:listcellviewData(baseCell, itemData,index)
        return baseCell;
    end

    local updateCellFunc = function (itemData,view)
        self:listcellviewData(view, itemData)
    end


    local  _scrollParams = {
        {
            data = self.listdata,
            createFunc = createRankItemFunc,
            -- updateCellFunc= updateCellFunc,
            perNums = 1,
            offsetX = 36,
            offsetY = 5,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -84, width = 124, height = 84},
            perFrame = 0,
        }
    }    
    self.scroll_list:refreshCellView(1)
    self.scroll_list:styleFill(_scrollParams)
    self.scroll_list:hideDragBar()
    -- for k,v in pairs(listdata) do
    -- 	if self.checkpoint_type ~= nil then
	   --  	-- if tonumber(v.id) == tonumber(self.checkpoint_type) then
	   --  	-- 	local itemData = v
	   --  	-- 	self:TheMiddleDataView(itemData)
	   --  	-- end
	   --  end
    -- end
end


function WonderlandMainView:getRedIsShow()
    local _type = self.checkpoint_type
    local challengCount = WonderlandModel:getBCountyType(tonumber(_type))  --挑战次数
    local count = FuncWonderland.getChallengCount() 
    self.panel_3.txt_1:setString(GameConfig.getLanguage("#tid_wonderland_ui_005")..(count - challengCount))
    if count - challengCount <= 0 then
        return false 
    else
        return true 
    end
    return false
end

--右边滚动条列表  关卡选择
function WonderlandMainView:listcellviewData(baseCell, itemData,index)
    echo("======index========",index)
    -- dump(itemData,"2222222222")
    local btn_mc = baseCell.mc_1
    local titlename = itemData.data.name
    local name = GameConfig.getLanguage(titlename)
    btn_mc:getViewByFrame(1).btn_1:getUpPanel().mc_1:getViewByFrame(1).txt_1:setString(name)   --:showFrame(itemData.id)---txt_1:setString(name)
    btn_mc:getViewByFrame(2).btn_1:getUpPanel().mc_1:getViewByFrame(1).txt_1:setString(name) --showFrame(itemData.id)--.txt_1:setString(name)
    btn_mc:getViewByFrame(1).btn_1:getDownPanel().mc_1:getViewByFrame(1).txt_1:setString(name) --showFrame(itemData.id)--.txt_1:setString(name)
    btn_mc:getViewByFrame(2).btn_1:getDownPanel().mc_1:getViewByFrame(1).txt_1:setString(name) --showFrame(itemData.id) --.txt_1:setString(name)
    -- btn_mc.currentView.panel_red:setVisible(false)
    local _type = itemData.id
    local challengCount = WonderlandModel:getBCountyType(tonumber(_type))  --挑战次数
    local count = FuncWonderland.getChallengCount() 
    -- self.panel_3.txt_1:setString(GameConfig.getLanguage("#tid_wonderland_ui_005")..(count - challengCount))
    if count - challengCount <= 0 then
        btn_mc:getViewByFrame(1).panel_red:setVisible(false)
        btn_mc:getViewByFrame(2).panel_red:setVisible(false)
    else
        btn_mc:getViewByFrame(1).panel_red:setVisible(true)
        btn_mc:getViewByFrame(2).panel_red:setVisible(true)
    end

    if itemData.open then
        FilterTools.clearFilter(btn_mc)
        btn_mc:setTouchedFunc(c_func(self.selectDiffType, self,itemData),nil,true);
    else
        btn_mc:getViewByFrame(1).panel_red:setVisible(false)
        btn_mc:getViewByFrame(2).panel_red:setVisible(false)
        FilterTools.setGrayFilter(btn_mc)
        btn_mc:setTouchedFunc(c_func(self.notOpen, self,itemData),nil,true);
    end

    if self.checkpoint_type ~= nil then
        if itemData.id == self.checkpoint_type then
            btn_mc:showFrame(2)
            self:middleDataView()
        end
    elseif index == 1 then
        self.checkpoint_type = itemData.id
        btn_mc:showFrame(2)
        self:middleDataView()
    end

end

function WonderlandMainView:notOpen(itemData)
    local time = itemData.time
    local _str = FuncTranslate._getLanguageWithSwap("#tid_wonderland_ui_008",time) --string.format(GameConfig.getLanguage("#tid_wonderland_ui_008"),tostring(time))
    WindowControler:showTips(_str); 
end


--中间数据处理
function WonderlandMainView:middleDataView()
    self:middleSpineInit()
    self:refreshUI(self.selectFloor)
end


function WonderlandMainView:refreshUI(floor)
    self:skilllistIcon(floor) 
    self:partnerlistIcon(floor)
    self:middleChallengInit(self.selectFloor)
end



-- 设置副本描述
function WonderlandMainView:setdiffDis()

    local floor = self.selectFloor
    local _type = self.checkpoint_type
    local dis = FuncWonderland.getWonderLandMiaoShu(_type,floor)
    -- echoError("======dis======",dis)
    self.rich_1:setString(dis)
end






function WonderlandMainView:selectDiffType(itemData)
    echo("=======选择的兽======",itemData.id)
    if itemData.id == self.checkpoint_type then
        return 
    end
    self.eventRefreshAllData = false
    local oldData = nil
    for k,v in pairs(self.listdata) do
        if v.id == self.checkpoint_type then
            oldData = v
        end
    end
     local newData = nil
    for k,v in pairs(self.listdata) do
        if v.id == itemData.id then
            newData = v
        end
    end


    local ctnView1 = self.scroll_list:getViewByData(oldData)
    ctnView1.mc_1:showFrame(1)
    local ctnView2 = self.scroll_list:getViewByData(newData)
    ctnView2.mc_1:showFrame(2)
    self.checkpoint_type = itemData.id
    self:middleDataView()
    self:getPaiHangBang(self.checkpoint_type)

    -- local _type = self.checkpoint_type
    -- local challengCount = WonderlandModel:getBCountyType(tonumber(_type))  --挑战次数
    -- local count = FuncWonderland.getChallengCount() 
    -- self.panel_3.txt_1:setString(GameConfig.getLanguage("#tid_wonderland_ui_005")..(count - challengCount))
    -- if count - challengCount <= 0 then
    --     btn_mc.currentView.panel_red:setVisible(false)
    -- else
    --     btn_mc.currentView.panel_red:setVisible(true)
    -- end

end


---[[
--中间关卡立绘处理
function WonderlandMainView:middleSpineInit()

    -----添加立绘
    local _type = self.checkpoint_type
    self.initfloor = WonderlandModel:getMaxfloor(_type)  --挑战到第几层  ---服务器数据
    echo("=====中间关卡立绘处理=====",self.initfloor)
    local floor = 0
    if self.initfloor >= FuncWonderland.MaxFloor then
        floor = self.initfloor
    else
        floor = self.initfloor + 1

    end
    if not self.eventRefreshAllData then
        self:setSpineView(floor)
    end

end
--]]


--中间挑战按钮处理
function WonderlandMainView:middleChallengInit(floor)

    echo("=======中间挑战按钮处理===========",floor)
    local _type = self.checkpoint_type
	local challengbtn =  self.panel_3.mc_btn  ---挑战按钮
    local isSweeping = WonderlandModel:judgeSweepOrChallengle(_type,floor) ---是挑战(false)，还是扫荡（true）
    local challengCount = WonderlandModel:getBCountyType(tonumber(_type))  --挑战次数
    local count = FuncWonderland.getChallengCount() 
    self.panel_3.txt_1:setString(GameConfig.getLanguage("#tid_wonderland_ui_005")..(count - challengCount))
    if count - challengCount <= 0 then
        self.panel_3.txt_1:setColor(cc.c3b(0xff,0x00,0x00))
    else
        self.panel_3.txt_1:setColor(cc.c3b(0x5a,0xa9,0x47))
    end
    FilterTools.clearFilter(challengbtn)
    if self.initfloor == FuncWonderland.MaxFloor then
        if floor == FuncWonderland.MaxFloor -1 then
            self.panel_3.mc_txt:showFrame(2)
            challengbtn:showFrame(2)
            self:rewardDataView(rewardType.sweeping,floor)
            FilterTools.setGrayFilter(challengbtn)
            challengbtn:getViewByFrame(2).btn_1:setTouchedFunc(c_func(self.maxFloorNotSweep, self),nil,true);
            return
        end
    end

    if isSweeping then
        challengbtn:showFrame(2)
        self:rewardDataView(rewardType.sweeping,floor)  --扫荡
        challengbtn:getViewByFrame(2).btn_1:setTouchedFunc(c_func(self.sweepButton, self),nil,true);
        self.panel_3.mc_txt:showFrame(2)
    else
        challengbtn:showFrame(1)
        self.panel_3.mc_txt:showFrame(1)
        self:rewardDataView(rewardType.challenge,floor) --挑战
        challengbtn:getViewByFrame(1).btn_1:setTouchedFunc(c_func(self.challengleButton, self),nil,true);
    end
end
function WonderlandMainView:maxFloorNotSweep()
    local tid = "#tid_wonderland_error_104"
    WindowControler:showTips(GameConfig.getLanguage(tid))
end
--扫荡
function WonderlandMainView:sweepButton()
    local _type = self.checkpoint_type
    local challengCount = WonderlandModel:getBCountyType(tonumber(_type)) 
    local count = FuncWonderland.getChallengCount()
    if count - challengCount <= 0 then
        WindowControler:showTips(FuncWonderland.ErrorString[4])
        return 
    end

    echo("======选中的层数扫荡=========", self.selectFloor)
    
    local params = {
        floor = self.selectFloor,
        bossType = _type,
    }
    WonderlandModel:sweepWonderLand(params)
end

--挑战
function WonderlandMainView:challengleButton()
    echo("======选中的层数挑战=========", self.selectFloor)
    local _type = self.checkpoint_type
    local challengCount = WonderlandModel:getBCountyType(tonumber(_type)) 
    local count = FuncWonderland.getChallengCount()
    if count - challengCount <= 0 then
        WindowControler:showTips(FuncWonderland.ErrorString[3])
        return
    end

    local params = {}
    local tags = {}
    local buffs = FuncWonderland.getBuffsByfloor(_type, self.selectFloor)
    local tags_config = FuncWonderland.getTagsByfloor(_type, self.selectFloor)
    local tagsDescription = nil
    if tags_config then
        for i,v in ipairs(tags_config) do
            local table_tag = string.split(v, ",")
            table.insert(tags, table_tag)
        end
    end

    local attr_addition = FuncWonderland.getWonderLandAtrr(_type, self.selectFloor)
    
    if _type == 3 then
        tagsDescription = FuncWonderland.getWonderLandMiaoShu(_type, self.selectFloor)
    end

    local levelId = FuncWonderland.getLevelIdByfloor(_type, self.selectFloor)
    params[FuncTeamFormation.formation.wonderLand] = {
        floor = self.selectFloor,
        bossType = _type,
        tags = tags,
        tagsDescription = tagsDescription,
        attr_addition = attr_addition,
        raidId = levelId,
    }

    WindowControler:showWindow("WuXingTeamEmbattleView", FuncTeamFormation.formation.wonderLand, params)
end

function WonderlandMainView:enterBattle(params)
    local params = params.params
    local systemId = params.systemId
    if tonumber(systemId) == FuncTeamFormation.formation.wonderLand then
        local formation = params.formation
        local floor = params.params[FuncTeamFormation.formation.wonderLand].floor
        local bossType = params.params[FuncTeamFormation.formation.wonderLand].bossType
        local params = {
            formation = params.formation,
            floor = floor,
            bossType = bossType,
        }
        WonderlandModel:challengeWonderLand(params)
    end
end

-- function WonderlandMainView:doFormationCallBack(event)
--     if event.result then
--          -- echo("----进战斗数据----")
--         if event.result.data then
--             ShareBossModel:setShareBossBattleInfo(event.result.data)
--             local serviceData = event.result.data.battleInfo
--             -- dump(serviceData,"serviceData=====")
--             serviceData.battleLabel = GameVars.battleLabels.shareBossPve

--             local battleInfoData = BattleControler:turnServerDataToBattleInfo(serviceData)
--             -- dump(battleInfoData,"zhandou=====")
--             EventControler:dispatchEvent(TeamFormationEvent.CLOSE_TEAMVIEW)
--             BattleControler:startBattleInfo(battleInfoData)

--         end       
--     end
-- end

---奖励类型  扫荡奖励和挑战
function WonderlandMainView:rewardDataView(_Rewtype,floor)
    local panel =  self.panel_3
    --隐藏奖励的UI
    for i=1,3 do
        panel["UI_"..i]:setVisible(false)
    end
    local _type = self.checkpoint_type
    if _Rewtype == rewardType.challenge then
        local reward = FuncWonderland.getSkillFirstByfloor(_type,floor)
        self:setRewardUI(reward)
    elseif _Rewtype == rewardType.sweeping then
        local reward = FuncWonderland.getSkillSweepByfloor(_type,floor) 
        self:setRewardUI(reward)
    end
end

---设置奖励UI
function WonderlandMainView:setRewardUI(reward)
    dump(reward,"奖励数据 ======")
    local panel =  self.panel_3
    --显示奖励的UI
    for i=1,#reward do
        panel["UI_"..i]:setVisible(true)
        panel["UI_"..i]:setResItemData({reward = reward[i]})
        local  needNum,hasNum,isEnough ,resType,resId = UserModel:getResInfo(reward[i])
        FuncCommUI.regesitShowResView(panel["UI_"..i], resType, needNum, resId,reward[i],true,true)
    end
end

--最左边视图的数据处理
function WonderlandMainView:leftInitData()
	


end

--最左边上面关卡难度选择视图
function WonderlandMainView:leftUpViewData()
    local _type = self.checkpoint_type
    local panel = self.panel_1.panel_2
    -- self.initfloor = 20  --测试
	local floor = self.initfloor   ---- 开启的最高层  扫荡的层
    local maxfloor = floor + 1  ---   --可以挑战的成的层
    local selecttab = {}

    if floor == 0 then
        floor  = 1
    end
    if floor >= FuncWonderland.MaxFloor then
        for i=1,3 do
            if i == 1 then
                selecttab[i] = floor -1
            elseif i == 2 then
                selecttab[i] = floor
            else
                selecttab[i] = floor +1
            end
        end
    else
        for i=1,3 do
            if i == 1 then
                selecttab[i] = floor 
            elseif i == 2 then
                selecttab[i] = floor + 1
            else
                selecttab[i] = floor + 2
            end
        end
    end

   
    local panercent = {
        [1] = 15,
        [2] = 50,
        [3] = 85,
    }
    if self.initfloor == 0 then
        panel.panel_progress.progress_1:setPercent(panercent[1])
    end
    for i=1,3 do
        panel["mc_zhu"..i]:setTouchedFunc(c_func(self.selectFloorFunc, self,i,selecttab),nil,true);

        if selecttab[i] == self.initfloor then
            if selecttab[i] >= FuncWonderland.MaxFloor then
                panel.panel_progress.progress_1:setPercent(50)
            else
                panel.panel_progress.progress_1:setPercent(panercent[i])
            end
        end
    end
     

    for i=1,#selecttab do
        if self.selectFloor ~= nil then
            if selecttab[i] == self.selectFloor then
                self:selectFloorFunc(i,selecttab,true)
                break
            end
        end
    end


end

function WonderlandMainView:selectFloorFunc(index,floorTab,def)
    echo("=======第几个选择1111,选择了第几层===",index,floorTab[index],self.initfloor)
    local _type = self.checkpoint_type
    local panel = self.panel_1.panel_2
    local floor = floorTab[index]
    local initfloor = self.initfloor
    if floor > FuncWonderland.MaxFloor then
        WindowControler:showTips(FuncWonderland.ErrorString[5])
        return 
    end
    if floorTab[index]  - initfloor  >= 2 then
        WindowControler:showTips(FuncWonderland.ErrorString[2])
        return 
    end
    self.selectFloor = floorTab[index]
    local name =  FuncWonderland.getNameByfloor(_type,floor)
    self.panel_1.panel_1.txt_1:setString(" "..name.."   "..floorTab[index]..GameConfig.getLanguage("#tid_wonderland_ui_002"))
    self.panel_1.panel_1.txt_2:setVisible(false)

    if floor >= FuncWonderland.MaxFloor then
        for i=1,3 do
            if i == 1 then
                panel["mc_zhu"..i]:showFrame(1)
                local _str = string.format(GameConfig.getLanguage("#tid_wonderland_ui_006"),tostring(floorTab[i]))
                panel["mc_zhu"..i]:getViewByFrame(1).txt_1:setString(_str)
            elseif i == 2 then
                -- if floorTab[i] <= initfloor + 1 then
                    panel["mc_zhu"..i]:showFrame(2)
                    local _str = string.format(GameConfig.getLanguage("#tid_wonderland_ui_006"),tostring(floorTab[i]))
                    panel["mc_zhu"..i]:getViewByFrame(2).txt_1:setString(_str)
            else
                    panel["mc_zhu"..i]:showFrame(3)
                    local _str = string.format(GameConfig.getLanguage("#tid_wonderland_ui_006"),tostring(floorTab[i]))
                    panel["mc_zhu"..i]:getViewByFrame(3).txt_1:setString(_str)
                -- end
            end
        end

    else
        for i=1,3 do
            local _str = string.format(GameConfig.getLanguage("#tid_wonderland_ui_006"),tostring(floorTab[i]))
            if floor == floorTab[i] then
                panel["mc_zhu"..i]:showFrame(2)
                panel["mc_zhu"..i]:getViewByFrame(2).txt_1:setString(_str)
            else
                if floorTab[i] <= initfloor + 1 then
                    if floorTab[i] > FuncWonderland.MaxFloor then
                        panel["mc_zhu"..i]:showFrame(3)
                        panel["mc_zhu"..i]:getViewByFrame(3).txt_1:setString(_str)
                    else
                        panel["mc_zhu"..i]:showFrame(1)
                        panel["mc_zhu"..i]:getViewByFrame(1).txt_1:setString(_str)
                    end
                else
                    panel["mc_zhu"..i]:showFrame(3)
                    panel["mc_zhu"..i]:getViewByFrame(3).txt_1:setString(_str)
                end
            end
        end
    end

    if self.selectFloor == self.initfloor + 1 then
        self.panel_left:setVisible(true)
        self.panel_right:setVisible(true)
    elseif self.selectFloor  == self.initfloor then
        self.panel_left:setVisible(false)
        self.panel_right:setVisible(true)
    end

    if ( self.initfloor == 0 and self.selectFloor == 1) then
        self.panel_left:setVisible(false)
        self.panel_right:setVisible(true)
    elseif self.initfloor == FuncWonderland.MaxFloor then
        if floor == FuncWonderland.MaxFloor - 2 then
            self.panel_left:setVisible(false)
            self.panel_right:setVisible(true)
        elseif floor == FuncWonderland.MaxFloor - 1 then
            self.panel_left:setVisible(false)
            self.panel_right:setVisible(true)
        elseif floor == FuncWonderland.MaxFloor then
            self.panel_left:setVisible(true)
            self.panel_right:setVisible(true)
        end
    end



    if def then
        if initfloor > 0 and initfloor < FuncWonderland.MaxFloor then
            local panel = self.panel_1.panel_2
            panel.panel_progress.progress_1:setPercent(50)
        end
    end

    --刷新界面
    self:refreshUI(self.selectFloor)
    self:setdiffDis()
    self:replaceSpine(self.selectFloor)
end


function WonderlandMainView:skilllistIcon(floor)
    local panel = self.panel_1.panel_3.panel_skill
    local _type = self.checkpoint_type
    local data = FuncWonderland.getSkillIconByfloor(_type,floor)
    local newdata = {}
    -- dump(data,"111111111111111",8)
    for i=1,#data do
        newdata[i] = {id = i,icon = data[i]}
    end

    panel:setVisible(false)
    local createRankItemFunc = function(itemData)
        local baseCell = UIBaseDef:cloneOneView(panel);
        self:setSkillIconCellView(baseCell, itemData)
        return baseCell;
    end
   -- local updateFunc = function (itemData,baseCell)
   --      self:setSkillIconCellView(baseCell, itemData)
   --  end

    local  _scrollParams = {
        {
            data = newdata,
            createFunc = createRankItemFunc,
            -- updateFunc= updateFunc,
            perNums = 1,
            offsetX = 10,
            offsetY = 5,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -58, width = 65, height = 58},
            perFrame = 0,
        }
    }    
    self.panel_1.panel_3.scroll_1:cancleCacheView();
    self.panel_1.panel_3.scroll_1:styleFill(_scrollParams);
    self.panel_1.panel_3.scroll_1:hideDragBar()
end

function WonderlandMainView:setSkillIconCellView(baseCell, itemData)
    local ctn = baseCell.ctn_1
    ctn:removeAllChildren()
    local skillname = itemData.icon
    local skillinon = display.newSprite(FuncRes.iconSkill(skillname))
    skillinon:setScale(0.6)
    ctn:addChild(skillinon)

    skillinon:setTouchedFunc(c_func(self.skillNodeTouchEnds, self), nil, nil,
         c_func(self.skillNodeTouchStart, self,itemData),
         c_func(self.skillNodeTouchMove, self),
         nil,
         c_func(self.skillNodeTouchEnd, self)  )
end

function WonderlandMainView:skillNodeTouchEnds()

end
function WonderlandMainView:skillNodeTouchStart(itemData)
    local newdata = {
        _type = self.checkpoint_type,
        itemData = itemData,
        floor = self.selectFloor,
    }
   WindowControler:showWindow("WonderlandTipsView",newdata)
end
function WonderlandMainView:screenRotation()
    EventControler:dispatchEvent(WonderlandEvent.SKILLTIPS_BACK_UI)
end

function WonderlandMainView:skillNodeTouchMove()
    

end

function WonderlandMainView:skillNodeTouchEnd()
    -- EventControler:dispatchEvent(WonderlandEvent.SKILLTIPS_BACK_UI)
end






---推荐伙伴头相处理
function WonderlandMainView:partnerlistIcon(floor)
    local panel = self.panel_1.panel_4.UI_1
    local _type = self.checkpoint_type
    local data = FuncWonderland.getSkillPantnerByfloor(_type,floor)
    panel:setVisible(false)
    local createRankItemFunc = function(itemData)
        local baseCell = UIBaseDef:cloneOneView(panel);
        self:setPartnerIconCellView(baseCell, itemData)
        return baseCell;
    end
    -- local updateFunc = function (itemData,baseCell)
    --     self:setPartnerIconCellView(baseCell, itemData)
    -- end

    local  _scrollParams = {
        {
            data = data,
            createFunc = createRankItemFunc,
            -- updateFunc= updateFunc,
            perNums = 1,
            offsetX = 10,
            offsetY = 5,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -55, width = 60, height = 55},
            perFrame = 0,
        }
    }    
    self.panel_1.panel_4.scroll_1:cancleCacheView();
    self.panel_1.panel_4.scroll_1:styleFill(_scrollParams);
    self.panel_1.panel_4.scroll_1:hideDragBar()
end

function WonderlandMainView:setPartnerIconCellView(baseCell, itemData)

    local _partnerId = itemData
    baseCell:updataUI(_partnerId)
    baseCell.panel_lv:setVisible(false)
    baseCell.mc_dou:setVisible(false)
    baseCell.mc_kuang:showFrame(1)

    local rew = "18,".._partnerId..",1"
    local  needNum,hasNum,isEnough ,resType,resId = UserModel:getResInfo(rew)
    FuncCommUI.regesitShowResView(baseCell, resType, needNum, resId,rew,true,true)
end



function WonderlandMainView:getPaiHangBang(_type)
    local panel = self.panel_2
    for i=1,3 do
        panel["panel_"..i]:setVisible(false)
    end
    panel.txt_2:setVisible(false)




    local function callback(_param)
        
        if (_param.result ~= nil) then
            -- dump(_param.result," 须臾排行榜数据 ====",7)
            local  data = _param.result.data.list or {}
            self:leftDownViewData(data)
        else
             self:leftDownViewData({})
        end
    end

    --获取排行榜
    local types = FuncWonderland.PaiHanbang_Type[tonumber(_type)]
    local params = {
        type = types,
        rank = 1,
        rankEnd = 3,
    }
    WonderlandModel:getPaiHangBang(params,callback)
end


--最左边下面视图初始化   排行榜 floor 
function WonderlandMainView:leftDownViewData(data)
    local _type = self.checkpoint_type
	local modeldata = WonderlandModel:getPaiHangBangDataSorting(data)
    local panel = self.panel_2
    for i=1,3 do
        panel["panel_"..i]:setVisible(false)
    end
    if #modeldata == 0 then
        panel.txt_2:setVisible(true)
    else
        for i=1,#modeldata do
            panel["panel_"..i]:setVisible(true)
            self:setListData(panel["panel_"..i],modeldata[i])
        end
        panel.txt_2:setVisible(false)
    end

    panel.btn_ph:setTouchedFunc(c_func(self.bestOflist, self,modeldata),nil,true);
end

--设置排行榜数据
function WonderlandMainView:setListData(view,data)
    local rankingsID = data.rank or 1
    local name = data.name or "玩家名字六字"
    local floor = data.score or 1
    view.mc_1:showFrame(rankingsID)
    view.txt_1:setString(name)
    view.txt_2:setString(floor..GameConfig.getLanguage("#tid_wonderland_ui_002"))

end


--排行榜的按钮
function WonderlandMainView:bestOflist(data)
	local listData = data
    if #listData == 0 then
        WindowControler:showTips(GameConfig.getLanguage("#tid_wonderland_ui_007"))
        return 
    end
    local _type = self.checkpoint_type
    --显示排行榜界面
    WindowControler:showWindow("WonderlandListView",_type)

end

--主界面帮助按钮
function WonderlandMainView:helpButton()
    local pames = {
        title = "须臾仙境规则",
        tid = "#tid_wonderland_rule_101",
    }

	WindowControler:showWindow("TreasureGuiZeView",pames)
end


---初始化立绘信息
function WonderlandMainView:setSpineView(floor)   -- iconCellviewData(floor)


    self:replaceSpine(floor)
    self:leftUpViewData()
    self:setdiffDis()


end
function WonderlandMainView:replaceSpine(floor)
    echo("======初始选中=floor=======",floor)
    self.selectFloor = floor
    local _ctn = self.ctn_lihui
    self.ctn_lihui:setOpacity(255)
    _ctn:setPosition(cc.p(self.lihui_X,self.lihui_Y))
    _ctn:removeAllChildren()
    local _type = self.checkpoint_type
    if floor == 0 then
        floor = 1
    end
    local sourceArr = FuncWonderland.getfloorSpine(_type,floor)

    echo("======sourceArr=====",sourceArr[1])
    local sourceId = tonumber(sourceArr[1])
    local scale = sourceArr[2] or 1
    self.spine = FuncRes.getSpineViewBySourceId(sourceId)
    self.spine:setScale(scale)
    _ctn:addChild(self.spine)
    if sourceArr[3] then
        self.spine:setPositionX(sourceArr[3])
    end
    if sourceArr[4] then
        self.spine:setPositionY(sourceArr[4])
    end
    local x = _ctn:getPositionX()
    _ctn:setPositionX(x + 30)
end



-----------------------------------移动逻辑------------------------------------
-- 添加滑动逻辑
function WonderlandMainView:initMoveNode( )
    if self.moveNode == nil then
        self.moveNode = FuncRes.a_white( 170*4,36*9.5) --display.newNode()
        self.moveNode:size(520,335)
        self.moveNode:anchor(0.5,0)
        -- self.moveNode:setPosition(cc.p(0,0))
        self.moveNode:setOpacity(0)
        self.ctn_node:addChild(self.moveNode,10)
        self.moveNode:setTouchEnabled(true)
        self.lihuiCanMove = true
        self.moveNode:setTouchedFunc(c_func(self.moveNodeTouchEnds, self), nil, nil,
         c_func(self.moveNodeTouchStart, self),
         c_func(self.moveNodeTouchMove, self),
         nil,
         c_func(self.moveNodeTouchEnd, self)  )
    end
end


--点击的状态
function WonderlandMainView:moveNodeTouchEnds()
    
end

function WonderlandMainView:moveNodeTouchEnd(event)
    if not self.lihuiCanMove then 
        return
    end 
    self:disabledUIClick()
    local moveEndX = event.x
    local moveEndY = event.y
    -- self.checkpoint_type
    -- self.initfloor

    local dis = 150
    local params = {}
    if moveEndX - self.starMoveX > dis then
        -- 立绘向右滑动
        echo("===============立绘向右============",self.selectFloor)
        local _r_f = 1
        local floor = self.selectFloor - 1
        local isokTab = WonderlandModel:judgeMoveConditions(self.checkpoint_type,floor,_r_f)
        self:lihuiRunaction(_r_f,c_func(self.runsetSpineView, self),isokTab)
         if self.selectFloor == self.initfloor then
            self.panel_right:setVisible(false)
        else
            self.panel_right:setVisible(true)
        end
        self.panel_left:setVisible(true)
        if self.initfloor == 0 then 
            self.panel_left:setVisible(false)
            self.panel_right:setVisible(false)
        elseif self.selectFloor == FuncWonderland.MaxFloor - 2 then
            self.panel_left:setVisible(false)
        end
    elseif moveEndX - self.starMoveX < -dis then
        -- 立绘向左++滑动
        echo("===============立绘向左============",self.selectFloor)
        local _r_f = -1
        local floor = self.selectFloor + 1
        local isokTab  = WonderlandModel:judgeMoveConditions(self.checkpoint_type,floor,_r_f)
        self:lihuiRunaction(_r_f,c_func(self.runsetSpineView, self),isokTab)
        if self.selectFloor == self.initfloor + 1 then
            self.panel_left:setVisible(false)
        else
            self.panel_left:setVisible(true)
        end
        self.panel_right:setVisible(true)
        if self.initfloor == 0  then
            self.panel_left:setVisible(false)
            self.panel_right:setVisible(false)
        elseif self.initfloor == FuncWonderland.MaxFloor then
            self.panel_right:setVisible(false)
        end
    else
        self:lihuiRunaction(0)
    end
end


function WonderlandMainView:setRightAndLeftButton()
    -- self.panel_left:setVisible(true)
    -- self.panel_right:setVisible(true)
    self.panel_left:setTouchedFunc(c_func(self.leftButton, self),nil,true);
    self.panel_right:setTouchedFunc(c_func(self.rightButton, self),nil,true);
end


function WonderlandMainView:leftButton()
    local _r_f = 1
    local floor = self.selectFloor - 1
    local isokTab  = WonderlandModel:judgeMoveConditions(self.checkpoint_type,floor,_r_f)
    -- local ismove = self:lihuiRunaction(_r_f,c_func(self.runsetSpineView, self),isokTab)
    echo("======self.selectFloor====1111======",self.selectFloor,floor)
    -- dump(isokTab,"111111111111")
    if isokTab[1] then
        self.selectFloor = self.selectFloor - 1
        self:runsetSpineView()
    else
        local str = isokTab[2]
        if str ~= nil and str ~= "" then
            WindowControler:showTips(FuncWonderland.ErrorString[str])
        end
        return 
    end

    if self.selectFloor == self.initfloor + 1 then
        self.panel_left:setVisible(true)
        self.panel_right:setVisible(true)
    elseif self.selectFloor  == self.initfloor then
        self.panel_left:setVisible(false)
        self.panel_right:setVisible(true)
    end

    if ( self.initfloor == 0 and self.selectFloor == 1) or self.initfloor == FuncWonderland.MaxFloor then

        self.panel_left:setVisible(false)
        self.panel_right:setVisible(false)
    end
    if self.initfloor == FuncWonderland.MaxFloor then
        if floor == FuncWonderland.MaxFloor  then
            self.panel_left:setVisible(true)
            self.panel_right:setVisible(true)
        elseif floor == FuncWonderland.MaxFloor - 1 then
             self.panel_left:setVisible(false)
            self.panel_right:setVisible(true)
        end
    end

    -- if self.selectFloor == self.initfloor + 1 then
    --     self.panel_left:setVisible(false)
    -- else
    --     self.panel_left:setVisible(true)
    -- end
    -- self.panel_right:setVisible(true)
    -- if self.initfloor == 0 then
    --     self.panel_left:setVisible(false)
    --     self.panel_right:setVisible(false)
    -- end
    -- if self.selectFloor ==  FuncWonderland.MaxFloor then
    --     self.panel_right:setVisible(false)
    -- end

    -- if self.selectFloor >= FuncWonderland.MaxFloor -2  and self.selectFloor <= FuncWonderland.MaxFloor -1 then
    --     self.panel_right:setVisible(true)
    -- end
end


function WonderlandMainView:rightButton()
    local _r_f = -1
    local floor = self.selectFloor + 1
    local isokTab = WonderlandModel:judgeMoveConditions(self.checkpoint_type,floor,_r_f)
    -- self:lihuiRunaction(_r_f,c_func(self.runsetSpineView, self),isokTab)
    -- echo("======self.selectFloor====22222======",self.selectFloor)
    -- dump(isokTab,"22222222222")
     if isokTab[1] then
        self.selectFloor = self.selectFloor + 1
        self:runsetSpineView()
    else
        local str = isokTab[2]
        if str ~= nil and str ~= "" then
            WindowControler:showTips(FuncWonderland.ErrorString[str])
        end
        return 
    end

    -- if self.selectFloor == self.initfloor then
    --     self.panel_right:setVisible(false)
    -- else
    --     self.panel_right:setVisible(true)
    -- end
    -- self.panel_left:setVisible(true)
   
    -- if self.selectFloor >= FuncWonderland.MaxFloor -2  and self.selectFloor <= FuncWonderland.MaxFloor -1 then
    --     self.panel_left:setVisible(true)
    -- end

    if self.selectFloor == self.initfloor + 1 then
        self.panel_left:setVisible(true)
        self.panel_right:setVisible(true)
    elseif self.selectFloor  == self.initfloor then
        self.panel_left:setVisible(false)
        self.panel_right:setVisible(true)
    end

    if ( self.initfloor == 0 and self.selectFloor == 1) or self.initfloor == FuncWonderland.MaxFloor then
        self.panel_left:setVisible(false)
        self.panel_right:setVisible(false)
    end

    if self.initfloor == FuncWonderland.MaxFloor then
        if floor == FuncWonderland.MaxFloor then
            self.panel_left:setVisible(true)
            self.panel_right:setVisible(true)
        elseif floor == FuncWonderland.MaxFloor - 1 then
            self.panel_left:setVisible(false)
            self.panel_right:setVisible(true)
        elseif floor == FuncWonderland.MaxFloor - 2 then
            self.panel_left:setVisible(false)
            self.panel_right:setVisible(true)
        end
    end

end



function WonderlandMainView:runsetSpineView()
    -- self:delayCall(function ()
        -- echo("========最新层级=========",self.selectFloor)
        self:setSpineView(self.selectFloor)
    -- end,0.35)
end




function WonderlandMainView:moveNodeTouchStart(event)
    -- dump(event, "moveStar -----------", 3)
    self.starMoveX = event.x
    self.starMoveY = event.y


end
function WonderlandMainView:moveNodeTouchMove(event)
    if not self.lihuiCanMove then 
        return
    end 
    local pianyi = 200
    local _dis = event.x - self.starMoveX
    if event.x - self.starMoveX > pianyi then
        _dis = pianyi
    elseif event.x - self.starMoveX < -pianyi then
        _dis = -pianyi
    end
    self:lihuiMove(_dis)
end

function WonderlandMainView:lihuiMove(dis)
    self.ctn_lihui:setPositionX(self.lihui_X + dis)
end

function WonderlandMainView:lihuiRunaction(_type,_callback,sTab)
    local pianyi = 200
    local _time = 0.25
    -- echo("=======self.selectFloor========'",self.selectFloor)
    -- dump(sTab,"判断条件")
        if math.abs(_type) > 0 then
            if sTab[1] then
                if _type > 0 then  --右
                   self.selectFloor = self.selectFloor - 1
                elseif _type < 0 then   --左
                    self.selectFloor = self.selectFloor + 1
                end
            else
                local str = sTab[2]
                if str ~= nil and str ~= "" then
                    WindowControler:showTips(FuncWonderland.ErrorString[str])
                end
                _type = 0
                self.ctn_lihui:runAction(
                    act.moveto(_time , self.lihui_X - (pianyi * _type), self.lihui_Y)
                )
                self:resumeUIClick()
                return
            end


            self.ctn_lihui:runAction(act.spawn(
                    act.moveto(_time , self.lihui_X + (pianyi * _type), self.lihui_Y),
                    act.fadeout(_time),
                    act.callfunc(function ()
                        if _callback then
                            self:resumeUIClick()
                            _callback()
                        end
                    end)
                )
            )
        else
            -- _type = 0
            -- self.ctn_lihui:runAction(
            --     act.moveto(_time , self.lihui_X - (pianyi * _type), self.lihui_Y)
            -- )
            self:resumeUIClick()
            if sTab[1] then
                if _callback then
                    _callback()
                    return true
                end
            else
                local str = sTab[2]
                if str ~= nil and str ~= "" then
                    WindowControler:showTips(FuncWonderland.ErrorString[str])
                end
                return false
            end
            
        end
end


-- 设置立绘是否可以滑动
function WonderlandMainView:setLihuiMove(_bool)
    self.lihuiCanMove = _bool

end



function WonderlandMainView:clickButtonBack()
    EventControler:dispatchEvent(WonderlandEvent.WONDERLAND_BACK_UI)
    WonderlandModel:setSelectBossType(nil)
    WonderlandModel:sendHomeRed()
    self:startHide();

end



return WonderlandMainView;
