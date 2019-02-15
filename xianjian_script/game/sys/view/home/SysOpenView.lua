--[[
  	Author: lichaoye
	Date: 2017-06-07
	新功能开启界面-view
  
  这界面后面被改的太烂了不忍心看……lcy  ---然后就交给我了...wk --然后又让我换特效了……修改了迷之缩进lcy
]]

local SysOpenView = class("SysOpenView", UIBase)
local BASESIZE = cc.size(293, 293)

function SysOpenView:ctor( winName, params)
	SysOpenView.super.ctor(self, winName)
	params = params or {}
	self._sysName = params.sysname
	self._callBack = params.callBack
	self._btnCallBack = params.btnCallBack
	self._worldPos = params.worldPos
	self._flySwitch = params.flySwitch
end

function SysOpenView:registerEvent()
	SysOpenView.super.registerEvent()
end

function SysOpenView:loadUIComplete()
	self:registerEvent()
	self:setViewAlign()
	self:updateUI()
end

-- 适配
function SysOpenView:setViewAlign()
   FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_r.panel_goon, UIAlignTypes.MiddleBottom)
   -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_buyfive, UIAlignTypes.RightBottom)
   -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_res, UIAlignTypes.MiddleBottom)
end

function SysOpenView:updateUI()
	-- 记录信息
	local list = LS:prv():get(StorageCode.tutorial_sysopen_check)
	if not list then 
		list = {} 
	else
		list = json.decode(list)
	end
	-- 标记为已经播过功能开启
	list[self._sysName] = true
	LS:prv():set(StorageCode.tutorial_sysopen_check,json.encode(list))
	
	echo("这里创建了一个icon")
	local ctn = self.ctn_1
	ctn:removeAllChildren()
	local res = FuncRes.iconSysBig(self._sysName)

	local sp = display.newSprite(res):addTo(ctn):anchor(0.5, 0.5)
	local sz = sp:getContentSize()
	-- 设置为固定大小
	sp:setScale(BASESIZE.width / sz.width, BASESIZE.height / sz.height)

	local callBack = function ()
	  	echo("动画进来了")
	  	-- if self.lockAnione then
		  -- 	self.lockAnione:pause()
	  	-- end
	end

 	-- 加一个黑底
	local layer = display.newColorLayer(cc.c4b(0,0,0,205))
		-- :pos(- GameVars.UIOffsetX,GameVars.UIOffsetY)
		:anchor(0, 1)
		:pos(- GameVars.UIOffsetX, GameVars.UIOffsetY):addTo(self, -100)
	layer:setContentSize(cc.size(GameVars.fullWidth,GameVars.height))
	self.blackbg = layer

	self.lockAnione = self:createUIArmature("UI_gongnengkaiqi","UI_gongnengkaiqi_yj_xingongneng", self, false,function ()
	end)

	FuncArmature.changeBoneDisplay(self.lockAnione , "node1", sp);
	self.lockAnione:setPosition(585,-120)

	self.lockAnione:registerFrameEventCallFunc(34,false,callBack)

	-- 系统名
	local text = GameConfig.getLanguage(FuncCommon.getSysOpenxtname(self._sysName))
	self.panel_ptxt.txt_qy:setString(text)
	local posx,posy = self.panel_ptxt.txt_qy:getPosition()
	self.panel_ptxt.txt_qy:setPositionY(posy-5)
	-- self.panel_ptxt.txt_qy:setPosition(-35, 0)
	FuncArmature.changeBoneDisplay(self.lockAnione , "wenzi", self.panel_ptxt.txt_qy);
	-- 介绍
	local text = GameConfig.getLanguage(FuncCommon.getSysOpenContent(self._sysName))
	self.panel_r.txt_6:setString(text)
	self.panel_r.txt_6:setVisible(false)
	self.panel_r.panel_jieshao:visible(false)
	FuncArmature.changeBoneDisplay(self.lockAnione , "layer4", self.panel_r.panel_jieshao);
	self.panel_r.ctn_sss:setPosition(0,0)
	FuncArmature.changeBoneDisplay(self.lockAnione , "node", self.panel_r.ctn_sss);

	
	local clickClose = function()
		self:registClickClose(nil, function()
			self:playAnim(function()
				echo("这里执行了回调里的内容")
				if self._callBack then self._callBack() end
				self:startHide()
			end)
		end)
		-- self:registClickClose()
	end
	clickClose()
end

-- 播放动画效果
function SysOpenView:playAnim(callback)
	-- 屏蔽点击
	-- self.panel_r:visible(false)
	-- self.panel_ptxt.txt_qy:visible(false)
	if tonumber(self._flySwitch) == 1 then
		self:startHide()
		WindowControler:setUIClickable(true)
		if callback then callback() end
	else
		local ctn = self.panel_qu   
		-- echo("世界坐标",self._worldPos.x,self._worldPos.y)
		local toPos = ctn:getParent():convertToNodeSpaceAR(self._worldPos)
		
		local function tuoweiAnim()
			local flyAnimation = self:createUIArmature("UI_gongnengkaiqi","UI_gongnengkaiqi_yj_tuowei", self, false,function () end)
			local backFaction = function ()
				flyAnimation:pause()
				flyAnimation:visible(false)
				flyAnimation:removeFromParent(true)
			end

			flyAnimation:setPosition(toPos.x,toPos.y)
			flyAnimation:registerFrameEventCallFunc(26,false,backFaction)
			
			local ctnPosX,ctnPosY = ctn:getPosition()
			local subX = toPos.x-ctnPosX
			local subY = toPos.y-ctnPosY
			local lenthNum = math.pow(subX,2)+math.pow(subY,2)
			local rotanum  = math.atan2(subY,subX)
			if tonumber(rotanum* 180/math.pi) < 0 then
				flyAnimation:setRotation(-100-rotanum* 180/math.pi)
			else
				 flyAnimation:setRotation(rotanum* 180/math.pi+210)
			end 
			
			local scaleNum =  math.sqrt(lenthNum)/290
			flyAnimation:setScale(scaleNum)
		end

		local spcallBack = function ()
		   	-- self.aniLight:pause()
		   	-- self.aniLight:visible(false)
		   	-- self.aniLight:removeFromParent(true)
		   	local res = FuncRes.iconSysBig(self._sysName)
		   	local sp = display.newSprite(res):addTo(self):anchor(0.5, 0.5)
		   	local sz = sp:getContentSize()
		   	-- 设置为固定大小
		   	sp:setScale(BASESIZE.width / sz.width, BASESIZE.height / sz.height)

		   	sp:setPosition(ctn:getPositionX()+85,ctn:getPositionY()-85)
		   	echo("飞行坐标",toPos.x,toPos.y,self._worldPos.x,self._worldPos.y)
		   	local moveAction = cc.MoveTo:create(0.6, toPos)
		   	local array = {
		   		cc.ScaleTo:create(0.4,0.4 * BASESIZE.width / sz.width,  0.4 * BASESIZE.height / sz.height),
		   		cc.CallFunc:create(tuoweiAnim),
				cc.EaseIn:create(moveAction, 4),
				-- cc.ScaleTo:create(0.3,0.2 * BASESIZE.width / sz.width,  0.2 * BASESIZE.height / sz.height),
				-- cc.ScaleTo:create(0.3,0.1 * BASESIZE.width / sz.width,  0.1 * BASESIZE.height / sz.height),
				-- 到了之后闪特效且显示外部图标
				cc.CallFunc:create(function ()
					-- 闪一下第7帧换东西
					local blankAnimation = self:createUIArmature("UI_gongnengkaiqi","UI_gongnengkaiqi_yj_jichu", self, false,function ()
						-- 引导的缓存清掉，防止图标不出现
						TutorialManager:getInstance():clearOpenSys()
						self:startHide()
						WindowControler:setUIClickable(true)
						if callback then callback() end
					end)
					blankAnimation:registerFrameEventCallFunc(7,false,function()
						sp:setVisible(false)
						-- 显示图标
						if self._btnCallBack then
							self._btnCallBack()
						end
					end)
					blankAnimation:zorder(100)
					blankAnimation:setPosition(toPos.x,toPos.y)
				end),
			}
			sp:runAction(cc.Sequence:create(array))

			if self.blackbg then
				self.blackbg:runAction(cc.FadeOut:create(0.2))
			end
		end
		self.lockAnione:playWithIndex(1, false)
		self.lockAnione:registerFrameEventCallFunc(5,false,spcallBack)
		WindowControler:setUIClickable(false)
		self.panel_r:visible(false)
		-- 先隐藏其他的内容
		
		self.lockAnione:doByLastFrame(true,true,GameVars.emptyFunc)
	end
end

function SysOpenView:press_btn_close()
	self:startHide()
end

return SysOpenView