local ServerLoading = class("ServerLoading", UIBase)

--[[
    self.UI_loading,
]]

function ServerLoading:ctor(winName)
    ServerLoading.super.ctor(self, winName)
end

function ServerLoading:loadUIComplete()
	self:registerEvent()
	--self.txt_load:visible(false)

    local loadingAniName = FuncCommon.getLoadingAniName()
    local loadingAni1 = self:createUIArmature("UI_zhuanjuhua", loadingAniName, self.ctn_loading, true, GameVars.emptyFunc)
    local loadingAni2 = self:createUIArmature("UI_startLoading", "UI_startLoading", self.ctn_loading, true, GameVars.emptyFunc)
    loadingAni2:setPositionY(loadingAni2:getPositionY()-18)
    loadingAni1:visible(false)
    loadingAni2:visible(false)

    self.ctn_loading:pos(GameVars.gameResWidth/2 ,-GameVars.gameResHeight/2-50 )

    self.anim1 = loadingAni1
    self.anim2 = loadingAni2

--	local anim = self:createUIArmature("UI_common", "UI_common_loading", self.ctn_loading, true, GameVars.emptyFunc)
--	anim:visible(false)
--	self.anim = anim
end 

function ServerLoading:registerEvent()

end

function ServerLoading:startShow()
	self:hideLoadingAnim()
	self:stopAllActions()
	local func = function()
        self.anim1:visible(true)
        self.anim2:visible(true)
--		self.anim:visible(true)
	end
	self:delayCall(func, 20/GameVars.GAMEFRAMERATE )
end

function ServerLoading:hideLoadingAnim()
	self:stopAllActions()
	if self.anim1 then
        self.anim1:visible(false)
        self.anim2:visible(false)
--		self.anim:visible(false)
	end
end

function ServerLoading:updateUI()
	
end

return ServerLoading
