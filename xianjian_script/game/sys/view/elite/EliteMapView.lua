--
--Author:      zhuguangyuan
--DateTime:    2018-01-31 17:42:02
--Description: 探索地图
-- 创建时传入地图层  是否播放进入特效
--

local EliteMapView = class("EliteMapView", UIBase);

local EliteMapControlerClazz = require("game.sys.view.elite.eliteMap.EliteMapControler")

function EliteMapView:ctor(winName,playEnterAnim)
    EliteMapView.super.ctor(self, winName)

    self.curEliteChapter = EliteMainModel:getCurrentChapter()
    self.storyId = WorldModel:getStoryIdByTypeAndChapter(FuncChapter.stageType.TYPE_STAGE_ELITE,self.curEliteChapter)
    echo("_____ 进入场景 self.curEliteChapter,self.storyId _______",self.curEliteChapter,self.storyId)
    self.playEnterAnim = playEnterAnim
    self.itemsType = true
end

function EliteMapView:loadUIComplete()
	-- 关闭点击特效
	IS_SHOW_CLICK_EFFECT = false

	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:showEnterAnim()
	self:initView()
	if tostring(self.curEliteChapter) ~= tostring(EliteMainModel:getCurrentChapter()) then
    	self:showNewFloorMap(self.storyId)
    end
end 


--===== 战斗进入与恢复
-- ===== 注意这两个函数是在 WindowControler 的进入战斗和退出战斗恢复ui时调用的
function EliteMapView:getEnterBattleCacheData()
    echo("\n 战斗前缓存view数据 EliteMapView")
    return  {
                storyId = self.storyId,
                chapter = self.curEliteChapter
            }
end
function EliteMapView:onBattleExitResume(cacheData )
    dump(cacheData,"战斗恢复view EliteMapView")
    EliteMapView.super.onBattleExitResume(cacheData)
    if cacheData and cacheData.storyId then
        self.storyId = cacheData.storyId
        self.curEliteChapter = cacheData.chapter
	    if self.curEliteChapter ~= EliteMainModel:getCurrentChapter() then
	    	EliteMainModel:setCurrentChapter(self.curEliteChapter)
			EliteMapModel:updateMapData(true)
			EventControler:dispatchEvent(EliteEvent.ELITE_CHOOSR_STORYID_CHANGE,{storyId = self.storyId})
		end

        -- 判断是否有新章开启,自动打开剩余格子
        local newPassRaid = WorldModel:getEliteNewPassRaid()
        local maxStoryId = WorldModel:getUnLockMaxStoryId( FuncChapter.stageType.TYPE_STAGE_ELITE )
        if tonumber(maxStoryId) >= tonumber(self.storyId) 
            and newPassRaid and WorldModel:isLastRaidId(newPassRaid) 
        then
            if tonumber(maxStoryId) > tonumber(self.storyId) then
                self.storyId = maxStoryId
                local function showTips() 
                    WindowControler:showTips(GameConfig.getLanguage("#tid_elite_001"));
                end
                self:delayCall(c_func(showTips), 1)
            end
            local function forceOpenGrids()
                EventControler:dispatchEvent(EliteEvent.ELITE_AUTO_OPEN_LEFT_GRIDS)
            end
            self:delayCall(c_func(forceOpenGrids), 1)
        end
        if UserModel:isLvlUp() then 
            EventControler:dispatchEvent(UserEvent.USEREVENT_LEVEL_CHANGE); 
        end 
        self:checkOpenShopByDelayTime(1)  -- 检查临时商店是否开启
    end
end

-- 检查临时商店是否开启
function EliteMapView:checkOpenShopByDelayTime(delayTime)
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

-- 播放锁妖塔进入动画，只有在主界面点击"战"按钮才播放动画
function EliteMapView:showEnterAnim()
	if not self.playEnterAnim then
		return
	end

	if not self.curEliteChapter then
		return
	end

	local sceneData = FuncElite.getEliteMapSkinData(self.curEliteChapter)
	if sceneData and sceneData.starAnim then
		local enterAnim  = ViewSpine.new("UI_suoyatazhuanchang")
		enterAnim:playLabel(sceneData.starAnim,false)
		enterAnim:addto(self)
		enterAnim:pos(GameVars.width/2,-GameVars.height/2)
	end
end

function EliteMapView:registerEvent()
	EliteMapView.super.registerEvent(self);
	self.btn_back:setTap(c_func(self.clickClose,self,nil,true))
	-- 战斗相关界面全部关闭
	EventControler:addEventListener(BattleEvent.BATTLEEVENT_BATTLE_CLOSE,self.onBattleClose,self)

	-- 进入下一章的逻辑
	EventControler:addEventListener(EliteEvent.ELITE_GOTO_NEXT_CHAPTER, self.gotoNextChapter, self)
	EventControler:addEventListener(EliteEvent.ELITE_OPEN_BOX_SUCCEED, self.updateLeftToOpenBoxNum, self)

	-- 宝箱
    EventControler:addEventListener(WorldEvent.WORLDEVENT_OPEN_STAR_BOXES, self.updateStarBoxes, self)
end

function EliteMapView:updateLeftToOpenBoxNum( event )
	local curLeftNum = EliteMapModel:getLeftBoxNumber()
	self.panel_erhang.txt_2:setString("剩余"..curLeftNum.."个宝箱未领取")
end

function EliteMapView:updateStarBoxes()
    local _storyId = self.storyId
    local _boxPanel = self.panel_jdt
    local _view = self
    EliteMainModel:updateBoxProgress( _storyId,_boxPanel,_view )
    self:updateBtnRed()
end

function EliteMapView:initData()
	if not self.curEliteChapter then
		self.curEliteChapter = 1
	end
    self.perfectFloor = EliteMainModel:getPerfectFloor()
	self.maxItemNum = 3
	self.numMap = {
        "一","二","三","四","五",
        "六","七","八","九","十",
        "十一","十二","十三","十四","十五",
        "十六","十七","十八","十九","二十",
    }
end

function EliteMapView:initView()
	self.mcChapterName = self.panel_icon.mc_zhang
	
	self.panel_up:setVisible(false)
	self.panel_down:setVisible(false)
	self.panel_choose1:setVisible(false)
	self.panel_choose2:setVisible(false)
	self.panel_choose1:setTouchedFunc(GameVars.emptyFunc,nil,true)
	self.panel_choose2:setTouchedFunc(GameVars.emptyFunc,nil,true)
	self.btn_select:setTouchedFunc(c_func(self.goToChooseChapter,self))
    local currentChapter = EliteMainModel:getCurrentChapter()
    self.panel_erhang.txt_2:setColor(cc.c3b(255,255, 0))
    self:updateTitle( currentChapter )

    self:updateLeftToOpenBoxNum()
	self:initMap()	
	self:updateStarBoxes()
	-- self.panel_erhang2:visible(true)
	-- self.panel_erhang2.txt_1:setColor(cc.c3b(255,255, 0))
	-- self.panel_erhang2.txt_2:setColor(cc.c3b(255,255, 0))
end

-- 快捷选关
function EliteMapView:goToChooseChapter()
	local mainView = WindowControler:getWindow( "EliteMainView" )
	if mainView then
		mainView:onClose()
	end
	local mainView = WindowControler:getWindow( "EliteLieBiaoView" )
	if mainView then
		mainView:onClose()
	end
	-- 获取目标章
	self:updateBtnRed()
	
	-- echo("self.targetStoryId===",self.targetStoryId)
	WindowControler:showWindow("EliteMainView",self.targetStoryId) 
	self:beforeCloseView()
end

-- 从第一章开始往后检查所有解锁章节,看是否有未领取的宝箱
-- 有则 最小一章作为快捷选关的目标章
function EliteMapView:updateBtnRed()
	local chapters = self:getBoxesStoryList()
	-- dump(chapters,"chapters---------")
	if #chapters > 1 or (#chapters == 1 and chapters[1].chapter ~= self.curEliteChapter) then
		self.btn_select:getUpPanel().panel_red:visible(true)
	else
		self.btn_select:getUpPanel().panel_red:visible(false)
	end

	if #chapters > 0 then
		self.targetStoryId = chapters[1].storyId
	else
		self.targetStoryId = self.storyId
	end
end

-- 获取未领取宝箱的章列表
function EliteMapView:getBoxesStoryList()
	local maxStoryId = WorldModel:getUnLockMaxStoryId( FuncChapter.stageType.TYPE_STAGE_ELITE )
	local maxChapter = FuncChapter.getStoryDataByStoryId(maxStoryId).chapter
	local isHasBoxes
	-- 有未领取宝箱的章列表
	local chapters = {}
	for chapterId = 1,maxChapter do
		local data = FuncChapter.getStoryDataByChapter(chapterId,FuncChapter.stageType.TYPE_STAGE_ELITE)
		local isHasBoxes = WorldModel:hasStarBoxesByStoryId(data.id)
		if isHasBoxes then
			local data = {chapter=chapterId,storyId=data.id}
			chapters[#chapters+1] = data
		end
	end

	return chapters
end

function EliteMapView:initViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_icon,UIAlignTypes.LeftTop);
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_erhang,UIAlignTypes.LeftTop);
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_res,UIAlignTypes.RightTop);
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back,UIAlignTypes.RightTop);
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_choose1,UIAlignTypes.MiddleTop);
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_choose2,UIAlignTypes.MiddleBottom);

	FuncCommUI.setScale9Align(self.widthScreenOffset,self.panel_choose1.scale9_1,UIAlignTypes.MiddleTop, 1, 0)
	FuncCommUI.setScale9Align(self.widthScreenOffset,self.panel_choose2.scale9_1,UIAlignTypes.Middle, 1, 0)

	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_jdt,UIAlignTypes.MiddleBottom);
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_select,UIAlignTypes.RightBottom);

	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_erhang2,UIAlignTypes.LeftBottom);
end

function EliteMapView:initMap()
	self.mapControler = EliteMapControlerClazz.new(self,self.storyId,self.curEliteChapter)
	self.eliteMap = self.mapControler:getEliteMap()
	self._root:addChild(self.eliteMap,-1)
end

-- 进入下一层
function EliteMapView:gotoNextChapter()
	-- 播放转场动画
    self:playTransitionAnim(EliteMainModel:getCurrentChapter())
end

-- 播放转场动画
function EliteMapView:playTransitionAnim(callBack,floorIndex)
	self:deleteCurrentFloorMap()
	self:showNewFloorMap()
	self:updateStarBoxes()
    self:updateLeftToOpenBoxNum()
end

--[[
	恭喜通关动画
]]
function EliteMapView:playPerfectAnim(callBack)
	if not self.perfectAnim then
		local anim = self:createUIArmature("UI_gongxitongguan","UI_gongxitongguan",self,false,GameVars.emptyFunc)
		anim:pos(GameVars.width/2 - GameVars.UIOffsetX,-GameVars.height/2 + GameVars.UIOffsetY)
		self.perfectAnim = anim
	end

	local animCallBack = function()
		self.perfectAnim:setVisible(false)
		if callBack then
			callBack()
		end
	end

	local totalFrame = self.perfectAnim.totalFrame
	self.perfectAnim:registerFrameEventCallFunc(totalFrame,1,c_func(animCallBack))

	self.perfectAnim:startPlay(false)
end

-- 删除旧层
function EliteMapView:deleteCurrentFloorMap()
	local pos = {x=self.mapControler.charModel.gridModel.xIdx,y=self.mapControler.charModel.gridModel.yIdx}
	EliteMapModel:onCloseMapView( self.curEliteChapter,pos )
	if self.mapControler then
		self.mapControler:deleteMe()
	end
end

-- 创建下一层地图
function EliteMapView:showNewFloorMap()
	echo("\n\n\n\n____ -- 换下一层时,若是已经探索过的则复盘,否则进最新进度 _____")
	local nextStoryId = WorldModel:getNextStoryId(self.storyId)
	local maxStoryId = FuncChapter.getStoryIdByRaidId(WorldModel:getMaxUnLockEliteRaidId())
	if tonumber(nextStoryId) < tonumber(maxStoryId) then
		EliteMapModel:resetExploreStatus( FuncChapter.getChapterByStoryId(nextStoryId) )
	end

	self.storyId = nextStoryId 
	self.curEliteChapter = FuncChapter.getChapterByStoryId(self.storyId)
	EliteMainModel:setCurrentChapter(self.curEliteChapter)
	EliteMapModel:updateMapData(true)

	local firstRaidId = FuncChapter.getRaidIdByStoryId(self.storyId,1)
	EventControler:dispatchEvent(EliteEvent.ELITE_CHOOSR_STORYID_CHANGE,{storyId = self.storyId,raidId = firstRaidId})

	-- 展示新层
    self:updateTitle( self.curEliteChapter )
    self:initMap()
end

function EliteMapView:updateTitle( floor )
    -- 更新章标题 
    local chapter = tonumber(floor) 
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
end

function EliteMapView:playNumChangeEffect(fromNum, toNum)
	local textNode = self.panel_star.txt_1
	local textAnimCtn = self.ctn_anim

	local animName = "UI_common_res_num"
	self.ani_resNum = self:createUIArmature("UI_common", animName, textAnimCtn, false, GameVars.emptyFunc)
	local posx, posy = self.ani_resNum:getPosition()
	self.resNumAnimPosX = posx
	self.resNumAnimPosY = posy
	FuncArmature.changeBoneDisplay(self.ani_resNum , "layer6", textNode)
	local numAnim = self.ani_resNum
	local textRect = textNode:getContainerBox()
	numAnim:pos(0,-9)
	textNode:pos(-textRect.width/2, textRect.height/2)

	local setTextNum = function(num)
		textNode:setString(num)
	end

	numAnim:gotoAndPause(1)
	numAnim:startPlay(false)
	local frameLen = numAnim.totalFrame
	for frame=1,frameLen do
		local num = toNum
		if frame < frameLen then
			num = math.floor((toNum - fromNum)*1.0/frameLen * frame) + fromNum
		end
		numAnim:registerFrameEventCallFunc(frame, 1, c_func(setTextNum, num))
	end
end

-- 战斗后当前view显示在最顶层
-- 如果是战斗胜利 检查下动画播放 再更新数据
function EliteMapView:onBattleClose()
	-- 如果不是战后恢复
	if not self.isBattleExitResume then
		return
	end

	local callBack = function ()
	    -- 更新战斗结果数据
	    self:updateBattleResultData(1)
    end

    if EliteMainModel:checkBattleWin() then
    	self:delayCall(c_func(callBack),1/GameVars.GAMEFRAMERATE)
    else
	    self:updateBattleResultData()
	end
end

-- 战斗退出后恢复当前view
function EliteMapView:onBattleExitResume()
	echo("\n\n------------战斗退出后恢复........... ")
    self.isBattleExitResume = true
end

-- 更新战斗数据
function EliteMapView:updateBattleResultData(delayTime)
	delayTime = delayTime or 0
	local updateData = function()
	end
	self:delayCall(c_func(updateData), delayTime)
end


function EliteMapView:clickClose()
	self:onBackLogic()
    self:beforeCloseView()
end

function EliteMapView:beforeCloseView()
	local tempType = EliteMainModel:getGridAni()
    if tempType then
        EliteMainModel:saveGridAni(false)
    end
    self:startHide()
	self:deleteMe()
end

--[[
	返回逻辑
	1.返回到当前章对应的展开的列表界面
	2.选中当前章已通关最大节或已开启的最大节
]]
function EliteMapView:onBackLogic()
	if WorldModel:isPassStory(self.storyId) then
		local maxRaidId = WorldModel:getStoryMaxRaidId(self.storyId)
		WindowControler:showWindow("EliteLieBiaoView",maxRaidId)
	else
		WindowControler:showWindow("EliteLieBiaoView")
	end
end

function EliteMapView:startHide()
	EliteMapView.super.startHide(self)
end

function EliteMapView:deleteMe()
	-- 打开点击特效
	IS_SHOW_CLICK_EFFECT = true

	if self.mapControler then
		self.mapControler:deleteMe()
	end

	local pos = {x=self.mapControler.charModel.gridModel.xIdx,y=self.mapControler.charModel.gridModel.yIdx}
    EliteMapModel:onCloseMapView( self.curEliteChapter,pos )
	EliteMapView.super.deleteMe(self)
end

return EliteMapView;
