-- FriendAppListView
-- //好友系统
-- refresh Time 20180504
-- author:wk   好友申请列表界面
local FriendAppListView = class("FriendAppListView", UIBase);
local cdTime = FriendModel:getworldTalkTime()
--//_type,1:好友列表,2:添加好友,3:好友申请
function FriendAppListView:ctor(_winName)
    FriendAppListView.super.ctor(self, _winName)
end

function FriendAppListView:loadUIComplete()
    self:registerEvent();
    self.worldHanhua = false
    self.scroll_list:setVisible(false)
    self.panel_2:setVisible(false)
    self.panel_app_q:setVisible(false)
    self.btn_1:setVisible(false)
    self.btn_2:setVisible(false)
    self.panel_app_q.btn_1:setTouchedFunc(c_func(self.worldAppFriend, self));
end

--世界喊话
function FriendAppListView:worldAppFriend()
	echo("======世界喊话=========")
    local function callBack()
        WindowControler:showTips(GameConfig.getLanguage("#tid_friend_101"));
        FriendModel.worldChatCD = TimeControler:getServerTime()
        FilterTools.setGrayFilter(self.panel_app_q.btn_1)
        self:delayCall(function ()
           FilterTools.clearFilter(self.panel_app_q.btn_1)
           FriendModel.worldChatCD = 0
           self.panel_app_q.btn_1:setTouchedFunc(c_func(self.worldAppFriend, self));
        end,cdTime)
        self.panel_app_q.btn_1:setTouchedFunc(function ()
           WindowControler:showTips(GameConfig.getLanguage("#tid_friend_106"));
        end);
    end

    FriendModel:sendWorldChat(callBack)
end
-- //注册按钮事件
function FriendAppListView:registerEvent()
    FriendAppListView.super.registerEvent(self);

    EventControler:addEventListener(FriendEvent.FRIEND_APPLY_REQUEST,self.initData,self)
end 

function FriendAppListView:initData(_cellBack)
    self.friendMap={};
    self.friendMap.count=FriendModel:getFriendCount();
    self:worldChatCd()
	self:sendServerdata()
    if _cellBack and type(_cellBack) == "function" then
        _cellBack()
    end
end

function FriendAppListView:worldChatCd()
    if FriendModel.worldChatCD == 0 then
        FilterTools.clearFilter(self.panel_app_q.btn_1)
        self.panel_app_q.btn_1:setTouchedFunc(c_func(self.worldAppFriend, self));
    else
        local serveTime = TimeControler:getServerTime()
        local time = serveTime - FriendModel.worldChatCD
        if time >= cdTime then 
            FilterTools.clearFilter(self.panel_app_q.btn_1)
            self.panel_app_q.btn_1:setTouchedFunc(c_func(self.worldAppFriend, self));
        else
            if  not self.worldHanhua then
                FilterTools.setGrayFilter(self.panel_app_q.btn_1)
                self.panel_app_q.btn_1:setTouchedFunc(function ()
                   WindowControler:showTips(GameConfig.getLanguage("#tid_friend_106"));
                end);
                self.worldHanhua = true
                self:delayCall(function ()
                   FilterTools.clearFilter(self.panel_app_q.btn_1)
                   FriendModel.worldChatCD = 0
                   self.panel_app_q.btn_1:setTouchedFunc(c_func(self.worldAppFriend, self));
                end,time)

            end
        end

    end
end




function FriendAppListView:sendServerdata()
	local function _callback(_param)
		dump(_param.result.data,"获取好友申请列表") 
        if (_param.result ~= nil) then
            -- FriendModel:updateFriendApply(_param.result.data);
            self:setFriendApplyMap(_param.result.data);
            EventControler:dispatchEvent(FriendEvent.FRIEND_ADD_FRIEND_BUTTON_ACTION,nil)
        else
            echo("----FriendMainView:freshFriendApplyCommon--", _param.error.code, _param.error.message);
        end
    end

    local isok =  FriendModel:isFriendApply()
    if isok then
	    local param = { };
	    param.page = 1;
	    FriendServer:getFriendApplyList(param, _callback);
	else

		self:setFriendApplyMap({})
	end
end

function FriendAppListView:setFriendApplyMap(data)

    local newdata = {}
    self.friendApplyMap = {}
    self.friendApplyMap.count = data.count or 0
    local applyList = data.applyList
    local num =  table.length(applyList or {})
    local friendList =  FriendModel:getFriendList()
    local friendNum = table.length(friendList or {})
    if num ~= 0 then
        local sumCount = FuncDataSetting.getDataByConstantName("FriendLimit")
        -- local data = FriendModel:getFriendList()
        if friendNum >= sumCount then
            self.panel_app_q:setVisible(true)
            self.panel_app_q.btn_1:setVisible(false)
            self.panel_app_q.mc_tt:showFrame(2)
            self.panel_app_q.mc_tt:getViewByFrame(2).panel_1.txt_1:setString(GameConfig.getLanguage("#tid_friend_105"))
        else
            -- self.friendApplyMap = data
            local index = 1
            for k,v in pairs(applyList) do
                newdata[index] = v
                index = index + 1
            end
            self.friendApplyMap.applyList = {}
            self.friendApplyMap.applyList = newdata

            self:setFriendApplyList()
        end
	else
		self.panel_app_q:setVisible(true)
		self.scroll_list:setVisible(false)
	    self.btn_1:setVisible(false)
	    self.btn_2:setVisible(false)
        self.panel_app_q.btn_1:setVisible(true)
        self.panel_app_q.mc_tt:showFrame(1)
        self.panel_app_q.mc_tt:getViewByFrame(1).panel_1.txt_1:setString(GameConfig.getLanguage("#tid_friend_104"))
	end

end




function FriendAppListView:setFriendApplyList()
  
	local panel = self.panel_2
    local function createFunc(_item)
        local _cell = UIBaseDef:cloneOneView(panel.panel_2);
        self:setFriendApplyCellItem(_cell, _item);
        return _cell;
    end
    local function updateCellFunc(_item,_cell)
        self:setFriendApplyCellItem(_cell,_item);
    end
    local data = self.friendApplyMap.applyList
    data  = FriendModel:friendSort(data) 
    local _scrollParam = {
         {
            data = data,
            createFunc = createFunc,
            updateCellFunc= updateCellFunc,
            perNums = 1,
            offsetX = 10,
            offsetY = 0,
            widthGap = 0,
            heightGap = 0, 
            itemRect = { x = 0, y = - 115, width = 920, height = 115 },
            perFrame = 1,
        }
    };
    self.scroll_list:cancleCacheView()
    self.scroll_list:setVisible(true)
    self.scroll_list:styleFill(_scrollParam);
    self.scroll_list:hideDragBar()
    self.panel_app_q:setVisible(false)
    self.btn_1:setVisible(true)
    self.btn_2:setVisible(true)

    -- -- //全部拒绝
    self.btn_1:setTouchedFunc(c_func(self.clickButtonRejectAllAppply, self));
     -- -- //全部同意
    self.btn_2:setTouchedFunc(c_func(self.clickButtonApproveAllApply, self));
end


function FriendAppListView:setFriendApplyCellItem(_cell,_item)
	--好友图标
    local _icon = FuncChar.icon(tostring(_item.avatar));
    -- local _node = _cell.panel_1.ctn_1;
    -- _node:removeAllChildren();

    -- ChatModel:setPlayerIcon(_node,_item.head,_item.avatar ,0.9)

    _cell.UI_1:setPlayerInfo(_item)

    local _name=_item.name;-- //名字
    if(_name==nil or _name=="")then
            _name=GameConfig.getLanguage("tid_common_2006");     
    end
    _cell.txt_1:setString(_name);
    _cell.txt_red:setString(0);
    -- _cell.panel_1.txt_1:setString(_item.level);
    -- //等级
    local sumtotal = 0
    if _item.abilityNew ~= nil then
        if _item.abilityNew.formationTotal ~= nil then
            sumtotal = _item.abilityNew.formationTotal
        end
    end
    _cell.txt_5:setString(GameConfig.getLanguage("#tid_friend_002") ..sumtotal);
    -- //战力
    -- local playermingcheng = "大神"  ---玩家称号说
    -- _cell.txt_god:setString("["..playermingcheng.."]")

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


    -- _cell.ctn_xian

    -- //注册按钮回调
     -- //拒绝好友申请
    _cell.btn_2:setTap(c_func(self.clickCellButtonRejectApply, self, _item));
   -- //同意好友申请
    _cell.btn_1:setTap(c_func(self.clickCellButtonApproveApply, self, _item));
	--//注册查看玩家详情
   -- _cell.panel_1:setTouchedFunc(c_func(self.clickCellButtonQueryPlayer,self,_item),nil,true);


    -- _cell.panel_lixian:setVisible(false)
    _cell.panel_haogandu:setVisible(false)


    local logoutTime = _item.userExt.logoutTime
    local str = FriendModel:getOutDDHHSSTime(logoutTime)
    _cell.txt_6:setString(str);

    -- _cell.panel_out_time_a:setTouchedFunc(c_func(self.touchOutTime, self, _cell));
    _cell.panel_hyd_h:setTouchedFunc(c_func(self.touchHYD, self, _cell));


end

function FriendAppListView:clickCellButtonQueryPlayer( _item )
    FriendModel:clickCellPlayerInfo(_item)
end



function FriendAppListView:touchOutTime( _cell )
    if not _cell.panel_lixian:isVisible() then
        _cell.panel_lixian:setVisible(true)
        local function callBack()
            _cell.panel_lixian:setVisible(false)
        end
        FriendModel:panelRunAction(_cell.panel_lixian,callBack)
        
    end
end

function FriendAppListView:touchHYD( _cell )
    if not _cell.panel_haogandu:isVisible() then
        _cell.panel_haogandu:setVisible(true)
        local function callBack()
            _cell.panel_haogandu:setVisible(false)
        end
        FriendModel:panelRunAction(_cell.panel_haogandu,callBack)
    end
end

function FriendAppListView:clickCellButtonRejectApply(_item)
    local function _callback(_param)
        if (_param.result ~= nil) then
            WindowControler:showTips(GameConfig.getLanguage("tid_friend_reject_apply_1029"));
            -- self.scroll_list:clearOneView(_item);
            FriendModel:setfriendApplyCount()
            table.remove(self.friendApplyMap.applyList, _item.index);
            self.friendApplyMap.count = self.friendApplyMap.count - 1;
            -- EventControler:dispatchEvent(FriendEvent.FRIEND_ADD_FRIEND_BUTTON_ACTION,nil)--self.friendApplyMapcount)
            self:removePlayData(_item)
            self:sendServerdata()
            EventControler:dispatchEvent(FriendEvent.FRIEND_ADD_FRIEND_BUTTON_ACTION,nil)
        else
           	if (_param.error.message == "friend_exists" or _param.error.message=="friend_apply_not_exists") then
                WindowControler:showTips(GameConfig.getLanguage("tid_friend_already_exist_1036"));
           	else

            end 
        end
    end
    local param = { };
    param.fuid = _item.uid;
    param.isAll = 0;
    FriendServer:rejectFriend(param, _callback);
end

-- //同意好友申请
function FriendAppListView:clickCellButtonApproveApply(_item)
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
            FriendModel:setfriendApplyCount()
            -- //添加好友
            WindowControler:showTips(GameConfig.getLanguage("tid_friend_approve_apply_1031"));
            -- //移除相关的数据
            table.remove(self.friendApplyMap.applyList, _item.index);
            self.friendApplyMap.count = self.friendApplyMap.count - 1;
            self.friendMap.count = self.friendMap.count + 1;
            -- //好友的数目+1
            FriendModel:setFriendCount(self.friendMap.count);
            self:sendServerdata()
            self:sendaddfriend({_item})
            EventControler:dispatchEvent(FriendEvent.FRIEND_ADD_FRIEND_BUTTON_ACTION,nil)--self.friendApplyMapcount)

        else
            if (_param.error.message == "friend_count_limit") then
                -- //好友已经达到上限
                WindowControler:showTips(GameConfig.getLanguage("tid_friend_friend_count_limit_1030"));
             elseif (_param.error.message == "friend_exists" or _param.error.message=="friend_apply_not_exists") then
                WindowControler:showTips(GameConfig.getLanguage("tid_friend_already_exist_1036"));
            end
        end
    end

    local param = { };
    param.fuid = _item.uid;
    param.isAll = 0;
    FriendServer:approveFriend(param, _callback);
end

function FriendAppListView:removePlayData(playData)
	local applyList = self.friendApplyMap.applyList
	for k,v in pairs(applyList) do
		if v.rid == playData.rid then
			table.remove(self.friendApplyMap.applyList,k)
		end
	end

	dump(self.friendApplyMap.applyList,"拒绝后的数据 ====")
end





-- //全部拒绝好友申请
function FriendAppListView:clickButtonRejectAllAppply()

    -- //首先判断是否有好友申请
    if (self.friendApplyMap.count <= 0) then
    	self:setFriendApplyMap({})
        WindowControler:showTips(GameConfig.getLanguage("tid_friend_no_friend_apply_1031"));
        return;
    end
    local function _callback(_param)
        if (_param.result ~= nil) then
            WindowControler:showTips(GameConfig.getLanguage("tid_friend_reject_apply_1029"));
            self.friendApplyMap.applyList = { };
            self.friendApplyMap.count = 0;
            FriendModel:updateFriendApply(self.friendApplyMap);
            FriendModel:setfriendApplyCount(1)
            self:setFriendApplyMap({})
            EventControler:dispatchEvent(FriendEvent.FRIEND_ADD_FRIEND_BUTTON_ACTION,nil)--self.friendApplyMapcount)
        else
            echo("--FriendMainView:clickButtonRejectAllAppply--", _param.error.code, _param.error.message);
        end
    end
    local param = { };
    param.isAll = 1;
    FriendServer:rejectFriend(param, _callback);
end

-- //全部同意好友申请
function FriendAppListView:clickButtonApproveAllApply()
    if (self.friendApplyMap.count <= 0) then
    	self:setFriendApplyMap({})
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
        	local data = _param.result.data
        	dump(data,"=======好友同意数据=====")
            self.friendMap.count = self.friendMap.count + data.count;
            -- //好友的数目增加
            FriendModel.friendApplyCount = 0
            FriendModel:setFriendCount(self.friendMap.count);
            WindowControler:showTips(GameConfig.getLanguage("tid_friend_approve_all_apply_1032"):format(_param.result.data.count));
            local applyList = self.friendApplyMap.applyList
            self:sendaddfriend(applyList)
            -- for k,v in pairs(applyList) do
            -- 	FriendModel:insertFriendData(v)
            -- end
            self.friendApplyMap.applyList = { };
            self.friendApplyMap.count = 0;
            self:setFriendApplyMap({})


            EventControler:dispatchEvent(FriendEvent.FRIEND_ADD_FRIEND_BUTTON_ACTION,nil)--self.friendApplyMapcount)
        else
            WindowControler:showTips(GameConfig.getLanguage("tid_friend_can_not_add_friend_1033"));
            echo("--clickButtonApproveAllApply--", _param.error.code, _param.error.message);
        end
    end
    local param = { };
    param.isAll = 1;
    FriendServer:approveFriend(param, _callback);
end
function FriendAppListView:sendaddfriend(ridtable)
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


return FriendAppListView;