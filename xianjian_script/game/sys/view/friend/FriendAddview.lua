
local FriendAddview = class("FriendAddview", UIBase);

function FriendAddview:ctor(_winName)
    FriendAddview.super.ctor(self, _winName);
end
function FriendAddview:loadUIComplete()
	
    local panel = self.panel_2;
    panel:setVisible(true);
    self.nowFriendApplyPage = 1
    self.panel_2.btn_1:setVisible(false)
    self.panel_2.btn_2:setVisible(false)
    self.panel_2.panel_1:setVisible(false)
    self.friendMap={};
    self.friendMap.count=FriendModel:getFriendCount();
    self:registerEvent()
    self.UI_1.btn_1:setTap(c_func(self.clickButtonClose,self));
    self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_friend_001")) 
    -- local function _callback(_param) 
    -- if (_param.result ~= nil) then
    --     FriendModel:updateFriendApply(_param.result.data);
    --     self:setFriendApplyMap(_param.result.data);
    -- else
    --     echo("----FriendMainView:freshFriendApplyCommon--", _param.error.code, _param.error.message);
    -- end
    -- local param = { };
    -- param.page = 1;
    -- FriendServer:getFriendApplyList(param, _callback);
end

function FriendAddview:registerEvent()
	FriendAddview.super.registerEvent(self);
	-- self:registClickClose(1, c_func( function()
 --            self:startHide()
 --    end , self))
	
	-- self:delayCall(function ()
        self.panel_fanye:setVisible(false); 
		self:sendServerdata()
	-- end,1)

	-- local function _callback(_param)
 --    if (_param.result ~= nil) then
 --        FriendModel:updateFriendApply(_param.result.data);
 --        self:setFriendApplyMap(_param.result.data);
 --    else
 --        echo("----FriendMainView:freshFriendApplyCommon--", _param.error.code, _param.error.message);
 --    end
 --    local param = { };
 --    param.page = 1;
 --    FriendServer:getFriendApplyList(param, _callback);
end
function FriendAddview:sendServerdata()
	local function _callback(_param)
		-- dump(_param.result.data,"获取好友申请列表") 
        if (_param.result ~= nil) then
            FriendModel:updateFriendApply(_param.result.data);
            self:setFriendApplyMap(_param.result.data);
        else
            echo("----FriendMainView:freshFriendApplyCommon--", _param.error.code, _param.error.message);
        end
    end
    local param = { };
    param.page = 1;
    FriendServer:getFriendApplyList(param, _callback);
end
function FriendAddview:setFriendApplyMap(data)
    -- dump(data,"11111111111111")
    self.newdata = {}
    if self.nowFriendApplyPage == 1 then
        self.friendApplyMap = data
        local index = 1
        for k,v in pairs(data.applyList) do
            self.newdata[index] = v
            index = index + 1
        end
        self.friendApplyMap.applyList = {}
        self.friendApplyMap.applyList = self.newdata
    else
        local count = #self.friendApplyMap.applyList
        local index = 1
        for k,v in pairs(data.applyList) do
            self.friendApplyMap.applyList[count + index] = v
            index = index　+１
        end
    end


	self:setFriendApplyList()
end

function FriendAddview:setFriendApplyList()
  
    -- //好友列表页面是否显示红点
    
   	
    local panel = self.panel_2;
    panel:setVisible(true);

    local _maxCountPerPage = FriendModel:getCountPerPage();
    local _maxPage = math.floor(self.friendApplyMap.count / _maxCountPerPage);
    echo("========_maxPage========self.friendApplyMap.count===========_maxCountPerPage====",_maxPage,self.friendApplyMap.count,_maxCountPerPage)
    if (self.friendApplyMap.count % _maxCountPerPage > 0) then
        _maxPage = _maxPage + 1;
    end
    self.totalFriendApplyPage = _maxPage;
    -- if (self.nowFriendApplyPage < 0) then
    --     -- //修正当前页面显示,防止好友动态更新引起的bug
    --     self.nowFriendApplyPage = 0;
    -- elseif (self.nowFriendApplyPage > _maxPage) then
    --     self.nowFriendApplyPage = _maxPage;
    -- end

    -- self.panel_fanye:setVisible(_maxPage>1);
    -- self.panel_fanye.panel_3.txt_1:setString("" .. self.nowFriendApplyPage .. "/" .. _maxPage);
--    self.panel_fanye.btn_3:enabled(self.nowFriendApplyPage > 1);
 --   self.panel_fanye.btn_4:enabled(self.nowFriendApplyPage < _maxPage);
    -- self.panel_fanye.btn_3:setTap(c_func(self.clickButtonPrevPage, self));
    -- //向左翻页
    -- self.panel_fanye.btn_4:setTap(c_func(self.clickButtonNextPage, self));




    local _cells={}
    local function genCellItem(_item)
        local _cell = UIBaseDef:cloneOneView(panel.panel_1);
        self:setFriendApplyCellItem(_cell, _item);
        return _cell;
    end
    local _scrollParam = {
        data = self.friendApplyMap.applyList,
        createFunc = genCellItem,
        perNums = 1,
        offsetX = 35,
        offsetY = 3,
        widthGap = 0,
        heightGap=2,
        itemRect = { x = 0, y = - 133, width = 758, height = 133 },
        perFrame = 1,
    };
    self.scroll_list3:scrollTo(0, 0)
    self.scroll_list3:setFillEaseTime(0.3);
    self.scroll_list3:setItemAppearType(1, true);
    self.scroll_list3:styleFill( { _scrollParam });
    self.scroll_list3:hideDragBar()
    self.scroll_list3:onScroll(c_func(self.onMyListScroll, self))
 --    if(self.lastFriendApplyPage ~= self.nowFriendApplyPage)then
 -- --         self.scroll_list3:gotoTargetPos(self.nowFriendApplySelectedIndex, 1);
 --          self.scroll_list3:gotoTargetPos(1, 1);
 --          self.lastFriendApplyPage=self.nowFriendApplyPage;
 --    end
    -- //如果没有好友申请



    if (self.friendApplyMap.count <= 0) then
        FilterTools.setGrayFilter(panel.btn_1);
        FilterTools.setGrayFilter(panel.btn_2);
        panel.btn_2:setVisible(false)
        panel.btn_1:setVisible(false)
        self:clickButtonClose()
    else
        FilterTools.clearFilter(panel.btn_1);
        FilterTools.clearFilter(panel.btn_2);
    end
    panel.btn_1:setVisible(true)--self.friendApplyMap.count > 0);
    -- //全部拒绝
    panel.btn_2:setVisible(true)--self.friendApplyMap.count > 0);
    -- //全部同意
    -- //注册回调函数
    panel.btn_1:setTap(c_func(self.clickButtonRejectAllAppply, self));
    panel.btn_2:setTap(c_func(self.clickButtonApproveAllApply, self));
end

function FriendAddview:onMyListScroll(event)
    -- dump(event,"232312323232")
    if event.name == "scrollEnd" then
        -- echo("111111111111111111111111111111111111111111111'")
        local groupIndex,posIndex =  self.scroll_list3:getGroupPos(1)
        -- echo("=======groupIndex========posIndex=========",groupIndex,posIndex)
        if groupIndex == 2 then 
            if posIndex >= #self.friendMap.friendList - 3 then
                -- self.ButtonNextPageparm = 0
                self:clickButtonNextPage()
            end
        end
        -- self.scroll_list:gotoTargetPos(2,#self.friendMap.friendList - 4);
    end
end
function FriendAddview:clickButtonPrevPage()
    local function _callback2(_param)
            if (_param.result ~= nil) then
                self.nowFriendApplyPage = self.nowFriendApplyPage - 1;
                self:setFriendApplyMap(_param.result.data);
            else
                echo("---get friend apply list by page error----", _param.error.code, _param.error.message);
            end
        end
    if (self.nowFriendApplyPage > 1) then
        local param2 = { };
        param2.page = self.nowFriendApplyPage - 1;
        FriendServer:getFriendApplyList(param2, _callback2);
    end
end
function FriendAddview:clickButtonNextPage()
    -- //管理好友申请的页面
        local function _callback(_param)
            if (_param.result ~= nil) then
                self.nowFriendApplyPage = self.nowFriendApplyPage + 1;
                self:setFriendApplyMap(_param.result.data);
            else
                echo("---get friend apply list by page error----", _param.error.code, _param.error.message);
            end
        end
        if (self.nowFriendApplyPage < self.totalFriendApplyPage) then
            local param = { };
            param.page = self.nowFriendApplyPage + 1;
            FriendServer:getFriendApplyList(param, _callback);
        end
end
-- //全部拒绝好友申请
function FriendAddview:clickButtonRejectAllAppply()
    -- //首先判断是否有好友申请
    if (self.friendApplyMap.count <= 0) then
        WindowControler:showTips(GameConfig.getLanguage("tid_friend_no_friend_apply_1031"));
        return;
    end
    local function _callback(_param)
        if (_param.result ~= nil) then
            WindowControler:showTips(GameConfig.getLanguage("tid_friend_reject_apply_1029"));
            self.friendApplyMap.applyList = { };
            self.friendApplyMap.count = 0;
            FriendModel:updateFriendApply(self.friendApplyMap);
            -- self:setFriendApplyList();
            EventControler:dispatchEvent(FriendEvent.FRIEND_ADD_FRIEND_BUTTON_ACTION,nil)--self.friendApplyMapcount)
            self:freshFriendApplyCommon()
            FriendModel:setfriendApplyCount(1)
            
            -- self:startHide()       
        else
            echo("--FriendMainView:clickButtonRejectAllAppply--", _param.error.code, _param.error.message);
        end
    end
    local param = { };
    param.isAll = 1;
    FriendServer:rejectFriend(param, _callback);
end
-- //全部同意好友申请
function FriendAddview:clickButtonApproveAllApply()
    if (self.friendApplyMap.count <= 0) then
        WindowControler:showTips(GameConfig.getLanguage("tid_friend_no_friend_apply_1031"));
        return;
    end
--//是否好友数目已经满了
    local  _max_friend_count=FuncDataSetting.getDataByConstantName("FriendLimit");
    local  _friend_count=FriendModel:getFriendCount();
    if(_friend_count>=_max_friend_count)then
         WindowControler:showTips(GameConfig.getLanguage("tid_friend_self_friend_count_reach_limit_1046"));
         return;
    end
    local function _callback(_param)
        if (_param.result ~= nil) then
            self.friendMap.count = self.friendMap.count + _param.result.data.count;
            -- //好友的数目增加
            FriendModel:setFriendCount(self.friendMap.count);
            -- //刷新缓存
            WindowControler:showTips(GameConfig.getLanguage("tid_friend_approve_all_apply_1032"):format(_param.result.data.count));
            self.nowFriendApplyPage = 1;
            EventControler:dispatchEvent(FriendEvent.FRIEND_ADD_FRIEND_BUTTON_ACTION,nil)--self.friendApplyMapcount)
            self:freshFriendApplyCommon();
            -- self:startHide()
            -- self:clickButtonClose()  
            -- self.friendApplyMap.applyList
            FriendModel:setfriendApplyCount(1)
            self:sendaddfriend(self.friendApplyMap.applyList)

        else
            WindowControler:showTips(GameConfig.getLanguage("tid_friend_can_not_add_friend_1033"));
            echo("--clickButtonApproveAllApply--", _param.error.code, _param.error.message);
        end
    end
    local param = { };
    param.isAll = 1;
    FriendServer:approveFriend(param, _callback);
end
function FriendAddview:setFriendApplyCellItem(_cell,_item)
-- dump(_item,"111111111111111")
	--好友图标
    local _icon = FuncChar.icon(tostring(_item.avatar));
    local _node = _cell.panel_1.ctn_1;
    _node:removeAllChildren();
 --    local _sprite = display.newSprite(_icon);
	-- local iconAnim = self:createUIArmature("UI_common", "UI_common_iconMask", _node, false, GameVars.emptyFunc)
	-- -- iconAnim:setScale(1.3)
	-- FuncArmature.changeBoneDisplay(iconAnim, "node", _sprite)
    ChatModel:setPlayerIcon(_node,_item.head,_item.avatar ,0.9)

    local _name=_item.name;-- //名字
    if(_name==nil or _name=="")then
            _name=GameConfig.getLanguage("tid_common_2006");     
    end
    _cell.txt_1:setString(_name);
    -- SetVIPPosition(_cell.txt_1,_cell.mc_1,_name);
    _cell.txt_red:setString(0);
    _cell.panel_1.txt_1:setString(_item.level);
    -- //等级
    local sumtotal = 0
    if _item.abilityNew ~= nil then
        if _item.abilityNew.formationTotal ~= nil then
            sumtotal = _item.abilityNew.formationTotal
        end
    end
    -- data.abilityNew.formationTotal 
    _cell.txt_5:setString(GameConfig.getLanguage("#tid_friend_002") ..sumtotal);
    -- //战力
    -- local playermingcheng = "大神"  ---玩家称号说
    -- _cell.txt_god:setString("["..playermingcheng.."]")
    local Guildname = GameConfig.getLanguage("#tid_friend_003")  ---公会仙盟
    _cell.txt_2:setString(Guildname) 
    -- _cell.ctn_xian

    -- //注册按钮回调
     -- //拒绝好友申请
    _cell.btn_1:setTap(c_func(self.clickCellButtonRejectApply, self, _item));
   -- //同意好友申请
    _cell.btn_2:setTap(c_func(self.clickCellButtonApproveApply, self, _item));
	--//注册查看玩家详情
   -- _cell.panel_1:setTouchedFunc(c_func(self.clickCellButtonQueryPlayer,self,_item),nil,true,c_func(self.onCellBeganEvent,self,_item),c_func(self.onCellMovedEvent,self,_item));

end
function FriendAddview:clickCellButtonRejectApply(_item)
    local function _callback(_param)
        if (_param.result ~= nil) then
            WindowControler:showTips(GameConfig.getLanguage("tid_friend_reject_apply_1029"));
            -- //弹出提示,已经拒绝好友
            -- //播放组件被移除动画
 --           local _moveAction = cc.MoveBy:create(0.3, cc.p(-500, 0));
--            local _cell = self.scroll_list3:getViewByData(_item);
            -- self.friendApplyChild[_item.index];
 --           _cell:runAction(_moveAction);
            -- //移除相关数据与组件
            self.scroll_list3:clearOneView(_item);
            table.remove(self.friendApplyMap.applyList, _item.index);
            self.friendApplyMap.count = self.friendApplyMap.count - 1;
            self.nowFriendApplySelectedIndex=_item.index;
            -- if (self.nowFriendApplyPage >= self.totalFriendApplyPage) then
            --     -- //如果是最后一页
            --     if (self.friendApplyMap.count > 0) then
            --         -- //如果最后一页的数组现在不为0,则不需要联网刷新
            --         FriendModel:updateFriendApply(self.friendApplyMap);
            --         -- //分发好友申请通知
            --         self:onFriendApplyChanged(_item, _cell);
            --     else
            --         -- //否则现在需要联网
            --         self.nowFriendApplyPage = self.nowFriendApplyPage - 1;
            --         if (self.nowFriendApplyPage <= 0) then
            --             self.nowFriendApplyPage = 1;
            --         end
            --         self:freshFriendApplyCommon();
            --     end
            -- else
            --     self:freshFriendApplyCommon();
            -- end
            EventControler:dispatchEvent(FriendEvent.FRIEND_ADD_FRIEND_BUTTON_ACTION,nil)--self.friendApplyMapcount)
            self:freshFriendApplyCommon()
            FriendModel:setfriendApplyCount()
            -- self:startHide()
        else
           if (_param.error.message == "friend_exists" or _param.error.message=="friend_apply_not_exists") then
                WindowControler:showTips(GameConfig.getLanguage("tid_friend_already_exist_1036"));
           else
            -- //如果拒绝了好友申请,逻辑上是不会出现错误码的
                 echo("---FriendMainView:clickCellButtonRejectApply-----", _param.error.code, _param.error.message);
            end 
        end
    end
    local param = { };
    param.fuid = _item.uid;
    param.isAll = 0;
    FriendServer:rejectFriend(param, _callback);
end
-- //同意好友申请
function FriendAddview:clickCellButtonApproveApply(_item)
--//是否好友数目已经满了
    local  _max_friend_count=FuncDataSetting.getDataByConstantName("FriendLimit");
    local  _friend_count=FriendModel:getFriendCount();
    if(_friend_count>=_max_friend_count)then
         WindowControler:showTips(GameConfig.getLanguage("tid_friend_self_friend_count_reach_limit_1046"));
         return;
    end
    local function _callback(_param)
        if (_param.result ~= nil) then
            if(_param.result.data.count<=0)then--//没能添加一个好友
                WindowControler:showTips(GameConfig.getLanguage("tid_friend_friend_count_limit_1030"));
                return;
            end
            -- //添加好友
            WindowControler:showTips(GameConfig.getLanguage("tid_friend_approve_apply_1031"));
 --           local _cell = self.scroll_list3:getViewByData(_item);
            -- self.friendApplyChild[_item.index];
            -- //移除相关的数据
            table.remove(self.friendApplyMap.applyList, _item.index);
            self.friendApplyMap.count = self.friendApplyMap.count - 1;
            self.friendMap.count = self.friendMap.count + 1;
--//刷新UI按钮
            -- //好友的数目+1
            FriendModel:setFriendCount(self.friendMap.count);
            -- //同时刷新缓存
--            local _moveAction = cc.MoveBy:create(0.3, cc.p(-500, 0));
--            _cell:runAction(_moveAction);
            self.scroll_list3:clearOneView(_item);
            self.nowFriendApplySelectedIndex=_item.index;
            FriendModel:setfriendApplyCount()
            -- if (self.nowFriendApplyPage >= self.totalFriendApplyPage) then
            --     -- //如果当前是最后一页
            --     if (self.friendApplyMap.count > 0) then
            --         -- //并且该页中还有组件
            --         FriendModel:updateFriendApply(self.friendApplyMap);
            --         self:onFriendApplyChanged(_item, _cell);
            --     else
            --         self.nowFriendApplyPage = self.nowFriendApplyPage - 1;
            --         if (self.nowFriendApplyPage <= 0) then
            --             self.nowFriendApplyPage = 1;
            --         end
            --         self:freshFriendApplyCommon();
            --     end
            -- else
                EventControler:dispatchEvent(FriendEvent.FRIEND_ADD_FRIEND_BUTTON_ACTION,nil)--self.friendApplyMapcount)
                self:freshFriendApplyCommon();

                self:sendaddfriend({_item})
                
            -- end
        else
            if (_param.error.message == "friend_count_limit") then
                -- //好友已经达到上限
                WindowControler:showTips(GameConfig.getLanguage("tid_friend_friend_count_limit_1030"));
             elseif (_param.error.message == "friend_exists" or _param.error.message=="friend_apply_not_exists") then
                WindowControler:showTips(GameConfig.getLanguage("tid_friend_already_exist_1036"));
            end
        end
    end
    -- dump(_item,"01000000000000000000000")
    local param = { };
    param.fuid = _item.uid;
    param.isAll = 0;
    FriendServer:approveFriend(param, _callback);
end
function FriendAddview:sendaddfriend(ridtable)
    -- dump(ridtable,"111111111111111111111111111")
    for i=1,#ridtable do

        ridtable[i].rid = ridtable[i]._id
        ChatModel:insertOnePrivateObject(ridtable[i])
        local _item = {
            avatar  = ridtable[i].avatar or UserModel:avatar(),
            content = FuncChat.CHAT_STRING.friend,
            level   = ridtable[i].level,--UserModel:level(),
            name    = ridtable[i].name,--UserModel:name(),
            rid    = ridtable[i].rid, --UserModel:rid(),
            time    = TimeControler:getServerTime(),
            type    = 1,
            vip     = ridtable[i].vip or UserModel:vip(),
            uid = ridtable[i].uid,
        }
        FriendModel:insertFriendData(ridtable[i])
        -- ChatModel:updatePrivateMessage(_item)
    end
end
function FriendAddview:freshFriendApplyCommon()
    local function _callback(_param)
        if (_param.result ~= nil) then
            FriendModel:updateFriendApply(_param.result.data);
            self:setFriendApplyMap(_param.result.data);
        else
            echo("----FriendMainView:freshFriendApplyCommon--", _param.error.code, _param.error.message);
        end
    end
    local param = { };
    param.page = 1;
    FriendServer:getFriendApplyList(param, _callback);
end
--//发送好友详情查询
function FriendAddview:clickCellButtonQueryPlayer(_item)
--   local  _a=self.scroll_list:isMoving()
--   local   _b=self.scroll_list2:isMoving()
--   local   _c=self.scroll_list3:isMoving()
--   if(_a or _b or _c)then
--          return;
--   end
-- dump(_item,"'11111111111111")
    if(_item.ignore_event) then
           return;
    end
    -- local    function    _afterApplyCall()
    --       local  _view=self.scroll_list2:getViewByData(_item);--//好友添加
    --       if(_view ~=nil )then
    --       local    _other_item=_item
    --            _other_item.applyed=true;
    --            local _cell = self.scroll_list2:getViewByData(self.friendAddingMap[_item.index]);
    --            local  sprite=UIBaseDef:cloneOneView(_cell.panel_yishenqing):getChildren()[1];
    --            _cell.btn_1:setVisible(false);
    --            PlayStampAnimation(self,sprite,_cell.ctn_donghua1,_cell.ctn_donghua1,_cell.panel_yishenqing);
    --            -- self:checkGrayOneKeyApply();
    --       end
    -- end
    -- local     function   callback(param)
    --     dump(param.result,"被申请列表")
    --           if(param.result~=nil)then -param.result.data.data[1]
    local   _player_ui=WindowControler:showWindow("CompPlayerDetailView",_item,self,2);--//从好友系统中进入
                   -- _player_ui:setAfterApplyCallback(_afterApplyCall,self);
    --           end
    -- end
    -- local   param={};
    -- param.rids={};
    -- param.rids[1]=_item._id;
    -- ChatServer:queryPlayerInfo(param,callback);
end
function    PlayStampAnimation(_self,sprite,ctn,oneView,otherView)
  local function   afterStampPlay()
       oneView:setVisible(false);
--       oneView:removeChildByTag(0x80);
       otherView:setVisible(true);  
  end

    sprite:setPosition(cc.p(0,0));
    sprite:setAnchorPoint(cc.p(0.5,0.5));
    local anim = _self:createUIArmature("UI_common","UI_common_shouqing", nil, false, afterStampPlay);
    FuncArmature.changeBoneDisplay(anim, "layer1", sprite)
    anim:pos(0,0);
    ctn:addChild(anim,1)--,0x80);
end
function   FriendAddview:onCellBeganEvent(_item,_event)
      echo("-----------maomao---------------");
      local    _other_item=_item;
      local    _other_point=self:convertToNodeSpace(cc.p(_event.x,_event.y))
      _other_item.offsetX=_other_point.x;
      _other_item.offsetY=_other_point.y;
      _other_item.ignore_event=false;
end

function  FriendAddview:onCellMovedEvent(_item,_event)
   
     local    _other_point=self:convertToNodeSpace(cc.p(_event.x,_event.y))
     local    _deltax = _other_point.x - (_item.offsetX or _other_point.x);
     local    _deltay = _other_point.y - (_item.offsetY or _other_point.y);

     local    _other_item = _item;
     _other_item.ignore_event = _other_item.ignore_event or _deltax * _deltax + _deltay * _deltay >25 ;
end
function FriendAddview:clickButtonClose()
    EventControler:dispatchEvent(FriendEvent.FRIEND_ADD_FRIEND_BUTTON_ACTION,nil)--self.friendApplyMapcount)
    self:startHide()
end
return FriendAddview
