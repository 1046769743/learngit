local TestView = class("TestView", UIBase);

--[[
    self.rect_1,
    self.txt_1,
    self.txt_2,
    self.txt_3,
    self.txt_4,
]]

function TestView:ctor(winName)
    TestView.super.ctor(self, winName);
end

function TestView:loadUIComplete()
	self:registerEvent();
	
	FuncArmature.loadOneArmatureTexture("test",nil,true)

	local ani = self:createUIArmature(nil,"renwchu_taijia", self._root, true):pos(100,-300)
	
end




function TestView:registerEvent()
	TestView.super.registerEvent();
	self.txt_1:setTouchedFunc(c_func(self.press_txt_1,self) )
	self.txt_3:setTouchedFunc(c_func(self.press_txt_3,self) )


	self.test_str1 = 123321121123

	--加密串是 123321
	self.test_str2 = numEncrypt:getMergeStr(numEncrypt:ns1(),numEncrypt:ns2(),numEncrypt:ns3(),numEncrypt:ns3(),numEncrypt:ns2(),numEncrypt:ns1())

end


function TestView:press_txt_1(  )
	echo("showNum11111111")
	self.txt_2:setString(self.test_str1)
end

function TestView:press_txt_3(  )
	echo("showNum222222222222__"..self.test_str2)
	self.txt_4:setString(self.test_str2)
	self.txt_6:setString(numEncrypt:getNum( self.test_str2) )
end


function TestView:updateUI()
	
end


return TestView;
