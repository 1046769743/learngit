local RaidLoadingView = class("RaidLoadingView", UIBase)

local DEFAULT_BG = "bg_denglu.png"

local BG_IMAGES = {
	[2]="bg_denglu.png",
	[3]="bg_denglu.png",
	[4]="bg_denglu.png",
	[5]="bg_denglu.png",
}

function RaidLoadingView:ctor(winName, raidId)
	RaidLoadingView.super.ctor(self, winName)
	--当前的关卡ID
	self.raidId = raidId
end

function RaidLoadingView:setViewAlign()
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_loading, UIAlignTypes.MiddleBottom)
	-- --FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_content, UIAlignTypes.MiddleBottom)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.txt_tip1, UIAlignTypes.MiddleBottom)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.txt_random_tips, UIAlignTypes.MiddleBottom)
end

function RaidLoadingView:loadUIComplete()
	self:setViewAlign()

	-- 六界进剧情 停止音乐播放
	AudioModel:stopMusic(  )

	self:loadRaidAni()
end


--[[
加载关卡动画
]]
function RaidLoadingView:loadRaidAni()
	self.ctn_juanzhou:removeAllChildren()

	local zhangName = WorldModel:getStoryRoundDes(self.raidId)
	if tonumber(zhangName) > 0 then
		zhangName = WorldModel:getChapterNum(zhangName)
		zhangName = GameConfig.getLanguageWithSwap("tid_story_10104",zhangName)
	else
		zhangName = GameConfig.getLanguage("#tid_story_xuzhang_title_01")
	end

	
	local title = WorldModel:getRaidRoundDes( self.raidId )
	-- local titleView = UIBaseDef:createPublicComponent( "UI_world_new_jump","txt_raidTitle" ):pos(0,0)
	-- titleView:setString(zhangName.."  "..title)
	-- local box = titleView:getContainerBox()
	-- titleView:pos(-box.width/2,box.height)

	local titleDes = WorldModel:getRaidName(self.raidId)	
	-- local titleDesView = UIBaseDef:createPublicComponent( "UI_world_new_jump","txt_raidTitle" ):pos(0,0)
	-- titleDesView:setString(titleDes)
	-- box = titleDesView:getContainerBox()
	-- titleDesView:pos(-box.width/2,-box.height/2)
	
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_juanzhou,UIAlignTypes.Middle)
	
	-- self.panel_mulu.txt_1:setString(titleDes)
	-- self.panel_mulu.txt_2:setString(zhangName.." "..title)

	FuncCommUI.setVerTicalTXT({
		str = titleDes,
		txt = self.panel_mulu.txt_1,
	})

	FuncCommUI.setVerTicalTXT({
		str = zhangName.." "..title,
		txt = self.panel_mulu.txt_2,
	})
	
	-- 创建特效
	self._loadComplete = false
	-- 门
	self._effmen = self:createUIArmature("UI_juqing", "UI_juqing_zong", self.ctn_juanzhou, false,function ()
		self:animComplete()
	end)
	--替换
	FuncArmature.changeBoneDisplay(self._effmen, "node1", self.panel_mulu)  
	self.panel_mulu:pos(0,0)
	-- 播完加载暂停
	self._effmen:registerFrameEventCallFunc(27, 1, function( )
        if not self._loadComplete then
		    self._effmen:pause()
		end
    end)
	-- 叶子
	self:createUIArmature("UI_juqing", "UI_juqing_shuye", self.ctn_juanzhou, true)

	self._effmen:gotoAndPlay(1)
	-- self.ctn_juanzhou:add(titleView)
	-- self.ctn_juanzhou:add(titleDesView)
end

function RaidLoadingView:animComplete()
	self:startHide()
	BattleControler:loadAniComplete()
end

function RaidLoadingView:loadComplete()
	self._loadComplete = true
	self._effmen:play()
end

function RaidLoadingView:initBg(bgImage)
	local bgImagePath = FuncRes.iconBg(bgImage)
	local bgImageSprite = display.newSprite(bgImagePath)
	self._bgImage = bgImage
	FuncCommUI.setBgScaleAlign( bgImageSprite )
	--bgImageSprite:setScaleX(scalex)
	--bgImageSprite:setScaleY(scaley)

	self.ctn_bg:addChild(bgImageSprite)
end

function RaidLoadingView:registerEvent()

end

function RaidLoadingView:finishLoading(frame,actionCFunc)
	self:delayCall(actionFuncs, frame/GameVars.GAMEFRAMERATE )
end


function RaidLoadingView:close()
	self:startHide()
end

--[[
在界面完成加载后执行
]]
function RaidLoadingView:deleteMe(  )
	RaidLoadingView.super.deleteMe(self)
end

return RaidLoadingView
