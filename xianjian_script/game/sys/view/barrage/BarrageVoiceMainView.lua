-- BarrageVoiceMainView
-- Aouth wk
-- time 2018/1/30

local BarrageVoiceMainView = class("BarrageVoiceMainView", UIBase);



function BarrageVoiceMainView:ctor(winName)
    BarrageVoiceMainView.super.ctor(self, winName);
    self.Leafsign_index = FuncChat.BarrageType
    self.blacklayer = FuncRes.a_black(1,1,110)--GameVars.width,GameVars.height,200)
    self.blacklayer:anchor(0,1)
    local fScaleX = GameVars.width
    local fScaleY = GameVars.height
    self.blacklayer:setScaleX(fScaleX)
    self.blacklayer:setScaleY(fScaleY)
    self.blacklayer:setPositionX(-400)--GameVars.UIbgOffsetX)
    self.blacklayer:setPositionY(100)--GameVars.UIbgOffsetX)
    self:addChild(self.blacklayer)
end

function BarrageVoiceMainView:setAllData(system,alldata)
    --dump(system,"111111111111111111")
    self.system = system
    self.alldata = alldata
    self:initView()

    BarrageModel:setVoiceTypeAndData(self.alldata,self.system)
end



function BarrageVoiceMainView:loadUIComplete()


	
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_1,UIAlignTypes.MiddleTop);

	self:registerEvent();
	self.UI_spake:setVisible(false)

	


	self:showComplete()
	self:clickButtonBack()

end 

function BarrageVoiceMainView:registerEvent()
	 EventControler:addEventListener(PCSdkHelper.EVENT_SCREEN_ORIENTATION ,self.screenRotation,self)
end

function BarrageVoiceMainView:initView()
	local panel = self.panel_1
	self.offAndON = BarrageModel:getoffAndONBysystem(self.system)  --弹幕是不是开启
    echo("=========self.offAndON=======",self.offAndON,type(self.offAndON))
	local barrageButton = panel.panel_kai
	self:onAndOff()
	--- 弹幕开关
	barrageButton:setTouchedFunc(c_func(self.onAndOff, self),nil,true);
	--- 图标按钮
	panel.btn_bq:setTouchedFunc(c_func(self.iconButton, self),nil,true);

    -- if  UserModel:vip()  < 5 then
    --     panel.btn_bq:getUpPanel().panel_lock:setVisible(true)
    -- else
        panel.btn_bq:getUpPanel().panel_lock:setVisible(false)
    -- end

	--发送按钮
    panel.btn_bq:setVisible(true)
	panel.mc_1:showFrame(1)
    if self.system ==  FuncBarrage.SystemType.crosspeak then
	   panel.mc_1:getViewByFrame(1).btn_1:setTouchedFunc(c_func(self.sendCrosspeakButton, self),nil,true);
    elseif self.system ==  FuncBarrage.SystemType.plot then
        panel.mc_1:getViewByFrame(1).btn_1:setTouchedFunc(c_func(self.sendPlotButton, self),nil,true);
        panel.btn_bq:setVisible(false)
    end




	self:addVoicebutton()

end
---发送到剧情
function BarrageVoiceMainView:sendPlotButton()
    local _text = self:getText()
    if _text == nil then
        return 
    end 

    local isok = self:panduanItem()
    if not isok then
        return 
    end
    local function callfun()
        local panel = self.panel_1
        panel.input_1:setText("");
    end
    
    local level = FuncDataSetting.getOriginalData("PlotDanmu")
    if not(UserModel:level() >= level) then 
        local arrData = {
            comment = _text or "",--聊天信息
            istouch = false,--是否可以点击
            praiseNum = 0,--赞的数量‘
            myPraise = 0,---自己是否赞过
            systemName = "plot",
            diifID = self.alldata.plotData.plotID,
            postId = self.alldata.plotData.order,
            time = TimeControler:getServerTime(),
        }

        WindowControler:showTips("发送成功")
        EventControler:dispatchEvent(BarrageEvent.BARRAGE_SEND_PLOT_MYSELF_EVENT,arrData)
        callfun()
        return
    end
    -- dump(self.alldata,"1111111111")

    local arrData = {
        plotID = self.alldata.plotData.plotID,
        _text = _text,
        order = self.alldata.plotData.order or 1,
    }
    BarrageModel:sendContentToServer(arrData,callfun)


end

function BarrageVoiceMainView:getText()
    local panel = self.panel_1
    local _text = panel.input_1:getText()
    local  _other_size = string.len4cn2(_text);
    if _other_size <= 0 then--//字数过少
        WindowControler:showTips(GameConfig.getLanguage("chat_words_too_little_1002"));
        return;
    end
    if _other_size > 30 then
        WindowControler:showTips(FuncBarrage.TextString)--GameConfig.getLanguage("chat_words_too_little_1002"));
        return 
    end
    if string.find(_text," ") ~= nil then
        WindowControler:showTips("输入了非法字符，请重新输入！"); 
        return 
    end

    return _text
end

function BarrageVoiceMainView:sendCrosspeakButton()

    local _text = self:getText()
    if _text == nil then
        return 
    end 
    -- local panel = self.panel_1
    -- local texts = panel.input_1:getText()
    -- if string.find(texts," ") ~= nil then
    --     WindowControler:showTips("输入了非法字符，请重新输入！"); 
    --     return 
    -- end


    local panel = self.panel_1
    local function callback(param)
        if(param.result~=nil)then--//没有其他操作

        	WindowControler:showTips("发送成功");
        	FilterTools.setGrayFilter(panel.mc_1:getViewByFrame(1).btn_1)
        	panel.mc_1:getViewByFrame(1).btn_1:setTouchedFunc(c_func(self.sendInCD, self),nil,true);
        	self:delayCall(function ()
        		if panel then
        			if panel.mc_1 then
		        		FilterTools.clearFilter(panel.mc_1:getViewByFrame(1).btn_1)
		        		panel.mc_1:getViewByFrame(1).btn_1:setTouchedFunc(c_func(self.sendCrosspeakButton, self),nil,true);
		        	end
	        	end
        	end,FuncBarrage.SendItems)
        elseif (param.error.message=="string_illegal") then
            WindowControler:showTips(GameConfig.getLanguage("chat_illegal_word_1005"));
        elseif(param.error.message=="ban_word")then--//敏感词
            WindowControler:showTips(GameConfig.getLanguage("tid_friend_ban_word_1004"));
        elseif(param.error.message=="ban_chat")then--//被禁言
            WindowControler:showTips(GameConfig.getLanguage("chat_extra_forbid_chat_1001"));
        else

        end
    end


    BarrageModel:sendCrosspeakToServe(self.alldata,_text,callback)
end
function BarrageVoiceMainView:sendInCD()
	WindowControler:showTips("少侠请慢点说");
end



-- --图标显示位置
-- function BarrageVoiceMainView:iconButton()

-- end

----显示图片试图
function BarrageVoiceMainView:iconButton()

    -- if UserModel:vip()  < 5 then
    --     WindowControler:showTips(GameConfig.getLanguage("#tid_danmu_1"));
    --     return 
    -- end
	local panel = self.panel_1  
    local callback = function ( name )
        local  _text = panel.input_1:getText()
        _text = FuncChat.ruleOutText(_text)
        local    _size = string.len(_text);
        if _size > 0 then
            _text = _text..name
        else
            _text = name
        end
        local  _other_size = string.len4cn2(_text);
        if _other_size > 30 then
            WindowControler:showTips(FuncBarrage.TextString)--GameConfig.getLanguage("chat_words_too_little_1002"));
            return 
        end
       	panel.input_1:setText(_text);
       	self:removeIconUI()
    end
    if self.FriendEmailview == nil then
        self.FriendEmailview =  WindowControler:createWindowNode("ChatExpression")
        self.FriendEmailview:callbackiconname(callback)
        self.FriendEmailview:setPosition(cc.p(-465/2,0))
        self.panel_1.ctn_1:addChild(self.FriendEmailview)
    else
    	self:removeIconUI()
    end

end

function BarrageVoiceMainView:removeIconUI()
	self.panel_1.ctn_1:removeAllChildren()
	self.FriendEmailview = nil
end





--语音按钮
function BarrageVoiceMainView:addVoicebutton()

    local touchEndCallBack = function (event)
        if self.notvoice then
            self.notvoice = false
            return 
        end

        if not self.endtouch then
            self.endtouch = true
            self.UI_spake:setVisible(false)
            -- self:voiceButton()
            if self.ismove or self.isSendVoice then
                self.firsttouch = true
                return
            end
            echo("=========语音录制结束============")
            local iserror = self.UI_spake:endTiming(self.Leafsign_index)
            self:delayCall(function ()
                self.firsttouch = true
            end,FuncChat.touchClickInterval())
        end
    end

    local touchMoveCallBack = function (event)
        if self.notvoice then
            return
        end
        local movex = event.x
        local movey = event.y
        local offset = FuncChat.voiceMoveOffset()
        if not self.ismove then
            if math.abs(movex - self.firstPosX) >= offset or math.abs(movey - self.firstPosY) >= offset then
                self.ismove = true
                self.UI_spake:setVisible(false)
                self.UI_spake:moveEndSendVoice()
                -- EventControler:dispatchEvent(HomeEvent.HOME_VOICE_PLAY);
                WindowControler:showTips("取消发送");
            end
        end
    end
    local touchBeginCallBack = function (event)
         if device.platform == "windows" or device.platform =="mac" then
            WindowControler:showTips("该平台不支持语音");
            self.notvoice = true
            return 
        end

        local isok = self:panduanItem()

        if not isok then
            self.notvoice = true
            return 
        end

        self.firstPosX = event.x
        self.firstPosY = event.y
        if self.firsttouch then
            self.ismove = false
            self.isSendVoice = false
            self.firsttouch = false
            self.endtouch = false
            self.UI_spake:setVisible(true)
            self.UI_spake:startedTiming(self.Leafsign_index)
            -- AudioModel:stopMusic()--停止播放背景音乐
        end
    end
    self.firsttouch = true

    self.panel_1.panel_1:setTouchedFunc(GameVars.emptyFunc, nil, false, 
        touchBeginCallBack, touchMoveCallBack,
         isPlayComClick2Music, touchEndCallBack)
    -- self.mc_6:getViewByFrame(1).panel_1:setTouchedFunc(c_func(self.voiceButton,self),nil, true)
end


function BarrageVoiceMainView:panduanItem()
    if self.system ==  FuncBarrage.SystemType.plot then
        local system = BarrageModel:bySystemShowBarrage(self.system)
        local count = RankAndcommentsModel:getNumBySystemAndDiffID(system,self.alldata.plotData.plotID,self.alldata.plotData.order)
        local suncount =  FuncRankAndcomments.getCommentNumber(self.system)
        if count - suncount >= 0 then
            WindowControler:showTips("每个剧情对话允许评论两次")--FuncRankAndcomments.STR_EVERYDAY);
            return false
        end
    end
    return true
end
function BarrageVoiceMainView:onAndOff(event)
    -- self.system
	if self.offAndON  then
		self.panel_1.panel_kai.mc_1:showFrame(1)
		if event then
            self.panel_1.panel_kai.mc_1:showFrame(2)
			EventControler:dispatchEvent(BarrageEvent.BARRAGE_UI_IS_NOT_SHOW);
            self.offAndON = false
		end
	else
		self.panel_1.panel_kai.mc_1:showFrame(2)
		if event then
            self.panel_1.panel_kai.mc_1:showFrame(1)
			EventControler:dispatchEvent(BarrageEvent.BARRAGE_UI_IS_SHOW);
            self.offAndON = true
		end
	end
    if event then
        local _type = BarrageModel:bySystemShowBarrage(self.system)
        BarrageModel:setbarrageModeData(_type,self.offAndON)
    end
end

function BarrageVoiceMainView:showComplete( )
  BarrageVoiceMainView.super.showComplete(self);
  --//加入弹出动画
    local  _rect= self._root:getContainerBox();
    local  _otherx,_othery = self._root:getPosition();

    self._root:setPosition(cc.p(0,150));
    local  _mAction=cc.MoveTo:create(0.2,cc.p(0,0));
    self._root:runAction(_mAction);
end

	

function BarrageVoiceMainView:clickButtonBack()
    -- self:startHide();

    local function cellCallback()
    	self:_closeCallback()
    end

    local  function _callback()
    	self:removeIconUI()
		local  _root = self._root;
		local  _rect = _root:getContainerBox();
		local  _mAction = cc.MoveTo:create(0.2,cc.p(0,150));
		local  _mSeq = cc.Sequence:create(_mAction,cc.CallFunc:create(cellCallback));
		_root:runAction(_mSeq);

       
    end
    self:registClickClose("out",_callback);
end
function BarrageVoiceMainView:_closeCallback()
	if self then
		self:removeAllChildren()
        EventControler:dispatchEvent(BarrageEvent.BARRAGE_REMVOE_VOICE_UI);
	end

	self:startHide();
end

function BarrageVoiceMainView:screenRotation()
	if self.UI_spake:isVisible() then
        self.UI_spake:setVisible(false)
        self.UI_spake:moveEndSendVoice()
        EventControler:dispatchEvent(HomeEvent.HOME_VOICE_PLAY);
        WindowControler:showTips("取消发送");
    end
end


return BarrageVoiceMainView;
