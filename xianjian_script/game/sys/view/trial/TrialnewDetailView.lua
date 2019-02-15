--2017.5.11
--wukai

local TrialnewDetailView = class("TrialnewDetailView", UIBase);

function TrialnewDetailView:ctor(winName, trialKind)
    TrialnewDetailView.super.ctor(self, winName);
    echo("=========试炼类型==============",trialKind)
    self._trailKind = trialKind;
 
    
end
function TrialnewDetailView:get_trailKind(trialKind)
    return (trialKind-3000-self._selectIndex)/5 + 1
end

function TrialnewDetailView:loadUIComplete()
    --左上
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_slbiaoti, UIAlignTypes.LeftTop);
    --右上
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back, UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_ding, UIAlignTypes.RightTop);
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.scroll_1, UIAlignTypes.Right);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_wen, UIAlignTypes.LeftTop);
    -- FuncCommUI.setScale9Align(self.widthScreenOffset,self.scale9_1,UIAlignTypes.MiddleTop,1,0)

    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_liangzhong,UIAlignTypes.LeftBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_man1,UIAlignTypes.LeftBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_man2,UIAlignTypes.LeftBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_man3,UIAlignTypes.LeftBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_man4,UIAlignTypes.LeftBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_man5,UIAlignTypes.LeftBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.scale9_2,UIAlignTypes.LeftBottom)
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.scale9_jiugongge, UIAlignTypes.RightTop);

    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_3,UIAlignTypes.MiddleBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_tiaozhan,UIAlignTypes.RightBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_zuiqiang, UIAlignTypes.LeftTop);

    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_shipei, UIAlignTypes.RightTop);


    FuncCommUI.setViewAlign(self.widthScreenOffset,self.scale9_xxaax, UIAlignTypes.MiddleBottom);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_jinzhi, UIAlignTypes.MiddleBottom);

    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_bg, UIAlignTypes.MiddleBottom);

    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_shipei.btn_up, UIAlignTypes.RightTop);
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_shipei.btn_down, UIAlignTypes.LeftBottom);
    local size2 = self.panel_shipei.scale9_jiugongge:getContentSize()
    self.scale9_2:size(GameVars.width - 160 - GameVars.toolBarWidth,138)
    self.panel_shipei.scale9_jiugongge:setScaleY(GameVars.height/size2.height)
    -- self.panel_shipei.scale9_jiugongge:size(138,GameVars.height)

    -- self.scale9_qipao:setVisible(false)
    -- self.txt_shan1:setVisible(false)
    -- self.panel_talk:setVisible(false)
    
    -- 预览
    -- self.btn_yulan:setTap(c_func(self.previewReward, self))
    self.btn_wen:setTap(c_func(self.press_btn_guize, self));

    self.ani = nil

    -- self.isopenTrial = TrailModel:isTrialTypeOpenCurrentTime(self._trailKind)
    self:buttonRedXiaoshi()
	self:registerEvent();  


    self:initUI();
    -- self:initUI();

    -- self:staticTimeReach()  ---到点刷新
    self:friendTuiJianData()
    self:showFriendView()
    self:addSpn()

    self:setdes()

    self:onTempShopOpen() --- 展示临时商店

    self:onTempShopOpen()     ---跳出灵石商店

--[[
    local datas =   {    
         _type = "CHAT_TYPE_PARTNER_SKIN",  ---类型
        subtypes = "friend",  ----世界，公会，好友列表
        data = { skinId = 111 }
    }

    ChatShareControler:SendPlayerShareGood(datas)

--]]

end

--设置描述
function TrialnewDetailView:setdes()
     
    self.mc_jinzhi:showFrame(tonumber(self._trailKind))

end


function TrialnewDetailView:showFriendView()
    local playdata = TrailModel:getchallengaddfrienddata()
    if playdata ~= nil then
        WindowControler:showWindow("CompNotifeAddFriendView",playdata)
    end
end

function TrialnewDetailView:buttonRedXiaoshi()
    self.btn_3:getUpPanel().panel_red:setVisible(false)
    self.mc_tiaozhan:getViewByFrame(1).btn_2:getUpPanel().panel_red:setVisible(false)
    self.mc_tiaozhan:getViewByFrame(2).btn_2:getUpPanel().panel_red:setVisible(false)
 end 

-- function TrialnewDetailView:()
--     -- body
-- end
--[[
--预览奖励
function TrialnewDetailView:previewReward( )
    -- self._selectIndex
    local id = TrailModel:getIdByTypeAndLvl(self._trailKind, self._selectIndex);
    local rewards = FuncTrail.getTrailData(id, "trialReward");
    -- dump(rewards,"奖励")
    WindowControler:showWindow("TrailPreviewView",self._trailKind,self._selectIndex);

end
--]]
function TrialnewDetailView:registerEvent()
	TrialnewDetailView.super.registerEvent();
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



    -- --临时商店功能更
    -- EventControler:addEventListener(ShopEvent.SHOPEVENT_TEMP_SHOP_OPEN, 
    --     self.onTempShopOpen, self);

    --关闭布阵界面
    -- EventControler:addEventListener(BattleEvent.CLOSE_TEAM_FORMATION_FOR_BATTLE,self.doBackClick,self)

    --开始战斗界面
    EventControler:addEventListener(BattleEvent.BEGIN_BATTLE_FOR_FORMATION_VIEW, self.onTeamFormationComplete, self)

    
    -- EventControler:addEventListener(TrialEvent.AGAIN_MATCHING,self.twoPipeiview, self)
    -- EventControler:addEventListener(TrialEvent.AGAIN_MATCHING, self.challengButton, self)
    EventControler:addEventListener(ChatEvent.FRIEND_REMOVE_ONE_PLAYER ,self.friendTuiJianData,self)


    

    
end

function TrialnewDetailView:doBackClick(data)
    -- dump(data.params,"关闭布阵界面")
end
--布阵挑战
function TrialnewDetailView:onTeamFormationComplete(data)
    -- dump(data.params,"布阵挑战")


    local params = data.params
    if params.systemId == FuncTeamFormation.formation.trailPve1 or params.systemId == FuncTeamFormation.formation.trailPve2 or params.systemId == FuncTeamFormation.formation.trailPve3  then
        local id = TrailModel:getIdByTypeAndLvl(self._trailKind, self._selectIndex);
        TrialServer:startBattle(c_func(self.startBattleCallback, self,id,2), id, 1,params.formation);
        -- EventControler:(BattleEvent.CLOSE_TEAM_FORMATION_FOR_BATTLE,self.doBackClick,self)
    end
end



function TrialnewDetailView:onTempShopOpen()
    if TrailModel.shopType ~= nil then
        WorldModel:resetDataBeforeBattle()
        WindowControler:showWindow("ShopKaiqi", TrailModel.shopType)
        TrailModel.shopType = nil
    end
end

function TrialnewDetailView:staticTimeReach()
    -- local clock = event.params.clock;
    -- 到点刷新

    -- if clock == "04:00:00" then 
        -- self.mc_tiaozhan:setTouchedFunc(
        --     c_func(self.timeOver, self));
    -- else 
    --     echo("not equal 4 ");
    -- end  self._trailKind
    -- echo("11111111111111111111111111111111111111111111111111")
    -- if TrailModel:isTrialTypeOpenCurrentTime(self._trailKind) == false then
    --     self.mc_shengyu:visible(false)
    --     self.ani:visible(false)
    --     self.mc_tiaozhan:showFrame(1);
    --     FilterTools.setGrayFilter(self.mc_tiaozhan)
    --     self.mc_tiaozhan:getViewByFrame(1).btn_2:getUpPanel().panel_red:visible(false)
    --     self.mc_tiaozhan:getViewByFrame(2).btn_3:getUpPanel().panel_red:visible(false)
    --     self.isopenTrial = false
    -- else
    --     self.isopenTrial = true
    -- end

    -- self:initUI()
end

function TrialnewDetailView:timeOver()

    if TrailModel:isTrialTypeOpenCurrentTime(self._trailKind) == false then
        -- WindowControler:showTips({text =" 此试炼已过期"})

    end 
end

function TrialnewDetailView:initUI() 

     -- 按钮 闪光
    -- local leftCount = TrailModel:getLeftCounts(self._trailKind);
    -- if self.ani == nil then
    --     self.ani= self:createUIArmature("UI_common","UI_common_zhonganniu", self.mc_tiaozhan, true);
    --     self.ani:setPosition(self.ani:getPositionX() + 90,self.ani:getPositionY() - 47)
    --     self.ani:setScale(1.2)
    -- end


    self:initSelectBar();

    --[[
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

    --]]
end 
--点击boos获得详情界面   ---点击显示动作方法

function TrialnewDetailView:playRandomAni()

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
function TrialnewDetailView:initPoint()
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
function TrialnewDetailView:initSelectBar()
    --todo 跳到1个 
    self._selectIndex = 1;
    -- if  self.pathdoing  == false then
        for i = 1,5 do
            if TrailModel:isTrailOpen(self._trailKind, i) == true then
                if TrailModel:isDeblockThanKindAndLvl(self._trailKind, i) == false then
                    -- if self._selectIndex < i then
                        self._selectIndex = i 
                        break
                else
                    self._selectIndex = i 
                    -- end
                end
            end
        end
        -- local _index = Cache:get("shilianIndex",nil)
        -- if _index then
        --     self._selectIndex = _index;
        --     Cache:set("shilianIndex",nil)
        -- end
    -- end
    
    local Traildiffid = TrailModel:getTraildiffid()
    if Traildiffid ~= nil then
        self._selectIndex = Traildiffid
    end
    

    -- self.panel_ndqiehuan:setVisible(false)
    self.panel_shipei.mc_qiehuan:setVisible(false)
    local createFunc = function(_itemdata)
        local _itemView = UIBaseDef:cloneOneView(self.panel_shipei.mc_qiehuan) 
        self:updataItem(_itemView,_itemdata)
        return _itemView
    end

    -- local reuseUpdateCellFunc = function(_itemdata, _itemView)
    --     -- self:updataItem(_itemView,_itemdata)
    --     return _itemView
    -- end
  
    local _data = {}
    for i = 1,5 do
        table.insert(_data,i)
    end
    
    local params = {
            {
                data = _data,
                createFunc = createFunc,
                perNums = 1,
                offsetX = 27,
                offsetY = 20,
                widthGap = 0,
                heightGap = 0,
                itemRect = { x = 0, y = -85, width = 130, height = 85 },
                perFrame = 200,
            }
    }
    self.scroll_1 = self.panel_shipei.scroll_1

    self.scroll_1:cancleCacheView();
    self.scroll_1:styleFill(params)
    self.scroll_1:setCanScroll(true);
    self.scroll_1:hideDragBar()
    -- echo("==============self._selectIndex=========",self._selectIndex)
    self.scroll_1:gotoTargetPos(self._selectIndex ,1,1)
    self:initDifficultUI(self._selectIndex);  ---初始化奖励数据和按钮问题
end 
function TrialnewDetailView:updataItem(itemView,itemData)
    -- echo("=========1111111111111===========",itemData)

    local id = TrailModel:getIdByTypeAndLvl(self._trailKind, itemData);
    local name = FuncTrail.getTrailData(id, "diffName");
    local txt
    local txt1; 

    local  txt = itemView:getViewByFrame(1).btn_1:getUpPanel().mc_1
    local  txt2 = itemView:getViewByFrame(1).btn_1:getDownPanel().mc_1
    txt:showFrame(tonumber(itemData))
    txt2:showFrame(tonumber(itemData))
    local mc_txt1 = itemView:getViewByFrame(2).btn_1:getUpPanel().mc_1
    local mc_txt2 = itemView:getViewByFrame(2).btn_1:getDownPanel().mc_1
    mc_txt1:showFrame(tonumber(itemData))
    mc_txt2:showFrame(tonumber(itemData))

    if TrailModel:isDeblockThanKindAndLvl(self._trailKind, itemData) == true then
        itemView:getViewByFrame(1).panel_feng:setVisible(false)
        itemView:getViewByFrame(2).panel_feng:setVisible(false)
    else
        itemView:getViewByFrame(1).panel_feng:setVisible(true)
        itemView:getViewByFrame(2).panel_feng:setVisible(true)
    end

    if TrailModel:isTrailOpen(self._trailKind, itemData) == true then
        if self._selectIndex == itemData then
            itemView:showFrame(2)
            itemView.currentView.panel_suo:setVisible(false)
        else
            itemView:showFrame(1)
            itemView.currentView.panel_suo:setVisible(false)
        end
    else
        itemView.currentView.panel_feng:setVisible(false)
    end
    
    itemView:getViewByFrame(1).btn_1:setTouchedFunc(c_func(self.mcBtnClick, self, itemData))
end



function TrialnewDetailView:mcBtnClick(difficut)
    -- echo("========difficut=================",difficut)
    if self.scroll_1:isMoving() then
		return
	end 
    -- if self.isopenTrial then
        if self._selectIndex ~= difficut then 
            local isOpen, needLvl = TrailModel:isTrailOpen(self._trailKind, difficut);
            if isOpen == true then 
                -- echo("self._selectIndex===",self._selectIndex)
                local lastView = self.scroll_1:getViewByData(self._selectIndex)
                lastView:showFrame(1)
    --            local txt1 = lastView.currentView.btn_1:getUpPanel().txt_1
    --            local id1 = TrailModel:getIdByTypeAndLvl(self._trailKind, self._selectIndex);
    --            local name1 = FuncTrail.getTrailData(id1, "diffName");
    --            txt1:setString(GameConfig.getLanguage(name1))
                -- lastView.currentView.panel_feng:setVisible(false)
                lastView.currentView.panel_suo:setVisible(false)
                if TrailModel:isDeblockThanKindAndLvl(self._trailKind, self._selectIndex) == true then
                    lastView:getViewByFrame(1).panel_feng:setVisible(false)
                    lastView:getViewByFrame(2).panel_feng:setVisible(false)
                else
                    lastView.currentView.panel_feng:setVisible(true)
                end
                


                self._selectIndex = difficut;
                self:initDifficultUI(difficut);
                local newView = self.scroll_1:getViewByData(self._selectIndex)
                newView:showFrame(2)
    --            local txt2 = newView.currentView.btn_2:getUpPanel().txt_1
    --            local id2 = TrailModel:getIdByTypeAndLvl(self._trailKind, self._selectIndex);
    --            local name2 = FuncTrail.getTrailData(id2, "diffName");
    --            txt2:setString(GameConfig.getLanguage(name2))
                -- newView.currentView.panel_feng:setVisible(false)
                newView.currentView.panel_suo:setVisible(false)
                newView.currentView.panel_suo:setVisible(false)
                if TrailModel:isDeblockThanKindAndLvl(self._trailKind, self._selectIndex) == true then
                    newView:getViewByFrame(1).panel_feng:setVisible(false)
                    newView:getViewByFrame(2).panel_feng:setVisible(false)
                else
                    newView.currentView.panel_feng:setVisible(true)
                end

            else 
                -- local str = FuncTranslate.getLanguageAndSub("#tid28003", "zh_CN", needLvl);
                local _str = string.format(GameConfig.getLanguage("#tid_trail_012"),tostring(needLvl))
                WindowControler:showTips(_str);
            end 
        end 
    -- end
    -- self:friendTuiJianData()
end
--挑战按钮
function TrialnewDetailView:challengButton()


    self:OntouchStarBattle()  ---内侧包 多人改 ---->  单人
----暂时屏蔽  内侧包版本
--[[
    -- echoError("cesgiu-------------")
    local function _callback(_param)
        dump(_param.result,"创建组队数据")
        if _param.result ~= nil then
            -- self:button_btn_close()
            local data = {
                _type =  self._trailKind,
                diffic = self._selectIndex,
            }
            TrailModel:setTraildiffid(self._selectIndex)
            WindowControler:showWindow("TrialNewFriendPiPeiView",data);
        end
    end   

    local id = TrailModel:getIdByTypeAndLvl(self._trailKind, self._selectIndex);
    local params = {}
    params.trialId = id
    TrialServer:sendCreateTeam(params,_callback)
--]]

end
function TrialnewDetailView:newstartBattleCallback(event)
    -- dump(event.result,"匹配数据")

    -- WindowControler:showWindow("TrialNewFriendPiPeiView", self.SelectType);   ---跳到匹配界面
end
function TrialnewDetailView:SweepButton()

    TrailModel:setTraildiffid(self._selectIndex)
	local id = TrailModel:getIdByTypeAndLvl(self._trailKind, self._selectIndex);
	TrialServer:sweep(c_func(self.sweepCallback, self), id, 1);
end
function TrialnewDetailView:JieFengButton()
	-- echoError("======解封按钮==============")

    --    
    if  TrailModel:IsTrailjiefeng(self._trailKind,self._selectIndex) then
        self:OntouchStarBattle()
    else
        WindowControler:showTips(GameConfig.getLanguage("#tid_trail_013"))
    end
end
function TrialnewDetailView:HuiSeSweepButton(TrialId)
    echo("弹扫荡灰色按钮=tips===",TrialId)
    -- FuncCommUI.regesitShowTrialTipView( self.btn_3,TrialId,false )
    local point = {}
    point.x = self.btn_3:getPositionX()
    point.y = self.btn_3:getPositionY()

    WindowControler:showWindow("TrailSaoDangTips",TrialId,point)
end
function TrialnewDetailView:SweepFinishTimeTips()
    local Trailid = TrailModel:getIdByTypeAndLvl(self._trailKind, self._selectIndex);
    local sumtime = TrailModel:getSweepFinishTime(Trailid)
    local day = 0
    local alltime = 0
    if sumtime ~= 0 then
        alltime = sumtime-TimeControler:getServerTime()
        day = math.floor((alltime)/(24*3600))
    end
    if day == 0 then
        time = math.floor(alltime/3600) 
        if time == 0 then
            time = "1小时"
        else
            time = time.."小时"
        end
    else
        time = day .."天"
    end
    -- self.panel_1.txt_1:setString(time.."后开启扫荡功能")
    WindowControler:showTips(time..GameConfig.getLanguage("#tid_trail_004"))
end
function TrialnewDetailView:paixudata(data)
    local newreward = {}
    for i=1,#data do
        local rew  = string.split(data[i], ",")
        local table = {
            id = rew[2],
            number = rew[3],
            types = rew[1],
        }
        newreward[i] = table
    end
    table.sort(newreward,c_func(self.Trial_sort,self))


    -- dump(newreward,"sssssssssssssssssss")
    local zuihoudata = {}
    for i=1,#newreward do
        local string = newreward[i].types..","..newreward[i].id..","..newreward[i].number
        zuihoudata[i] = string
    end


    -- dump(zuihoudata,"0000000000000000000")

    return zuihoudata
end
function TrialnewDetailView:Trial_sort(a,b)
    local _sortType = function (_ret)
        if self._sortType then
            return _ret
        else    
            return not _ret
        end
    end
    -- echo("================a========b=",a,b)

    if a.id > b.id then
        return _sortType(false)
    elseif a.id < b.id  then
        return _sortType(true)
    end
end


function TrialnewDetailView:chalButtonNotitemNum()
   WindowControler:showTips(GameConfig.getLanguage("#tid_trail_014"));
end
function TrialnewDetailView:initDifficultUI(difficut)
    -- self:initPoint();
    -- echo("============difficut==========",difficut)

    -- echo("初始化界面 " .. tostring(difficut));
    -- self.panel_ndqiehuan["mc_nd" .. tostring(difficut)]:showFrame(2);
    --奖励
    local id = TrailModel:getIdByTypeAndLvl(self._trailKind, difficut);
    local rewards = {} --= FuncTrail.getTrailData(id, "trialReward");  --挑战奖励
    local awardtype = nil
    -- local trialRewardFirst = FuncTrail.getTrailData(id, "trialRewardFirst");  --解封奖励
    -- local magnitudes = FuncTrail.getTrailData(id, "magnitude");
    -- dump(rewards,"试炼奖励预览")
    if TrailModel:isDeblockThanKindAndLvl(self._trailKind, self._selectIndex) == true then

    
    	---解封
    	-- rewards = FuncTrail.newgetTrailData(id, "trialReward");  --挑战奖励

        rewards = FuncTrail.getTrailIDbyReward(self._trailKind,id,true)  
        rewards = self:paixudata(rewards)

    	-- self.panel_zuiqiang:setVisible(true)
    	self.btn_3:setVisible(false) ---测试
    	self.mc_tiaozhan:showFrame(2)
        -- self.mc_tiaozhan:getViewByFrame(2).btn_2:setVisible(false)  ----测试
    	
    	
    	self.mc_liangzhong:showFrame(2)
        -- self.mc_liangzhong:setVisible(false)
    	awardtype = 2
        -- local sweeptime = TrailModel:getSweepFinishTime(id) --Trailserverdata.time
        local sum = FuncTrail.getSumChallengNum()
        local num = TrailModel.StarData[tostring(id)].count or 0
        local mc_1 = self.mc_tiaozhan:getViewByFrame(2).mc_1

        -- txt_1:setString("挑战次数："..(sum- num).."/"..sum)
        if num >= sum then
            mc_1:showFrame(2)
            mc_1:getViewByFrame(2).txt_1:setString(GameConfig.getLanguage("#tid_trail_015")..(sum- num).."/"..sum)
            self.mc_tiaozhan:getViewByFrame(2).btn_2:setTap(c_func(self.chalButtonNotitemNum,self))   --挑战按钮
            self.mc_tiaozhan:getViewByFrame(2).btn_2:getUpPanel().panel_red:setVisible(false)
        else
            mc_1:showFrame(1)
            mc_1:getViewByFrame(1).txt_1:setString(GameConfig.getLanguage("#tid_trail_015")..(sum- num).."/"..sum)
            self.mc_tiaozhan:getViewByFrame(2).btn_2:setTap(c_func(self.challengButton,self))   --挑战按钮
            self.mc_tiaozhan:getViewByFrame(2).btn_2:getUpPanel().panel_red:setVisible(true)
        end
        -- if TrailModel:ByTypeAndIDgetRedIshow(self._trailKind,difficut) then
        --     self.mc_tiaozhan:getViewByFrame(1).btn_2:getUpPanel().panel_red:setVisible(true)
        -- end

        -- local time = FuncTrail.getServerTime(id,sweeptime)

        local time = TrailModel:getSweepFinishTime(id) --Trailserverdata.time
        -- echo("===========time==========",time,TimeControler:getServerTime(),time -  TimeControler:getServerTime())
        if time ~= 0 then
            self.panel_zuiqiang:setVisible(true)
            if time <=  TimeControler:getServerTime() then
                -- if time ~= 0 then 
                    FilterTools.clearFilter(self.mc_tiaozhan);
                    -- self.btn_3:setTap(c_func(self.btn_3,self))  ----扫荡按钮
                    self.btn_3:setTap(c_func(self.SweepButton,self,id))

                -- else
                --     FilterTools.setGrayFilter(self.btn_3);
                --     self.btn_3:setTap(c_func(self.SweepFinishTimeTips,self,id))  ----灰色扫荡按钮
                -- end
                -- self.panel_zuiqiang:setVisible(false)
            else
                FilterTools.setGrayFilter(self.btn_3);
                self.btn_3:setTap(c_func(self.SweepFinishTimeTips,self,id))  ----灰色扫荡按钮
                -- self.panel_zuiqiang:setVisible(false)
            end
        else
            self.btn_3:setVisible(false)
            -- self.panel_zuiqiang:setVisible(false)
        end

	else
		--未解封
		rewards = FuncTrail.newgetTrailData(id,"trialRewardFirst");  --解封奖励
		-- self.panel_zuiqiang:setVisible(false)
		self.btn_3:setVisible(false)
		self.mc_tiaozhan:showFrame(1)
		self.mc_tiaozhan:getViewByFrame(1).btn_2:setTap(c_func(self.JieFengButton,self))  ---解封按钮
        self.mc_tiaozhan:getViewByFrame(1).btn_2:getUpPanel().panel_red:setVisible(false)
        local Trailserverdata =  TrailModel:getServerData(id)
        -- if Trailserverdata ~= nil then
        self.mc_liangzhong:setVisible(true)
        -- end
		self.mc_liangzhong:showFrame(1)
		awardtype = 1
        if TrailModel:ByTypeAndIDgetRedIshow(self._trailKind,difficut) then
            self.mc_tiaozhan:getViewByFrame(1).btn_2:getUpPanel().panel_red:setVisible(true)
        else
            self.mc_tiaozhan:getViewByFrame(1).btn_2:getUpPanel().panel_red:setVisible(false)
        end

	end
    local index = 0

    -- dump(rewards,"奖励数据")
    for i = 1, 5 do
        local itemView_1 = self["mc_man"..i]:getViewByFrame(1)["UI_1"]
        local itemView_2 = self["mc_man"..i]:getViewByFrame(2)["UI_1"]
        local itemReward = rewards[i]
        if itemReward then

        	local reward_s = string.split(itemReward, ",")
        	local rewardType = reward_s[1]      ----类型
	    	local rewardNum = reward_s[3] * 2    ---总数量
	    	local rewardId = reward_s[2] 	
            self["mc_man"..i]:setVisible(true)
            local sumnumber = 0
            local sumdata = TrailModel.StarData[tostring(id)]
            local count = 0
            if sumdata ~= nil then
               count = sumdata.count
            end
            
            local rewarddata = TrailModel:getIdByrewardNumber(self._trailKind)
            if rewarddata ~= nil then
                if rewarddata[tostring(rewardId)] ~= nil then
                    sumnumber = reward_s[3]* count  --rewarddata[tostring(rewardId)]
                end
            end
            if awardtype == 2 then
                itemReward = rewardType..","..rewardId..","..(rewardNum-sumnumber)
            end
            itemView_1:setResItemData({reward = itemReward})
            itemView_2:setResItemData({reward = itemReward})
            itemView_1:showResItemName(false)
            -- itemView_1:updateItemUI()
            -- itemView_1:showResItemNum(false)
             itemView_2:showResItemName(false)
            -- itemView_2:updateItemUI()
            -- itemView_2:showResItemNum(false)
            if awardtype == 2 then
                if rewardNum - sumnumber <= 0 then
                    self["mc_man"..i]:showFrame(2)
                    itemView_1:showResItemNum(false)
                    itemView_2:showResItemNum(false)
                    index = index  + 1
                else
                    self["mc_man"..i]:showFrame(1)
                    
                end
            else
                self["mc_man"..i]:showFrame(1)
            end

            --注册点击事件 弹框
            local  needNum,hasNum,isEnough ,resType,resId = UserModel:getResInfo(itemReward)
            FuncCommUI.regesitShowResView(itemView_1, resType, needNum, resId,itemReward,true,true)
            local  needNum,hasNum,isEnough ,resType,resId = UserModel:getResInfo(itemReward)
            FuncCommUI.regesitShowResView(itemView_2, resType, needNum, resId,itemReward,true,true)

        else
            self["mc_man"..i]:setVisible(false)
        end
    end
    FilterTools.clearFilter( self.btn_3 )
    --[[
    if awardtype == 2  then
        if index == #rewards then
            for i = 1, index do
                self["mc_man"..i]:setVisible(false)
                if i == 1 then
                    local num =  CountModel:getLimitNum()
                    local sum = FuncTrail.getRescueRewardLimit()
                    local frame = 1
                    if num >= sum then
                        frame = 2
                    end
                    self["mc_man"..i]:setVisible(true)
                    self["mc_man"..i]:showFrame(frame)
                    local itemView_1 = self["mc_man"..i]:getViewByFrame(frame)["UI_1"]
                    -- local itemView_2 = self["mc_man"..i]:getViewByFrame(2)["UI_1"]
                    local itemReward = "17,1"   ----侠义奖励
                    itemView_1:setResItemData({reward = itemReward})
                    local  needNum,hasNum,isEnough ,resType,resId = UserModel:getResInfo(itemReward)
                    FuncCommUI.regesitShowResView(itemView_1, resType, needNum, resId,itemReward,true,true)
                    -- itemView_2:setResItemData({reward = itemReward})
                    self.mc_tiaozhan:getViewByFrame(2).btn_2:getUpPanel().panel_red:setVisible(false)
                end
            end
            FilterTools.setGrayFilter(self.btn_3);
            self.btn_3:setTap(c_func(self.wupingyimangbutton, self));
        end
    end
    --]]
    -- local info = self.mc_1.currentView.panel_1
    -- self.txt_miaoshu:setString(GameConfig.getLanguage(FuncTrail.getTrailData(id, "describe")))

--[[ 
    if TrailModel:isDeblockThanKindAndLvl(self._trailKind, self._selectIndex) == true then
    -- 已解封
        self.mc_1:showFrame(1)
        --描述  
        -- local info = self.mc_1.currentView.panel_1
        -- info.txt_miaoshu:setString(GameConfig.getLanguage(FuncTrail.getTrailData(id, "describe")))
        -- -- 消耗体力
        -- info.panel_di.txt_tlshuzi:setString(FuncTrail.getTrailData(id, "winCostSp"))
        -- -- 扫荡要求
        -- info.panel_sldleiji.mc_lxicon1:showFrame(tonumber(self._trailKind))
        -- info.panel_sldleiji.txt_sld1:setString(FuncTrail.getTrailData(id, "openSweep"))

    else
        -- 未解封
        -- self.mc_1:showFrame(2)
        -- local txtMiaoshu = self.mc_1.currentView.panel_1.txt_miaoshu
        -- local txtJiefeng = self.mc_1.currentView.panel_1.txt_miaoshu2
        self.txt_miaoshu:setString(GameConfig.getLanguage(FuncTrail.getTrailData(id, "describe")))
        -- txtJiefeng:setString(GameConfig.getLanguage( FuncTrail.getTrailData(id, "firstDescribe")))
    end
--]]


    -- self:initMcBtn(difficut);
    -- self:InfoShow(difficut)
    self:ListButtonRed(difficut)
    self:addBgAndText(id)

end 
function TrialnewDetailView:ListButtonRed(_index)
    local listallcell = self.scroll_1:getAllView()
    for i=1,5 do
        if _index ~= i then
            local ishowred = TrailModel:ByTypeAndIDgetRedIshow(self._trailKind,i)
            -- echo("===========第几章ID====",i,ishowred)
            -- local id = TrailModel:getIdByTypeAndLvl(self._trailKind, i);
            -- local sum = FuncTrail.getSumChallengNum()
            -- local starData = TrailModel.StarData[tostring(id)]
            -- local num = starData.count or 0
            -- ishowred = false
            -- if  sum - num > 0 then
            --     ishowred = true
            -- end
            
            listallcell[i]:getViewByFrame(1).btn_1:getUpPanel().panel_red:visible(ishowred)
        end
    end
end
function TrialnewDetailView:addSpn()
    local ctn = self.ctn_bg;
    ctn:removeAllChildren();
    local bossConfig = FuncTrail.getTrialResourcesData(self._trailKind, "dynamic");
    local arr = string.split(bossConfig, ",");
    -- dump(arr, "bossConfig");

    local sp = ViewSpine.new(arr[1], {}, arr[1]);
    self.spinBoss = sp
    -- sp:setScale(0.9)
    sp:playLabel(arr[2]);
    ctn:addChild(sp);
end

-- art_20001_shanshen山神
-- art_20086_daobaohouzi盗宝者
-- art_20002_huoshen火神



function TrialnewDetailView:wupingyimangbutton()
    -- 
    WindowControler:showTips(GameConfig.getLanguage("#tid_trail_016"))
end
function TrialnewDetailView:addBgAndText(TrailID)
    -- echo("===========33333========",TrailID)
    local string = FuncTrail.byIdgetdata( TrailID ).describe
    self.panel_talk.txt_shan1:setString(GameConfig.getLanguage(string))

    
    -- local imgBg = FuncTrail.byIdgetdata( TrailID ).imgBg
    -- local mapBgs = display.newSprite(FuncRes.iconPVE(imgBg))
    -- mapBgs:setScale(0.73,0.65)
    -- self.ctn_bg:removeAllChildren()
    -- self.ctn_bg:addChild(mapBgs)


end
function TrialnewDetailView:friendTuiJianData()
    

    local allfriendData = FriendModel:getFriendList()
    -- dump(allfriendData,"好友数据",6)

	--设置好友推送数据
    local zuiqiangplayerInfo = TrailModel:getTrailPlayData()
    -- dump(zuiqiangplayerInfo,"最强路人数据",6)

    local luren =  self.panel_zuiqiang.panel_luren
    local mengyou = self.panel_zuiqiang.panel_mengyou
    local haoyou = self.panel_zuiqiang.panel_haoyou
    luren:setVisible(false)
    mengyou:setVisible(false)
    haoyou:setVisible(false)
    self.alldata = {}
    self.pointtable = {}
    self.pointtable[1]  = { x = luren:getPositionX(),y = luren:getPositionY()}
    self.pointtable[2]  = { x = mengyou:getPositionX(),y = mengyou:getPositionY()}
    self.pointtable[3]  = { x = haoyou:getPositionX(),y = haoyou:getPositionY()}

    -- haoyou:setPosition(cc.p(mengyou:getPositionX(),mengyou:getPositionY()))

    -- if zuiqiangplayerInfo ~= nil  then
    --     if zuiqiangplayerInfo.data.list ~= nil then
    --         if #zuiqiangplayerInfo.data.list == 0 then

    --         end
    --     end
    -- end


    self:setzuiqiangpeople(zuiqiangplayerInfo)
    self:setgonghuidata()
    self:setpeopledata(allfriendData)
    self:seticonpoint()

end
function TrialnewDetailView:seticonpoint()
    if #self.alldata ~= 0 then
        for i=1,#self.alldata do
            self.alldata[i]:setPosition(cc.p(self.pointtable[i].x,self.pointtable[i].y))
        end
    end
end
function TrialnewDetailView:setzuiqiangpeople(zuiqiangplayerInfo)   ----最强路人
    if zuiqiangplayerInfo == nil then
        return 
    end
    for k,v in pairs(zuiqiangplayerInfo.data.list) do
        if k == UserModel:rid() then
            return 
        end
    end

    local luren =  self.panel_zuiqiang.panel_luren
    local index = 1
    local peopletable = {}
    if zuiqiangplayerInfo.data ~= nil then
        if zuiqiangplayerInfo.data.list ~= nil then
            for k,v in pairs(zuiqiangplayerInfo.data.list) do
                peopletable[index] = v
                peopletable[index].rid = k
                index = index + 1
            end
        end

    end
    if #peopletable > 1 then
        table.sort(peopletable,c_func(self.partner_table_sort,self))
    end
    if #peopletable ~= 0 then
        local powerpeople = peopletable[1]
        luren:setVisible(true)
        luren.txt_level:setString(powerpeople.level or 1)
        -- luren.txt_zuiqiang:setString()
        
        local _node = luren.ctn_1;
        _node:removeAllChildren()
        local _icon = FuncChar.icon(tostring(powerpeople.avatar or 101));
        local _sprite = display.newSprite(_icon);
        local iconAnim = self:createUIArmature("UI_common", "UI_common_iconMask", _node, false, GameVars.emptyFunc)
        -- iconAnim:setScale(1.3)
        FuncArmature.changeBoneDisplay(iconAnim, "node", _sprite)
        luren:setTouchedFunc(c_func(self.touchplayerInfo, self,powerpeople),nil,true);
        table.insert(self.alldata,luren)
    end
end
function TrialnewDetailView:partner_table_sort(a,b)
    local _sortType = function (_ret)
        if self._sortType then
            return _ret
        else    
            return not _ret
        end
    end
    if a.score > b.score then
        return _sortType(false)
    elseif a.score < b.score  then
        return _sortType(true)
    end
end
function TrialnewDetailView:setpeopledata(allfriendData)   ----好友
        

    local haoyou = self.panel_zuiqiang.panel_haoyou
    -- if allfriendData.friendList ~= nil then
        if #allfriendData ~= 0 then
            local firstdata = {}
            for k,v in pairs(allfriendData) do
                if v.userExt ~= nil then
                    if v.userExt.trialTime ~= nil then
                        table.insert(firstdata,v)
                    end
                end
            end
            if #firstdata ~= 0 then
                if firstdata[1]._id == UserModel:rid() then
                    return 
                end
                haoyou:setVisible(true)
                table.sort(firstdata,c_func(self.partner_table_sort,self))
                local zuida =  firstdata[1]   ---第一个玩家
                -- dump(zuida,"匹配的最强路人数据")
                haoyou.txt_level:setString(zuida.level or 1)
                -- haoyou.txt_zuiqiang:setString()
                
                local _node = haoyou.ctn_1;
                _node:removeAllChildren()
                local _icon = FuncChar.icon(tostring(zuida.avatar or 101));
                local _sprite = display.newSprite(_icon);
                local iconAnim = self:createUIArmature("UI_common", "UI_common_iconMask", _node, false, GameVars.emptyFunc)
                -- iconAnim:setScale(1.3)
                FuncArmature.changeBoneDisplay(iconAnim, "node", _sprite)
                haoyou:setTouchedFunc(c_func(self.touchplayerInfo, self,zuida),nil,true);
                table.insert(self.alldata,haoyou)
            end
        end
    -- end
end

function TrialnewDetailView:partner_table_sort(a,b)
    local _sortType = function (_ret)
        if self._sortType then
            return _ret
        else    
            return not _ret
        end
    end
    if a.abilityNew.total > b.abilityNew.total then
        return _sortType(false)
    elseif a.abilityNew.total < b.abilityNew.total  then
        return _sortType(true)
    end
    
end
function TrialnewDetailView:setgonghuidata(alltreamData)  ---工会
    if alltreamData == nil then
        return 
    end
    local mengyou = self.panel_zuiqiang.panel_mengyou
    table.insert(self.alldata,mengyou)
end
function TrialnewDetailView:touchplayerInfo( playerInfo )

    dump(playerInfo,"玩家数据申请")

    local function _callback(param)
        if(param.result~=nil)then
            local   _fdetail=param.result.data.data[1]
            local   _playerUI=WindowControler:showWindow("CompPlayerDetailView",_fdetail,nil,3);
        end
    end
    local  _param={};
    _param.rids={};
    _param.rids[1]=playerInfo.rid or playerInfo._id;

    -- if playerInfo.isRobot == true then 
    --   WindowControler:showWindow("CompPlayerDetailView", playerInfo, nil, 2);
    -- else
    -- if playerInfo.rid ~= UserModel:rid() then
        ChatServer:queryPlayerInfo(_param,_callback);
    -- else
    --     WindowControler:showTips("不能查看自己")
    -- end
    -- end 

end
--[[
--战力推荐和星级和次数
function TrialnewDetailView:InfoShow(difficut)
    
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

    self.txt_1:setString("推荐战力："..ability) --推荐战力
    if starFrame == 0 then    
        self.panel_boss.mc_star:showFrame(4) ---星级显示
    else
        self.panel_boss.mc_star:showFrame(starFrame)
    end
    -- self.mc_shengyu:setString() --挑战剩余次数
    local leftTime = CountModel:getTrialCountTime(self._trailKind);
    local totalNum = TrailModel:getTotalCount();

    self.mc_shengyu:getViewByFrame(1).txt_1:setString("剩余挑战次数:"..tostring(totalNum - leftTime) .. "/" .. tostring(totalNum))

    if totalNum - leftTime <= 0 then
        self.mc_shengyu:showFrame(2)
        self.mc_tiaozhan:getViewByFrame(1).btn_2:getUpPanel().panel_red:visible(false)
        self.mc_tiaozhan:getViewByFrame(2).btn_3:getUpPanel().panel_red:visible(false)
        FilterTools.setGrayFilter(self.mc_tiaozhan);
        self.mc_shengyu:getViewByFrame(2).txt_1:setString("剩余挑战次数:"..tostring(totalNum - leftTime) .. "/" .. tostring(totalNum))
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

--]]
function TrialnewDetailView:goToTreasureInfo(treasureId)
    -- WindowControler:showWindow("LotteryTreasureDetail", 
    --     treasureId)
end

--[[
function TrialnewDetailView:initMcBtn( difficut )
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
            self.mc_tiaozhan:getViewByFrame(2).btn_3:getUpPanel().txt_1:setString("扫荡");
        else
            if self.isopenTrial  then
                self.mc_tiaozhan:getViewByFrame(2).btn_3:getUpPanel().txt_1:setString("扫荡"..leftCount.."次");
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
--]]
function TrialnewDetailView:battleClick()
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
         WindowControler:showTips(GameConfig.getLanguage("#tid_trail_017"));
    end 
end
function TrialnewDetailView:OntouchStarBattle()
    -- FuncTeamFormation.formation.trailPve1
    local trailPve = nil
     if self._trailKind == TrailModel.TrailType.ATTACK then
        trailPve = FuncTeamFormation.formation.trailPve1;
    elseif self._trailKind == TrailModel.TrailType.DEFAND then
        trailPve = FuncTeamFormation.formation.trailPve2;
    else
        trailPve = FuncTeamFormation.formation.trailPve3;
    end 
    TrailModel:setTraildiffid(self._selectIndex)
    WindowControler:showWindow("WuXingTeamEmbattleView",trailPve)
end

function TrialnewDetailView:openClick()
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

function TrialnewDetailView:sweepBtnClick()
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
        WindowControler:showTips(GameConfig.getLanguage("#tid_trail_017"));
    end 
end


function TrialnewDetailView:startBattleCallback(level,sigleFlag,event)
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

            -- dump(event.result.data.battleInfo,"battleinfo----",5)
            local battleInfo = BattleControler:turnServerDataToBattleInfo( event.result.data.battleInfo )
           
            --暂时的
            --battleInfo.battleLabel = GameVars.battleLabels.trailPve2
            EventControler:dispatchEvent(BattleEvent.CLOSE_TEAM_FORMATION_FOR_BATTLE,self.doBackClick,self)
            BattleControler:startPVE(battleInfo);
        end 
    end
end

  --[[  --挑战
function TrialnewDetailView:clickButtonChallengeAfter()
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

function TrialnewDetailView:showDeblockActionCallBack(data)
    -- echo("-------------------------------------------------------------------");
    -- echo("----------------showDeblockActionCallBack-----------------");
    -- echo("-------------------------------------------------------------------");

    EventControler:dispatchEvent(TrialEvent.BATTLE_SUCCESSS_EVENT, 
            {}); 

    if self._preClickDeblock == true and 
        self._result == 1 then 
        self.mc_tiaozhan:setVisible(false);

        -- self:disabledUIClick();

        -- echo("callBackFunc initPoint")

        function callBackFunc()
            -- echo("callBackFunc");
            self:resumeUIClick();
            self.mc_tiaozhan:setVisible(true);
            self._blockAni:setVisible(false);
            -- self:initMcBtn(self._selectIndex);
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
        -- self:initMcBtn(self._selectIndex);
    end 
end

-- 战斗结束回调
function TrialnewDetailView:endBattleCallback(event)
    -- echo("endBattleCallback");说
    -- dump(event.result.data, "_____endBattleCallback-----");

    local reward = {};
    if event.result.data ~= nil then 
        reward = event.result.data.data;
    end 

    BattleControler:showReward( {reward = reward,
        result = self._result});
end

function TrialnewDetailView:sweepCallback(event)
    -- echo("sweepCallback callBack");
    if event.error == nil then 
        echo("sweepCallback ok")
        -- dump(event, "扫荡返回数据");
        WindowControler:showWindow("TrialSweepNewView", 
            event.result.data.reward);
        TrailModel:sweepdata(event.result.data.dirtyList.u.trials)
        EventControler:dispatchEvent(TrialEvent.SWEEP_BATTLE_SUCCESS_EVENT, {});
        -- self:initUI()
    end 
end

function TrialnewDetailView:sweepSuccessCallback()
    -- echo("sweepSuccessCallback");
    
    EventControler:dispatchEvent(TrialEvent.BATTLE_SUCCESSS_EVENT, 
            {}); 

    -- self:initUI()
    self:initDifficultUI(self._selectIndex);
    -- self:initMcBtn(self._selectIndex);
    -- self:initPoint();   
    -- self:InfoShow(self._selectIndex)
end

function TrialnewDetailView:press_btn_back()
    TrailModel:setTraildiffid(nil)
    self:startHide();

end

function TrialnewDetailView:press_btn_wenhao()
    WindowControler:showWindow("TrailSweepInfoView", self._trailKind);
end

--function TrialnewDetailView:press_btn_gengduo()
--    local id = TrailModel:getIdByTypeAndLvl(self._trailKind, self._selectIndex);

--    --推荐法宝
--    local treasureIds = FuncTrail.getTrailData(id, "recommend");

--    WindowControler:showWindow("TrailRecommendTreasureView", treasureIds)
--end

function TrialnewDetailView:lvlUpCallBack()
    -- echo("lvlUpCallBack");
    self:initUI();
end

function TrialnewDetailView:updateUI()
	
end

function TrialnewDetailView:getAdaptationSizeCoeffcient(ctn, targetNode)
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
function TrialnewDetailView:press_btn_guize()
    WindowControler:showWindow("TrailRegulationView",self._trailKind)
end



return TrialnewDetailView;




