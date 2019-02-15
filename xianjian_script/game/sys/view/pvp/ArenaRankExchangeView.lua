--竞技场排名兑换
--2017-1-11 16:45:08
--@Author:xiaohuaxiong
local ArenaRankExchangeView = class("ArenaRankExchangeView",UIBase)

function ArenaRankExchangeView:ctor(_window_name)
    ArenaRankExchangeView.super.ctor(self,_window_name)
    self.greenColor = cc.c3b(0x00,0x8c,0x0d)
    self.redColor = cc.c3b(0xFF,0x0,0x0)
end

function ArenaRankExchangeView:loadUIComplete()
    self.rankExchangeDes = {
        [1] = GameConfig.getLanguage("#tid_pvp_des010"),
        [2] = GameConfig.getLanguage("#tid_pvp_des011"),
        [3] = GameConfig.getLanguage("#tid_pvp_des012"),
        [4] = GameConfig.getLanguage("#tid_pvp_des013"),
        [5] = GameConfig.getLanguage("#tid_pvp_des014"),
    }   
    self.selectedTag = PVPModel:getRankExchangesTag()
    self:registerEvent()
    self:initLeftTag()
    self:performStatic()
    self:updateRankView()
end

function ArenaRankExchangeView:registerEvent()
    ArenaRankExchangeView.super.registerEvent(self)
    --监听竞技场货币的变化
    EventControler:addEventListener(UserEvent.USEREVENT_PVP_COIN_CHANGE,self.notifyPvpCoinChangedEvent,self)
    EventControler:addEventListener(UserEvent.USEREVENT_PVP_COIN_CHANGE,self.updateLeftRedPoint,self)
    --监听竞技场排名奖励发生变化
    -- EventControler:addEventListener(PvpEvent.RANK_EXCHANGE_CHANGED_EVENT,self.notifyPvpRankExchangeEvent,self)
end


--竞技场货币变化通知
function ArenaRankExchangeView:notifyPvpCoinChangedEvent(_param)
    --刷新所有的组件
    self.scroll_1:refreshCellView(1)
end

--整合所有的数据
function ArenaRankExchangeView:performStatic()
    --所有的排名兑换奖励数据
    local _rank_data = FuncPvp.getRankExchangesByTag(self.selectedTag)
    local _now_rank_data = {}
    for _key,_value in pairs(_rank_data) do
        table.insert(_now_rank_data,_value)
    end
    local _now_ranks = PVPModel:getRankExchangesByTag(self.selectedTag) --已经获得的排名兑换数据
    -- dump(_rank_data, "\n\n_rank_data===")
    -- dump(_now_ranks, "\n\n_now_ranks===")
    local function _table_sort(a,b)
        --如果已经领取过了,排名靠下
        if _now_ranks[a.id] then
            if not _now_ranks[b.id]  then
                return false
            end
        else
            if _now_ranks[b.id] then
                return true
            end
        end
        return tonumber(a.id) < tonumber(b.id)
    end
    table.sort(_now_rank_data,_table_sort)
    self._rankData = _now_rank_data
end

function ArenaRankExchangeView:clickButtonClose()
    self:startHide()
end

--左侧页签
function ArenaRankExchangeView:initLeftTag()
    local tagData = {
        [1] = 1,
        [2] = 2,
        [3] = 3,
        [4] = 4,
        [5] = 5,
    }

    self.mc_yeqian:setVisible(false)
    local createFunc = function (item, index)
        local view = UIBaseDef:cloneOneView(self.mc_yeqian)
        self:updateTagView(view, item, index)
        return view
    end

    local _param = {
        data = tagData,
        createFunc = createFunc,
        offsetX = 6,
        offsetY = 35,
        perNums = 1,
        widthGap = 0,
        heightGap = -5,
        perFrame = 1,
        itemRect = {x = 0, y = -98, width = 223, height = 67},
    }
    self.scroll_2:styleFill({_param})
    self.scroll_2:setCanScroll(false)
end

--左侧页签创建函数
function ArenaRankExchangeView:updateTagView(_view, _item, _index)
    if _index == self.selectedTag then
        _view:showFrame(2)
    else
        _view:showFrame(1)
        local showRed = PVPModel:isRankRedPointShow(_index)
        _view.currentView.panel_red:setVisible(showRed)
    end

    local txt =  self.rankExchangeDes[_item]
    _view.currentView.btn_1:getUpPanel().txt_1:setString(txt)
    _view.currentView.btn_1:getDownPanel().txt_1:setString(txt)
    _view.index = _index
    _view.currentView.btn_1:setTouchedFunc(c_func(self.updateSelectedTag, self, _view))
end

--更新选中页签 并更新数据
function ArenaRankExchangeView:updateSelectedTag(_view)
    local curTag = self.selectedTag
    if curTag == _view.index then
        return 
    end
    local view = self.scroll_2:getViewByData(curTag)
    view:showFrame(1)
    --这里重新注册点击事件是因为view是mc  处于不同的frame导致 否则会导致在某一frame下无点击事件的情况
    view.currentView.btn_1:setTouchedFunc(c_func(self.updateSelectedTag, self, view))
    local txt =  self.rankExchangeDes[curTag]
    view.currentView.btn_1:getUpPanel().txt_1:setString(txt)
    view.currentView.btn_1:getDownPanel().txt_1:setString(txt)
    self.selectedTag = _view.index
    local view1 = self.scroll_2:getViewByData(self.selectedTag)
    view1:showFrame(2)
    view1.currentView.btn_1:setTouchedFunc(c_func(self.updateSelectedTag, self, view1))
    local txt1 =  self.rankExchangeDes[self.selectedTag]
    view1.currentView.btn_1:getUpPanel().txt_1:setString(txt1)
    view1.currentView.btn_1:getDownPanel().txt_1:setString(txt1)
    PVPModel:setRankExchangesTag(self.selectedTag)
    self:updateLeftRedPoint()
    self:performStatic()
    self:updateRankView()
end

function ArenaRankExchangeView:updateLeftRedPoint()
    local allView = self.scroll_2:getAllView()
    for i,v in ipairs(allView) do
        local index = v.index
        local showRed = PVPModel:isRankRedPointShow(index)
        if v.currentView.panel_red then
            v.currentView.panel_red:setVisible(showRed)
        end
    end
end

--更新所有的组件
function ArenaRankExchangeView:updateRankView()
    self.panel_1:setVisible(false)
    local __private_id_nums = 1
    --create function
    local function createFunc(_item,_index)
        local _view = UIBaseDef:cloneOneView(self.panel_1)
        _view.__private_id = __private_id_nums
        self:updateEveryRankItem(_view,_item)
        return _view
    end
    --
    local function updateCellFunc(_item,_view,_index)
        self:updateEveryRankItem(_view,_item)
    end

    local _param = {
        data = self._rankData,
        createFunc = createFunc,
        updateCellFunc = updateCellFunc,
        offsetX =0,
        offsetY = 5,
        perNums = 1,
        widthGap = 0,
        heightGap = -20,
        perFrame = 1,
        itemRect = {x=0,y=-141.4,width = 842,height = 141.4},
    }
    self.scroll_1:styleFill({_param})
    self.scroll_1:gotoTargetPos(1, 1, 0)
end
--param:_play_stamp是否播放盖章动画
function ArenaRankExchangeView:updateEveryRankItem(_view,_item,_play_stamp)
    --设置道具的图标
    _view.UI_1:setResItemData({reward=_item.reward[1]}) 
    local _reward =string.split( _item.reward[1],",")
    -- local _item_item = FuncItem.getItemData(_reward[2])

    local des = nil;
    local name = nil;
    local quality = nil;
    local itemId = nil;
    local itemType = nil;
    local itemNum = nil;

    if #_reward == 2 then 
        itemId = _reward[1];
        itemType = _reward[1];
        itemNum = _reward[2];
    else 
        itemId = _reward[2];
        itemType = _reward[1];
        itemNum = _reward[3];

    end 


    quality = FuncDataResource.getQualityById(itemType, itemId);
    name = FuncDataResource.getResNameById(itemType, itemId);
    des = FuncDataResource.getResDescrib(itemType, itemId);

    --展示道具详情需要的参数
    local _param = {
        itemResType = itemType,
        itemId = itemId,
        viewType = FuncItem.ITEM_VIEW_TYPE.ONLYDETAIL,
        itemNum = tonumber(itemNum),
        desStr = des,
    }


    _view.UI_1:setResItemClickEnable(true)
    _view.UI_1:setClickBtnCallback(c_func(self.onTouchItemDetail, self,_param))
    --道具的品质
    _view.mc_zi:showFrame(quality)
    --道具的名字
    _view.mc_zi.currentView.txt_1:setString(name)
    --兑换这个奖励需要达到的兑换条件
    _view.txt_2:setString(tostring(_item.condition))
    --当前是否已经领取了
    local _now_ranks = PVPModel:getAllRankExchanges() --已经获得的排名兑换数据
    --当前是否已经达到
    if _now_ranks[_item.id] then --同时检测是否需要播放动画
        _view.mc_1:showFrame(2)
        _view.txt_2:setColor(self.greenColor)
        if _play_stamp then
           -- _view.mc_1:setVisible(false)
           _view.mc_1.currentView.panel_lingqu:setVisible(false)
            local _panel = UIBaseDef:cloneOneView(_view.mc_1.currentView.panel_lingqu)
            self:playStamp(_panel:getChildren()[1],_view.mc_1.currentView.ctn_1,_view.mc_1)
        end
        return
    end

    --兑换时需要花费的资源
    local _user_money = UserModel:getArenaCoin()
    local _cost_data = string.split(_item.cost[1],",")

    local _rank = PVPModel:getHistoryTopRank()
    _view.mc_1:showFrame(1) 
    local _panel = _view.mc_1.currentView   
    if _rank <= _item.condition then --如果已经达到条件
        _view.txt_2:setColor(self.greenColor)
        local _ani_ctn = _panel.btn_1:getUpPanel().ctn_1
        _ani_ctn:removeAllChildren()
        local ani = self:createUIArmature("UI_common","UI_common_saoguang", _ani_ctn, true)
        _view.anim = ani
        ani:pos(-2, 2)
        ani:setScaleX(0.6)
        ani:setScaleY(0.55)
        
        if _user_money >= tonumber(_cost_data[2]) then
            FilterTools.clearFilter(_panel.btn_1)
            ani:setVisible(true)
        else
            FilterTools.setGrayFilter(_panel.btn_1)
            ani:setVisible(false)
        end        
        _panel.btn_1:setTap(c_func(self.clickButtonExchange,self,_item))
        --加入扫光动画        
    else
        _view.txt_2:setColor(self.redColor)
        FilterTools.setGrayFilter(_panel.btn_1)
        local _ani_ctn = _view.mc_1.currentView.btn_1:getUpPanel().ctn_1
        _ani_ctn:removeAllChildren()
        _panel.btn_1:setTap(c_func(self.clickButtonRankCondition,self))
    end

    if _user_money < tonumber(_cost_data[2]) then--竞技场货币不足
        _panel.panel_xian.mc_1:showFrame(2)
    else
        _panel.panel_xian.mc_1:showFrame(1)
    end
    _panel.panel_xian.mc_1.currentView.txt_1:setString(_cost_data[2])

end
--播放动画
--sprite:将要被替换的组件
--ctn:装载动画的容器
--otherView:动画播放完毕之后将要显示的组件
function ArenaRankExchangeView:playStamp(sprite,ctn,otherView)
    local function delayAfterStamp()
        otherView:setVisible(true)
    end
    sprite:setPosition(cc.p(0,0))
    sprite:setAnchorPoint(cc.p(0.5,0.5))
    local _anim = self:createUIArmature("UI_common","UI_common_shouqing", nil, false, delayAfterStamp);
    FuncArmature.changeBoneDisplay(_anim, "layer1", sprite)
    _anim:pos(0,0);
    ctn:addChild(_anim)
end
--只更新与竞技场货币的显示相关的组件
function ArenaRankExchangeView:updatePvpCoinOnly(_view,_item)
    --当前是否已经领取了
    local _now_ranks = PVPModel:getAllRankExchanges() --已经获得的排名兑换数据
    --当前是否已经达到,如果达到了,就直接返回,无需再更新了
    local _panel = _view.mc_1.currentView
    local _rank = PVPModel:getHistoryTopRank()
    if _now_ranks[_item.id] then
        return
    else 
        --兑换时需要花费的资源
        local _user_money = UserModel:getArenaCoin()
        local _cost_data = string.split(_item.cost[1],",")
        if _user_money < tonumber(_cost_data[2]) then--竞技场货币不足
            _panel.panel_xian.mc_1:showFrame(2)          
            _panel.btn_1:getUpPanel().ctn_1:visible(false)
            FilterTools.setGrayFilter(_panel.btn_1)
            if _view.anim then
                _view.anim:setVisible(false)
            end              
        else
            -- FilterTools.clearFilter(_panel.btn_1)
            if _rank <= _item.condition then
                FilterTools.clearFilter(_panel.btn_1)
                _panel.panel_xian.mc_1:showFrame(1)
                if _view.anim then
                    _view.anim:setVisible(true)
                else
                    local _ani_ctn = _panel.btn_1:getUpPanel().ctn_1
                    _ani_ctn:removeAllChildren()
                    local ani = self:createUIArmature("UI_common","UI_common_saoguang", _ani_ctn, true)
                    _view.anim = ani
                    ani:pos(-2, 2)
                    ani:setScaleX(0.6)
                    ani:setScaleY(0.55)
                    _view.anim:setVisible(true)
                end
            end
        end
        _panel.panel_xian.mc_1.currentView.txt_1:setString(_cost_data[2])
    end   
    
end
--排名条件不足
function ArenaRankExchangeView:clickButtonRankCondition()
    WindowControler:showTips(GameConfig.getLanguage("pvp_rank_condition_not_satisfy_1002"))
end
--点击兑换
function ArenaRankExchangeView:clickButtonExchange(_item)
    local _user_money = UserModel:getArenaCoin()
    local _cost_data = string.split(_item.cost[1],",")
    if _user_money < tonumber(_cost_data[2]) then
        WindowControler:showTips(GameConfig.getLanguage("pvp_coin_not_enough_1001"))
        return
    end
    PVPServer:requestRankExchange(_item.id, c_func(self.onExchangeEvent, self, _item.id))
end

function ArenaRankExchangeView:onExchangeEvent(_itemId, _event)
    if not _event.result then
        return 
    end

    local itemData = self:getCurrentItemData(_itemId)
    if self.scroll_1:getViewByData(itemData) then
        local currentView = self.scroll_1:getViewByData(itemData)
        self:updateEveryRankItem(currentView, itemData, true)
    end

    --同时遍历所有的奖励
    local _rank_item = FuncPvp.getRankExchange(_itemId)
    FuncCommUI.startRewardView(_rank_item["reward"]);
end

function ArenaRankExchangeView:getCurrentItemData(_itemId)
    for i,v in ipairs(self._rankData) do
        if v.id == _itemId then
            return v
        end
    end
end

--展示道具详情
function ArenaRankExchangeView:onTouchItemDetail(_param)
    WindowControler:showWindow("CompGoodItemView",_param)
end
return  ArenaRankExchangeView