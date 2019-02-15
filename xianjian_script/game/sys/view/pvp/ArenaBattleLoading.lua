local ArenaBattleLoading = class("ArenaBattleLoading", UIBase)

function ArenaBattleLoading:ctor(winName, enemyInfo, myInfo)
	ArenaBattleLoading.super.ctor(self, winName)
	-- dump(enemyInfo, "\n\nenemyInfo==")
	self.enemyInfo = enemyInfo
	self.myInfo = myInfo
	if not self.myInfo then
		self.myInfo = FuncPvp.getPlayerRankInfo(PVPModel:getUserRank())
	end
    self.myInfo.name=self.myInfo.name=="" and GameConfig.getLanguage("tid_common_2006") or self.myInfo.name;
    self.bg = display.newSprite(FuncRes.iconBg("StartFight_bg_beijingdi.png"))
    -- echoError ("ArenaBattleLoading-=------------------")
end

function ArenaBattleLoading:loadUIComplete()
	local offsetY = (GameVars.height - GameVars.gameResHeight) / 2
	local offsetX = (GameVars.width - GameVars.gameResWidth) / 2
	-- 我方剪影
	self.myCharIconList = {
		-- 男
		{
			bg="arena_img_nanzhuyou.png",
			pos = {x = -150 + offsetX, y = 80 + offsetY},
			rankPos = {x = -299, y = 250 - offsetY},
			subPos = {x = -490, y = 261 - offsetY},
			lihuiPos = {x = 0, y = -120 - offsetY},
			animPos = {x = 0, y = 0}
		},
		-- 女
		{
			bg="arena_img_nvzhuyou.png",
			pos={x = -250 + offsetX, y = 50 + offsetY},
			rankPos = {x = -299, y = 250 - offsetY},
			subPos = {x = -490, y = 261 - offsetY},
			lihuiPos = {x = 0, y = -120 - offsetY},
			animPos = {x = 0, y = 0}
		}
	}

	-- 敌方剪影
	self.enemyCharIconList = {
		-- 男
		{
			bg="arena_img_nanzhuzuo.png",
			pos={x = 150 - offsetX, y = 30 + offsetY},
			rankPos = {x = 199, y = -137 - offsetY},
			subPos = {x = 106, y = -119 - offsetY},
			lihuiPos = {x = 0, y = -120 - offsetY},
			animPos={x = 0, y = 0}
		},
		-- 女
		{
			bg="arena_img_nvzhuzuo.png",
			pos={x = 150 - offsetX, y = 70 + offsetY},
			rankPos = {x = 199, y = -137 - offsetY},
			subPos = {x = 106, y = -119 - offsetY},
			lihuiPos = {x = 0, y = -120 - offsetY},
			animPos={x = 0, y = 0}
		}
	}

	self.progress_bar = self.panel_loading_progress.progress_loading
	self.ctn = display.newNode()
	self.ctn_jindu = display.newNode()
	self.progress_bar:addChild(self.ctn, 100)
	self.progress_bar:addChild(self.ctn_jindu, 50)
	self.total_process = 100
	self.progress = 0
	-- 本次改版去掉云 2017.06.24
	-- self.progress_cloud = self.panel_loading_progress.panel_cloud
	-- self.progress_cloud_box = self.progress_cloud:getContainerBox()
	self.progress_panel_box = self.progress_bar:getContainerBox()
	self.txt_progress = self.panel_loading_progress.txt_1
	self.progress_bar:setPercent(0)
	
	self:registerEvent()
	self:setViewAlign()
	
	self:scheduleUpdateWithPriorityLua(c_func(self.frameUpdate, self) ,1)
	local addPercent = self:getOneProcess(10)
	self:tweenProgress(addPercent, 5)
	self:animShowPlayerPanel()
	self:initPlayerInfos()	
    -- local    _colorLayer=display.newColorLayer(cc.c4b(0,0,0,255*0.7));
    -- _colorLayer:setContentSize(cc.size(GameVars.width+200,GameVars.height+100));
    -- local    _worldPointX,_worldPointY=self.ctn_mask_stay:getPosition();
    -- _colorLayer:setPosition(cc.p(-_worldPointX-100,_worldPointY));
    -- self.ctn_mask_stay:addChild(_colorLayer);
end

function ArenaBattleLoading:animShowPlayerPanel()
	self.panel_loading_progress:visible(false)
	self.panel_lbao1:setVisible(false)
	self.panel_lbao2:setVisible(false)
	self.panel_lbao3:setVisible(false)
	self.panel_lbao4:setVisible(false)
	self.panel_redbg:setVisible(false)
	self.panel_bluebg:setVisible(false)
	self.ctn_you:setVisible(false)
	self.ctn_zuo:setVisible(false)
	self.panel_loading_progress:pos(-450, 0)	
	self.panel_lbao1:pos(-150, 30)
	self.panel_lbao2:pos(-150, 30)
	self.panel_lbao3:pos(-150, 30)
	self.panel_lbao4:pos(-150, 30)
	self.panel_redbg:pos(-490, 271)
	self.panel_bluebg:pos(-363, 271)
	self.ctn_you:pos(50, 180)
	self.ctn_zuo:pos(0, 180)
	local showProgress = function()
		local addPercent = self:getOneProcess(45)
		self:tweenProgress(addPercent, 20)
	end

    self.ruchangAnim =  self:createUIArmature("UI_arenaLoading", "UI_arenaLoading_duizhan", self.ctn_ruchang, true)
    local anim = self.ruchangAnim:getBoneDisplay("layer23")
    -- ruchangAnim:pos(-GameVars.width / 2, GameVars.height / 2);

	-- local animCallBack = function()
	-- 	anim:pause()
	-- 	-- 呼吸光子动画
	-- 	local shineAnim = anim:getBoneDisplay("layer8")
	-- 	shineAnim:startPlay(true)
	-- end
	-- anim:registerFrameEventCallFunc(anim.totalFrame, 1, c_func(animCallBack))
	FuncArmature.changeBoneDisplay(anim, "node1", self.bg)
	FuncArmature.changeBoneDisplay(anim, "node2", self.ctn_you)
    FuncArmature.changeBoneDisplay(anim, "node3", self.ctn_zuo)
    FuncArmature.changeBoneDisplay(anim, "node4", self.panel_lbao3)
    FuncArmature.changeBoneDisplay(anim, "node5", self.panel_lbao4)
    FuncArmature.changeBoneDisplay(anim, "node6", self.panel_lbao1)
    FuncArmature.changeBoneDisplay(anim, "node7", self.panel_lbao2)
    FuncArmature.changeBoneDisplay(anim, "node8", self.panel_loading_progress)
    FuncArmature.changeBoneDisplay(anim, "node9", self.panel_bluebg)
    FuncArmature.changeBoneDisplay(anim, "node10", self.panel_redbg)
    self.ruchangAnim:startPlay(false, true)
    self.ruchangAnim:registerFrameEventCallFunc(self.ruchangAnim.totalFrame, 1, c_func(showProgress))
end

function ArenaBattleLoading:getOneProcess(num)
	if num < self.total_process then
		self.total_process = self.total_process - num
		return num
	end
end

function ArenaBattleLoading:frameUpdate()
	self:updateProgressCloud()
end

function ArenaBattleLoading:getLeftProcessToShow()
	return self.total_process
end

function ArenaBattleLoading:registerEvent()
    EventControler:addEventListener(LoadEvent.LOADEVENT_BATTLELOADCOMP, self.onBattleResLoadOver, self)
    -- EventControler:addEventListener(BattleEvent.BEGIN_PVP_BATTLE_FOR_FORMATION_VIEW, self.enterPVPBattle, self)
end

-- function ArenaBattleLoading:enterPVPBattle(event)
-- 	EventControler:dispatchEvent(BattleEvent.CLOSE_TEAM_FORMATION_FOR_BATTLE)
-- 	local parmas = event.params
-- 	self.ruchangAnim:registerFrameEventCallFunc(20, 1, c_func(function ()
-- 			EventControler:dispatchEvent(BattleEvent.BEGIN_BATTLE_FOR_FORMATION_VIEW,
--                 {formation = parmas.formation,systemId = parmas.systemId, params = parmas.params})
-- 		end))
-- end

function ArenaBattleLoading:onBattleResLoadOver()
	--TODO   6 为战斗固定延迟的帧数
	self:tweenProgress(self:getLeftProcessToShow(), 6)
	-- self.progress_bar:tweenToPercent(100, 6)
end

function ArenaBattleLoading:updateProgressCloud()
	if not self.progress_bar then return end
	-- local percent = self.progress_bar:getPercent()
	-- local totalWidth = self.progress_box.width
	-- -- self.progress_cloud:pos(percent*1.0/100 * totalWidth, -self.progress_box.height/2)
	-- percent = math.floor(percent)
	-- if percent >= 100 then
	-- 	percent = 100
	-- 	self.panel_loading_progress.txt_1:setString(percent .. "%")
	-- 	self:delayCall(c_func(self.startHide,self),0.05)
	-- 	return
	-- end

	-- self.panel_loading_progress.txt_1:setString(percent .. "%")

	local box = self.progress_panel_box
	local totalWidth = box.width
	-- echoError("width=", box.width, "height=", box.height)
	local percent = self.progress_bar:getPercent()

	percent = math.floor(percent)
	if percent >= 100 then
		percent = 100
	end
	self.txt_progress:setString(math.ceil(percent).."%")

	if not self.animMan then
		self.animMan = self:createUIArmature("UI_loading", "UI_loading_renwu", self.ctn, true)
		self.animMan:pos(-2, 35)

		self.animGuang = self:createUIArmature("UI_loading", "UI_loading_guangxiao", self.ctn, true)
		self.animGuang:pos(5, 0)

		self.animProgress = self:createUIArmature("UI_loading", "UI_loading_jindu", self.ctn_jindu, true)
		self.animProgress:pos(totalWidth / 2 + 1, -6) 
	end

	-- percent = 20
	local anim = self.animProgress
	local zhezhao = anim:getBoneDisplay("layer14")
	zhezhao:pos(math.ceil(percent)*1.0/100 * totalWidth - 675, -box.height/2)
	self.ctn:pos(math.ceil(percent)*1.0/100 * totalWidth - 5, -box.height/2)

	if percent == 100 then
		self:delayCall(c_func(self.startHide,self), 0.05)
		return
	end
	
end


function ArenaBattleLoading:setViewAlign()
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_enemy, UIAlignTypes.Left)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_my, UIAlignTypes.Right)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_loading_progress, UIAlignTypes.MiddleBottom)
end

function ArenaBattleLoading:initPlayerInfos()
	-- 敌方信息
	-- dump(self.enemyInfo,"敌人时装信息 == ")
	local enemyName = self.enemyInfo.name

	if enemyName == "" or not enemyName then
		enemyName =FuncCommon.getPlayerDefaultName()
	end
	self.panel_lbao3.txt_name:setString(enemyName)
	self.panel_lbao4.txt_rank:setString(self.enemyInfo.rank)
    local enemyCtn = self.ctn_zuo
   	-- local enemySpine = FuncPvp.getCharSpine(self.enemyInfo.avatar)
	
	local enemySex = FuncChar.getCharSex(self.enemyInfo.avatar)
	local enemyBgInfo = self.enemyCharIconList[enemySex]
	-- local enemyCharBg = display.newSprite(FuncRes.iconOther(enemyBgInfo.bg))
	-- enemyCharBg:anchor(0.5,0)
	-- enemyCharBg:pos(enemyBgInfo.pos.x,enemyBgInfo.pos.y)
	-- self.panel_enemy.panel_info.panel_1:pos(enemyBgInfo.rankPos.x, enemyBgInfo.rankPos.y)
	-- -- self.panel_enemy.panel_info.panel_2:pos(enemyBgInfo.subPos.x, enemyBgInfo.subPos.y)
	-- enemyCtn:addChild(enemyCharBg)
	-- enemyCtn:addChild(enemySpine)

	
	-- 敌方立绘
	-- 如果是机器人则使用默认立绘 否则取得敌方立绘信息
	local enemyGarmentId = nil
	if self.enemyInfo.userBattleType == 2 then
		local robotInfo = FuncPvp.getRobotById(FuncPvp.genRobotRid(self.enemyInfo._id))
		enemyGarmentId = robotInfo.garmentId
	else
    	enemyGarmentId = self.enemyInfo.userExt.garmentId
    end
	    
	local avatarId = self.enemyInfo.avatar
    local lihuiSprite1 = FuncGarment.getGarmentLihui(enemyGarmentId, avatarId, nil, nil, "ui")
    local zhezhaoHong = FuncRes.iconOther("StartFight_img_hongzhezhao")
	local zhezhaoSpHong = display.newSprite(zhezhaoHong)
	zhezhaoSpHong:setScaleX(-1)
	-- local artSp1 = FuncCommUI.getMaskCan(zhezhaoSpHong, lihuiSprite1)
    lihuiSprite1:setScaleX(-0.8)
    lihuiSprite1:setScaleY(0.8)
    lihuiSprite1:pos(enemyBgInfo.lihuiPos.x, enemyBgInfo.lihuiPos.y)
    zhezhaoSpHong:pos(-80.5, 115)
    lihuiSprite1 = FuncCommUI.getMaskCan(zhezhaoSpHong, lihuiSprite1)
    enemyCtn:addChild(lihuiSprite1);


	-- 我方信息
	-- dump(self.myInfo,"我方时装信息 == ")
	local selfName = self.myInfo.name
	if selfName =="" or not selfName then
		selfName = FuncCommon.getPlayerDefaultName()
	end

	self.panel_lbao1.txt_name:setString(selfName)
	self.panel_lbao2.txt_rank:setString(self.myInfo.rank)
    local myCtn = self.ctn_you
    -- local mySpine = FuncPvp.getCharSpine(self.myInfo.avatar)
    -- mySpine:setRotationSkewY(180);

    local mySex = FuncChar.getCharSex(self.myInfo.avatar)
    local myBgInfo = self.myCharIconList[mySex]
	-- local myCharBg = display.newSprite(FuncRes.iconOther(myBgInfo.bg))
	-- myCharBg:anchor(0.5,0)
	-- myCharBg:pos(myBgInfo.pos.x,myBgInfo.pos.y)
	-- self.panel_my.panel_info.panel_1:pos(myBgInfo.rankPos.x, myBgInfo.rankPos.y)
	-- -- self.panel_my.panel_info.panel_2:pos(myBgInfo.subPos.x, myBgInfo.subPos.y)
	-- myCtn:addChild(myCharBg)
	-- myCtn:addChild(mySpine)

	-- 我方立绘
    local avatarId = self.myInfo.avatar
    local MyGarmentId = GarmentModel:getOnGarmentId()
    if self.myInfo.userExt.garmentId ~= nil then
    	MyGarmentId = self.myInfo.userExt.garmentId
    end

    -- if tostring(MyGarmentId) == "3" and tostring(avatarId) == "104" then
    -- 	myBgInfo.lihuiPos.x = myBgInfo.lihuiPos.x - 100
    -- end
    -- 立绘朝左 不翻转 故最后一个参数传true
    local lihuiSprite2 = FuncGarment.getGarmentLihui(MyGarmentId, avatarId, nil, nil, "ui")
    local zhezhaoLan = FuncRes.iconOther("StartFight_img_lanzhezhao")
	local zhezhaoSpLan = display.newSprite(zhezhaoLan)
	-- local artSp2 = FuncCommUI.getMaskCan(zhezhaoSpLan, lihuiSprite2)
    lihuiSprite2:setScaleX(-0.8)
    lihuiSprite2:setScaleY(0.8)
    lihuiSprite2:pos(myBgInfo.lihuiPos.x, myBgInfo.lihuiPos.y)
    zhezhaoSpLan:pos(-133, 115)
    lihuiSprite2 = FuncCommUI.getMaskCan(zhezhaoSpLan, lihuiSprite2)
    myCtn:addChild(lihuiSprite2);

	-- self.panel_my:pos(myBgInfo.animPos.x,myBgInfo.animPos.y)
	-- self.panel_enemy:pos(enemyBgInfo.animPos.x,enemyBgInfo.animPos.y)
end

function ArenaBattleLoading:tweenProgress(addPercent, frame)
	self.progress =  self.progress + addPercent
	self.progress_bar:tweenToPercent(self.progress, frame)
end

return ArenaBattleLoading

