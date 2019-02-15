

-- //购买体力,源文件被误删
-- //2016-4-22
local CompModifyNameView = class("CompModifyNameView", UIBase);

function CompModifyNameView:ctor(_winName,playerData)
    CompModifyNameView.super.ctor(self, _winName);
    self.playerData = playerData
    self.hasInit=false;
end
--
function CompModifyNameView:loadUIComplete()
	self:registClickClose("out");

    self:sendModifyNameToServer()
end
function CompModifyNameView:sendModifyNameToServer()
	self.UI_1.txt_1:setString(GameConfig.getLanguage("tid_common_2044")) 
	self.UI_1.btn_close:setTap(c_func(self.startHide,self));
	self.UI_1.mc_1:setVisible(false)

    -- self.btn_random_name:setTap(c_func(self.startHide,self));
    -- self.btn_random_name:visible(false)
    self.btn_confirm:setTap(c_func(self.DetermineModifyName,self))
    self.btn_cancel:setTap(c_func(self.startHide,self))
    self.input_name:setAlignment("left", "up")

end
--确定改名，发给服务器
function CompModifyNameView:DetermineModifyName()

	local text = self.input_name:getText()
	if text == "" or text == nil then
		WindowControler:showTips(GameConfig.getLanguage("tid_common_2026"))
		return 
	end
	
	-- self:startHide()

	local function _callback(_param)
		local sss = FriendModel:getFriendList()
		-- dump(sss,"11111111")
		-- dump(_param.result,"修改昵称服务器数据")
		if _param.result ~= nil then
			self.playerData.nicheng = text
			local data = {
				_id = self.playerData._id,
				name = text,
			}
			-- EventControler:dispatchEvent(FriendEvent.FRIEND_MODIFY_NAME,self.playerData)   --测试
			WindowControler:showTips(GameConfig.getLanguage("tid_common_2027"))
			FriendModel:setFriendNiCheng(data)
			FriendModel:upfriendData(data)
			EventControler:dispatchEvent(FriendEvent.FRIEND_MODIFY_NAME,self.playerData)   --成功就发改昵称
			self:startHide()
		end
	end

	
	local param = { };
    param.mark = text;
    param.fuid = self.playerData.uid
    local isbadword,text = Tool:checkIsBadWords(text)
    if isbadword == true then
        _tipMessage = GameConfig.getLanguage("tid_friend_ban_word_1004");
        WindowControler:showTips(_tipMessage);

    else
        -- FriendServer:modifyUserMotto(param, _callback);
        dump(param,"======修改昵称=====")
        FriendServer:modifyFriendname(param, _callback);
        -- self:startHide()
    end
end
--取消改名 
function CompModifyNameView:CancelModifyName()
	self:startHide()

end
--服务器返回的名字
function CompModifyNameView:SetName()
	-- self.input_1:setText()

end


return CompModifyNameView;
