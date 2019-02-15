-- GuildSucceedView
-- Author: Wk
-- Date: 2017-09-29
-- 公会预览view   创建成功
local GuildSucceedView = class("GuildSucceedView", UIBase);

function GuildSucceedView:ctor(winName)
    GuildSucceedView.super.ctor(self, winName);
end

function GuildSucceedView:loadUIComplete()
	-- local size = self.panel_di:getContainerBox()
	-- self.panel_bg:setScaleX(GameVars.width/size.width) 
	self:registClickClose(-1, c_func( function()
		EventControler:dispatchEvent(GuildEvent.GUILD_jump_TO_RECOMMEND)
        self:press_btn_close()
    end , self))

	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.txt_jixu,UIAlignTypes.MiddleBottom)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_yun1,UIAlignTypes.LeftBottom)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_yun2,UIAlignTypes.RightBottom)
	
	self.panel_biaoti:setVisible(false)
	self.panel_bg:setVisible(false)

	self:registerEvent()

	-- self.lockAni = self:createUIArmature("UI_xianmeng", "UI_xianmeng_chuangjianchenggong",self.ctn_2, false,function ()
	-- end)
	-- local view = UIBaseDef:cloneOneView(self.UI_1); 
	-- FuncArmature.changeBoneDisplay(self.lockAni,"layer25",self.UI_1)
	-- FuncArmature.changeBoneDisplay(self.lockAni,"layer26",self.txt_1)
	-- FuncArmature.changeBoneDisplay(self.lockAni,"layer27",self.txt_2)
	-- FuncArmature.changeBoneDisplay(self.lockAni,"layer28",self.txt_jixu)
	-- local middle = self.lockAni:getBoneDisplay("layer28")
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,middle,UIAlignTypes.MiddleBottom)
	-- local x = GameVars.width/2
	-- local y = GameVars.height/2
	-- self.UI_1:setPosition(0, 0);
	-- self.txt_1:setPosition(-250/2, 0);
	-- self.txt_2:setPosition(-50,0);
	-- self.txt_jixu:setPosition(0, 0);

	self:initData()

end

function GuildSucceedView:registerEvent()
	EventControler:addEventListener(GuildEvent.CLOSE_ALL_VIEW_UI, self.press_btn_close, self)
	-- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)

end
function GuildSucceedView:initData()
	local guildName = GuildModel.guildName
	local guildIcon = GuildModel.guildIcon
	self.UI_1:initData(guildIcon)
	local data = FuncGuild.getguildType()
	local namestid  = data[tostring(guildName._type)].afterName
	local names = GameConfig.getLanguage(namestid)

	self.txt_1:setString(guildName.name..names)

	-- self.mc_wenzi:setVisible(false)
	--:showFrame(guildName._type)

	self.lockAni = self:createUIArmature("UI_xianmeng", "UI_xianmeng_chuangjianchenggong",self.ctn_2, false,function ()

	end)
	-- local view = UIBaseDef:cloneOneView(self.UI_1); 
	FuncArmature.changeBoneDisplay(self.lockAni,"layer25",self.UI_1)
	FuncArmature.changeBoneDisplay(self.lockAni,"layer26",self.txt_1)
	FuncArmature.changeBoneDisplay(self.lockAni,"layer27",self.txt_2)
	FuncArmature.changeBoneDisplay(self.lockAni,"layer28",self.txt_jixu)
	-- local middle = self.lockAni:getBoneDisplay("layer28")
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,middle,UIAlignTypes.MiddleBottom)
	local x = GameVars.width/2
	local y = GameVars.height/2
	self.UI_1:setPosition(0, 0);
	self.txt_1:setPosition(-250/2, 0);
	self.txt_2:setPosition(-50,0);
	self.txt_jixu:setPosition(0, 0);


end

function GuildSucceedView:press_btn_close()
	
	self:startHide()
end



return GuildSucceedView;
