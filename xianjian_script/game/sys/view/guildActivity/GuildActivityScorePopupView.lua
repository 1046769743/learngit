--
--Author:      zhuguangyuan
--DateTime:    2018-06-08 17:23:40
--Description: 获得积分弹tips 
--
-- 1.参照tips
-- 2.WindowControler:showTips(23, 1, 0,true)

local GuildActivityScorePopupView = class("GuildActivityScorePopupView", UIBase);

function GuildActivityScorePopupView:ctor(winName,score)
    GuildActivityScorePopupView.super.ctor(self, winName)
    self.score = score
end

function GuildActivityScorePopupView:loadUIComplete()
	GuildActivityScorePopupView.super.loadUIComplete(self)
	-- self:registerEvent()
	-- self:initData()
	-- self:initViewAlign()
	-- self:initView()
	-- self:updateUI()
end 

function GuildActivityScorePopupView:hideComplete( )
    self:visible(false)
end

function GuildActivityScorePopupView:registerEvent()
	GuildActivityScorePopupView.super.registerEvent(self);
end

function GuildActivityScorePopupView:initData()
	-- TODO
end

function GuildActivityScorePopupView:initView()
	-- TODO
end

function GuildActivityScorePopupView:initViewAlign()
	-- TODO
end

function GuildActivityScorePopupView:startShow(info, delayTime)
	dump(info, "=================info", nesting)
	self:showScoreNum( self.mc_shuzi,info )

	if delayTime == nil then
        delayTime = 1.5
    end

    self:pos()

    self:stopAllActions()

    self:opacity(0)

    self:runAction(
        act.sequence(
                act.fadeto(0.15, 255),
                act.delaytime(delayTime),
                act.fadeto(0.3, 0),
                act.callfunc(c_func(self.hideComplete, self))
            )
    )

    -- Tips.super.startShow(self)

    --1秒以后隐藏
    -- self:delayCall(c_func(self.startHide,self), 1.5)

    -- local onlyChar = str
    -- if self.txt_1 then
    --     self.txt_1:setString(str)
    -- else
    --     self.rich_1:setString(str)
    --     onlyChar = self.rich_1._onlyChars
    -- end
    
    -- local width = FuncCommUI.getStringWidth(onlyChar,self.txtView:getFontSize()) +10
    -- if width <= self._initTxtWidth then
    --     width =  self._initTxtWidth
    -- end
    -- self.txtView:setTextWidth(width)
    -- self.txtView:setString(str)
    -- local offsetX = -(width - self._initTxtWidth)/2
    -- self.txtView:pos(self._initTxtPos.x +offsetX,self._initTxtPos.y )

    -- local s9size = self.scale9_tips:getContentSize()
    -- s9size.width = width + 40
    -- if s9size.width <= self._initSize.width then
    --     s9size.width = self._initSize.width
    -- end
    -- offsetX = -(s9size.width - self._initSize.width)/2
    -- self.scale9_tips:setContentSize(s9size)
    -- self.scale9_tips:pos(self._initPos.x +offsetX,self._initPos.y )

end


function GuildActivityScorePopupView:updateUI()
	-- self:showScoreNum( self.mc_shuzi,self.score )
end

function GuildActivityScorePopupView:showScoreNum( _mcView,_score )
-- 参照战力组件
	local mcView = _mcView or self.mc_shuzi
	local nums = number.split(_score)
    local len = table.length(nums);
    --不能高于6
    if len > 6 then 
        return
    end 
    mcView:showFrame(len);
    for k, v in ipairs(nums) do
        local mcs = mcView:getCurFrameView();
        local childMc = mcs["mc_" .. tostring(k)]
        childMc:showFrame(v + 1);
    end

    self:delayCall(c_func(self.startHide,self),3)
end

function GuildActivityScorePopupView:deleteMe()
	GuildActivityScorePopupView.super.deleteMe(self);
end

return GuildActivityScorePopupView;
