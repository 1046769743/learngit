--[[
	guan
	2016.4.25
]]

local GMEnterView = class("GMEnterView", UIBase);

--[[
    self.panel_3.mc_1,
    self.panel_3.mc_2,
]]

function GMEnterView:ctor(winName)
    GMEnterView.super.ctor(self, winName);
    self._isMoved = false;
    self.lastX = 0
    self.lastY =0
end

function GMEnterView:loadUIComplete()
	self:registerEvent();

    self:updateUI()
end 

function GMEnterView:registerEvent()
	GMEnterView.super.registerEvent();

    EventControler:addEventListener(AppInformation.APP_VERSION_CHANGE, self.updateUI,self)

    self.panel_3:setTouchedFunc(c_func(self.showOrHideLogsView,self),nil,true);
    FuncCommUI.dragOneView(self)
end

function GMEnterView:updateUI()  
    self.panel_3.mc_1:getCurFrameView().txt_1:setString("gm-v" .. AppInformation:getVersion() or "test")
end


-- 显示或关闭logsView
function GMEnterView:showOrHideLogsView()
	echo("showOrHideLogsView");

    if not LoginControler:isLogin() then
        WindowControler:showTips({text = "请登入后在点开GM 命令"})
        return
    end

    if BattleControler:isInBattle() then
        WindowControler:showTips({text = "亲,战斗中不允许点GM命令"})
        return
    end

	if self._isMoved == false then 
		WindowControler:showTopWindow("TestConnView");
	end 
	self._isMoved = false;
end

return GMEnterView;
