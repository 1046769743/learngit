-- FriendListView
-- //好友系统
-- refresh Time 20180504
-- author:wk   好友列表界面
local FriendListView = class("FriendListView", UIBase);
--//_type,1:好友列表,2:添加好友,3:好友申请
function FriendListView:ctor(_winName)
    FriendListView.super.ctor(self, _winName)
end

function FriendListView:loadUIComplete()
    self:registerEvent();
    self.tianjiarenshu = 0
    -- self:initData()
    self.panel_h.txt_1:setString(GameConfig.getLanguage("#tid_friend_102"))
    self:setMcButton()
    self:setButtonRed()

end
-- //注册按钮事件
function FriendListView:registerEvent()
    FriendListView.super.registerEvent(self);
    EventControler:addEventListener(FriendEvent.FRIEND_ADD_FRIEND_BUTTON_ACTION  ,self.initData,self)
    EventControler:addEventListener(FriendEvent.FRIEND_REMOVE_SOME_PLAYER  ,self.initData,self)
    EventControler:addEventListener("notify_friend_Agreed_2928" ,self.AddFriendAgreedsendmassege,self)
    
end 

function FriendListView:setButtonRed()
    local isShowRed = FriendModel:getFriendIsHaveSp()
   self.mc_btn:getViewByFrame(1).panel_red:visible(isShowRed or false)
end




function FriendListView:AddFriendAgreedsendmassege(_param)
    if _param.params.params.data.type == 1 then
        local friendinfo = _param.params.params.data.data
        local shaoxia = GameConfig.getLanguage("tid_common_2001")
        if friendinfo ~= nil then
            local _item = {
                avatar  = friendinfo.avatar or 101,
                content = FuncChat.CHAT_STRING.friend,
                level   = friendinfo.level or 1,
                name    = friendinfo.name or shaoxia,
                rid    = friendinfo._id or friendinfo.rid,
                time    = TimeControler:getServerTime(),
                type    = 1,
                vip     = friendinfo.vip or 0,
                uid     =  friendinfo.uid,
            }
            FriendModel:insertFriendData(friendinfo)
        end
    else  ---删除好友
        local uid = _param.params.params.data.uid
        FriendModel:removeFriendUID( uid )
    end
    self:initData()

end



function FriendListView:initData(_cellBack)
    echo("==========_cellBack======",type(_cellBack))
    self:freshFriendListUICommon(_cellBack)

end

-- //重新获取好友列表页面
function FriendListView:freshFriendListUICommon(_cellBack)

    local function _callback(_param)
        -- dump(_param.result,"获取服务器好友列表")
        if (_param.result ~= nil) then
            FriendModel:setFriendList(_param.result.data.friendList);
            FriendModel:setFriendCount(_param.result.data.count);
            FriendModel:updateFriendSendSp(_param.result.data);
            self:showDataList()
            EventControler:dispatchEvent(FriendEvent.FRIEND_REFRESH_FIREND_COUNT);
        else
            WindowControler:showTips(GameConfig.getLanguage("tid_friend_no_enough_friends_1017"));
            echo("-----FriendMainView:clickButtonPrevPage-------", _param.error.code, _param.error.message);
        end
        if _cellBack then
            if type(_cellBack) == "function" then
                _cellBack()
            end
        end
    end
    local param = { };
    param.page = 1;
    FriendServer:getFriendListByPage(param, _callback);
end

function FriendListView:showDataList()
    self.friendMap={};
    self.friendMap.count = FriendModel:getFriendCount();
    
    local data = FriendModel:getFriendList()



    self.panel_1:setVisible(false)
    if table.length(data) == 0 then
        self.mc_btn:setVisible(false)
        self.scroll_list3:setVisible(false)
        self.panel_h:setVisible(true)
    else
        self.panel_h:setVisible(false)
        self.mc_btn:setVisible(true)
        self:initCell()
    end
end





function FriendListView:initCell()
	local data = FriendModel:getFriendList()
	data = FriendModel:friendSort(data)
	local function createFunc(_item)
        local _cells = UIBaseDef:cloneOneView(self.panel_1.panel_2);
        self:setFriendListCell(_cells, _item);
        return _cells;
    end 
    local function updateFunc(_item,_cells)
        self:setFriendListCell(_cells, _item);
    end 

	local _scrollParam = {
        {
            data = data,
            createFunc = createFunc,
            updateCellFunc = updateFunc,
            perNums = 1,
            offsetX = 10,
            offsetY = 0,
            widthGap = 0,
            heightGap = 0,
            itemRect = { x = 0, y = - 115, width = 920, height = 115 },
            perFrame = 1,
        },
    }
    self.scroll_list3:setVisible(true)
    self.scroll_list3:styleFill( _scrollParam );
    self.scroll_list3:hideDragBar()
    self.scroll_list3:refreshCellView(1)


end


-- //设置好友列表信息
function FriendListView:setFriendListCell(_cell, _item)

    local _icon = FuncChar.icon(tostring(_item.avatar));
    -- local _node = _cell.panel_1.ctn_1;
    -- _node:removeAllChildren();

    -- ChatModel:setPlayerIcon(_node,_item.head,_item.avatar ,0.9)

    _cell.UI_1:setPlayerInfo(_item)
    local  _name=_item.name-- //玩家名字
    if(_name==nil or _name=="")then
        _name=GameConfig.getLanguage("tid_common_2006");
    end
    -- local friendnicheng = _item.mk  --好友昵称
    -- if friendnicheng == "" or friendnicheng == nil then
    --     friendnicheng = _name
    -- end

    _cell.txt_1:setString(_item.mk or _name);


    local number = 0
    if _item.abilityNew ~= nil then
        if _item.abilityNew.formationTotal ~= nil then
            number = _item.abilityNew.formationTotal
        end
    end
    
    _cell.txt_5:setString("总战力：" .. number);    -- //战斗力
    -- if (_item.vip > 0) then    -- //VIP等级
    --     _cell.mc_1:showFrame(_item.vip);
    -- else
    --     _cell.mc_1:setVisible(false);
    -- end
    -- _cell.mc_1:setVisible(false); --版本测试

    -- //登录情况
    -- _cell.txt_6:setString(self:formatLoginInfo(_item.userExt.loginTime));
    -- //是否已经领取体力,是否已经赠送立体--//设置领取体力,赠送体力按钮回调
    if (_item.hasSend) then
        -- //如果已经赠送
        _cell.panel_yizengsong:setVisible(true);
        _cell.btn_1:setVisible(false);
        -- _cell.mc_bg:showFrame(2)
    else
       _cell.panel_yizengsong:setVisible(false);
       _cell.btn_1:setVisible(true);
        _cell.btn_1:setTap(c_func(self.clickCellButtonSendSp, self, _item));
        -- _cell.mc_bg:showFrame(1)
    end
    if  _item.userExt ~= nil then
        if _item.userExt.logoutTime == 0 then
            _cell.mc_bg:showFrame(1)
        else
            _cell.mc_bg:showFrame(2)
        end
    end

--//为好友的管理注册事件监听
    -- _cell.panel_1.txt_1:setString(_item.level)  ---玩家等级
    -- local playermingcheng = "大神"  ---玩家称号  
    -- _cell.txt_god:setString("["..playermingcheng.."]")

    _cell.mc_god:showFrame(_item.crown or 1)

    _cell.txt_red:setString(_item.lk or 100);--好友熟悉度

    -- local Guildname = "暂无仙盟"  ---公会仙盟 
    -- _cell.txt_2:setString(Guildname)

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


    -- if self.sharedata == nil then
        _cell.btn_talk:setTap(c_func(self.clickCellButtonAchieveSp, self, _item))  ---每个玩家私聊按钮
        _cell.UI_1:setTouchedFunc(c_func(self.clickCellButtonQueryPlayer,self,_item),nil,true)
    -- else
        -- _cell.btn_talk:setVisible(false)
        -- _cell.btn_1:setVisible(false)
        -- _cell:setTouchedFunc(c_func(self.Funcsharedata, self,_item),nil,true);
        -- _cell.panel_yizengsong:setVisible(false);
    -- end

    if _item.hasSp then
        _cell.btn_2:setVisible(true)
    else
        _cell.btn_2:setVisible(false)
    end

    if _item.hasGetSp then
        _cell.panel_yilingqu:setVisible(true) 
    else
        _cell.panel_yilingqu:setVisible(false) 
    end

    _cell.btn_2:setTouchedFunc(c_func(self.cellgetSp,self,_item),nil,true)

    -- _cell.panel_lixian:setVisible(false)
    _cell.panel_haogandu:setVisible(false)

    local logoutTime = _item.userExt.logoutTime
    local str = FriendModel:getOutDDHHSSTime(logoutTime)
    _cell.txt_6:setString(str);

    -- _cell.panel_out_time_h:setTouchedFunc(c_func(self.touchOutTime, self, _cell));
    _cell.panel_hyd_h:setTouchedFunc(c_func(self.touchHYD, self, _cell));

end

function FriendListView:clickCellButtonQueryPlayer( _item )
	FriendModel:clickCellPlayerInfo(_item)
end

function FriendListView:cellgetSp(_item)
    local function _callback(_param)
	    if (_param.result ~= nil) then
	        local function callBack()
	        	local spNum = _param.result.data.sp
	            if spNum > 0 then
	                -- local _cell = self.mc_scroll:getViewByFrame(1).scroll_1:getViewByData(_item);
	                -- _cell.mc_liwu:showFrame(2)
	                -- _cell.mc_liwu:getViewByFrame(2).btn_1:setTap(c_func(self.getNotLiWuButton,self,_item))
	                -- _cell.panel_red:setVisible(false)
	                local _cell = self.scroll_list3:getViewByData(_item)
	                _cell.panel_yilingqu:setVisible(true)
                    _cell.btn_2:setVisible(false)
	                FriendModel:setFriendSp(_item)
	                EventControler:dispatchEvent(FriendEvent.FRIEND_ADD_FRIEND_BUTTON_ACTION,nil)
	                WindowControler:showTips(GameConfig.getLanguage("#tid_chat_007"))
	            else--//分情况
	                local _maxSpNum = FuncDataSetting.getDataByConstantName("HomeCharBuySPMax");
	                local  _oneSp=FuncDataSetting.getDataByConstantName("FriendGift");
	                if (UserExtModel:sp() + _oneSp > _maxSpNum) then--//体力超上限
	                    WindowControler:showTips(GameConfig.getLanguage("tid_friend_achieve_sp_reach_limit_1044"):format(_maxSpNum));
	                else
	                    WindowControler:showTips(GameConfig.getLanguage("tid_friend_achieve_sp_to_limit_1047"));
	                end
	            end
                self:setButtonRed()
	        end

	        FriendModel:SendServergetFriendList(callBack)
	    else
            echo("-----FriendMainView:clickButtonSendSp-------", _param.error.code, _param.error.message);
            local _tipMessage = GameConfig.getLanguage("tid_friend_achieve_sp_failed_1024");
            -- //领取体力失败
            if (_param.error.message == "friend_sp_times_max") then
                _tipMessage = GameConfig.getLanguage("tid_friend_self_sp_reach_limit_1025");
                -- //自己已经达到体力上限
            elseif (_param.error.message == "friend_sp_not_exists") then--//好友已经被删除了
                -- //无法领取体力
                _tipMessage = GameConfig.getLanguage("tid_friend_need_add_friend_first_1045");--GameConfig.getLanguage("tid_friend_can_not_achieve_sp_1026");
                -- self:freshFriendListUICommon();--//刷新页面
            elseif(_param.error.message=="friend_not_exists")then--//如果不是好友
                _tipMessage=GameConfig.getLanguage("tid_friend_need_add_friend_first_1045");
                -- self:freshFriendListUICommon();--//刷新页面
            end
            WindowControler:showTips(_tipMessage);
        end

    end
        local param = { };
    param.frid = _item._id;
    param.isAll = 0;
    FriendServer:achieveFriendSp(param, _callback);
end


function FriendListView:clickCellButtonSendSp(_item)
    -- //如果赠送成功了,需要刷新相关的组件
    local function _callback(_param)
        if (_param.result ~= nil) then
            local _cell = self.scroll_list3:getViewByData(_item)
            local sprite=UIBaseDef:cloneOneView(_cell.panel_yizengsong):getChildren()[1];
            _cell.btn_1:setVisible(false);
            _cell.panel_yizengsong:setVisible(true)
            -- PlayStampAnimation(self,sprite,_cell.ctn_donghua1,_cell.ctn_donghua1,_cell.panel_yizengsong,1);
            if _item.lk ~= nil then
                _cell.txt_red:setString(_item.lk+1)
            end
            -- self.friendMap.friendList[tonumber(_item.index)].vSendSp = true
            -- self.friendMap.friendList[tonumber(_item.index)].hasSend = true

           local  _other_item=_item
            _other_item.vSendSp=true;
            -- _cell.mc_bg:showFrame(2)
            
            if FriendModel:gettianjiarenshu() > 0 then
                self.tianjiarenshu = self.tianjiarenshu - 1
            end


            FriendModel:checkFriendSp(_item._id)
            FriendModel:settianjiarenshu( self.tianjiarenshu )
            -- self:checkGrayOneKeySend();
            ---发送体力聊天
            -- self:sendChatSendSP(_item)

            WindowControler:showTips(GameConfig.getLanguage("tid_friend_send_sp_success_1020"));

        else
            echo("-----FriendMainView:clickButtonSendSp-------", _param.error.code, _param.error.message);
            local _tipMessage = GameConfig.getLanguage("tid_friend_send_sp_failed_1019");
            -- 赠送体力失败
            if (_param.error.message == "friend_not_exists") then
                _tipMessage = GameConfig.getLanguage("不存在该玩家")--"tid_friend_not_exist_1021");
                -- //好友不存在
            elseif (_param.error.message == "friend_sp_times_max") then
                -- //对方体力已经达到上限
                _tipMessage = GameConfig.getLanguage("tid_friend_sp_reach_limit_1022");
            end
            WindowControler:showTips(_tipMessage);
        end
        self:setButtonRed()
        -- self:setRefreshlistview(1)
    end
    local param = { };
    param.frid = _item._id;
    param.isAll = 0;
    echo("========体力赠送RID===",_item._id)
    -- //非一键赠送
    FriendServer:sendFriendSp(param, _callback);
end





function FriendListView:touchOutTime( _cell )
	if not _cell.panel_lixian:isVisible() then
		_cell.panel_lixian:setVisible(true)
		local function callBack()
			_cell.panel_lixian:setVisible(false)
		end
    	FriendModel:panelRunAction(_cell.panel_lixian,callBack)
		
	end
end

function FriendListView:touchHYD( _cell )
	if not _cell.panel_haogandu:isVisible() then
		_cell.panel_haogandu:setVisible(true)
		local function callBack()
			_cell.panel_haogandu:setVisible(false)
		end
    	FriendModel:panelRunAction(_cell.panel_haogandu,callBack)
	end
end

-- //格式化登录情况详情
function FriendListView:formatLoginInfo(loginTime)
    -- //登录情况
    local _loginInfo = "";
    loginTime=os.time()-loginTime;
    if (loginTime > 30 * 24 * 3600) then
        -- 大于30天
        _loginInfo = GameConfig.getLanguage("tid_friend_long_ago_1009");
    elseif (loginTime > 24 * 3600) then
        _loginInfo = GameConfig.getLanguage("tid_friend_some_day_ago_1010"):format(math.floor(loginTime /(24 * 2600)));
    elseif (loginTime > 3600) then
        _loginInfo = GameConfig.getLanguage("tid_friend_some_hour_ago_1011"):format(math.floor(loginTime / 3600));
    elseif (loginTime > 60) then
        _loginInfo = GameConfig.getLanguage("tid_friend_some_minute_ago_1012"):format(math.floor(loginTime / 60));
    else
        _loginInfo = GameConfig.getLanguage("tid_friend_just_right_1013");
    end
    return GameConfig.getLanguage("tid_friend_login_state_1014") .. _loginInfo;
end


-- //获取好友赠送的体力
function FriendListView:clickCellButtonAchieveSp(_item)
    -- //如果获取失败
    local isopen = FuncCommon.isjumpToSystemView(FuncCommon.SYSTEM_NAME.CHAT)
    if isopen then
        -- dump(_item,"玩家私聊按钮")
        -- local chatClass = self.chatClass;
        -- //将于对象玩家的聊天信息加入到缓存中  
        local player = _item;
        player.rid = player._id;
        local _ui_type = 3;
        ChatModel:insertOnePrivateObject(_item);

        local Windowname =  WindowControler:getWindow( "ChatMainView" )
        if Windowname ~= nil then
            Windowname:showChattypeUI(5,2,player._id)
        else
           	WindowControler:showWindow("ChatMainView", 5,2,player._id);
        end
    end

end


function PlayStampAnimation(_self,sprite,ctn,oneView,otherView)
	local function   afterStampPlay()
       oneView:setVisible(false);
       otherView:setVisible(true);  
  	end
    sprite:setPosition(cc.p(0,-2));
    sprite:setAnchorPoint(cc.p(0.5,0.5));
    local anim = _self:createUIArmature("UI_common","UI_common_shouqing", nil, false,afterStampPlay);
    FuncArmature.changeBoneDisplay(anim, "layer1", sprite)
    anim:pos(0,-2);
    ctn:addChild(anim,1)--0x80);
    
end


---赠送体力发送消息给其他玩家
function FriendListView:sendChatSendSP(ridtable)
    -- dump(ridtable,"送体力的数据")
    ridtable.rid = ridtable._id
    ChatModel:insertOnePrivateObject(ridtable)
    local _item = {
        avatar  = UserModel:avatar(),
        content = "【刚刚送了你体力x1】礼物虽小，情谊无价，祝你在登仙之路越走越高！",
        level   = UserModel:level(),
        name    = UserModel:name(),
        rid    = UserModel:rid(),
        time    = TimeControler:getServerTime(),
        type    = 1,
        vip     = UserModel:vip(),
    }
    -- ChatModel:updatePrivateMessage(_item)

end

function FriendListView:setMcButton()
	self.mc_btn:showFrame(1)
	self.mc_btn:getViewByFrame(1).btn_3:setTouchedFunc(c_func(self.allGetSp,self),nil,true)
	self.mc_btn:getViewByFrame(1).btn_1:setTouchedFunc(c_func(self.allSendSp,self),nil,true)
end

-- //一键赠送体力
function FriendListView:allSendSp()
    local function _callback(_param)
        if (_param.result ~= nil) then
            if _param.result.data.count ~= 0 then
                WindowControler:showTips(GameConfig.getLanguage("tid_friend_send_sp_success_1020"));
                local data = FriendModel:getFriendList()
                for _index = 1, #data do
                   local item = data[_index];
                   if(not item.hasSend)then
                        local _cell = self.scroll_list3:getViewByData(data[_index]);
                        if _cell ~= nil then
                            local sprite=UIBaseDef:cloneOneView(_cell.panel_yizengsong):getChildren()[1];
                            _cell.btn_1:setVisible(false);
                            if item.lk ~= nil then
                                _cell.txt_red:setString(item.lk+1)
                            end
                            PlayStampAnimation(self,sprite,_cell.ctn_donghua1,_cell.ctn_donghua1,_cell.panel_yizengsong,1);
                        end
                        
                        local  _other_item = item
                        _other_item.hasSend=true;
                    end
                end
                -- self:sendAllChatSendSP() --注释发送送体力的方法
                self.yijiangzengsong = false
                self.tianjiarenshu = 0
                
                FriendModel:settianjiarenshu( self.tianjiarenshu )
            else
                WindowControler:showTips("已全部赠送")
            end
        else
            echo("-----FriendMainView:clickButtonSendSp-------", _param.error.code, _param.error.message);
            local _tipMessage = GameConfig.getLanguage("tid_friend_send_sp_success_1020");
            -- 赠送体力失败
            if (_param.error.message == "friend_not_exists") then
                _tipMessage = GameConfig.getLanguage("不存在该玩家")--"tid_friend_not_exist_1021");
                -- //好友不存在
            elseif (_param.error.message == "friend_sp_times_max") then
                -- //对方体力已经达到上限
                _tipMessage = GameConfig.getLanguage("tid_friend_sp_reach_limit_1022");
            end
            WindowControler:showTips(_tipMessage);
        end
    end
    local param = { };
    param.isAll = 1;
    FriendServer:sendFriendSp(param, _callback);
end

    ---赠送体力发送消息给其他玩家
function FriendListView:sendAllChatSendSP()
    local friendList = FriendModel:getFriendList()
    for i=1,#friendList do
    -- dump(friendList,"0000000")
        if not friendList[i].hasSend then
            friendList[i].rid =friendList[i]._id
            ChatModel:insertOnePrivateObject(friendList[i])
            local _item = {
                avatar  = UserModel:avatar(),
                content = "【刚刚送了你体力x1】礼物虽小，情谊无价，祝你在登仙之路越走越高！",
                level   = UserModel:level(),
                name    = UserModel:name(),
                rid    = UserModel:rid(),
                time    = TimeControler:getServerTime(),
                type    = 1,
                vip     = UserModel:vip(),
            }
            -- ChatModel:updatePrivateMessage(_item)
        end
        
    end
end


function FriendListView:allGetSp()
    local function _callback(_param)
        if (_param.result ~= nil) then
            -- dump(_param.result.data,"一键领取体力返回数据",8)
            if (_param.result.data.sp > 0) then
                local _achieveInfo = GameConfig.getLanguage("tid_friend_sp_detail_1023");
                -- //获取了多少体力,还剩余多少体力
            	-- //获取了多少体力,还剩余多少体力
               	local  _oneSp=FuncDataSetting.getDataByConstantName("FriendGift");
               	local _maxSpNum = FuncDataSetting.getDataByConstantName("ReceiveTimes")*_oneSp;
            	-- //体力上限
               	local   _achieveCount=CountModel:getCountByType(FuncCount.COUNT_TYPE.COUNT_TYPE_ACHIEVE_SP_COUNT)*_oneSp;
               	local data = FriendModel:getFriendList()
                local rids = _param.result.data.rids
               	for _index = 1, #data do
                    local  item = data[_index];
                    if item.hasSp then
                        if rids then
                            for k,v in pairs(rids) do
                                if v ==  item._id then
                                   	local _cell = self.scroll_list3:getViewByData(data[_index]);
                                    if _cell ~= nil then
                                        _cell.btn_2:setVisible(false)
                                        _cell.panel_yilingqu:setVisible(true)
                                    end
                                    -- local sprite = UIBaseDef:cloneOneView(_cell.panel_yilingqu):getChildren()[1];
                                    -- PlayStampAnimation(self,sprite,_cell.ctn_donghua2,_cell.ctn_donghua2,_cell.panel_yilingqu);
                                    local  _other_item = item
                                    _other_item.hasGetSp = true;
                                    item.hasSp = nil
                                end
                            end
                        end
                    end
                end


               WindowControler:showTips(_achieveInfo:format(_param.result.data.sp, _maxSpNum - _achieveCount));
            else
                local needCount=0;
                local _maxSpNum = FuncDataSetting.getDataByConstantName("HomeCharBuySPMax");
                local  _oneSp = FuncDataSetting.getDataByConstantName("FriendGift");
                if(UserExtModel:sp()+_oneSp>_maxSpNum)then--//体力超上限
                    WindowControler:showTips(GameConfig.getLanguage("tid_friend_achieve_sp_reach_limit_1044"):format(_maxSpNum));
                else
                    WindowControler:showTips(GameConfig.getLanguage("tid_friend_achieve_sp_to_limit_1047"));
                end
            end
            self:setButtonRed()
        else
            echo("---FriendMainView:clickButtonOneKeyAchieveSp-----", _param.error.code, _param.error.message);
            local _tipMessage = GameConfig.getLanguage("tid_friend_achieve_sp_failed_1024");
            if (_param.error.message == "friend_sp_times_max") then
                -- //已经达到体力上限
                _tipMessage = GameConfig.getLanguage("tid_friend_self_sp_reach_limit_1025");
            elseif (_param.error.message == "friend_sp_not_exists") then
                _tipMessage = GameConfig.getLanguage("tid_friend_can_not_achieve_sp_1026");
            end
            WindowControler:showTips(_tipMessage);
        end
    end
    if FriendModel:spIsGetAll() then
        local param = { };
        param.isAll = 1;
        FriendServer:achieveFriendSp(param, _callback);
    else
        WindowControler:showTips(GameConfig.getLanguage("tid_friend_no_sp_achieve_1040"))--"#tid_chat_006"))
    end
end

return FriendListView;