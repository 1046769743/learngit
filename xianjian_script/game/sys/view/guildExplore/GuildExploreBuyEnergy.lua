--[[
	Author: TODO
	Date:2018-07-10
	Description: TODO
]]

local GuildExploreBuyEnergy = class("GuildExploreBuyEnergy", UIBase);

function GuildExploreBuyEnergy:ctor(winName)
    GuildExploreBuyEnergy.super.ctor(self, winName)
end

function GuildExploreBuyEnergy:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function GuildExploreBuyEnergy:registerEvent()
	GuildExploreBuyEnergy.super.registerEvent(self);
	self.UI_1.btn_close:setTap(c_func(self.startHide,self))
	self.UI_1.mc_1.currentView.btn_1:setTap(c_func(self.pressBuyBtn,self))
	self:registClickClose("out")
end

function GuildExploreBuyEnergy:pressBuyBtn(  )
	local addNums = FuncGuildExplore.getSettingDataValue("ExploreEnergyCost", "num")


	if not GuildExploreModel:checkActivityBuyEnergy(  ) then
		--如果没有激活财神
		WindowControler:showTips(GameConfig.getLanguage("tid_Explore_tips_2") )
		self:startHide()
		return
	end

	

	

	echo(GuildExploreModel:getLeftBuyEnergyCount(),"_GuildExploreModel")
	if GuildExploreModel:getLeftBuyEnergyCount( ) == 0 then
		WindowControler:showTips(GameConfig.getLanguage("tid_Explore_tips_3") )
		self:startHide()
		return
	end

	if UserModel:tryCost(FuncDataResource.RES_TYPE.DIAMOND, addNums,true) then
		GuildExploreServer:buyEnergy(  )
		self:startHide()
	end
end

function GuildExploreBuyEnergy:initData()
	-- TODO
end

function GuildExploreBuyEnergy:initView()
	-- TODO
end

function GuildExploreBuyEnergy:initViewAlign()
	-- TODO
end

function GuildExploreBuyEnergy:updateUI()
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_Explore_buytitle") )
	local addNums = FuncGuildExplore.getSettingDataValue("ExploreRecoveryNum", "num")
	local costNums = FuncGuildExplore.getSettingDataValue("ExploreEnergyCost", "num")
	self.txt_2:setString(tostring(addNums))
	self.txt_4:setString(tostring(costNums))
end

function GuildExploreBuyEnergy:deleteMe()
	-- TODO

	GuildExploreBuyEnergy.super.deleteMe(self);
end

return GuildExploreBuyEnergy;
