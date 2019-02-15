--[[
	Author: zhuguangyuan
	Date:2017-07-21
	Description: 精英副本每一节的小节列表
    -- 从精英主界面进入此界面传入的是 raidId
    -- 从背包进入此界面传入的是 raidId
    -- 战斗返回只传了 raidId
    -- 从奇侠进入 传递的是 raidId,targetResId,targetResNum
]]

local EliteLieBiaoView = class("EliteLieBiaoView", UIBase);

function EliteLieBiaoView:ctor(winName,raidId,targetResId,targetResNum)
    EliteLieBiaoView.super.ctor(self, winName)
    self.curStageType = FuncChapter.stageType.TYPE_STAGE_ELITE  --默认精英副本

    echo("传入参数 raidId,targetResId,targetResNum ---------",raidId,targetResId,targetResNum)

    if raidId then
        self.targetRaidId = raidId
        if targetResId and targetResNum then
            -- 资源需求Id和数量
            self.targetData = {
                targetId = targetResId,
                needNum = targetResNum
            }
        end
    else
        local maxStoryId = WorldModel:getUnLockMaxStoryId(self.curStageType)
        raidId = WorldModel:getUnLockMaxRaidIdByStoryId(maxStoryId)
    end

    -- 注意当前展开关卡用在有展开关卡的时候
    -- 当前关卡为 当有展开关卡时为展开关卡 当没有展开关卡时默认为上一次展开的关卡
    self.currentUnfoldRaidId = tostring(raidId)  -- 其他界面调过来时传入的关卡id
    self.currentStoryId = FuncChapter.getStoryIdByRaidId( self.currentUnfoldRaidId )
    -- 扫荡的两种类型
    self.sweetpType = {
        SWEEP_ONE = 1,
        SWEEP_TEN = 10
    }
end

function EliteLieBiaoView:loadUIComplete()
	self:initView() 
	self:registerEvent(); 
	self:initData()  
	self:updateUI() 
end 

function EliteLieBiaoView:getEnterBattleCacheData()
    echo("\n 战斗前缓存view数据 EliteLieBiaoView")
    return  {
                storyId = self.currentStoryId,
                raidId = self.currentUnfoldRaidId
            }
end
function EliteLieBiaoView:onBattleExitResume(cacheData )
    dump(cacheData,"战斗恢复view EliteLieBiaoView")
    EliteLieBiaoView.super.onBattleExitResume(cacheData)
    if cacheData and cacheData.raidId then
        self.currentStoryId = cacheData.storyId
        self.currentUnfoldRaidId = cacheData.raidId

        -- 判断是否有新章开启(自动选中下一个关卡)
        -- self.newPassRaid = WorldModel:getEliteNewPassRaid()
        -- local maxStoryId = WorldModel:getUnLockMaxStoryId( self.curStageType )
        -- if tonumber(maxStoryId) >= tonumber(self.currentStoryId) 
        --     and self.newPassRaid and WorldModel:isLastRaidId(self.newPassRaid) 
        -- then
        --     if tonumber(maxStoryId) > tonumber(self.currentStoryId) then
        --         self.currentStoryId = maxStoryId
        --         self.currentUnfoldRaidId = FuncChapter.getRaidIdByStoryId(maxStoryId,1)
        --         local function showTips() 
        --             WindowControler:showTips(GameConfig.getLanguage("#tid_elite_001"));
        --         end
        --         self:delayCall(c_func(showTips), 1)
        --     end
        --     local function forceOpenGrids()
        --         EventControler:dispatchEvent(EliteEvent.ELITE_AUTO_OPEN_LEFT_GRIDS)
        --     end
        --     self:delayCall(c_func(forceOpenGrids), 1)
        -- else
        --     self.currentUnfoldRaidId = WorldModel:getUnLockMaxRaidIdByStoryId(self.currentStoryId)
        -- end
        self.currentStoryId,self.currentUnfoldRaidId = EliteMainModel:checkIsPerfect(self.currentStoryId,self.currentUnfoldRaidId)

        self:initData()
        self:updateUI() 
        
        if UserModel:isLvlUp() then 
            EventControler:dispatchEvent(UserEvent.USEREVENT_LEVEL_CHANGE); 
        end 
        self:checkOpenShopByDelayTime(1)  -- 检查临时商店是否开启
    end
end


----------------------------------------------
--1 UI组件重命名、适配
----------------------------------------------
function EliteLieBiaoView:initView()
    -- 滚动条
    self.raidScoller = self.scroll_1
    -- 设置滚动条创建完毕的回调
    self.raidScoller:setOnCreateCompFunc( c_func(self.isScrollItemCreateComplete, self) )

    self.panel_la:setVisible(false)
    self.panel_la:setVisible(false)
    self.mcChapterName = self.panel_icon.mc_zhang

    -- -- 上一章下一章
    self.lastBtn = self.btn_left
    self.nextBtn = self.btn_right
    self.re_exploreBtn = self.btn_tshg -- 探索回顾

    -- 可领取宝箱的进度显示条
    self.boxPanel = self.panel_jdt

    self:initViewAlign() --组件适配
    self:initScrollCfg() --初始化滚动条

    self.bg = display.newSprite(FuncRes.iconElite("elite_bj"))
    self.bg:parent(self,-1):anchor(0.5,0.5):pos(GameVars.halfResWidth,-GameVars.halfResHeight)
    self.bg:setScaleX(GameVars.width/GameVars.gameResWidth)
end

--组件适配
function EliteLieBiaoView:initViewAlign()
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_bg, UIAlignTypes.Middle)
 	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_icon, UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back,UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_ziyuan,UIAlignTypes.RightTop)
    FuncCommUI.setScrollAlign(self.widthScreenOffset, self.scroll_1,UIAlignTypes.Middle,1,nil,1)

    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_left,UIAlignTypes.LeftBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_right,UIAlignTypes.RightBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_tshg,UIAlignTypes.LeftBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.txt_b2,UIAlignTypes.LeftBottom)
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_jdt,UIAlignTypes.MiddleBottom)

    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_left1,UIAlignTypes.Left)
end

--初始化滚动条
function EliteLieBiaoView:initScrollCfg()
	-- 创建一个展开画卷 
	local createRaidFuncUnfold = function(itemData)
		local itemView = UIBaseDef:cloneOneView(self.panel_la)
		self:createPanelUnfold(itemView,itemData)
		return itemView
	end

    self.raidListParamsUnfold = {
        data = nil,
        createFunc = createRaidFuncUnfold,
        updateCellFunc = updateRaidFuncUnfold,
        perNums= 1,
        offsetX = 0,
        offsetY = 0,
        widthGap = 0,
        heightGap = 10,
        itemRect = {x= 0,y=-441,width = 565,height = 446}, --525
        perFrame = 1
    }

	-- 创建一个收起画卷
	local createRaidFuncRetract = function(itemData)
        self.panel_la.UI_2:setVisible(false)
        local itemView = UIBaseDef:cloneOneView(self.panel_la.UI_1)
		self:createPanelRetract(itemView,itemData)
		return itemView
	end
    self.raidListParamsRetract = {
    	data = nil,
        createFunc = createRaidFuncRetract,
        updateCellFunc = updateRaidFuncRetract,
        perNums= 1,
        offsetX = 0,
        offsetY = 0,
        widthGap = 0,
        heightGap = 10,
        itemRect = {x= 0,y=-441,width = 200,height = 446}, -- 200
        perFrame = 1
    }
    -- 隐藏滚动条
    self.raidScoller:hideDragBar()	
end

----------------------------------------------
--2 注册界面事件
----------------------------------------------
function EliteLieBiaoView:registerEvent()
	EliteLieBiaoView.super.registerEvent(self)
	self.btn_back:setTap(c_func(self.onClose, self))  -- 返回

	self.lastBtn:setTap(c_func(self.onGoToLastChapter, self)) -- 上一章
	self.nextBtn:setTap(c_func(self.onGoToNextChapter, self)) -- 下一章

    -- EventControler:addEventListener(WorldEvent.WORLDEVENT_OPEN_STAR_BOXES, self.updateStarBoxes, self)
    EventControler:addEventListener(UserEvent.USEREVENT_SP_CHANGE, self.onSpChange, self)
    EventControler:addEventListener(EliteEvent.ELITE_RADI_CHANGE, self.updateSpDisplay, self)
    EventControler:addEventListener(EliteEvent.ELITE_CONFIRM_TO_GOTO_SCENE, self.gotoExploreScene, self)
    EventControler:addEventListener(EliteEvent.ELITE_CHOOSR_STORYID_CHANGE, self.choosingRaidChanged, self)
end

-- 场景中选中的关卡发生变化
function EliteLieBiaoView:choosingRaidChanged( event )
    if event.params.raidId then
        self.currentStoryId = event.params.storyId
        self.currentUnfoldRaidId = event.params.raidId
        self:initData()
        self:updateUI() 
    end
end

-- 检查临时商店是否开启
function EliteLieBiaoView:checkOpenShopByDelayTime(delayTime)
    local openShop = function()
        local openShopType = WorldModel:getOpenShopType()
        if openShopType ~= nil and table.length(openShopType) > 0 then
            WorldModel:resetDataBeforeBattle()
            WindowControler:showWindow("ShopKaiqi", openShopType)
        end
    end

    if delayTime == nil or delayTime == 0 then
        openShop()
    else
        self:delayCall(c_func(openShop), delayTime)
    end
end



-- 切换到上一章
function EliteLieBiaoView:onGoToLastChapter()
    -- 已经是第一章
    if WorldModel:isFirstChapter(self.currentStoryId) then
        WindowControler:showTips(GameConfig.getLanguage("#tid_story_10105"))
        return
    end

    self.currentStoryId = WorldModel:getLastStoryId(self.currentStoryId)
    EventControler:dispatchEvent(EliteEvent.ELITE_CHOOSR_STORYID_CHANGE,{storyId = self.currentStoryId})

    if WorldModel:isPassStory(self.currentStoryId) then
        self.currentUnfoldRaidId = FuncChapter.getLastRaidIdByStoryId(self.currentStoryId)
        self.currentRaidId = self.currentUnfoldRaidId
    end

    self:initData()
    self:updateUI() 
end

-- 切换到下一章（需检查章是否开启）
function EliteLieBiaoView:onGoToNextChapter()
    local isMainLineOK,isEliteOK = EliteMainModel:checkIfCangotoNextChapter( self.currentStoryId )
    if isEliteOK and isMainLineOK then
        self.currentStoryId = WorldModel:getNextStoryId(self.currentStoryId)
        EventControler:dispatchEvent(EliteEvent.ELITE_CHOOSR_STORYID_CHANGE,{storyId = self.currentStoryId})
        if WorldModel:isPassStory(self.currentStoryId) then
            self.currentUnfoldRaidId = FuncChapter.getLastRaidIdByStoryId(self.currentStoryId)
            self.currentRaidId = self.currentUnfoldRaidId
        else
            self.currentUnfoldRaidId = WorldModel:getUnLockMaxRaidIdByStoryId(self.currentStoryId)
            self.currentRaidId = self.currentUnfoldRaidId
        end
        self:initData()
        self:updateUI() 
    end
end



----------------------------------------------
--3 初始化章数据 当前关卡等
----------------------------------------------
function EliteLieBiaoView:initData()
    -- 当前章数据
    self.storyData = FuncChapter.getStoryDataByStoryId(self.currentStoryId)

    if self.currentUnfoldRaidId == "nil" or self.currentUnfoldRaidId == "" or self.currentUnfoldRaidId == nil then
        self.currentUnfoldRaidId =  WorldModel:getUnLockMaxRaidIdByStoryId(self.currentStoryId) -- 默认进入已经通关的最大关卡
        self.currentRaidId = self.currentUnfoldRaidId   -- 默认展开最新一章
    else
        echo("选中的关卡id为===" ,self.currentUnfoldRaidId)
    end

    self.currentCenterRaidNum = FuncChapter.getSectionByRaidId(self.currentUnfoldRaidId) 
    self.currentRaidSpCost = FuncChapter.getRaidDataByRaidId( self.currentUnfoldRaidId ).spCost --挑战或者扫荡当前关卡需消耗的体力
end


----------------------------------------------
--4 更新UI
----------------------------------------------
function EliteLieBiaoView:updateUI()
	-- 更新章标题 -- 最多十九章
    local chapter = FuncChapter.getChapterByStoryId(self.currentStoryId) --( tonumber() - 200 ) % 30
    local contentView = nil
    if chapter < 11 then
        self.mcChapterName:showFrame(1)
        self.mcChapterName.currentView.mc_1:showFrame(chapter)
    else
        self.mcChapterName:showFrame(2)
        local chapter1,chapter2 = math.modf(chapter/10)
        chapter2 = chapter2*10 + 0.1
        chapter2 = math.floor(chapter2)
        chapter1 = chapter1 * 10
        if chapter2 == 0 then
            chapter2 = 10
            chapter1 = chapter1/10 
        end
        echo("______ chapter1,chapter2 __________",chapter1,chapter2)
        self.mcChapterName.currentView.mc_1:showFrame(chapter1)
        self.mcChapterName.currentView.mc_2:showFrame(chapter2)
    end

	-- 更新滚动条
	self:updateRaidList()

	-- 更新星级宝箱及进度条
	-- self:updateStarBoxes()

    -- 显示体力
    self:updateSpDisplay()

    -- 回顾探索 本章已经通关才显示
    if WorldModel:isPassStory(self.currentStoryId) then
        self.re_exploreBtn:visible(true)
        local params = {
            viewType = FuncElite.TIPS_VIEW_TYPE.ENTER_SCENE
        }
        local function gotoReconfirm(  )
            WindowControler:showWindow("EliteReExploreRecomfirmView",params)
        end
        self.re_exploreBtn:setTap(c_func(gotoReconfirm))

        self:updateMapBoxes(true)
    else
        self.re_exploreBtn:visible(false)
        self:updateMapBoxes(false)
    end
end

--[[
    更新场景宝箱数据
]]
function EliteLieBiaoView:updateMapBoxes(visible)
    self.txt_b2:setVisible(visible)

    local totalNum = EliteMapModel:getMapBoxTotalNum(self.currentStoryId)
    local gotNum = EliteMapModel:getMapBoxGotNum(self.currentStoryId)
    -- 场景宝箱
    local boxInfo = GameConfig.getLanguageWithSwap("#tid_elite_tips_1010",gotNum,totalNum)
    self.txt_b2:setString(boxInfo)
end

-- 更新滚动条
-- 更新所有已经解锁的章的视图
function EliteLieBiaoView:updateRaidList()
    self.isViewCreateComplete = false
    self.raidScoller.setEnableScroll(false)

	-- 取消缓存
	self.raidScoller:cancleCacheView()

	-- 更新滚动条
	self.raidListParams = self:buildItemScrollParams()

    self.raidScoller:setScrollBorder(-30)
    self.raidScoller:styleFill(self.raidListParams)

    -- 将当前解锁的关卡设置未list的中心
    self:setCurRaidInListCenter()
end

-- 动态生成item滚动区配置参数
function EliteLieBiaoView:buildItemScrollParams()
    local raidListParams = {}
    local data = FuncChapter.getOrderRaidList(self.currentStoryId)
    local raidData = nil
    local copyItemParams = nil
    for k,v in pairs(data) do
        if not WorldModel:isRaidLock(v) then
            raidData = FuncChapter.getRaidDataByRaidId(v)
            if tostring(self.currentUnfoldRaidId) == tostring(raidData.id) then
                copyItemParams = table.copy(self.raidListParamsUnfold)
            else
                copyItemParams = table.copy(self.raidListParamsRetract)
            end
            copyItemParams.data = {raidData}
            raidListParams[ #raidListParams + 1 ] = copyItemParams
        end
    end
    return raidListParams
end

-- 将当前关卡设置为list的中心
function EliteLieBiaoView:setCurRaidInListCenter()
	local easeTime = 0
	if self.onRaidChange then
		easeTime = 0.5
	end

	-- 跳到滚动条组件的第几个 第几组 调到的方式0 1 2 缓存更新时间
	-- 跳到第一组的第currentCenterRaidNum个，居中 
    -- 不展开时中间 
        -- 若最新关卡>4 则将其左边第二的关卡居中，以使得最新关卡居右
        -- 否则最新关卡关卡处中
    -- 当前要展开关卡为最后一关时最后一关往右靠
    -- 当前关卡不超过四时最左的关卡往左靠
    -- 否则当前展开关卡处中
    if self.currentUnfoldRaidId == -1 then
        if (self.currentCenterRaidNum == self.storyData.section) 
            and self.currentCenterRaidNum > 5 then
            self.raidScoller:gotoTargetPos(self.currentCenterRaidNum - 2, 1, 1, easeTime)
        elseif self.currentCenterRaidNum < 6 then
            self.raidScoller:gotoTargetPos(1, 1, 0, easeTime)
        end
    elseif self.currentCenterRaidNum < 4 then
        self.raidScoller:gotoTargetPos(1, 1, 0, easeTime)
    else 
        self.raidScoller:gotoTargetPos(self.currentCenterRaidNum, 1, 1, easeTime)
    end
end

-- 更新星级宝箱
function EliteLieBiaoView:updateStarBoxes()
    local _storyId = self.currentStoryId
    local _boxPanel = self.boxPanel
    local _view = self
    EliteMainModel:updateBoxProgress( _storyId,_boxPanel,_view )
end

--播放宝箱闪光动画
function EliteLieBiaoView:playStarBoxAnim(panelBox,isPlay)  
-- isPlay,true表示播放动画；false表示不播放动画，如果ctn已经有动画，需要做换装的反动作，并删除动画
	local ctnBox = panelBox.ctn_xing1
	if isPlay then
		if ctnBox:getChildrenCount() == 0 then
			panelBox.mc_box:setVisible(false)
			local mcView = UIBaseDef:cloneOneView(panelBox.mc_box)
			local anim = self:createUIArmature("UI_xunxian","UI_xunxian_xingjibaoxiang",ctnBox, false, GameVars.emptyFunc)
	    	-- anim:pos(0,0)
	    	mcView.currentView:pos(-1,5)
	    	FuncArmature.changeBoneDisplay(anim,"node",mcView)
	    	anim:startPlay(true)
		end
	else
		if ctnBox:getChildrenCount() > 0 then
			panelBox.mc_box:setVisible(true)
			ctnBox:removeAllChildren()
		end
	end
end

-------------------------------------------------------------------------------
-- 创建收起的关卡画卷
-------------------------------------------------------------------------------
function EliteLieBiaoView:isScrollItemCreateComplete()
    self.isViewCreateComplete = true
    self.raidScoller.setEnableScroll(true)
end


-- 收起画卷
function EliteLieBiaoView:createPanelRetract(itemView,itemData)
    itemView:setVisible(true)

    local panelView = itemView.panel_1
    local huluMC = panelView.mc_hulu
    panelView.mc_hulu2:visible(false)
    -- local eliteTimesMC = panelView.mc_num
    local txtChapterAndRaid = panelView.txt_xy
    txtChapterAndRaid:visible(false)

    local btnPassRaidRules = panelView.btn_guize
    local panelUnfold = panelView.panel_zipian
    local mainRewardUI = panelView.UI_1
    panelView.panel_xuanzhong:setVisible(false)


    -- 设置节名称
    local RaidName = GameConfig.getLanguage(itemData.name)
    panelView.txt_zhangjie:setString(RaidName)
    local sectionStr = Tool:transformNumToChineseWord(tonumber(itemData.section))
    panelView.txt_2:setString("第"..sectionStr.."节")

    -- 展示本关卡可获得的最贵重奖品/暂时展示第1个
    -- 点击可显示tips
    local rewardString =itemData["bonusView"]
    local str1 = rewardString[1]
    local params = {
        reward = str1,
    }
    mainRewardUI:setResItemData(params)
    mainRewardUI:setTouchEnabled(false)
    mainRewardUI:showResItemNum(false)  -- 隐藏数量

    -- eliteTimesMC:setVisible(false)
    local chapter = self.currentStoryId - 200
    txtChapterAndRaid:setString(chapter.."-"..itemData.section)
    
    -- 设置葫芦
    -- 通过读取战斗结果设置所得葫芦个数
    local raidScore = WorldModel:getBattleStarByRaidId( itemData.id )
    huluMC:setVisible(true)
    if raidScore == WorldModel.stageScore.SCORE_ONE_STAR then
        huluMC:showFrame(1)
    elseif raidScore == WorldModel.stageScore.SCORE_TWO_STAR then
        huluMC:showFrame(2)
    elseif raidScore == WorldModel.stageScore.SCORE_THREE_STAR then
        huluMC:showFrame(3)
    elseif raidScore == WorldModel.stageScore.SCORE_LOCK then
        huluMC:showFrame(4)
    end

    btnPassRaidRules:setVisible(false)

    -- 展开画卷
    panelUnfold:setTouchedFunc(function()
        if not self.isViewCreateComplete then
            return
        end
        self.currentUnfoldRaidId = itemData.id
        self.currentRaidId = self.currentUnfoldRaidId
        self.currentCenterRaidNum = FuncChapter.getSectionByRaidId(itemData.id)
        self:updateRaidList()
    end)
end


-------------------------------------------------------------------------------
-- 创建展开的关卡画卷
-------------------------------------------------------------------------------
function EliteLieBiaoView:createPanelUnfold(itemView,itemData)
    itemView:setVisible(true)
    self.raidData = itemData
    self.currentRaidSpCost = itemData.spCost  --体力消耗
    self.level = self.raidData.level    --等级

    -- 发送章节变更事件
    EventControler:dispatchEvent(EliteEvent.ELITE_RADI_CHANGE)

    --================================================= 面板1
    local panelView = itemView.UI_1.panel_1
    local btnPassRaidRules = panelView.btn_guize
    local txtChapterAndRaid = panelView.txt_xy
    txtChapterAndRaid:visible(false)

    local panelUnfold = panelView.panel_zipian
    local huluMC = panelView.mc_hulu
    panelView.mc_hulu2:visible(false)
    local mainRewardUI = panelView.UI_1
    panelView.panel_xuanzhong:setVisible(true)

    -- 设置节名称
    local RaidName = GameConfig.getLanguage(itemData.name)
    panelView.txt_zhangjie:setString(RaidName)
    local sectionStr = Tool:transformNumToChineseWord(tonumber(itemData.section))
    panelView.txt_2:setString("第"..sectionStr.."节")

    -- 展示本关卡可获得的最贵重奖品/暂时展示第1个
    -- 点击可显示tips
    local rewardString =itemData["bonusView"]
    local str1 = rewardString[1]
    local params = {
        reward = str1,
    }
    mainRewardUI:setResItemData(params)
    mainRewardUI:setTouchEnabled(false)
    mainRewardUI:showResItemNum(false)  -- 隐藏数量

    local chapter = self.currentStoryId - 200
    txtChapterAndRaid:setString(chapter.."-"..itemData.section)

    -- 设置葫芦
    -- 通过读取战斗结果设置所得葫芦个数
    local raidScore = WorldModel:getBattleStarByRaidId( itemData.id )
    huluMC:setVisible(true)
    if raidScore == WorldModel.stageScore.SCORE_ONE_STAR then
        huluMC:showFrame(1)
    elseif raidScore == WorldModel.stageScore.SCORE_TWO_STAR then
        huluMC:showFrame(2)
    elseif raidScore == WorldModel.stageScore.SCORE_THREE_STAR then
        huluMC:showFrame(3)
    elseif raidScore == WorldModel.stageScore.SCORE_LOCK then
        huluMC:showFrame(4)
    end

    btnPassRaidRules:setVisible(false)
    -- 收起画卷
    panelUnfold:setTouchedFunc(function()
        if not self.isViewCreateComplete then
            return
        end
        self.currentUnfoldRaidId = -1
        self:updateRaidList()
    end)


    --============================================面板2
    local panelDetils = itemView.UI_2.panel_2
    local btn_saoOne = itemView.UI_2.panel_2.btn_1
    local btn_saoTen = itemView.UI_2.panel_2.btn_2
    local btn_gongLue = itemView.UI_2.panel_2.btn_gl
    local mc_tiaoZhan = itemView.UI_2.panel_2.mc_ts
    local txtRewardTips = itemView.UI_2.panel_2.txt_1
    local txtElitetimes = itemView.UI_2.panel_2.rich_3
    itemView.UI_2.panel_2.txt_green:visible(false)

    local rich_power = itemView.UI_2.panel_2.rich_power
    local powerNumUI = itemView.UI_2.panel_2.UI_number

    if itemData and itemData.recommendPower then
        powerNumUI:setPower(itemData.recommendPower)
    elseif rich_power and powerNumUI then
        rich_power:visible(false)
        powerNumUI:visible(false)
    end

    -- 设置节奖励
    local rewardArr = nil
    local rewardTip = ""

    -- 根据是否首次通关，展示不同的可能获得奖品
    local raidScore = WorldModel:getBattleStarByRaidId( itemData.id )
    if raidScore == WorldModel.stageScore.SCORE_LOCK then
        txtRewardTips:setString(GameConfig.getLanguage("#tid_elite_002")) 
        rewardTip = GameConfig.getLanguage("#tid_story_10101")
        rewardArr = itemData["firstBonus"]
    else  
        txtRewardTips:setString(GameConfig.getLanguage("#tid_elite_003"))
        rewardTip = GameConfig.getLanguage("#tid_story_10102")
        rewardArr = itemData["bonusView"]
    end

    local rewardNum = 3 --默认只展示3个奖品 但是配置可能不止三个
    
    -- 默认先隐藏全部
    for i=1,rewardNum do
        panelDetils["UI_"..i]:setVisible(false)
    end

    local count = #rewardArr
    if #rewardArr > 3 then
        count = 3
    end
    for i=1, count do
        local rewardUI = panelDetils["UI_"..i]
        rewardUI:setVisible(true)

        local rewardStr = rewardArr[i]
        local params = {
            reward=rewardStr,
        }
        rewardUI:setResItemData(params)
        -- rewardUI:setResItemClickEnable(true)
        rewardUI:showResItemNum(false)  -- 隐藏数量

        local resNum,_,_ ,resType,resId = UserModel:getResInfo( rewardStr )
        -- FuncCommUI.regesitShowResView(rewardUI:getResItemIconCtn(),resType,resNum,resId,rewardStr,true,true)
        FuncCommUI.regesitShowResView(rewardUI,resType,resNum,resId,rewardStr,true,true)
    end


    -- 面板2显示今日剩余挑战次数
    local eliteLeftTimes = WorldModel:getEliteRaidLeftTimes( itemData.id )
    local tips = GameConfig.getLanguage("#tid_elite_004")
    tips = "<color = 764F32>"..tips.."<->"
    local tips2 = eliteLeftTimes.."/3"
    if eliteLeftTimes == 0 then
        tips2 = "<color = E1725F>"..tips2.."<->"
    else
        tips2 = "<color = 139018>"..tips2.."<->"
    end  
    txtElitetimes:setString(tips..tips2)

    -- 显示扫荡按钮
    local _str = GameConfig.getLanguage("#tid_elite_005")
    if eliteLeftTimes == 0 then 

        btn_saoTen:setBtnStr(string.format(_str, tostring(3)))
    else
        local spLeftTimes = math.floor( UserExtModel:sp() / self.currentRaidSpCost)
        if eliteLeftTimes > spLeftTimes and spLeftTimes ~= 0 then
            eliteLeftTimes = spLeftTimes
        end
        btn_saoTen:setBtnStr(string.format(_str, tostring(eliteLeftTimes)))
    end

    local mySp = UserExtModel:sp()

    if tonumber(mySp) < tonumber(self.currentRaidSpCost) then
        itemView.UI_2.panel_2.mc_buzu:showFrame(2)
        itemView.UI_2.panel_2.mc_buzu.currentView.txt_2:setString(self.currentRaidSpCost)
    else
        itemView.UI_2.panel_2.mc_buzu:showFrame(1)
        itemView.UI_2.panel_2.mc_buzu.currentView.txt_2:setString(self.currentRaidSpCost)
    end

    -- 扫荡按钮侦听,未达到扫荡条件则将按钮置灰
    -- local raidScore = WorldModel:getBattleStarByRaidId( self.currentUnfoldRaidId )
    if EliteMainModel:isSweepConditionTrue(self.currentUnfoldRaidId,true) then
        FilterTools.clearFilter(btn_saoOne)
        FilterTools.clearFilter(btn_saoTen)
    else
        FilterTools.setGrayFilter(btn_saoOne)
        FilterTools.setGrayFilter(btn_saoTen)
    end
    btn_saoOne:setTap(c_func(self.onSweepOne,self))
    btn_saoTen:setTap(c_func(self.onSweepTen,self))

    -- 探索还是挑战
    if tonumber(self.currentUnfoldRaidId) >= tonumber(WorldModel:getMaxUnLockEliteRaidId()) then
        mc_tiaoZhan:showFrame(1)
        local btn_gotoScene = mc_tiaoZhan:getViewByFrame(1).btn_1
        btn_gotoScene:setTap(c_func(self.gotoExploreScene,self))
    else
        mc_tiaoZhan:showFrame(2)
        local btn_tiaoZhan = mc_tiaoZhan:getViewByFrame(2).btn_zhan
        btn_tiaoZhan:setTap(c_func(self.goTeamFormationView,self))
    end
    btn_gongLue:setTap(c_func(self.gotoStrategyView,self))

    -- 监听副本次数变化(扫荡、买次数),更新扫荡按钮及关卡
    EventControler:addEventListener(UserEvent.USEREVENT_STAGE_COUNTS_CHANGE, self.updateEliteTimes, self)
    -- 监听购买挑战次数
    EventControler:addEventListener(WorldEvent.WORLDEVENT_BUY_CHALLEGE_TIMES,self.buyEliteTimesSucceed,self)
    -- 布阵结束，开始战斗
    EventControler:addEventListener(BattleEvent.BEGIN_BATTLE_FOR_FORMATION_VIEW, self.onTeamFormationComplete, self)
end

-- 进入探索场景
function EliteLieBiaoView:gotoExploreScene(event)
    local isEnter = true
    local curChapter = FuncChapter.getChapterByStoryId(self.currentStoryId)

    if event and event.params then
        isEnter = false
        if event.params.viewType == FuncElite.TIPS_VIEW_TYPE.ENTER_SCENE then
            isEnter = true
            -- 回顾探索需要重置数据
            if WorldModel:isPassStory(self.currentStoryId) then
                EliteMapModel:resetExploreStatus( curChapter )
            end
        end
    end
    if isEnter then
        EliteMainModel:setCurrentChapter(curChapter) 
        EliteMapModel:updateMapData(true)
        local isPlayEnterAni = false
        WindowControler:showWindow("EliteMapView",isPlayEnterAni)
        -- 关闭本界面及选章主界面
        local mainView = WindowControler:getWindow( "EliteMainView" )
        if mainView then
            mainView:onClose()
        end
        self:onClose()
    end
end

-- 罗鑫说想加个小提示 O.O 2017/8/22 
function EliteLieBiaoView:buyEliteTimesSucceed()
    WindowControler:showTips(GameConfig.getLanguage("#tid_elite_006"))
end
-- 跳到通关攻略界面
function EliteLieBiaoView:gotoStrategyView()
    local arrayData = {
        systemName = FuncCommon.SYSTEM_NAME.ROMANCE,---系统名称
        diifID = self.currentUnfoldRaidId,  --关卡ID
    }
    RankAndcommentsControler:showUIBySystemType(arrayData)
end

-------------------------------------------------------------------------------
-- 扫荡
-------------------------------------------------------------------------------
-- 扫荡一次
function EliteLieBiaoView:onSweepOne()
    local times = 1
    if not EliteMainModel:isSweepConditionTrue(self.currentUnfoldRaidId) then --未达到三星
        return
    end

    local mySp = UserExtModel:sp()
    -- 体力不足
    if tonumber(mySp) < self.currentRaidSpCost then
        WindowControler:showWindow("CompBuySpMainView");
        return
    else
        self.curSweepType = self.sweetpType.SWEEP_ONE
        -- 精英关卡剩余次数
        local eliteLeftTimes = WorldModel:getEliteRaidLeftTimes(self.currentUnfoldRaidId)
        if eliteLeftTimes == 0 then
            self:goBuyEliteTimesView()
        else
            self:doSweep(self.currentUnfoldRaidId,times)
        end
    end
end

-- 扫荡动态次数(需要根据体力计算实际扫荡次数)
function EliteLieBiaoView:onSweepTen()
    local times = 10
    if not EliteMainModel:isSweepConditionTrue(self.currentUnfoldRaidId) then  --未达到三星
        return
    end

    local mySp = UserExtModel:sp()
     -- 体力不足
    if tonumber(mySp) < self.currentRaidSpCost then
        WindowControler:showWindow("CompBuySpMainView");
        return
    else
        -- 体力足够扫荡一次
        self.curSweepType = self.sweetpType.SWEEP_TEN

        -- 取体力剩余次数和关卡剩余次数的最小值
        local leftTimes = math.floor(mySp / self.currentRaidSpCost)
        if leftTimes < times then
            times = leftTimes
        end

        -- 精英关卡剩余次数
        local eliteLeftTimes = WorldModel:getEliteRaidLeftTimes(self.currentUnfoldRaidId)
        if eliteLeftTimes == 0 then
            self:goBuyEliteTimesView()
            return
        else
            if times > eliteLeftTimes then
                times = eliteLeftTimes
            end
        end 
        self:doSweep(self.currentUnfoldRaidId,times)  
    end
end

-- 扫荡
function EliteLieBiaoView:doSweep(raidId,times)
    local sweepCallBack = function(serverData)
        if serverData and serverData.result ~= nil then
            local params = {
                rewardData = serverData.result.data.reward,
                targetData = self.targetData,
                raidId = self.currentUnfoldRaidId,
                sweepType = self.curSweepType 
            }
            ShareBossModel:setFindRewardStatus(serverData.result.data.shareBossReward)
            WindowControler:showWindow("WorldSweepListView",params)
        end
    end
    WorldServer:sweep(raidId,times,c_func(sweepCallBack))
end

-- 检查扫荡条件  -- 三星关卡才能扫荡
function EliteLieBiaoView:isSweepConditionTrue(noShow)
    local raidScore = WorldModel:getBattleStarByRaidId( self.currentUnfoldRaidId )
    -- 特权是否开启
    local _type = FuncCommon.additionType.switch_super_sweep
    local hasTequan = FuncCommon.checkHasPrivilegeAdditionByType( _type )
    if raidScore == WorldModel.stageScore.SCORE_THREE_STAR then
        return true
    else
        if hasTequan and raidScore >= WorldModel.stageScore.SCORE_ONE_STAR then
            return true
        end
        if not noShow then
            local tipMsg = GameConfig.getLanguage("#tid2133")
            WindowControler:showTips(tipMsg)
        end
       
        return false
    end
end


-------------------------------------------------------------------------------
-- 当体力变化时
-------------------------------------------------------------------------------
function EliteLieBiaoView:onSpChange()
    self:updateSpDisplay()
    self:updateSweepBtn()  
end
-- 更新体力展示
function EliteLieBiaoView:updateSpDisplay()
    -- -- 没有选中任何关卡时隐藏体力显示
    if self.currentUnfoldRaidId == -1 then
        return
    end

    local targetItemData = FuncChapter.getRaidDataByRaidId(self.currentUnfoldRaidId)
    local itemView = self.raidScoller:getViewByData(targetItemData)
    if not itemView then
        return
    end

    local mySp = UserExtModel:sp()
    if tonumber(mySp) < tonumber(self.currentRaidSpCost) then
        itemView.UI_2.panel_2.mc_buzu:showFrame(2)
        itemView.UI_2.panel_2.mc_buzu.currentView.txt_2:setString(self.currentRaidSpCost)
    else
        itemView.UI_2.panel_2.mc_buzu:showFrame(1)
        itemView.UI_2.panel_2.mc_buzu.currentView.txt_2:setString(self.currentRaidSpCost)
    end
end

-- 扫荡之后更新关卡可挑战次数  更新扫荡按钮
function EliteLieBiaoView:updateEliteTimes()
    if self.currentUnfoldRaidId == -1 then
        return
    end
    local targetItemData = FuncChapter.getRaidDataByRaidId(self.currentUnfoldRaidId)
    local itemView = self.raidScoller:getViewByData(targetItemData)

    -- 面板1显示今日剩余挑战次数
    local panelView = itemView.UI_1.panel_1  -- 挑战次数的更新由挑战或者扫荡产生影响 
                                             -- 此两种情况都是某个关卡已经展开的情况下才发生
    local eliteLeftTimes = WorldModel:getEliteRaidLeftTimes(self.currentUnfoldRaidId)

    -- 面板2显示今日剩余挑战次数
    local txtElitetimes = itemView.UI_2.panel_2.rich_3
    local tips = GameConfig.getLanguage("#tid_elite_004")
    tips = "<color = 764F32>"..tips.."<->"
    local tips2 = eliteLeftTimes.."/3"
    if eliteLeftTimes == 0 then
        tips2 = "<color = E1725F>"..tips2.."<->"
    else
        tips2 = "<color = 139018>"..tips2.."<->"
    end  
    -- 剩余挑战次数
    txtElitetimes:setString(tips..tips2)

    self:updateSweepBtn()
end

-- 扫荡按钮受可挑战次数和体力的双重限制
function EliteLieBiaoView:updateSweepBtn()
    if self.currentUnfoldRaidId == -1 then --如果没有展开关卡则不用更新
        return
    end

    local targetItemData = FuncChapter.getRaidDataByRaidId(self.currentUnfoldRaidId)
    local itemView = self.raidScoller:getViewByData(targetItemData)
    -- 若对面板的点击过快，且恰逢体力变化
    -- 则可能造成进入了该函数后取得的itemview为空
    -- 此时应该返回以避免报错
    if itemView == nil then
        return
    end

    local btn_saoTen = itemView.UI_2.panel_2.btn_2

    -- 扫荡按钮还受体力的限制
    local eliteLeftTimes = WorldModel:getEliteRaidLeftTimes(self.currentUnfoldRaidId)
    if eliteLeftTimes == 0 then
        btn_saoTen:setBtnStr("扫荡3次")
        return
    end
    local spLeftTimes = math.floor( UserExtModel:sp() / self.currentRaidSpCost)
    if eliteLeftTimes > spLeftTimes and spLeftTimes ~= 0 then
        eliteLeftTimes = spLeftTimes
    end
    btn_saoTen:setBtnStr("扫荡"..eliteLeftTimes.."次")
end


-------------------------------------------------------------------------------
-- 布阵及战斗
-------------------------------------------------------------------------------
function EliteLieBiaoView:goTeamFormationView()
    -- 若关卡未开启则提示信息
    local maxPassRaid = WorldModel:getMaxUnLockEliteRaidId()
    if tonumber(self.currentUnfoldRaidId) > tonumber(maxPassRaid) then
        WindowControler:showTips(GameConfig.getLanguage("#tid_elite_007"))
        return  
    end

    -- 若挑战次数不足则购买
    local leftTimes = WorldModel:getEliteRaidLeftTimes(self.currentUnfoldRaidId)
    if leftTimes == 0 then  
        self:goBuyEliteTimesView()  
        return
    end

    local battleSpCost = self.currentRaidSpCost
    if leftTimes == 3 and maxPassRaid == "20101" then
        echo("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n 新手引导不消耗体力")
        battleSpCost = 0 
    end

    -- 若体力不足，则提示购买体力
    if not UserModel:tryCost(FuncDataResource.RES_TYPE.SP, tonumber(battleSpCost), true) then
        WindowControler:showWindow("CompBuySpMainView")  
        return
    end

    -- 获取关卡配置的布阵信息
    local format = self.raidData.format

    local formation = {}
    if format then
        for i=1,#format do
            local arr = string.split(format[i],",")
            formation[arr[1]] = arr[2]
        end
    end

    -- 进入布阵界面
    local params = {}
    params[FuncTeamFormation.formation.pve_elite] = {
        npcs = formation,
        raidId = self.currentUnfoldRaidId,
    }
    WindowControler:showWindow("WuXingTeamEmbattleView",FuncTeamFormation.formation.pve_elite,params)
end
function EliteLieBiaoView:goBuyEliteTimesView()
    local buyTimes = WorldModel:getEliteBuyTimes(self.currentUnfoldRaidId)
    local maxTimes = WorldModel:getEliteMaxBuyTimes()
    echo("__________ buyTimes,maxTimes ________________",buyTimes,maxTimes)
    if buyTimes < maxTimes then
        WindowControler:showWindow("WorldBuyChallengeTimesView",self.currentUnfoldRaidId);
    else
        WindowControler:showTips(GameConfig.getLanguage("tid_story_10119"))
    end
end


-- 布阵完成，进入战斗初始化函数
function EliteLieBiaoView:onTeamFormationComplete(event)
    local params = event.params
    local sysId = params.systemId
    if sysId == FuncTeamFormation.formation.pve_elite then
        local formation = params.formation
        echo("\n\n\n\n\n\n 进入战斗前 向服务器发送布阵信息及关卡id enterPVEStage ")
        WorldServer:enterPVEStage(self.currentUnfoldRaidId, c_func(self.enterEliteStageCallBack,self), formation)
    end
end

-- PVE战斗前初始化
function EliteLieBiaoView:enterEliteStageCallBack(event)
    if event.result ~= nil then
        self.battleId = event.result.data.battleInfo.battleId

        -- 缓存用户数据
        UserModel:cacheUserData()

        -- 保存当前战斗信息，战斗结算会用到
        local cacheBattleInfo = {}
        cacheBattleInfo.raidId = self.currentUnfoldRaidId
        cacheBattleInfo.battleId = self.battleId
        cacheBattleInfo.level = self.level
        cacheBattleInfo.spCost = self.currentRaidSpCost  -- 主角加经验(等于体力消耗) 
        cacheBattleInfo.heroAddExp = self.raidData.expPartner or 0  -- 伙伴加经验
        WorldModel:resetDataBeforeBattle()
        WorldModel:setCurPVEBattleInfo(cacheBattleInfo)
         -- 初始化PVE战斗结果
        local cacheData = {
            battleRt = Fight.result_lose,
            raidId = self.currentUnfoldRaidId,
            -- 缓存关卡成绩
            raidScore = WorldModel:getBattleStarByRaidId(self.currentUnfoldRaidId)
        }
        WorldModel:setPVEBattleCache(cacheData)

        -- 发送 关闭布阵界面 消息
        EventControler:dispatchEvent(BattleEvent.CLOSE_TEAM_FORMATION_FOR_BATTLE)

        -- 开始战斗
        local battleInfo = {}
        battleInfo.battleUsers = event.result.data.battleInfo.battleUsers;
        battleInfo.randomSeed = event.result.data.battleInfo.randomSeed;
        battleInfo.battleLabel = GameVars.battleLabels.worldPve
        battleInfo.battleId = self.battleId
        battleInfo.levelId = self.level

        local params = {
            raidId = self.raidId,
        }
        EliteMainModel:saveMonterData(params)
        BattleControler:startPVE(battleInfo)
    end
end

-- 战斗结束回到主界面会调这个方法
function EliteLieBiaoView:onBecomeTopView()
    if ShareBossModel:checkFindReward() then
        local findReward = ShareBossModel:getFindReward()
        WindowControler:showWindow("ShareFindRewardView", findReward)
        ShareBossModel:resetFindReward()
    end
end

--关闭按钮
function EliteLieBiaoView:onClose()
    self:startHide()
end

function EliteLieBiaoView:deleteMe()
	EliteLieBiaoView.super.deleteMe(self);
end

return EliteLieBiaoView;
