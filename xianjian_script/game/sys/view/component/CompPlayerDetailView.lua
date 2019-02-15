-- //角色详情
-- //2016-5-11
-- //@author:xiaohuaxiong
local CompPlayerDetailView = class("CompPlayerDetailView", UIBase);
-- //tyope,type:1表示从世界聊天页面中进入
-- //_type:2表示从好友系统中进入
--//_type:3 表示从其他页面进入
-- //_callback回调函数
-- //传递给回调函数的参数
function CompPlayerDetailView:ctor(_winName, _params, _super_class, _type)
    CompPlayerDetailView.super.ctor(self, _winName);
    self.params = _params;
    dump(_params,"玩家数据")
    self.super_class = _super_class;
    self.ui_type = _type;
    self.yijingaddFriend = false
    self.vCallback=nil;--//回调函数
end
function CompPlayerDetailView:loadUIComplete()
    self.UI_1.mc_1:setVisible(false)
    self:registClickClose("out")
    -- self:panduanisMySelf()
    self:registerEvent();
    self:PlayerDataHandle(self.params)
    self:getfriendList()
    self.UI_1.txt_1:setString(GameConfig.getLanguage("chat_player_detail_1009"))

    -- echo("========uid===============",UserModel:uid())
    -- echo("========uid===============",UserModel:rid())
    


end
function CompPlayerDetailView:panduanisMySelf()
    local uid = tonumber(self.params._id)
    if  uid == UserModel:uid() then
        -- self.params.isRobot = true
    end

end
-- function CompPlayerDetailView:getFriendListByPage()
--     local function _callback(_param)
--         -- dump(_param.result,"1111111111111111111")
--         if (_param.result ~= nil) then
--             FriendModel:setFriendList(_param.result.data.friendList);
--         end
--     end
--     local param = {};
--     param.page = 1;
--     FriendServer:getFriendListByPage(param,_callback)
-- end
function CompPlayerDetailView:registerEvent()
    CompPlayerDetailView.super.registerEvent(self);

    EventControler:addEventListener(FriendEvent.FRIEND_MODIFY_NAME ,self.modifynameEvent,self)
    EventControler:addEventListener("notify_friend_Agreed_2928" ,self.refreshaddfriendbutton,self)
    self:registClickClose("out");
    self.UI_1.btn_close:setTap(c_func(self.clickButtonClose, self));

    GuildControler:getMemberList(_file)
    
end
function CompPlayerDetailView:refreshaddfriendbutton()
    
    self:getfriendList()
end
function CompPlayerDetailView:getfriendList()
    local function _callback(_param)
        -- dump(_param.result,"服务器数据")
        if (_param.result ~= nil) then
            FriendModel:setFriendList(_param.result.data.friendList);
            FriendModel:setFriendCount(_param.result.data.count);
            FriendModel:updateFriendSendSp(_param.result.data);
            self:playerisFriend(_param.result.data.friendList)
            -- echo("===========22222============",UserModel:rid())
        else
            WindowControler:showTips(GameConfig.getLanguage("tid_friend_no_enough_friends_1017"));
        end
    end
    local param = { };
    param.page = 1
    -- FriendServer:getFriendListByPage(param, _callback);


    local data =  FriendModel:getFriendList()
    -- -- dump(data,"好友列表")
    self:playerisFriend(data)

end
function CompPlayerDetailView:playerisFriend(data)
    -- local friendlist =  FriendModel:getFriendList()
    -- dump(data,"好友列表")
    local playerID =  self.params._id
    local name = "暂无昵称"
    self.isFriend = false
    if data ~= nil then
        if data ~= nil then
            for i=1,#data do
                local friendid =  data[i]._id 
                
                if playerID == friendid then
                    self.isFriend = true
                    if data[i].mk ~= nil then
                        name = data[i].mk 

                        self.txt_not:setString("("..name..")")
                    end
                end
            end
        end
    -- else
    --     dump(FriendModel:getFriendList(),"22222222222")
    --     if #FriendModel:getFriendList() ~= 0 then
    --         for k,v in pairs(FriendModel:getFriendList().friendList) do
    --             if   playerID == v._id then
    --                  name = v.mk
    --             end
    --         end
    --     end
    end
    if self.params.friend then
            self.isFriend = true
    end
    if self.params.isfriend then
            self.isFriend = true
    end
    if self.params.isFriend then
            self.isFriend = true
    end
    -- self.txt_not:setString(name)
    if self.isFriend then  
        self.mc_duo:getViewByFrame(1).btn_6:getUpPanel().txt_1:setString(GameConfig.getLanguage("tid_friend_remove_button_title_1043"))
        self.mc_duo:getViewByFrame(1).btn_6:setTap(c_func(self.closeFriend, self));
    else
        self.mc_duo:getViewByFrame(1).btn_6:getUpPanel().txt_1:setString(GameConfig.getLanguage("tid_friend_add_friend_first_1046"))
        self.mc_duo:getViewByFrame(1).btn_6:setTap(c_func(self.AddFriend, self));
    end
end
function CompPlayerDetailView:modifynameEvent(namedata)
    -- dump(namedata.params)
    local name = self.params.name
    if name == "" then
        name  = GameConfig.getLanguage("tid_common_2006")
    end
    local newname = namedata.params.nicheng
    local newnamestring = "("..newname..")"
    self.txt_1:setString(name)
    self.txt_not:setString(newnamestring)

end
function CompPlayerDetailView:PlayerDataHandle()
    

    local data = self.params
    if data.isRobot == true then
        self.mc_duo:showFrame(2)
    else
        if data.abilityNew ~= nil and type(data.abilityNew) == "table" then
            if data.abilityNew.formationTotal ~= nil then
                data.ability = data.abilityNew.formationTotal
            else
                data.ability = data.abilityNew.total
            end
        end
        self.mc_duo:showFrame(1)
    end
    if  data._id == UserModel:rid() then
        self.mc_duo:showFrame(2)
    end
    

    if data.name == "" then
        data.name  = GameConfig.getLanguage("tid_common_2006")
    end
    local sign = nil
    if data.userExt ~= nil then
        if data.userExt.sign ~= nil then
            sign = data.userExt.sign
        end

    end
    local title = ""
    if data.titles ~= nil then
        -- if type(data.title) == "table" then
            for k,v in pairs(data.titles) do
                title = tonumber(k)
            end
        -- else
        --     title = tonumber(data.title)
        -- end
    end
    local _crown = data.crown
    if not data.crown or data.crown == 0 then
        _crown = 1
    end
    local playerdata = {
            playerLevel = data.level or 100,
            playerattribute = "上神",
            playername = data.name or "少侠" ,
            playernickname =  data.nicheng or data.mk or "",
            playerTitle =  title or "",  --称号
            playerGuildname = data.guildName or "暂无仙盟",
            playerability = data.ability or 1356,
            LoginServer = data.sec or "dev",
            playersigned = sign or "该玩家太懒,什么都没留下",
            playeravatar = data.avatar or 101,
            playerID = data._id or 1001,
            isFriend = data.friend or false,
            crown = _crown,   ---头衔
            headid = data.head,
            frame = data.frame or "",

        }
    self:setviewData(playerdata)

end
--添加称号
function CompPlayerDetailView:addCharTitle(_ctn,titleid)
    local titleid = titleid --TitleModel:gettitleids()
    if titleid ~= "" then
        local titlesprite = FuncTitle.bytitleIdgetpng(titleid)
        local titlepng = display.newSprite(titlesprite)
        titlepng:setScale(0.8)
        _ctn:addChild(titlepng)
    end
end

function CompPlayerDetailView:setviewData(playerData)
    --玩头像
    local _node = self.ctn_1;
    -- local _icon = FuncChar.icon(tostring(playerData.playericon));
    -- local _sprite = display.newSprite(_icon);
    -- local iconAnim = self:createUIArmature("UI_common", "UI_common_iconMask", _node, false, GameVars.emptyFunc)
    -- -- iconAnim:setScale(1.3)
    -- FuncArmature.changeBoneDisplay(iconAnim, "node", _sprite)
    local  headid =  playerData.headid
    local  avatar = playerData.playeravatar
    local iconid = FuncUserHead.getHeadIcon(headid,avatar)
    local icon = FuncRes.iconHero( iconid )
    local iconSprite = display.newSprite(icon)
    local frame = playerData.frame or ""
    local frameicon = FuncUserHead.getHeadFramIcon(frame)
    local iconK = FuncRes.iconHero( frameicon )

    local frameSprite = display.newSprite(iconK)


      local headMaskSprite = display.newSprite(FuncRes.iconOther("partner_bagmask"))
    headMaskSprite:anchor(0.5,0.5)
    headMaskSprite:pos(0,0)
    -- headMaskSprite:setScale(0.99)
    local spritesico = FuncCommUI.getMaskCan(headMaskSprite,iconSprite)


    _node:removeAllChildren()
    _node:addChild(spritesico)
    _node:addChild(frameSprite)
    
    -- ChatModel:setPlayerIcon(_node,playerData.headid,playerData.playeravatar,0.9)




    --玩家等级
    self.txt_level:setString(playerData.playerLevel)
    --玩家属性称号
    -- self.txt_god:setString(playerData.playerattribute)
    --玩家名字和昵称结合
    local name = playerData.playernickname
    if name == "" or name == nil then
        name = "（暂无昵称）"
    else
        name = "("..name..")"
    end

    self.txt_1:setString(playerData.playername) ---玩家名字
    self.ctn_xmicon:setVisible(false)   --仙盟图标
    -- echo("=======length============",string.len(playerData.playername))
    local stringlen =  string.len(playerData.playername)
    local stringzifu = math.floor(stringlen/3)
    local stringzimu = math.fmod(stringlen,3)
    local numbers = 20
    if type(tonumber(playerData.playername))  ==  "number" then
        -- echo("==============",playerData.playername)
        local stringlen =  string.len(playerData.playername)
        numbers = stringlen * 6

    end
    
    --头衔 
    self.mc_god:showFrame(playerData.crown)

    self.txt_not:setString(name)
    self.txt_not:setPositionX(self.txt_1:getPositionX()+ stringzifu* numbers + stringzimu * 20 + 20)

    --玩家称号
    self.txt_2:setVisible(false)
    local titleid =  playerData.playerTitle
    if titleid ~= "" then
        self:addCharTitle(self.ctn_chenghao,titleid)
    else
        self.txt_2:setVisible(true)
        self.txt_2:setString(GameConfig.getLanguage("tid_common_2029"))
    end


    --总战力

    self.txt_4:setString(GameConfig.getLanguage("tid_common_2045")..(playerData.playerability or 0))
    --公会名称
    self.txt_6:setString(GameConfig.getLanguage("tid_common_2046")..playerData.playerGuildname)
    --最近登录的服务器
    if self.ui_type == 1 then
        local name = self:getservername(playerData.LoginServer)
        if name ~= nil then
            local _str = string.format(GameConfig.getLanguage("tid_common_2047"),name)
            self.txt_7:setString(_str)
        else
            self.txt_7:setVisible(false)
        end
    else
        self.txt_7:setVisible(false)
    end
    --玩家签名
    self.txt_8:setString(playerData.playersigned)

    -- 查看阵容按钮（未开启置灰）
    local lineupBtn = self.mc_duo:getViewByFrame(1).btn_1
    -- echo("================111111111111======",playerData.playerID, UserModel:rid())
    if playerData.playerID ~= UserModel:rid() then
        if LineUpModel:isLineUpOpen( self.params.level ) then
            -- FilterTools.clearFilter(lineupBtn)
            lineupBtn:setTap(c_func(self.SeeInformation, self));
        else
            FilterTools.setGrayFilter(lineupBtn)
        end
        
    else
        lineupBtn:setTap(c_func(self.SeeInformation, self));
    end

    -- self.mc_duo:getViewByFrame(1).btn_1:setTap(c_func(self.SeeInformation, self));
    self.mc_duo:getViewByFrame(1).btn_2:setTap(c_func(self.invitationAddGuild, self));
    self.mc_duo:getViewByFrame(1).btn_3:setTap(c_func(self.modifyname, self));

    -- self.mc_duo:getViewByFrame(1).btn_4:setTap(c_func(self.Invitationchallenge, self));

    
    --切磋按钮暂时未开通,暂时隐藏
    --self.mc_duo:getViewByFrame(1).btn_4:setTap(c_func(self.Invitationchallenge, self));
    self.mc_duo:getViewByFrame(1).btn_4:setVisible(false)
    self.mc_duo:getViewByFrame(1).btn_5:setPositionX(0)
    self.mc_duo:getViewByFrame(1).btn_6:setPositionX(179)

    self.mc_duo:getViewByFrame(1).btn_5:setTap(c_func(self.Privatechat, self));
    -- self.mc_duo:getViewByFrame(1).btn_6:setTap(c_func(self.AddFriend, self));
    self.mc_duo:getViewByFrame(2).btn_ok:setTap(c_func(self.isok, self));
end
function CompPlayerDetailView:getservername(sev)
    local serverlist =  LoginControler:getServerList()
    for k,v in pairs(serverlist) do
        if v._id == sev then
            return v.mark
        end
    end
end
function CompPlayerDetailView:isok()
    self:clickButtonClose()
end
--查看信息
function CompPlayerDetailView:SeeInformation()
    -- DelegateEventServer:getServerDelegateEventData()
    -- FriendViewControler:forceShowFriendList()
    -- WindowControler:showTips("正在努力研发查看信息")

    -- echo(LineUpModel:isLineUpOpen( self.params.level ))
    local systemname = FuncCommon.SYSTEM_NAME.LINEUP
    local isopen,level,typeid,lockTip,is_sy_screening =  FuncCommon.isSystemOpen(systemname)

    if isopen then
        LineUpViewControler:showMainWindow({
            trid = self.params._id,
            tsec = self.params.sec or LoginControler:getServerId(),
            formationId = FuncTeamFormation.formation.pve,
        })
        
        EventControler:dispatchEvent(ChatEvent.REMOVE_CHAT_UI)
    else
        if is_sy_screening then
            WindowControler:showTips(FuncCommon.screeningstring);
        end
    end
end
--邀请加入公会
function CompPlayerDetailView:invitationAddGuild()
    -- local partnerserverdata = PartnerModel:getAllPartner()
    -- dump(partnerserverdata,"1111111111")
    -- WindowControler:showTips("正在努力研发仙盟")  
    -- local serverlist =  LoginControler:getServerList()
    -- dump(serverlist,"服务器数据列表")
    if self.sendinvite then
        WindowControler:showTips(GameConfig.getLanguage("#tid_guild_007"))
        return 
    end
    local isaddGuild = GuildModel:isInGuild()
    if not isaddGuild then
        WindowControler:showTips(GameConfig.getLanguage("#tid_guild_008"))  
        return 
    end

    local playerId = self.params._id
    local guildData =  GuildModel:getMemberInfo(playerId)
    if guildData ~= nil then
        WindowControler:showTips(GameConfig.getLanguage("#tid_guild_task_4008"))
    else
        local function callback(param)
            if (param.result ~= nil) then
                dump(param.result,"邀请返回数据",8)
                WindowControler:showTips(GameConfig.getLanguage("#tid_guild_007"))
                self.sendinvite = true
            end
        end

        local params = {
            id = playerId,
        };  
        GuildServer:inviteMember(params,callback)
    end
end
--修改昵称
function CompPlayerDetailView:modifyname()

    if self.isFriend then
        WindowControler:showWindow("CompModifyNameView",self.params)
    else
        WindowControler:showTips(GameConfig.getLanguage("#tid_guild_009"))
    end
end
--切磋
function CompPlayerDetailView:Invitationchallenge()
    -- DelegateEventServer:completeDelegateEvent()
    WindowControler:showTips(GameConfig.getLanguage("tid_common_2048")) 
    -- DelegateEventServer:qualityLevelUp(nil)
end

--删除好友
function CompPlayerDetailView:closeFriend()
    local isopen = FuncCommon.isjumpToSystemView(FuncCommon.SYSTEM_NAME.FRIEND)
    if not isopen then
        return 
    end

    if self.ui_type  ~= 2 then
        self:setChatSuperClass(self.super_class);
        local function callback(param)
            if (param.result ~= nil) then
                self:startHide();
                WindowControler:showTips(GameConfig.getLanguage("tid_friend_remove_friend_ok_1042"));
                EventControler:dispatchEvent(FriendEvent.FRIEND_REMOVE_SOME_PLAYER,self.params._id);
                EventControler:dispatchEvent(ChatEvent.FRIEND_REMOVE_ONE_PLAYER,self.params._id);
                FriendModel:removeFriend(self.params._id)
                -- self:getfriendList()
                ChatModel:removemseeage(self.params._id)
                 
            elseif (param.error.message == "friend_not_exists") then
                -- //好友不存在
                WindowControler:showTips(GameConfig.getLanguage("#tid_guild_010"))--GameConfig.getLanguage("tid_friend_not_exist_1021"));
                -- //不会有另一个错误 
            end
        end
        local _param = { }
        _param.fuid = self.params.uid--_id;
        -- echo("=========删除好友的UID===========",self.params.uid)
        -- dump(_param,"删除好友结构")
        FriendServer:removeFriend(_param, callback);
    else
        self:setFriendClass(self.super_class);
        --好友界面调用
        local function callback(param)
            if (param.result ~= nil) then
                WindowControler:showTips(GameConfig.getLanguage("tid_friend_remove_friend_ok_1042"));
                local _friend_class = self.friendClass;
                 
                if FriendModel.friendCount ~= nil then
                    FriendModel.friendCount = FriendModel.friendCount - 1
                    if FriendModel.friendCount < 0 then
                        FriendModel.friendCount = 0
                    end
                end
                FriendModel:removeFriend(self.params._id)
                EventControler:dispatchEvent(FriendEvent.FRIEND_REMOVE_SOME_PLAYER,self.params._id);
                self:startHide();
                -- //调用好友系统中的刷新函数
                -- _friend_class:clickButtonFriendList();
            elseif (param.error.message == "friend_not_exists") then
                -- //好友不存在
                WindowControler:showTips(GameConfig.getLanguage("#tid_guild_010"))--GameConfig.getLanguage("tid_friend_not_exist_1021"));
                -- //不会有另一个错误
            end
        end
        local _param = { }
        _param.fuid = self.params.uid--_id;
        -- dump(_param,"删除好友结构")
        FriendServer:removeFriend(_param, callback);
    end
end
--私聊
function CompPlayerDetailView:Privatechat()
    local isopen = FuncCommon.isjumpToSystemView(FuncCommon.SYSTEM_NAME.CHAT)
    if isopen then
        -- //关闭自身,同时调用私聊页面
        local chatClass = self.chatClass;
        -- //将于对象玩家的聊天信息加入到缓存中
        local player = self.params;
        player.rid = player._id;
        local  _ui_type=self.ui_type;
        -- dump(player,"私聊玩家数据")
        
        ChatModel:insertOnePrivateObject(player);
        self:startHide();
         local chattype = 1
        if self.isFriend or player.friend then
            chattype = 2 
        end
        local Windownames =  WindowControler:getWindow( "ChatMainView" )
        if Windownames ~= nil then
            Windownames:showChattypeUI(5,chattype,self.params._id)
        else
            local _chat_ui = WindowControler:showWindow("ChatMainView", 5,chattype,self.params._id);
        end
    end
end
--加好友
function CompPlayerDetailView:AddFriend()
    local isopen = FuncCommon.isjumpToSystemView(FuncCommon.SYSTEM_NAME.FRIEND)
    if not isopen then
        return 
    end

    --//是否好友数目已经满了
    local  _max_friend_count=FuncDataSetting.getDataByConstantName("FriendLimit");
    local  _friend_count=FriendModel:getFriendCount();
    if(_friend_count>=_max_friend_count)then
         WindowControler:showTips(GameConfig.getLanguage("tid_friend_self_friend_count_reach_limit_1046"));
         return;
    end
    local function callback(param)
        dump(param.result,"申请添加为好友返回数据")
        if (param.result ~= nil) then
             if param.result.data.friendAdd == 1 then
                WindowControler:showTips(GameConfig.getLanguage("#tid_guild_011"))
                return 
            else   ---等于0 是其他请况

            end
            if param.result.data.count ~= 0 then
                WindowControler:showTips(GameConfig.getLanguage("tid_friend_send_request_1015"));
                EventControler:dispatchEvent(FriendEvent.FRIEND_INFORMATION_REQUEST,self.params)
            else
                -- self:refreshaddfriendbutton()
                -- FriendModel:updateFriendApply(param.result.data)
                FriendModel:setfriendApplyCount()
                WindowControler:showTips(GameConfig.getLanguage("#tid_guild_012"))
            end
        elseif (param.error.message == "friend_exists") then 
            WindowControler:showTips("tid_friend_already_exist_1036");
        elseif (param.error.message == "friend_count_limit") then
            -- //好友已经达到上限
            WindowControler:showTips(GameConfig.getLanguage("tid_friend_friend_count_limit_1030"));
        else
            WindowControler:showTips(GameConfig.getLanguage("tid_friend_send_request_failed_1016"));
        end
    end
    local   _open,_level=FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.FRIEND);
        local   _user_level=UserModel:level();
        if(_user_level<_level)then
                 WindowControler:showTips(GameConfig.getLanguage("chat_common_level_not_reach_1014"):format(_level));
                 return;
        end
    local _param = { };
    _param.ridInfos = {}
    -- _param.ridInfos[1] = {}
    local sce = self.params.sec or LoginControler:getServerId()
    _param.ridInfos[1] = {[sce] = self.params._id}
    FriendServer:applyFriend(_param, callback);

end
function CompPlayerDetailView:clickButtonClose()
    self:startHide();
end

function CompPlayerDetailView:setAfterApplyCallback(_callback,_class)
    self.vCallback=_callback;
    self.vClass=_class;
end
-- //设置上层调用,聊天页面中,调用私聊页面
function CompPlayerDetailView:setChatSuperClass(_super_class)
    self.chatClass = _super_class;
end
-- //设置聊天系统的引用
function CompPlayerDetailView:setFriendClass(_class)
    self.friendClass = _class;
end

return CompPlayerDetailView;