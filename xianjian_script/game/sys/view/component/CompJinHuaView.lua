-- CompJinHuaView

-- //神器精华

local CompJinHuaView = class("CompJinHuaView", UIBase);

function CompJinHuaView:ctor(_winName)
    CompJinHuaView.super.ctor(self, _winName);
    self.hasInit=false;
end
--
function CompJinHuaView:loadUIComplete()
	CompJinHuaView.super.loadUIComplete(self)
	self.btn_xianyujiahao:setTap(c_func(self.getpathview,self))

	self:registerEvent();
	self:setupdataUI()
end
function CompJinHuaView:registerEvent()

	EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.setupdataUI, self)
	EventControler:addEventListener(LoginEvent.LOGINEVENT_LOGIN_UPDATE_MODEL_COMPLETE, self.setupdataUI, self)
end

function CompJinHuaView:getpathview()
		-- WindowControler:showTips("获取途径暂未开启")
	WindowControler:showWindow("GetWayListView",FuncDataResource.RES_TYPE.CIMELIACOIN)
end
function CompJinHuaView:setupdataUI()
	local number = UserModel:getCimeliaCoin() or 0 
	if number == nil then
		number = 0
	end
	self.txt_1:setString(number)
end
function CompJinHuaView:clickButtonClose()
    self:startHide();
end


return CompJinHuaView;
