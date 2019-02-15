--
--Author:      zhuguangyuan
--DateTime:    2018-05-11 15:01:07
--Description: 返回主城
--


local ReturnHome = class("ReturnHome", UIBase);

function ReturnHome:ctor(winName)
    ReturnHome.super.ctor(self, winName)
end

function ReturnHome:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function ReturnHome:registerEvent()
	ReturnHome.super.registerEvent(self);
--[[	self.btn_tophome:setTap(self.returnHome, self)
	self.btn_topchat:setTap(self.returnHome, self)
	self.btn_topmubiao:setTap(self.returnHome, self)--]]
end

function ReturnHome:returnHome()
	-- body
end
function ReturnHome:initData()
	-- TODO
end

function ReturnHome:initView()
	-- TODO
end

function ReturnHome:initViewAlign()
	-- TODO
end

function ReturnHome:updateUI()
	-- TODO
end

function ReturnHome:deleteMe()
	-- TODO

	ReturnHome.super.deleteMe(self);
end

return ReturnHome;
