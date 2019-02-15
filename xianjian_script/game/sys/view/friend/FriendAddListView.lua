-- FriendAddListView
-- //好友系统
-- refresh Time 20180504
-- author:wk   添加好友列表界面
local FriendAddListView = class("FriendAddListView", UIBase);

function FriendAddListView:ctor(_winName)
    FriendAddListView.super.ctor(self, _winName);
   
end

function FriendAddListView:loadUIComplete()
    self:registerEvent();
    self.panel_3:setVisible(false)
    self.mc_btn:setVisible(false)
    self.scroll_1:setVisible(false)
    self.panel_ti:setVisible(false)
    self:setBUtton()
    -- self:initData()
    self.panel_ti.txt_1:setString(GameConfig.getLanguage("#tid_friend_003"))

end
-- //注册按钮事件
function FriendAddListView:registerEvent()
    FriendAddListView.super.registerEvent(self);
end 


-- //重新刷新好友申请页面
function FriendAddListView:freshFriendAddingUICommon(_cellBack)
    local function _callback(_param)
        -- dump(_param.result,"推荐好友显示")
        if (_param.result ~= nil) then
        	self.findData = {}
            local _recommendFriend = _param.result.data.introduceList;
            self:setFriendAddingMap(_recommendFriend);
            self.getshengqingplaydata = true
        else
            echo("----FriendMainView:freshFriendAddingUICommon---", _param.error.code, _param.error.message);
            WindowControler:showTips(GameConfig.getLanguage("tid_friend_achieve_friend_failed_1018"));
        end
        if _cellBack then
            _cellBack()
        end
    end
    if self.findData and #self.findData == 0  then
        local param = { };
        if not self.getshengqingplaydata then
            FriendServer:getFriendRecommendList(param, _callback);
        else
            -- self:addfriendbgshow(self.friendAddingMap)
            self:setFriendAddingList();
            if _cellBack then
                _cellBack()
            end
        end
    else
        self:setFriendAddingMap()
        if _cellBack then
            _cellBack()
        end
    end
end

function FriendAddListView:initData(_cellBack,data)
	self.findData = data
	self:freshFriendAddingUICommon(_cellBack)
end

-- //添加好友页面
function FriendAddListView:setFriendAddingMap(_addedMap)
    -- FriendModel:setRecommendedFriend(_addedMap)      
    self.friendAddingMap = {};
    self.friendAddingMap = _addedMap or self.findData;
    -- self.researchFriendFlag=nil;


    self:setFriendAddingList();
    -- self:addfriendbgshow(self.friendAddingMap)
end

function FriendAddListView:setFriendAddingList()
	if table.length(self.findData) ~= 0 then
		self.friendAddingMap = self.findData
	end
	local count = table.length(self.friendAddingMap or {})
	if count == 0 then
		self.panel_ti:setVisible(true)
		self.mc_btn:setVisible(false)
		self.scroll_1:setVisible(false)
	else
		self.panel_ti:setVisible(false)
		self.mc_btn:setVisible(true)
		self.scroll_1:setVisible(true)
		self:setaddfriendlistview()
	end
end


function FriendAddListView:setaddfriendlistview()

    local newtable  = {}
    for k,v in pairs(self.friendAddingMap) do
        if v.applyed ~= nil then
            table.insert(newtable,v)
        else
            table.insert(newtable,1,v)
        end
    end

    newtable = FriendModel:friendSort(newtable) 

    for _index = 1, #newtable do
        newtable[_index].index = _index;
    end
    self.friendAddingMap  = {}
    self.friendAddingMap = newtable


    local recommendedFriend  =  FriendModel.recommendedFriend
    if recommendedFriend ~= nil then
        for k,v in pairs(self.friendAddingMap) do
            local ishave = nil
            for kk,vv in pairs(recommendedFriend) do
                if v._id == vv._id then 
                    ishave = vv
                end
            end
            if ishave then
                v.applyed = true
            end
        end
    end 


    -- dump(recommendedFriend,"11111111111")
    -- dump(self.friendAddingMap,"好友添加列表=====")

    
    local panel = self.panel_3;
    local function createFunc(_item)
        local _cell = UIBaseDef:cloneOneView(panel.panel_2);
        self:setFriendAddingCellItem(_cell,_item);
        return _cell;
    end
    local function updateCellFunc(_item,_cell)
    	self:setFriendAddingCellItem(_cell,_item);
    end

    local  _scrollParam = {
        {
            data = self.friendAddingMap,
            createFunc = createFunc,
            updateCellFunc = updateCellFunc,
            perNums = 1,
            offsetX = 10,
            offsetY = 0,
            widthGap = 0,
            heightGap = 0, 
            itemRect = {x = 0, y = -115, width = 920, height = 115},
            perFrame = 1,
        }
    } 
    self.scroll_1:refreshCellView( 1 )
    self.scroll_1:setVisible(true)
    self.scroll_1:styleFill(_scrollParam );
    self.scroll_1:hideDragBar()
    self.scroll_1:cancleCacheView()
   	self.scroll_1:gotoTargetPos(1,1,0)

end

function FriendAddListView:setFriendAddingCellItem(_cell, _item)

	-- local _cell = _view.panel_2
    -- //英雄图标
    local _icon = FuncChar.icon(tostring(_item.avatar));
    -- local _node = _cell.panel_1.ctn_1;
   	-- _node:removeAllChildren()
    -- ChatModel:setPlayerIcon(_node,_item.head,_item.avatar ,0.9)
    _cell.UI_1:setPlayerInfo(_item)

    local _name=_item.name-- //玩家名字
    if(_item.name==nil or _item.name=="")then
        _name=GameConfig.getLanguage("tid_common_2006");
    end 

    _cell.txt_1:setString(_name);

    -- _cell.panel_1.txt_1:setString(_item.level);--等级
    -- //等级
    local ability = 0
    if _item.abilityNew ~= nil then
        if _item.abilityNew.formationTotal ~= nil then
            ability = _item.abilityNew.formationTotal
        end
    end

    _cell.txt_red:setString(_item.lk or 0);
    _cell.txt_5:setString(GameConfig.getLanguage("#tid_friend_002") .. ability);

    
    _cell.mc_god:showFrame(_item.crown or 1) --头衔


    -- local Guildname =  _item.guildName or GameConfig.getLanguage("#tid_friend_003")  ---公会仙盟  暂无
    -- _cell.txt_2:setString(GameConfig.getLanguage("#tid_friend_009")..Guildname)


        ---公会仙盟
    local guildName = GameConfig.getLanguage("#tid_friend_003")  
    local guildAfterName = _item.guildAfterName
    if guildAfterName ~= nil then
        local houzui  = FuncGuild.guildNameType[guildAfterName]
        guildName =  _item.guildName..houzui
    end
    _cell.txt_2:setString(guildName) 

    if _item.guildLogo ~= nil and _item.guildColor ~= nil and _item.guildIcon ~= nil then
        _cell.UI_guild_icon:setVisible(true)
        local icondata = { 
            borderId = _item.guildLogo,
            bgId = _item.guildColor,
            iconId = _item.guildIcon,
        }
        _cell.UI_guild_icon:initData(icondata)
    else
        _cell.UI_guild_icon:setVisible(false)
    end

    if _item.titles ~= nil then
        _cell.mc_t:showFrame(1)
        local titleid = ""
        for k,v in pairs(_item.titles) do
            if v.isActivate == 1  then
                titleid = k
            end
        end
        local ctn_title = _cell.mc_t:getViewByFrame(1).ctn_title
        FriendModel:addCharTitle(ctn_title,titleid)
    else
        _cell.mc_t:showFrame(2)
    end


    -- _cell.panel_yishenqing:setVisible(false);
    _cell.btn_2:setVisible(false)
    _cell.mc_bg:showFrame(1)

    -- //申请按钮
    if _item._id == UserModel:rid() then
        _cell.btn_1:setVisible(false)
        --//查看玩家信息
        _cell.UI_1:setTouchedFunc(function ()     end,nil,true);
    else
        _cell.btn_1:setVisible(true)
        --//查看玩家信息
        _cell.UI_1:setTouchedFunc(c_func(self.clickCellButtonQueryPlayer,self,_item),nil,true);
    end
    local isfriend = FriendModel:byIdISFriend(_item._id)
    if isfriend then
        _cell.btn_1:setVisible(false)
    end

    _cell.btn_1:setTouchedFunc(c_func(self.clickCellButtonApplyFriend, self, _item));
--//查看玩家信息
    -- _cell.panel_1:setTouchedFunc(c_func(self.clickCellButtonQueryPlayer,self,_item),nil,true,c_func(self.onCellBeganEvent,self,_item),c_func(self.onCellMovedEvent,self,_item));
    
    if _item.isfriend ~= nil then
        if _item.isfriend then
            -- _cell.panel_yishenqing:setVisible(false)
            _cell.btn_2:setVisible(false)
            _cell.btn_1:setVisible(false)
        end
    end
    if _item.applyed ~= nil then
        _cell.btn_2:setVisible(true)
        _cell.btn_1:setVisible(false)
    end


    -- _cell.panel_lixian:setVisible(false)
    _cell.panel_haogandu:setVisible(false)


    local logoutTime = _item.userExt.logoutTime
    local str = FriendModel:getOutDDHHSSTime(logoutTime)
    _cell.txt_6:setString(str);

    -- _cell.panel_out_time:setTouchedFunc(c_func(self.touchOutTime, self, _cell));
    _cell.panel_hyd_h:setTouchedFunc(c_func(self.touchHYD, self, _cell));
end


function FriendAddListView:clickCellButtonQueryPlayer( _item )
    FriendModel:clickCellPlayerInfo(_item)
end

function FriendAddListView:touchOutTime( _cell )
	if not _cell.panel_lixian:isVisible() then
		_cell.panel_lixian:setVisible(true)
		local function callBack()
			_cell.panel_lixian:setVisible(false)
		end
    	FriendModel:panelRunAction(_cell.panel_lixian,callBack)
		
	end
end

function FriendAddListView:touchHYD( _cell )
	if not _cell.panel_haogandu:isVisible() then
		_cell.panel_haogandu:setVisible(true)
		local function callBack()
			_cell.panel_haogandu:setVisible(false)
		end
    	FriendModel:panelRunAction(_cell.panel_haogandu,callBack)
	end
end


-- //申请加好友,单元格中的事件
function FriendAddListView:clickCellButtonApplyFriend(_item)
    --//是否好友数目已经满了
	-- self.scroll_1._isEnableScroll = false
    local isopen = FuncCommon.isjumpToSystemView(FuncCommon.SYSTEM_NAME.FRIEND)
    if not isopen then
        return 
    end

    if _item._id == UserModel:rid() then 
        WindowControler:showTips(GameConfig.getLanguage("#tid_friend_010"))
        return 
    end 

    local  _max_friend_count=FuncDataSetting.getDataByConstantName("FriendLimit");
    local  _friend_count = FriendModel:getFriendCount();
    
    if(_friend_count>=_max_friend_count)then
        WindowControler:showTips(GameConfig.getLanguage("tid_friend_self_friend_count_reach_limit_1046"));
        return;
    end
    local function _callback(_param)
        if (_param.result ~= nil) then
          local  _otherItem=_item;
           _otherItem.applyed=true;
           -- dump(_param.result,"获得发送返回数据")
            if _param.result.data ~= nil then
                if _param.result.data.friendAdd == 1 then
                    WindowControler:showTips(GameConfig.getLanguage("#tid_friend_011"))
                    return 
                else   ---等于0 是其他请况

                end
                if _param.result.data.count ~= 0 then
                    local _cell = self.scroll_1:getViewByData(self.friendAddingMap[_item.index]);
                    if _cell ~= nil then
                    	FriendModel:setRecommendedFriend(_item)
        	            _cell.btn_1:setVisible(false);
                        -- _cell.panel_yishenqing:setVisible(true)
                        _cell.btn_2:setVisible(true)
        	            WindowControler:showTips(GameConfig.getLanguage("tid_friend_send_request_1015"));
        	        end
                else
                    if _param.result.data.friendAdd == 0 then 
                        WindowControler:showTips(GameConfig.getLanguage("#tid_friend_012"))
                    end
                end
            end 
        else
            if (_param.error.message == "friend_can_not_be_myself") then
                WindowControler:showTips(GameConfig.getLanguage("tid_friend_can_not_add_self_1034"));
            elseif (_param.error.message == "friend_exists" or _param.error.message=="friend_apply_not_exists") then
                WindowControler:showTips(GameConfig.getLanguage("tid_friend_already_exist_1036"));
            elseif(_param.error.message=="friend_count_limit")then--//对方好友已满
                WindowControler:showTips(GameConfig.getLanguage("tid_friend_friend_count_limit_1030"));
            else
                WindowControler:showTips(GameConfig.getLanguage("tid_friend_send_request_failed_1016"));
            end
            self:setFriendAddingList()
        end
    end
    local rid = self.friendAddingMap[_item.index]._id
    local param = { };
    param.ridInfos = {}
    local sce = FriendModel:getRidBySec(rid) or  LoginControler:getServerId()
    param.ridInfos[1]  = {[sce] = rid}
    FriendServer:applyFriend(param, _callback);
    
end


function FriendAddListView:setBUtton()
	
	self.mc_btn:showFrame(3)
	self.mc_btn:getViewByFrame(3).btn_1:setTouchedFunc(c_func(self.clickButtonChangeOtherFriend, self));
	self.mc_btn:getViewByFrame(3).btn_2:setTouchedFunc(c_func(self.allApplyFriend, self));


end
-- //换一批好友推荐
function FriendAddListView:clickButtonChangeOtherFriend()
    --//检测是否处于冷却中
    if(self.coldChangeOther)then
          WindowControler:showTips(GameConfig.getLanguage("friend_extra_fresh_cold_down"));
          return;
    end
    local function  _delayAfterColdDown()
          FilterTools.clearFilter(self.mc_btn:getViewByFrame(3).btn_1);
          self:unscheduleUpdate()
          self.refreshbutton:getUpPanel().txt_1:setString("刷新列表")
          self.coldChangeOther=nil;
    end
    --//冷却
    self.coldChangeOther=true;
    FilterTools.setGrayFilter(self.mc_btn:getViewByFrame(3).btn_1);
    -- self:runAction( cc.Sequence:create(cc.DelayTime:create(3.0),cc.CallFunc:create(_delayAfterColdDown)));
    self.getshengqingplaydata = false
    self:unscheduleUpdate()
    self.updateFrameCount = 1
    self.refreshbutton =  self.mc_btn:getViewByFrame(3).btn_1
    self.refreshbutton:getUpPanel().txt_1:setString("5s")
    self:scheduleUpdateWithPriorityLua(c_func(self.updateFrame, self) ,0)
    self:freshFriendAddingUICommon();
end

function FriendAddListView:updateFrame()
    if self.updateFrameCount%GameVars.GAMEFRAMERATE == 0 then
        local sumTime = 5
        self.refreshbutton:getUpPanel().txt_1:setString((sumTime - self.updateFrameCount/GameVars.GAMEFRAMERATE).."s")
        if sumTime - self.updateFrameCount/GameVars.GAMEFRAMERATE == 0 then
            self:unscheduleUpdate()
            FilterTools.clearFilter(self.mc_btn:getViewByFrame(3).btn_1);
            self.refreshbutton:getUpPanel().txt_1:setString("刷新列表")
            self.coldChangeOther=nil;
        end
    end
    self.updateFrameCount = self.updateFrameCount + 1
end




---一键添加
function FriendAddListView:allApplyFriend()
    
    local  _max_friend_count=FuncDataSetting.getDataByConstantName("FriendLimit");
    local  _friend_count = FriendModel:getFriendCount();
    
    if(_friend_count>=_max_friend_count)then
        WindowControler:showTips(GameConfig.getLanguage("tid_friend_self_friend_count_reach_limit_1046"));
        return;
    end


    local function _callback(_param)
        if _param.result then
        -- if _param.result.data.count ~= 0 then
            if table.length(self.friendAddingMap) ~= 0 then
                for k,v in pairs(self.friendAddingMap) do
                    FriendModel:setRecommendedFriend(v)
                end
                self:setaddfriendlistview()
                WindowControler:showTips(GameConfig.getLanguage("tid_friend_send_request_1015"));
            end
        end
    end


    local param = { };
    param.ridInfos = {}
    for k,v in pairs(self.friendAddingMap) do
        if not v.applyed then
            local sce = LoginControler:getServerId()
            local data = {[sce] = v._id}
            table.insert(param.ridInfos,data)
        end
    end

    if table.length(param.ridInfos) ~= 0 then
        local isFriend = false
        if table.length(param.ridInfos) == 1 then
            local sce = LoginControler:getServerId() 
            local data = FriendModel:getFriendDataByID(param.ridInfos[1][sce])
            if data then
                isFriend = true
            end
        end 
        if not isFriend then
            FriendServer:applyFriend(param, _callback);
        else
            WindowControler:showTips(GameConfig.getLanguage("#tid_friend_015"))--"【玩家已是您的好友】")
        end
    else
        WindowControler:showTips("已全部申请")
    end

end



return FriendAddListView;