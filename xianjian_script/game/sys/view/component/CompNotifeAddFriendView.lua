-- CompNotifeAddFriendView
--time  2017/05/16
-- wukai

local CompNotifeAddFriendView = class("CompNotifeAddFriendView", UIBase);

function CompNotifeAddFriendView:ctor(winName,data)
    CompNotifeAddFriendView.super.ctor(self, winName);
    self.data = data
    self.shengqingdata = false
    self.touaddbutton = nil
end

function CompNotifeAddFriendView:loadUIComplete()
	self:registerEvent()
    self.btn_close:setTap(c_func(self.button_Close,self))
    self.btn_1:setTap(c_func(self.button_Close,self))
    self.btn_2:setTap(c_func(self.addFriend,self))
    -- self:registClickClose(0, c_func( function()
    --         self:startHide()
    -- end , self))
    self:updateUI(self.data)
    -- self.btn_xianyujiahao:setTouchedFunc(c_func(self.clickGetWay, self));
end 
function CompNotifeAddFriendView:registerEvent()
    -- EventControler:addEventListener(UserEvent.USEREVENT_GARMENT_CHANGE, self.updateUI, self)
    EventControler:addEventListener("notify_friend_apply_request_2924",self.setaddfriendButton,self)
end
function CompNotifeAddFriendView:setaddfriendButton(_params)
dump(_params.params,"===好友申请变化======")
	self.shengqingdata = true
end
function CompNotifeAddFriendView:updateUI(data)
    local data = {}
	local playerdata = {
            playerLevel = data.level or 15,
            playerattribute = "上神",
            playername = data.name or "玩家名称",
            playernickname =  data.nicheng or data.mk or "",
            playerTitle =  "暂无称号",
            playerGuildname = "暂无仙盟",
            playerability = data.ability or 100000,
            LoginServer = data.sec or "dev",
            playersigned = "该玩家太懒,什么都没留下",
            playericon = data.avatar or 101,
            playerID = data._id or 1001,
            isFriend = data.friend or false,
        }
    local _node = self.ctn_1;
    local _icon = FuncChar.icon(tostring(playerdata.playericon));
    local _sprite = display.newSprite(_icon);
    local iconAnim = self:createUIArmature("UI_common", "UI_common_iconMask", _node, false, GameVars.emptyFunc)
    -- iconAnim:setScale(1.3)
    FuncArmature.changeBoneDisplay(iconAnim, "node", _sprite)
    self.txt_level:setString(playerdata.playerLevel)

    self.txt_1:setString(playerdata.playername)

    local _str = GameConfig.getLanguageWithSwap("tid_rank_1001", playerdata.playerability)
    
    self.txt_2:setString(_str)
    -- self.txt_3:setString()--推荐理由
end
function CompNotifeAddFriendView:addFriend()
	echo("===========加好友============")
    local isopen = FuncCommon.isjumpToSystemView(FuncCommon.SYSTEM_NAME.FRIEND)
    if not isopen then
        return 
    end
	local function _callback(_param)
        if (_param.result ~= nil) then
            -- WindowControler:showTips(GameConfig.getLanguage("tid_friend_approve_apply_1031"));
            WindowControler:showTips(GameConfig.getLanguage("#tid_chat_016"))
        else
            if (_param.error.message == "friend_count_limit") then
                    -- //好友已经达到上限
                    WindowControler:showTips(GameConfig.getLanguage("tid_friend_friend_count_limit_1030"));
            elseif (_param.error.message == "friend_exists" or _param.error.message=="friend_apply_not_exists") then
                    WindowControler:showTips(GameConfig.getLanguage("tid_friend_already_exist_1036"));
            end
        end
    end
    if self.touaddbutton== false then
       	if self.shengqingdata == true then
       		
            -- self.shengqingdata = false
            local param = { };
            param.fuid = self.data._id;
            param.isAll = 0;
            FriendServer:approveFriend(param, _callback);
            self.touaddbutton = true
        else
            local _param = { };
            _param.ridInfos = { };
            -- _param.rids[1] = self.data._id;
            local sce = FriendModel:getRidBySec(self.data._id) or  LoginControler:getServerId()
            _param.ridInfos[1]  = {[sce] = self.data._id}
            FriendServer:sendapplyFriend(_param)
            self.touaddbutton = true
       	end
    else
        WindowControler:showTips(GameConfig.getLanguage("tid_common_2028"))
    end
end


function CompNotifeAddFriendView:button_Close()
	self:startHide()
end



return CompNotifeAddFriendView





