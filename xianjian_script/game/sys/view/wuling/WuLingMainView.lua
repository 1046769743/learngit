--[[
	Author: caocheng
	Date:2017-10-30
	Description: 五灵养成主界面
]]

local WuLingMainView = class("WuLingMainView", UIBase);

function WuLingMainView:ctor(winName, _itemId)
    WuLingMainView.super.ctor(self, winName)

    if _itemId then
    	self.chooseType = tonumber(FuncTeamFormation.getFiveSoulByItemId(_itemId))
    	if self.chooseType == 0 then
    		self.chooseType = FuncWuLing.CHOOSE_TYPE.MatrixMethod
    	end
    else
    	local canPromote, canPromoteTable = WuLingModel:checkRedPoint()
    	if canPromote and #canPromoteTable > 0 then
    		self.chooseType = canPromoteTable[1]
    	else
    		self.chooseType = FuncWuLing.CHOOSE_TYPE.MatrixMethod
    	end
    end

end

function WuLingMainView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
end 

function WuLingMainView:registerEvent()
	WuLingMainView.super.registerEvent(self);
	self.btn_back:setTap(c_func(self.clickClose,self,nil,true))
	-- EventControler:addEventListener(WuLingEvent.WULINGEVENT_MAINVIEW_CHANGE, self.resetChangeView, self)
	EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE, self.updateWulingMainView, self)
	-- EventControler:addEventListener(WuLingEvent.WULINGEVENT_POWER_UPDATA,self.updatePower,self)
	-- 道具发生变化，刷新红点
	-- EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE,self.refreshRedPoint,self)
 --    -- 道具发生变化，刷新界面
 --    EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE,self.itemsChange,self)
end

function WuLingMainView:updateWulingMainView()
	local canPromote, canPromoteTable = WuLingModel:checkRedPoint()
	if canPromote and #canPromoteTable > 0 and self.oldChooseType and not canPromoteTable[self.oldChooseType] then
		self.chooseType = canPromoteTable[1]
	end
	self:updateUI()
end

function WuLingMainView:initData()
	
end

function WuLingMainView:initView()
	self.panel_zongpower:setVisible(false)
	self:initStation()
	self:initDatilView()
	self:initBtnView()
	self:initAniMation()
	-- self:initPowerView()
end

function WuLingMainView:initViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_title, UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_wen, UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_res, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_chongzhi, UIAlignTypes.LeftBottom)
end

function WuLingMainView:updateUI()
	self:initStation()
	self:initDatilView()
	self:initBtnView()
end

--缓存进战斗前的数据
function  WuLingMainView:getEnterBattleCacheData()
	return  {
                chooseType = self.chooseType,
            }
end

--出战斗后根据缓存的数据恢复界面
function WuLingMainView:onBattleExitResume(cacheData )
    dump(cacheData,"战斗恢复view EliteLieBiaoView")
    WuLingMainView.super.onBattleExitResume(cacheData)
    if cacheData and cacheData.chooseType then
        self.chooseType = cacheData.chooseType

        self:initData()
        self:initView() 
    end
end

function WuLingMainView:clickClose()
	EventControler:dispatchEvent(WuLingEvent.WULINGEVENT_MAINVIEW_UPDATA)
	self:startHide()
end

function WuLingMainView:initStation()
	if self.chooseType == FuncWuLing.CHOOSE_TYPE.MatrixMethod then
		self.panel_zuo.mc_taiji:showFrame(2)
	else	
		self.panel_zuo.mc_taiji:showFrame(1)
	end
	for k =1,5 do
		if k == self.chooseType then
			self.panel_zuo["mc_"..k]:showFrame(2)
			self.panel_zuo["mc_"..k].currentView.panel_j:setVisible(true)
		else
			self.panel_zuo["mc_"..k]:showFrame(1)
			self.panel_zuo["mc_"..k].currentView.panel_j:setVisible(false)
		end
		self.panel_zuo["mc_"..k]:setTouchedFunc(c_func(self.changeShowType,self,k))
		local tempLevel = WuLingModel:getWuLingLevelById(k)
		self.panel_zuo["mc_"..k].currentView.txt_2:setString("+"..tempLevel)
	end
	self.panel_zuo.mc_taiji:setTouchedFunc(c_func(self.changeShowType,self,FuncWuLing.CHOOSE_TYPE.MatrixMethod))

end


function WuLingMainView:changeShowType(index)
	if index ==  self.chooseType then
		return
	end
	self.chooseType = index
	self:initStation()
	self:initDatilView()
end

function WuLingMainView:initDatilView()
	if self.chooseType == FuncWuLing.CHOOSE_TYPE.MatrixMethod then
		self.mc_you:showFrame(1)
		local spiritDetail = self.mc_you.currentView.panel_x1
		self.mc_you.currentView.panel_x1:visible(false)
		self.mc_you.currentView.panel_box:removeAllChildren()
		for k= 1,5 do
			local baseSpiritView = UIBaseDef:cloneOneView(spiritDetail)
			local tempLevel = WuLingModel:getWuLingLevelById(k)
			local resistance,skillLevel = WuLingModel:getWuLingProperty(k,tempLevel)
			baseSpiritView.mc_1:showFrame(k)
			local isActive = WuLingModel:checkFiveSoulActiveById(k)
			if not isActive then
				baseSpiritView.mc_1.currentView.txt_2:setString("")
				baseSpiritView.txt_1:setString(GameConfig.getLanguage("tid_fivesoul_error_5"))
				baseSpiritView.txt_2:setString("")
			else
				baseSpiritView.mc_1.currentView.txt_2:setString("+"..tempLevel)
				baseSpiritView.txt_1:setString(GameConfig.getLanguage("tid_common_2066").."+"..resistance.."%")
				baseSpiritView.txt_2:setString(GameConfig.getLanguage("tid_common_2067").."+"..skillLevel)
			end
	
			baseSpiritView:setPosition(0,-40*(k-1))
			self.mc_you.currentView.panel_box:addChild(baseSpiritView)

		end
		self.mc_you.currentView.txt_lv:setString(GameConfig.getLanguage("tid_common_2068").."  "..UserModel:level())
		local nowMatrixMethod = FuncWuLing.getFiveSoulMatrixMethodByLevel(UserModel:level())
		local textStr = WuLingModel:switchMatrixMethodByLevel(UserModel:level())
		self.mc_you.currentView.txt_1:setString(textStr)
		self.mc_you.currentView.btn_tan:setTouchedFunc(c_func(self.showMatrixMethodDetail,self))
	else
		self.mc_you:showFrame(2)
		local tempLevel = WuLingModel:getWuLingLevelById(self.chooseType)
		local spiritLevel = WuLingModel:getWuLingLevelById(tonumber(self.chooseType))
		local resistance,skillLevel = WuLingModel:getWuLingProperty(self.chooseType,tempLevel)
		local nextResistance,nextSkillLevel = WuLingModel:getWuLingProperty(self.chooseType,tempLevel+1)
		local spiritCfg = WuLingModel:getSingleWuLing(self.chooseType,spiritLevel)
		local nextLevel = tempLevel + 1
		local nextData = WuLingModel:getSingleWuLing(self.chooseType,nextLevel)
		self.mc_you.currentView.panel_huobi.mc_wuc:showFrame(self.chooseType)
		self.mc_you.currentView.mc_1:showFrame(self.chooseType)
		self.mc_you.currentView.mc_2:showFrame(self.chooseType)
		self.mc_you.currentView.mc_2.currentView.txt_1:setString(GameConfig.getLanguage("tid_common_2069").."  +"..spiritLevel)
		self.mc_you.currentView.txt_1:setString(GameConfig.getLanguage("tid_common_2066").."+"..resistance.."%")
		self.mc_you.currentView.txt_2:setString(GameConfig.getLanguage("tid_common_2067").."+"..skillLevel)
		if self.tempView3 then
			self.tempView3:removeFromParent()
		end
		if self.chooseType == FuncWuLing.FIVE_TYPE.FENG then
			self.tempView3 = self:createUIArmature("UI_wulingfazhen","UI_wulingfazhen_changzhu2",self.mc_you.currentView.mc_1,true)
		elseif self.chooseType == FuncWuLing.FIVE_TYPE.LEI then
			self.tempView3 = self:createUIArmature("UI_wulingfazhen","UI_wulingfazhen_changzhu4",self.mc_you.currentView.mc_1,true)
		elseif self.chooseType == FuncWuLing.FIVE_TYPE.SHUI then
			self.tempView3 = self:createUIArmature("UI_wulingfazhen","UI_wulingfazhen_changzhu5",self.mc_you.currentView.mc_1,true)
		elseif self.chooseType == FuncWuLing.FIVE_TYPE.HUO then
			self.tempView3 = self:createUIArmature("UI_wulingfazhen","UI_wulingfazhen_wulingchangzhu",self.mc_you.currentView.mc_1,true)
		elseif self.chooseType == FuncWuLing.FIVE_TYPE.TU then
			self.tempView3 = self:createUIArmature("UI_wulingfazhen","UI_wulingfazhen_changzhu3",self.mc_you.currentView.mc_1,true)
		end		
		self.tempView3:pos(66,-65)
		if spiritCfg.cost then
			self.mc_you.currentView.mc_anniu:showFrame(1)
			self.mc_you.currentView.panel_huobi:setVisible(true)
			--改为消耗道具升级
			local cost_table = string.split(spiritCfg.cost[1], ",")
			local itemId = cost_table[2]
			local haveNum = ItemsModel:getItemNumById(itemId)
			local needNum = cost_table[3]
			local panel_progress = self.mc_you.currentView.panel_huobi.panel_hh
			panel_progress.txt_1:setString(haveNum.."/"..needNum)
			local progress = haveNum / needNum * 100
			if progress > 100 then
				progress = 100
			end
			panel_progress.progress_jindu:setPercent(progress)

			if not self.aniSaoguang then
				self.aniSaoguang = self:createUIArmature("UI_common","UI_common_saoguang", self.mc_you.currentView.mc_anniu.currentView.btn_1:getUpPanel(), true);
				self.aniSaoguang:setScaleX(0.75)
				self.aniSaoguang:setScaleY(0.7)
				self.aniSaoguang:pos(73, -34)
			end
			
			if tonumber(haveNum) >= tonumber(needNum) then
				-- FilterTools.clearFilter(self.mc_you.currentView.mc_anniu.currentView.btn_1)
				self.aniSaoguang:setVisible(true)
				self.mc_you.currentView.mc_anniu.currentView.btn_1:setTouchedFunc(c_func(self.enterUpgradeView,self))
			else
				self.aniSaoguang:setVisible(false)
				-- FilterTools.setGrayFilter(self.mc_you.currentView.mc_anniu.currentView.btn_1)
				self.mc_you.currentView.mc_anniu.currentView.btn_1:setTouchedFunc(c_func(self.wuLingPointTips, self, itemId))	
			end	
			self.mc_you.currentView.txt_3:visible(true)
			self.mc_you.currentView.panel_jiantou:visible(true)
			-- self.mc_you.currentView.panel_jiantou2:visible(true)
			self.mc_you.currentView.txt_3:setString("+"..nextLevel..GameConfig.getLanguage("tid_common_2070"))
			self.mc_you.currentView.panel_jiantou.txt_4:setString(GameConfig.getLanguage("tid_common_2066").."+"..nextResistance.."%")
			self.mc_you.currentView.panel_jiantou.txt_5:setString(GameConfig.getLanguage("tid_common_2067").."+"..nextSkillLevel)	
		else
			self.mc_you.currentView.panel_huobi:setVisible(false)
			self.mc_you.currentView.mc_anniu:showFrame(2)
			self.mc_you.currentView.txt_3:visible(false)
			self.mc_you.currentView.panel_jiantou:visible(false)
			-- self.mc_you.currentView.panel_jiantou2:visible(false)
		end
		self:initPowerView(self.chooseType)
	end	
end

function WuLingMainView:initBtnView()
	self.btn_chongzhi:setVisible(false)
	
	self.btn_wen:setTouchedFunc(c_func(self.showRuleView,self))
end

function  WuLingMainView:enterUpgradeView()
	if self.chooseType == FuncWuLing.CHOOSE_TYPE.MatrixMethod then

	else
		local params = {
				soulId = self.chooseType
			}
		if self.chooseType == FuncWuLing.FIVE_TYPE.FENG then
			AudioModel:playSound(MusicConfig.s_fivesoul_zhulingfeng)  
		elseif self.chooseType == FuncWuLing.FIVE_TYPE.LEI then
			AudioModel:playSound(MusicConfig.s_fivesoul_zhulinglei)  
		elseif self.chooseType == FuncWuLing.FIVE_TYPE.SHUI then
			AudioModel:playSound(MusicConfig.s_fivesoul_zhulingshui)  
		elseif self.chooseType == FuncWuLing.FIVE_TYPE.HUO then
			AudioModel:playSound(MusicConfig.s_fivesoul_zhulinghuo)  
		elseif self.chooseType == FuncWuLing.FIVE_TYPE.TU then
			AudioModel:playSound(MusicConfig.s_fivesoul_zhulingtu)  
		end
		self.oldChooseType = self.chooseType	
		self.oldAbility = WuLingModel:getTempAbility(self.oldChooseType)
		WuLingServer:upgradeFiveSouls(params,c_func(self.enterUpgradeSpirit,self))	
	end		
end

function WuLingMainView:enterUpgradeSpirit(event)
	if event.error then

	else
		self:disabledUIClick()

		EventControler:dispatchEvent(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT)

		local callBackFunc = function ()
			WindowControler:showWindow("WuLingUpgradeSpirit", self.oldChooseType, self.oldAbility)
			self:resumeUIClick()
		end

		self.aniUpdateView = self:createUIArmature("UI_wulingfazhen","UI_wulingfazhen_wulingshengji",self.panel_zuo["mc_"..self.oldChooseType],false)		
		self.aniUpdateView:pos(67,-67)
		-- FuncArmature.setArmaturePlaySpeed(self.aniUpdateView,0.9)
		self.aniUpdateView:registerFrameEventCallFunc(20, 1, callBackFunc)
	end	
end

--新版本确认中间的法阵已无升级功能  接口废弃
function WuLingMainView:enterUpgradeMatrixMethod(event)
	if event.error then

	else
		self:disabledUIClick()
		if self.tempView1 then
			self.tempView1:removeFromParent()
		end
		EventControler:dispatchEvent(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT)
		self.tempView1 = self:createUIArmature("UI_wulingfazhen","UI_wulingfazhen_fazhenshengji",self,false,function ()
			self:resumeUIClick()
			WindowControler:showWindow("WuLingUpgradeMatrixMethod",self.oldAbility)
			self:initDatilView()
			self:initBtnView()
			-- self:initPowerView()
		end)
		self.tempView2 = self:createUIArmature("UI_wulingfazhen","UI_wulingfazhen_baguashengji_shang",self,false)
		self.tempView1:pos(385,-320)
		self.tempView1:setLocalZOrder(-1)
		self.tempView2:pos(375,-320)
	end	
end

function WuLingMainView:resetChangeView()
	self:initStation()
	self:initDatilView()
	self:initBtnView()
	-- self:initPowerView()
end

function WuLingMainView:initAniMation()
	self.aniMainView = self:createUIArmature("UI_wulingfazhen","UI_wulingfazhen_changzhu",self,true)
	self.aniMainView:pos(473,-187)
end



function WuLingMainView:enterResetView()

	WindowControler:showWindow("WuLingResetTips")
end

function WuLingMainView:showRuleView()
	WindowControler:showWindow("WuLingRuleTips")
end

function WuLingMainView:showMatrixMethodDetail()
	WindowControler:showWindow("WuLingDetailTips")
end

function WuLingMainView:resetTips()
	WindowControler:showTips(GameConfig.getLanguage("tid_fivesoul_error_1"))
end


function WuLingMainView:wuLingPointTips(_itemId)
	--使用五灵点时的提示  废弃
	-- WindowControler:showTips(GameConfig.getLanguage("tid_fivesoul_error_3"))
	local itemName = FuncItem.getItemName(_itemId)
	WindowControler:showTips(GameConfig.getLanguageWithSwap("tid_fivesoul_error_4", itemName))
	WindowControler:showWindow("GetWayListView", _itemId)
end

function WuLingMainView:initPowerView(_id)
	local tempPowerNum = WuLingModel:getTempAbility(_id)
	self.mc_you.currentView.panel_zongpower.UI_number:setPower(tempPowerNum)	
end

function WuLingMainView:updatePower()
	local tempPowerNum = WuLingModel:getTempAbility(self.chooseType)
	if tempPowerNum ~= self.oldAbility then 
		FuncCommUI.showPowerChangeArmature(self.oldAbility, tempPowerNum,0.8,true,1.8);
		self.oldAbility = tempPowerNum
	end		
end


function WuLingMainView:deleteMe()
	-- TODO

	WuLingMainView.super.deleteMe(self);
end

return WuLingMainView;
