-- GuildUpgSucView
-- Author: Wk
-- Date: 2017-10-11
-- 仙盟升级成功界面
local GuildUpgSucView = class("GuildUpgSucView", UIBase);

function GuildUpgSucView:ctor(winName,data)
    GuildUpgSucView.super.ctor(self, winName);
    self.sucdata = data
end

function GuildUpgSucView:loadUIComplete()

	local size = self.panel_ps:getContainerBox()
	self.panel_ps:setScaleX(GameVars.width/size.width) 

	self:registClickClose(-1, c_func( function()
        self:press_btn_close()
    end , self))

	self:registerEvent()
    self:initData()


end 

function GuildUpgSucView:registerEvent()
	EventControler:addEventListener(GuildEvent.CLOSE_ALL_VIEW_UI, self.press_btn_close, self)
end

function GuildUpgSucView:initData()

	local dataTable = {
		guildid = self.sucdata.buildID,
		level = self.sucdata.level,
	}
	local alldata = FuncGuild.getguildBuildUpAllData()
	local ctn = self.ctn_1
	local levelone = self.txt_1
	local leveltow = self.txt_2
	local describe = self.rich_3
	local singdata = alldata[tostring(dataTable.guildid)][tostring(dataTable.level)]

	levelone:setString((dataTable.level -1)..GameConfig.getLanguage("#tid_guildAddCell_001"))  
	leveltow:setString(dataTable.level..GameConfig.getLanguage("#tid_guildAddCell_001"))
	describe:setString(GameConfig.getLanguage(singdata.lvUpDes))

	local build  = self.sucdata.buildID
	self.mc_build:showFrame(build)

    local lockAni = self:createUIArmature("UI_xianmeng", "UI_xianmeng_jianchushengji",self.ctn_1, false,function ()

	end)
	-- local view = UIBaseDef:cloneOneView(self.UI_1); 
	FuncArmature.changeBoneDisplay(lockAni,"a",self.mc_build)
	FuncArmature.changeBoneDisplay(lockAni,"c",self.txt_1)
	FuncArmature.changeBoneDisplay(lockAni,"b",self.txt_2)
	FuncArmature.changeBoneDisplay(lockAni,"e",self.rich_3)
	FuncArmature.changeBoneDisplay(lockAni,"f",self.txt_jixu)
	self.mc_build:setPosition(cc.p(-275/2,189/2))
	self.txt_1:setPosition(cc.p(0,0))
	self.txt_2:setPosition(cc.p(0,0))
	self.rich_3:setPosition(cc.p(-100,0))
	self.txt_jixu:setPosition(cc.p(-40,0))
	self.panel_lvjian:setVisible(false)



	-- self:addBuildIcon()
end

-- function GuildUpgSucView:addBuildIcon()
-- 	local builddata = FuncGuild.getguildBuildAllData()
-- 	local buildID =  self.sucdata.buildID
-- 	local buildicon =  builddata[tostring(buildID)]
-- 	local buildspritename = nil
-- 	-- if CONFIG_USEDISPERSED then
-- 	-- 	buildspritename =  FuncRes.uipng(buildicon)
-- 	-- else
-- 	-- 	buildspritename = "#"..buildicon..".png"
-- 	-- end
-- 	buildspritename = FuncRes.iconGuild(buildicon)
-- 	buildsprite = display.newSprite(buildspritename)
-- 	self.ctn_1:addChild()
-- end


function GuildUpgSucView:press_btn_close()
	
	self:startHide()
end


return GuildUpgSucView;
