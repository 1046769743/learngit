local TestDebugView = class("TestDebugView", UIBase);

--[[
    self.btn_back,
    self.btn_debug,
    self.input_1,
    self.input_2,
    self.rect_1,
    self.rect_2,
    self.rect_bg,
    self.txt_2,
    self.txt_aaa,
    self.txt_info,
]]

function TestDebugView:ctor(winName)
    TestDebugView.super.ctor(self, winName);
end

function TestDebugView:loadUIComplete()
	self:registerEvent();
end 

function TestDebugView:registerEvent()
	TestDebugView.super.registerEvent();
    self.btn_debug:setTap(c_func(self.press_btn_debug, self));
    self.btn_back:setTap(c_func(self.press_btn_back, self));

    self.btn_send:setTap(c_func(self.press_btn_send, self))


    if LoginControler._uname then
        self.txt_isLogin:setString("是")
    else
        self.txt_isLogin:setString("否")

    end

end

function TestDebugView:press_btn_debug()

    local  method = self.input_1:getText()
    local value = tonumber(self.input_2:getText() )

    if not method or method =="" then

        return
    end

    echo("_调试")
    --如果是没有登入的
    if not LoginControler._uname then
        return
    end

    if (value) then
        Server:sendRequest({value=value}, method)
    else
        local info = json.decode(self.input_2:getText() ) or {}

        dump(info,"info_")
        Server:sendRequest(info, method)
    end

    --{"all":1,"tempId":2,"reward":["3,1000001"],"param":["dev_30",20001,11369]}

end



--发送请求
function TestDebugView:press_btn_send(  )
    local str = self.input_3:getText()
    if str =="" then
        return
    end
    echo(str,"___str")

    local jsonData = json.decode(str)
    if not jsonData then
        echo("___错误的数据--")
        return
    end

    Server.curConn = jsonData

    Server:sureSend(jsonData)

    --Server.socket:sendRequest(str)


end

function TestDebugView:press_btn_back()
    self:startHide()

end


function TestDebugView:updateUI()
	
end


return TestDebugView;
