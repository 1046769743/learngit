--[[
	Author: TODO
	Date:2017-12-25
	Description: TODO
]]

local WuXingCrossPeakTeamView = class("WuXingCrossPeakTeamView", UIBase);

function WuXingCrossPeakTeamView:ctor(winName, systemId, isMuilt, isCheck, hasNpc)
    WuXingCrossPeakTeamView.super.ctor(self, winName)
    self.systemId = systemId
end

function WuXingCrossPeakTeamView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function WuXingCrossPeakTeamView:registerEvent()
	WuXingCrossPeakTeamView.super.registerEvent(self);

	local coverLayer = WindowControler:createCoverLayer(GameVars.width, GameVars.height, cc.c4b(0,0,0,0), true):addto(self.ctn_bgbg, 0)
    coverLayer:pos(- GameVars.width / 2,  GameVars.height / 2)
	coverLayer:setTouchedFunc(c_func(self.hideCandidatePanel, self))
	coverLayer:setTouchSwallowEnabled(false)
	
	self.btn_hb:setTap(c_func(self.popUpCandidatePanel,self))
	-- EventControler:addEventListener(TeamFormationEvent.UPDATA_POSNUMTEXT, self.updateFirstTxt, self)
	-- EventControler:addEventListener(TeamFormationEvent.CANDIDATE_CHANGED, self.updateCandidateTxt, self)
	EventControler:addEventListener(TeamFormationEvent.CANDIDATE_CHANGED, self.updateCandidateUI, self)
	EventControler:addEventListener(TeamFormationEvent.CANDIDATE_NOT_FULL, self.popUpCandidatePanel, self)
	EventControler:addEventListener(TeamFormationEvent.CHANGED_TO_WULING, self.hideBtnAndPanel, self)
	EventControler:addEventListener(TeamFormationEvent.CHANGED_TO_PARTNER, self.showBtnAndPanel, self)
	-- self:registClickClose("-1", c_func(self.hideCandidatePanel, self))
end

function WuXingCrossPeakTeamView:initData()
	self.fightInStageMax = CrossPeakModel:getFightInStageMax()
	self.fightNumMax = CrossPeakModel:getFightNumMax()
	self.candidateNum = self.fightNumMax - self.fightInStageMax
end

function WuXingCrossPeakTeamView:initView()
	self.panel_hb:setVisible(false)
	self.isVisible = false
	self.panel_hb.mc_1:showFrame(self.candidateNum - 2)
	self.candidatePanel = self.panel_hb.mc_1.currentView
	self.panel_txt:setVisible(false)
	self:updateFirstTxt()
	self:updateCandidateTxt()
	self:updateCandidateUI()
end

function WuXingCrossPeakTeamView:showBtnAndPanel()
	self.btn_hb:setVisible(true)
end

function WuXingCrossPeakTeamView:hideBtnAndPanel()
	self:hideCandidatePanel()
	self.btn_hb:setVisible(false)
end

-- 弹出候补框
function WuXingCrossPeakTeamView:popUpCandidatePanel()
	self.panel_hb:setVisible(true)
	self.isVisible = true
	self.btn_hb:setVisible(false)
	-- 设置候补框的弹出状态
	TeamFormationModel:setCandidatePanelStatus(true)
end

-- 隐藏候补框
function WuXingCrossPeakTeamView:hideCandidatePanel()
	if self.isVisible == true then
    	self.panel_hb:setVisible(false)
		self.isVisible = false
		self.btn_hb:setVisible(true)
		-- 设置候补框的弹出状态
		TeamFormationModel:setCandidatePanelStatus(false)
		-- 设置此时正处于关闭候补框状态 用于处理点击到柱子上奇侠时的事件
		TeamFormationModel:setCloseCandidatePanel(true)
    end
end

-- 更新左上角文字描述
function WuXingCrossPeakTeamView:updateFirstTxt()	
	-- local string1 = string.format("/ %s个首发", self.fightInStageMax)
	-- local nowTeamNum = TeamFormationModel:hasNowTeamNum(self.systemId)
	-- if nowTeamNum < self.fightInStageMax then
	-- 	self.panel_txt.mc_1:showFrame(2)
	-- else
	-- 	self.panel_txt.mc_1:showFrame(1)
	-- end
	-- self.panel_txt.mc_1.currentView.txt_2:setString(tostring(nowTeamNum))
	-- self.panel_txt.txt_3:setString(string1)

	-- if not self.tipsAnim then
	-- 	self.panel_txt:opacity(0)
	-- 	self.tipsAnim = self:createUIArmature("UI_wulingchuzhan","UI_wulingchuzhan_chuzhantishi", self.ctn_texiao, false)
	--     self.tipsAnim:pos(0, -5)
	--     self.tipsAnim:registerFrameEventCallFunc(15, 1, function ()
	--         self.panel_txt:runAction(act.fadein(0.5))
	--         -- self.mc_wen:setVisible(true)
	--     end)
	-- end
	 
end

function WuXingCrossPeakTeamView:updateCandidateTxt()
	-- local string2 = string.format("/ %s个候补", self.candidateNum)
	-- local nowCandidateNum = TeamFormationModel:hasNowCandidateNum()
	-- if nowCandidateNum < self.candidateNum then
	-- 	self.panel_txt.mc_2:showFrame(2)
	-- else
	-- 	self.panel_txt.mc_2:showFrame(1)
	-- end
	-- self.panel_txt.mc_2.currentView.txt_4:setString(tostring(nowCandidateNum))
	-- self.panel_txt.txt_5:setString(string2)
end

function WuXingCrossPeakTeamView:updateCandidateUI() 
	local formation = TeamFormationModel:getTempFormation()
	for k = 1, self.candidateNum, 1 do
		local tempView = self.candidatePanel["panel_goods"..k]
		tempView.panel_tanhao:setVisible(false)
		tempView.panel_xuanzhong:setVisible(false)
		tempView.panel_yishangzhen:setVisible(false)
		tempView.panel_tiao:setVisible(false)
		if formation.bench[tostring(k)] == nil or formation.bench[tostring(k)] == "0" then
			tempView:setVisible(false)
			tempView.partnerId = "0"
		else
			tempView:setVisible(true)
			tempView.mc_pai:visible(false)
			tempView.mc_pai:showFrame(1)
	        local partnerId = formation.bench[tostring(k)]

	        local itemType 
	        local nowElement
	        tempView.ctn_tu2:removeAllChildren()
	        if tonumber(partnerId) == 1 then
	            partnerId = UserModel:avatar()
	            local garmentId = GarmentModel:getOnGarmentId()
	            tempView.UI_1:updataUI(partnerId,garmentId,nil,self.systemId)
	            local curTreaData = nil
	            local tempTreasure = nil
                curTreaData = TeamFormationModel:getCurTreaByIdx(1)  
                tempTreasure = FuncTreasureNew.getTreasureDataById(curTreaData)   
	            nowElement = tempTreasure.wuling
	            itemType = tempTreasure.type
	            tempView.mc_gfj:showFrame(itemType)
	        else    
	            local skin = ""
	            local partnerData = PartnerModel:getPartnerDataById(partnerId)
	            local partnerCfg = FuncPartner.getPartnerById(partnerId)
	            if partnerData then
	                skin = partnerData.skin
	            end
	            tempView.UI_1:updataUI(partnerId,skin,nil,self.systemId)
	            itemType = FuncPartner.getPartnerById(partnerId).type
	            -- itemType = TeamFormationModel:getPropByPartnerId(partnerId)
	        	nowElement = partnerCfg.elements
	            tempView.mc_gfj:showFrame(itemType)
	        end
	        
	        local wuxingData = FuncTeamFormation.getWuXingDataById(nowElement)
	        local wuxingIcon = FuncRes.iconWuXing(wuxingData.icon)
	        local sp = display.newSprite(wuxingIcon):addto(tempView.ctn_tu2)
	        sp:setScale(0.3)

	        -- if FuncCommon.isSystemOpen("fivesoul") then 
	        --     tempView.ctn_tu2:visible(true)
	        --     tempView.panel_d:visible(true)
	        -- else
	        --     tempView.ctn_tu2:visible(false)
	        --     tempView.panel_d:visible(false)
	        -- end
	        tempView.partnerId = partnerId     
		end
		tempView:setTouchedFunc(c_func(self.doItemClick, self, k))
	    tempView:setTouchSwallowEnabled(true)
	end
end

function WuXingCrossPeakTeamView:doItemClick(_index)
	local formation = TeamFormationModel:getTempFormation()
	if formation.bench[tostring(_index)] == nil or formation.bench[tostring(_index)] == "0" then
		return 
	end

	TeamFormationModel:removeCandidatePartner(_index)
	EventControler:dispatchEvent(TeamFormationEvent.CANDIDATE_CHANGED)
    EventControler:dispatchEvent(TeamFormationEvent.UPDATA_SCROLL)
end

function WuXingCrossPeakTeamView:initViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_txt, UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.ctn_texiao, UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_hb, UIAlignTypes.MiddleBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.btn_hb, UIAlignTypes.RightTop)
end

function WuXingCrossPeakTeamView:updateUI()
	
end

function WuXingCrossPeakTeamView:deleteMe()
	-- TODO

	WuXingCrossPeakTeamView.super.deleteMe(self);
end

return WuXingCrossPeakTeamView;
