--guan 
--2016.4.27

local NpcContentWidget = class("NpcContentWidget", UIBase);

local RES_TRANS = {
	["c_1"] = {res = "UI_yindaoyuan", ani = "yindaoyuan_hankui"}, -- 蓝葵
	["c_2"] = {res = "UI_yindaoyuan", ani = "yindaoyuan_hongkui"}, -- 红葵
	["c_3"] = {res = "UI_yindaoyuan1", ani = "yindaoyuan_lixiaoyao"}, -- 红葵

	["c_99"] = {res = "UI_yindaoyuan", ani = "texiao"}, -- 转场
}

-- 引导员方向的枚举
local NPC_WAY = {
	LEFT = 1,
	RIGHT = 2,
}

local defaultIconSize = {
	width = 42,
	height = 42,
}

function NpcContentWidget:ctor(winName)
    NpcContentWidget.super.ctor(self, winName);

    self._npc = {} -- 后来有两帧了只能强行改成表
    self._npcView = {}
    self._ctn_npc = {}
    self._myRichText = {}

    self._curFrame = nil--NPC_WAY.LEFT -- 默认左侧
end

function NpcContentWidget:loadUIComplete()
	self:registerEvent()
	
	-- 切一次
	self.mc_1:showFrame(2)
	self._myRichText[NPC_WAY.RIGHT] = self.mc_1.currentView.panel_npcAndWord.panel_word.rich_1
	self._ctn_npc[NPC_WAY.RIGHT] = self.mc_1.currentView.panel_npcAndWord.ctn_npc

	-- 切一次
	self.mc_1:showFrame(1)
	self._myRichText[NPC_WAY.LEFT] = self.mc_1.currentView.panel_npcAndWord.panel_word.rich_1
	self._ctn_npc[NPC_WAY.LEFT] = self.mc_1.currentView.panel_npcAndWord.ctn_npc

	self:setWay(NPC_WAY.LEFT)
	-- self.panel_npcAndWord.panel_word.rich_1
	-- self._myRichText[NPC_WAY.RIGHT]
end 

function NpcContentWidget:registerEvent()
	NpcContentWidget.super.registerEvent()

	-- self:registClickClose("out")
end

-- 浮动动画
function NpcContentWidget:createArrowAni(view)
	if view.__moving then return end
	view.__pos = cc.p(view:getPosition())
	view.__moving = true
	local arr = {
		cc.EaseOut:create(cc.MoveBy:create(0.5, cc.p(0,10)),4),
		cc.EaseIn:create(cc.MoveBy:create(0.5, cc.p(0,-10)),4),
		-- cc.MoveBy:create(0.5, cc.p(0,10)),
		-- cc.MoveBy:create(0.5, cc.p(0,-10))
	}
	local rep = cc.RepeatForever:create(cc.Sequence:create(arr))
	view:runAction(rep)
end

-- 切人脸方向
function NpcContentWidget:setWay(way)
	if self._curFrame ~= way then
		self._curFrame = way
		self.mc_1:showFrame(self._curFrame)
		self:createArrowAni(self.mc_1.currentView.panel_npcAndWord.panel_jian)
	end
end

function NpcContentWidget:setContent( str )
	local str = self:_transTxt(str)
	self._myRichText[self._curFrame]:setIconSize(defaultIconSize)
	self._myRichText[self._curFrame]:setString(str)
end

-- 将文本中的#1替换为主角名
function NpcContentWidget:_transTxt(str)
	local tutorialManager = TutorialManager.getInstance()
	return tutorialManager:transTextContent(str)
end

function NpcContentWidget:playContent(str, callBack)
	local str = self:_transTxt(str)
	local speed = 20 -- 文字速度
	local preSpeed = 5 -- 提前跳过的文字
	
	self._myRichText[self._curFrame]:setIconSize(defaultIconSize)

	self._myRichText[self._curFrame]:startPrinter(str,speed)

	if callBack then
		self._myRichText[self._curFrame]:registerCompleteFunc(callBack)
	end
	
	-- 提前跳5个字
	self._myRichText[self._curFrame]:skipPrinter()
	-- self._myRichText[self._curFrame]:skipPrinter(preSpeed)
end
--[[
	npc 1蓝葵 2红葵 3 李逍遥
]]
function NpcContentWidget:setNPC(npcInfo)
	local npc = npcInfo.npc
	if npcInfo.way and (npcInfo.way == NPC_WAY.LEFT or npcInfo.way == NPC_WAY.RIGHT)then
		self:setWay(npcInfo.way)
	end

	if not self._npc[self._curFrame] then
		self._npc[self._curFrame] = npc
		self._npcView[self._curFrame] = self:getNPCView(self._npc[self._curFrame], npcInfo)
	else
		if self._npc[self._curFrame] ~= npc then -- 不同，发生了变化
			if not (RES_TRANS[self._npc[self._curFrame]] and RES_TRANS[npc] and RES_TRANS[self._npc[self._curFrame]].res == RES_TRANS[npc].res) then -- 资源变了
				self._npcView[self._curFrame]:deleteMe()
				self._npcView[self._curFrame] = self:getNPCView(npc, npcInfo)
			end

			if self._npc[self._curFrame] == "c_1" and npc == "c_2" then -- 从1变为2要转场
				self._npc[self._curFrame] = npc
				self._npcView[self._curFrame]:playLabel(RES_TRANS["c_99"].ani)
				local totalFrame = self._npcView[self._curFrame]:getTotalFrames() - 2
				local tempFunc = function()
					self._npcView[self._curFrame]:playLabel(RES_TRANS[self._npc[self._curFrame]].ani, true)
				end
				self:delayCall(tempFunc, totalFrame/GameVars.GAMEFRAMERATE)
			else
				self._npc[self._curFrame] = npc
				if RES_TRANS[self._npc[self._curFrame]] then
					self._npcView[self._curFrame]:playLabel(RES_TRANS[self._npc[self._curFrame]].ani, true)
				end
			end
		end
	end
end

-- 获取npcView
function NpcContentWidget:getNPCView(npc,npcInfo)
	local npcView = nil
	if string.find(npc, "c_") then
		npcView = ViewSpine.new(RES_TRANS[npc].res):addTo(self._ctn_npc[self._curFrame])
		npcView:playLabel(RES_TRANS[npc].ani, true)
	else
		npcView = self:loadImgRes(npc):addTo(self._ctn_npc[self._curFrame])
		-- self:cutNpc(self:loadImgRes(self._npc)):addTo(self.panel_npcAndWord.ctn_npc)
	end

	local scaleX = self._curFrame == NPC_WAY.RIGHT and -npcInfo.scale or npcInfo.scale
	local scaleY = npcInfo.scale
	npcView:setScale(scaleX, scaleY)
	npcView:pos(npcInfo.x, npcInfo.y)

	return npcView
end

--[[
	resName sourceId viewInfo npc 大小位置信息
	viewInfo = {
		scale = scale,
		x = x,
		y = y,
	}
]]
function NpcContentWidget:loadImgRes(resName, viewInfo)
	if resName == nil then 
	    echoError("loadImgRes image name is null 暂时用主角代替")
	    local avatar = UserModel:avatar();
	    local garmentId = GarmentModel:getOnGarmentId()

	    resName = FuncGarment.getGarmentSpinName(garmentId,avatar)
	end

	 --加载Spine动画
   	if(resName == "player")then
		local   avatar=UserModel:avatar();
		local garmentId = GarmentModel:getOnGarmentId()
		resName = FuncGarment.getGarmentSource(garmentId, avatar)
   	end

   	local artSpine= FuncRes.getSpineViewBySourceId(resName,nil,true )

   	if not artSpine then
   		echoError(resName, "没有获取到spine对象")
   	end

   	return artSpine
end

function NpcContentWidget:cutNpc(artSpine)
	local nodeWight = 1000 -- 给一个大宽度，保证左右不切
    local nodeHeight = 700 -- 给一个大高度，保证顶端不切
	local clipNode = cc.ClippingNode:create()

	local cOffsetX = nodeWight/2 -- 固定偏移

	-- artSpine:scale(1.5)
	-- artSpine:pos(cOffsetX, 0)

	local stencil = cc.LayerColor:create(cc.c4b(0, 0, 0, 0), nodeWight, nodeHeight)
	clipNode:setStencil(stencil)
	clipNode:addChild(artSpine)

	clipNode:setInverted(false)

	-- clipNode:setAnchorPoint(cc.p(0.5, 0))
	clipNode:pos(-cOffsetX, 0)

	return clipNode
end


return NpcContentWidget;
