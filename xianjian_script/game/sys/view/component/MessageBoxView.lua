--guan
--2016.1.13

--todo 公共messageBox

local MessageBoxView = class("MessageBoxView", UIBase);

--[[
    self.btn_close,
    self.mc_btn1,
    self.rich_neirong,
    self.rich_title,
    self.scale9_tanchuang1,
]]

function MessageBoxView:ctor(winName, params)
    MessageBoxView.super.ctor(self, winName);
    self._params = params;
end

function MessageBoxView:loadUIComplete()
    self:registerEvent();
end 

function MessageBoxView:registerEvent()
    MessageBoxView.super.registerEvent();
    -- self.btn_close:setTap(c_func(self.press_btn_close, self));
    self:initUI();
end

function MessageBoxView:initUI()
    --标题
    self.txt_title:setString(self._params.title or "");
    --内容
    self.txt_des:setString(self._params.des or "");

    --btn
    if self._params.isSingleBtn == true then 
        self.mc_1:showFrame(1);
        self.mc_1.currentView.btn_1:setTap(c_func(self.press_btn_1, self));
        if self._params.firstBtnStr ~= nil then
            -- self.mc_1.currentView.btn_queding1.txt_queding:setString(self._params.firstBtnStr);
            self.mc_1.currentView.btn_1:setBtnStr(self._params.firstBtnStr);
        end 
    else
        self.mc_1:showFrame(2);

        self.mc_1.currentView.btn_quxiao1:setTap(c_func(self.press_btn_1, self));
        if self._params.firstBtnStr ~= nil then
            -- self.mc_1.currentView.btn_quxiao1.txt_quxiao:setString(self._params.firstBtnStr);
            self.mc_1.currentView.btn_2:setBtnStr(self._params.firstBtnStr);

        end         

        self.mc_1.currentView.btn_queding2:setTap(c_func(self.press_btn_2, self));
        if self._params.secondBtnStr ~= nil then
            -- self.mc_1.currentView.btn_queding2.txt_queding:setString(self._params.secondBtnStr);
            self.mc_1.currentView.btn_1:setBtnStr(self._params.secondBtnStr);
            
        end  
    end 
end

function MessageBoxView:press_btn_1()
    echo("press_btn_1");
    if self._params.firstBtnCallBack ~= nil then 
        self._params.firstBtnCallBack();
    end 
    self:startHide();
end

function MessageBoxView:press_btn_2()
    echo("press_btn_2");
    if self._params.secondBtnCallBack ~= nil then 
        self._params.secondBtnCallBack();
    end 
    self:startHide();
end

function MessageBoxView:press_btn_close()
    self:startHide();
end


function MessageBoxView:updateUI()
    
end

return MessageBoxView;







