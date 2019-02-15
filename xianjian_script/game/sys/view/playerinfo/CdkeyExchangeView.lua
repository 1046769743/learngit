--
--Author:      zhuguangyuan
--DateTime:    2017-07-14 10:10:27
--Description: 兑换码（此处无用）
--

local CdkeyExchangeView = class("CdkeyExchangeView", UIBase)

function CdkeyExchangeView:ctor(winName)
	CdkeyExchangeView.super.ctor(self, winName)
end

function CdkeyExchangeView:loadUIComplete()
	self:registerEvent()
end

function CdkeyExchangeView:registerEvent()
	self:registClickClose("out")
	self.UI_1.mc_1:setVisible(false)
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_cdkey_001")) 
	self.UI_1.btn_close:setTap(c_func(self.close, self))
	self.btn_confirm:setTap(c_func(self.tryExchangeCdkey, self))
end

function CdkeyExchangeView:tryExchangeCdkey()
	local cdkey = self.input_cdkey:getText()
	local ok,tip = FuncSetting.checkCdkeyStr(cdkey)
	if not ok then
		WindowControler:showTips(tip)
		return
	end

	if FuncSetting.checkIsPassCode(cdkey) then
		if string.len(cdkey) ~= 8 then
			WindowControler:showTips(FuncTranslate._getErrorLanguage("#error270301"))
		else
			UserServer:exchangePassCode(cdkey, c_func(self.onPassCodeExchangeOk, self))
		end
	else
		if string.len(cdkey) ~= 9 then
			WindowControler:showTips(FuncTranslate._getErrorLanguage("#error270104"))
		else
			UserServer:exchangeCdkey(cdkey, c_func(self.onCdkeyExchangeOk, self))
		end
	end	
end

function CdkeyExchangeView:onCdkeyExchangeOk(serverData)
	if not serverData or not serverData.result or not serverData.result.data then
		echo("error===", serverData.error.code)
		if serverData.error.code == 270109 then 
			WindowControler:showTips(GameConfig.getLanguage("#tid_cdkey_002"))
		end
		return
	end
	self:close()
	local rewards = serverData.result.data.reward
	WindowControler:showWindow("CdkeyExchangeResult", rewards)
end

function CdkeyExchangeView:onPassCodeExchangeOk(serverData)
	if not serverData or not serverData.result or not serverData.result.data then
		echo("error===", serverData.error.code)
		return
	end
	self:close()
	local rewards = serverData.result.data.reward
	WindowControler:showWindow("CdkeyExchangeResult", rewards)
end

function CdkeyExchangeView:close()
	self:startHide()
end

return CdkeyExchangeView

