--
--Author:      zhuguangyuan
--DateTime:    2018-05-22 16:09:45
--Description: 名册系统 - 某个册系的详情界面
--

local HandbookOneDirDetailView = class("HandbookOneDirDetailView", UIBase);

function HandbookOneDirDetailView:ctor(winName,dirId)
    HandbookOneDirDetailView.super.ctor(self, winName)
    self.dirId = dirId
    -- echo("self.dirId = = = = = = = ",self.dirId)
end

function HandbookOneDirDetailView:loadUIComplete()
	self.loadUiStatus = true
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
	self:refreshLeftAndRightBtn()
end 

function HandbookOneDirDetailView:registerEvent()
	HandbookOneDirDetailView.super.registerEvent(self);
	self.btn_zuo:setTap(c_func(self.clickLeft, self))
	self.btn_rou:setTap(c_func(self.clickRight, self))
	-- 解锁一个阵位
    EventControler:addEventListener(HandbookEvent.HANDBOOK_DATA_UPDATA, self.onOneDirUpgrade, self)
    -- 奇侠上阵下阵及换阵
    -- EventControler:addEventListener(HandbookEvent.HANDBOOK_DATA_UPDATA, self.updateUI, self)
    EventControler:addEventListener(HandbookEvent.ONE_DIR_UPGRADE_SUCCEED, self.onOneDirUpgrade, self)
    EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE, self.updateTitle, self)
end

function HandbookOneDirDetailView:clickLeft(  )
	self.loadUiStatus = true
	local orderArr = FuncHandbook.orderArr
	-- dump(orderArr,"orderArr")
	for i,v in ipairs(orderArr) do
		if self.dirId == v then
			self.orderNum = i
		end
	end
	self.dirId = orderArr[self.orderNum - 1]
	-- echo("self.dirId = = = = = ",self.dirId)
	self:refreshLeftAndRightBtn()
	self:onOneDirUpgrade()
	self:initView()
end

function HandbookOneDirDetailView:clickRight(  )
	self.loadUiStatus = true
	local orderArr = FuncHandbook.orderArr
	-- dump(orderArr,"orderArr")
	for i,v in ipairs(orderArr) do
		if self.dirId == v then
			self.orderNum = i
		end
	end
	local tmpNum = orderArr[self.orderNum + 1]
	-- echo("self.dirId = = = = = ",self.dirId)
	local needLevel = FuncHandbook.getUnlockLevel( tmpNum )
	if UserModel:level() < needLevel then
		WindowControler:showTips(GameConfig.getLanguageWithSwap("#tid_handbooktips_004",needLevel,FuncHandbook.dirId2Name[tmpNum]))
		return
	end
	self.dirId = orderArr[self.orderNum + 1]
	self:refreshLeftAndRightBtn()
	self:onOneDirUpgrade()
	self:initView()
end

function HandbookOneDirDetailView:refreshLeftAndRightBtn(  )
	self.btn_zuo:visible(true)
	self.btn_rou:visible(true)
	if tonumber(self.dirId) == 1 then    --最右边
		self.btn_rou:visible(false)
	end
	if tonumber(self.dirId) == 6 then    --最左边
		self.btn_zuo:visible(false)
	end
end

-- 提升了本名册的等级
function HandbookOneDirDetailView:onOneDirUpgrade(event)
	-- dump(event.params,"params ==================== ")
	if event and event.params then
		for k,v in pairs(event.params[tostring(self.dirId)]) do
			if k == "positions" then
				self.statusArr = event.params
			end
		end
	end
	dump(self.statusArr,"params ====================")
	self:updateData()
	self:updateTitle()
	self:updateUI()
end

function HandbookOneDirDetailView:initData()
	self:updateData()
end
function HandbookOneDirDetailView:updateData()
	local dirLevel = HandbookModel:getOneDirLevel( self.dirId )
	-- echo("dirLevel  = = = = = = = = ",dirLevel)
	self.dirData = FuncHandbook.getOneDirLvData( self.dirId,dirLevel )
	-- echo("_______ self.dirId,dirLevel ",self.dirId,dirLevel)
end

function HandbookOneDirDetailView:initView()
	self:updateTitle()
	self.mc_1:visible(false)
	self.panel_leftTop.ctn_1:removeAllChildren()
	local btnAni = self:createUIArmature("UI_qixiamingce", "UI_qixiamingce_mingceanniu", self.panel_leftTop.ctn_1, true, GameVars.emptyFunc)
	btnAni:setScale(1.4)
	self.panel_leftTop.btn_2:setTap(c_func(self.levelUpOneDir, self))
	self.btn_back:setTap(c_func(self.onClose, self))
	self.btn_1:setTap(c_func(self.lineUpWithOneKey, self))
	self:initScrollCfg()
end

function HandbookOneDirDetailView:updateTitle()
	-- 富文本显示标题
	local dirName = FuncHandbook.dirId2Name[tostring(self.dirId)]
	local color = self.dirData.color
	local curLevel = HandbookModel:getOneDirLevel( self.dirId )
	local dirName1 =self:turnColorRichStr(dirName.."+"..curLevel,color)
	self.panel_leftTop.rich_1:setString(dirName1)

	-- 名册等级变化时加成系数会变化
	local dirLevelAddFactor = (self.dirData.score/100).."%"
	self.panel_leftTop.txt_2:setString(dirLevelAddFactor)

	--是否显示小红点
	local isConditionOk =HandbookModel:isDirCanUpLevel(self.dirId  )
	-- echo("isConditionOk =============zzzzzzzzz============= ",isConditionOk)
	if isConditionOk == true then
		self.panel_leftTop.panel_red:visible(true)
	else
		self.panel_leftTop.panel_red:visible(false)
	end

	local icon = FuncHandbook.getDirIconSp( self.dirId )
	local upPanel = self.panel_leftTop.btn_2:getUpPanel().ctn_1
	upPanel:removeAllChildren()
	icon:parent(upPanel)

end
-- 一键上阵
function HandbookOneDirDetailView:lineUpWithOneKey()
	local freeIndexArr = HandbookModel:isHasFreePosition(self.dirId)
	local sortedPartners = HandbookModel:isHasFreePartners(self.dirId,true)
	-- dump(freeIndexArr, "freeIndexArr", nesting)
	-- dump(sortedPartners, "sortedPartners", nesting)

	if table.length(freeIndexArr) <= 0 then
		WindowControler:showTips("没有空闲阵位")
	elseif table.length(sortedPartners) <= 0 then
		WindowControler:showTips("没有可上阵奇侠")
	else
		if not self.hasSentRequest then
			self.hasSentRequest = true
			local function _callBack( serverData )
				self.hasSentRequest = false
				if serverData.error then
				else
					-- dump(serverData.result, desciption, nesting)
					EventControler:dispatchEvent(HandbookEvent.ONE_PARTNER_ENTER_FIELD)
					HandbookModel:onePartnerPosChanged()
					local userData = UserModel._data
					local totalPower = FuncHandbook.getPowerAdditionOneDir( userData,self.dirId ) 
					-- local guangxiaoAni = self:createUIArmature("UI_qixiamingce", "UI_qixiamingce_shuxingbianhua", self.ctn_1, false, GameVars.emptyFunc)
					-- guangxiaoAni:setScale(2)
					-- self:delayCall(function( )
					-- 	FuncCommUI.showPowerChangeArmature(10, totalPower or 10 );
					-- 	self.ctn_1:removeAllChildren()
					-- end,0.8)
					self:updateUI()
				end
			end
			
			local partnerArr = {}
			for index,partnerId in pairs(sortedPartners) do
				partnerArr[partnerId] = freeIndexArr[tonumber(index)]
			end
			dump(partnerArr, "partnerArr", nesting)
			HandbookServer:enterTheField(self.dirId,partnerArr,_callBack)
		end
	end
end

function HandbookOneDirDetailView:initScrollCfg()
	local createFunc = function(itemData)
		local itemView = UIBaseDef:cloneOneView(self.mc_1)
		self:updateOnePositionView(itemData,itemView)
		return itemView
	end
	local updateFunc = function(itemData,itemView)
		self:updateOnePositionView(itemData,itemView)
		return itemView
	end

    self.scrollParams = {
   		{
	        data = {1,2,3,4,5},
	        createFunc = createFunc,
	        updateCellFunc = updateFunc,
	        perNums= 1,
	        offsetX = 1,
	        offsetY = 9,
	        widthGap = 0,
	        heightGap = 10,
	        itemRect = {x= 0,y=-275,width = 190,height = 343}, 
	        perFrame = 1
	    }
    }
end

function HandbookOneDirDetailView:playAnimation()
	
end

function HandbookOneDirDetailView:updateOnePositionView( itemData,itemView )
	-- dump(itemData, "desciption", nesting)
	local posIndex = itemData
	local positionStatus = HandbookModel:getOneDirPositionStatus( self.dirId )
	local inplacePartnerId = positionStatus[tostring(posIndex)]
	local status = nil
	local contentView = nil
	-- echo("inplacePartnerId =========== ",inplacePartnerId)
	if inplacePartnerId then
		if inplacePartnerId == "" then
			-- echo("1111111111111")
			itemView:showFrame(2)
			contentView = itemView:getCurFrameView()
			local freePartners = HandbookModel:isHasFreePartners(self.dirId)
			-- echo("length = = = == = = ",table.length(freePartners))
			-- echo("dirId = = = = = = = ",self.dirId)
			if freePartners and table.length(freePartners)>0 then
				contentView.panel_red:visible(true)
			else
				contentView.panel_red:visible(false)
			end
			status = 2
		else
			-- echo("2222222222222")
			itemView:showFrame(1)
			status = 1
			contentView = itemView:getCurFrameView()
			contentView.mc_1:showFrame(tonumber(self.dirId))
			local color = self.dirData.color

			-- dump(self.statusArr,"self.statusArr ========= ")
			-- if self.statusArr ~= nil then
			-- 	dump(self.statusArr[tostring(self.dirId)].positions[tostring(posIndex)],"self.statusArr[1].positions[1] ============== ")
			-- end

			if self.statusArr ~= nil and self.statusArr[tostring(self.dirId)].positions[tostring(posIndex)] ~= "" then
				for k,v in pairs(self.statusArr[tostring(self.dirId)].positions) do
					if tonumber(k) == posIndex then
						contentView.ctn_anim:removeAllChildren()
						local fangzhiAni = self:createUIArmature("UI_qixiamingce", "UI_qixiamingce_fangzhiqixia", contentView.ctn_anim, false, GameVars.emptyFunc)
						fangzhiAni:setScale(2.5)
					end
				end
			end 

			local partnerData = PartnerModel:getPartnerDataById(inplacePartnerId)
			local partnerStar = partnerData.star
			contentView.mc_2:showFrame(partnerStar)

			local partnerName = FuncPartner.getPartnerName(partnerData.id)
			-- partnerName = "你．（）"
			partnerName = string.gsub(partnerName, '（', "")
			partnerName = string.gsub(partnerName, '）', "")
			partnerName = string.gsub(partnerName, '[()]', "")

			local dirName1 =self:turnColorRichStr(partnerName,color)
			contentView.rich_1:setString(dirName1)

			local userData = UserModel._data
			local score = FuncHandbook.getScoreOnePartner(userData.partners[inplacePartnerId], userData,self.dirId) 
			contentView.txt_3:setString(score)
			local tag = FuncHandbook.getPartnerTagByScore(score)
			contentView.mc_3:showFrame(tonumber(tag))

			-- 奇侠立绘
			local partnerStaticData = FuncPartner.getPartnerById(inplacePartnerId)
			local bossConfig = partnerStaticData.dynamic
			local arr = string.split(bossConfig, ",");
		    local bossSpine = FuncRes.getArtSpineAni(arr[1])
			local headMaskSprite =  display.newSprite(FuncRes.iconOther("handbook_img_zhezhao"))
		    headMaskSprite:anchor(0.5,0.5)
		    headMaskSprite:pos(2,120)
		   	local itemIcon = FuncCommUI.getMaskCan(headMaskSprite,bossSpine)
		    contentView.ctn_1:removeAllChildren()
		    contentView.ctn_1:addChild(itemIcon)
			-- bossView:pos(10,-80)
			bossSpine:setScale(0.4)
			bossSpine:pos(0,0)
			bossSpine:anchor(0.5,0)
			bossSpine:setAnimation(0, "ui", true);

		end
	else
		itemView:showFrame(3)

		local txtWait = GameConfig.getLanguage("#tid_handbook_daijiesuo")
		itemView.currentView.txt_5:setString(txtWait)
		
		local costZuanshi = FuncHandbook.getCostByDir( self.dirId,posIndex )
		itemView.currentView.txt_1:setString(costZuanshi)
		status = 3
	end

	itemView:setTouchEnabled(true)
	local function _touchFunc( status,posIndex )
		if status == 3 then
			WindowControler:showWindow("HandbookUnlockApositionView", self.dirId,posIndex)
		else
			local positionStatus = HandbookModel:getOneDirPositionStatus( self.dirId )
			local inplacePartnerId = positionStatus[tostring(posIndex)]
			WindowControler:showWindow("HandbookExchangeDirView", self.dirId,inplacePartnerId,posIndex)
		end
	end
	itemView:setTouchedFunc(c_func(_touchFunc,status,posIndex))

	if posIndex == 5 then
		self.statusArr = nil
	end

end

function HandbookOneDirDetailView:levelUpOneDir()
	local curLevel = HandbookModel:getOneDirLevel( self.dirId )
	local maxLevel = FuncHandbook.getOneDirMaxLevel( self.dirId )
	if tonumber(curLevel) < tonumber(maxLevel) then
		WindowControler:showWindow("HandbookUpgradeOneDirView", self.dirId)
	else
		WindowControler:showTips("已达到最大等级,不可再提升")
	end
end

function HandbookOneDirDetailView:initViewAlign()
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_middleTop, UIAlignTypes.MiddleTop)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_leftTop, UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_title, UIAlignTypes.LeftTop)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.txt_tips, UIAlignTypes.LeftBottom)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_1, UIAlignTypes.RightBottom)
    -- FuncCommUI.setScrollAlign(self.widthScreenOffset, self.scroll_1,UIAlignTypes.Middle,1,nil,1)
end

-- 更新
function HandbookOneDirDetailView:updateUI(event)
	if event and event.name then
		echo("\n____event.name______",event.name)
	end
	self:updatePropertyUI()
	self:updatePositionUI()
end

-- 更新评分 战力 属性加成
function HandbookOneDirDetailView:updatePropertyUI()
	local userData = UserModel._data
	local totalScore = FuncHandbook.getScoreOneDir( userData,self.dirId ) 
	-- self.panel_middleTop.txt_4:setString(totalScore)
	local dirName = FuncHandbook.dirId2Name[tostring(self.dirId)]
	local dirName1 = GameConfig.getLanguage("#tid_handbooktype_100"..tostring(self.dirId))
	-- echo("dirId = = = = = = = ",self.dirId)
	self.panel_middleTop.rich_pingfen:setString(FuncTranslate._getLanguageWithSwap("#tid_handbook_pingfen",dirName,totalScore ) )
	self.panel_middleTop.txt_5:setString(FuncTranslate._getLanguageWithSwap("#tid_handbook_shuxing",dirName1 ))
	local totalPower = FuncHandbook.getPowerAdditionOneDir( userData,self.dirId )
	echo("totalPower =========== ",totalPower)
	if not self.loadUiStatus then 
		if self.totalPower then
			if self.totalPower < totalPower then
				self:delayCall(function( )
					local guangxiaoAni1 = self:createUIArmature("UI_qixiamingce", "UI_qixiamingce_shuxingbianhua", self.ctn_1, false, GameVars.emptyFunc)
					local guangxiaoAni2 = self:createUIArmature("UI_qixiamingce", "UI_qixiamingce_shuxingbianhua", self.ctn_2, false, GameVars.emptyFunc)
					guangxiaoAni1:setScale(2)
					guangxiaoAni2:setScale(1.5)
					self:delayCall(function( )
						FuncCommUI.showPowerChangeArmature(10, totalPower or 10 );
						self.ctn_1:removeAllChildren()
					end,0.8)
				end,0.5)
			elseif self.totalPower > totalPower then
				self:delayCall(function( )
					local guangxiaoAni1 = self:createUIArmature("UI_qixiamingce", "UI_qixiamingce_shuxingbianhua", self.ctn_1, false, GameVars.emptyFunc)
					local guangxiaoAni2 = self:createUIArmature("UI_qixiamingce", "UI_qixiamingce_shuxingbianhua", self.ctn_2, false, GameVars.emptyFunc)
					guangxiaoAni1:setScale(2)
					guangxiaoAni2:setScale(1.5)
				end,0.5)
			end
		end
	end  
	self.totalPower = totalPower
	self.panel_middleTop.txt_10:setString("战斗力 +"..totalPower)

	local showRule = function (  )
		WindowControler:showWindow("HandbookRuleView")
	end

	self.panel_title.btn_rule:setTap(showRule)

	local arr = FuncHandbook.getPropertyAddFromOneDir(userData,self.dirId)
	local properties = FuncHandbook.formatProperties( arr )

	local i=6
	for k,v in pairs(properties) do
		local pStr = FuncBattleBase.getAttributeName( k )
		local value1 = ""
		for changeMode,value in pairs(v) do
			value1 = value
			if tonumber(changeMode) == 2 then
				value1 = (math.floor(value1/100)).."%"
			elseif tonumber(changeMode) == 1 then
			end
			-- pStr = pStr.." +"..value1
		end
		if self.panel_middleTop["txt_"..i] then
			self.panel_middleTop["txt_"..i]:visible(true)
			self.panel_middleTop["txt_"..i]:setString("+".. value1)

			self.panel_middleTop["txt_"..i..i]:visible(true)
			self.panel_middleTop["txt_"..i..i]:setString(pStr)
		end
		i = i + 1
	end
	for ii=i,9 do
		if self.panel_middleTop["txt_"..ii] then
			self.panel_middleTop["txt_"..ii]:visible(false)
			self.panel_middleTop["txt_"..ii..ii]:visible(false)
		end
	end
	self.loadUiStatus = false
end

-- 更新阵位scorllView
function HandbookOneDirDetailView:updatePositionUI()
    -- self.scroll_1:cancleCacheView()
    self.scroll_1:styleFill(self.scrollParams)
    self.scroll_1:hideDragBar()
    self.scroll_1:refreshCellView(1)
end

function HandbookOneDirDetailView:deleteMe()
	HandbookOneDirDetailView.super.deleteMe(self);
end

function HandbookOneDirDetailView:onClose( ... )
	self:startHide()
end

function HandbookOneDirDetailView:turnColorRichStr( str,color )
	return  "<color="..color..">"..str .."<->"
end


return HandbookOneDirDetailView;
