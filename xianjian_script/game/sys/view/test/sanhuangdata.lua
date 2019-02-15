local sanhuangdata = class("sanhuangdata", function() 
	return display.newNode()
end)

local BTN_WIDTH = 160
local BTN_HEIGHT = 70
local hangNums = 5

function sanhuangdata:ctor()
	self.btn_num = 0
    self._root = display.newNode():addto(self)
    local layer = WindowControler:createCoverLayer(0,GameVars.height ,cc.c4b(99,99,99,255)):addto(self,-1)
	self:createTestBtns()
end

function sanhuangdata:createTestBtns()
	self:creatBtns("三皇抽奖登录数据",c_func(self.sanhuangSeverDataTest,self))
    self:creatBtns("三皇元宝抽一抽奖数据结构调试",c_func(self.sanhuangSeverDataTest,self))
    self:creatBtns("三皇元宝抽十抽奖数据结构调试",c_func(self.sanhuangSeverDataTest,self))
    self:creatBtns("三皇抽奖替换奖池按钮数据",c_func(self.sanhuangSeverDataTest,self))
    self:creatBtns("三皇抽奖替换数据",c_func(self.sanhuangSeverDataTest,self))
    self:creatBtns("三皇免费抽一抽获得数据",c_func(self.sanhuangSeverDataTest,self))
    self:creatBtns("三皇免费抽五抽获得数据",c_func(self.sanhuangSeverDataTest,self))
    self:creatBtns("三皇抽奖数据结构调试",c_func(self.sanhuangSeverDataTest,self))
end

function sanhuangdata:back()
	self:clear()
end

function sanhuangdata:testActivity()
	local actInspect = require("game.sys.config_inspect.ActInspect").new()
	actInspect:run()
end

function sanhuangdata:testRomance()
--	local romanceInspect = require("game.sys.config_inspect.RomanceInspect").new()
--	romanceInspect:run()
end

function sanhuangdata:testShop()
	local shopInspect = require("game.sys.config_inspect.ShopInspect").new()
	shopInspect:run()
end

function sanhuangdata:testBattle()
	local shopInspect = require("game.sys.config_inspect.BattleInspect").new()
	shopInspect:run()
end


--创建一个测试按钮只用传递一个显示文本和一个点击函数即可,目前是自动排列
function sanhuangdata:createBtn(text, clickFunc)
    self.btn_num = self.btn_num + 1
    local xIndex =  self.btn_num %hangNums 
    xIndex = xIndex == 0 and hangNums or xIndex
    local yIndex = math.ceil( self.btn_num/hangNums )
    local xpos = GameVars.UIOffsetX +  (xIndex-1) * BTN_WIDTH  + 30

	local ypos = GameVars.height - GameVars.UIOffsetY-(yIndex-1) * BTN_HEIGHT - 70
    local sp = display.newNode():addto(self._root):pos(xpos,ypos):anchor(0,0)
    sp:size(130,50)
    display.newRect(cc.rect(0, 0,130, 50),
        {fillColor = cc.c4f(1,1,1,0.8), borderColor = cc.c4f(0,1,0,1), borderWidth = 1}):addto(sp)

    display.newTTFLabel({text = text, size = 20, color = cc.c3b(255,0,0)})
            :align(display.CENTER, sp:getContentSize().width/2, sp:getContentSize().height/2)
            :addTo(sp):pos(65,25)
    sp:setTouchedFunc(clickFunc,cc.rect(0,0,127,64))
end

function sanhuangdata:loadUIComplete()
	self:registerEvent()
end

function sanhuangdata:registerEvent()
end

function sanhuangdata:close()
	self:startHide()
end
return sanhuangdata
