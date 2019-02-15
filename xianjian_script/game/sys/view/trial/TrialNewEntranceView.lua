-- TrialNewEntranceView
--试炼系统
--2017-2-8 17:10
--@Author:wukai


local TrialNewEntranceView = class("TrialNewEntranceView", UIBase);
function TrialNewEntranceView:ctor(winName, selectTypeID)
    TrialNewEntranceView.super.ctor(self, winName);
    if selectTypeID ~= nil then
    	self.selectTypeID = selectTypeID
    else
    	self.selectType = 1
    end
    if TrailModel._selecttype ~= nil then
    	self.selectTypeID = TrailModel._selecttype
    end
    self.oldrota = 0 --计入当前的角度
end

function TrialNewEntranceView:loadUIComplete()
	self:loadkQuestUI(DailyQuestModel:getquestId());

	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back,UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_UI,UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_name1,UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_guize,UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_x1,UIAlignTypes.MiddleBottom)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_man1,UIAlignTypes.LeftBottom)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.scale9_1,UIAlignTypes.LeftBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_1,UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_2,UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_3,UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_lihui,UIAlignTypes.MiddleBottom)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.scroll_1,UIAlignTypes.LeftBottom)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_kaitong,UIAlignTypes.LeftBottom)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.txt_jiangcheng,UIAlignTypes.LeftBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_x1.btn_gl,UIAlignTypes.Right)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_zhuan,UIAlignTypes.RightBottom)

	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_x1.panel_1,UIAlignTypes.Right)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_x1.btn_2,UIAlignTypes.Right)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_x1.btn_1,UIAlignTypes.Right)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_gl,UIAlignTypes.Right)
	for i=1,5 do
		local panel = self.panel_x1["mc_d_"..i]
		FuncCommUI.setViewAlign(self.widthScreenOffset,panel,UIAlignTypes.Left)
	end
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_x1.txt_jiangli,UIAlignTypes.Left)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_x1.scroll_1,UIAlignTypes.Left)

	FuncCommUI.setScale9Align(self.widthScreenOffset,self.panel_x1.scale9_1,UIAlignTypes.MiddleBottom,1.5,1)


	self.mc_2.currentView.btn_1:setTap(c_func(self.selectTypeTwo,self))
	self.btn_back:setTap(c_func(self.press_btn_close,self))
	self.mc_1.currentView.btn_1:setTap(c_func(self.selectTypeOne,self))
	
	self.mc_3.currentView.btn_1:setTap(c_func(self.selectTypeThree,self))
	-- self.mc_3:setVisible(false)

	self.panel_x1.btn_gl:setTap(c_func(self.showRankComments,self))

	-- self.btn_1:setTap(c_func(self.challengebutton,self))
	self.btn_guize:setTap(c_func(self.Showguize,self))

	self.btn_bang:setVisible(false)

	self.ani = nil
	self:setBtnRedisFalse()
	self:isopenDeleteSuo()

	self:OpenSelectType()
	self:registerEvent()
	self:pathOpendefaultShow()


	-- self:getGoodManData()---获得好友玩家
	-- self:getLuRenData()
	-- self:getfriendlistData()
	-- FuncTrail.OpenSysten()

	-- self:setRollingData()    --滚动选择
	self:setdeffName()
end 

--设置难度类型
function TrialNewEntranceView:setdeffName()
	local diffData = FuncTrail.getTrialDataById(self.selectType)
	for i=1,5 do
		local mc_1 = self.panel_x1["mc_d_"..i]:getViewByFrame(1).mc_1
		local name = diffData[i].diffName
		mc_1:getViewByFrame(1).btn_1:getUpPanel().txt_1:setString(GameConfig.getLanguage(name))
		mc_1:getViewByFrame(1).btn_1:getDownPanel().txt_1:setString(GameConfig.getLanguage(name))
		mc_1:getViewByFrame(2).btn_1:getUpPanel().txt_1:setString(GameConfig.getLanguage(name))
		mc_1:getViewByFrame(2).btn_1:getDownPanel().txt_1:setString(GameConfig.getLanguage(name))

		local txt_1 = self.panel_x1["mc_d_"..i]:getViewByFrame(2).txt_1
		txt_1:setString(GameConfig.getLanguage(name))
	end
end

function TrialNewEntranceView:updateAdditionText(_amountType)
	local amountType = _amountType or FuncCommon.additionType.addition_trialA
	-- local isHas,value,subType = GuildModel:checkIsHaveAdditionByZone( amountType )
	local idArr = {
		[1] = "2002",
		[2] = "2003",
		[3] = "2004",

	}
	local privilegeData = UserModel:privileges() 
    local additionType = amountType
    local curTime = TimeControler:getServerTime()
    local fromSys = FuncCommon.additionFromType.CARD
    -- echo("================================",privilegeData,additionType,curTime,fromSys)
    local isHas,value,subType = FuncCommon.checkHasPrivilegeAddition( privilegeData,additionType,curTime,fromSys )
	echo("______ isHas,value,subType _________________",isHas,value,subType)
	local timeDay = MonthCardModel:getCardLeftDay(FuncMonthCard.card_xiyao)

	local additionData = FuncCommon.getAdditionDataByAdditionId( idArr[tonumber(_amountType)] )
	local additionData = additionData.subNumber/100
	self.panel_x1.mc_keji:visible(false)
	self.panel_x1.mc_keji:visible(true)
	if timeDay > 0 then
		self.panel_x1.mc_kaitong:showFrame(2) 
		self.panel_x1.mc_kaitong:getViewByFrame(2).txt_1:setString(GameConfig.getLanguageWithSwap("#tid_trial_buff_1",additionData))--"已激活财神送宝特权，收益+"..additionData.."%")
		local btn_go = self.panel_x1.mc_kaitong --.currentView.btn_1
		btn_go:setTouchedFunc(function ( ) end)
	else
		self.panel_x1.mc_kaitong:showFrame(1)
		self.panel_x1.mc_kaitong:getViewByFrame(1).txt_1:setString(GameConfig.getLanguageWithSwap("#tid_trial_buff_2",additionData))--"激活财神送宝特权，收益+"..additionData.."%")
		local btn_go = self.panel_x1.mc_kaitong --.currentView.btn_1
		btn_go:setTouchedFunc(function (  )
			WindowControler:showWindow("MonthCardMainView", FuncMonthCard.CARDYEQIAN["1"])
		end)
	end

	-- 添加仙盟科技对本玩法的产出量加成 显示
	local resourceData = FuncGuild.getCalculateResourceData(UserModel:guildSkills())
	local tmpArr = {}
	-- echo("length = = = = = = = ",table.length(resourceData))
	self.panel_x1.mc_keji:visible(true)
	self.panel_x1.mc_keji:showFrame(1)
	self.panel_x1.mc_keji:getViewByFrame(1).txt_1:setString(GameConfig.getLanguage("#tid_trial_buff_3"))
	-- self.panel_x1.mc_keji:getViewByFrame(1).btn_1
	self.panel_x1.mc_keji:setTouchedFunc(function (  )
			local isaddGuild = GuildModel:isInGuild()
			if  not isaddGuild then
				WindowControler:showTips(GameConfig.getLanguage("#tid_group_guild_1605"))
			else 
				WindowControler:showWindow("GuildSkillMainView")
			end
		end)
	if resourceData and table.length(resourceData)>0 then
		for k,v in pairs(resourceData) do
			-- dump(v,"vvvvvvv = = = = = = ")
			tmpArr = v
			for a,b in pairs(tmpArr) do
				if b.key == _amountType then
					-- self.panel_x1.mc_keji:visible(true)
					self.panel_x1.mc_keji:showFrame(2)
					local txt_1 = self.panel_x1.mc_keji.currentView.txt_1
					txt_1:setString(GameConfig.getLanguageWithSwap("#tid_trial_buff_4",(b.value/100)))
					self.panel_x1.mc_keji:setTouchedFunc(function ()  end)
				end
			end
		end
	end
end

function TrialNewEntranceView:showRankComments()
	local diffID = self.conditionDiffID
	-- echo("======diffID=========",diffID)
	-- local countTab = FuncTrail.getallchallengCount()
	-- local data = FuncTrail.byIdgetdata(diffID)
	local arrayData = {
        systemName = FuncCommon.SYSTEM_NAME.TRAIL,---系统名称
        diifID = diffID,  --关卡ID
    }
    RankAndcommentsControler:showUIBySystemType(arrayData)


end


function TrialNewEntranceView:setBtnRedisFalse()
	for i=1,3 do
		self["mc_"..i]:getViewByFrame(1).btn_1:getUpPanel().panel_red:visible(false)
	end
end
function TrialNewEntranceView:isopenDeleteSuo()
	for i=1,3 do
		local isopen  = TrailModel:isopenType(i)
		if self["mc_"..i]:getViewByFrame(1).btn_1:getUpPanel().panel_suo ~= nil then
			local isshow = false
			if isopen then
				isshow = false
			else
				isshow = true
			end
			self["mc_"..i]:getViewByFrame(1).btn_1:getUpPanel().panel_suo:visible(isshow)
			self["mc_"..i]:getViewByFrame(1).btn_1:getDownPanel().panel_suo:visible(isshow)
			self["mc_"..i]:getViewByFrame(2).panel_suo:visible(isshow)
		end
	end
end
function TrialNewEntranceView:getfriendlistData()
    
    local function _callback(_param)
        -- dump(_param.result,"获取服务器好友列表")
        if (_param.result ~= nil) then
            FriendModel:setFriendList(_param.result.data.friendList);
            FriendModel:setFriendCount(_param.result.data.count);
            FriendModel:updateFriendSendSp(_param.result.data);
        else
            WindowControler:showTips(GameConfig.getLanguage("tid_friend_no_enough_friends_1017"));
        end

    end
    local param = { };
    param.page = 1;
     --暂时不要获取列表
    -- FriendServer:getFriendListByPage(param, _callback);

end
function TrialNewEntranceView:getLuRenData()   ---路人数据
	local function _callback(_param)
		TrailModel:setTrailPlayData(_param.result)
	end
	 --暂时不要获取列表
	-- TrialServer:getPowerLuRenData(_callback)
end
function TrialNewEntranceView:getGoodManData()
	local function _callback(_param)
        -- dump(_param.result,"获取服务器好友列表")
        if (_param.result ~= nil) then
            FriendModel:setFriendList(_param.result.data.friendList);
            FriendModel:setFriendCount(_param.result.data.count);
            FriendModel:updateFriendSendSp(_param.result.data);
        else
            WindowControler:showTips(GameConfig.getLanguage("tid_friend_no_enough_friends_1017"));
            echo("-----FriendMainView:clickButtonPrevPage-------", _param.error.code, _param.error.message);
        end
    end
    local param = { };
    param.page = 1
    --暂时不要获取列表
    -- FriendServer:getFriendListByPage(param, _callback);
end

function TrialNewEntranceView:pathOpendefaultShow()
	if  self.selectTypeID  then
    	self.selectType = tonumber(self.selectTypeID)
    	self:defaultShow(self.selectType)
    end
end

function TrialNewEntranceView:Showguize()
	WindowControler:showWindow("TrailRegulationView",self.selectType)
end

function TrialNewEntranceView:registerEvent()
	TrialNewEntranceView.super.registerEvent();
   EventControler:addEventListener(TrialEvent.BATTLE_SUCCESSS_EVENT,
        self.battleSuccessCallBack, self);

    --定点刷新
    EventControler:addEventListener(TimeEvent.TIMEEVENT_STATIC_CLOCK_REACH_EVENT, 
        self.staticTimeReach, self)

    EventControler:addEventListener(MonthCardEvent.MONTH_CARD_BUY_SUCCESS_EVENT, self.reFreshMonthUI, self)

    --扫荡成功
    -- EventControler:addEventListener(TrialEvent.SWEEP_BATTLE_SUCCESS_EVENT,
    --     self.sweepSuccessCallback, self);

    -- EventControler:addEventListener(COUNT_TYPE_TRIAL_TYPE_TIMES_1, self.OnTimeRefreshUI, self)
    -- EventControler:addEventListener(CountEvent.COUNTEVENT_MODEL_UPDATE,self.OnTimeRefreshUI,self)
end
function TrialNewEntranceView:OnTimeRefreshUI()
	-- TrailModel:bytimeGetCount()
	self:OpenSelectType()
	self:updateData(self.selectType)
	self:defaultShow(self.selectType)
	self:isopenDeleteSuo()


end

function TrialNewEntranceView:reFreshMonthUI(event)
	self:delayCall(function (  )
		self:updateAdditionText(self.selectType)
	end,0.5)
	
end
function TrialNewEntranceView:sweepSuccessCallback()
	-- self:updateData(self.selectType)
	-- self:isopenDeleteSuo()
	local trialdata =  TrailModel:getTrialLevelIsOpen(self.selectType)
	self:rewardData(trialdata.id)
end
-- 挑战返回的
function TrialNewEntranceView:battleSuccessCallBack()
	self:updateData(self.selectType)
	self:isopenDeleteSuo()

end
function TrialNewEntranceView:staticTimeReach(event)
    local clock = event.params.clock;
    self:updateData(self.selectType)
    self:isopenDeleteSuo()

end

-- --旧的挑战按钮
-- function TrialNewEntranceView:challengebutton()
-- 	-- echo("======挑战=======")
-- 	-- WindowControler:showWindow("TrialnewDetailView", self.selectType);
-- end

function TrialNewEntranceView:OpenSelectType()

	self:defaultShow(TrailModel.trialselectType or 1)

end

function TrialNewEntranceView:defaultShow(index)
	if index == 1 then
		self.mc_1:showFrame(2)
		self:selectTypeOne()
		self:addctn_lihui(1)
	elseif index ==2 then
		self.mc_2:showFrame(2)
		self:selectTypeTwo()
		self:addctn_lihui(2)
	else
		self.mc_3:showFrame(2)
		self:selectTypeThree()
		self:addctn_lihui(3)
	end

end

function TrialNewEntranceView:selectTypeOne()
	if self:weikaiqi(1) then
		self:updateData(1)
		self.mc_1:showFrame(2)
		self.mc_2:showFrame(1)
		self.mc_3:showFrame(1)
		self.selectType = 1
		self:addctn_lihui(1)
		self:showButtonRed(1)
		local  bgName = TrailModel.BgName[1]
		self:changeBg(bgName)
		self:addSelectTypeEffect(1)

		local amountType = FuncCommon.additionType.addition_trialA
		self:updateAdditionText(amountType)
	end
end

function TrialNewEntranceView:selectTypeTwo()
	if  self:weikaiqi(2) then
		self:updateData(2)
		self.mc_1:showFrame(1)
		self.mc_2:showFrame(2)
		self.mc_3:showFrame(1)
		self.selectType = 2
		self:addctn_lihui(2)
		self:showButtonRed(2)
		local  bgName = TrailModel.BgName[2]
		self:changeBg(bgName )
		self:addSelectTypeEffect(2)

		local amountType = FuncCommon.additionType.addition_trialB
		self:updateAdditionText(amountType)
	end
end

function TrialNewEntranceView:selectTypeThree()
	if  self:weikaiqi(3) then
		self:updateData(3)
		self.mc_1:showFrame(1)
		self.mc_2:showFrame(1)
		self.mc_3:showFrame(2)
		self.selectType = 3
		-- self:touchChallengButton(3)
		self:addctn_lihui(3)
		self:showButtonRed(3)
		local  bgName = TrailModel.BgName[3]
		self:changeBg(bgName )
		self:addSelectTypeEffect(3)

		local amountType = FuncCommon.additionType.addition_trialC
		self:updateAdditionText(amountType)
	end
end

---山神难度选择
function TrialNewEntranceView:addSelectTypeEffect(index)
	if self.animType == nil then
		self.animType = self:createUIArmature("UI_shilian","UI_shilian_mubiaowenli", self, true,GameVars.emptyFunc)
	end
	local panle = self["mc_"..index]
	local x = panle:getPositionX()
	local y = panle:getPositionY()
	self.animType:setPosition(cc.p(x+320/2,y-88/2))

end


function TrialNewEntranceView:weikaiqi(index)
	local open ,level = TrailModel:isopenType(index)
	if  open then
		return true
	else
		local _str = string.format(GameConfig.getLanguage("#tid_trail_012"),tostring(level))
		WindowControler:showTips(_str);
		return false
	end
end

--- 不需要
function TrialNewEntranceView:showButtonRed(index)
	for i=1,3 do
		if index ~= i then
			local redfiles =  TrailModel:newRedisShow(i)  ---TrailModel:showTrailMainRed(i)
			self["mc_"..i]:getViewByFrame(1).btn_1:getUpPanel().panel_red:visible(redfiles)
		else
			self["mc_"..i]:getViewByFrame(1).btn_1:getUpPanel().panel_red:visible(false)
		end
	end
end
--- 不需要
function TrialNewEntranceView:touchChallengButton(index)
	local file =  TrailModel:isTrialTypeOpenCurrentTime(index)
	if file == false then 
		self.mc_shengyu:visible(false)
		-- FilterTools.setGrayFilter(self.btn_1);
		-- self.btn_1:getUpPanel().panel_red:visible(false)
	else
		self.mc_shengyu:visible(true)
	end
end


--新的
function TrialNewEntranceView:updateData(index)
	local trial_type = index
	--难度类型的数据ID
	local trialdata =  TrailModel:getTrialLevelIsOpen(trial_type)
	self:rewardData(trialdata.id)
	self:setSelectButton(trial_type,trialdata)
	TrailModel:setTraildiffid(trialdata.id)
end



---奖励显示  index ---表示选择的是哪个类型的试炼（山神，火神，和盗宝贼）
function TrialNewEntranceView:rewardData(diffID)

	self.conditionDiffID = diffID
	TrailModel:setTraildiffid(diffID)
	local _data = FuncTrail.getRewardById(diffID)
	self.panel_x1.mc_man1:setVisible(false)
	 local createFunc = function(_itemdata)
        local _itemView = UIBaseDef:cloneOneView(self.panel_x1.mc_man1) 
        self:updataItem(_itemView,_itemdata)
        return _itemView
    end

    local updateFunc = function(_itemdata, _itemView)
        self:updataItem(_itemView,_itemdata)
        return _itemView
    end


    local params = {
        {
            data = _data,
            createFunc = createFunc,
            -- updateFunc = updateFunc,
            perNums = 1,
            offsetX = 5,
            offsetY = 0,
            widthGap = 0,
            heightGap = 0,
            itemRect = { x = 0, y = -90, width = 90, height = 90 },
            perFrame = 0,
        }
    }
    self.panel_x1.scroll_1:cancleCacheView();
    self.panel_x1.scroll_1:styleFill(params)
    -- self.scroll_1:setCanScroll(true);
    -- self.scroll_1:hideDragBar()


    self:diffButtonInfoShow(diffID)   ---后面添加





	--[[
	-- echo("1111111111111111111111111111111111===",index)
	TrailModel:settrialselectType(index)
	local uitable = {
		[1] = self.mc_man1,
		[2] = self.mc_man2,
		[3] = self.mc_man3,
		[4] = self.mc_man4,
		[5] = self.mc_man5,
	}
	-- local serverdata = trialReward  --挑战的奖励
	local difftype = 5
	local openindex = 1
	for i=1,difftype do
		if TrailModel:isTrailOpen(index, i) == true then
			openindex = i
		end 
	end
	local Trailid = TrailModel:getIdByTypeAndLvl(index,openindex)
	-- local challengtrialReward = FuncTrail.newgetTrailData(Trailid,"trialReward")
	local aa = FuncTrail.getTrailIDbyReward(index,Trailid)

	local rewarddada = self:paixudata(aa)
	for i=1,#uitable do
		uitable[i]:setVisible(false)
		
	end

	local _indexs = 0
	for i=1,5 do
		if rewarddada[i] ~= nil then
			uitable[i]:setVisible(true)
			local itemReward = rewarddada[i]
			local reward = string.split(itemReward, ",")
			local rewardType = reward[1]      ----类型
	    	local rewardNum = reward[3] * 2    ---总数量
	    	local rewardId = reward[2] 			---物品ID
	    	local gterewardnumber = 0       -- 根据ID===服务器的数据
	    	local sumdedata = {}
	    	local allnumber =	TrailModel:getIdByrewardNumber(index)

	    	local sumnumber = 0
            local sumdata = TrailModel.StarData[tostring(Trailid)]
            local count = 0
            if sumdata ~= nil then
               count = sumdata.count
            end

	    	if allnumber  ~= nil then
	    		if allnumber[tostring(rewardId)] ~= nil then
	    			gterewardnumber = allnumber[tostring(rewardId)]
	    			-- gterewardnumber = reward[3]* count
	    		end
	    	end
	    	rewardNum = rewardNum - gterewardnumber
	    	itemReward = rewardType..","..rewardId..","..rewardNum
	    	local item_view_1 = uitable[i]:getViewByFrame(1)["UI_1"]
			local item_view_2 = uitable[i]:getViewByFrame(2)["UI_1"]
			item_view_1:setResItemData({reward = itemReward})
			item_view_2:setResItemData({reward = itemReward})
			-- item_view_1:showResItemName(true)
			-- item_view_2:showResItemName(true)
	    	if rewardNum <= 0 then
	    		uitable[i]:showFrame(2)
	    		item_view_1:showResItemNum(false)
	    		item_view_2:showResItemNum(false)
	    		_indexs = _indexs  + 1
	    	else
	    		uitable[i]:showFrame(1)
	    	end
			FuncCommUI.regesitShowResView(item_view_1,
            rewardType, rewardNum, rewardId, itemReward, true, true);
            FuncCommUI.regesitShowResView(item_view_2,
            rewardType, rewardNum, rewardId, itemReward, true, true);
		end
	end

	--]]
end

function TrialNewEntranceView:updataItem(_itemView,_itemdata)
	local item_view_1 = _itemView:getViewByFrame(1)["UI_1"]
	item_view_1:setResItemData({reward = _itemdata})
	local reward = string.split(_itemdata, ",")
	local rewardType = reward[1]      ----类型
	local rewardNum = reward[3]   ---总数量
	local rewardId = reward[2] 			---物品ID
	FuncCommUI.regesitShowResView(item_view_1,
            rewardType, rewardNum, rewardId, _itemdata, true, true);
end

--挑战按钮详情显示
function TrialNewEntranceView:diffButtonInfoShow(diffID)
	local countTab = FuncTrail.getallchallengCount()
	local data = FuncTrail.byIdgetdata(diffID)
	local trialType = data.trialType

	local  isshored,count = TrailModel:newRedisShow(tonumber(trialType)) --countTab[tonumber(trialType)] - TrailModel:getTrialCount(tonumber(trialType))  ---每个类型的次数 需要后端的数据处理 ————TODO
	local satr = TrailModel:getChallengStar(tonumber(diffID))				--需要后端的数据处理 ————TODO  星级
	
	self.panel_x1.panel_1.btn_1:setVisible(true)
	self.panel_x1.panel_1.btn_1:setTouchedFunc(c_func(self.sweepButton, self,data,count))
	echo("=======satr=======",count,satr)

	if count > 0 then
		if satr  then  ---三星扫荡
			self.panel_x1.panel_1.txt_2:setString(count)
			-- if count == 0 then
			-- 	self.panel_x1.panel_1.txt_2:setColor(cc.c3b(0xff,0x00,0x00))
			-- else
			-- 	self.panel_x1.panel_1.txt_2:setColor(cc.c3b(0x00,0xff,0x00))
			-- end
		else
			self.panel_x1.panel_1.btn_1:setVisible(true)
			self.panel_x1.panel_1.txt_2:setString(count)
		end
		self.panel_x1.panel_1.txt_2:setColor(cc.c3b(0x00,0xff,0x00))
		self.panel_x1.panel_1.btn_2:setTouchedFunc(c_func(self.challengButton,self, data))
	else
		self.panel_x1.panel_1.btn_1:setTouchedFunc(c_func(self.newSweepButton, self,data))
		self.panel_x1.panel_1.btn_2:setTouchedFunc(c_func(self.challengButton,self, data))
		self.panel_x1.panel_1.txt_2:setString(count)
		-- if count == 0 then
		-- 	self.panel_x1.panel_1.txt_2:setColor(cc.c3b(0xff,0x00,0x00))
		-- else
		-- 	self.panel_x1.panel_1.txt_2:setColor(cc.c3b(0x00,0xff,0x00))
		-- end
		self.panel_x1.panel_1.txt_2:setColor(cc.c3b(0xff,0x00,0x00))
	end
	echo("=====diffID==========",diffID)
	local rewardData = TrailModel:getRewardProgress(diffID)
	self.panel_x1.panel_1.txt_5:setString(rewardData)
	

	self:redIsShow(trialType)
end

function TrialNewEntranceView:newSweepButton( )
	WindowControler:showTips("扫荡次数不足")--GameConfig.getLanguage("#tid_trail_018"))


end



--按钮上显示红点的问题
function TrialNewEntranceView:redIsShow(trialType)
	for i=1,3 do
		local isshow = false
		if i == trialType then
			isshow = false
		else
			isshow = TrailModel:newRedisShow(i)
		end
		self["mc_"..i]:getViewByFrame(1).btn_1:getUpPanel().panel_red:setVisible(isshow)
	end	
end


--多人挑战
function TrialNewEntranceView:manyPeopleChalleng(data)
	-- body
	-- echo("=====多人挑战=========",data.id)
	if 1 then
		WindowControler:showTips(GameConfig.getLanguage("#tid_trail_018"))
		return 
	end
	local isok = self:isCanChalleng(data)
	if not isok then
		return
	end
	local itemid = FuncTrail.getManyPeopleChallengID()
	local itemdata = FuncItem.getItemData(itemid)
	local num = ItemsModel:getItemNumById(itemid)
	if num < 1 then
		WindowControler:showTips(GameConfig.getLanguage(itemdata.name)..GameConfig.getLanguage("#tid_trail_019"))
		return 
	end
	local function _callback(_param)
        dump(_param.result,"创建组队数据")
        if _param.result ~= nil then
            -- self:button_btn_close()
            local data = {
                _type =  self.selectType,
                diffic = data.id,
            }
            TrailModel:setTraildiffid(data.id)
            WindowControler:showWindow("TrialNewFriendPiPeiView",data);
        end
    end   

    -- local id = TrailModel:getIdByTypeAndLvl(self._trailKind, self._selectIndex);
    local params = {}
    params.trialId = data.id
    TrialServer:sendCreateTeam(params,_callback)


end
--挑战
function TrialNewEntranceView:challengButton(data)
	-- body
	echo("=====挑战=========",self.selectType,data.id)
	local isok = self:isCanChalleng(data)
	if isok then
		local trailPve = nil
	    if self.selectType == TrailModel.TrailType.ATTACK then
	        trailPve = FuncTeamFormation.formation.trailPve1;
	    elseif self.selectType == TrailModel.TrailType.DEFAND then
	        trailPve = FuncTeamFormation.formation.trailPve2;
	    else
	        trailPve = FuncTeamFormation.formation.trailPve3;
	    end 
	    TrailModel:setSelectChallengeID(self.selectType)
	 --    local levelId = FuncTrail.getLevelIdByTrialId(data.id, 2)
	 --    local params = {}
	 --    params[trailPve] = {
	 --    	raidId = levelId,
		-- }
	    WindowControler:showWindow("WuXingTeamEmbattleView", trailPve)
	end
end
--扫荡
function TrialNewEntranceView:sweepButton(data)
	-- body
	-- echo("=====扫荡=========",data.id)
	local trialType = data.trialType
	local  isshored,count = TrailModel:newRedisShow(tonumber(trialType)) --countTab[tonumber(trialType)] - TrailModel:getTrialCount(tonumber(trialType))  ---每个类型的次数 需要后端的数据处理 ————TODO
	local satr = TrailModel:getChallengStar(tonumber(data.id))				--需要后端的数据处理 ————TODO  星级
	if count > 0 then
		if satr  then 

		else
			WindowControler:showTips(GameConfig.getLanguage("#tid_trial_024"))--"暂不可扫荡")
			return
		end
	else
		WindowControler:showTips("扫荡次数不足")
		return 
	end


	local isok = self:isCanChalleng(data)
	if isok then
		local id = data.id
		TrialServer:sweep(c_func(self.sweepCallback, self), id, 1);
	end
end
function TrialNewEntranceView:sweepCallback(event)
    -- echo("sweepCallback callBack");
    if event.error == nil then 
        -- echo("sweepCallback ok")
        dump(event.result, "扫荡返回数据");
        local data = event.result.data.reward
        data = FuncTrail.paixudata(data)
        WindowControler:showWindow("TrialSweepNewView",data);
        -- TrailModel:sweepdata(event.result.data.dirtyList.u.trials)
        self:sweepSuccessCallback()
        EventControler:dispatchEvent(TrialEvent.BATTLE_SUCCESSS_EVENT);
        -- self:initUI()
    end 
end


--是否能挑战
function TrialNewEntranceView:isCanChalleng(data)
	local _chalType = self.selectType
	local diffData = FuncTrail.getTrialDataById(_chalType)
	-- dump(diffData,"22222====")
	local condition = data.condition
	local isopen = UserModel:checkCondition( condition )
	if isopen == nil then  --开启
		return true
	else
		self:nomcBtnClick(data)
		return false
	end
end



--设置难度按钮的点击事件
function TrialNewEntranceView:setSelectButton(_chalType,trialdata)
	-- self.panel_xx
	local difficulty = trialdata.difficulty
	local diffData = FuncTrail.getTrialDataById(_chalType)
	-- dump(diffData,"难度数据=====")
	for i=1,#diffData do
		--判断是不是开启，一个加锁的状态
		local button = self.panel_x1["mc_d_"..i]
		
		local condition = diffData[i].condition
		local isopen = UserModel:checkCondition( condition )
		if isopen == nil then  --开启
			button:setTouchedFunc(c_func(self.mcBtnClick, self,diffData[i],i))
			-- button.panel_feng:setVisible(false)
			button:showFrame(1)
		else  --未开启
			button:setTouchedFunc(c_func(self.nomcBtnClick, self,diffData[i],i))
			button:showFrame(2)
			-- button.panel_feng:setVisible(true)
		end
		-- button:setTouchedFunc(c_func(self.mcBtnClick, self,diffData[i]))
	end
	self:selectCheckpointDifficulty(difficulty)
end
function TrialNewEntranceView:nomcBtnClick(data)
	local condition = data.condition[1]
	WindowControler:showTips( GameConfig.getLanguage("#tid_trail_020")..condition.v ) 
end


function TrialNewEntranceView:selectCheckpointDifficulty(difficulty)
	echo("========difficulty=====",difficulty)
	for i=1,5 do
		local mc_1 = self.panel_x1["mc_d_"..i]:getViewByFrame(1).mc_1
		mc_1:showFrame(1)
		if i == tonumber(difficulty) then
			mc_1:showFrame(2)
		end
	end
end


function TrialNewEntranceView:mcBtnClick(trialdata,difficulty)
	self:selectCheckpointDifficulty(difficulty,trialdata.id)
	self:rewardData(trialdata.id)
	--[[
	-- dump(trialdata,"====数据====")
	echo("======选中那个难度====",trialdata.id)
	-- local diffID = trialdata.id
	-- self:rewardData(diffID)
	-- self:disabledUIClick()
	local rog = 360
	if self.conditionDiffID ~= trialdata.id then
		self.animdiff:setVisible(false)
		local rota = self.panel_dabaozi.panel_xx:getRotation()
		local newrota = rota+rog/5
		local diffData = nil
		if rota >= 0 then
			local emainder =  math.fmod(math.abs(newrota), rog)
		    local selectindex =  math.floor(emainder/72)+1
			
		else
			local emainder =  math.fmod(math.abs(newrota), rog)
	    	selectindex =  math.floor(emainder/72)
	    end
	    self.panel_dabaozi.panel_xx:runAction(act.sequence(cc.RotateTo:create(0.15, newrota),
	    	act.callfunc(function ()
	    		self.animdiff:setVisible(true)
	    		self:rewardData(trialdata.id)
				self.conditionDiffID = trialdata.id
				self:resumeUIClick()
			end)))
	    -- local diffData = FuncTrail.getTrialDataById(self.selectType)
    	-- local condition = diffData[selectindex]
		
		-- echo("=========condition.id========",condition.id
	else
		self:resumeUIClick()
	end
	]]
end


function TrialNewEntranceView:addctn_lihui(index)

	local lihuiname =  FuncTrail.getTrialResourcesData(index,"staticId")
	self.ctn_lihui:removeAllChildren()


	local spinename = {
        [1] = "art_20001_shanshen",
        [2] = "art_20002_huoshen",
        [3] = "art_20086_daobaohouzi", 
    }

    local spnename = spinename[tonumber(index)]
    local sp = ViewSpine.new(spnename)
    sp:playLabel("stand");
	self.ctn_lihui:addChild(sp)


end


---滚动设置
function TrialNewEntranceView:setRollingData()
	-- self.ctn_zhuan
	-- self.panel_dabaozi.mc_btn_:setVisible(true)
	-- self.panel_xx:setVisible(true)
	local x =  self.ctn_zhuan:getPositionX() --+35
	local y =   self.ctn_zhuan:getPositionY()
	-- self.panel_dabaozi.mc_btn_:setPosition(cc.p(x,y))
	-- self.panel_xx:setPosition(cc.p(x,y))

	self.panel_dabaozi:setPosition(cc.p(x,y))

	self:initMoveNode( )

	-- FuncTrail.Angle
end
-- 添加滑动逻辑
function TrialNewEntranceView:initMoveNode( )
    local moveNode = FuncRes.a_white(400,400)-- 170*4,36*9.5)
    moveNode:setPosition(cc.p(1,0))
    self.panel_dabaozi.panel_xx:addChild(moveNode,10)
    moveNode:setTouchEnabled(true)
    self.moveNode = moveNode
    self.lihuiCanMove = true
    moveNode:opacity(0)
    moveNode:setTouchedFunc(c_func(self.moveNodeTouchEnds, self), nil, false,
     c_func(self.moveNodeTouchStart, self),
     c_func(self.moveNodeTouchMove, self),
     nil,
     c_func(self.moveNodeTouchEnd, self)  )
end
function TrialNewEntranceView:moveNodeTouchEnds()
	echo("点击")
end
function TrialNewEntranceView:moveNodeTouchEnd(event)
    if not self.lihuiCanMove then 
        return
    end 
     self:disabledUIClick()
    
    local moverota = 0
    local vertical = 360
    -- local offset = vertical/3  --偏移平均值
    -- local maxRota = vertical+offset 
    local rota = self.panel_dabaozi.panel_xx:getRotation() 
    -- echo("======移动位置========",self.rotation_dis)
    -- if  self.rotation_dis >= offset then
    -- 	moverota = offset
    -- else
    -- 	moverota = 0
    -- end
    -- dump(event,"======1111===")
    local integer = 0  --360度的整数
    local remainder = 0  --72度的余数
    local averageAngle = vertical/5
    local offset = averageAngle/5  --偏移平均值
    if rota >= 0 then  --向右转
    	local sumremainder =  math.fmod(rota, vertical)
    	remainder = math.fmod(sumremainder, averageAngle)
    	if remainder >= offset then
    		local newmoverota = rota + averageAngle - remainder
    		if rota >= self.oldrota then
    			moverota = newmoverota
    		else
    			moverota = rota  - remainder
    		end
    	else
    		moverota = rota  - remainder
    	end
    	local emainder =  math.fmod(math.abs(moverota), vertical)
    	selectindex =  math.floor(emainder/averageAngle)+1
    else
    	rota = math.abs(rota)
 		local sumremainder =  math.fmod(rota, vertical)
    	remainder = math.fmod(sumremainder, averageAngle)
    	if remainder >= offset then
    		local newmoverota = -rota - averageAngle + remainder
    		if -rota <= self.oldrota then
    			moverota = newmoverota
    		else
    			moverota = -rota + remainder
    		end
    	else
    		moverota = -rota  + remainder
    	end
    	local tab = {[0]= 1,[1] = 5,[2] = 4,[3] = 3,[4] = 2,[5] = 1}
    	local emainder =  math.fmod(math.abs(moverota), vertical)
    	selectindex =  math.floor(emainder/averageAngle)
    	selectindex = tab[selectindex]
    end
    
    -- local sumremainder =  math.fmod(math.abs(moverota), vertical)
    -- local selectindex =  math.floor(sumremainder/averageAngle)+1  


    echo("======选中的难度==========",FuncTrail.IndexStr[selectindex],self.conditionDiffID)
    if self.moveto then
		self.panel_dabaozi.panel_xx:runAction(act.sequence(cc.RotateTo:create(0.1, moverota),
			act.callfunc(function ()
				self.animdiff:setVisible(true)
				local diffData = FuncTrail.getTrialDataById(self.selectType)
				local condition = diffData[selectindex]
				self:rewardData(condition.id)
				self.conditionDiffID = condition.id
				self:resumeUIClick()
			end)
			))
		self.oldrota = moverota
	else
		self:resumeUIClick()
    end

end

function TrialNewEntranceView:addSelectDiffEffect()
	local ctn = self.panel_dabaozi.panel_1
	if self.animdiff == nil then
		self.animdiff = self:createUIArmature("UI_shilian","UI_shilian_nandutexiao", ctn, true,GameVars.emptyFunc)
		self.animdiff:setPosition(cc.p(65,-46))
	end
end




function TrialNewEntranceView:moveNodeTouchStart(event)
    -- dump(event, "moveStar -----------", 3)
    self.starMoveX = event.x
    self.starMoveY = event.y
    self.moveto = false

end
function TrialNewEntranceView:moveNodeTouchMove(event)
    if not self.lihuiCanMove then 
        return
    end 


    local _dis = (event.x - event.prevX)/3

   	if _dis == 0 then
   	 	_dis = (event.y - event.prevY)/3
   	end

    local roa = self.panel_dabaozi.panel_xx:getRotation()
    
    local rotation = roa + _dis

  	self.moveto = true

  	self.rotation_dis = _dis
    self.panel_dabaozi.panel_xx:setRotation(rotation)
    self.animdiff:setVisible(false)
end

-- 设置立绘是否可以滑动
function TrialNewEntranceView:setLihuiMove( event )
    self.lihuiCanMove = event.params
end










function TrialNewEntranceView:press_btn_close()
	EventControler:dispatchEvent("TIAOZHANHONGDIANSHUAXIN")   ---主城红点显示
    self:startHide()
end
function TrialNewEntranceView:HEXtoC3b(hex)
    local flag = string.lower(string.sub(hex,1,2))
    local len = string.len(hex)
    if len~=8 then
        print("hex is invalid")
        return nil 
    end
    if flag ~= "0x" then
        print("not is a hex")
        return nil
    end
    local rStr =  string.format("%d","0x"..string.sub(hex,3,4))
    local gStr =  string.format("%d","0x"..string.sub(hex,5,6))
    local bStr =  string.format("%d","0x"..string.sub(hex,7,8))

    -- local ten = string.format("%d",hex)
    ten = cc.c3b(rStr,gStr,bStr)
    return ten
end



function TrialNewEntranceView:numbetToString( tonumbers )
	-- echo("===========tonumbers=======",tonumbers)
	local string = nil
	tonumbers = tonumber(tonumbers)
	if tonumbers == 1 then
		string = "一"
	elseif tonumbers == 2 then
		string = "二"
	elseif tonumbers == 3 then
		string = "三"
	elseif tonumbers == 4 then
		string = "四"
	elseif tonumbers == 5 then
		string = "五"
	elseif tonumbers == 6 then
		string = "六"
	elseif tonumbers == 7 then
		string = "日"
	end
	return string
end


return TrialNewEntranceView;







