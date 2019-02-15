local InputView = class("InputView", UIBase)
--公用 input输出框
--[[
    self.UI_inputModel,
    self.btn_1,
    self.btn_2,
    self.rect_1,
]]

function InputView:ctor(winName)
    InputView.super.ctor(self, winName)
end

function InputView:loadUIComplete()
	self:registerEvent()

    --self:setTouchedFunc(func, rect, touchSwallowEnabled, beganCallback, movedCallback)

   local coverLayer = WindowControler:createCoverLayer( -GameVars.UIOffsetX,GameVars.UIOffsetY,cc.c4b(0,0,0,0)):addto(self._root,-1)
        
   coverLayer:setTouchedFunc(c_func(self.pressClickEmpty, self),nil,true)

end 


--点击空地
function InputView:pressClickEmpty(  )
    echo("pressClickEmpty ")
    self:doCallBack(0)
end

function InputView:createBox(  )
    if self.editBox then
        self.editBox:unregisterScriptEditBoxHandler()
        self.editBox:clear()
    end

    local rect = self.rect_1:getContainerBoxToParent()

    local offset = 10

    local dbOffset = 20
    --创建editBox
    self.editBox = ccui.EditBox:create(cc.size(rect.width-dbOffset,rect.height-dbOffset) , display.newScale9Sprite("a/a0_4.png") ,nil,nil )
                    :addto(self._root)
                    :pos(rect.x+offset,rect.y + rect.height -offset):anchor(0,1)
    self.editBox:setFontColor(cc.c3b(0,0,0))
    

    self.editBox:registerScriptEditBoxHandler(c_func(self.pressEditBox, self))
    if(device.platform=="android")then
         self.editBox:setVisible(false);
    end
end



function InputView:pressEditBox(e)
     if e=="began" then
        if device.platform == "android" then
            echo("------pressEditBox begin")
        end


    elseif e =="changed" then
         local  _text=self.editBox:getText();
         local  _size=string.len4cn2(_text);
-- //如果超过了限制
         if(_size>self.maxlength)then
                local _sub_text=string.subcn(_text,1,self.maxlength);
                self.editBox:setText(_sub_text);
         end
    elseif  e=="ended" then
          self:doCallBack(0);
    elseif e =="return" then
        self:doCallBack(1)
    else
    end
end


function InputView:doCallBack(t)
    if not self.editBox then
        return
    end


    local text = self.editBox:getText()
    
    if self._callBack then

        text = string.gsub(text, "[<>]","*")
        self._callBack(text,t)

        

    end
    
    local tempFunc = function()
        self:visible(false)
        if self.editBox then
            self.editBox:unregisterScriptEditBoxHandler()
            self.editBox:clear()
            self.editBox = nil
        end
    end
    self:stopAllActions()
    --延迟一帧删除
    self:delayCall(tempFunc ,0.05)
    
    
end


function InputView:registerEvent()
	InputView.super.registerEvent()
--//如果是安卓平台,直接隐藏掉
    self.btn_1:setVisible(false);
    self.btn_2:setVisible(false);
--    self.btn_1:setTap(c_func(self.press_btn_1, self))
--    self.btn_2:setTap(c_func(self.press_btn_2, self))
end


--开始输入     传入一个回调  callBack("haha",1) 2个参数 输入结果 和方式 1是确定 0是取消
--inputParams  fontSize ,fontColor,等 flash里面的参数
function InputView:startInput(curStr, callBack,inputParams )
    -- 2017-12-19 TODO临时解决Android平台频繁点击输入框导致闪退的问题
    -- if device.platform == "android" then
    --     if self.hasShowInput then
    --         return
    --     end

    --     local setStatusCallBack = function()
    --         self.hasShowInput = false
    --     end
        
    --     self.hasShowInput = true
    --     self:delayCall(setStatusCallBack,0.3)
    -- end

    self._callBack = callBack
    self._inputParams = inputParams
    self:stopAllActions()
    self:createBox()

    self.editBox:setText(curStr or "")

    local tempFunc = function (  )
        --手动弹开输入面板
        self.editBox:touchDownAction(nil,2)
    end

    self:delayCall(tempFunc,0.05)
    
    if inputParams then
        echo(inputParams.maxLength,"inputParams.maxLength")
        self.editBox:setMaxLength(inputParams.maxLength or 20)
    end
    self.maxlength=inputParams.maxLength or 20;
    --开始显示
--    self:visible(true)
--//如果是安卓平台
   if(device.platform=="android")then
          self.editBox:setVisible(false);
          echo("---------device.platform==",device.platform,"--------");
         self:visible(false)
   else
         self:visible(true)
   end
   -- echo("--platform----",device.platform);
end

function InputView:press_btn_1()
    echo("pressBtn1")
    self:doCallBack(0)
end

function InputView:press_btn_2()
    self:doCallBack(1)
end


function InputView:updateUI()
	
end

return InputView
