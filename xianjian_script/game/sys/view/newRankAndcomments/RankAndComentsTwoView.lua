-- RankAndComentsTwoView
--[[
	Author: wk
	Date:2018-01-15
]]

local RankAndComentsTwoView = class("RankAndComentsTwoView", UIBase);

function RankAndComentsTwoView:ctor(winName,arrayData,itemData)
    RankAndComentsTwoView.super.ctor(self, winName)
    self.arrayData = arrayData
    self.itemData = itemData
end

function RankAndComentsTwoView:loadUIComplete()
	self:registerEvent()
	self:registClickClose("out") 
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_newRank_008"))
	self.UI_1.btn_close:setTouchedFunc(c_func(self.close, self))

	self:setButton()
end 

function RankAndComentsTwoView:setButton()
	self.UI_1.mc_1:showFrame(1)
	self.UI_1.mc_1:getViewByFrame(1).btn_1:setTouchedFunc(c_func(self.quedingButton, self))
end
function RankAndComentsTwoView:quedingButton()
	local function _callback(param)
		if param.result ~= nil then
			self:close()
			WindowControler:showTips(GameConfig.getLanguage("#tid_newRank_009"))
		end
	end 

	local params = {
		system = self.arrayData.systemName,
		systemInnerIndex  = self.arrayData.diifID,
		postId = self.itemData.id,
	}
	RankAndcommentsServer:reportToServe(params, _callback)
end


function RankAndComentsTwoView:close()
	self:startHide()
end

function RankAndComentsTwoView:deleteMe()
	-- TODO
	RankAndComentsTwoView.super.deleteMe(self);
end

return RankAndComentsTwoView;
