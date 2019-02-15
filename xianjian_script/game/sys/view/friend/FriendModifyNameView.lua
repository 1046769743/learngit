-- //玩家修改自己的签名
-- //2016-4-25
local FriendModifyNameView = class("FriendModifyNameView", UIBase);

function FriendModifyNameView:ctor(_winName,_super_class)
    FriendModifyNameView.super.ctor(self, _winName);
    self.super_class = _super_class;
    self.originText = "";
end
function FriendModifyNameView:loadUIComplete()
    self:registerEvent();
    self.input_1:setAlignment("left", "up")
end
-- //register
function FriendModifyNameView:registerEvent()
    FriendModifyNameView.super.registerEvent(self);
    self:registClickClose("out");
    self.UI_comp_tc2.btn_close:setTap(c_func(self.clickButtonCancel, self));
    self:setContent();
end
-- //base event none
-- //
function FriendModifyNameView:setContent()
    -- //标题
    --         local     _content=FuncTranslate.getLanguage("#tid3391028","zh_CN");
    --        self.txt_2:setString(_content);
    self.UI_comp_tc2.txt_1:setString(GameConfig.getLanguage("tid_friend_sign_1001"));
    -- //如果玩家还没有设置自己的签名
    --        local     _motto=FriendModel:getMotto();
    --        if(_motto~=_content)then
    --                    self.txt_1:setString(_motto);
    --       end

    self.originText = FriendModel.motto;
    -- //获取原始的签名
    if (self.originText ~= "") then
        -- //如果玩家已经有了签名
        self.input_1:setText(self.originText);
    end
    -- //register event
    self.UI_comp_tc2.mc_1.currentView.btn_1:setTap(c_func(self.clickButtonConfirm, self));
end
function FriendModifyNameView:clickButtonCancel()
    echo("-------FriendModifyNameView:clickButtonCancel--------");
    self:startHide();
end
function FriendModifyNameView:clickButtonConfirm()
    echo("-------FriendModifyNameView:clickButtonConfirm---------");
    local function _callback(_param)
        if (_param.result ~= nil) then
            WindowControler:showTips(GameConfig.getLanguage("tid_friend_modify_asign_1002"));
            -- //修改签名成功
            local _text = self.input_1:getText();
            FriendModel:setUserMotto(_text);
            self.super_class:setUserMotto();
            -- //刷新好友列表页面
            self:clickButtonCancel();
            -- //关闭窗口
        else
            echo("----FriendModifyNameView:clickButtonConfirm-----", _param.error.code, _param.error.message);
            local _tipMessage = GameConfig.getLanguage("tid_friend_modify_asign_failed_1003");
            if (_param.error.message == "ban_word") then
                -- //敏感字
                _tipMessage = GameConfig.getLanguage("tid_friend_ban_word_1004");
            elseif (_param.error.message == "string_illegal") then
                -- //非法字符
                _tipMessage = GameConfig.getLanguage("tid_friend_illegal_word_1005");
            end
            WindowControler:showTips(_tipMessage);
        end
    end
    local _text = self.input_1:getText();
--    if (string.len(_text) <= 0) then
--        -- //字符数目
--        WindowControler:showTips(GameConfig.getLanguage("tid_friend_assign_short_1007"));
--        return;
--    end
   local  _size=string.len4cn2(_text);
    if (_size > 30) then
        -- //签名超过了15汉字
        WindowControler:showTips(GameConfig.getLanguage("tid_friend_assign_long_1006"));
        return;
    end
--    if (_text == self.originText) then
--        -- //签名不能与原来的相同
--        WindowControler:showTips(GameConfig.getLanguage("tid_friend_assign_same_1008"));
--        return;
--    end
    local param = { };
    param.sign = _text;
    local isbadword,_text = Tool:checkIsBadWords(_text)
    if isbadword == true then
        _tipMessage = GameConfig.getLanguage("tid_friend_ban_word_1004");
        WindowControler:showTips(_tipMessage);
    else
        FriendServer:modifyUserMotto(param, _callback);
    end
end
-- //设置上层的类
function FriendModifyNameView:setSuperClass(_class)
    self.super_class = _class;
end
return FriendModifyNameView;
