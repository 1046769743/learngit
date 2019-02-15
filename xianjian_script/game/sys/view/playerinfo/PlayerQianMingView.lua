--
--Update:      zhuguangyuan
--DateTime:    2017-07-12 13:12:02
--Description: 签名视图
--
local PlayerQianMingView = class("PlayerQianMingView", UIBase)

function PlayerQianMingView:ctor(winName)
    PlayerQianMingView.super.ctor(self, winName)
end

function PlayerQianMingView:loadUIComplete()
    self:registerEvent()
    -- 如果没有 用默认的
--  self.input_name:setString("用默认的")
    self.input_name:setInputEndCallback(c_func(self.hideEnterNewNameTxt, self))
    self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_playerInfo_007")) 
    self.input_name:setAlignment("left", "up")
end

-- 用户点击输入框进行输入
-- 输入完成后返回 若输入不为空 隐藏掉提示
function PlayerQianMingView:hideEnterNewNameTxt(  )
    if self.input_name:getText() == "" or self.input_name:getText() == " " then
        return
    end
    
    self.txt_xx:setVisible(false)
end

function PlayerQianMingView:registerEvent()
    if UserModel:isNameInited() then
        self:registClickClose("out")
        self.UI_1.btn_close:setTap(c_func(self.close, self))
    end
    self.btn_confirm:setTap(c_func(self.onQianmingConfirm, self))
    self.UI_1.mc_1:visible(false)    
end

function PlayerQianMingView:onQianmingConfirm()
    local qianming = self.input_name:getText()
    if qianming == "" then  --输入为空则使用默认的签名
        WindowControler:showTips( GameConfig.getLanguage("#tid_playerInfo_008"))
        return
    end
    -- qianming = string.subcn(qianming,1,15)

    --回调函数
    local function _callback(_param)
        if (_param.result ~= nil) then
            WindowControler:showTips(GameConfig.getLanguage("#tid_playerInfo_009"));
            -- //修改签名成功
            --local _text = self.input_name:getText(); 注释掉by zhuguangyuan 
            EventControler:dispatchEvent(UserEvent.USER_CHANGE_QIAN_MING_EVENT)
            
            self:close()
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

    --检查是否包含敏感字符，再决定是否发往服务器
    local param = { };
    param.sign = qianming;
    echo("\n\nqianming===len===", string.lenword(qianming))
    local isbadword,qianming = Tool:checkIsBadWords(qianming)
    if isbadword == true then
        local _tipMessage = GameConfig.getLanguage("tid_friend_ban_word_1004");
        WindowControler:showTips(_tipMessage);
    elseif string.lenword(qianming) > 15 then
        WindowControler:showTips(GameConfig.getLanguage("tid_friend_assign_long_1006"))
    else
        FriendServer:modifyUserMotto(param, _callback);
    end
end

function PlayerQianMingView:close()
    self:startHide()
end

return PlayerQianMingView

