-- ArtifactDecomposeSuccess
-- Author: Wk
-- Date: 2017-07-22
-- 神器分解成功系统界面
local ArtifactDecomposeSuccess = class("ArtifactDecomposeSuccess", UIBase);

function ArtifactDecomposeSuccess:ctor(winName,reward)
    ArtifactDecomposeSuccess.super.ctor(self, winName);
    self.reward = reward
end

function ArtifactDecomposeSuccess:loadUIComplete()
	self:registerEvent()
	self.UI_1:setVisible(false)
	self.panel_sp:setVisible(false)
	-- self.txt_2:setVisible(false)
	self:addBgEfftet()
	self:delayCall(function( )
		self.UI_1:setVisible(true)
		self:initData()
	end,0.5)
	
end 
function ArtifactDecomposeSuccess:addBgEfftet()
	local ctn =  self.ctn_efbg
	FuncCommUI.addCommonBgEffect(ctn,FuncCommUI.EFFEC_TTITLE.GONGXIHUODE,c_func(self.addCloseFunc, self))
	self:delayCall(function( )
		self:registClickClose(1, c_func( function()
	        self:press_btn_close()
	    end , self))
	end,1.0)
end

function ArtifactDecomposeSuccess:addCloseFunc()
	
end

function ArtifactDecomposeSuccess:registerEvent()
	-- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
end

function ArtifactDecomposeSuccess:initData()
	--[[
		self.reward = {
			id = 29,
			number = 100,
		}

	--]]

 	local params = {}
	params.reward = self.reward.id .. ","..self.reward.number
	self.UI_1:setResItemData(params)
	self.UI_1:showResItemName(true)
	self.UI_1:showResItemNum(true)
	self.UI_1:showResItemNameWithQuality()
	local rewardname =  FuncDataResource.getResNameById(self.reward.id)
	self.UI_1.panelInfo.mc_zi.currentView.txt_1:setString(rewardname)
end


function ArtifactDecomposeSuccess:press_btn_close()
	
	self:startHide()
end


return ArtifactDecomposeSuccess;
