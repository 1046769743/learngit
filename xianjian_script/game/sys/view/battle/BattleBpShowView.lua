--
-- Author: pangkangning
-- Note:仙界对决bp选人结束展示页
-- Date: 2018-06-04 
--

local BattleBpShowView = class("BattleBpShowView", UIBase)


function BattleBpShowView:ctor(winName,controler)
    BattleBpShowView.super.ctor(self, winName)
    self.controler = controler
    self._selectIds = {}
end
function BattleBpShowView:loadUIComplete(  )
	local camp = BattleControler:getTeamCamp()
	local partners = self.controler.levelInfo:getAllHeroByCamp(camp)
	local count = #partners
	if count == 6 then
	    self.mc_1:showFrame(2)
	else
		self.mc_1:showFrame(1)
	end
	local tmpView = self.mc_1.currentView
	if count == 6 then
		for i=1,5 do
			tmpView["UI_"..i]:visible(false)
		end
	else
		for i=1,7 do
			tmpView["UI_"..i]:visible(false)
		end
	end
	self.mc_1.currentView.panel_1:visible(false)
	-- 加载角色立绘
	self:udpatePartners()
	-- 法宝

	self:delayCall( function( )
		self:updateTreasure()
	end,((count-1)*3)/GameVars.GAMEFRAMERATE )

	self:delayCall(function( )
		self:startHide()
	end, 3)
end
function BattleBpShowView:udpatePartners( ... )
	local camp = BattleControler:getTeamCamp()
	local partners = self.controler.levelInfo:getAllHeroByCamp(camp)
	local tmpView = self.mc_1.currentView
	local _updatePartner = function( idx,cardId )
		local cartInfo = FuncCrosspeak.getPartnerMapping(cardId)
		local tmp = {quality=cartInfo.quality,star = cartInfo.star}
		tmpView["UI_"..idx]:updataUI(cartInfo.partnerId,nil,tmp)
		tmpView["UI_"..idx]:visible(true)
	end
	local idx = 1
	for k,v in pairs(partners) do
		if v.__cardId ~= "1" then --主角
			self:delayCall( c_func(_updatePartner,idx,v.__cardId),
							((idx-1)*3)/GameVars.GAMEFRAMERATE 
							)
			idx = idx + 1
		end
	end
end
function BattleBpShowView:updateTreasure( )
	local oData = self.controler.levelInfo:getCrossPeakOtherData()
	local segData = FuncCrosspeak.getSegmentDataById(oData.seg)
    local avatar = UserModel:avatar()
	local camp = BattleControler:getTeamCamp( )
	local bpT = self.controler.levelInfo:getCrossPeakTreasure()
	local treasureId = bpT[camp]
	local view = self.mc_1.currentView.panel_1
	view:visible(true)
	local tData = FuncTreasureNew.getTreasureDataById(treasureId)
	-- dump(tData,"====")
	view.txt_1:setString(GameConfig.getLanguage(tData.name))
	view.mc_skill:showFrame(1)
	local sp = display.newSprite(FuncRes.iconTreasureNew(treasureId))
    view.mc_skill.currentView.ctn_1:removeAllChildren()
    view.mc_skill.currentView.ctn_1:addChild(sp)
    view.mc_type:showFrame(tData.type)
    view.mc_star:showFrame(segData.starTreasure)
    -- view.mc_star:visible(false)
    local energyCost = FuncTreasureNew.getEnergyCost(treasureId,segData.starTreasure)
    view.txt_cost:setString(GameConfig.getLanguage("#tid_wuxing_031")..energyCost)

    local skills = FuncTreasureNew.getTeasureSkillsByIdAndAvatar(treasureId, avatar)
    local skillData = FuncTreasureNew.getTreasureSkillDataDataById(skills[1])
    local skillDes = GameConfig.getLanguage(skillData.describe)
    view.txt_name:setString(GameConfig.getLanguage(skillData.name))
    view.rich_des:setString(skillDes)
end
return BattleBpShowView