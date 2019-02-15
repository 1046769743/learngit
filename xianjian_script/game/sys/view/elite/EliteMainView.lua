--[[
	Author: zhuguangyuan
	Date:2017-07-21
	Description: 精英副本主界面
	-- 显示已经开启的所有章
	-- 滑动点击可以进入某一章的关卡列表界面
	-- 关卡列表界面点击上一章下一章后此界面做监听 并做相应的滚动条滚动到相应的章
]]

local EliteMainView = class("EliteMainView", UIBase);

function EliteMainView:ctor(winName,storyId)
    EliteMainView.super.ctor(self, winName)
    self.curStageType = FuncChapter.stageType.TYPE_STAGE_ELITE  --默认精英副本
    echo("______storyId____",storyId)
    self.currentStoryId = tostring(storyId) 
    self.passInStoryId = storyId
end

function EliteMainView:loadUIComplete()
	self:initData()  
	self:initView() 
	self:registerEvent(); 
	self:updateUI() --更新UI
end 

-- ===== 战斗进入与恢复
-- ===== 注意这两个函数是在 WindowControler 的进入战斗和退出战斗恢复ui时调用的
function EliteMainView:getEnterBattleCacheData()
    echo("\n 战斗前缓存view数据 EliteMainView")
    return  {
            	storyId = self.currentStoryId
            }
end

function EliteMainView:onBattleExitResume(cacheData )
    dump(cacheData,"战斗恢复view EliteMainView")
    EliteMainView.super.onBattleExitResume(cacheData)
    if cacheData and cacheData.storyId then
        self.currentStoryId = cacheData.storyId

        self:initData()
		self:updateUI() --更新UI
    end
end


----------------------------------------------
--1 初始化当前
----------------------------------------------
function EliteMainView:initData()
	-- 获取已经解锁的所有章数据
	self.unlockChapterData = {}
	local maxStoryId = WorldModel:getUnLockMaxStoryId( self.curStageType )
	local maxChapter = FuncChapter.getStoryDataByStoryId(maxStoryId).chapter
	for chapterId = 1,maxChapter do
		local data = FuncChapter.getStoryDataByChapter(chapterId,self.curStageType)
		table.insert(self.unlockChapterData,data)
	end

	-- 设置默认选中的章
    if self.currentStoryId == "nil" or self.currentStoryId == nil then
		self.currentStoryId = WorldModel:getUnLockMaxStoryId( self.curStageType )
	end
    self.currentChapter = FuncChapter.getStoryDataByStoryId(self.currentStoryId).chapter
end


----------------------------------------------
--2 UI组件重命名、适配
----------------------------------------------
function EliteMainView:initView()
    -- 滚动条
    self.unlockChapterScroller = self.scroll_1

    -- 章 面板
    self.unlockChapterPanel = self.panel_1
    self.unlockChapterPanel:setVisible(false)

    -- 标题 返回键
    self.panel_icon:setVisible(true)
    self.btn_back:setVisible(true)

    self:initViewAlign() --组件适配
    self:initScrollCfg() --初始化滚动条
    self:updateStarBoxes()
end

--组件适配
function EliteMainView:initViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_icon, UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back,UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_ziyuan,UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_jdt,UIAlignTypes.MiddleBottom)

    FuncCommUI.setScrollAlign(self.widthScreenOffset, self.scroll_1,UIAlignTypes.Middle,0,0)
end

--初始化滚动条
function EliteMainView:initScrollCfg()
	-- 创建一个章 画卷 的回调函数
	local createChapterFunc = function(itemData)
		local itemView = UIBaseDef:cloneOneView(self.unlockChapterPanel)
		itemView:setVisible(true)
		self:updateOneChapterView(itemView,itemData)
		return itemView
	end

	local updateCellFunc = function ( itemData,view )
		self:updateOneChapterView(view,itemData)
	end
	-- item分割线参数配置
    self.unlockChapterListParams = {
	    {
	    	data = self.unlockChapterData,
	        createFunc = createChapterFunc,
	        perNums= 1,
	        offsetX = 0,
	        offsetY = 50,
	        widthGap = 0,
	        heightGap = 10,
	        itemRect = {x = -130,y = -577,width = 410,height = 577},
	        perFrame = 1,
	        updateCellFunc = updateCellFunc,
	        cellWithGroup = 1
		}
    }
    self.unlockChapterScroller:setScrollPage(1, 30, 1,{scale = 0.5,wave = 0.38},c_func(self.scrollMoveEndCallBack, self))
    -- 隐藏滚动边
    self.unlockChapterScroller:hideDragBar()	

    self:delayCall(
    function ()
        local pos = self.currentChapter
        self.unlockChapterScroller:pageEaseMoveTo(pos,1,0.2);
    end,
    0.1)
end

-- 滑动滚动条选中 某个条目的回调
function EliteMainView:scrollMoveEndCallBack(itemIndex,groupIndex)
	if itemIndex < 1 then
        itemIndex = 1
    end
    echo("\n-------- 当前选中的index为 "..itemIndex)
    self:setSelectedItem(itemIndex)

    local _storyId = WorldModel:getStoryIdByTypeAndChapter(FuncChapter.stageType.TYPE_STAGE_ELITE,itemIndex)
    self.currentStoryId = _storyId
    
    local _boxPanel = self.panel_jdt
    local _view = self
    -- echoError ("\n-------- 更新宝箱状态--------",_storyId)
    EliteMainModel:updateBoxProgress( _storyId,_boxPanel,_view )
end

-- 设置某个item被选中的效果 
-- 显示立绘和云
function EliteMainView:setSelectedItem(itemIndex)
	echo("itemIndex = ",itemIndex)
	self.currentChapter = itemIndex
    local itemData = self.unlockChapterData[itemIndex]
    -- dump(itemData,"itemdata =")
    local itemView = self.unlockChapterScroller:getViewByData( itemData );

    -- 	隐藏前一次选中的item的立绘和云
    if self.lastSelectItemView ~= nil then 
        self.lastSelectItemView.panel_yun1:setVisible(false)
		self.lastSelectItemView.panel_yun2:setVisible(false)
		self.lastSelectItemView.panel_qipao:setVisible(false)

		local ctn_chapterBoss = self.lastSelectItemView.ctn_1
    	ctn_chapterBoss:removeAllChildren()
    end 

    -- 显示选中的item的立绘和云
    self.lastSelectItemView = itemView;
    if self.lastSelectItemView then
        self.lastSelectItemView.panel_yun1:setVisible(true)
		self.lastSelectItemView.panel_yun2:setVisible(true)
		if WorldModel:hasStarBoxesByStoryId(itemData.id) then
			self.lastSelectItemView.panel_qipao:setVisible(true)
		else
			self.lastSelectItemView.panel_qipao:setVisible(false)
		end

		--立绘动画
		echo("立绘 ====== ",itemData.eliteSetPainting)
		local partnerData = FuncPartner.getPartnerById(itemData.eliteSetPainting)
		local bossConfig = partnerData.dynamic
		local arr = string.split(bossConfig, ",");
	    local bossSpine = FuncRes.getArtSpineAni(arr[1])
	    bossSpine:setScale(0.4)
		bossSpine:pos(40,20)

		-- --遮罩与立绘合成
		-- local newHeroAnim = getMaskCan(artMaskSprite,bossSpine)
		-- newHeroAnim:pos(0,0)
		local ctn_chapterBoss = itemView.ctn_1
	    ctn_chapterBoss:removeAllChildren()
	    -- ctn_chapterBoss:addChild(newHeroAnim)
	    ctn_chapterBoss:addChild(bossSpine)
    end
end

-- 更新一章视图
function EliteMainView:updateOneChapterView(itemView,itemData)
	-- 点击该章进入章详情，展示章里的关卡
	itemView:setTouchEnabled(true)
	itemView:setTouchedFunc(function()
		self.currentChapter = itemData.chapter		
    	self.currentStoryId = itemData.id

    	self.unlockChapterScroller:gotoTargetPos(self.currentChapter,1,1,0)

    	local passRaidId =  WorldModel:getUnLockMaxRaidIdByStoryId(self.currentStoryId) -- 已经通关的最大关卡
    	local lastRaidId = FuncChapter.getLastRaidIdByStoryId(self.currentStoryId)	-- 本章的最大关卡
    	if tonumber(lastRaidId) < tonumber(passRaidId) then
    		passRaidId = lastRaidId
    	end
    	echo("\n\n\n进入的关卡为 = ",passRaidId)
   		WindowControler:showWindow("EliteLieBiaoView", passRaidId)  -- 进入一章的所有关卡界面
	end)

	local txt_chapterName = itemView.txt_zhangjie

	-- 显示卷轴的颜色
	local index = tonumber(string.sub(itemData.id, 2, 3))
	echo("################# index = ",index)
	itemView.mc_juanzhou:showFrame( index )

	itemView.panel_yun1:setVisible(false)
	itemView.panel_yun2:setVisible(false)
	itemView.panel_qipao:setVisible(false)

	
	if itemData.chapter == self.currentChapter then
		itemView.panel_yun1:setVisible(true)
		itemView.panel_yun2:setVisible(true)
		if WorldModel:hasStarBoxesByStoryId(self.currentStoryId) then
			itemView.panel_qipao:setVisible(true)
		else
			itemView.panel_qipao:setVisible(false)
		end

		self.lastSelectItemView = itemView

		local partnerData = FuncPartner.getPartnerById(itemData.eliteSetPainting)
		local bossConfig = partnerData.dynamic
    	local arr = string.split(bossConfig, ",");
	    local bossSpine = FuncRes.getArtSpineAni(arr[1])
		local ctn_chapterBoss = itemView.ctn_1
	    ctn_chapterBoss:removeAllChildren()
	    ctn_chapterBoss:addChild(bossSpine)
	    bossSpine:setScale(0.4)
		bossSpine:pos(40,20)
	end

	-- 设置章名称
	local chapterName = GameConfig.getLanguage(itemData.name)
	local chapterId   = itemData.chapter
	local _str = GameConfig.getLanguage("#tid_elite_008") 
	local sectionStr = Tool:transformNumToChineseWord(tonumber(chapterId))
	txt_chapterName:setString(string.format(_str,sectionStr)) 
	-- 设置章奖励
    local rewardNum = 3 --默认只展示3个奖品 但是配置可能不止三个
    
    -- 默认先隐藏全部
    for i=1,rewardNum do
        itemView["UI_"..i]:setVisible(false)
    end

    rewardArr = itemData["eliteRewardShow"]
    -- dump(rewardArr,"eliteRewardShow:")

    rewardNum = #rewardArr
    for i=1,rewardNum do
        local rewardUI = itemView["UI_"..i]
        rewardUI:setVisible(true)

        local rewardStr = rewardArr[i]
        local params = {
            reward=rewardStr,
        }
        rewardUI:setResItemData(params)
        rewardUI:setResItemClickEnable(false)
        if not isFirstPass then
            rewardUI:showResItemNum(false)  -- 隐藏数量
        end
    end
end


----------------------------------------------
--3 注册界面事件
----------------------------------------------
function EliteMainView:registerEvent()
	-- 返回
	self.btn_back:setTap(c_func(self.gobackToScene, self));

	-- 监听关卡列表界面点击上一章下一章 章切换事件
	-- 由关卡列表界面退出到本主界面时 对本主界面进行更新
    EventControler:addEventListener(EliteEvent.ELITE_CHOOSR_STORYID_CHANGE, self.setCenterChapter, self)

    -- 监听到打开了开宝箱所发的消息
    -- 进行主界面的气泡显示更新
    -- 气泡显示的另一种情况是进入关卡界面时还没有气泡
    -- 战斗结束后星级达到要求后要显示气泡，这种情况在战斗结束后返回重建界面的时候就算是做了刷新
    EventControler:addEventListener(WorldEvent.WORLDEVENT_OPEN_STAR_BOXES, self.updateRewardTips, self)

    -- 开宝箱
    EventControler:addEventListener(WorldEvent.WORLDEVENT_OPEN_STAR_BOXES, self.updateStarBoxes, self)
end

function EliteMainView:updateStarBoxes()
    local _storyId = self.currentStoryId
    local _boxPanel = self.panel_jdt
    local _view = self
    -- echoError ("1更新宝箱 = ",_storyId)
    EliteMainModel:updateBoxProgress( _storyId,_boxPanel,_view )
end

function EliteMainView:updateRewardTips( )
	-- 关卡界面领取了奖励 精英界面应当刷新
	-- 可以通过直接获取当前view 进行对奖励气泡的隐藏或再现
	-- 也可以直接调用selectedItem（index）
	self:setSelectedItem(self.currentChapter)
end

function EliteMainView:gobackToScene()
	-- 只有从场景中进入快捷选关的时候才会传 self.passInStoryId
	-- 这种情况下点返回按钮 回到上一次所在场景
	if self.passInStoryId then
		local _curChapter = FuncChapter.getChapterByStoryId(self.passInStoryId) 
		EliteMainModel:enterEliteExploreScene(_curChapter)
	end
    -- WindowControler:showWindow("EliteMapView")
    self:onClose()
end
--关闭按钮
function EliteMainView:onClose()
	self:startHide()
end

-- 关卡界面点击上一章下一章 精英主界面做相应的更新
function EliteMainView:setCenterChapter(event)
	if event == nil then
		return
	end

	local changedStoryId = event.params.storyId
	echo("changedStoryId=",changedStoryId)

	if changedStoryId == self.currentStoryId then
		return
	else
		self.currentStoryId = changedStoryId
		self.currentChapter = FuncChapter.getStoryDataByStoryId(self.currentStoryId).chapter
		-- 如果关卡界面新通关一章，进入新章后 主界面要做刷新以显示新开启的章
		if self.currentChapter > #self.unlockChapterData then
			self:initData()
			self:updateUI() --更新UI
		else
			self:setCurChapterInListCenter()
		end
		-- 更新宝箱状态
		self:updateStarBoxes()
	end
end


----------------------------------------------
--4 更新UI
----------------------------------------------
function EliteMainView:updateUI()
	-- 更新滚动条
	self:undateUnlockChapter()
end

-- 更新滚动条-更新所有已经解锁的章的视图
function EliteMainView:undateUnlockChapter()
	-- 取消缓存
	self.unlockChapterScroller:cancleCacheView()
	-- 更新滚动条
    self.unlockChapterScroller:styleFill(self.unlockChapterListParams)
    self.unlockChapterScroller:setOnCreateCompFunc( c_func(self.setCurChapterInListCenter,self) )
    -- -- 朝中心适配border
    -- self.unlockChapterScroller:setScrollBorder( -self.unlockChapterScroller.viewRect_.width/2 + self.unlockChapterListParams[1].itemRect.width/2  )
end

-- 将当前解锁的关卡设置为list的中心
function EliteMainView:setCurChapterInListCenter()
	-- 跳到滚动条组件的第几个 第几组 调到的方式0 1 2 缓存更新时间
	-- 跳到第一组的第currentChapter个，居中 
    self.unlockChapterScroller:gotoTargetPos(self.currentChapter,1,1,0)
    self:setSelectedItem(self.currentChapter)
end



function EliteMainView:deleteMe()
	-- TODO
	EliteMainView.super.deleteMe(self);
end

return EliteMainView;
