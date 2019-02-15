--[[
	Author: lichaoye
	Date: 2017-05-03
	魂匣-奖励界面
]]
local NewLotterySoulRewardView = class("NewLotterySoulRewardView", UIBase)

function NewLotterySoulRewardView:initFdata()
	local t = {}
	local reward = {
		[1] = "1",
		[2] = "9641",
		[3] = "1",
	}
	local tTemp = {}
	
	for i=1,6 do
		tTemp[i] = table.copy(reward)
	end

	for i=1,5 do
		t[i] = table.copy(tTemp)
	end
	t[2][7] = {
		[1] = "18",
		[2] = "5003",
		[3] = "1",
	}

	return t
end

function NewLotterySoulRewardView:ctor( winName, params )
	-- FuncNewLottery.CachePartnerdata()
	NewLotterySoulRewardView.super.ctor(self, winName)
	-- self._rewards = self:initFdata()
end

function NewLotterySoulRewardView:registerEvent()
	-- self:registClickClose("out")
	self.panel_btn.btn_2:setTap(c_func(self.press_btn_close, self))
	-- EventControler:addEventListener(NewLotteryEvent.RESUME_REWARD_ITEMS,self.playGetProcess,self)--继续弹奖励itmes
	EventControler:addEventListener(NewLotteryEvent.RESUME_REWARD_ITEMS,self.resumeCard,self) -- 继续播获得伙伴的动画
end

-- 适配
function NewLotterySoulRewardView:setViewAlign()
   FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_zuo, UIAlignTypes.Left)
   FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_you, UIAlignTypes.Right)
end

function NewLotterySoulRewardView:loadUIComplete()
	self:initVar()
	self:registerEvent()
	self:setViewAlign()
	self:updateUI()

	self:createTouchLayer()
end
--  创建一个触摸层
function NewLotterySoulRewardView:createTouchLayer()
	local tl = display.newNode():addto(self._root):anchor(0,1)
	tl:setContentSize(GameVars.width, GameVars.height)
	tl:pos(0,0)
	tl:setTouchedFunc(function()
		if not self._playingCard then
			if self._playingIcon then
				self:showResult()
			else
				self:playGetProcess()
			end
		end
	end)
	self.touchLayer = tl
end

function NewLotterySoulRewardView:updateUI()
	-- 按钮
	self.panel_btn:visible(false)
	-- 文字
	self.txt_jixu:visible(false)
	self:updateBtn()
	-- 播放获取过程
	self:playGetProcess()
	-- self:updateHero()
end

function NewLotterySoulRewardView:updateBtn()
	local times = 1
	local consume = tonumber(FuncDataSetting.getDataByConstantName("LotteryBoxConsume"))
	if #self._rewards == 1 then
		self.panel_btn.mc_goon:showFrame(1)
	elseif #self._rewards == 5 then
		self.panel_btn.mc_goon:showFrame(2)
		times = 5
	end
	-- 消耗
	consume = consume * times
	self.panel_btn.txt_1:setString(consume)
	
	local btn = self.panel_btn.mc_goon.currentView.btn_1
	btn:setTap(function()
		if UserModel:getGold() < consume then
			WindowControler:showTips(GameConfig.getLanguage("tid_common_1001")) 
			return 
		end
		-- 点的时候判断一下活动开没开
		local LotterySoulData = FuncNewLottery.getMyServerLotterySoulData()
		-- 抽奖界面再抽
		if LotterySoulData then
			-- 清空上次抽奖数据
			NewLotteryModel:clearSoulRewardData()
			NewLotteryServer:requestSoulDrawCard(times, LotterySoulData.id, function ()
			    -- WindowControler:showWindow("NewLotterySoulRewardView")
			    if NewLotteryModel:getSoulReward() then
			    	self:initVar()
			    	self:updateUI()
			    else 
				    WindowControler:showTips(GameConfig.getLanguage("#tid_chouka_024"))
				end
			end)
		else
			echoError("活动没开啊")
		end
	end)
end

-- 直接展示结果
function NewLotterySoulRewardView:showResult()
	self._playingIcon = false
	FuncArmature.setArmaturePlaySpeed(self.iconAnim ,1.5)
	self.panel_btn:visible(self._curGroup > #self._rewards)
	self.txt_jixu:visible(self._curGroup <= #self._rewards)
end
-- 播放获取过程
function NewLotterySoulRewardView:playGetProcess()
	if self._curGroup <= #self._rewards then
		local rewards = self._rewards[self._curGroup]
		self._curGroup = self._curGroup + 1
		self:updateIcon(rewards)
		if self._curGroup == #self._rewards + 1 then
			self:playGetAnimation(function()
				self:playGetProcess()
			end)
		else
			self:playGetAnimation(function()
				self.txt_jixu:visible(true)
			end)
		end
	else
		self.panel_btn:visible(true)
		self.txt_jixu:visible(false)
	end
end

function NewLotterySoulRewardView:updateIcon(rewards)
	self._views = {}
	for i=1,7 do
		self["panel_" .. i]:visible(false)
		local reward = rewards[i]
		local view = UIBaseDef:cloneOneView(self["panel_" .. i])
		if reward then
			-- view:visible(true)
			view._reward = reward
			self:createreward(view, reward)
			self._views[i] = view
			if i == 7 then
				local view1 = UIBaseDef:cloneOneView(self.UI_1)
				view1._reward = reward
				self:updateHero(view1, reward[2])
				view1:addTo(self._root) -- 临时存放
				
				self._huoban = view1
			end
		end
		view:addTo(self._root) -- 临时存放
		view:visible(false)
	end
	-- 伙伴的卡 一定在第7个
	self.UI_1:visible(false)
end

-- 播放获取动画
function NewLotterySoulRewardView:playGetAnimation(callBack)
	local ctn_chou = self.ctn_chou
	ctn_chou:removeAllChildren()
	local ctn_hero = self.ctn_juese
	ctn_hero:removeAllChildren()

	local frames = {7,8,10,12,14,16}
	local names = {"b8", "b2", "b4", "a19", "a19_copy", "b6"}
	
	self._playingIcon = true
	self.iconAnim = self:createUIArmature("UI_chouka_b","UI_chouka_b_huxia1", ctn_chou, false, function ()
		-- echo("进来了~~~")
		-- self._playingIcon = false
		-- if callBack then callBack() end
	end)
	-- 继续文字
	self.txt_jixu:visible(false)
	self.iconAnim:registerFrameEventCallFunc(33,1,function()
		self._playingIcon = false
		if callBack then callBack() end
	end)

	for i,v in ipairs(self._views) do
		if i < 7 then
			self.iconAnim:registerFrameEventCallFunc(frames[i],1,function()
				self:ShowItemsAudio()
				self.iconAnim:getBoneDisplay(names[i]):getBone("node1"):visible(false)
				FuncArmature.changeBoneDisplay(self.iconAnim:getBoneDisplay(names[i]), "node1", v)  --替换
				self.iconAnim:getBoneDisplay(names[i]):registerFrameEventCallFunc(5,1,function ()
					self.iconAnim:getBoneDisplay(names[i]):getBone("node1"):visible(true)
				end)
				self.iconAnim:getBoneDisplay(names[i]):doByLastFrame(true, true ,function () 
					-- -- 防止跳帧，在通用的doByLastFrame里处理了
					-- self.iconAnim:getBoneDisplay(names[i]):gotoAndPause(20)
				end)
				v:pos(-17,13)
			end)
		else
			self._playingCard = true
			self.heroAnim = self:createUIArmature("UI_chouka_b","UI_chouka_b_huxia2", ctn_hero, false, function ()
				self._playingCard = false
			end)

			self._huoban:setPosition(-80,150)
			FuncArmature.changeBoneDisplay(self.heroAnim, "node1", self._huoban)

			self.heroAnim:registerFrameEventCallFunc(85,1,function()
				AudioModel:playSound(MusicConfig.s_lottery_dajiang)
				self.heroAnim:getBoneDisplay("a1"):getBone("node1"):visible(false)
				FuncArmature.changeBoneDisplay(self.heroAnim:getBoneDisplay("a1"), "node1", v)  --替换
				self.heroAnim:getBoneDisplay("a1"):registerFrameEventCallFunc(5,1,function()
					self.heroAnim:getBoneDisplay("a1"):getBone("node1"):visible(true)
				end)
				self.heroAnim:getBoneDisplay("a1"):doByLastFrame(true, true ,function () 
				end)
				v:pos(-17,13)
			end)

			-- WindowControler:showWindow("NewLotteryShowHeroUI",v._reward[2])
			self.iconAnim:registerFrameEventCallFunc(22,1,function()
				WindowControler:showWindow("NewLotteryShowHeroUI",v._reward[2],true)
				self.heroAnim:pause()
			end)
		end
	end
end

function NewLotterySoulRewardView:resumeCard()
	-- self:delayCall(function ()
	-- 	if self.lockAni ~= nil then
	-- 		self.lockAni:play(true)
	-- 	end
	-- end,0.1)
	if self.heroAnim then
		-- self._playingIcon = true
		self.heroAnim:play()
	end
end

-- 初始化变量
function NewLotterySoulRewardView:initVar()
	self.saverpartnerdata = {} -- 缓存
	self._curGroup = 1 -- 当前是第几组奖励
	-- self._cacheAct = nil -- 缓存的未做完的动作
	self._playingIcon = false -- 是否正在播icon动画
	self._playingCard = false -- 是否正在播卡牌动画
	-- self._rewards = self:initFdata()
	self._rewards = NewLotteryModel:getSoulReward()
end

function NewLotterySoulRewardView:createreward(view,reward)
	-- local reward = {
	-- 	[1] = "1",
	-- 	[2] = "9641",
	-- 	[3] = "1",
	-- }
	-- dump(reward,"奖励数据")
	---1伙伴，2item（法宝碎片，伙伴碎片，道具）    3法宝
	local rewardtype =  tonumber(reward[1])
	local rewardID = tonumber(reward[2])
	local rewardnumber = tonumber(reward[3])

	-- view.panel_1
	if rewardtype == 18 then
		local PartnerID = rewardID
	    local PartnerData = FuncNewLottery.PartnerData --PartnerModel:getAllPartner()
	    -- view.panel_1:visible(true)
	    if PartnerData[tostring(PartnerID)] == nil then  --伙伴数据库里是否存在该伙伴
	    	if self.saverpartnerdata[tostring(PartnerID)] ~= nil then
		    	rewardnumber = FuncPartner.getPartnerById(rewardID).sameCardDebris
	    		rewardtype = 1
	    	else
	    		self.saverpartnerdata[tostring(PartnerID)] = PartnerID
		    end
		    
	    else
	    	rewardnumber = FuncPartner.getPartnerById(rewardID).sameCardDebris
	    	rewardtype = 1
	    end
	end
	-- 后方光圈隐藏
	-- view.panel_1:visible(false)
	if rewardtype == 18 then
		view.mc_xing:visible(true)
		local PData = FuncPartner.getPartnerById(rewardID)
		view.mc_xing:showFrame(PData.initStar or 1)
	else
		view.mc_xing:visible(false)
	end
	local awardstring = rewardtype..","..rewardID..","..(rewardnumber or "")

	view.UI_1:setResItemData({reward = tostring(awardstring)})
	view.UI_1:showResItemName(true)
	view.UI_1:showResItemNameWithQuality()
end

function NewLotterySoulRewardView:updateHero(panel, _partnerId)
	panel:updataUI(_partnerId)
end

function NewLotterySoulRewardView:ShowItemsAudio()
	AudioModel:playSound(MusicConfig.s_lottery_xiaotubiao)
end

function NewLotterySoulRewardView:press_btn_close()
	-- 清空上次抽奖数据
	NewLotteryModel:clearSoulRewardData()
	self:startHide()
end

return NewLotterySoulRewardView