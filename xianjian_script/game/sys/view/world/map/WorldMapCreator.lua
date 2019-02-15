--[[
	Author: 张燕广
	Date:2017-09-14
	Description: 负责地图元素的创建
]]

WorldMapCreator = class("WorldMapCreator")

local WorldCharModelClazz = require("game.sys.view.world.model.WorldCharModel")
local WorldSpaceModelClazz = require("game.sys.view.world.model.WorldSpaceModel")
local WorldNpcModelClazz = require("game.sys.view.world.model.WorldNpcModel")
local WorldPlayerModelClazz = require("game.sys.view.world.model.WorldPlayerModel")
local WorldCloudModelClazz = require("game.sys.view.world.model.WorldCloudModel")
local WorldMapEffectModelClazz = require("game.sys.view.world.model.WorldMapEffectModel")
local WorldMapMontainModelClazz = require("game.sys.view.world.model.WorldMapMontainModel")

function WorldMapCreator:ctor(controler)
	self.controler = controler
	self.mainMap = self.controler.mainMap
	self.mapUI = self.controler.mapUI
	self.mapConfig = self.controler.mapConfig
	self.mapUI.UI_name_title:setVisible(false)
	self:registEvent()
	self:initData()
end

function WorldMapCreator:initData()
	self.spaceArr = {}
	self.controler.spaceArr = self.spaceArr

	self.mapMontainArr = {}
	self.controler.mapMontainArr = self.mapMontainArr

	self.montainScale = 1.0

	-- 第三方玩家相关变量
	-- 是否展示第三方玩家
	self.isShowOtherPlayer = true --FuncSetting.showOtherPlayer()

	self.npcSize = {width=180,height=180}
	-- 第三方玩家
	self.playerArr = {}
	self.controler.playerArr = self.playerArr
	self.showPlayerDataList = {}

	self.maxPlayerNum = 10
	self.playerScale = 0.8 * self.controler.charScale
	self.npcScale = 1.1

	-- 将要死亡的玩家数组
	self.willDiePlayerArr = {}
	-- 已经死亡的玩家数组
	self.diedPlayerArr = {}
	-- 空闲玩家数组
	self.idlePlayerArr = {}

	self.onlinesPlayers = {}

	self.playerMinX = self.mapConfig.rect.x
	self.playerMaxX = self.mapConfig.rect.x + self.mapConfig.rect.width

	self.playerMinY = -(self.mapConfig.rect.y + self.mapConfig.rect.height)
	self.playerMaxY = -self.mapConfig.rect.y
end

function WorldMapCreator:registEvent()
	-- 获取在线玩家成功
	EventControler:addEventListener(WorldEvent.GET_ONLINE_PLAYER_SUCCESS,self.initPlayers, self); 
	-- 刷新在线玩家
	EventControler:addEventListener(WorldEvent.GET_ONLINE_PLAYER_AGAIN_SUCCESS, self.refreshPlayers, self)
end

-- ======================================================刷新方法======================================================
function WorldMapCreator:updateFrame(dt)
	self:updatePlayer()
	self:checkRefreshPlayers()
end

function WorldMapCreator:updatePlayer(dt)
	if #self.willDiePlayerArr > 0 then
		-- 将要死亡的玩家
		for i=1,#self.willDiePlayerArr do
			local player = self.willDiePlayerArr[i]
			-- table.removebyvalue(self.playerArr,player)
			-- player:deleteMe()
			self:playPlayerDieAnim(player)
		end
		self.willDiePlayerArr = {}
	end
	

	if #self.diedPlayerArr > 0 then
		-- 已经死亡的玩家
		for i=1,#self.diedPlayerArr do
			local player = self.diedPlayerArr[i]
			if player then
				table.removebyvalue(self.playerArr,player)
				if player.deleteMe then
					player:deleteMe()
				end
			end
		end
		self.diedPlayerArr = {}
	end
	
end

-- =====================================================创建类方法======================================================
-- 初始化地图地标
function WorldMapCreator:initMapSpaceModels()
	self:initSpaceModels()
	if self.controler.is3DMode then
		-- self:initMapMontain()
		self:initMapMontainModels()
	end
end

-- 初始化地图场景特效Models
function WorldMapCreator:initMapEffModels()
	local spaceCtn = self.mainMap:getSpaceLayer()
	local effCfg = self.mapConfig.mapEff
	local mapEffArr = self.controler.mapEffArr

	for k,v in pairs(effCfg) do
		local effInfo = v
		local effName = k
		local curEffModel = WorldMapEffectModelClazz.new(self.controler,spaceCtn,effInfo)
		if curEffModel then
			mapEffArr[#mapEffArr+1] = curEffModel
		end
	end
end

-- 创建主角
function WorldMapCreator:createCharModel(charInitPos,charSize,charScale)
	local charCtn = self.mainMap:getPlayerLayer()
	local charShadowCtn = self.mainMap:getPlayerShadowLayer()

	local charSex = UserModel:sex()
	
	local charModel = WorldCharModelClazz.new(self.controler,charSex)
	local playerSpine = self:getCharSpine(charSex,self:getCharGarmentId())
    -- playerSpine:zorder(2)
    charModel:initView(charCtn,playerSpine,charInitPos.x,charInitPos.y,0,charSize)
    -- charModel:initView(charCtn,playerSpine,GameVars.width/2,-GameVars.height  /2,0)
    charModel:setViewScale(charScale)

    -- 设置主角身上其他视图
    self:setCharOtherView(charModel)

	return charModel
end

--[[
	设置主角身上其他视图
]]
function WorldMapCreator:setCharOtherView(charModel)
	local charShadowCtn = self.mainMap:getPlayerShadowLayer()
	-- 主角影子
	local shadow = display.newSprite(FuncRes.iconPVE("world_char_shadow"))
	charModel:setShadowView(charShadowCtn, shadow)

	-- 设置名称
	local cloneTitleUI = UIBaseDef:cloneOneView(self.mapUI.UI_name_title);
	charModel:setNameView(charCtn, cloneTitleUI)

	-- 设置主角携带的伙伴
	if PrologueUtils:showPrologueJoinAnim() then
		local myPartnersAnim = ViewSpine.new("world_lixiaoyaozhaolinger")
		myPartnersAnim:playLabel("fei",true)
		charModel:setPartners(myPartnersAnim)
	end
end

--[[
	更新主角视图(更新主角皮肤时会更新整个视图)
]]
function WorldMapCreator:updateCharModelView(charModel)
	local charSex = UserModel:sex()
	local garmentId= self:getCharGarmentId()

	local playerSpine = self:getCharSpine(charSex,garmentId)
	charModel:updateModelView(playerSpine,charModel.mySize)
	-- 设置主角身上其他视图
	self:setCharOtherView(charModel)
end

--[[
	创建序章衔接之门特效
]]
function WorldMapCreator:createPrologueDoorAnim(spaceName)
	local spaceCtn = self.mainMap:getSpaceLayer()
	local anim = self.mapUI:createUIArmature("UI_xuzhangjieshu", "UI_xuzhangjieshu_zong", spaceCtn, false, GameVars.emptyFunc)
	self.controler:setViewRotation3DBack(anim)
	
	local spaceInfo = self.mapConfig.mapSpace[spaceName]

	anim:pos(spaceInfo.x,spaceInfo.y)
	anim:zorder(1)
	return anim
end

-- 创建云
function WorldMapCreator:createCloudModel()
	local ctn = self.mainMap:getPlayerLayer()

	local cloudModel = WorldCloudModelClazz.new(self.controler)
	local cloudSprite = display.newSprite("icon/world/cloud.png")
	local x = 0
	local y = 0
	local z = 0
	local size = cloudSprite:getContentSize()
    cloudModel:initView(ctn,cloudSprite,x,y,z,size)
    
	return cloudModel
end

-- 获取主角服装ID
function WorldMapCreator:getCharGarmentId()
	local garmentId = GarmentModel.DefaultGarmentId
	if LoginControler:isLogin() then
		garmentId = GarmentModel:getOnGarmentId()
	end

	return garmentId
end

function WorldMapCreator:getCharSpine(sex,garmentId)
	local spineName = FuncGarment.getWorldSpineById(sex, garmentId)
	return ViewSpine.new(spineName)
end

-- 创建npc
function WorldMapCreator:createNpcModel(curRaidData,npcHeightOffset)
	local playerCtn = self.mainMap:getPlayerLayer()
	local npcModel = WorldNpcModelClazz.new(self.controler)

	local npcId = curRaidData.storyNpc
	local npcSourceData = FuncTreasure.getSourceDataById(npcId)
	-- TODO 暂时用写死的高度
	local npcHeight = npcSourceData.viewSize[2] + npcHeightOffset
	self.npcSize.height = npcHeight

	local npcSpine = nil
	if npcId then
		local npcPos = curRaidData.enterLocation
		npcSpine = self:getNpcSpineById(npcId)
		npcSpine:zorder(1)
		npcSpine:setScale(self.npcScale)

		-- TODO
        local npcLockTip = self:getNpcLockTip()
        npcSpine:addChild(npcLockTip)
        npcLockTip:pos(0,npcHeight)
        -- 默认隐藏
        npcLockTip:setVisible(false)
        self.controler.npcLockTip = npcLockTip

        local npcUnLockTip = self:getNpcUnLockTip()
        npcSpine:addChild(npcUnLockTip)
        npcUnLockTip:pos(0,npcHeight)
        self.controler.npcUnLockTip = npcUnLockTip

		npcModel:initView(playerCtn,npcSpine,tonumber(npcPos[1]),tonumber(-npcPos[2]),0,self.npcSize)
		-- 注册气泡
		self:registerNpcBubleView(npcLockTip)
		self:registerNpcBubleView(npcUnLockTip)
	end

	if not npcModel then
		echoError("找策划配置错误npcId=",npcId)
		dump(curRaidData,"curRaidData")
	end

	if TutorialManager.getInstance():isNpcInWorldHalt() then
		npcModel:setCanWalk(false)
	end

	return npcModel
end

-- 更新npc 指引头像
function WorldMapCreator:updateNpcTipHead(raidData)
	local npcId = raidData.storyNpc

	local headName = raidData.head
	local taskTipView = self.controler.taskTip

	if taskTipView then
		if taskTipView:getChildByName("head") then
			taskTipView:removeChildByName("head",true)
		end
		
		local npcHead = display.newSprite(FuncRes.iconHead(headName))
		npcHead:setName("head")
		taskTipView:addChild(npcHead)

		npcHead:anchor(0.5,0.5)
		npcHead:pos(-6.2, 0)
		npcHead:zorder(1)
		npcHead:setScale(0.89)
	end
end

function WorldMapCreator:registerNpcBubleView(view)
	 local conditions = {
        systemname = FuncCommon.SYSTEM_NAME.PVE,
        npc = true,
        offset = {
          x = -50,
          y = 10,
        },
      }
      FuncCommUI.regesitShowBubbleView(conditions,view)
end

-- 创建npc spine动画
function WorldMapCreator:getNpcSpineById(npcId)
	local npcSourceData = FuncTreasure.getSourceDataById(npcId)

	local npcAnimName = npcSourceData.spine
    local npcAnimLabel = npcSourceData.flying or npcSourceData.stand

    local npcNode = nil
    local npcAnim = nil
    if npcId == nil or npcAnimName == nil or npcAnimLabel == nil then
        echoError("npcId =",npcId,",npcAnimName=",npcAnimName,",npcAnimLabel=",npcAnimLabel)
    else
        local spbName = npcAnimName .. "Extract"
        npcAnim = ViewSpine.new(spbName, {}, nil, npcAnimName, nil, npcSourceData);
        npcAnim:playLabel(npcAnimLabel);
    end

    return npcAnim
end

-- 创建npc任务锁定标记
function WorldMapCreator:getNpcLockTip()
	local tipImg = "world_img_tanhui"
	local tipSprite = display.newSprite(FuncRes.iconPVE(tipImg))
    return tipSprite
end

-- 创建npc任务未锁定标记
function WorldMapCreator:getNpcUnLockTip()
    local taskTipAnim = self.mapUI:createUIArmature("UI_shijieditu","UI_shijieditu_tanhao",nil, true, GameVars.emptyFunc)
    taskTipAnim:playWithIndex(1,false,false)

    local callBack = function()
    	taskTipAnim:playWithIndex(2,true,false)
	end

	taskTipAnim:registerFrameEventCallFunc(15,1,c_func(callBack))
    return taskTipAnim
end

-- 初始化地标
-- TODO 后期优化，动态初始化地标，比如:不在屏幕内销毁地标或者设置为不可见
function WorldMapCreator:initSpaceModels()
	local spaceList = self.controler.spaceList
	local spaceCtn = self.mainMap:getSpaceLayer()

	local spaceArr = self.spaceArr
	local spaceNameArr = self.controler.spaceNameArr

	for k,v in pairs(spaceList) do
		spaceNameArr[#spaceNameArr+1] = k
		local curSpaceModel = self:createOneSpace(spaceCtn,k,v)
		if curSpaceModel then
			spaceArr[#spaceArr+1] = curSpaceModel
		end
	end

	-- if LoginControler:isLogin() then
	-- 	self.controler:updateDelegateTaskStatus()
	-- end
end

-- 创建一个地标
function WorldMapCreator:createOneSpace(ctn,spaceName,spaceInfo)
	local curSpaceModel = WorldSpaceModelClazz.new(self.controler,ctn,spaceName,spaceInfo)
	return curSpaceModel
end

-- 需要删除的方法
-- 创建一个地标
function WorldMapCreator:createOneSpace_old(ctn,spaceName,spaceInfo)
	-- 导出的地标sprite原点是中心
	local width = spaceInfo.width
	local height = spaceInfo.height
	local x = spaceInfo.x
	-- TODO 验证spine版地标位置
	-- spine原点是脚下中心
	local y = spaceInfo.y - 50 --height / 2
	
	local spaceSize = cc.size(width,height)

	if not self.controler.is3DMode then
		local spaceImg = FuncRes.iconWorldSpace(spaceName)
		local sprite = display.newSprite(spaceImg)
		local curSpaceModel = WorldSpaceModelClazz.new(self.controler)
		curSpaceModel:initView(spaceName,ctn,sprite,x,y,0,spaceSize)
		return curSpaceModel
	end

	local spaceData = FuncChapter.getSpaceDataByName(spaceName)
	if not spaceData then
		echoError("配置cuowu spaceName=",spaceName)
		return nil
	end

	local spineName = spaceData.spine
	local spine = ViewSpine.new(spineName)
	spine:playLabel("animation")
	local curSpaceModel = WorldSpaceModelClazz.new(self.controler)
	curSpaceModel:initView(spaceName,ctn,spine,x,y,0,spaceSize)
	return curSpaceModel
end

function WorldMapCreator:initMapMontainModels()
	local ctn = self.mainMap.mapMontainNode
	local mapMontainList = self.controler.mapMontainList

	for k,v in pairs(mapMontainList) do
		local name = k
		local cfgInfo = v
		local curModel = WorldMapMontainModelClazz.new(self.controler,ctn,name,cfgInfo)
		self.mapMontainArr[#self.mapMontainArr+1] = curModel
	end
end

-- TODO 需要删除的方法
-- 创建地图山体
function WorldMapCreator:initMapMontain_old()
	local ctn = self.mainMap.mapMontainNode
	local mapMontainList = self.controler.mapMontainList

	local DEBUG = false
	local callBack = function(sprite,info)
		local contentSize = sprite:getContentSize()
		local height = contentSize.height
		local width = contentSize.width

		local posx = 0
		local posy = 0

		if DEBUG then
			posx = info.x - width / 2
			posy = info.y + height / 2
			sprite:anchor(0,1)
		else
			posx = info.x
			posy = info.y - height / 2
			sprite:anchor(0.5,0)
		end
		
		sprite:pos(posx,posy)
		ctn:addChild(sprite)

		self.controler:setViewRotation3DBack(sprite)
		sprite:setScale(self.montainScale)

		self.mapMontainArr[#self.mapMontainArr+1] = sprite
	end

	for k,v in pairs(mapMontainList) do
		local iconPath = FuncRes.iconWorldMontain(k)
		display.newSpriteAsync(iconPath,callBack,v)
	end
end

-- 创建神界
function WorldMapCreator:initGodWorld()
	self:initGodMap()
	self:initGodMontain()
	self:initGodSpace()
end

-- 初始化神界地图
function WorldMapCreator:initGodMap()
	local ctn = self.mainMap.godMapNode
	local godMap = self.controler.godMap

	local callBack = function(sprite,info)
		local posx = info.x
		local posy = info.y
		sprite:pos(posx,posy)
		ctn:addChild(sprite)

		self.controler:setViewRotation3DBack(sprite)
	end

	for k,v in pairs(godMap) do
		local iconPath = FuncRes.iconGodMap()
		display.newSpriteAsync(iconPath,callBack,v)
	end
end

-- 初始化天界地标
function WorldMapCreator:initGodSpace()
	local spaceCtn = self.mainMap.godSpaceNode
	local spaceList = self.controler.godSpace

	for k,v in pairs(spaceList) do
		local curSpaceModel = self:createOneSpace(spaceCtn,k,v)
	end
end

-- 创建神界山体
function WorldMapCreator:initGodMontain()
	local ctn = self.mainMap.godMontainNode
	local montainList = self.controler.godMontainList

	local callBack = function(sprite,info)
		local posx = info.x
		local posy = info.y
		sprite:pos(posx,posy)
		ctn:addChild(sprite)

		self.controler:setViewRotation3DBack(sprite)
		sprite:setScale(self.montainScale)
	end

	for k,v in pairs(montainList) do
		local iconPath = FuncRes.iconGodMontain(k)
		display.newSpriteAsync(iconPath,callBack,v)
	end
end

-- 初始化主角和任务的tip
function WorldMapCreator:initTips()
	local uiCtn = self.mainMap:getUILayer()

	-- char task
	-- local charTip = display.newNode()

	-- local pos = cc.p(50,-400)
	-- local charHead = display.newSprite(FuncRes.iconHead("head_" .. (UserModel:sex() or "1")))
	-- -- local charHead = display.newSprite(FuncRes.iconHead("head_1"))
	-- charHead:anchor(0.5,0.5)
	-- charHead:pos(0,-1)
	-- charHead:setScale(0.85)

	-- local charTipKuang = display.newSprite(FuncRes.iconPVE("world_btn_juesekuang"))
	-- charTipKuang:anchor(0.5,0.5)
	-- charTipKuang:setScale(1.5)

	-- charTip:addChild(charTipKuang,0,100)
	-- charTip.tipSize = charTipKuang:getContentSize()
	-- charTip.tipViewBg = charTipKuang


	-- charHead:setName("head")
	-- charTip:addChild(charHead)
	
	-- charTip:pos(pos.x,pos.y)
	-- uiCtn:addChild(charTip)

	-- task tip
	pos = cc.p(-GameVars.UIOffsetX + GameVars.toolBarWidth + 65, -350 + GameVars.UIOffsetY)
	local taskTip = display.newNode()
	-- local taskIcon = display.newSprite(FuncRes.iconPVE("world_img_tanhao"))
	-- 任务框
	local taskKuang = display.newSprite(FuncRes.iconPVE("world_btn_juesekuang"))
	taskKuang:anchor(0.5,0.5)
	taskTip:addChild(taskKuang,0,100)
	-- taskKuang:setScaleX(-1)
	-- taskTip:setScale(1.2)
	taskTip.tipSize = taskKuang:getContentSize()
	taskTip.tipViewBg = taskKuang
	--[[
	local taskIconAnim = self.mapUI:createUIArmature("UI_shijieditu","UI_shijieditu_tanhao",taskTip, true, GameVars.emptyFunc)
	taskIconAnim:anchor(0.5,0)
	taskIconAnim:setScale(0.75)
	taskIconAnim:pos(3,-19)

	local taskIconAnimCallBack = function()
    	taskIconAnim:playWithIndex(2,true,false)
	end
	taskIconAnim:registerFrameEventCallFunc(15,1,c_func(taskIconAnimCallBack))
	]]

	taskTip:pos(pos.x,pos.y)
	uiCtn:addChild(taskTip)

	local curRaidId = WorldModel:getNextMainRaidId()
	local desStr = ""

	local raidData = FuncChapter.getRaidDataByRaidId(curRaidId)
	local chat = raidData.chat
	local isHideText = false
	if WorldModel:isRaidLock(curRaidId) then
		if chat and chat[2] then			
			local openLevel = raidData.condition[2].v 
			desStr = FuncTranslate._getLanguageWithSwap(chat[2], openLevel)
		end		
	else
		isHideText = true
		if not taskTip.anim then
			local tipsAnim = self.mapUI:createUIArmature("UI_liujie", "UI_liujie_touxiangtishi_zong_copy", taskTip, true, GameVars.emptyFunc)
			tipsAnim:setName("tipsAnim")
			tipsAnim:setScale(0.80)
			tipsAnim:pos(-8.5, 5.2)
			tipsAnim:zorder(2)
			taskTip.tipsAnim = tipsAnim
		end
	end

		
	local text = desStr
	local textDi = display.newSprite(FuncRes.iconPVE("world_img_tipsbg"))

	textDi:anchor(0.5, 0.5)
	taskTip:addChild(textDi, 10, 101)
	textDi:pos(-3, -77)
	taskTip.textDi = textDi
	local textLabel = TTFLabelExpand.new({co = {text = text, fontSize = 20, color = 0xf8f4eb, align = "center", valign = "center" }, w = 100, h = 60})
	textLabel:addto(textDi):pos(8, 66)
	taskTip.textLabel = textLabel
	-- local textLabel1 = TTFLabelExpand.new({co = {text = "新剧情", fontSize = 24, color = 0xf8f4eb, align = "center", valign = "center" }, w = 100, h = 30})
	-- textLabel1:addto(textDi):pos(8, 40)
	-- taskTip.textLabel1 = textLabel1


	if isHideText then
		taskTip.textDi:setVisible(false)
	else
		taskTip.textDi:setVisible(true)
	end

	local tipObj = {}
	tipObj.onClickTipBegin = function(tipObj,tipType)
		if tipType == 1 then
			-- FilterTools.setFlashColor(charTip,"spaceHighLight")
		else
			FilterTools.setFlashColor(taskTip,"spaceHighLight")
		end
	end

	tipObj.onClickTipGlobalEnd = function (  )
		-- FilterTools.clearFilter(charTip)
		FilterTools.clearFilter(taskTip)
	end

	tipObj.onClickTipEnd = function(tipObj,tipType)
		-- FilterTools.clearFilter(charTip)
		FilterTools.clearFilter(taskTip)

		-- echo("tipType=====",tipType)
		if tipType == 1 then
			-- self:doLockChar()
			self.controler:setCharInCenter()
		else
			-- 点击npc指引时主角移动过去自动触发npc对话 2018.01.19 by ZhangYanguang 
			self.controler:doAutoClickNpc()
		end
	end

	-- charTip:setVisible(false)
	taskTip:setVisible(false)

	-- charTip:setTouchedFunc(c_func(tipObj.onClickTipEnd,tipObj,1),nil, true,c_func(tipObj.onClickTipGlobalEnd,tipObj,1))
	taskTip:setTouchedFunc(c_func(tipObj.onClickTipEnd,tipObj,2),nil, true,c_func(tipObj.onClickTipGlobalEnd,tipObj,2))

	-- self.controler.charTip = charTip
	self.controler.taskTip = taskTip
end

-- ======================================================第三方玩家======================================================
function WorldMapCreator:createPlayers()
	if self.isShowOtherPlayer then
		EventControler:dispatchEvent(WorldEvent.GET_ONLINE_PLAYER);
	end
end

-- 初始化第三方玩家
function WorldMapCreator:initPlayers(event)
	local onlinesPlayers = event.params.onLines;
	self.onlinesPlayers = onlinesPlayers

    -- dump(onlinesPlayers, "--initPlayers--");
    local onlinesPlayerNum = table.length(onlinesPlayers);

    local fakePlayerNum = self.maxPlayerNum + 10
    local fakePlayerList = WorldModel:getFakePlayerList(fakePlayerNum)

    -- 需要补充的机器人数量
    local filledPlayerNum = self.maxPlayerNum - onlinesPlayerNum

    local showPlayerDataList = table.copy(onlinesPlayers)
    for i=1,filledPlayerNum do
    	showPlayerDataList[tostring(i)] = fakePlayerList[tostring(i)]
    end

    -- 备用机器人数量
    for i=filledPlayerNum+1,fakePlayerNum do
    	self.idlePlayerArr[#self.idlePlayerArr+1] = fakePlayerList[tostring(i)]
    end

    local count = 1
    for k,v in pairs(showPlayerDataList) do
        self.mainMap:delayCall(c_func(self.birthOnePlayer, self, k, v), 
            (count * 2 - 1) / GameVars.GAMEFRAMERATE);

        if count > self.maxPlayerNum then 
            break;
        end

        count = count + 1 
    end
end

function WorldMapCreator:refreshPlayers(data)
	if not self.isShowOtherPlayer then
		return
	end

	if not self.controler.mapUI:checkIsVisible() then
		return
	end

	local onlinesPlayers = data.params.onLines;
	-- dump(onlinesPlayers)
	-- 下线了的真实玩家
	for playerId, v in pairs(self.onlinesPlayers) do
		-- 已经下线
        if onlinesPlayers[playerId] == nil and not v.isRobot then 
        	-- 如果还活着
        	if self:isPlayerAlive(playerId) then
        		self.willDiePlayerArr[#self.willDiePlayerArr+1] = playerModel
        	end
        end 
    end

    local count = 0
    --新加入的真实玩家
    for playerId, v in pairs(onlinesPlayers) do
        if self.onlinesPlayers[playerId] == nil then
        	if table.length(self.showPlayerDataList) < self.maxPlayerNum then
        	-- if true then
        		-- 创建一个玩家
        		-- echo("### 新建玩家",v.name)
        		self.showPlayerDataList[playerId] = v
        		self:birthOnePlayer(playerId, v)
        	else
        		-- 将玩家加入到备用池中
        		self.idlePlayerArr[#self.idlePlayerArr+1] = v
           	end
           	count = count + 1
        end
    end

    -- echo("新加入玩家=====",count)
    self.onlinesPlayers = onlinesPlayers
end

-- 执行玩家死亡逻辑
function WorldMapCreator:onPlayerDie(player)
	self.diedPlayerArr[#self.diedPlayerArr+1] = player

	local playerId = player:getPlayerId()

	-- 从当前展示列表中删除
	local diePlayerInfo = self.showPlayerDataList[playerId]
	table.removebyvalue(self.showPlayerDataList, diePlayerInfo)

	-- 机器人或在线的玩家
	if player:isRobot() or (not player:isRobot() and self:isPlayerOnLine(playerId)) then
		-- 加入到空闲数组中
		self.idlePlayerArr[#self.idlePlayerArr+1] = diePlayerInfo
	end

	-- 延迟随机生成一个新玩家
	self.mainMap:delayCall(c_func(self.randomBirthPlayer,self), 0.1)
end

-- 一个玩家进入地标
-- 播放动画等逻辑操作
function WorldMapCreator:onPlayerEnterSpace(playerModel)
	-- playerModel:deleteMe()
	if playerModel == self.lockPlayerModel and self.lockPlayerModel:isLock() then
		local callBack = function()
			local targetSpace = self:getPlayerTargetSpace(playerModel:getTargetSpace())
			self:movePlayer(playerModel,targetSpace)
		end
		self.mainMap:delayCall(c_func(callBack), 2)
	else
		local callBack = function()
			self.willDiePlayerArr[#self.willDiePlayerArr+1] = playerModel
		end

		self:playPlayerEnterSpaceAnim(playerModel,c_func(callBack))
	end
end

function WorldMapCreator:birthOnePlayer(playerId,playerInfo)
	local avatarId = tostring(playerInfo.avatar or 101);

    if tostring(avatarId) == tostring(102) then 
        avatarId = tostring(104);
    end 

    local playerCtn = self.mainMap:getPlayerLayer()
	local playerModel = WorldPlayerModelClazz.new(self.controler)

    local garmentId = playerInfo.garmentId or GarmentModel.DefaultGarmentId;
    if garmentId == "" then 
        garmentId = GarmentModel.DefaultGarmentId;
    end

    local playerName = playerInfo.name or "少侠"
    -- 玩家名字
    local cloneTitleUI = UIBaseDef:cloneOneView(self.mapUI.UI_name_title);
    -- cloneTitleUI.txt_name:setString(playerName);

    -- local playerSpine = GarmentModel:getSpineViewByAvatarAndGarmentId(avatarId, garmentId)
    -- playerSpine:playLabel("stand");
    local charSex = FuncChar.getCharSex(avatarId)
    local playerSpine = self:getCharSpine(charSex,garmentId)
    playerSpine:opacity(200)

    local playerSize = cc.size(260,180)
    local pos = self:getPlayerBirthPos()
    -- pos = self.charModel.pos

    cloneTitleUI:update(playerInfo)


    playerModel:initView(playerCtn,playerSpine,pos.x,pos.y,0,playerSize)
    playerModel:setViewScale(self.playerScale)
    playerModel:setNameView(cloneTitleUI)

    -- playerModel:setName(playerName)

    -- 设置目标位置
    local targetSpace = self:getPlayerTargetSpace()
    
    playerModel:setTargetSpace(targetSpace)
    playerModel:setIsRobot(playerInfo.isRobot or false)
    playerModel:setPlayerId(playerId)
    self.controler:movePlayer(playerModel,targetSpace)

    self.playerArr[#self.playerArr+1] = playerModel
    -- self.count = self.count + 1
    -- echo("\n新建玩家 name=",playerInfo.name)
    self.showPlayerDataList[playerId] = playerInfo
end

-- 获取玩家出生地
function WorldMapCreator:getPlayerBirthPos()
	local randomX = math.random(1, 100);
	local randomY = math.random(1, 100);

	local x = self.playerMinX + (self.playerMaxX - self.playerMinX) * randomX / 100
	local y = self.playerMinY + (self.playerMaxY - self.playerMinY) * randomY / 100
	-- echo("x,y===",x,y,self.playerMinY)
	return cc.p(x,y)
end

function WorldMapCreator:getPlayerModel(playerId)
	for k,v in pairs(self.controler.playerArr) do
		if tolua.type(v) == "WorldPlayerModel" and v:getPlayerId() == playerId then
			return v
		end
	end
end

function WorldMapCreator:isPlayerAlive(playerId)
	local playerModel = self:getPlayerModel(playerId)
	return playerModel ~= nil
end

function WorldMapCreator:isPlayerOnLine(playerId)
	local playerInfo = self.onlinesPlayers[playerId]
	return playerInfo ~= nil
end

function WorldMapCreator:randomBirthPlayer()
	local playerInfo = nil
	while true do
		local random = math.random(1, #self.idlePlayerArr);
		-- local random = 1
		playerInfo = self.idlePlayerArr[random]
		-- if not playerInfo or (playerInfo and playerInfo.name and self:checkPlayerName(playerInfo.name)) then
		-- if true then
		if not playerInfo or (playerInfo and playerInfo.name) then
			break
		end
	end

	if playerInfo then
		local playerId = playerInfo._id
		self:birthOnePlayer(playerId,playerInfo)
	else
		echoError ("playerInfo is nil..........")
	end
end

-- 获取玩家数据
function WorldMapCreator:getPlayerInfo(playerId)
	local playerInfo = self.showPlayerDataList[playerId]
	return playerInfo
end

function WorldMapCreator:checkPlayerName(name)
	for k,v in pairs(self.controler.playerArr) do
		if v.getName then
			if name == v:getName() then
				return false
			end
		end
	end

	return true
end

function WorldMapCreator:checkRefreshPlayers()
	if self.totalFrame == nil then
		self.totalFrame = 0
	end

	self.totalFrame = self.totalFrame + 1

	if self.mainMap:isVisible() then
		local isFrameReach = self.totalFrame % GameStatic._local_data.onLineUserHeart == 0;
		if isFrameReach then
			EventControler:dispatchEvent(WorldEvent.GET_ONLINE_PLAYER_AGAIN,
	            {rids = self:getOnlinePlayerRids()});
		end
	end
end

function WorldMapCreator:getOnlinePlayerRids()
    local rids = {};
    if not self.onlinesPlayers then
    	return rids;
    end

    for k, v in pairs(self.onlinesPlayers) do
        -- --只算真人
        -- if v.isRobot then 
        --     table.insert(rids, k);
        -- end
        table.insert(rids, k);
    end

    return rids;
end

-- 随机获取与excludeSpaceName不相同的地标名称
function WorldMapCreator:getPlayerTargetSpace(excludeSpaceName)
	local spaceNameArr = self.controler.spaceNameArr

	local random = math.random(1, #spaceNameArr);
	local spaceName = spaceNameArr[random]
	if not excludeSpaceName or spaceName ~= excludeSpaceName then
		return spaceName
	else
		while true do
			random = math.random(1, #spaceNameArr);
			spaceName = spaceNameArr[random]
			if spaceName ~= excludeSpaceName then
				return spaceName
			end
		end
	end
end
-- ======================================================播放动画方法======================================================
-- 播放云动画
function WorldMapCreator:playCloudAnim()
	-- if not self.cloudAnim then
	-- 	local uiCtn = self.mainMap:getUILayer()
	-- 	self.cloudAnim = self.mapUI:createUIArmature("UI_shijieditu","UI_shijieditu_yun",uiCtn, false, GameVars.emptyFunc)
	--     self.cloudAnim:pos(0,0)
	--     FuncCommUI.setViewAlign(self.widthScreenOffset,self.cloudAnim,UIAlignTypes.MiddleBottom)
	-- end
	-- self.cloudAnim:startPlay()
end

-- 播放玩家死亡动画
function WorldMapCreator:playPlayerDieAnim(player)
	local callBack = function()
		self:onPlayerDie(player)
	end

	self.mainMap:delayCall(c_func(callBack), 0.2)
end

-- 播放主角进入地标动画
function WorldMapCreator:playPlayerEnterSpaceAnim(playerModel,callBack)
	local actCallBack = nil
	if callBack then
		actCallBack = act.callfunc(callBack)
	end

	local action = cc.Spawn:create(
		act.scaleto(0.8,0.2,0.2),
		act.fadeout(0.8)
	)

	local act = cc.Sequence:create(
		action,
		actCallBack,
		nil)
	local playerView = playerModel:getPlayerView()
	playerView:stopAllActions()
	playerView:runAction(act)
end

-- 播放主角离开地标动画
function WorldMapCreator:playPlayerExitSpaceAnim(playerModel,callBack)
	local actCallBack = nil
	if callBack then
		actCallBack = act.callfunc(callBack)
	end

	local action = cc.Spawn:create(
		act.scaleto(0.8,1.0,1.0),
		act.fadein(0.8)
	)

	local act = cc.Sequence:create(
		action,
		actCallBack,
		nil)

	local playerView = playerModel:getPlayerView()
	playerView:stopAllActions()
	playerView:runAction(act)
end

function WorldMapCreator:deleteMe()
	self.controler = nil
	EventControler:clearOneObjEvent(self)
	-- 将要死亡的玩家
	for i=1,#self.willDiePlayerArr do
		local player = self.willDiePlayerArr[i]
		if player and player.deleteMe then
			player:deleteMe()
		end
	end
	self.willDiePlayerArr = {}

	-- 已经死亡的玩家
	for i=1,#self.diedPlayerArr do
		local player = self.diedPlayerArr[i]
		if player and player.deleteMe then
			player:deleteMe()
		end
	end

	self.diedPlayerArr = {}
end

return WorldMapCreator
