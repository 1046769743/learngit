-- WelfareTiLiRewardView.lua
--aouth wk
--time 201/1/9

local WelfareTiLiRewardView = class("WelfareTiLiRewardView", UIBase);
local dayStr = {
	[1] = "早餐",
	[2] = "中餐",
	[3] = "晚餐",
	[4] = "夜宵",
}
local GetTiliState = {
	replacement = 1,  --补领
	get = 2,   --已领取
	notGet = 3,	--未领取
}



function WelfareTiLiRewardView:ctor(winName)
    WelfareTiLiRewardView.super.ctor(self, winName);
    self.isReFreshUI = {false,false,false,false}


end

function WelfareTiLiRewardView:loadUIComplete()
	self:registerEvent();
	-- self.UI_1.mc_1:getViewByFrame(1).btn_1:setTap(c_func(self.getLingShiView,self));
	-- self:registClickClose(-1, c_func( function()
 --            self:clickButtonBack();
 --    end , self));

	-- self.UI_1.btn_close:setTap(c_func(self.clickButtonBack,self));
	self.oldservertimse = TimeControler:getServerTime()


	self.getTiliInfo = {}   ---体力领取的问题
	self.poisoning = {}
	self.addGeteffect = {}  --领取特效
	self.addHezieffect = {}
	local randomData = FuncActivity.getInTheDayData()
	for i=1,#randomData do
		self.poisoning[randomData[i]] = false
	end
	-- 
	-- self:addSpine()
	self:updateUI();
	-- self:setlanguage()
	self:addbubblesRunaction()
	self.timeFactor = 1
	self:scheduleUpdateWithPriorityLua(c_func(self.updateFrame, self) ,0)
end 
function WelfareTiLiRewardView:registerEvent()
	EventControler:addEventListener("COUNT_TYPE_GET_TILI", self.refshUI, self)
end
function WelfareTiLiRewardView:refshUI( )

	local _type = FuncCount.COUNT_TYPE.COUNT_TYPE_GET_TILI
	if CountModel._data ~= nil then
		if CountModel._data[tostring(_type)] then
			CountModel._data[tostring(_type)].count = 0
		end
	end
	self.getTiliInfo = {}   ---体力领取的问题
	self.poisoning = {}
	self.addGeteffect = {}  --领取特效
	self.addHezieffect = {}

	local randomData = FuncActivity.getInTheDayData()
	for i=1,#randomData do
		self.poisoning[randomData[i]] = false
	end
	self:updateUI();
	EventControler:dispatchEvent(ActivityEvent.REFRESH_RED_POINT)
end
function WelfareTiLiRewardView:getLingShiView()
end

--初始化数据
function WelfareTiLiRewardView:updateUI()
	local sumNum = CountModel:getTiLiNum()
	local data = FuncGuild.byCountTypeGetTable(sumNum,4) --服务器数据
	local index = 1
	self.serveData = {}
	for i=#data,1,-1 do
		self.serveData[index] = data[i]
		index = index + 1
	end

	--时间段
	self.timeData  =  FuncActivity.getDailyTime()
	--随机食物
	local randomData = FuncActivity.getInTheDayData()

	-- self:todayRecipe(self.timeData,randomData)
	self:todayFoodRecipe(randomData)
	self:setlanguage()
end

--添加
function WelfareTiLiRewardView:addSpine()

	local spineName = "art_30019_xiaoman"
	local _cameraSpine = ViewSpine.new(spineName)
	self.ctn_anu:addChild(_cameraSpine)
	_cameraSpine:setPositionY(-50)
	_cameraSpine:setScaleX(-0.7)
	_cameraSpine:setScaleY(0.7)
	-- _cameraSpine:playLabel("ui",true)
end


--今日菜谱
function WelfareTiLiRewardView:todayRecipe(index,foodName,isopen)
	-- dayStr
	local panel = self.panel_caipu
	-- for i=1,#timeData do
		-- local foodName =  FuncActivity.getValueByParameter(randomData[i],"foodName")
		local qiantime = self.timeData[index][1]
		local houtime = self.timeData[index][2]
		local name = ""
		if foodName ~= nil then
			name = GameConfig.getLanguage(foodName)
		end
		if not isopen then
			name = "  ????"
		end
		local strArr1 = qiantime..":00".."~"..houtime..":00"
		local strArr2 = name
		-- echo("====qiantime====houtime=====",qiantime,houtime,strArr)
		panel["txt_"..(index*2-1)]:setString(strArr1)
		panel["txt_"..(index*2)]:setString(strArr2)

	-- end
end


--[[
 "111111111111111" = {
     1 = 0
     2 = 0
     3 = 1
     4 = 0
 }
]]
--食物数据
function WelfareTiLiRewardView:todayFoodRecipe(randomData)
	-- self.serveData
	local maxindex = {  --按位处理   从左到右，高到低 
		[1] = 4,
		[2] = 3,
		[3] = 2, 
		[4] = 1,

	}

	local servetime = os.date("*t", TimeControler:getServerTime())
	local hour = servetime.hour
	for i=1,#randomData do
		local panelFrame = self["mc_long"..i]
		local ctn_food = panelFrame:getViewByFrame(1).ctn_food
		ctn_food:removeAllChildren()
		local arrTime  = self.timeData[i]
		local begantime = tonumber(arrTime[1])
		local endtime = tonumber(arrTime[2])

		local sprite =  FuncRes.getFoodIcon("food_img_guichengmalaji.png")  ---暂时用后期读表
		local icon = display.newSprite(sprite)
		ctn_food:addChild(icon)


		if self.serveData[i] == 1 then --已经领取0

			-- echo("==第几个==",i,"=已经领取=====")
			-- self.UI_1.mc_1:getViewByFrame(1).btn_1:setTap(c_func(self.getRewArdTips,self));
			ctn_food:removeAllChildren()
			panelFrame:showFrame(1)
            panelFrame:setTouchedFunc(c_func(self.getRewArdTips,self),nil,false,nil,nil)
           	panelFrame.currentView.mc_1:showFrame(2)
           	--:setString("已领取")
           	local foodName =  FuncActivity.getValueByParameter(randomData[i],"foodName")
            panelFrame.currentView.txt_name:setString(GameConfig.getLanguage(foodName))

            self:todayRecipe(i,foodName,true)

            if self.poisoning[randomData[i]] ~= nil then
        		if self.poisoning[randomData[i]] then
            		self:addpoisoning(ctn_food)
            	end
            end
            self.getTiliInfo[i] = GetTiliState.get

            
		else  --未领取
			if hour >= endtime or hour < 4 then  ---补领
				-- echo("==第几个==",i,"=可以补领=====")
				panelFrame:showFrame(1)
                panelFrame:setTouchedFunc(c_func(self.getTiLiReward,self,randomData[i],maxindex[i],panelFrame),nil,false,nil,nil)
                local foodName =  FuncActivity.getValueByParameter(randomData[i],"foodName")
                panelFrame.currentView.txt_name:setString(GameConfig.getLanguage(foodName))
                local num = FuncActivity.getValueByParameter(randomData[i],"missCost")
                -- panelFrame.currentView.mc_1.currentView.txt_1:setString(num..GameConfig.getLanguage("#tid_welfare_004"))
                panelFrame.currentView.mc_1:showFrame(1)
                panelFrame.currentView.mc_1.currentView.txt_1:setString(num)
            	self.getTiliInfo[i] = GetTiliState.replacement

            	ctn_food:removeAllChildren()
            	local foodicon = FuncActivity.getValueByParameter(randomData[i],"foodIcon")
            	local sprite =  FuncRes.getActiveFoodIcon(foodicon)  ---暂时用后期读表
				local icon = display.newSprite(sprite)
				icon:setAnchorPoint(0.5,0.5)
				icon:setPosition(cc.p(0,-13))
				ctn_food:addChild(icon)

            	self:addzhengqiEffect(ctn_food,randomData[i])

            	self:todayRecipe(i,foodName,true)

			elseif hour >= begantime and hour <= endtime then  --可领取
				-- echo("==第几个==",i,"=可领取=====")
				panelFrame:showFrame(2)
                panelFrame:setTouchedFunc(c_func(self.getTiLiReward,self,randomData[i],0,panelFrame),nil,false,nil,nil)
                local foodName =  FuncActivity.getValueByParameter(randomData[i],"foodName")
                panelFrame.currentView.txt_name:setString(GameConfig.getLanguage(foodName))
            	self.getTiliInfo[i] = GetTiliState.notGet

            	local ctn_food = panelFrame:getViewByFrame(2).ctn_food
				ctn_food:removeAllChildren()

				local foodicon = FuncActivity.getValueByParameter(randomData[i],"foodIcon")
            	local sprite =  FuncRes.getActiveFoodIcon(foodicon)  ---暂时用后期读表
				local icon = display.newSprite(sprite)
				icon:setAnchorPoint(0.5,0.5)
				icon:setPosition(cc.p(0,-13))
				ctn_food:addChild(icon)
				self:addzhengqiEffect(ctn_food,randomData[i])
				-- self:delayCall(function ()
					self:addHeZispine(panelFrame,randomData[i],icon)
				-- end,0.1)--5/GameVars.GAMEFRAMERATE );
				
				self:todayRecipe(i,foodName,true)

			else   --不可领
				-- echo("==第几个==",i,"=-不可领取=====")
				panelFrame:showFrame(3)
                panelFrame:setTouchedFunc(c_func(self.notGetRewArdTips,self),nil,false,nil,nil)
                self:todayRecipe(i,foodName,false)
                local qiantime = self.timeData[i][1]
				local houtime = self.timeData[i][2]
				local timeTxt = qiantime.."点出笼"
				-- echo("====qiantime====houtime=====",qiantime,houtime,strArr)
				panelFrame.currentView.txt_1:setString(timeTxt)
			end
		end

	end


end
function WelfareTiLiRewardView:addHeZispine(panelFrame,foodid,icon)
	if not self.addGeteffect[foodid] then
		self:disabledUIClick()
		-- ctn:setVisible(true)
		local ctn = panelFrame:getViewByFrame(2)
		local posX =  ctn:getPositionX()
		local posY =  ctn:getPositionY()
		local spineName = "UI_fuli"
		self.spine = ViewSpine.new(spineName)
		self.spine:playLabel("UI_fuli_dakai",false,false)
		-- self.spine:setPlaySpeed(0.1)
		self.spine:setPosition(cc.p(posX + 158/2,posY-231/2))
		ctn:addChild(self.spine)
		function delayFunc()
			self:resumeUIClick()
			self.spine:zorder(-1)
		end
		local stopframe = 15
		local startAniTime =  stopframe * 1/GameVars.GAMEFRAMERATE ;
		self:delayCall(delayFunc, startAniTime);

		self.addGeteffect[foodid] = true
	end


end
function WelfareTiLiRewardView:addzhengqiEffect(ctn,foodid)
	self:createUIArmature("UI_fuli","UI_fuli_zhengqi", ctn, true,GameVars.emptyFunc)
end

--阿奴说的话
function WelfareTiLiRewardView:setlanguage()

	-- local str = FuncActivity.TILI_STR[2]
	local str = GameConfig.getLanguage("#tid_activity_30001002")
	local num = #self.getTiliInfo
	dump(self.getTiliInfo,"领取情况========")
	if num ~= 0 then
		local isallget = true
		for i=1,num do
			if self.getTiliInfo[i] ~= nil then
				if self.getTiliInfo[i] == GetTiliState.notGet then
					isallget = false
					-- str = FuncActivity.TILI_STR[1]
					str = GameConfig.getLanguage("#tid_activity_30001001")
					break 
				elseif self.getTiliInfo[i] == GetTiliState.replacement then
					isallget = false
					-- str = FuncActivity.TILI_STR[3]
					str = GameConfig.getLanguage("#tid_activity_30001003")
				end
			else
				isallget = false
			end
		end
		if isallget  then
			-- str = FuncActivity.TILI_STR[2]
			str = GameConfig.getLanguage("#tid_activity_30001002")
		end
	end
	-- dump(self.serveData,"领取情况====111111====")
	if self.serveData ~= nil then
		local isallgettili = true
		for i=1,#self.serveData do
			if self.serveData[i] ~= 1 then
				isallgettili = false
			end
		end
		if isallgettili then
			-- str = FuncActivity.TILI_STR[2]
			str = GameConfig.getLanguage("#tid_activity_30001002")
		end
	end

	local txt_1 = self.panel_qipao.txt_1
	txt_1:setString(str)

end


function WelfareTiLiRewardView:addbubblesRunaction()
	-- local delaytime_1 = act.delaytime(0.2)
	local scaleto_1 = act.scaleto(0.1,1.2,1.2)
	local scaleto_2 = act.scaleto(0.05,1.0,1.0)
	local delaytime_2 = act.delaytime(3.0)
 	local scaleto_3 = act.scaleto(0.1,0)
 	local delaytime_3 = act.delaytime(0.5)
 	local callfun = act.callfunc(function ()
 		-- self:setlanguage()
 	end)
	local seqAct = act.sequence(act.spawn(callfun,scaleto_1),scaleto_2,delaytime_2,scaleto_3,delaytime_3)

	-- self.panel_qipao:runAction(act._repeat(seqAct))


end



function WelfareTiLiRewardView:getRewArdTips()
	WindowControler:showTips(GameConfig.getLanguage("#tid_welfare_005"))
end

function WelfareTiLiRewardView:notGetRewArdTips()
	WindowControler:showTips(GameConfig.getLanguage("#tid_welfare_006"))
end

function WelfareTiLiRewardView:getTiLiReward(foodId,miss,panelFrame)
	local num = FuncActivity.getValueByParameter(foodId,"spAdd")
	--发送协议前需要检查体力是否会溢出
	local tid = "#tid_welfare_007"
	if UserModel:isSpOverflow(num, tid) then
		return
	end
    
	local callBack = function(event)
		if event.result ~= nil then
			-- dump(event.result,"=====领取体力奖励的数据返回=====")
			local data = event.result.data
			self:updateUI()
			local sumnum = FuncActivity.getValueByParameter(foodId,"spAdd")
			-- WindowControler:showTips("恭喜获得"..sumnum.."点体力")
			local str = "5"..","..sumnum
			local rewards = {[1] = str}
			if self.poisoning ~= nil then
				self.poisoning[foodId] = false
			end
			FuncCommUI.startRewardView(rewards)
			EventControler:dispatchEvent(ActivityEvent.REFRESH_RED_POINT)
			-- if data ~= nil then
			-- 	if data.poison ~= nil then   --是否中毒
			-- 		if data.poison then
			-- 			self.poisoning[foodId] = true
			-- 			-- local str= FuncActivity.TILI_STR[4]
			-- 			local str = GameConfig.getLanguage("#tid_activity_30001004")
			-- 			local txt_1 = self.panel_qipao.txt_1
			-- 			txt_1:setString(str)
			-- 			self:addEffect(panelFrame,foodId)
			-- 		end
			-- 	end
			-- end
		end
	end

	local params = {
		foodId = foodId,  ---菜品ID
		miss = miss,  ---是不是补领
	}
	-- dump(params,"111111111111========")
	ActivityServer:getTiLiReward(params, callBack)
end


function WelfareTiLiRewardView:addpoisoning(ctn_food)
	local sprite =  FuncRes.getActiveFoodIcon("activity_img_canzha.png")  ---暂时用后期读表
	local icon = display.newSprite(sprite)
	-- ctn_food:removeAllChildren()
	icon:setAnchorPoint(0.5,0.5)
	icon:setPosition(cc.p(0,-13))
	ctn_food:addChild(icon)
end

function WelfareTiLiRewardView:addEffect(panelFrame)
	if panelFrame ~= nil then
		local ctn_food = panelFrame:getViewByFrame(1).ctn_food
		ctn_food:removeAllChildren()

		self:addpoisoning(ctn_food)

		local anim1 = self:createUIArmature("UI_fuli","UI_fuli_fameitexiao", ctn_food, true,GameVars.emptyFunc)
		local anim2 = self:createUIArmature("UI_fuli","UI_fuli_tilizhongdujingshi", self, true,GameVars.emptyFunc)
		anim2:setPosition(cc.p(GameVars.halfResWidth,-GameVars.halfResHeight))
		anim2:setScaleX(GameVars.width/1136)
		anim2:setScaleY(GameVars.height/640)
		self:delayCall(function ()
			if anim1 ~= nil then
				ctn_food:removeAllChildren()
				-- anim1:removeFromParent()
				self:addpoisoning(ctn_food)
			end
			if anim2 ~= nil then
				anim2:removeFromParent()
			end
			local num = FuncActivity.getCompensation()			
			local str = FuncDataResource.RES_TYPE.DIAMOND ..",".. num
			local reward = {str}
			WindowControler:showWindow("RewardSmallBgView", reward);
		end,2.0)

	end
end


--刷新界面数据的定时器  
function WelfareTiLiRewardView:updateFrame()
	self.timeFactor = self.timeFactor + 1
	local remainder = math.fmod(self.timeFactor,30*2) --math.floor(self.timeFactor/30)
	if remainder == 0 then
		local oldsever_time = os.date("*t",self.oldservertimse)
		local serversTime = TimeControler:getServerTime()
		local time_sever = os.date("*t",serversTime)
		local hour = time_sever.hour
		local timeData  =  FuncActivity.getDailyTime()
		for i=1,#timeData do
			local sumTime = timeData[i]
			if hour >= tonumber(sumTime[1]) and hour <= tonumber(sumTime[2]) then
				if oldsever_time.hour ~= hour then
					self:updateUI()
					self.oldservertimse = TimeControler:getServerTime()
				end
			end
		end
	end
end




function WelfareTiLiRewardView:clickButtonBack()
    self:startHide();

end


return WelfareTiLiRewardView;
--[[
- "时间======" = {
-     1 = {
-         1 = "8"
-         2 = 10
-     }
-     2 = {
-         1 = "12"
-         2 = 14
-     }
-     3 = {
-         1 = "18"
-         2 = 20
-     }
-     4 = {
-         1 = "21"
-         2 = 23
-     }
- }

- "===随机获得数据 = =====" = {
-     1 = 6
-     2 = 2
-     3 = 3
-     4 = 1
- }

]]