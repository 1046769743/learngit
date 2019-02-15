--
--Author:      zhuguangyuan
--DateTime:    2017-09-25 19:29:27
--Description: 新版情缘系统 主奇侠 的界面
--
-- 1.陌生友好等原是情缘值的描述  改为对情缘等级的描述
-- 2.屏蔽跑环任务

local NewLovePartnerView = class("NewLovePartnerView", UIBase);


function NewLovePartnerView:ctor(winName,MainPartnerId,curPartnerId)
    NewLovePartnerView.super.ctor(self, winName)
    self.mainPartnerId = MainPartnerId
    self.curPartnerId = curPartnerId
    echo("_____ MainPartnerId,self.mainPartnerId _______", MainPartnerId, curPartnerId)
end

function NewLovePartnerView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:updateData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
	-- self:addChatAndQuest()
end 

function NewLovePartnerView:updateNewLovePartnerView(MainPartnerId, curPartnerId)
	self.mainPartnerId = MainPartnerId
    self.curPartnerId = curPartnerId
	self:updateData()
	self:updateUI()
end

function NewLovePartnerView:initData()
	-- 事件对应的处理函数
	self.funcMap = {
    	["NEWLOVEEVENT_ONE_LOVE_LEVEL_UP_GRADE"] = "onLoveLevelUpSucceed",
        ["NEWLOVEEVENT_ONE_PARTNER_RESONATE_ONE_STEP"] = "onLoveResonanceUpSucceed",
        ["NEWLOVEEVENT_ANIMATION_OVER_EVENT"] = "playAnimation",
    	["NEWLOVEEVENT_BATTLE_WIN"] = "onPlotFinish",
    	["GET_FIRST_CHARGE_REWARD_EVENT"] = "onPartnerInfoChange",
    	["PARTNER_LEVELUP_EVENT"] = "onPartnerInfoChange",
    	["PARTNER_STAR_LEVELUP_EVENT"] = "onPartnerInfoChange",
    	["PARTNER_QUALITY_CHANGE_EVENT"] = "onPartnerInfoChange",
    	["PARTNER_HECHENG_SUCCESS_EVENT"] = "onPartnerInfoChange",
	}

    self.propertyMap = {
        ["2"] = "生命",
        ["10"] = "攻击",
        ["11"] = "物防",
        ["12"] = "法防",
    }
    NewLoveModel.haveSentLoveLevelUpRequest = false
    NewLoveModel.haveSentResonateLevelUpRequest = false
end

function NewLovePartnerView:onBecomeTopView()
	
end

-- ===== 战斗进入与恢复
-- ===== 注意这两个函数是在 WindowControler 的进入战斗和退出战斗恢复ui时调用的
function NewLovePartnerView:getEnterBattleCacheData()
    -- echoError("\n 战斗前缓存view数据 NewLovePartnerView")
    return  {
                vicePartnerId = self.currentVicePartnerId,
            }
end
function NewLovePartnerView:onBattleExitResume(cacheData)
    dump(cacheData,"\n\n战斗恢复view NewLovePartnerView")
    NewLovePartnerView.super.onBattleExitResume(cacheData)
    if cacheData and cacheData.vicePartnerId then    	
        self:updateChooseEffect(cacheData.vicePartnerId)
        self:updateVicePartner(cacheData.vicePartnerId)
        self:updateVicePartnerProperty(cacheData.vicePartnerId)
    end
end


function NewLovePartnerView:registerEvent()
	NewLovePartnerView.super.registerEvent(self);
	self.btn_back:setTap(c_func(self.onClose, self))  -- 返回

	-- 一条情缘升级成功
    EventControler:addEventListener(NewLoveEvent.NEWLOVEEVENT_ONE_LOVE_LEVEL_UP_GRADE, self.updateUIByDelayTime, self)
   	-- 伙伴共鸣升阶成功
    EventControler:addEventListener(NewLoveEvent.NEWLOVEEVENT_ONE_PARTNER_RESONATE_ONE_STEP, self.updateUIByDelayTime, self)

    -- 首充唤醒赵灵儿 刷新赵灵儿
    EventControler:addEventListener(ChargeEvent.GET_FIRST_CHARGE_REWARD_EVENT,self.updateUIByDelayTime, self); 

    -- 播放特效字和飘字
    EventControler:addEventListener(NewLoveEvent.NEWLOVEEVENT_ANIMATION_OVER_EVENT, self.updateUIByDelayTime, self)

    -- 某一个伙伴升级/升品/升星成功
    EventControler:addEventListener(PartnerEvent.PARTNER_LEVELUP_EVENT, self.updateUIByDelayTime, self)
    EventControler:addEventListener(PartnerEvent.PARTNER_STAR_LEVELUP_EVENT, self.updateUIByDelayTime, self)
    EventControler:addEventListener(PartnerEvent.PARTNER_QUALITY_CHANGE_EVENT, self.updateUIByDelayTime, self)
    EventControler:addEventListener(PartnerEvent.PARTNER_HECHENG_SUCCESS_EVENT, self.updateUIByDelayTime, self)

    -- 战斗胜利，剧情任务完成
    EventControler:addEventListener(NewLoveEvent.NEWLOVEEVENT_BATTLE_WIN, self.updateUIByDelayTime, self)
end
--关闭按钮
function NewLovePartnerView:onClose()
	self:startHide()
end

-- 延迟1秒调用响应函数
-- 使数据及时更新
function NewLovePartnerView:updateUIByDelayTime(event)
	local params = event.params
    local delayUpdateUI = function()
    	local funcKey = self.funcMap[event.name]
    	self[funcKey](self,params)
    end
    self:delayCall(c_func(delayUpdateUI), 0)
end

-- 更新右侧属性界面
-- 更新相应的情缘线
function NewLovePartnerView:onLoveLevelUpSucceed(params)
	-- dump(params," 情缘升级成功后的 回调 params -----")
	local loveId = params.loveId
	local level = params.lv
	self.txtArr = params.txtArr
	self.nowLevel = level
	-- echo("level ============ lplplplplplplplplp ====== ",level)
	--
	--Author:      zhuguangyuan
	--DateTime:    2018-06-07 17:36:04
	--Description: 四测屏蔽跑环,特效也用回以前的

	-- 先刷新按钮
	local mainPartnerId = FuncNewLove.getLoveMainPartnerIdByLoveId(loveId)
	local vicePartnerId = FuncNewLove.getLoveVicePartnerIdByLoveId(loveId)
	self.ctn_love1:removeAllChildren()
	self.ctn_love:removeAllChildren()
	self.ctn_love2:removeAllChildren()
	local firstAni = self:createUIArmature("UI_tishitexiao", "UI_tishitexiao_saoguang", self.ctn_love1, false, GameVars.emptyFunc)
	if level < FuncNewLove.maxLevel then
		local secondAni = self:createUIArmature("UI_tishitexiao", "UI_tishitexiao_saoguang", self.ctn_love, false, GameVars.emptyFunc)
		secondAni:setScaleX(1.2)
		secondAni:setScaleY(0.9)
	end
	local blinkAni = self:createUIArmature("UI_tishitexiao", "UI_tishitexiao_shan02", self.ctn_love2, false, GameVars.emptyFunc)

	firstAni:setScaleX(1.2)
	firstAni:setScaleY(0.9)
	

	-- self:refreshStatusBtn(vicePartnerId)
	self.vicePartnerId = vicePartnerId
	self:updateData()
	self:updateChooseEffect(self.vicePartnerId)
	self:updateVicePartner(self.vicePartnerId)
	NewLoveModel.haveSentLoveLevelUpRequest = false
	self:updateMainPartnerProperty()

	self:delayCall(function( )
        self.ctn_love1:removeAllChildren()
		self.ctn_love:removeAllChildren()
		-- self.vicePartnerId = vicePartnerId
		-- self:updateData()
		-- self:updateChooseEffect(self.vicePartnerId)
		self:updateVicePartnerProperty(self.vicePartnerId)
		-- self:updateVicePartner(self.vicePartnerId)
		-- NewLoveModel.haveSentLoveLevelUpRequest = false
		-- self:updateMainPartnerProperty()
    end,1.3)

end

function NewLovePartnerView:playAnimation()
	local function _callBack( ... )
		local _curPower = PartnerModel:getPartnerAbility(self.mainPartnerId)
		-- echo("________ 战力提升 ____self._oldPower,_curPower___________ ",self._oldPower,_curPower)
		FuncCommUI.showPowerChangeArmature(self._oldPower or 10, _curPower or 10 );
	end

	local _ctn = self.ctn_1
	local isEffectType
	-- echo("self.nowLevel ================ ",self.nowLevel)
	if self.nowLevel == 1 then
		isEffectType = FuncCommUI.EFFEC_NUM_TTITLE.ACTIVATION
	else
		isEffectType = FuncCommUI.EFFEC_NUM_TTITLE.HOISTING 
	end
	_ctn:removeAllChildren()
	local data = {text = self.txtArr, isAnimation = nil, isEffectType = isEffectType, callBack = _callBack}
	FuncCommUI.playNumberRunaction(_ctn,data)
end

-- 更新右侧属性界面
-- 更新主界面相应伙伴的阶色
function NewLovePartnerView:onLoveResonanceUpSucceed(params)
	dump(params," 共鸣升级成功后的 回调 params -----")
	echo("=========== 副伙伴id =========== ",params.vicePartnerId)
	
	local mainPartnerId = params.partnerId
	local level = params.level
	local vicePartnerId = params.vicePartnerId
	self:updateData()
	self:updateChooseEffect(mainPartnerId)
	self:updateVicePartnerProperty(vicePartnerId)
	self:updateMainPartner()
	self:updateMainPartnerProperty()
	self:resonanceBtn()

	-- local name = FuncPartner.getPartnerName(mainPartnerId)
	-- local str = name.."的共鸣属性提升至"..level.."阶!"
	-- -- WindowControler:showTips( { text = str })
	-- NewLoveModel.haveSentResonateLevelUpRequest = false
	-- if not self.levelUpEff then
	-- 	self.levelUpEff = self:createUIArmature("UI_qingyuan_tisheng","UI_qingyuan_tisheng", self.ctn_1, true,GameVars.emptyFunc)
	-- end
	-- self.levelUpEff:startPlay(true)
	-- local function callBack( ... )
	-- 	local _curPower = PartnerModel:getPartnerAbility(mainPartnerId)
	-- 	FuncCommUI.showPowerChangeArmature(self._oldPower or 10, _curPower or 10 );
	-- end
	-- self.levelUpEff:doByLastFrame( false, true ,callBack)
end

-- 剧情任务完成，刷新副伙伴界面右侧
function NewLovePartnerView:onPlotFinish(params)

end

-- 监听完成伙伴养成类型的任务的情况
-- 进行界面刷新
function NewLovePartnerView:onPartnerInfoChange(params)
	-- echo("1111111111111111111111111111111111")
	-- dump(params," 养伙伴 成功后的 回调 event.params -----")
	local vicePartnerId = nil
	if params.id then
		vicePartnerId = params.id
		-- echo("_________________________ 事件返回的伙伴id",vicePartnerId)
	else
		vicePartnerId = params
		-- echo("新和成的伙伴id",vicePartnerId)
	end
	
	-- if tostring(vicePartnerId) == self.mainPartnerId then
	-- 	vicePartnerId = self.associatedPartnerId
	-- end
	
	if tostring(vicePartnerId) == tostring(self.associatedPartnerId) then
		-- 主奇侠走这里
		self.vicePartnerId = vicePartnerId
		self:updateData()
		self:updateUI()		
		self:updateChooseEffect(self.vicePartnerId)
		self:updateVicePartner(self.vicePartnerId)
		self:updateVicePartnerProperty(self.vicePartnerId)
	elseif self.associatedPartnerId then
		-- 副奇侠走这里
		self:updateData()
		self:updateUI()
		self:updateChooseEffect(self.associatedPartnerId)
		self:updateVicePartner(self.associatedPartnerId)
		self:updateVicePartnerProperty(self.associatedPartnerId)
	end
end

-- 监听情缘值改变的消息
-- 进行界面刷新
function NewLovePartnerView:onLoveValueChange(event)

end


-- 监听剧情完成的消息
-- 进行界面刷新
function NewLovePartnerView:onPlotFinish(event)

end

-- PVE战斗前初始化
function NewLovePartnerView:getServerBattleDataCallBack(event)
	if event.error then
		if event.error.code == 510702 then 
			WindowControler:showTips( GameConfig.getLanguage("#tid_loveGlobal_006"))
		elseif event.error.code == 510703 then
			WindowControler:showTips( GameConfig.getLanguage("#tid_loveGlobal_007"))
		end
	end

    if event.result ~= nil then
        -- dump(event.result.data.battleInfo,"event.result.data.battleInfo ========== ")

        -- 缓存用户数据
        UserModel:cacheUserData()
        -- 发送关闭布阵界面消息，关闭布阵界面
        EventControler:dispatchEvent(BattleEvent.CLOSE_TEAM_FORMATION_FOR_BATTLE)

        local battleInfo = BattleControler:turnServerDataToBattleInfo(event.result.data.battleInfo)
        -- 本地根据战斗数据进行战斗演示
        BattleControler:startPVE(battleInfo)
    end
end

function NewLovePartnerView:updateData()
	-- 主伙伴的相关数据
	self.mainPartnerData =  PartnerModel:getPartnerDataById(self.mainPartnerId)
    self.isHaveMainPartner = PartnerModel:isHavedPatnner(self.mainPartnerId)
	-- dump(self.mainPartnerData,"主伙伴数据 ")
	if not self.mainPartnerData then
		self.mainPartnerStar = 0
		self.mainPartnerLoves = {} 
		self.mainPartnerResonateLv = 0
	else
		self.mainPartnerStar = self.mainPartnerData.star
		self.mainPartnerLoves = self.mainPartnerData.loves 
		self.mainPartnerResonateLv = self.mainPartnerData.resonanceLv
		echo("主伙伴共鸣等级-- ",self.mainPartnerResonateLv)
	end
	-- 所有副伙伴id
	self.partners = FuncNewLove.getVicePartnersListByPartnerId(self.mainPartnerId)
end

function NewLovePartnerView:initView()
	-- self.panel_bg.panel_1:zorder(1000)
end

function NewLovePartnerView:initViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_name, UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_right, UIAlignTypes.Right)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_du, UIAlignTypes.Left)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_love1, UIAlignTypes.Left)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_love, UIAlignTypes.Left)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_tiao1, UIAlignTypes.Left)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_tiao2, UIAlignTypes.Left)
end


function NewLovePartnerView:updateUI()
	-- 默认选中主奇侠
	-- self:updateChooseEffect(self.mainPartnerId)
	self:updateMainPartner()
	self:updateMainPartnerProperty()

	-- 更新副奇侠们的界面
	local canShowRedPoint
	local readPointArr = {}    --- 如果有红点显示 就把当前的vicePartnerId加到这个数组里
	for k,vicePartnerId in ipairs(self.partners) do
		self:updateVicePartner(vicePartnerId)
		canShowRedPoint = NewLoveModel:isShowVicePartnerRedPoint(self.mainPartnerId,vicePartnerId)
		if canShowRedPoint then
			table.insert(readPointArr,vicePartnerId)
		end
	end
	if #readPointArr ~= 0 then  -- 如果数组不为空 说明情缘可以提升 则取数组里面key为1的value 默认选中最高的一个有红点的头像
		local curPartnerId = readPointArr[1]
		if self.curPartnerId then
			curPartnerId = self.curPartnerId
		end

		self:updateChooseEffect(curPartnerId)
		self:updateVicePartner(curPartnerId)
		self:updateVicePartnerProperty(curPartnerId)
	else  --否则走原来逻辑
		local lastIndex = NewLoveModel:getLastChoosedPartnerIndex()
		local lastPartnerId = nil
		for k,v in ipairs(self.partners) do
			self:updateVicePartner(v)
			if tonumber(lastIndex) == tonumber(k) then
				lastPartnerId = v
				local _data = FuncPartner.getPartnerById(lastPartnerId)
	    		local _isShow = _data.isShow
				if _isShow == 0 then
					for kk,vv in ipairs(self.partners) do
						local _data = FuncPartner.getPartnerById(vv)
	    				local _isShow = _data.isShow
						if _isShow ~= 0 then 
							NewLoveModel:setLastChoosedPartnerIndex(kk)
							lastPartnerId = vv
						end
					end
				end
			end
		end

		if self.curPartnerId then
			lastPartnerId = self.curPartnerId
		end

		self:updateChooseEffect(lastPartnerId)
		self:updateVicePartner(lastPartnerId)
		self:updateVicePartnerProperty(lastPartnerId)
	end
	

	if #self.partners < 4 then
		local num = #self.partners + 1
		for k = 4,num,-1 do
			self.panel_right["panel_tou"..tostring(k)]:setVisible(false)
		end
	end

end

--------------------------------------------------------------------------
---------------------- 主伙伴    -----------------------------------------
--------------------------------------------------------------------------
-- 更新主伙伴头像相关
function NewLovePartnerView:updateMainPartner()
	-- 主奇侠名字
	local name = FuncPartner.getPartnerName(self.mainPartnerId)
	-- self.panel_bg.panel_lihui.txt_name:setString(name)
	self.panel_bg.panel_lihui:setTouchedFunc(function() end)
end

-- 更新主伙伴右侧属性
function NewLovePartnerView:updateMainPartnerProperty()
	-- local contentView = nil
	-- self.mc_du:showFrame(1)
	-- mcView = self.mc_du:getCurFrameView()
	-- contentView = mcView.panel_3

	-- -- 情缘加成 
	-- local mainPartnerName = FuncPartner.getPartnerName(self.mainPartnerId)
	-- contentView.panel_1.txt_biaoti:setString(mainPartnerName..GameConfig.getLanguage("#tid_loveGlobal_008"))
	-- local totalProperties = self:totalAddAbilities( self.mainPartnerId,self.mainPartnerResonateLv )
	-- local i = 1
	-- for k,v in pairs(totalProperties) do
	-- 	contentView.panel_1["rich_"..i]:setString(self.propertyMap[k].."+"..tostring(v/100).."%")
	-- 	i = i + 1
	-- end

	-- -- 共鸣属性
	-- local resonanceLv = self.mainPartnerResonateLv
	-- if resonanceLv < FuncNewLove.maxLevel then
	-- 	local inVisible = 1
	-- 	contentView.panel_2.mc_1:showFrame(1)
	-- 	resonanceView = contentView.panel_2.mc_1:getCurFrameView()
 --        -- 当前阶
 --        if resonanceLv == 0 then
 --            resonanceView.mc_1:showFrame(1)
 --            local tips = GameConfig.getLanguage("#tid_love_tip_1910")
 --            resonanceView.txt_1:setString(GameConfig.getLanguage("#tid_loveGlobal_009")) 
 --            resonanceView.txt_2:setVisible(false)
 --            resonanceView.txt_3:setVisible(false)
 --            resonanceView.txt_4:setVisible(false)
 --        else
 --            local dataArr = FuncNewLove.getResonatePropertyBypartnerId(self.mainPartnerId,resonanceLv)
 --            resonanceView.mc_1:showFrame( resonanceLv + 1)  
 --            for k,v in ipairs(dataArr) do
 --            	resonanceView["txt_"..k]:setVisible(true)
 --            	resonanceView["txt_"..k]:setString(self.propertyMap[tostring(v.property)].."+"..tostring(v.value/100).."%")
 --            	inVisible = k + 1
 --            end  
 --            for k = inVisible,4 do
 --        		addPropertyView["txt_"..k]:setVisible(false)
 --        	end 
 --        end
 --        -- 目标阶
	-- 	dataArr = FuncNewLove.getResonatePropertyBypartnerId(self.mainPartnerId,resonanceLv + 1)
	-- 	resonanceView.mc_2:showFrame( resonanceLv + 2 )
	--     for k,v in ipairs(dataArr) do
	--     	resonanceView["txt_"..(k+4)]:setVisible(true)
 --        	resonanceView["txt_"..(k+4)]:setString(self.propertyMap[tostring(v.property)].."+"..tostring(v.value/100).."%")
 --        	inVisible = k + 1
 --        end  
 --        for k = inVisible,4 do
 --        	addPropertyView["txt_"..(k+4)]:setVisible(false)
 --        end 
	-- elseif resonanceLv == FuncNewLove.maxLevel then
	-- 	contentView.panel_2.mc_1:showFrame(2)
	-- 	resonanceView = contentView.panel_2.mc_1:getCurFrameView()

	-- 	local dataArr = FuncNewLove.getResonatePropertyBypartnerId(self.mainPartnerId,resonanceLv)
	-- 	resonanceView.mc_1:showFrame( resonanceLv + 1)
	--     for k,v in ipairs(dataArr) do
	--     	resonanceView["txt_"..k]:setVisible(true)
 --        	resonanceView["txt_"..k]:setString(self.propertyMap[tostring(v.property)].."+"..tostring(v.value/100).."%")
 --        	inVisible = k + 1
 --        end  
 --        for k = inVisible,4 do
 --        	addPropertyView["txt_"..k]:setVisible(false)
 --        end  		
	-- end

	-- -- 共鸣状态及升阶
	-- if resonanceLv == FuncNewLove.maxLevel then
	-- 	contentView.panel_2.mc_gongming:showFrame(3)
	-- else
	-- 	local isFinish = NewLoveModel:isCanResonate(self.mainPartnerId)
	-- 	if isFinish then
	-- 		contentView.panel_2.mc_gongming:showFrame(2)
	-- 		panelView = contentView.panel_2.mc_gongming:getCurFrameView()
	-- 		local canShowRedPoint = NewLoveModel:isShowResonanceRedPoint(self.mainPartnerId)
	-- 		panelView.btn_gongming:getUpPanel().panel_red:visible(canShowRedPoint)
	-- 		panelView.btn_gongming:setTap(function()
	-- 			if NewLoveModel.haveSentResonateLevelUpRequest then
	-- 				return
	-- 			end
	-- 			NewLoveModel.haveSentResonateLevelUpRequest = true
	-- 			self._oldPower = PartnerModel:getPartnerAbility(self.mainPartnerId)
	-- 			echo("_________ 主伙伴当前战力 ________ ",self._oldPower)
	-- 			NewLoveModel:loveResonanceUp(self.mainPartnerId)
	-- 		end)
	-- 	else
	-- 		contentView.panel_2.mc_gongming:showFrame(1)
	-- 		panelView = contentView.panel_2.mc_gongming:getCurFrameView()
	-- 		-- panelView.txt_x1
	--             -- 情缘阶进度条组
	--         -- 注意顺序要与左侧副奇侠顺序一致
	--         local targetResonateLevel = nil
	--         if self.mainPartnerResonateLv < FuncNewLove.maxLevel then
	--             targetResonateLevel = self.mainPartnerResonateLv + 1
	--         else
	--             targetResonateLevel = self.mainPartnerResonateLv
	--         end
	--         local inVisible = nil
	--         for k,vicePartnerId in ipairs(self.partners) do
	--             local loveId,loveLevel,loveValue = NewLoveModel:getVicePartnerLoveData( self.mainPartnerId,vicePartnerId,self.mainPartnerLoves )
	            
	--             local name = FuncPartner.getPartnerName(vicePartnerId)
	--             -- local str = loveLevel.."/"..targetResonateLevel
	--             -- local percent = nil
	--             if loveLevel >= targetResonateLevel then
	--                 -- percent = 100 
	--                 panelView["panel_tiao"..k].mc_1:showFrame(3)
	--             else
	--                 -- percent = loveLevel/targetResonateLevel * 100
	--                 panelView["panel_tiao"..k].mc_1:showFrame(2)
	--             end
	--             panelView["panel_tiao"..k].txt_2:setString(mainPartnerName)
	--             panelView["panel_tiao"..k].txt_1:setString(name)
	--             panelView["panel_tiao"..k].panel_tiao.mc_1:showFrame(targetResonateLevel)

	--             local loveTipsDesc = FuncNewLove.getLoveLevelDescById(loveId,targetResonateLevel)
	-- 			loveTipsDesc = GameConfig.getLanguage(loveTipsDesc)
	-- 			panelView["panel_tiao"..k].panel_tiao.mc_1:getCurFrameView().txt_1:setString(loveTipsDesc)
	--             inVisible = k + 1
	--         end
	--         for k = inVisible,4 do
	--             panelView["panel_tiao"..k]:setVisible(false)
	--         end
	-- 	end
	-- end
end

--------------------------------------------------------------------------
---------------------- 副        -----------------------------------------
--------------------------------------------------------------------------
-- 更新副伙伴头像相关
-- 更新情缘值相关（情缘阶文字）
function NewLovePartnerView:updateVicePartner(vicePartnerId)
	local k = self:getPartnerRank(vicePartnerId)
	local partnerView = self.panel_right["panel_tou"..tostring(k)]

	-------------------------------------------
	-- 未投放伙伴需做特殊处理
	local panelView = nil
    local _data = FuncPartner.getPartnerById(vicePartnerId)
    local _isShow = _data.isShow
    if _isShow == 0 then
    	partnerView.panel_1.mc_1:showFrame(2)
    	-- partnerView.panel_tiao:setVisible(false)
    	-- partnerView.mc_1:setVisible(false)
    	partnerView.panel_1.panel_red:setVisible(false)

		-- 奇侠名字
		local name = FuncPartner.getPartnerName(vicePartnerId)
		-- partnerView.panel_1.txt_1:setString(name)

    	panelView = partnerView.panel_1.mc_1:getCurFrameView()
    	panelView:setTouchedFunc(function()
			WindowControler:showTips( GameConfig.getLanguage("tid_common_2053"))
		end)
		return
    else
    	partnerView.panel_1.mc_1:showFrame(1)
    	panelView = partnerView.panel_1.mc_1:getCurFrameView()
    end

	-------------------------------------------
    -- 已经投放的伙伴
	local _quality = "1"
	local _skin = ""
	local _level = 1 
	local _star = 1 

	local partnerData = PartnerModel:getPartnerDataById(vicePartnerId)
	if partnerData then
		_quality = partnerData.quality
		_skin = partnerData.skin
		_level = partnerData.level
		_star = partnerData.star
	end

    -- 奇侠头像
    local _spriteIcon = FuncPartner.getPartnerIconByIdAndSkin( vicePartnerId, _skin)
    --
    local headMaskSprite = display.newSprite(FuncRes.iconOther("partner_bagmask"))
    headMaskSprite:anchor(0.5,0.5)
    headMaskSprite:pos(-1,0)
    headMaskSprite:setScale(0.99)
    --
    _spriteIcon = FuncCommUI.getMaskCan(headMaskSprite,_spriteIcon)
    panelView.UI_1.ctn_1:removeAllChildren()
    panelView.UI_1.ctn_1:addChild(_spriteIcon)
    _spriteIcon:scale(1.2)

    -- 点击头像响应
    partnerView.panel_1:setTouchedFunc(function()
        -- 更新选中效果
        self.vicePartnerId = vicePartnerId
        self:updateChooseEffect(self.vicePartnerId)
        self:updateVicePartner(self.vicePartnerId)
        self:updateVicePartnerProperty(self.vicePartnerId)
    end)

    local isHavePartner = PartnerModel:isHavedPatnner(vicePartnerId)
    partnerView.isHasPartner = isHavePartner
    -- 还没拥有伙伴则情缘肯定不能升级
    if not isHavePartner or not self.isHaveMainPartner then
        FilterTools.setGrayFilter(_spriteIcon)
        -- itemView.panel_red:setVisible(false)
		panelView.UI_1.mc_kuang:showFrame(1)
		-- panelView.UI_1.mc_di:showFrame(1)

		panelView.UI_1.panel_lv:setVisible(false)
    	panelView.UI_1.mc_dou:setVisible(false)
    	partnerView.panel_1.panel_red:setVisible(false)
        -- partnerView.mc_jindu:showFrame(1)
        -- partnerView.mc_di:showFrame(3)
    else
    	panelView.UI_1.panel_lv:setVisible(true)
    	panelView.UI_1.mc_dou:setVisible(true)
    	partnerView.panel_1.panel_red:setVisible(true)

    	-- 奇侠品质
        local quality = FuncPartner.getPartnerQuality(tostring(vicePartnerId))
        if quality then
        	frameNum = quality[tostring(_quality)].color
    		panelView.UI_1.mc_kuang:showFrame(frameNum)
    		-- panelView.UI_1.mc_di:showFrame(frameNum)
    	end

        -- 等级和星级
    	panelView.UI_1.panel_lv.txt_3:setString(_level)
    	panelView.UI_1.mc_dou:showFrame(_star)

    	-- 红点
    	local canShowRedPoint = NewLoveModel:isShowVicePartnerRedPoint(self.mainPartnerId,vicePartnerId)
        partnerView.panel_1.panel_red:setVisible(canShowRedPoint)
    end

    -- 显示主副伙伴立绘
	local cfgData = FuncPartner.getPartnerById(vicePartnerId)
	local bossConfig = cfgData.dynamic
	local arr = string.split(bossConfig, ",");
    local viceSpine = FuncRes.getArtSpineAni(arr[1])
	viceSpine:pos(-180,-150)
    viceSpine:setScale(0.6)
    viceSpine:anchor(0.5,0)
	viceSpine:setAnimation(0, "ui", true) 
	local viceSpineContainer = display.newNode()
	viceSpine:addTo(viceSpineContainer)
	local viceMaskSprite =  display.newSprite(FuncRes.iconOther("activity_bg_zhezhao"))
	local viceSpineNode = FuncCommUI.getMaskCan(viceMaskSprite,viceSpineContainer)

    local cfgData2 = FuncPartner.getPartnerById(self.mainPartnerId)
	local bossConfig2 = cfgData2.dynamic
	local arr2 = string.split(bossConfig2, ",");
    local mainSpine = FuncRes.getArtSpineAni(arr2[1])
    mainSpine:pos(180,-150)
    mainSpine:setScale(0.6)
    mainSpine:anchor(0.5,0)
	mainSpine:setAnimation(0, "ui", true) 
	local mainSpineContainer = display.newNode()
	mainSpine:addTo(mainSpineContainer)
	local mainMaskSprite =  display.newSprite(FuncRes.iconOther("activity_bg_zhezhao"))
	local mainSpineNode = FuncCommUI.getMaskCan(mainMaskSprite,mainSpineContainer)
	viceSpineNode:pos(275,0)
	mainSpineNode:pos(-275,0)

	local spineContainer = display.newNode()
    spineContainer:removeAllChildren()
    spineContainer:addChild(viceSpineNode)
    spineContainer:addChild(mainSpineNode)
    local headMaskSprite =  display.newSprite(FuncRes.iconOther("love_img_zhezhaoyuan"))
    local cheekMaskSprite =  display.newSprite(FuncRes.iconOther("love_img_lihuizhezhao1"))
    headMaskSprite:anchor(0.5,0):scale(1.68):pos(0,-229)
    cheekMaskSprite:anchor(0.5,0):scale(1.68):pos(0,-229)
    local itemIcon = FuncCommUI.getMaskCan(headMaskSprite,spineContainer)
    self.panel_bg.panel_lihui.ctn_zhezhao:removeAllChildren()
    self.panel_bg.panel_lihui.ctn_zhezhao:addChild(itemIcon)
    self.panel_bg.panel_lihui.ctn_zhezhao:addChild(cheekMaskSprite)

    if not PartnerModel:isHavedPatnner(vicePartnerId) then
    	FilterTools.setGrayFilter( viceSpine ,120 )
    	self.panel_h2:setVisible(true)
    else
    	FilterTools.clearFilter( viceSpine )
    	self.panel_h2:setVisible(false)
    end
    if not PartnerModel:isHavedPatnner(self.mainPartnerId) then
    	FilterTools.setGrayFilter( mainSpine ,120 )
    	self.panel_h1:setVisible(true)
    else
    	FilterTools.clearFilter( mainSpine )
    	self.panel_h1:setVisible(false)
    end
    self.panel_bg.panel_jingzi2:zorder(1000)

    self:refreshStatusBtn(vicePartnerId)
end

-- 根据伙伴id获取其在伙伴列表中的序号 k
-- 对应 self.panel_right["panel_tou"..tostring(k)] 框
function NewLovePartnerView:getPartnerRank(vicePartnerId)
	for k,v in ipairs(self.partners) do
		if tostring(vicePartnerId) == tostring(v) then
			return k 
		end
	end
end

-- 计算总加成属性
-- 用于主奇侠界面的显示
function NewLovePartnerView:totalAddAbilities(mainPartnerId,resonanceLv)
	local loveId,loveLevel,loveValue = nil,nil,nil
	local totalArr = {}
	local dataArr = nil
	for k,v in pairs(self.propertyMap) do
		totalArr[k] = 0
	end
	-- dump(totalArr,"初始化总数组")

	for k,vicePartnerId in ipairs(self.partners) do
		loveId,loveLevel,loveValue = NewLoveModel:getVicePartnerLoveData( self.mainPartnerId,vicePartnerId,self.mainPartnerLoves )
		if loveLevel > 0 then
			dataArr = FuncNewLove.getLovelevelUpProperty(loveId,loveLevel)
			for k,v in pairs(dataArr) do
				totalArr[tostring(v.property)] = totalArr[tostring(v.property)] + v.value
			end
		end
		-- dump(totalArr,"计算后一次后总数组"..vicePartnerId.."__________")
	end
	-- dump(totalArr,"\n\n计算完成后总数组")
	if resonanceLv > 0 then
		dataArr = FuncNewLove.getResonatePropertyBypartnerId(mainPartnerId,resonanceLv)
		if dataArr then
			for k,v in pairs(dataArr) do
				totalArr[tostring(v.property)] = totalArr[tostring(v.property)] + v.value
			end
		end
	end
	-- dump(totalArr,"\n\n加上共鸣属性后后总数组")
	return totalArr
end

-- 更新副伙伴右侧属性
function NewLovePartnerView:updateVicePartnerProperty(vicePartnerId)
	-- echo("______ vicePartnerId",vicePartnerId)
	-- 情缘对名字
	-- self:refreshStatusBtn(vicePartnerId)
	local loveId,loveLevel,loveValue,condition = NewLoveModel:getVicePartnerLoveData( self.mainPartnerId,vicePartnerId,self.mainPartnerLoves )
	local mainName = FuncPartner.getPartnerName(self.mainPartnerId)
	local viceName = FuncPartner.getPartnerName(vicePartnerId)
	self.panel_1.txt_1:setString(mainName)
	self.panel_1.txt_2:setString(viceName)

	-- 左边属性框的名字设置
	self.mc_du:getCurFrameView().panel_3.panel_1.txt_1:setString(mainName)
	self.mc_du:getCurFrameView().panel_3.panel_1.txt_2:setString(viceName)

	self.mc_du:getCurFrameView().panel_3.panel_1.txt_biaoti:setString("情缘属性只对"..mainName.."生效")

	-- 共鸣btn
	self:resonanceBtn(vicePartnerId)

	-- 情缘等级描述
	local targetLevel = loveLevel
	if targetLevel < FuncNewLove.maxLevel then
		-- targetLevel = targetLevel + 1
	end
	echo("====================== targetLevel ====================== ",targetLevel)
	local frameNum = targetLevel
	-- if frameNum < 1 then
	-- 	frameNum = 1
	-- end
	self.panel_1.mc_2:showFrame(frameNum+1)

	local loveTipsDesc = FuncNewLove.getLoveLevelDescById(loveId,targetLevel)
	loveTipsDesc = GameConfig.getLanguage(loveTipsDesc)
	self.panel_1.mc_2:getCurFrameView().txt_1:setString(loveTipsDesc)

	-- 左边属性框的伙伴关系设置
	self.mc_du:getCurFrameView().panel_3.panel_1.mc_1:showFrame(frameNum+1)
	self.mc_du:getCurFrameView().panel_3.panel_1.mc_1:getCurFrameView().txt_1:setString(loveTipsDesc)

	-- 弹出情缘各个等级属性的展示
	local function popupLoveDetailView()
		WindowControler:showWindow("NewLoveLevelDetailView",self.mainPartnerId,vicePartnerId) 
		-- WindowControler:showWindow("NewLovePromoteView","500904","攻击提升10%",2) 
	end
	self.panel_1.btn_1:setTap(c_func(popupLoveDetailView))

	self:currentAndNextProperty(vicePartnerId)

end


function NewLovePartnerView:refreshStatusBtn(vicePartnerId)
	-- 情缘任务状态及跳转
	-- 取得情缘升级条件
	local loveId,loveLevel,loveValue,condition = NewLoveModel:getVicePartnerLoveData( self.mainPartnerId,vicePartnerId,self.mainPartnerLoves )
	-- echo("111111111111111111111 ============= ",self.mainPartnerId,vicePartnerId,self.mainPartnerLoves)
	-- echo("loveLevel ================ ",loveLevel)
	NewLoveModel:setCurrentLoveId(loveId)
	self.loveLevel = loveLevel
	local mainName = FuncPartner.getPartnerName(self.mainPartnerId)

	-- 显示任务完成与否的不同状态
    if loveLevel < FuncNewLove.maxLevel then
		-- 展示所有条件的完成状态,并寻找下一个要做的任务
    	local inVisible = 1
    	local isFinshAllCondition = true
    	local toDoCondition = {}
    	-- local condition_panel = contentView.mc_go.currentView
    	self.panel_1.mc_1:showFrame(1)
    	-- local condition_panel = self.panel_1.mc_2.currentView
    	self.mc_du.currentView.panel_3.panel_1.panel_x1:setVisible(true)
    	local condition_panel = self.mc_du.currentView.panel_3.panel_1.panel_x2   --------情缘升级条件 ↓
    	condition_panel:setVisible(true)
    	-- dump(condition,"condition ============== ")
    	---- 如果条件列表长度为1  当前状态为激活的状态
    	---- 要手动添加主角是否拥有的条件状态
    	---- 如果条件列表长度大于1  当前状态为提升的状态
    	---- 正常走原来逻辑就好
    	if table.length(condition) == 1 then ------- 激活的状态
    		local yesStr = "拥有奇侠"..mainName
    		condition_panel["panel_t1"].rich_1:setString(yesStr)
    		if self.isHaveMainPartner then
    			condition_panel["panel_t1"].mc_1:showFrame(3)
    			condition_panel["panel_t1"].btn_1:visible(false)
    			self.ctn_tiao1:visible(false)
    		else
    			condition_panel["panel_t1"].mc_1:showFrame(2)
    			condition_panel["panel_t1"].btn_1:visible(true)
    			self.ctn_tiao1:visible(true)
    			isFinshAllCondition = false
    		end
    		for k,v in ipairs(condition) do
	    		local str = FuncNewLove.getConditionShowText(v.type,v.mode)

	    		-- 如果配表中的伙伴id 用的是占位符，则用主伙伴id代替
	    		local tempPartnerId = nil
	    		if v.partner == "1" or v.partner == 1 then
	    			tempPartnerId = self.mainPartnerId
	    		else
	    			tempPartnerId = v.partner
	    		end
	    		local name = FuncPartner.getPartnerName(tempPartnerId)

	    		if tostring(v.mode) == "3" then
	    			local qualityColor1 = FuncPartner.QualityToColor[v.value]
	    			str = GameConfig.getLanguageWithSwap(str,name,qualityColor1)
	    			condition_panel["panel_t2"].rich_1:setString(str)	
	    		else
	    			str = GameConfig.getLanguageWithSwap(str,name,v.value)
	    			condition_panel["panel_t2"].rich_1:setString(str)

	    		end

	    		if NewLoveModel:isFinishCondition(loveId,v) then
	    			condition_panel["panel_t2"].mc_1:showFrame(3)
	    			condition_panel["panel_t2"].btn_1:visible(false)
	    			self.ctn_tiao2:visible(false)
	    		else
	    			condition_panel["panel_t2"].mc_1:showFrame(2)
	    			condition_panel["panel_t2"].btn_1:visible(true)
	    			self.ctn_tiao2:visible(true)
	    			if isFinshAllCondition then
	    				isFinshAllCondition = false
	    				toDoCondition = v 
	    				-- dump(toDoCondition,"将要做的任务的条件 = ")
	    				local name2 = FuncPartner.getPartnerName(toDoCondition.partner)
	    			end
	    		end
    		end
    	else ---- 提升的状态
    		for k,v in ipairs(condition) do
	    		-- condition_panel["panel_t"..inVisible]:setVisible(true)
	    		-- if not self.isHaveMainPartner then
	    		-- 	condition_panel["panel_t"..inVisible]:setVisible(false)
	    		-- end
	    		local str = FuncNewLove.getConditionShowText(v.type,v.mode)

	    		-- 如果配表中的伙伴id 用的是占位符，则用主伙伴id代替
	    		local tempPartnerId = nil
	    		if v.partner == "1" or v.partner == 1 then
	    			tempPartnerId = self.mainPartnerId
	    		else
	    			tempPartnerId = v.partner
	    		end
	    		local name = FuncPartner.getPartnerName(tempPartnerId)

	    		if tostring(v.mode) == "3" then
	    			local qualityColor1 = FuncPartner.QualityToColor[v.value]
	    			str = GameConfig.getLanguageWithSwap(str,name,qualityColor1)
	    			condition_panel["panel_t"..inVisible].rich_1:setString(str)	
	    		else
	    			str = GameConfig.getLanguageWithSwap(str,name,v.value)
	    			condition_panel["panel_t"..inVisible].rich_1:setString(str)

	    		end

	    		if NewLoveModel:isFinishCondition(loveId,v) then
	    			condition_panel["panel_t"..inVisible].mc_1:showFrame(3)
	    			condition_panel["panel_t"..inVisible].btn_1:visible(false)
	    			self["ctn_tiao"..inVisible]:visible(false)
	    		else
	    			condition_panel["panel_t"..inVisible].mc_1:showFrame(2)
	    			condition_panel["panel_t"..inVisible].btn_1:visible(true)
	    			self["ctn_tiao"..inVisible]:visible(true)
	    			if isFinshAllCondition then
	    				isFinshAllCondition = false
	    				toDoCondition = v 
	    				-- dump(toDoCondition,"将要做的任务的条件 = ")
	    				local name2 = FuncPartner.getPartnerName(toDoCondition.partner)
	    			end
	    		end
	    		inVisible = inVisible + 1
    		end
    	end
    	-- for k = inVisible, 2 do
    	-- 	condition_panel["panel_t"..k]:setVisible(false)
    	-- end
    	--------情缘升级条件 ↑



    	-- 如果主伙伴还没获得,则不能做任务
    	-- 未获得主伙伴也能点进此界面预览 其情缘关系
    	-- 所以此处需做处理
    	-- local promoteBtn = self.panel_1.mc_2.currentView
    	-- if not self.isHaveMainPartner then
     --   		-- contentView.mc_btn:setVisible(false)
     --   		promoteBtn.mc_1:setVisible(false)
   		-- else
     --    	-- contentView.mc_btn:setVisible(true)
     --    	promoteBtn.mc_1:setVisible(true)
     --    end

        -- 情缘等级为0  在待激活状态  按钮要显示激活
        local jihuoBtnView = self.panel_1.mc_1
    	if loveLevel == 0 then
    		condition_panel.mc_1:showFrame(1)
    		jihuoBtnView:showFrame(1)
    		jihuoBtnView.currentView.panel_red:setVisible(isFinshAllCondition)
    		local panelView = jihuoBtnView.currentView.btn_2 --contentView.mc_btn:getCurFrameView()
    		-- 处理完所有任务 则提升
    		-- echo("isFinshAllCondition ===================== ",isFinshAllCondition)
    		local _panelBtn = jihuoBtnView.currentView.btn_2:getUpPanel()
			self:updateBtnAnim(_panelBtn, 78, -36, isFinshAllCondition)

    		if isFinshAllCondition then
				panelView:setTouchedFunc(function()
	    			if loveId then
	    				NewLoveModel.haveSentLoveLevelUpRequest = true
	    				panelView:setTouchEnabled(false)
	    				self._oldPower = PartnerModel:getPartnerAbility(self.mainPartnerId)
						-- echo("_________ 主伙伴当前战力 ________ ",self._oldPower)
						-- 下一等级增加的属性  用于飘字
						local loveId = FuncNewLove.getLoveIdByPartnerId(self.mainPartnerId,vicePartnerId)
						local dataArr = FuncNewLove.getLovelevelUpProperty(loveId,self.loveLevel + 1)
						-- dump(dataArr,"dataArr ========== ")
						local txtArr = {FuncPartner.getPartnerName(self.mainPartnerId),self.propertyMap[tostring(dataArr[1].property)].."+"..tostring(dataArr[1].value/100).."%"}
	    				NewLoveModel:loveLevelUp(loveId, loveLevel + 1,txtArr)
	    			end
	    		end)
    		else
    			-- 条件没达成  点击激活按钮  要在没达成条件的地方播放一个动画 提示玩家没达成
    			panelView:setTouchedFunc(function()
    				self.ctn_tiao1:removeAllChildren()
	    			self.ctn_tiao2:removeAllChildren()
	    			local btnAni1 = self:createUIArmature("UI_qingyuan_tisheng", "UI_qingyuan_tisheng_kuoquan", self.ctn_tiao1, false, GameVars.emptyFunc)
	    			local btnAni2 = self:createUIArmature("UI_qingyuan_tisheng", "UI_qingyuan_tisheng_kuoquan", self.ctn_tiao2, false, GameVars.emptyFunc)
	    			btnAni1:setScale(0.3)
	    			btnAni2:setScale(0.3)
    				WindowControler:showTips("先解锁情缘激活条件")
	    			echo("条件没达成")
	    		end)
    		end
    	else
    		-- 情缘等级大于0  按钮显示提升情缘或者前往提升
    		-- 处理完所有任务 则提升
    		condition_panel.mc_1:showFrame(2)
    		jihuoBtnView:showFrame(2)
    		local panel_red = jihuoBtnView.currentView.panel_red
    		panel_red:setVisible(isFinshAllCondition)
    		local panelView = jihuoBtnView.currentView.btn_2

    		local _panelBtn = jihuoBtnView.currentView.btn_2:getUpPanel()
			self:updateBtnAnim(_panelBtn, 78, -36, isFinshAllCondition)
    		if isFinshAllCondition then
				echo("=======提升情缘=======")
	    		 --contentView.mc_btn:getCurFrameView()
				panelView:setTouchedFunc(function()
	    			if NewLoveModel.haveSentLoveLevelUpRequest or not self.isHaveMainPartner then
	    				return
	    			end
	    			if loveId then
	    				NewLoveModel.haveSentLoveLevelUpRequest = true
	    				panelView:setTouchEnabled(false)
	    				self._oldPower = PartnerModel:getPartnerAbility(self.mainPartnerId)
						-- echo("_________ 主伙伴当前战力 ________ ",self._oldPower)
	    				-- 下一等级增加的属性  用于飘字
						local loveId = FuncNewLove.getLoveIdByPartnerId(self.mainPartnerId,vicePartnerId)
						local dataArr = FuncNewLove.getLovelevelUpProperty(loveId,self.loveLevel + 1)
						local txtArr = {FuncPartner.getPartnerName(self.mainPartnerId),self.propertyMap[tostring(dataArr[1].property)].."+"..tostring(dataArr[1].value/100).."%"}
	    				NewLoveModel:loveLevelUp(loveId, loveLevel + 1,txtArr)
	    			end
	    		end)	    
    		else
	    	-- 	jihuoBtnView:showFrame(2)
	    	-- 	local panelView = jihuoBtnView.currentView.btn_2 --contentView.mc_btn:getCurFrameView()
	    	-- 	panelView:setTouchedFunc( c_func(self.generateLink,self,toDoCondition,vicePartnerId) )
	    		panelView:setTouchedFunc(function()
	    			self.ctn_tiao1:removeAllChildren()
	    			self.ctn_tiao2:removeAllChildren()
	    			local btnAni1 = self:createUIArmature("UI_qingyuan_tisheng", "UI_qingyuan_tisheng_kuoquan", self.ctn_tiao1, false, GameVars.emptyFunc)
	    			local btnAni2 = self:createUIArmature("UI_qingyuan_tisheng", "UI_qingyuan_tisheng_kuoquan", self.ctn_tiao2, false, GameVars.emptyFunc)
	    			btnAni1:setScale(0.3)
	    			btnAni2:setScale(0.3)
	    			WindowControler:showTips("先解锁情缘升级条件")
	    		end)	
    		end
    	end
    	self:refreshGotoBtn(toDoCondition,self.mainPartnerId,vicePartnerId)
    elseif loveLevel == FuncNewLove.maxLevel then
    	self.ctn_love3:removeAllChildren()
    	self.panel_1.mc_1:showFrame(3)
    	self.mc_du.currentView.panel_3.panel_1.panel_x1:setVisible(false)
    	self.mc_du.currentView.panel_3.panel_1.panel_x2:setVisible(false)
    end
end

function NewLovePartnerView:updateBtnAnim(_btnPanel, x, y, isFinshAllCondition)
	if isFinshAllCondition then
		local btn_anim = _btnPanel:getChildByName("saoguang")
		if not btn_anim then
			local btnAni = self:createUIArmature("UI_anniuliuguang","UI_anniuliuguang_zong",_btnPanel, true)
			btnAni:pos(x, y)
			btnAni:setName("saoguang")
		end
	else
		_btnPanel:removeChildByName("saoguang")
	end
end


--（当前未激活情缘 或者 当前情缘属性）  和  （激活情缘属性  或者  下一级情缘属性）
function NewLovePartnerView:currentAndNextProperty(vicePartnerId)
	-- echo("self.loveLevel ================== ",self.loveLevel)
	if self.loveLevel == 0 then
		self.mc_du.currentView.panel_3.panel_1.mc_t1:showFrame(2)
    	self.mc_du.currentView.panel_3.panel_1.panel_x1.mc_t2:showFrame(1)
	else
		self.mc_du.currentView.panel_3.panel_1.mc_t1:showFrame(2)
    	self.mc_du.currentView.panel_3.panel_1.panel_x1.mc_t2:showFrame(2)
	end

	local currentProperties = self:totalAddAbilities( self.mainPartnerId,self.mainPartnerResonateLv )
	-- echo("self.mainPartnerResonateLv =============== ",self.mainPartnerResonateLv)
	-- dump(currentProperties,"currentProperties ========== ")
	local i = 1
	for k,v in pairs(currentProperties) do
		self.mc_du.currentView.panel_3.panel_1["panel_"..i].rich_1:setString(self.propertyMap[k].."+"..tostring(v/100).."%")
		self.mc_du.currentView.panel_3.panel_1["panel_"..i].mc_1:showFrame(FuncPartner.ATTR_KEY_MC[tostring(k)])
		i = i + 1
	end

	-- 获取下一等级增加的属性
	local loveId = FuncNewLove.getLoveIdByPartnerId(self.mainPartnerId,vicePartnerId)
	local dataArr
	if self.loveLevel < FuncNewLove.maxLevel then
		dataArr = FuncNewLove.getLovelevelUpProperty(loveId,self.loveLevel + 1)
	else
		dataArr = FuncNewLove.getLovelevelUpProperty(loveId,self.loveLevel)
	end
	

	-- dump(dataArr,"dataArr ========================= ")
	-- echo("self.mainPartnerResonateLv ============= ",self.mainPartnerResonateLv)
	local resonateArr 
	local resonateValue
	if self.mainPartnerResonateLv == 0 then
		resonateValue = 0
	else
		resonateArr = FuncNewLove.getResonatePropertyBypartnerId(self.mainPartnerId,self.mainPartnerResonateLv)
		resonateValue = (resonateArr[1].value)/100
	end
	-- echo("resonateValue ========== ",resonateValue)
	-- dump(resonateArr,"resonateArr ========== ")

	local nextProperties = self:totalAddAbilities( self.mainPartnerId,self.mainPartnerResonateLv )
	local j = 1
	for k,v in pairs(nextProperties) do
		self.mc_du.currentView.panel_3.panel_1.panel_x1["panel_"..j].rich_1:setString(self.propertyMap[k].."+"..tostring(v/100).."%")
		self.mc_du.currentView.panel_3.panel_1.panel_x1["panel_"..j].mc_1:showFrame(FuncPartner.ATTR_KEY_MC[tostring(k)])
		---- 改变的属性换个颜色
		if table.length(dataArr) ~= 0 and tonumber(dataArr[1].property) == tonumber(k) then
			self.mc_du.currentView.panel_3.panel_1.panel_x1["panel_"..j].rich_1:setString("<color=008c0d>"..self.propertyMap[k].."+"..tostring(dataArr[1].value/100+resonateValue).."%".."<->")
		end
		j = j + 1
	end
end

--前往按钮
function NewLovePartnerView:refreshGotoBtn(toDoCondition, mainPartnerId, vicePartnerId)
	local condition_panel = self.mc_du.currentView.panel_3.panel_1.panel_x2 
	condition_panel["panel_t1"].btn_1:setTouchedFunc( c_func(self.gotoPartnerView,self,toDoCondition,mainPartnerId,vicePartnerId) )
	condition_panel["panel_t2"].btn_1:setTouchedFunc( c_func(self.gotoPartnerView,self,toDoCondition,vicePartnerId,vicePartnerId) )

	---- ctn1 主立绘加点击事件
	local node_1 = display.newNode()
	node_1:setContentSize(cc.size(200,400))
	node_1:pos(-100,-50)
	node_1:addto(self.panel_bg.panel_lihui.ctn_1,1)
	node_1:setTouchedFunc(c_func(self.gotoPartnerView,self,toDoCondition,mainPartnerId,vicePartnerId))

	local node_2 = display.newNode()
	node_2:setContentSize(cc.size(200,400))
	node_2:pos(-100,-50)
	node_2:addto(self.panel_bg.panel_lihui.ctn_2,1)
	node_2:setTouchedFunc(c_func(self.gotoPartnerView,self,toDoCondition,vicePartnerId,vicePartnerId))

	--[[
	  -- 测试代码
	  local color = color or cc.c4b(255,0,0,120)
	    local layer = cc.LayerColor:create(color)
	    node_2:addChild(layer)
	    node_2:zorder(100000000)
	    node_2:setTouchEnabled(true)
	    node_2:setTouchSwallowEnabled(true)
	    layer:setContentSize(cc.size(200,400) )
	]]--
end

function NewLovePartnerView:gotoPartnerView( toDoCondition ,PartnerId ,vicePartnerId)
	-- dump(toDoCondition,"toDoCondition==================")
	-- echo("PartnerId =============== ",PartnerId)
	-- echo("vicePartnerId ============== ",vicePartnerId)
	-- if toDoCondition.type == 1 then
		-- 1=等级 2=星级 3=品阶 4=拥有此伙伴
		local targetItem = nil
		if not PartnerModel:isHavedPatnner(PartnerId) then
			targetItem =  FuncPartner.PartnerIndex.PARTNER_COMBINE
		else
			targetItem =  FuncPartner.PartnerIndex.PARTNER_QUALILITY
		end
		-- 副奇侠界面要养成主奇侠 记录跳转后刷新用的副奇侠id
		-- if toDoCondition.partner == self.mainPartnerId then
			self.associatedPartnerId = vicePartnerId
		-- end
		if WindowControler:checkHasWindow( "PartnerView" ) then
			local wind = WindowControler:getWindow( "PartnerView"  )
			wind:gotoPartner( targetItem,PartnerId )
			WindowControler:showTopWindow("PartnerView")
		else
			WindowControler:showWindow("PartnerView",targetItem,tostring(PartnerId))
		end
	-- end
end

--情缘共鸣按钮
function NewLovePartnerView:resonanceBtn( vicePartnerId )
	local canShowRedPoint = NewLoveModel:isShowResonanceRedPoint(self.mainPartnerId)
	self.btn_q1:getUpPanel().panel_red:visible(canShowRedPoint)
	local str = ""
	if self.mainPartnerResonateLv == 0 then
		str = tostring(self.mainPartnerResonateLv)
	else
		str = "+"..tostring(self.mainPartnerResonateLv)
	end
	self.btn_q1:setBtnStr(str,"txt_2")
	self.btn_q1:setTouchedFunc(function()
		WindowControler:showWindow("NewLoveResonanceView",self.mainPartnerId,vicePartnerId,self.mainPartnerLoves)
	end)
end

-- 生成任务链接 1=伙伴养成
function NewLovePartnerView:generateLink( toDoCondition, vicePartnerId )
	-- echo("_________ 点击按钮 _前往做任务")
    -- dump(toDoCondition, "\n\n当前的点击类型======")
	if toDoCondition.type == 1 then
		-- 1=等级 2=星级 3=品阶 4=拥有此伙伴
		local targetItem = nil
		if toDoCondition.mode == 4 or (not PartnerModel:isHavedPatnner(toDoCondition.partner)) then
			targetItem =  FuncPartner.PartnerIndex.PARTNER_COMBINE
		elseif toDoCondition.mode == 1 or toDoCondition.mode == 3 then
			targetItem =  FuncPartner.PartnerIndex.PARTNER_QUALILITY
		else
			targetItem =  FuncPartner.PartnerIndex.PARTNER_UPSTAR
		end
		-- 副奇侠界面要养成主奇侠 记录跳转后刷新用的副奇侠id
		-- if toDoCondition.partner == self.mainPartnerId then
			self.associatedPartnerId = vicePartnerId
		-- end
		if WindowControler:checkHasWindow( "PartnerView" ) then
			local wind = WindowControler:getWindow( "PartnerView"  )
			wind:gotoPartner( targetItem,toDoCondition.partner )
			WindowControler:showTopWindow("PartnerView")
		else
			WindowControler:showWindow("PartnerView",targetItem,toDoCondition.partner)
		end
	end
end


-- 更新选中效果
function NewLovePartnerView:updateChooseEffect(PartnerId)
	
	if tostring(PartnerId) == self.mainPartnerId then
		-- self.panel_bg.panel_lihui.panel_xuan:setVisible(true)
        -- self.panel_bg.panel_lihui.panel_xuan:setScaleY(-1)
		for k,v in ipairs(self.partners) do
			self.panel_right["panel_tou"..tostring(k)].panel_1.panel_xuan:setVisible(false)
             if self.panel_right["panel_tou"..tostring(k)].isHasPartner then
                -- self.panel_right["panel_tou"..tostring(k)].mc_jindu:showFrame(2)
                -- self.panel_right["panel_tou"..tostring(k)].mc_di:showFrame(1)
            else
                -- self.panel_right["panel_tou"..tostring(k)].mc_jindu:showFrame(1)
                -- self.panel_right["panel_tou"..tostring(k)].mc_di:showFrame(3)
            end
		end
	else
		self.currentVicePartnerId = PartnerId		
		-- self.panel_bg.panel_lihui.panel_xuan:setVisible(false)
		for k,v in ipairs(self.partners) do
			if tostring(PartnerId) == tostring(v) then
				self.panel_right["panel_tou"..tostring(k)].panel_1.panel_xuan:setVisible(true)
                -- self.panel_right["panel_tou"..tostring(k)].mc_jindu:showFrame(3)
                 -- self.panel_right["panel_tou"..tostring(k)].mc_di:showFrame(2)
                NewLoveModel:setLastChoosedPartnerIndex(k)
			else
				self.panel_right["panel_tou"..tostring(k)].panel_1.panel_xuan:setVisible(false)
                if self.panel_right["panel_tou"..tostring(k)].isHasPartner then
                    -- self.panel_right["panel_tou"..tostring(k)].mc_jindu:showFrame(2)
                    -- self.panel_right["panel_tou"..tostring(k)].mc_di:showFrame(1)
                else
                    -- self.panel_right["panel_tou"..tostring(k)].mc_jindu:showFrame(1)
                    -- self.panel_right["panel_tou"..tostring(k)].mc_di:showFrame(3)
                end
			end
		end
	end

	local canShowRedPoint = NewLoveModel:isShowResonanceRedPoint(self.mainPartnerId)
	-- self.panel_bg.panel_lihui.panel_red:setVisible(canShowRedPoint)
end

function NewLovePartnerView:deleteMe()
	-- TODO
	NewLovePartnerView.super.deleteMe(self);
end



return NewLovePartnerView;
