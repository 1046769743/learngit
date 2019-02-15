local ConnRepeateView = class("ConnRepeateView", UIBase);

--[[
    self.txt_info,
]]

function ConnRepeateView:ctor(winName)
    ConnRepeateView.super.ctor(self, winName);
end

function ConnRepeateView:loadUIComplete()
	self:registerEvent();
end 


function ConnRepeateView:setCallFunc( func )
	self.callFunc = func
end

function ConnRepeateView:registerEvent()


	

end

function ConnRepeateView:startShow(  )

	self._isShow = true
	--ConnRepeateView.super.startShow(self)
	self:disabledUIClick()
	echo("_______开始显示------")
	self._root:visible(false)
	self:stopAllActions()
	--延迟10帧显示
	self:delayCall(c_func(self.showComplete, self),0.3)

end

function ConnRepeateView:showComplete()
	self:resumeUIClick()
	self._root:visible(true)
	self:registClickClose(nil ,c_func(self.pressClickView, self) )
end

function ConnRepeateView:pressClickView( )
	--
	self:startHide()

	if self.callFunc then
		local func = self.callFunc
		self.callFunc = nil
		func()
	else
		--重发当前请求
		Server:reSendRequest()
	end
end




function ConnRepeateView:updateUI()
	
end


return ConnRepeateView;
