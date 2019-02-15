
-- //购买体力,源文件被误删
-- //2016-4-22
local CompXiaYiView = class("CompXiaYiView", UIBase);

function CompXiaYiView:ctor(_winName)
    CompXiaYiView.super.ctor(self, _winName);
    self.hasInit=false;
end
--
function CompXiaYiView:loadUIComplete()
	CompXiaYiView.super.loadUIComplete(self)
	self.btn_xianyujiahao:setTap(c_func(self.getpathview,self))

	self:registerEvent();
	self:setupdataUI()
end
function CompXiaYiView:registerEvent()

	EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.setupdataUI, self)
	EventControler:addEventListener(LoginEvent.LOGINEVENT_LOGIN_UPDATE_MODEL_COMPLETE, self.setupdataUI, self)
end

function CompXiaYiView:getpathview()
		-- WindowControler:showTips("获取途径暂未开启")
	WindowControler:showWindow("GetWayListView",FuncDataResource.RES_TYPE.CHIVALROUS)
end
function CompXiaYiView:setupdataUI()
	local number = UserModel:getRescueCoin()
	if number == nil then
		number = 0
	end
	self.txt_xianyu:setString(number)
end
function CompXiaYiView:clickButtonClose()
    self:startHide();
end


return CompXiaYiView;
