--
-- Author: ZhangQiang
-- Date: 2016-07-07
-- 断网提示界面

local CompServerOverTimeTipView = class("CompServerOverTimeTipView", UIBase);

function CompServerOverTimeTipView:ctor(winName,_other_ui)
    CompServerOverTimeTipView.super.ctor(self, winName);
    self.callFuncArr = {}
    self.other_ui=_other_ui

    -- 暂停新手引导
    -- EventControler:dispatchEvent(TutorialEvent.TUTORIAL_SET_PAUSE, {ispause = true})
end

function CompServerOverTimeTipView:loadUIComplete()
	self:registerEvent()
    self:initData()

    if(self.other_ui)then
          self:showPlayerOfflineTips()
    else
         self:updateUI()
    end

    
end 

function CompServerOverTimeTipView:setTipContent(tipContent)
    self.tipContent = tipContent
    self:updateUI()
end

function CompServerOverTimeTipView:initData()
    self.tipContent = GameConfig.getLanguage("tid_common_2014")
    if not PCSdkHelper:checkNetWorkPermission() then
        -- 已为"#1"关闭网络使用权限您可以在“设置”中为此应用打开网络权限
        self.tipContent = GameConfig.getLanguageWithSwap("tid_common_2074",AppInformation:getGameDisplayName())
    end
end

function CompServerOverTimeTipView:registerEvent()
	CompServerOverTimeTipView.super.registerEvent();
    self.UI_1.mc_1.currentView.btn_1:setTap(c_func(self.press_btn_1, self));
    self.UI_1.mc_1.currentView.btn_1:setClickPriority(GameVars.clickPriorityMap.overGuide)
    self.UI_1.btn_close:setVisible(false)
    self.UI_1.btn_close:setTap(c_func(self.close,self))
    self.UI_1.btn_close:setClickPriority(GameVars.clickPriorityMap.overGuide)
end

function CompServerOverTimeTipView:updateUI()
    self.UI_1.txt_1:setString(GameConfig.getLanguage("tid_common_2013"))
    self.txt_1:setString(self.tipContent)

    if device.platform == "ios" then
        local newX = self.rich_1:getPositionX() + 20
        self.rich_1:setPositionX(newX)

        self.rich_1:setTouchedFunc(c_func(self.onClickGetSolution,self))
    else
        self.rich_1:setVisible(false)
    end
end

function CompServerOverTimeTipView:onClickGetSolution()
    WindowControler:showHighWindow("CompNetworkSolutionList")
end

--//提示玩家当前已经被挤掉线
function CompServerOverTimeTipView:showPlayerOfflineTips()
   self.UI_1.txt_1:setString(GameConfig.getLanguage("tid_player_offline_tips"));
   self.txt_1:setString(GameConfig.getLanguage("tid_player_offline_cause"))
end

-- isGoLogin 是否回到登录界面
function CompServerOverTimeTipView:setCallFunc( func,isGoLogin,errorInfo)
    self.isGoLogin = isGoLogin

    if #self.callFuncArr > 0 then
        echo("__当前重连函数数量:"..#self.callFuncArr)
    end
    if func then
        table.insert(self.callFuncArr,func)
    end

    if errorInfo and errorInfo.code then
        local message = FuncTranslate.getServerErrorMessage(errorInfo)
        self:setTipContent(message)
        -- 如果是封禁账号
        if tonumber(errorInfo.code) == ErrorCode.account_forbided then
            self.rich_1:setVisible(false)
        end
    end

    
end
--这个是确定按钮的回调
function CompServerOverTimeTipView:press_btn_1()
    echo("确定按钮的回调PrologueUtils:showPrologue()=",PrologueUtils:showPrologue());
    self:startHide()

    -- 如果是序章中
    -- 1.请求序章标记接口如果onClose
    if PrologueUtils:showPrologue() then
        return
    end

    if (BattleControler:isInBattle() and BattleControler.isDebugBattle ) then
        return
    end

    -- 如果在登录界面中，且是一键返回登录，不执行回调，直接return
    if LoginControler:isInLoginView() and self.isGoLogin then
        Server:handleClose()
        return
    end

	if #self.callFuncArr > 0 then
        local tempArr = table.copy(self.callFuncArr)

        --做回调
        for i,v in ipairs(tempArr) do
            v()
        end
        
  --       echo("确定按钮的回调 1");
		-- local func = self.callFunc
		-- self.callFunc = nil
		-- func()
	else
        echo("确定按钮的回调 2");
		--重发当前请求
		Server:reSendRequest()
	end
end


function CompServerOverTimeTipView:close()
	self:startHide()
end

return CompServerOverTimeTipView;
