--
-- Author: xd
-- Date: 2016-01-07 15:05:41
--
local InputExpand = class("InputExpand", function (  )
	return display.newNode()
end)


local inputTools = {}


function InputExpand:ctor( cfgs )
	local co = cfgs.co
	self.__uiCfgs = cfgs
	if co then
		self._defaultstr = co.defStr or " "
	else
		self._defaultstr = " "
	end
	if self._defaultstr =="" then
		self._defaultstr =" "
	end
	co.align = "left"
	local alignPoint  = UIBaseDef:turnAlignPoint( co.align  )
	local fontSize = co.fontSize or 32

	local align ,valign = UIBaseDef:turnAlign(co.align, "up")

	--self.__contentSize = {width =cfgs.w,height = cfgs.h }

	self._wid = math.round(cfgs.w)
	self._hei = math.round(cfgs.h)

	if self._hei % 2 == 1 then
		self._hei = self._hei +1
	end

	if self._wid % 2 == 1 then
		self._wid = self._wid + 1
	end

	--创建公用UI
	local ttfparams = {
        font = UIBaseDef:turnFontName(GameVars.systemFontName ),
        text = "",
        size = fontSize,
        align = cc.TEXT_ALIGNMENT_LEFT,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
        color = numberToColor(co.color or 0),
        dimensions = cc.size(self._wid,self._hei),
    }

    --self:setContentSize(cc.size(cfgs.w,cfgs.h ))

    -- dump(ttfparams.dimensions,"____dimensions")
	self.contentLabel = display.newTTFLabel(ttfparams):addto(self):anchor(0,1)
	self.contentLabel:setCascadeOpacityEnabled(true)
	-- self:setContentSize(cc.size(cfgs.w,cfgs.h))

	

	-- echo(cfgs.h,'____高度')

	self:initDefaultText()

end

--点击文本输出
function InputExpand:startInput(  )
	if self.scrollView then
		if self.scrollView:isMoving() then
			return
		end
	end

	FuncCommUI.startInput(self:getText(), c_func(self.inputEnd, self), self.__uiCfgs.co)
end

--输入结束
function InputExpand:inputEnd(text, t)
	if t == 0 then
		return
	end
	--这个时候 自身是可能被删除的
	if tolua.isnull(self) then
		return
	end

	self:setText(text)
	if self._inputEndCallBack then
		echo("InputExpand..inputEnd----------------------------------------")
		self._inputEndCallBack()
	end
end


--设置文本
function InputExpand:setText(text)
	local co = self.__uiCfgs.co
	if text =="" then
		self.contentLabel:setString(self._defaultstr)
		self.contentLabel:setColor(numberToColor(co.defColor or 0))
	else
		self.contentLabel:setString(text)
		self.contentLabel:setColor(numberToColor(co.color or 0))
	end
end

function InputExpand:initDefaultText()
	local co = self.__uiCfgs.co
	self.contentLabel:setString(self._defaultstr)
	self.contentLabel:setColor(numberToColor(co.defColor or 0))
end

function InputExpand:set_defaultstr(text)
	self._defaultstr = text
end

--获取文本
function InputExpand:getText(  )
	local str = self.contentLabel:getString()
	--如果是默认文本 那么返回空
	if str == self._defaultstr then
		return ""
	end
	return self.contentLabel:getString()
end


function InputExpand:attachIME(  )
	if self._isInputEnable == nil or self._isInputEnable == true then 
		echo("激活IME")
		self.textField:attachWithIME();
	end 
end

--设置输入框是否可以输入 不能用了！
function InputExpand:setEnabled(bool)
	self._isInputEnable = bool;
end

--获取坐标
function InputExpand:getContainerBox()
	return {x=0,y=-self._hei,width = self._wid,height = self._hei}
end



--弹出输入框 传递回调函数 并返回输入字符串和结果, 1是成功, 2是取消  callBack("info",1)
function inputTools:popUpInput( callBack )
    if  self._inputView then
    	local scene = WindowControler:getCurrScene()

        self._inputView = UIBaseDef:createUIByName("InputView",UIBase)
    end
end

--align: left, right, center
--valign: up, down , center
function InputExpand:setAlignment(align, valign)
	local align, valign = UIBaseDef:turnAlign(align, valign)
	self.contentLabel:setAlignment(align, valign)
end

function InputExpand:setInputEndCallback(callBack)
	self._inputEndCallBack = callBack
end

function InputExpand:adjustContentLabel(width, height)
    self:setTouchedFunc(c_func(self.startInput, self))
	self.contentLabel:setContentSize(cc.size(width, height))
	self.contentLabel:setDimensions(width, height)
	self._hei = height
	self._wid = width
end

return InputExpand




