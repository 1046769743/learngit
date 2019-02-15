--[[
  购买铜钱
]]

local CompBuyCoinMainView = class("CompBuyCoinMainView", UIBase);
function CompBuyCoinMainView:ctor(_winName)
    CompBuyCoinMainView.super.ctor(self, _winName);
    self.hasInit=false;
end

function CompBuyCoinMainView:loadUIComplete()
    self:registerEvent();
    self:initView()
    self:updateCoinInfo();
    -- self.scroll_record=self.panel_jieguo.scroll_1;
    -- self.scroll_record:setFillEaseTime(0.2);
    self.table_record={};
    --//动作队列
    self.actionSequence={};
    -- self.panel_jieguo.panel_1:setVisible(false);
    self.panel_baoji:setVisible(false);
    --//Tga标记,用于执行自删除操作
    self.sequenceTag=11;
    self.isVisibleChanged=false;
    --//索引1位字体的描边颜色,[2]位字体的颜色
    self.explodeMapColor={  
           [2]={ [1]=cc.c4b(0x22,0x40,0x92,255), [2]=cc.c3b(0x23,0xcb,0xff ) , },
           [5]={[1]=cc.c4b(0x51,0x03,0x62,255),[2]=cc.c3b(0xf8,0x40,0xff ),},
           [10]={[1]=cc.c4b( 0x5f,0x2a,0x00,255),[2]=cc.c3b(0xff,0xdb,0x4c),},
        };
    -- self.panel_jieguo:setVisible(false);
end

function CompBuyCoinMainView:registerEvent()
    CompBuyCoinMainView.super.registerEvent(self);
    self:registClickClose("out");
    -- self.btn_close:setTap(c_func(self.clickButtonClose, self));
    -- self:registClickClose(-1, c_func( function()
    --         self:startHide()
    -- end , self))
    self.btn_close:setTap(c_func(self.startHide,self))
    EventControler:addEventListener(UserEvent.USEREVENT_GOLD_CHANGE,self.onEventRefresh,self);--//仙玉发生了变化
    EventControler:addEventListener(UserEvent.USEREVENT_TEQUAN_CHANGE,self.onEventRefresh,self);
end

function CompBuyCoinMainView:initView()
    -- //购买十次
    self.btn_buyten:setTap(c_func(self.clickButtonTenTimes , self));
    -- //购买一次
    self.btn_queding:setTap(c_func(self.clickButtonOneTime, self));
end

function CompBuyCoinMainView:clickButtonClose()
    self:startHide();
end

function  CompBuyCoinMainView:onEventRefresh()
   self.hasInit=false;
   self:updateCoinInfo();
end

--//购买铜钱唯一的入口
function CompBuyCoinMainView:updateCoinInfo()
   if(self.hasInit)then
         return;
   end
   self.hasInit=true;

    -- //购买次数,最大购买次数
    self.buyTimes = CountModel:getCoinBuyTimes();
    self.maxBuyTimes = CountModel:getMaxCoinBuyTimes();

    -- 剩余次数
    self.panel_1.txt_2:setString(self.buyTimes .. "/" .. self.maxBuyTimes .. " 次")
    self:addPrivilegeAddition( self.buyTimes+1 )

    -- 本次消耗
    self.txt_2:setString(self.diamondCost)
    -- 本次铜钱获得
    self.panel_2.txt_2:setString("" .. self.coinNum);

    -- 钻石不足
    if (self.diamondCost > UserModel:getGold()) then
         self.panel_2.txt_1:setColor(cc.c3b(255,0,0));
    else
         self.panel_2.txt_1:setColor(cc.c3b(0x8E,0x5F,0x35));
    end

    FuncCommUI.regesitShowBuyCoinTipView(self.panel_2.btn_1,params,false)
end

function CompBuyCoinMainView:addPrivilegeAddition( buyTimes,add )
    self.diamondCost, self.coinNum = FuncCommon.getCoinPriceByTimes(buyTimes,UserExtModel:buyCoinTimes());
    echo("______self.coinNum _",self.coinNum)
    -- 仙盟无极阁产量加成
    -- local isHas,value,subType = GuildModel:checkIsHaveAdditionByZone( FuncCommon.additionType.addition_buyCoin )
    local privilegeData = UserModel:privileges() 
    local additionType = FuncCommon.additionType.addition_buyCoin 
    local curTime = TimeControler:getServerTime()
    -- local fromSys = FuncCommon.additionFromType.GUILD
    local isHas,value,subType = FuncCommon.checkHasPrivilegeAddition( privilegeData,additionType,curTime,fromSys )
    -- echoError("isHas,value,subType == ",isHas,value,subType)
    -- echo("加成value====",value)
    if isHas then
        self.mc_yueka:showFrame(2)
        self.coinNum = self.coinNum + math.round(self.coinNum * value / 10000)
        -- echo("加成后self.coinNum=",self.coinNum)
    else
        self.mc_yueka:showFrame(1)
        local btn = self.mc_yueka.currentView.btn_1
        btn:setTap(function (  )
            WindowControler:showWindow("MonthCardMainView", FuncMonthCard.CARDYEQIAN[FuncMonthCard.card_caiyi])
        end)
    end
    -- echoError("______self.coinNumwwwwww _",self.coinNum,UserModel:getCoin())
    return self.diamondCost, self.coinNum
end

--[[
  获取加成值
]]
function CompBuyCoinMainView:getCoinPrivilegeAddition(coinNum)
    local privilegeData = UserModel:privileges() 
    local additionType = FuncCommon.additionType.addition_buyCoin 
    local curTime = TimeControler:getServerTime()
    -- local fromSys = FuncCommon.additionFromType.GUILD
    local isHas,value,subType = FuncCommon.checkHasPrivilegeAddition( privilegeData,additionType,curTime,fromSys )
    if isHas then
        coinNum = coinNum + math.floor(coinNum * value / 10000)
    end

    return coinNum
end

-- //购买一次
function CompBuyCoinMainView:clickButtonOneTime()
    self:buyCoinByRequest(1);
end
-- //十次
function CompBuyCoinMainView:clickButtonTenTimes()
    self:buyCoinByRequest(10);
end

-- //购买
function CompBuyCoinMainView:buyCoinByRequest(_times)
  -- //检测条件
  AudioModel:playSound(MusicConfig.s_com_click1)
  if (self.buyTimes >= self.maxBuyTimes) then
        -- //购买次数
      
      WindowControler:showTips(GameConfig.getLanguage("#tid_shenqi_001"));
      return;
  end
    -- //至少能购买一次
	if not UserModel:tryCost(FuncDataResource.RES_TYPE.DIAMOND, self.diamondCost, true) then
		return
	end
    self:requestBuyCoin(_times);
end

-- //联网
function CompBuyCoinMainView:requestBuyCoin(_times)
    local function _onPanelVisible()
          -- self.panel_jieguo:setVisible(true);
          self.ctn_ss:removeChildByTag(1);
    end
    local function _callback(_param)
      dump(_param.result,"购买铜钱",9)
        if (_param.result ~= nil) then
            -- //如果有暴击
            AudioModel:playSound(MusicConfig.s_com_buycopper);

            local msg = _param.result.data;
            local explode = 1;
            for _index = 1, #msg.hit do
                local  _record={};
                _record.explode=msg.hit[_index];
                _record.coin = msg.detailCoin[_index];
                _record.coin = self:getCoinPrivilegeAddition(_record.coin)
                _record.cost = self.totalTimes[_index];
                table.insert(self.actionSequence,_record);
            end
--//如果底层面板是隐藏的
            if(not self.isVisibleChanged) then --and not self.panel_jieguo:isVisible())then
                  -- local   _ani=self:createUIArmature("UI_buycoin","UI_buycoin_menghei",nil,false,_onPanelVisible);
                  -- self.ctn_ss:addChild(_ani,1,1);
                  -- _ani:pos(-214,-103);
                  self.isVisibleChanged=true;
            end
--//调度动作队列
            self:scheduleExplodeRecord();
            -- //更新购买次数
 --           self.buyTimes = self.buyTimes + table.length( msg.detailCoin);
            -- local content = GameConfig.getLanguage("tid_buy_times_1002");
            -- self.txt_1:setString(content:format(self.buyTimes, self.maxBuyTimes));
            -- self:addPrivilegeAddition( self.buyTimes+1 )

            -- 本次钻石消耗
            -- self.panel_2.txt_1:setString("" .. self.diamondCost);
            -- 本次获得铜钱
            -- self.panel_2.txt_2:setString("" .. self.coinNum);
            self:updateCoinInfo()

            self:delayCall(function ( ... )
                --发消息给任务
                echo("--DAILY_QUEST_CHANGE_EVENT--");
                EventControler:dispatchEvent(QuestEvent.DAILY_QUEST_CHANGE_EVENT, 
                    {questType = DailyQuestModel.Type.BuyCoin});
                EventControler:dispatchEvent("BuyCoin_success");
            end, 10/GameVars.GAMEFRAMERATE);
        else
            -- echo("--------CompBuyCoinMainView:requestBuyCoin---------", _param.error.code, _param.error.message);
            -- WindowControler:showTips(GameConfig.getLanguage("tid_buy_coin_failed_1005"));
            local error_code = _param.error.code 
            local tip = GameConfig.getErrorLanguage("#error"..error_code)
            WindowControler:showTips(tip)
        end
    end
    local param = { };
    self.totalCost=self.diamondCost;
    local     _totalTimes={};
    -- //如果是购买十次,需要判定是否能够满额购买,或者如果不能,需要计算出最大购买次数
    if (_times > 1) then
        local _count = 0;
        local _goldCount = UserModel:getGold();
        local _buyTimes = self.buyTimes + 1;
        local _gold = FuncCommon.getCoinCostByTimes( _buyTimes ) 
        local _costGold = _gold;
        _buyTimes = _buyTimes + 1;
        while (_costGold <= _goldCount and _count <= 10) do
            table.insert(_totalTimes,_costGold);
            _count = _count + 1;
            local _gold = FuncCommon.getCoinCostByTimes( _buyTimes )
            _costGold = _costGold + _gold;
            _buyTimes = _buyTimes + 1;
        end
        if (_count >= 10) then
            _count = 10;
        end
        if(_count+self.buyTimes>self.maxBuyTimes)then
             _count=self.maxBuyTimes-self.buyTimes;
        end
        _times=_count;
        if _count > 10 then
          _times = 10
        end
        
        self.totalCost=_costGold;
    else
           _totalTimes[1]=self.diamondCost;
    end
    self.totalTimes=_totalTimes;

    -- _times = 2
    param.times = _times;
    UserServer:buyCoin(param, _callback);
end

--//向队列中插入元素
function CompBuyCoinMainView:scheduleExplodeRecord()
--//如果正处于执行中,那么就直接返回
      if(self.isPerforming or #self.actionSequence<=0)then
            return;
      end
      self.isPerforming=true;
--//对第一个动作队列执行删除操作
      local    _record=self.actionSequence[1];
      table.remove(self.actionSequence,1);
      self:performExplodeAction(_record);
end

--//执行动作
function CompBuyCoinMainView:performExplodeAction(_record)
    local function genRecordFunc(_recordItem)
        -- local _viewItem = UIBaseDef:cloneOneView(self.panel_jieguo.panel_1);
        return _viewItem;
    end
    -- //暴击动画之后调用
    local function _afterExplodeAni()
        local scroll_param = {
            data = self.table_record,
            createFunc = genRecordFunc,
            perNums = 1,
            offsetX = 0,
            offsetY = 0,
            widthGap = 0,
            heightGap = 0,
            itemRect = { x = 0, y = -40.75, width = 412.75, height = 40.75 },
        };
    end
    --//自删除
   table.insert(self.table_record,_record);
   local     _removeTag=self.sequenceTag;
   local    function  _remove_self()
        self.ctn_ss:removeChildByTag(_removeTag);
        self.ctn_ss:removeChildByTag(_removeTag+1);
        self.ctn_ss:removeChildByTag(_removeTag+2);
   end
   local    function   _delayCallback()
        self.isPerforming=false;
        self:scheduleExplodeRecord();
   end

   --//如果是普通金钱获取
   if(_record.explode<=1)then
        -- self.coinNum  ---铜钱的数量
        local coinNum = _record.coin
        -- echo("coinNum===",coinNum)

        local arrnumber = FuncCommUI.byNumberGetNumberArr(tostring(coinNum))

        local _flutter_label = UIBaseDef:cloneOneView(self.panel_baoji);
        _flutter_label.mc_baoji:setVisible(false)
        _flutter_label.mc_1:showFrame(#arrnumber)
        for i=1,#arrnumber do
          _flutter_label.mc_1:getViewByFrame(#arrnumber)["mc_"..i]:showFrame(tonumber(arrnumber[i]+1))
        end


        AudioModel:playSound(MusicConfig.s_com_buycopper);

        local x = _flutter_label:getPositionX()
        local y = _flutter_label:getPositionY()
        -- echo("========================",x,y)
        _flutter_label:setPosition(cc.p(-130,0))
        local    _ani=self:createUIArmature("UI_buycoin","UI_buycoin_piaodong",nil,false,_remove_self);
        FuncArmature.changeBoneDisplay(_ani, "layer1", _flutter_label);

         self.ctn_ss:addChild(_ani,3,_removeTag);
         self.ctn_ss:runAction( cc.Sequence:create(cc.DelayTime:create(0.2) ,cc.CallFunc:create(_delayCallback)  )     );
         _afterExplodeAni();
   else
        local map = {[2]=1,[5]=2,[10]=3 };
        local aniMap = { [2] = "UI_buycoin_baodianlan", [5] = "UI_buycoin_baodianzi", [10] =  "UI_buycoin_baodianjin"};
        local aniMap2={[2]="UI_buycoin_baodian",[5]="UI_buycoin_zisebaoji",[10]="UI_buycoin_jinse",};

        local coinNum = _record.coin
        local arrnumber = FuncCommUI.byNumberGetNumberArr(tostring(coinNum))
        local _flutter_label = UIBaseDef:cloneOneView(self.panel_baoji);
        _flutter_label.mc_baoji:setVisible(true)
        _flutter_label.mc_1:showFrame(#arrnumber)
        for i=1,#arrnumber do
          _flutter_label.mc_1:getViewByFrame(#arrnumber)["mc_"..i]:showFrame(tonumber(arrnumber[i]+1))
        end

        local x = _flutter_label:getPositionX()
        local y = _flutter_label:getPositionY()
        -- echo("========================",x,y)
        _flutter_label:setPosition(cc.p(-130,0))
        local    _ani=self:createUIArmature("UI_buycoin","UI_buycoin_piaodong",nil,false,_remove_self);
        FuncArmature.changeBoneDisplay(_ani, "layer1", _flutter_label);

         self.ctn_ss:addChild(_ani,3,_removeTag);
         self.ctn_ss:runAction( cc.Sequence:create(cc.DelayTime:create(0.2) ,cc.CallFunc:create(_delayCallback)  )     );

          local ani = self:createUIArmature("UI_buycoin",aniMap[_record.explode], nil, false, GameVars.emptyFunc);
          ani:pos(-120,0);
          self.ctn_ss:addChild(ani, 1,_removeTag+1);

          ani = self:createUIArmature("UI_buycoin",aniMap2[_record.explode], nil, false, _remove_self);
          ani:pos(-200,-20);
          self.ctn_ss:addChild(ani, 2,_removeTag+2);
          _afterExplodeAni();
    end
    self.sequenceTag=self.sequenceTag+3;
end

return CompBuyCoinMainView;
