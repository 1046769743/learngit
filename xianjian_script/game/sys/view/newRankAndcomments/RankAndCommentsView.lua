-- RankAndCommentsView
--[[
	Author: wk
	Date:2018-01-15
]]

local RankAndCommentsView = class("RankAndCommentsView", UIBase);

function RankAndCommentsView:ctor(winName)
    RankAndCommentsView.super.ctor(self, winName)
end

function RankAndCommentsView:loadUIComplete()
	self:registerEvent()

end 

function RankAndCommentsView:registerEvent()
	RankAndCommentsView.super.registerEvent(self);

	self:registClickClose("out")
	self.panel_di.txt_1:setString(GameConfig.getLanguage("#tid_newRank_010")) 
	self.panel_di.btn_1:setTouchedFunc(c_func(self.close, self))
	self.UI_pinglun_1:setVisible(false)
	self.UI_pinglun_2:setVisible(false)
	-- self.txt_1:setVisible(false)
	-- self.UI_pinglun_1.UI_1:setVisible(false)
	-- self.UI_pinglun_2.UI_1:setVisible(false)

end

function RankAndCommentsView:initData(arrayData)
	self.UI_pinglun_1:setVisible(true)
	self.UI_pinglun_2:setVisible(true)
	-- self.UI_pinglun_1.panel_1.btn_1:setVisible(false)
	-- self.UI_pinglun_2.panel_2.btn_close:setVisible(false)
	self.txt_1:setVisible(false)
	-- local alldata = {}--用model里面的数据

	local  rankInfo = RankAndcommentsModel:getAllRankInfoData()
 	local  commentsInfo = RankAndcommentsModel:getAllCommentsInfoData()


 	if rankInfo ~= nil and table.length(rankInfo) ~= 0 then
		self.UI_pinglun_1:initData(arrayData,rankInfo)  --排行
	else
		self.UI_pinglun_1:setVisible(false)
		self.txt_1:setVisible(true)
		self.txt_1:setString(GameConfig.getLanguage("#tid_newRank_011"))
	end

	self.UI_pinglun_2:initData(arrayData,commentsInfo) --评论
	self.UI_pinglun_2.panel_2.panel_kai:setVisible(false)
	-- self.UI_pinglun_2.panel_2.txt_dm:setVisible(false)
end


function RankAndCommentsView:close()
	self:startHide()
end

function RankAndCommentsView:deleteMe()
	-- TODO
	RankAndCommentsView.super.deleteMe(self);
end

return RankAndCommentsView;
