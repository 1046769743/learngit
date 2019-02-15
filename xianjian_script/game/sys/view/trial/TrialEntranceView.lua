--2016.2.19 第二版
--guan

local TrialEntranceView = class("TrialEntranceView", UIBase);

--[[
    self.UI_trial_homepage,
    self.btn_back,
    self.btn_,
    self.btn_1,
    self.btn_2,
]]

function TrialEntranceView:ctor(winName)
    TrialEntranceView.super.ctor(self, winName);
end

function TrialEntranceView:loadUIComplete()
	self:registerEvent();
    self:resolutionAdaptation();
    self:initUI();
end 

function TrialEntranceView:resolutionAdaptation()
    --左上
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_name1, UIAlignTypes.LeftTop);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_guize, UIAlignTypes.LeftTop);
    --右上
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back, UIAlignTypes.RightTop);
--//在安卓上适配
   if(device.platform=="android")then
         local    txt=self.btn_1:getUpPanel().panel_1.txt_cishu2
         txt:setPositionY(txt:getPositionY()+3);

         txt=self.btn_2:getUpPanel().panel_1.txt_cishu2;
         txt:setPositionY(txt:getPositionY()+3);

         txt=self.btn_3:getUpPanel().panel_1.txt_cishu2
         txt:setPositionY(txt:getPositionY()+3);
   end
end

function TrialEntranceView:registerEvent()
	TrialEntranceView.super.registerEvent();
    self.btn_back:setTap(c_func(self.press_btn_back, self));
    self.btn_1:setTap(c_func(self.press_btn_1, self));
    self.btn_2:setTap(c_func(self.press_btn_2, self));
    self.btn_3:setTap(c_func(self.press_btn_3, self));
--    self.btn_guize:setTap(c_func(self.press_btn_guize, self));

    EventControler:addEventListener(TrialEvent.BATTLE_SUCCESSS_EVENT,
        self.battleSuccessCallBack, self);

    --定点刷新
    EventControler:addEventListener(TimeEvent.TIMEEVENT_STATIC_CLOCK_REACH_EVENT, 
        self.staticTimeReach, self)
end

function TrialEntranceView:staticTimeReach(event)
    local clock = event.params.clock;
    echo("staticTimeReach " .. tostring(clock));

    if clock == "04:00:00" then 
        self:initUI();
    else 
        echo("not equal 4 ");
    end 
end

function TrialEntranceView:press_btn_back()
    self:startHide()
end

function TrialEntranceView:press_btn_1()
    if TrailModel:isTrialTypeOpenCurrentTime(1) == true then
            WindowControler:showWindow("TrialDetailView", 1);
    else
        local notOpneStr = GameConfig.getLanguage("trail_not_open");
        WindowControler:showTips({text = notOpneStr});
    end

end

function TrialEntranceView:press_btn_2()
    if TrailModel:isTrialTypeOpenCurrentTime(2) == true then
            WindowControler:showWindow("TrialDetailView", 2);
    else
        local notOpneStr = GameConfig.getLanguage("trail_not_open");
        WindowControler:showTips({text = notOpneStr});
    end
end

function TrialEntranceView:press_btn_3()
    if TrailModel:isTrialTypeOpenCurrentTime(3) == true then
            WindowControler:showWindow("TrialDetailView", 3);
    else
        local notOpneStr = GameConfig.getLanguage("trail_not_open");
        WindowControler:showTips({text = notOpneStr});
    end

end

function TrialEntranceView:updateUI()
	
end

function TrialEntranceView:initUI()
    for i = 1, 3 do
        self:initTrailKindUI(i);
    end
end

function TrialEntranceView:initTrailKindUI(trailKind)
    local panel = self["btn_" .. tostring(trailKind)]:getUpPanel().panel_1;
    --todo 剩余次数
    local leftTime = CountModel:getTrialCountTime(trailKind);
    local totalNum = TrailModel:getTotalCount();

    panel.txt_cishu2:setString(tostring(totalNum - leftTime) .. "/" .. tostring(totalNum));

    if TrailModel:isTrialTypeOpenCurrentTime(trailKind) == true then 
--        panel.panel_weikai:setVisible(false);
    else
        panel.scale9_outerGlow:setVisible(false);
        panel.txt_cishu1:setVisible(false);
        panel.txt_cishu2:setVisible(false);
        panel.panel_weikai:setVisible(true);
    end 

    --boss
    local bossConfig = FuncTrail.getTrialResourcesData(trailKind, "dynamic");
    local arr = string.split(bossConfig, ",");
    local ctn = panel.ctn_boss;

    ctn:removeAllChildren();
    panel.ctn_dizuo:removeAllChildren();
    panel.ctn_ding:removeAllChildren();

    local sp = ViewSpine.new(arr[1], {}, arr[1]);
    sp:playLabel(arr[2]);

    if arr[4] == "1" then 
        sp:setRotationSkewY(180);
    end 

    if arr[5] ~= nil then -- 缩放
        sp:setScale(tonumber(arr[5]))
    end
    if arr[6] ~= nil then -- x轴偏移
        sp:setPositionX(sp:getPositionX() + tonumber(arr[6]))
    end
    if arr[7] ~= nil then -- y轴偏移
        sp:setPositionY(sp:getPositionY() + tonumber(arr[7]))
    end

    local bedDownArmature = nil;
    local bedUpArmature = nil;
    local bedDownArmature2 = nil;
    local xueyaoAni = nil
    --山神
    if trailKind == 1 then 
        bedDownArmature = self:createUIArmature("UI_shilian","UI_shilian_shanshen_di", 
            panel.ctn_dizuo, true);
        bedUpArmature = self:createUIArmature("UI_shilian","UI_shilian_shanshen_ding", 
            panel.ctn_ding, true);
        bedDownArmature2 = self:createUIArmature("UI_shilian","UI_shilian_shanshen_fazhen", 
            panel.ctn_dizuo, true);
    elseif trailKind == 2 then --火神
        bedDownArmature = self:createUIArmature("UI_shilian","UI_shilian_huoshen_di", 
            panel.ctn_dizuo, true);
        bedUpArmature = self:createUIArmature("UI_shilian","UI_shilian_huoshen_ding", 
            panel.ctn_ding, true);
        bedDownArmature2 = self:createUIArmature("UI_shilian","UI_shilian_huoshen_fazhen", 
            panel.ctn_dizuo, true);
    else 
--        bedDownArmature = self:createUIArmature("UI_shilian","ui_shilian_leishen_di", 
--            panel.ctn_dizuo, true);
--        bedUpArmature = self:createUIArmature("UI_shilian","ui_shilian_leishen_ding", 
--            panel.ctn_ding, true);   
            xueyaoAni = self:createUIArmature("UI_shilian","UI_shilian_xueyao", 
            panel.ctn_dizuo,true);
               
    end

    if TrailModel:isTrialTypeOpenCurrentTime(trailKind) == false then 
        sp:gotoAndStop(tonumber(arr[3]) );
        if bedDownArmature ~= nil then
            FuncArmature.playOrPauseArmature(bedDownArmature, false);
        end
        if bedDownArmature ~= nil then
            FuncArmature.playOrPauseArmature(bedUpArmature, false);
        end
        if bedDownArmature2 ~= nil then 
            FuncArmature.playOrPauseArmature(bedDownArmature2, false);
        end 
    end 

    ctn:addChild(sp);
    if xueyaoAni ~= nil then
        echo("雪妖 替换")
        ctn:setPositionX(ctn:getPositionX()- ctn.ctnWidth/2 - 40);
        ctn:setPositionY(ctn:getPositionY() + ctn.ctnHeight/2 );
        FuncArmature.changeBoneDisplay(xueyaoAni, "node", ctn ); 
    end
    local adaptationSizeCoeffcient = self:getAdaptationSizeCoeffcient(ctn, sp);
    sp.currentAni:setScale(adaptationSizeCoeffcient);

    -- 奖励预览
    local rewards = FuncTrail.getTrialResourcesData(trailKind, "rewardscan");
    for i = 1 ,4 do
        local itemReward = rewards[i]
        if itemReward ~= nil then
            local item_view = panel["UI_"..i]
            item_view:setResItemData({reward = itemReward})
            item_view:showResItemName(false)
            item_view:updateItemUI()
            item_view:setVisible(true)
        else
            item_view:setVisible(false)
        end
    end
    
end

function TrialEntranceView:getAdaptationSizeCoeffcient(ctn, targetNode)
    local ctnWidth = ctn.ctnWidth;
    local ctnHeight = ctn.ctnHeight;

    echo("ctnWidth " .. tostring(ctnWidth));
    echo("ctnHeight " .. tostring(ctnHeight));

    local box = targetNode:getBoundingBox();

    -- dump(box, "box");
    
    local targetWidth, taregetHeight = box.width, box.height;

    local widthCoeffcient = ctnWidth / targetWidth;
    local heightCoeffcient = ctnHeight / taregetHeight;

    echo("widthCoeffcient " .. tostring(widthCoeffcient));
    echo("heightCoeffcient " .. tostring(heightCoeffcient));

    return widthCoeffcient > heightCoeffcient and widthCoeffcient or heightCoeffcient;
end

function TrialEntranceView:battleSuccessCallBack()
    for i = 1, 3 do
        --todo剩余次数
        local leftTime = CountModel:getTrialCountTime(i);
        local panel = self["btn_" .. tostring(i)]:getUpPanel().panel_1;
        local totalNum = TrailModel:getTotalCount();
        panel.txt_cishu2:setString(tostring(totalNum - leftTime) .. "/" .. tostring(totalNum));

    end

    EventControler:dispatchEvent("TIAOZHANHONGDIANSHUAXIN")
end

function TrialEntranceView:press_btn_guize()
    WindowControler:showWindow("TrailRegulationView")
end

return TrialEntranceView;




















