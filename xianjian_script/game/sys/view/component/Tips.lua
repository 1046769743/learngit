--  User: cwb
--  Date: 2015/5/22
--  提示弹窗


local Tips = class("Tips", UIBase)


----   txt_warn 文本显示信息

function Tips:startShow(info, delayTime)
    self._isShow = true
    local str
    if type(info) == "string" then
        str = info
    else
        str = info.text
    end

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

    local onlyChar = str
    if self.txt_1 then
        self.txt_1:setString(str)
    else
        self.rich_1:setString(str)
        onlyChar = self.rich_1._onlyChars
    end
    
    local width = FuncCommUI.getStringWidth(onlyChar,self.txtView:getFontSize()) +10
    if width <= self._initTxtWidth then
        width =  self._initTxtWidth
    end
    self.txtView:setTextWidth(width)
    self.txtView:setString(str)
    local offsetX = -(width - self._initTxtWidth)/2
    self.txtView:pos(self._initTxtPos.x +offsetX,self._initTxtPos.y )

    local s9size = self.scale9_tips:getContentSize()
    s9size.width = width + 40
    if s9size.width <= self._initSize.width then
        s9size.width = self._initSize.width
    end
    offsetX = -(s9size.width - self._initSize.width)/2
    self.scale9_tips:setContentSize(s9size)
    self.scale9_tips:pos(self._initPos.x +offsetX,self._initPos.y )
end





function Tips:loadUIComplete()
	Tips.super.loadUIComplete(self)
    self._initPos = {}
    self._initPos.x,self._initPos.y = self.scale9_tips:getPosition()
    self._initSize = self.scale9_tips:getContentSize()

    self.txtView = self.txt_1 or self.rich_1

    self._initTxtPos = {}
    self._initTxtPos.x,self._initTxtPos.y = self.txtView:getPosition()
    self._initTxtWidth = self.txtView:getContainerBox().width



end


function Tips:hideComplete( )
    self:visible(false)
end


function Tips:updateUI()
end




return Tips
