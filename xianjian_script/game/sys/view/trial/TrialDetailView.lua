--2016.2.19
--guan

local TrialDetailView = class("TrialDetailView", UIBase);

function TrialDetailView:ctor(winName, trialKind)
    TrialDetailView.super.ctor(self, winName);
    -- echo("=========000000000000=========",trialKind)
    -- trialKind = "3001"
    -- self.pathdoing = nil  --是不是路径过来的
    -- if type(trialKind) == "string" then
    --     self.pathdoing = true
    --     local numbers = tonumber(trialKind)
    --     local skillID = math.floor(trialKind/1000)
    --     local _trailKind = math.fmod(trialKind,1000)
    --     self._selectIndex = _trailKind
    --     self._trailKind = self:get_trailKind(numbers)
    -- elseif type(trialKind) == "number" then
        -- self.pathdoing = false
        self._trailKind = trialKind;
        -- self._selectIndex = 1
    -- end

    -- echo("=========1111111111=========",self._trailKind,self._selectIndex)
    
end
function TrialDetailView:get_trailKind(trialKind)
    return (trialKind-3000-self._selectIndex)/5 + 1
end

function TrialDetailView:loadUIComplete()
    --左上
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_slbiaoti, UIAlignTypes.LeftTop);
    --右上
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back, UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_ding, UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.scroll_1, UIAlignTypes.Left);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_wen, UIAlignTypes.LeftTop);
    FuncCommUI.setScale9Align(self.widthScreenOffset,self.scale9_1,UIAlignTypes.MiddleTop,1,0)
    

    
    -- btn_yulan
    self.btn_yulan:setTap(c_func(self.previewReward, self));
    self.btn_wen:setTap(c_func(self.press_btn_guize, self));
    self.ani = nil
    self.isopenTrial = TrailModel:isTrialTypeOpenCurrentTime(self._trailKind)
	self:registerEvent();  
    self:initUI();
    self:staticTimeReach()

end 
-- function TrialDetailView:()
--     -- body
-- end
--预览奖励
function TrialDetailView:previewReward( )
    -- self._selectIndex
    local id = TrailModel:getIdByTypeAndLvl(self._trailKind, self._selectIndex);
    local rewards = FuncTrail.getTrailData(id, "trialReward");
    -- dump(rewards,"奖励")
    WindowControler:showWindow("TrailPreviewView",self._trailKind,self._selectIndex);


   
end
function TrialDetailView:registerEvent()
	TrialDetailView.super.registerEvent();
    self.btn_back:setTap(c_func(self.press_btn_back, self));
    --等升级消息，升级解锁新难度
    -- todo 是不是也要放到server中？？？？
    EventControler:addEventListener(UserEvent.USEREVENT_LEVEL_CHANGE, 
        self.lvlUpCallBack, self);
    
    --单人战斗结束，上报结果
    -- EventControler:addEventListener(BattleEvent.BATTLEEVENT_BATTLE_RESULT, 
    --     self.blockBattleEnd, self);

    --关节面时候播 解封动画, 不管挑战还是解封，都是在收到close的时候更新界面
    EventControler:addEventListener(BattleEvent.BATTLEEVENT_BATTLE_CLOSE,
        self.showDeblockActionCallBack, self);

    --扫荡成功
    EventControler:addEventListener(TrialEvent.SWEEP_BATTLE_SUCCESS_EVENT,
        self.sweepSuccessCallback, self);

    --定点刷新
    -- EventControler:addEventListener(TimeEvent.TIMEEVENT_STATIC_CLOCK_REACH_EVENT, 
    --     self.staticTimeReach, self);

    EventControler:addEventListener(CountEvent.COUNTEVENT_MODEL_UPDATE,self.staticTimeReach,self)

    -- --主动离开战斗
    -- EventControler:addEventListener(BattleEvent.BATTLEEVENT_USER_LEAVE, 
    --     self.onBattleLeave, self);


    --临时商店功能更
    EventControler:addEventListener(ShopEvent.SHOPEVENT_TEMP_SHOP_OPEN, 
        self.onTempShopOpen, self);

    --关闭布阵界面
    -- EventControler:addEventListener(BattleEvent.CLOSE_TEAM_FORMATION_FOR_BATTLE,self.doBackClick,self)

    --开始战斗界面
    -- EventControler:addEventListener(BattleEvent.BEGIN_BATTLE_FOR_FORMATION_VIEW, self.onTeamFormationComplete, self)
    
end
function TrialDetailView:doBackClick(data)
    -- dump(data.params,"关闭布阵界面")
end
--布阵挑战
function TrialDetailView:onTeamFormationComplete(data)
    -- dump(data.params,"布阵挑战")
    local params = data.params
    if params.systemId == FuncTeamFormation.formation.trailPve1 or params.systemId == FuncTeamFormation.formation.trailPve2 or params.systemId == FuncTeamFormation.formation.trailPve3  then
        local id = TrailModel:getIdByTypeAndLvl(self._trailKind, self._selectIndex);
        TrialServer:startBattle(c_func(self.startBattleCallback, self,id,2), id, 1,params.formation);
        -- EventControler:(BattleEvent.CLOSE_TEAM_FORMATION_FOR_BATTLE,self.doBackClick,self)
    end
end



function TrialDetailView:onTempShopOpen(event)
    local params = event.params
    local shopType = params.shopType
    if shopType then
        WorldModel:resetDataBeforeBattle()
        WindowControler:showWindow("ShopKaiqi", shopType)
    end
end

function TrialDetailView:staticTimeReach()
    -- local clock = event.params.clock;
    -- 到点刷新

    -- if clock == "04:00:00" then 
        -- self.mc_tiaozhan:setTouchedFunc(
        --     c_func(self.timeOver, self));
    -- else 
    --     echo("not equal 4 ");
    -- end  self._trailKind
    -- echo("11111111111111111111111111111111111111111111111111")
    if TrailModel:isTrialTypeOpenCurrentTime(self._trailKind) == false then
        self.mc_shengyu:visible(false)
        self.ani:visible(false)
        self.mc_tiaozhan:showFrame(1);
        FilterTools.setGrayFilter(self.mc_tiaozhan)
        self.mc_tiaozhan:getViewByFrame(1).btn_2:getUpPanel().panel_red:visible(false)
        self.mc_tiaozhan:getViewByFrame(2).btn_3:getUpPanel().panel_red:visible(false)
        self.isopenTrial = false
    else
        self.isopenTrial = true
    end


end

function TrialDetailView:timeOver()

    if TrailModel:isTrialTypeOpenCurrentTime(self._trailKind) == false then
        -- WindowControler:showTips({text =" 此试炼已过期"})

    end 
end

function TrialDetailView:initUI() 

     -- 按钮 闪光
    -- local leftCount = TrailModel:getLeftCounts(self._trailKind);
    if self.ani == nil then
        self.ani= self:createUIArmature("UI_common","UI_common_zhonganniu", self.mc_tiaozhan, true);
        self.ani:setPosition(self.ani:getPositionX() + 90,self.ani:getPositionY() - 47)
        self.ani:setScale(1.2)
    end


    self:initSelectBar();
    --boss
    local ctn = self.panel_boss.ctn_boss;
    ctn:removeAllChildren();
    local bossConfig = FuncTrail.getTrialResourcesData(self._trailKind, "dynamic");
    local arr = string.split(bossConfig, ",");
    -- dump(arr, "bossConfig");
    local sp = ViewSpine.new(arr[1], {}, arr[1]);
    self.spinBoss = sp
    sp:setScale(0.9)
    sp:playLabel(arr[2]);

--    sp:setShadowVisible(false)

    local bedDownArmature = nil;
    local bedUpArmature = nil;
    local xueyaoAni = nil
    --底座
    if self._trailKind == 1 then 
        bedDownArmature = self:createUIArmature("UI_shilian","UI_shilian_shanshen_di", 
            self.panel_boss.ctn_dizuo, true);
        bedUpArmature = self:createUIArmature("UI_shilian","UI_shilian_shanshen_ding", 
            self.panel_boss.ctn_ding, true);
        local bedDownArmature2 = self:createUIArmature("UI_shilian","UI_shilian_shanshen_fazhen", 
            self.panel_boss.ctn_dizuo, true);
        bedDownArmature2:setScale(1.2);
        
    elseif self._trailKind == 2 then 
        bedDownArmature = self:createUIArmature("UI_shilian","UI_shilian_huoshen_di", 
            self.panel_boss.ctn_dizuo, true);
        bedUpArmature = self:createUIArmature("UI_shilian","UI_shilian_huoshen_ding", 
            self.panel_boss.ctn_ding, true);
        local bedDownArmature2 = self:createUIArmature("UI_shilian","UI_shilian_huoshen_fazhen", 
            self.panel_boss.ctn_dizuo, true);
        bedDownArmature2:setScale(1.2);
    else 
        xueyaoAni = self:createUIArmature("UI_shilian","UI_shilian_xueyao", 
        self.panel_boss.ctn_dizuo,true);
    end 
    if bedDownArmature ~= nil then
        bedDownArmature:setScale(1.2);
    end
    if bedDownArmature ~= nil then
        bedUpArmature:setScale(1.2);
    end

    if arr[4] == "1" then 
        sp:setRotationSkewY(180);
    end 

    ctn:addChild(sp);
    if xueyaoAni ~= nil then
        ctn:setPositionX(ctn:getPositionX()- ctn.ctnWidth/2 - 40);
        ctn:setPositionY(ctn:getPositionY() + ctn.ctnHeight/2 - 20 );
        FuncArmature.changeBoneDisplay(xueyaoAni, "node", ctn ); 
    end

    local adaptationSizeCoeffcient = self:getAdaptationSizeCoeffcient(ctn, sp);
    sp.currentAni:setScale(adaptationSizeCoeffcient);


    --
    local node = display.newLayer();
    node:setContentSize(cc.size(270,315))
    self.panel_boss:addChild(node,10000)
    node:setPositionY(-315)
    node:setTouchedFunc(c_func(self.playRandomAni,self))
end 
--点击boos获得详情界面   ---点击显示动作方法

function TrialDetailView:playRandomAni()

 --    local bossAni = FuncTrail.getTrialResourcesData(self._trailKind, "action");
	-- math.randomseed(os.time());
 --    local index = math.random(1,3);
 --    echo("随机 index =========== " .. index)
 --    if bossAni[index] then
 --        local bossConfig = FuncTrail.getTrialResourcesData(self._trailKind, "dynamic");
 --        local arr = string.split(bossConfig, ",");
 --        local arrAction = {
 --            {label = bossAni[index],loop = false},
 --            {label = arr[2],loop = true},
 --        };
 --        self.spinBoss:playActionArr(arrAction);
 --    end

    WindowControler:showWindow("TrailBOSSInfoView",self._trailKind,self._selectIndex)        


end

--试炼点，能否扫荡
function TrialDetailView:initPoint()
    -- echo("initPoint " .. tostring(self._selectIndex));

    local pointTopLimit = 10000 -- todo 读表
    local havePoint = UserModel:trialPoints()[tostring(self._trailKind)] or 0;

    local id = TrailModel:getIdByTypeAndLvl(self._trailKind, self._selectIndex);
    -- echo("idididiidid = ",id,"===============================")
    -- echo("设置当前关卡id")
    self.levelId = id
    local sweepNeedPoint = FuncTrail.getTrailData(id, "openSweep");

--    local str = tostring(havePoint) .. "/"  .. tostring(pointTopLimit);
    local str = tostring(havePoint) ;
    -- echo("str_______  " .. str);
    self.panel_ding.panel_sld.txt_sld1:setString(str);

    self.panel_ding.panel_sld.mc_1:showFrame(self._trailKind);

 

    --剩余次数 todo 
    local leftCount = TrailModel:getLeftCounts(self._trailKind);
    local totalNum = TrailModel:getTotalCount();
    self.panel_cishu.txt_2:setString(tostring(leftCount) ..  "/" .. tostring(totalNum))
end

-- 初始化左侧列表
function TrialDetailView:initSelectBar()
    --todo 跳到1个 
    self._selectIndex = 1;
    -- if  self.pathdoing  == false then
        for i = 1,5 do
            if TrailModel:isTrailOpen(self._trailKind, i) == true then
                if self._selectIndex < i then
                    self._selectIndex = i
                end
            end
        end
        local _index = Cache:get("shilianIndex",nil)
        if _index then
            self._selectIndex = _index;
            Cache:set("shilianIndex",nil)
        end
    -- end
    


    local createFunc = function(_itemdata)
        local _itemView = UIBaseDef:cloneOneView(self.panel_ndqiehuan["mc_nd3"]) 
        self:updataItem(_itemView,_itemdata)
        return _itemView
    end

    local reuseUpdateCellFunc = function(_itemdata, _itemView)
        self:updataItem(_itemView,_itemdata)
        return _itemView
    end
    self.scroll_1:setCanScroll(true);
    self.scroll_1:hideDragBar()
    local _data = {}
    for i = 1,5 do
        table.insert(_data,i)
    end
    
    local params = {
            {
                data = _data,
                createFunc = createFunc,
                perNums = 1,
                offsetX = 0,
                offsetY = 0,
                widthGap = 0,
                heightGap = 0,
                itemRect = { x = 0, y = - 145, width = 93, height = 145 },
                perFrame = 1,
            }
    }
    self.scroll_1:styleFill(params)
    self.scroll_1:gotoTargetPos(self._selectIndex ,1,1)
    self.panel_ndqiehuan:setVisible(false)

    self:initDifficultUI(self._selectIndex);
end 
function TrialDetailView:updataItem(itemView,itemData)
    local id = TrailModel:getIdByTypeAndLvl(self._trailKind, itemData);
    local name = FuncTrail.getTrailData(id, "diffName");
    local txt
    local txt1; 
    itemView:showFrame(2)
    txt = itemView.currentView.btn_2:getDownPanel().txt_1
    txt1 = itemView.currentView.btn_2:getUpPanel().txt_1
    txt:setString(GameConfig.getLanguage(name))
    txt1:setString(GameConfig.getLanguage(name))
    itemView:showFrame(1)
    txt = itemView.currentView.btn_1:getDownPanel().txt_1
    txt1 = itemView.currentView.btn_1:getUpPanel().txt_1
    txt:setString(GameConfig.getLanguage(name))
    txt1:setString(GameConfig.getLanguage(name))
    
    if TrailModel:isTrailOpen(self._trailKind, itemData) == true then
        if self._selectIndex == itemData then
            itemView:showFrame(2)
            itemView.currentView.panel_feng:setVisible(false)
            txt = itemView.currentView.btn_2:getUpPanel().txt_1
        else
            itemView:showFrame(1)
            itemView.currentView.panel_feng:setVisible(false)
            txt = itemView.currentView.btn_1:getUpPanel().txt_1
        end
        
    end
    
    if TrailModel:isTrailOpen(self._trailKind, itemData) == true then 
        txt:setVisible(true)
        txt:setString(GameConfig.getLanguage(name))
    else
        txt:setVisible(false)
    end 


    
    itemView:setTouchedFunc(c_func(self.mcBtnClick, self, itemData))
    itemView:setTouchSwallowEnabled(true);
end



function TrialDetailView:mcBtnClick(difficut)

    if self.scroll_1:isMoving() then
		return
	end 
    -- if self.isopenTrial then
        if self._selectIndex ~= difficut then 
            local isOpen, needLvl = TrailModel:isTrailOpen(self._trailKind, difficut);
            if isOpen == true then 
                local lastView = self.scroll_1:getViewByData(self._selectIndex)
                lastView:showFrame(1)
    --            local txt1 = lastView.currentView.btn_1:getUpPanel().txt_1
    --            local id1 = TrailModel:getIdByTypeAndLvl(self._trailKind, self._selectIndex);
    --            local name1 = FuncTrail.getTrailData(id1, "diffName");
    --            txt1:setString(GameConfig.getLanguage(name1))
                lastView.currentView.panel_feng:setVisible(false)
                self._selectIndex = difficut;
                self:initDifficultUI(difficut);
                local newView = self.scroll_1:getViewByData(self._selectIndex)
                newView:showFrame(2)
    --            local txt2 = newView.currentView.btn_2:getUpPanel().txt_1
    --            local id2 = TrailModel:getIdByTypeAndLvl(self._trailKind, self._selectIndex);
    --            local name2 = FuncTrail.getTrailData(id2, "diffName");
    --            txt2:setString(GameConfig.getLanguage(name2))
                newView.currentView.panel_feng:setVisible(false)

            else  
                -- local str = FuncTranslate.getLanguageAndSub("#tid28003", "zh_CN", needLvl);
                WindowControler:showTips({text = GameConfig.getLanguage("#tid_trail_005") .. tostring(needLvl)});
            end 
        end 
    -- end
end

function TrialDetailView:initDifficultUI(difficut)
    -- self:initPoint();
    -- echo("============difficut==========",difficut)

    -- echo("初始化界面 " .. tostring(difficut));
    -- self.panel_ndqiehuan["mc_nd" .. tostring(difficut)]:showFrame(2);
    --奖励
    local id = TrailModel:getIdByTypeAndLvl(self._trailKind, difficut);
    local rewards = FuncTrail.getTrailData(id, "trialReward");
    local magnitudes = FuncTrail.getTrailData(id, "magnitude");
    -- dump(rewards,"试炼奖励预览")
    for i = 1, 4 do
        local itemView = self["UI_"..i]
        local itemReward = rewards[i]
        if itemReward then
            itemView:setVisible(true)
            itemView:setResItemData({reward = itemReward})
            itemView:showResItemName(false)
            itemView:updateItemUI()
            itemView:showResItemNum(false)
            --注册点击事件 弹框
            local  needNum,hasNum,isEnough ,resType,resId = UserModel:getResInfo(itemReward)
            FuncCommUI.regesitShowResView(itemView, resType, needNum, resId,itemReward,true,true)
            -- self["mc_shuliang"..i]:showFrame(i)
            -- self["mc_shuliang"..i]:setVisible(true)
        else
            itemView:setVisible(false)
            -- self["mc_shuliang"..i]:setVisible(false)
        end
    end
    -- local info = self.mc_1.currentView.panel_1
    self.txt_miaoshu:setString(GameConfig.getLanguage(FuncTrail.getTrailData(id, "describe")))

--[[ 
    if TrailModel:isDeblockThanKindAndLvl(self._trailKind, self._selectIndex) == true then
    -- 已解封
        self.mc_1:showFrame(1)
        --描述  
        local info = self.mc_1.currentView.panel_1
        info.txt_miaoshu:setString(GameConfig.getLanguage(FuncTrail.getTrailData(id, "describe")))
        -- 消耗体力
        info.panel_di.txt_tlshuzi:setString(FuncTrail.getTrailData(id, "winCostSp"))
        -- 扫荡要求
        info.panel_sldleiji.mc_lxicon1:showFrame(tonumber(self._trailKind))
        info.panel_sldleiji.txt_sld1:setString(FuncTrail.getTrailData(id, "openSweep"))

    else
        -- 未解封
        -- self.mc_1:showFrame(2)
        -- local txtMiaoshu = self.mc_1.currentView.panel_1.txt_miaoshu
        -- local txtJiefeng = self.mc_1.currentView.panel_1.txt_miaoshu2
        self.txt_miaoshu:setString(GameConfig.getLanguage(FuncTrail.getTrailData(id, "describe")))
        -- txtJiefeng:setString(GameConfig.getLanguage( FuncTrail.getTrailData(id, "firstDescribe")))
    end
]]


    self:initMcBtn(difficut);
    self:InfoShow(difficut)
end 
--战力推荐和星级和次数
function TrialDetailView:InfoShow(difficut)
    
    -- self._trailKind
    local Trailid = TrailModel:getIdByTypeAndLvl(self._trailKind,difficut)
    local ability = FuncTrail.getTrailData(Trailid,"ability")
    local starFrame = TrailModel:getTrailStar(Trailid)
    -- echo("=Trailid===starFrame========",Trailid,starFrame)

    -- local startable =  number.splitByNum( starFrame ,2)
        -- dump(startable)
    -- local star = 0
    -- for i=1,#startable do
    --     if startable[i] == 1 then
    --         star = star + 1
    --     end
    -- end

    -- starFrame = star


    local TrailStar = tonumber(starFrame)
    if TrailStar == 3 then
        self.mc_tiaozhan:showFrame(2);
    else
        self.mc_tiaozhan:showFrame(1);
    end

    self.txt_1:setString(..ability) --推荐战力
    if starFrame == 0 then    
        self.panel_boss.mc_star:showFrame(4) ---星级显示
    else
        self.panel_boss.mc_star:showFrame(starFrame)
    end
    -- self.mc_shengyu:setString() --挑战剩余次数
    local leftTime = CountModel:getTrialCountTime(self._trailKind);
    local totalNum = TrailModel:getTotalCount();

    self.mc_shengyu:getViewByFrame(1).txt_1:setString(GameConfig.getLanguage("#tid_trail_007")..tostring(totalNum - leftTime) .. "/" .. tostring(totalNum))

    if totalNum - leftTime <= 0 then
        self.mc_shengyu:showFrame(2)
        self.mc_tiaozhan:getViewByFrame(1).btn_2:getUpPanel().panel_red:visible(false)
        self.mc_tiaozhan:getViewByFrame(2).btn_3:getUpPanel().panel_red:visible(false)
        FilterTools.setGrayFilter(self.mc_tiaozhan);
        self.mc_shengyu:getViewByFrame(2).txt_1:setString(GameConfig.getLanguage("#tid_trail_007")..tostring(totalNum - leftTime) .. "/" .. tostring(totalNum))
        self.ani:visible(false)
    else
        FilterTools.clearFilter( self.mc_tiaozhan )
        self.ani:visible(true)
    end
    if self.isopenTrial  == false then
        self.mc_tiaozhan:getViewByFrame(1).btn_2:getUpPanel().panel_red:visible(false)
        self.mc_tiaozhan:getViewByFrame(2).btn_3:getUpPanel().panel_red:visible(false)
        FilterTools.setGrayFilter(self.mc_tiaozhan);
    end
end

function TrialDetailView:goToTreasureInfo(treasureId)
    -- WindowControler:showWindow("LotteryTreasureDetail", 
    --     treasureId)
end

function TrialDetailView:initMcBtn( difficut )
    -- echo("====11",TrailModel:isSweepOpenThatKindAndLvl(self._trailKind, 
    --     difficut),"====222",TrailModel:isDeblockThanKindAndLvl(self._trailKind, 
    --         difficut))
    if TrailModel:isSweepOpenThatKindAndLvl(self._trailKind, 
        difficut) == true and TrailModel:isDeblockThanKindAndLvl(self._trailKind, 
            difficut) == true then 

        -- echo("mc 扫荡");
        FilterTools.clearFilter(self.mc_tiaozhan);
        self.mc_tiaozhan:showFrame(2);

        local leftCount = TrailModel:getLeftCounts(self._trailKind);

        if leftCount <= 0 then 
            self.mc_tiaozhan:showFrame(2);
            FilterTools.setGrayFilter(self.mc_tiaozhan);
            self.mc_tiaozhan:getViewByFrame(2).btn_3:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_trail_008"));
        else
            if self.isopenTrial  then
                local _str = string.format(GameConfig.getLanguage("#tid_trail_009"),tostring(leftCount))
                self.mc_tiaozhan:getViewByFrame(2).btn_3:getUpPanel().txt_1:setString(_str);
            end
        end 

        if self.isopenTrial  == false then
            self.mc_tiaozhan:showFrame(1);
            FilterTools.setGrayFilter(self.mc_tiaozhan);
            -- self.mc_tiaozhan:getViewByFrame(1).btn_3:getUpPanel().txt_1:setString("挑战");
        end
        -- self.mc_tiaozhan:setTouchedFunc(function ()
        --     WindowControler:showTips("功能未开启")
        -- end)
       self.mc_tiaozhan:getViewByFrame(2).btn_3:setTap(c_func(self.sweepBtnClick,self))  --扫荡
       -- setTouchedFunc(c_func(self.sweepBtnClick, self)); 
        -- self.panel_cishu:setVisible(true);
    elseif TrailModel:isDeblockThanKindAndLvl(self._trailKind, 
        difficut) == true then
        -- echo("mc 挑战");
        local leftCount = TrailModel:getLeftCounts(self._trailKind);
        FilterTools.clearFilter(self.mc_tiaozhan);
        self.mc_tiaozhan:showFrame(1);
        if leftCount <= 0 then 
            FilterTools.setGrayFilter(self.mc_tiaozhan);
        end 
        -- self.mc_tiaozhan:setTouchedFunc(function ()
        --     WindowControler:showTips("功能未开启")
        -- end)
       self.mc_tiaozhan:getViewByFrame(1).btn_2:setTap(c_func(self.battleClick,self))  --挑战
       -- setTouchedFunc(c_func(self.battleClick, self));
        -- self.panel_cishu:setVisible(true);


--     else
--         FilterTools.clearFilter(self.mc_tiaozhan);
--         echo("mc 解封");
--         self.mc_tiaozhan:showFrame(1);
--         self.mc_tiaozhan:setTouchedFunc(function ()
--             WindowControler:showTips("功能未开启")
--         end)
-- --        self.mc_tiaozhan:setTouchedFunc(
-- --            c_func(self.openClick, self));
--         self.panel_cishu:setVisible(false);
    end
end

function TrialDetailView:battleClick()
    -- echo("挑战");
    --获取当前关卡Id
    local id = TrailModel:getIdByTypeAndLvl(self._trailKind, self._selectIndex);
    --有没有体力
    -- if UserModel:tryCost(FuncDataResource.RES_TYPE.SP, 12, true) then 
    if self.isopenTrial == true then
            if TrailModel:getLeftCounts(self._trailKind) > 0 then 
                self._isNotBlockBattle = false;

                local hid = FuncTrail.getTrailData(id, "level2");
                echo("hid " .. tostring(hid));

                self._battleLevel = hid;

                -- TrialServer:startBattle(c_func(self.startBattleCallback, self,id,2), 
                --     id, 1);
                self:OntouchStarBattle()

                Cache:set("shilianIndex",self._selectIndex)
            else 
                WindowControler:showTips({text = 
                    GameConfig.getLanguage("trail_no_count")});
            end
    else
         WindowControler:showTips(GameConfig.getLanguage("#tid_trail_010")); 
    end 
end
function TrialDetailView:OntouchStarBattle()
    -- FuncTeamFormation.formation.trailPve1
    local trailPve = nil
     if self._trailKind == TrailModel.TrailType.ATTACK then 
        trailPve = FuncTeamFormation.formation.trailPve1;
    elseif self._trailKind == TrailModel.TrailType.DEFAND then
        trailPve = FuncTeamFormation.formation.trailPve2;
    else
        trailPve = FuncTeamFormation.formation.trailPve3;
    end 
    WindowControler:showWindow("WuXingTeamEmbattleView",trailPve)
end

function TrialDetailView:openClick()
    -- echo("解封");

    local id = TrailModel:getIdByTypeAndLvl(self._trailKind, self._selectIndex);
    --解封不费体力有没有体力
    self._preClickDeblock = true;
    self._isNotBlockBattle = false;

    local hid = FuncTrail.getTrailData(id, "level1");

    self._battleLevel = hid;

    echo("hid " .. tostring(hid));

    TrialServer:startBattle(c_func(self.startBattleCallback, self,id,1), 
        id, 1);
    Cache:set("shilianIndex",self._selectIndex)
    -- self.mc_tiaozhan:setVisible(false);

    -- function callBackFunc()
    --     echo("callBackFunc"); 
    --     self:resumeUIClick();
    --     self.mc_tiaozhan:setVisible(true);
    --     self._blockAni:setVisible(false);
    --     self.mc_tiaozhan:showFrame(2);
    -- end

    -- --展示动画
    -- self._blockAni = self:createUIArmature("UI_shilian","UI_shilian_fengyin_donghua", 
    --     self.ctn_unblock, false, callBackFunc);

end

function TrialDetailView:sweepBtnClick()
    -- echo("扫荡");
    
    local id = TrailModel:getIdByTypeAndLvl(self._trailKind, self._selectIndex);
    local leftCount = TrailModel:getLeftCounts(self._trailKind);

    if self.isopenTrial == true then
        if UserModel:tryCost(FuncDataResource.RES_TYPE.SP, 12 * leftCount, true) then 
            if leftCount > 0 then 
                self._isPreSweep = true;
                TrialServer:sweep(c_func(self.sweepCallback, self), 
                    id, leftCount);
            else 
                WindowControler:showTips({text = 
                    GameConfig.getLanguage("trail_no_count")})
            end
        end 
    else
        WindowControler:showTips(GameConfig.getLanguage("#tid_trail_010"));
    end 
end


function TrialDetailView:startBattleCallback(level,sigleFlag,event)
    --echo("startBattleCallback");
    -- echo("level",level,"=-=-=-=-=-=====================当前关卡Id")
    --echo("flag","当前单人还是多人",sigleFlag)
    -- dump(event.result.data)
    --LogsControler:writeDumpToFile(event,8,8)
    if event.error == nil then 
        -- echo("startBattleCallback event.error == nil")
        --单人战斗
        if self._isNotBlockBattle ~= true then 
            -- echo("self._isNotBlockBattle ~= true")
            self._battleId = tostring(event.result.data.battleInfo.battleId);

            TrialServer:setBattleId(self._battleId);

            local battleInfo = {}
            battleInfo.battleUsers = event.result.data.battleInfo.battleUsers;
            battleInfo.randomSeed = event.result.data.battleInfo.randomSeed;
            battleInfo.levelId = self._battleLevel;

            if self._trailKind == TrailModel.TrailType.ATTACK then 
                battleInfo.battleLabel = GameVars.battleLabels.trailPve;
            elseif self._trailKind == TrailModel.TrailType.DEFAND then
                battleInfo.battleLabel = GameVars.battleLabels.trailPve2;
            else
                battleInfo.battleLabel = GameVars.battleLabels.trailPve3;
            end
            battleInfo.battleId = self._battleId
            echo("试炼战斗----",self._trailKind)
            dump(battleInfo,"battleInfo----")
            --暂时的
            --battleInfo.battleLabel = GameVars.battleLabels.trailPve2
            EventControler:dispatchEvent(BattleEvent.CLOSE_TEAM_FORMATION_FOR_BATTLE,self.doBackClick,self)
            BattleControler:startPVE(battleInfo);
        end 
    end
end

  --[[  --挑战
function TrialDetailView:clickButtonChallengeAfter()
    --检测是否还有挑战次数
    --购买的挑战次数
    local buyCount = CountModel:getPVPBuyChallengeCount()
    --已经挑战的次数
    local callengeCount = CountModel:getPVPChallengeCount()
    local firstTime = PVPModel:firstTime()
    local _times_left = FuncPvp.getPvpChallengeLeftCount(buyCount, callengeCount, firstTime)
    if _times_left <= 0 then
        WindowControler:showTips(GameConfig.getLanguage("tid_pvp_1042"))
        return
    end
    --构建数据结构
    local _user_formation = table.deepCopy(TeamFormationModel:getPVPFormation())
    local _formation = {
        treasureFormation = table.deepCopy(_user_formation.treasureFormation),
        partnerFormation = table.deepCopy(_user_formation.partnerFormation),
    }
    local _param = {
        opponentRid = self._playerInfo.rid_back, --对手的rid
        opponentRank = self._playerInfo.rank , --对手的排名
        userRank = PVPModel:getUserRank(), --玩家自己的排名
        formation = _formation, --玩家自己的PVP阵列
    }
--    dump(_param,"---_param----")
    PVPServer:requestChallenge(_param,c_func(self.onChallengeEvent,self))
end
]]

function TrialDetailView:showDeblockActionCallBack(data)
    -- echo("-------------------------------------------------------------------");
    -- echo("----------------showDeblockActionCallBack-----------------");
    -- echo("-------------------------------------------------------------------");

    EventControler:dispatchEvent(TrialEvent.BATTLE_SUCCESSS_EVENT, 
            {}); 

    if self._preClickDeblock == true and 
        self._result == 1 then 
        self.mc_tiaozhan:setVisible(false);

        self:disabledUIClick();

        -- echo("callBackFunc initPoint")

        function callBackFunc()
            -- echo("callBackFunc");
            self:resumeUIClick();
            self.mc_tiaozhan:setVisible(true);
            self._blockAni:setVisible(false);
            self:initMcBtn(self._selectIndex);
            self:delayCall(function ()
                -- echo(" callBackFunc callBackFunc ");
                self._blockAni:removeFromParent();
            end)
            AudioModel:playSound("s_com_appearBtn");
        end

        AudioModel:playSound("s_trial_jiefeng");
        --展示动画
        self._blockAni = self:createUIArmature("UI_shilian_fengyin","UI_shilian_fengyin_donghua",
            self.ctn_unblock, false, callBackFunc);
        self._preClickDeblock = nil;
        self._result = nil;
        -- self:initPoint();
    else 
        -- echo("showDeblockActionCallBack initPoint")
        -- self:initPoint();
        self:initMcBtn(self._selectIndex);
    end 
end

-- 战斗结束回调
function TrialDetailView:endBattleCallback(event)
    -- echo("endBattleCallback");
    -- dump(event.result.data, "_____endBattleCallback-----");

    local reward = {};
    if event.result.data ~= nil then 
        reward = event.result.data.data;
    end 

    BattleControler:showReward( {reward = reward,
        result = self._result});
end

function TrialDetailView:sweepCallback(event)
    -- echo("sweepCallback callBack");
    if event.error == nil then 
        -- echo("sweepCallback ok")
        dump(event.result.data, "datttt");
        WindowControler:showWindow("TrialSweepNewView", 
            event.result.data.reward);

        EventControler:dispatchEvent(TrialEvent.SWEEP_BATTLE_SUCCESS_EVENT, {});
    end 
end

function TrialDetailView:sweepSuccessCallback()
    -- echo("sweepSuccessCallback");
    
    EventControler:dispatchEvent(TrialEvent.BATTLE_SUCCESSS_EVENT, 
            {}); 


    self:initMcBtn(self._selectIndex);
    -- self:initPoint();   
    self:InfoShow(self._selectIndex)
end

function TrialDetailView:press_btn_back()
    self:startHide();
end

function TrialDetailView:press_btn_wenhao()
    WindowControler:showWindow("TrailSweepInfoView", self._trailKind);
end

--function TrialDetailView:press_btn_gengduo()
--    local id = TrailModel:getIdByTypeAndLvl(self._trailKind, self._selectIndex);

--    --推荐法宝
--    local treasureIds = FuncTrail.getTrailData(id, "recommend");

--    WindowControler:showWindow("TrailRecommendTreasureView", treasureIds)
--end

function TrialDetailView:lvlUpCallBack()
    -- echo("lvlUpCallBack");
    self:initUI();
end

function TrialDetailView:updateUI()
	
end

function TrialDetailView:getAdaptationSizeCoeffcient(ctn, targetNode)
    local ctnWidth = ctn.ctnWidth;
    local ctnHeight = ctn.ctnHeight;

    -- echo("ctnWidth " .. tostring(ctnWidth));
    -- echo("ctnHeight " .. tostring(ctnHeight));

    local box = targetNode:getBoundingBox();
    -- dump(box, "box");
    local targetWidth, taregetHeight = box.width, box.height;

    local widthCoeffcient = ctnWidth / targetWidth;
    local heightCoeffcient = ctnHeight / taregetHeight;

    -- echo("widthCoeffcient " .. tostring(widthCoeffcient));
    -- echo("heightCoeffcient " .. tostring(heightCoeffcient));

    return widthCoeffcient > heightCoeffcient and widthCoeffcient or heightCoeffcient;
end
function TrialDetailView:press_btn_guize()
    WindowControler:showWindow("TrailRegulationView",self._trailKind)
end



return TrialDetailView;


