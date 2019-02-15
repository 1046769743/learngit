local BulleTip = class("BulleTip", UIBase)
--公用 input输出框
--[[
    self.UI_inputModel,
    self.btn_1,
    self.btn_2,
    self.rect_1,
]]

function BulleTip:ctor(winName)
    BulleTip.super.ctor(self, winName)
end

function BulleTip:loadUIComplete()
	self:registerEvent()


    --self:setTouchedFunc(func, rect, touchSwallowEnabled, beganCallback, movedCallback)

   -- local coverLayer = WindowControler:createCoverLayer( -GameVars.UIOffsetX,GameVars.UIOffsetY,cc.c4b(0,0,0,0)):addto(self._root,-1)
        
   -- coverLayer:setTouchedFunc(c_func(self.pressClickEmpty, self),nil,true)

end 


--[[
设置字体多少
]]
function BulleTip:setTxt( str )
    self.txt_1:setVisible(true)
    if self.rich_1 then
        self.rich_1:setVisible(false)
    end
    
    local width = self.txt_1:getContainerBox().width
    -- local height,linenums,wid =FuncCommUI.getStringHeightByFixedWidth(str, self.rich_1:getFontSize(), nil, width)

    local lineLen = string.countTextLineLength( 170,20 )
    local lineCnt = #(string.turnStrToLineGroup(  str,lineLen))

    local baseTxtHeight = 60
    local height = (lineCnt)*23
    local fix = 2

    --echo(height,width,lineLen,lineCnt,"============")
     --self.txt_1:setContentSize(cc.size(width,height+20))
    self.txt_1:setTextHeight(height)
     
    self.txt_1:setPositionY(self.txt_1:getPositionY() + (height - baseTxtHeight) + fix)

    self.scale9_1:setContentSize(cc.size(209, height + 46))
    self.scale9_1:setPositionY(height + 46)


    self.txt_1:startPrinter(str, 20000)
end

function BulleTip:setAmigoTxt(str)
    -- echo("wwwwwwwwww"..str)
    local showNum = FuncDataSetting.getDataByConstantName("AmigoMsgMaxWords")
    local s = ""
    if string.len(str) > tonumber(showNum) then
        s = string.sub(str, 1, tonumber(showNum))
        s = s.."..."
    else
        s = str
    end
    -- echo("bbbbbbbbbb"..s)

    self.txt_1:setVisible(false)
    self.rich_1:setVisible(true)
    local width = self.rich_1:getContainerBox().width
    -- local height,linenums,wid =FuncCommUI.getStringHeightByFixedWidth(str, 20, nil, width)

    -- height = height + 10

    local lineLen = string.countTextLineLength( 170,20 )
    local lineCnt = #(string.turnStrToLineGroup(  s,lineLen))

    local height = (lineCnt)*24
    

    -- local height = s:getVirtualRendererSize().height
    -- local width = 170

    --echo(height,width,lineLen,lineCnt,"============")
     --self.txt_1:setContentSize(cc.size(width,height+20))
    -- self.rich_1:setTextHeight(height)

    if lineCnt > 2 then
        self.rich_1:pos(-57,height-30)
    else
        self.rich_1:pos(-57,height)
    end

    self.scale9_1:setContentSize(cc.size(width+28,height+36))
    self.scale9_1:pos(-71,height)


    self.rich_1:startPrinter(s, 20000)
end




--[[
注册事件
]]
function BulleTip:registerEvent()
	BulleTip.super.registerEvent()

end





return BulleTip
