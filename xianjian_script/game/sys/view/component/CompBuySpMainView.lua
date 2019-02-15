-- //购买体力,源文件被误删
-- //2016-4-22
local CompBuySpMainView = class("CompBuySpMainView", UIBase);

function CompBuySpMainView:ctor(_winName)
    CompBuySpMainView.super.ctor(self, _winName);
    self.hasInit=false;
end
--
function CompBuySpMainView:loadUIComplete()
    self:registerEvent();
    self:registClickClose("out");
    -- self.btn_quxiao:setTap(c_func(self.clickButtonClose, self));
    self.btn_close:setTap(c_func(self.startHide,self));
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.txt_back,UIAlignTypes.MiddleBottom)   
    -- self:registClickClose(0, c_func( function()
    --         self:clickButtonClose()
    -- end , self))
    -- 


    self:buyStrength();
end
function CompBuySpMainView:clickButtonClose()
    self:startHide();
end
function CompBuySpMainView:registerEvent()
    CompBuySpMainView.super.registerEvent(self);
    EventControler:addEventListener(UserEvent.USEREVENT_GOLD_CHANGE,self.onEventRefresh,self);--//仙玉发生了变化
    EventControler:addEventListener(UserEvent.USEREVENT_TEQUAN_CHANGE,self.onEventRefresh,self);--//特权发生了变化
    EventControler:addEventListener(MonthCardEvent.MONTH_CARD_BUY_SUCCESS_EVENT,self.onEventRefresh,self)
end

function  CompBuySpMainView:onEventRefresh()
    self.hasInit=false;
    self:buyStrength();
end
-- //购买体力页面
function CompBuySpMainView:buyStrength()
   if(self.hasInit)then
           return;
   end
   self.hasInit=true;
    -- 标题
--    local title = GameConfig.getLanguage("tid_buy_sp_title_1007");
 --   self.panel_bg.UI_bg.txt_1:setString(title);
    -- //npc icon ,dialog
--    local _npcIcon, _npcDialog = FuncCommon.getNpcIconDialog(2);
    self.panel_1.panel_talk.txt_1:setString(GameConfig.getLanguage("#tid2006"));--//NPC体力购买提示
--    local _node = self.panel_1.ctn_1;
--    local _sprite = display.newSprite("#global_img_anu.png");--:size(_node.ctnWidth, _node.ctnHeight);
 --   _sprite:setAnchorPoint(cc.p(0.5, 0.5));
   -- _node:addChild(_sprite);
    -- //购买的次数和总次数
    self.buyTimes = CountModel:getSpBuyCount();
    self.maxTimes = UserModel:getSpMaxBuyTimes();

    self.btn_queding:getUpPanel().txt_1:setTextWidth(150)
    self.btn_queding:getUpPanel().txt_1:pos(3, -13)
    local inactiveMonthCards = MonthCardModel:getUnpurchasedMonthCards()
    -- if (self.buyTimes >= self.maxTimes) and #inactiveMonthCards > 0 then
    --     self.btn_queding:getUpPanel().txt_1:setString("查看特权")
    -- else
        self.btn_queding:getUpPanel().txt_1:setString("购  买")
    -- end

    -- echo("===================================",self.buyTimes,self.maxTimes)
    -- self.panel_1.txt_3:setString("" .. self.buyTimes .. "/"..self.maxTimes);
    -- self.panel_1.txt_4:setString("" .. self.maxTimes);
    -- self.panel_1.txt_3:setVisible(false);
    -- self.panel_1.txt_4:setVisible(false);
    local content = GameConfig.getLanguage("tid_buy_times_1002");
    -- self.panel_1.txt_1:setString(content:format(self.buyTimes, self.maxTimes));
    -- //花费的钻石数目和能购买的体力
    self.diamondCost = FuncCommon.getSpPriceByTimes(self.buyTimes + 1);
    self.spFixedNum = FuncDataSetting.getDataByConstantName("HomeCharBuySP");

    self.txt_money:setString("" .. self.diamondCost)
    self.panel_1.panel_2.txt_2:setString("" .. self.spFixedNum);
    self.panel_1.panel_dd.txt_2:setString(self.maxTimes - self.buyTimes)--"" .. self.buyTimes .. "/"..self.maxTimes);

    if(self.diamondCost>UserModel:getGold())then
        self.txt_money:setColor(cc.c3b(255,0,0));
    else
        self.txt_money:setColor(cc.c3b(0x8E,0x5F,0x35));
    end

    -- //注册按钮回调
    self.btn_queding:setTap(c_func(self.clickConfirmButton, self));
    self.panel_baoji:visible(false)

    -- 处理几条特权
    local mcname = {
        [FuncMonthCard.card_xiyao] = "mc_xiyao",
        [FuncMonthCard.card_caiyi] = "mc_caiyi",
        [FuncMonthCard.card_caishen] = "mc_caishen",
    }

    for id,mc in pairs(mcname) do
        -- 增加次数
        local num = 0
        local card = FuncMonthCard.getMonthCardById(id)
        if card and card.additionId then
            for _,addId in ipairs(card.additionId) do
                local addInfo = FuncCommon.getAdditionDataByAdditionId(addId)
                if addInfo.type == FuncCommon.additionType.addition_sp_canBuyTimes then
                    num = addInfo.subNumber
                    break
                end
            end
        end
        local curmc = self.panel_1[mc]
        -- 已经激活
        if MonthCardModel:checkCardIsActivity(id) then
            curmc:showFrame(2)
        else
            curmc:showFrame(1)
            -- 跳转
            curmc.currentView.btn_1:setTap(function()
                WindowControler:showWindow("MonthCardMainView", FuncMonthCard.CARDYEQIAN[id] )
            end)
        end

        curmc.currentView.txt_2:setString(num)
    end
end
-- //购买按钮
function CompBuySpMainView:clickConfirmButton()
    -- //次数
    if (self.buyTimes >= self.maxTimes) then 
        local inactiveMonthCards = MonthCardModel:getUnpurchasedMonthCards()
        -- if #inactiveMonthCards > 0 then
        --     WindowControler:showWindow("MonthCardMainView", FuncMonthCard.CARDYEQIAN[inactiveMonthCards[1].monthCardId])
        -- else
            local tips = GameConfig.getLanguage("tid_buy_limit_1003");
            WindowControler:showTips(tips);
        -- end
        return;
    end
    -- //购买后体力是否超过了上限
    local tid = "#tid_welfare_009"
    if UserModel:isSpOverflow(self.spFixedNum, tid) then
        return
    end
    
    -- //资源
	if not UserModel:tryCost(FuncDataResource.RES_TYPE.DIAMOND, self.diamondCost, true) then
		return
	end
    self:requestBuySp();
end
-- //发起联网请求
function CompBuySpMainView:requestBuySp()
    local function _callback(_param)
        local tips = nil;
        if (_param.result ~= nil) then
            dump(_param.result,"当前体力数据",8)


--            tips = GameConfig.getLanguage("tid_buy_sp_success_1000");
--            WindowControler:showTips(tips);
            local    _tip_content=GameConfig.getLanguage("com_buy_sp_some_success");
           
            
             local arrnumber = FuncCommUI.byNumberGetNumberArr(tostring(self.spFixedNum))

            local _flutter_label = UIBaseDef:cloneOneView(self.panel_baoji);
            _flutter_label.mc_1:showFrame(#arrnumber)
            for i=1,#arrnumber do
              _flutter_label.mc_1:getViewByFrame(#arrnumber)["mc_"..i]:showFrame(tonumber(arrnumber[i]+1))
            end

            
            local x = _flutter_label:getPositionX()
            local y = _flutter_label:getPositionY()
            -- echo("========================",x,y)
            _flutter_label:setPosition(cc.p(-100,0))
            local    _ani=self:createUIArmature("UI_buycoin","UI_buycoin_piaodong",nil,false,_remove_self);
            FuncArmature.changeBoneDisplay(_ani, "layer1", _flutter_label);


             self.ctn_ss:addChild(_ani);
            -- //购买成功后页面需要刷新
  --          self.buyTimes = self.buyTimes + 1;
            local content = GameConfig.getLanguage("tid_buy_times_1002");
            -- self.panel_1.txt_1:setString(content:format(self.buyTimes, self.maxTimes));
            self.diamondCost = FuncCommon.getSpPriceByTimes(self.buyTimes + 1);
            self.spFixedNum = FuncDataSetting.getDataByConstantName("HomeCharBuySP");

            local inactiveMonthCards = MonthCardModel:getUnpurchasedMonthCards()
            -- if (self.buyTimes >= self.maxTimes) and #inactiveMonthCards > 0 then
            --     self.btn_queding:getUpPanel().txt_1:setString("查看特权")
            -- else
                self.btn_queding:getUpPanel().txt_1:setString("购  买")
            -- end

            self.txt_money:setString("" .. self.diamondCost)
            self.panel_1.panel_2.txt_2:setString("" .. self.spFixedNum);

            self:delayCall(function ( ... )
                --发消息给任务
                echo("--DAILY_QUEST_CHANGE_EVENT--");
                EventControler:dispatchEvent(QuestEvent.DAILY_QUEST_CHANGE_EVENT, 
                    {questType = DailyQuestModel.Type.BuyVigour});
            end, 10/GameVars.GAMEFRAMERATE);
            
            EventControler:dispatchEvent(UserEvent.USEREVENT_BUY_SP_SUCCESS)
        else
            tips = GameConfig.getLanguage("tid_buy_sp_failed_1009");
            WindowControler:showTips(tips);
        end
    end
    UserServer:buySp(_callback);
end
return CompBuySpMainView;
