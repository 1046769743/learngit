-- BarrageBaseCell
-- Aouth wk
-- time 2018/1/30

local BarrageBaseCell = class("BarrageBaseCell",function ()
    return display.newNode()
end)

-- BarrageBaseCell.ItemType = {
-- 	rich = 1,--纯文本
-- 	praise_rich = 2,--赞加文本
-- 	chat = 3,	--聊天相关
-- 	voice = 4, --纯语音
-- }


function BarrageBaseCell:ctor(controler)
	self.controler = controler --控制器视图

	self:registerEvent()
end

--子类重写
function BarrageBaseCell:registerEvent()

	
end


function BarrageBaseCell:setTap(handler)

    self.__tapFunc = handler
    if handler ~= GameVars.emptyFunc then
    	if self._clickNode then
        	self._clickNode:setTouchedFunc(self.__tapFunc, nil, true)
        else
        	echoError("====未注册点击事件====")
        end
    else
    	if self._clickNode then
	        self._clickNode:setTouchedFunc(self.__tapFunc, nil , false)
	    else
	    	echoError("====未注册点击事件====")
	    end
    end
    
    return self
end


--设置按钮是否可点
function BarrageBaseCell:enabled(v)
    if v then 
    	v = true
    else 
    	v = false 
    end
    self.__enabled = v
    self._clickNode:setTouchEnabled(v)
    return self
end


function BarrageBaseCell:UpTextData(data)
end





return BarrageBaseCell;
