--
--Author:      zhuguangyuan
--DateTime:    2017-09-11 10:29:18
--Description: 游戏玩家对游戏的反馈
-- 重整代码结构

local GameFeedBackView = class("GameFeedBackView", UIBase);

local INPUT_DEFAULT_HEIGHT = 150 -- 输入的最大字符长度
local FEED_BACK_STRING_LEN = 300
local FEED_BACK_INTERVAL = 300
function GameFeedBackView:ctor(winName, _data)
    GameFeedBackView.super.ctor(self, winName)
    self.feedBackTip = GameConfig.getLanguage("tid_common_2020")
    self.talkDatas = _data
end

function GameFeedBackView:loadUIComplete()
	echo(" GameFeedBackView:loadUIComplete  --------------------------------- ")
	local curTime = TimeControler:getServerTime()
	if LS:prv():get("isFirstEnter"..UserModel:rid()) then
		local lastTime = LS:prv():get("isFirstEnter"..UserModel:rid())
		if tonumber(self:getRefreshTime()) > tonumber(lastTime) and tonumber(curTime) > tonumber(self:getRefreshTime()) then
			LS:prv():set("isFirstEnter"..UserModel:rid(), curTime)
		end
	else
		LS:prv():set("isFirstEnter"..UserModel:rid(), curTime)
	end
	
	self.time = tonumber(LS:prv():get("isFirstEnter"..UserModel:rid()))
	self.maxFeedBackTime = 60
	self.maxFeedBackCount = 20
	self.feedBackMap = {}
	self.feedBackData = self:initReplyData(self.time)
	self.isBack = true
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_game_fankui_001")) 
	self:initViewAlign()	
	self.UI_talk:setVisible(false)
	self:initData()
	self:registerEvent()
	-- self:updateUI()
end 

function GameFeedBackView:initReplyData(_time)
	local feedBackData = {
		name = GameConfig.getLanguage("#tid_game_fankui_002"),
		_type = 2,
		content = self.feedBackTip,
		time = _time,
	}

	return feedBackData
end

function GameFeedBackView:getRefreshTime()
	 -- 处理四点刷新的事
    local curTime = TimeControler:getServerTime()
    local dates = os.date("*t", curTime)
    -- 每天几点几分刷新
    local targetH = FuncCount.getHour(FuncCount.COUNT_TYPE.COUNT_TYPE_SIGN_RECEIVE_RETIO)
    local targetM = FuncCount.getMinute(FuncCount.COUNT_TYPE.COUNT_TYPE_SIGN_RECEIVE_RETIO) or 0
    targetH = tonumber(targetH)
    targetM = tonumber(targetM)

    local oneDay = 24 * 60 * 60
    -- 当天对应时间的时间戳
    local todayTargetStamp = os.time({year=dates.year, month=dates.month, day=dates.day, hour=targetH, min = targetM})
    return todayTargetStamp
end


-- voice -- 聊天数据结构" = {
-- -     "avatar"  = 101
-- -     "content" = "1"
-- -     "level"   = 55
-- -     "name"    = "究极门侠客"
-- -     "rid"     = "dev_1872"
-- -     "time"    = 1512023971
-- -     "type"    = 1
-- -     "vip"     = 5
-- -     "zitype"  = 2
-- - }
--@@======================================================
function GameFeedBackView:initData()
	-- local params =  {
	-- 	uid = UserModel:uid(),
	-- 	platform = AppInformation:getAppPlatform(),
	-- 	fields = "status,uid,content,op_content,create_time,op_datetime,vip,rid"
	-- }
	-- local url = FuncSetting.FEEDBACK_URL
	-- local dateStr = os.date("%Y-%m-%d %X")
	-- local token = crypto.md5(string.format("PlayCrab%s%s", FuncSetting.FEEDBACK_PRIKEY, dateStr))
	-- local signature = string.format("PLAYCRAB %s:%s", FuncSetting.FEEDBACK_PUBKEY, token)
	-- --httpheader
	-- local headers = {
	-- 	string.format("Authorization: %s", signature),
	-- 	string.format("Date: %s", dateStr),
	-- }

	-- WebHttpServer:sendRequest(params, url, WebHttpServer.POST_TYPE.GET, headers, c_func(self.getFeedBack, self))

	-- 输入的内容
	self.content = ""
	self.input_content = self.panel_shuru.input_content

	local sortFunc = function (a, b)
		return tonumber(a.time) < tonumber(b.time)
	end

	table.insert(self.talkDatas, self.feedBackData)

	-- dump(self.talkDatas, "\n\nself.talkDatas==")
	table.sort(self.talkDatas, sortFunc)

	self:initView()
end

function GameFeedBackView:getFeedBack(serverData)
	if serverData.data and serverData.data.code ~= "403" then
		local data = serverData.data
		self.talkDatas = {}
		if data and table.length(data) > 0 then
			for i,v in ipairs(data) do
				if v.status == 1 then
					local talkData = {
						avatar = UserModel:avatar(),
						level = UserModel:level(),
						name = UserModel:name(),
						_type = 1,
						rid = v.rid,
						content = v.content,
						vip = v.vip,
						time = v.create_time,
					} 
					table.insert(self.talkDatas, talkData)
				elseif v.status == 2 then
					local talkData1 = {
						avatar = UserModel:avatar(),
						level = UserModel:level(),
						name = UserModel:name(),
						_type = 1,
						rid = v.rid,
						content = v.content,
						vip = v.vip,
						time = v.create_time,
					}
					table.insert(self.talkDatas, talkData1)
					local talkData2 = {
						name = "【小仙】",
						_type = 2,
						content = v.op_content,
						time = v.op_datetime,
					}
					table.insert(self.talkDatas, talkData2)
				end
			end
		end
		
		
		local sortFunc = function (a, b)
			return tonumber(a.time) < tonumber(b.time)
		end

		table.insert(self.talkDatas, self.feedBackData)

		-- dump(self.talkDatas, "\n\nself.talkDatas==")
		table.sort(self.talkDatas, sortFunc)

		self:initView()
	end
end

function GameFeedBackView:currencyTextModel(_cell, _item, playinfo)
	_cell:initData(_item, self.scroll_1)
end
--@@======================================================
function GameFeedBackView:initView()
    -- dump(self.talkDatas,"\n\nself.talkDatas===",9)

    local  function createCellFunc(_table)
        local  _cell=UIBaseDef:cloneOneView(self.UI_talk)--mc_talk);
        self:currencyTextModel(_cell, _table, _item);
        return _cell;
    end
    self.params = {}
    local sumIndex = 0
    -- dump(data,"0000000000000000000000000000")
    if  #self.talkDatas ~= 0 then
        for i=1, #self.talkDatas do
            -- dump(data[1][i],"+++++++++++++++++")
            -- local height,length = FuncCommUI.getStringHeightByFixedWidth(data[i].content,20,nil,380)
            local content = self.talkDatas[i].content

            local width,height = FuncChat.getStrWandH(content, 360)
            -- echo("===========width=====length=================",width,length)
            local param = {
               data={self.talkDatas[i]},
               createFunc = createCellFunc,
               perNums = 1,
               offsetX = -10,
               offsetY = 5,
               widthGap = 0,
               itemRect = {x = 0, y= -60 - height, width = 450, height = 50 + height},
               perFrame = 0,
            };
            sumIndex =  sumIndex + 1
            table.insert(self.params, param)
        end
        -- dump(params,"111111111111111111111111")
        self.scroll_1:styleFill(self.params);
        self.scroll_1:refreshCellView(1)
		self.scroll_1:hideDragBar()
        self.scroll_1:gotoTargetPos(1, #self.params);
    end
end

function GameFeedBackView:initViewAlign()

end

function GameFeedBackView:registerEvent()
	GameFeedBackView.super.registerEvent(self);
	self:registClickClose("out") --点击屏幕任意地方关闭窗口
	self.panel_shuru:setTouchedFunc(c_func(self.onInputTap, self)) --点击输入面板，弹出输入框
	-- self.UI_1.mc_1:showFrame(1)
	self.btn_fa:setTap(c_func(self.onConfirmBtnTab, self))	--确定按钮
	self.UI_1.btn_1:setTap(c_func(self.onCloseTap, self))	--关闭按钮
	self:registClickClose("out")
	EventControler:addEventListener(UserEvent.USEREVENT_FEEDBACK_SUCCESS, self.frequentlyFeedBack, self)
end

function GameFeedBackView:onInputTap()
	self.input_content:setInputEndCallback(c_func(self.onInputFinished, self))
	-- FuncCommUI.startInput(self.content, c_func(self.onInputFinished, self), self.panel_shuru.input_content.__uiCfgs.co)
end

--输入完毕
function GameFeedBackView:onInputFinished()

	if self.input_content:getText() == "" or self.input_content:getText() == " " then
		return
	end
	
end

-- function GameFeedBackView:getStrlength( str )
-- 	local lenInByte = #str
-- 	local widthsize = 0
-- 	local num = 0
-- 	for i=1,lenInByte do
-- 	    local curByte = string.byte(str, i)
-- 	    local byteCount = 0;
-- 	    -- UTF-8 编码规则
-- 	    --  1）对于单字节的符号，字节的第一位设为0，
-- 	    -- 后面7位为这个符号的unicode码。
-- 	    -- 因此对于英语字母，UTF-8编码和ASCII码是相同的。

-- 		-- 2）对于n字节的符号（n>1），第一个字节的前n位都设为1，
-- 		-- 第n+1位设为0，后面字节的前两位一律设为10。
-- 		-- 剩下的没有提及的二进制位，全部为这个符号的unicode码。

-- 		-- 3）汉字占用三个字节

-- 	    if curByte>0 and curByte<=127 then
-- 	        byteCount = 1
-- 	    elseif curByte>=192 and curByte<224 then
-- 	        byteCount = 2
-- 	    elseif curByte>=224 and curByte<240 then
-- 	        byteCount = 3
-- 	    elseif curByte>=240 and curByte<248 then
-- 	        byteCount = 4
-- 	    end 
-- 	    if byteCount ~= 0 then
-- 	    	num = num + 1
-- 		end
-- 	end
-- 	return num
-- end

-- 点击确定按钮，往服务器发送玩家的反馈信息
function GameFeedBackView:onConfirmBtnTab()
	local content = self.input_content:getText()
	self.content = content

	-- echo("\n\ntime ===", LS:prv():get(UserModel:rid().."isFrequentlyTime"))
	--检查是否为空、超字数、含敏感词
	if nil == content or "" == content then
		WindowControler:showTips(GameConfig.getLanguage("tid_setting_1004"))
		return
	else
		if LS:prv():get(UserModel:rid().."isFrequentlyTime") and TimeControler:getServerTime() < (tonumber(LS:prv():get(UserModel:rid().."isFrequentlyTime")) + FEED_BACK_INTERVAL) then
	        WindowControler:showTips(GameConfig.getLanguage("#tid_game_fankui_003"))--GameConfig.getLanguage("chat_cool_down_1007"));
	        return
	    else
	    	if string.len4cn2(self.content) > FEED_BACK_STRING_LEN then
				WindowControler:showTips(GameConfig.getLanguage("tid_setting_1006"))
				return
			end
			if Tool:checkIsBadWords(content) then 
				WindowControler:showTips(GameConfig.getLanguage("#tid_game_fankui_004"));
				return;
			end
			--向服务器发送反馈数据
			if self.isBack and self.isBack == true then
				self:sendMessage()
			end			
	    end
	end
end

function GameFeedBackView:sendMessage()
	self.isBack = false
	self.paramData = self:getFeedBackParams()
	local url = FuncSetting.FEEDBACK_URL
	local dateStr = os.date("%Y-%m-%d %X")
	local token = crypto.md5(string.format("PlayCrab%s%s", FuncSetting.FEEDBACK_PRIKEY, dateStr))
	local signature = string.format("PLAYCRAB %s:%s", FuncSetting.FEEDBACK_PUBKEY, token)
	--httpheader
	local headers = {
		string.format("Authorization: %s", signature),
		string.format("Date: %s", dateStr),
	}
	-- dump(self.paramData, "---params send to questionServer---");
	WebHttpServer:sendRequest(self.paramData, url, 
		WebHttpServer.POST_TYPE.POST, headers, c_func(self.onFeedBackOk, self))

end

function GameFeedBackView:getFeedBackParams()
	local params = {
		uid = UserModel:uid(),
		pid = "暂传uid " .. UserModel:uid(), 
		rid = UserModel:rid(),
		version = AppInformation:getVersion(), --必填
		package_version = "1.0.1", --必填
		game = "xianpro", --必填
		platform = AppInformation:getAppPlatform(), --必填
		area_service = LoginControler:getServerName(), --必填
		vip = UserModel:vip(),
		role = UserModel:rid(), --必填
		title = "仙",
		content = self.content,
		create_time = TimeControler:getServerTime(),
	}
	return params
end

function GameFeedBackView:onFeedBackOk(serverData)
	if serverData.data and serverData.data.code == "200" then
		-- echo("\n\n__________发送成功___________")		
		self.isBack = true
		EventControler:dispatchEvent(UserEvent.USEREVENT_FEEDBACK_SUCCESS)
		WindowControler:showTips(GameConfig.getLanguage("tid_setting_1003"))
		self.input_content:setText("")
		local funcTitle = "sendLuaErrorLogByFeedBack"
		ClientActionControler:sendLuaErrorLogToPlatform(funcTitle)
		local data = serverData.data
		local sendContent = {
			avatar = UserModel:avatar(),
			level = UserModel:level(),
			name = UserModel:name(),
			_type = 1,
			rid = UserModel:rid(),
			content = self.content,
			vip = UserModel:vip(),
			time = TimeControler:getServerTime(),
		}
		self:updateUI(sendContent)
	end
end

function GameFeedBackView:onCloseTap()
	self:startHide()
end

function GameFeedBackView:frequentlyFeedBack()
	local time = tonumber(TimeControler:getServerTime())

	if #self.feedBackMap == self.maxFeedBackCount then
		table.remove(self.feedBackMap, 1)
	end
	table.insert(self.feedBackMap, time)
	
	if #self.feedBackMap == self.maxFeedBackCount and (self.feedBackMap[#self.feedBackMap] - self.feedBackMap[1]) <= self.maxFeedBackTime then
		LS:prv():set(UserModel:rid().."isFrequentlyTime", TimeControler:getServerTime())
	end
end

--@@======================================================
function GameFeedBackView:updateUI(sendContent)
	table.insert(self.talkDatas, sendContent)
	self:initView()
end

function GameFeedBackView:deleteMe()
	-- TODO
	GameFeedBackView.super.deleteMe(self);
end

return GameFeedBackView;
