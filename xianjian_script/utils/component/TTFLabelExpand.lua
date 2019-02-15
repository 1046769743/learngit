local TTFLabelExpand = class("TTFLabelExpand", function ( )
    return display.newNode()
end
)


local txtOffestX =4
local txtOffestY =2         --ttf字体变化这个值需要动态修改

-- if device.platform =="mac" then
--     txtOffestY = 8
-- end

local sysTxtOffestX = 1
local sysTxtOffestY = 2     --系统字体y偏移



--如果有投影或者 外发光  需要单独判断 因为win32还没实现
TTFLabelExpand.childLabels   =nil  


function TTFLabelExpand:ctor( cfgs )
    local txtCfg = cfgs[UIBaseDef.prop_config]
    local align ,valign = UIBaseDef:turnAlign(txtCfg.align, txtCfg.valign)

    local ccfg = cfgs[UIBaseDef.prop_config]

    self.outLineLength = 0
    if ccfg.outLineSize and ccfg.outLineSize > 0 then
        self.outLineLength = ccfg.outLineSize
    end

    --这里要对文本的高度做修正  文本高度不能是奇数, 否则会被切1像素
    local hei = cfgs[UIBaseDef.prop_height]
    hei = math.floor(hei)
    if hei % 2 ==1 then
        hei = hei +1
        cfgs[UIBaseDef.prop_height] = hei
    end


    local params = {
        font = UIBaseDef:turnFontName(txtCfg.fontName),
        text = txtCfg.text or "",
        size = txtCfg.fontSize or 24,
        align = align,
        valign = valign,
        color = numberToColor(txtCfg.color or 0),
        dimensions = cc.size(cfgs[UIBaseDef.prop_width],hei+self.outLineLength*2 +txtOffestY*2),
        kerning = txtCfg.kerning or 0,
        leading =  txtCfg.leading or 0
    }

    self.cfgs = cfgs
    self.params = params
    self.childLabels = {}

    local alignP ,valignP = UIBaseDef:turnAlignPoint(txtCfg.align, txtCfg.valign)
    self._halign = alignP
    self._valign = valignP

    --根据对齐方式 计算偏移x
    if align == cc.TEXT_ALIGNMENT_LEFT then
        self._fontOffsetX = 0
    elseif align == cc.TEXT_ALIGNMENT_CENTER then
        self._fontOffsetX = -1
    else
        self._fontOffsetX = -2
    end


    if self.params.font ==GameVars.systemFontName then
        self._fontOffsetY = sysTxtOffestY
    else
        self._fontOffsetY = txtOffestY
    end

    --判断是否是自动匹配
    params.color.a = (cfgs.a or 1) *255
	self.origin_color = params.color
    --组件配置
    
    --[[if device.platform  == "android"  then
        echo("params.font=",params.font)
        params.font = "fnt/" .. params.font .. ".TTF";
    end--]]
    local label = display.newTTFLabel(params)
    self.baseLabel = label
    label:setAnchorPoint(cc.p(0,1))
    -- label:pos(self._fontOffsetX,self.params.dimensions.height +self._fontOffsetY)
    label:pos(self._fontOffsetX,self:getOffsetY() )
    label:setCascadeOpacityEnabled(true)
    label:setLineBreakWithoutSpace(true)
    label.baseColor = params.color

    
    -- label:setAdditionalKerning(-30)
    -- echo(label:getLineHeight(),params.size,"___行高, 尺寸")

    -- label:setLineHeight(label:getLineHeight() - 50 )



    -- label:setMaxLineWidth(self.params.dimensions.width)
    table.insert(self.childLabels, label)
    -- ccfg.outLine = 0x0000ff
    
    if self.outLineLength > 0 then
        
        self:setOutLine(numberToColor(ccfg.outLine or 0),ccfg.outLineSize,ccfg.outLineAlpha )
        -- self:setColor(numberToColor(txtCfg.color or 0))
    end

    if ccfg.shadowPos  then
        ccfg.shadowPos[1] = tonumber(ccfg.shadowPos[1])
        ccfg.shadowPos[2] = tonumber(ccfg.shadowPos[2])
        if  ccfg.shadowPos[1]> 0 or ccfg.shadowPos[2] > 0  then
            self:setShadow(numberToColor(ccfg.shadow or 0),ccfg.shadowPos,ccfg.shadowAlpha )
        end
    end
    if self.params.kerning and self.params.kerning ~=0 then
        label:setAdditionalKerning(self.params.kerning)
    end
    if self.params.leading and self.params.leading ~=0 then
        local lineHeight = label:getLineHeight()
        label:setLineHeight(lineHeight +self.params.leading)
    end
    -- self:setString(ccfg.text)
    label:addto(self)
    -- self:setContentSize(cc.size(self.params.dimensions.width,self.params.dimensions.height))
    -- FilterTools.setGrayFilter(self)
end


function TTFLabelExpand:getOffsetY(  )
    if true then
        return txtOffestY +2+ self.outLineLength
    end
    if device.platform =="mac" then
        local fontSize = self.params.size
        --目前mac暂时用这一版调配出来的数值 做偏移
        local offsetY = self._fontOffsetY + math.pow( fontSize/24,4 )/1.8 +1
        return offsetY

    elseif(device.platform=="android")then
         local      _offsetY=0;
         if(self.params.font ==GameVars.systemFontName)then
                 _offsetY= math.pow(self.params.size/24,6.28)/1.532+1;
         end
         return  self._fontOffsetY+_offsetY;
    else
        return self._fontOffsetY
    end

end


function TTFLabelExpand:getContainerBox()
    return {x=0,y=-self.params.dimensions.height,width=self.params.dimensions.width,height=self.params.dimensions.height}
end


function TTFLabelExpand:getStringNumLines(  )
    return self.childLabels[1]:getStringNumLines()
end

function TTFLabelExpand:getStringLength(  )
    return self.childLabels[1]:getStringLength()
end

local posWay = { {-1,0},{1,0},{0,1},{0,-1}  }

function TTFLabelExpand:getContentSize()
    local ss = cc.size(self.params.dimensions.width,self.params.dimensions.height)
    return ss
end


--给文本设置滤镜
function TTFLabelExpand:setLabelFtParams( ftParams )
    
    for i,v in ipairs(self.childLabels) do
        local turnColor =  FilterTools.turnFilterColor(v.baseColor, ftParams )
        v:setTextColor(turnColor)
        v:opacity(turnColor.a)
    end

    --如果有外发光的  那么让外发光 也变化下
    if self.outLineLength > 0 then
        self.baseLabel:enableOutline(FilterTools.turnFilterColor(self.baseLabel._outLineColor, ftParams ),self.outLineLength)
    end

end




function TTFLabelExpand:setColor(color)
    if not color.a then
        color.a = 255
    end
   self:setTextColor(color)
end

function TTFLabelExpand:setTextColor(color )
     local label = self.childLabels[1]
     if not color.a then
         color.a = 255
     end
    label.baseColor = color
    label:setTextColor(color)
end

function TTFLabelExpand:getOriginColor()
	return self.origin_color
end



function TTFLabelExpand:setTextHeight( hei )
    for i,v in ipairs(self.childLabels) do
        v:setHeight(hei)
    end
    self.params.dimensions.height = hei
end

function TTFLabelExpand:setTextWidth( wid )
    for i,v in ipairs(self.childLabels) do
        v:setWidth(wid)
    end
    self.params.dimensions.width = wid
end

function TTFLabelExpand:setOutLine( color,length,alpha )
    if not length or length ==0 then
        return
    end
    alpha = alpha or 1
    if length > 2 then
        length = 2
    end
    self.outLineLength = length
    -- length = 5
    color.a = alpha * 255
    --如果是ios或者android
    -- if (device.platform  == "ios" or device.platform  =="android" )  then
     if true then
        local c4b = cc.c4b(color.r,color.g,color.b,alpha *255)
        self.baseLabel:enableOutline(c4b,length)

        self.baseLabel._outLineColor = c4b

    else
        for i=1,4 do
            local ttflabel = display.newTTFLabel(self.params):addto(self)
            ttflabel:setTextColor(color)
            ttflabel.baseColor = color
            local way = posWay[i]
            -- ttflabel:pos(way[1]*length + txtOffestX,way[2]*length + txtOffestY)
            -- ttflabel:setAnchorPoint(cc.p(0,0))

            ttflabel:setAnchorPoint(cc.p(0,1))
            -- ttflabel:pos(way[1]*length + self._fontOffsetX,self.params.dimensions.height +way[2]*length + self._fontOffsetY )
            ttflabel:pos(way[1]*length + self._fontOffsetX,way[2]*length + self:getOffsetY() )


            ttflabel:setCascadeOpacityEnabled(true)
            ttflabel:setLineBreakWithoutSpace(true)
            ttflabel:opacity(alpha*255)
            if self.params.kerning and self.params.kerning ~=0 then
                label:setAdditionalKerning(self.params.kerning)
            end
			ttflabel._is_outline = true
            table.insert(self.childLabels, ttflabel)
        end
    end
end



function TTFLabelExpand:setChildStr( text )
    for i,v in ipairs(self.childLabels) do
        v:setString(text)
    end
end

function TTFLabelExpand:setAdditionalKerning( space )
    if self.params.kerning and self.params.kerning == space then
        return
    end

    for i,v in ipairs(self.childLabels) do
        v:setAdditionalKerning(space)
    end
end

function TTFLabelExpand:setLineHeight( h )
    for i,v in ipairs(self.childLabels) do
        v:setLineHeight(h)
    end
end

-- 获取行高(取最大的)
function TTFLabelExpand:getLineHeight()
    local max = -1
    for i,v in ipairs(self.childLabels) do
        local h = v:getLineHeight()
        max = three(h > max, h, max)
    end

    return max
end

function TTFLabelExpand:setString(text )
    -- local lineLength = string.countTextLineLength( self.params.dimensions.width,self.params.size ) 
    -- local turnStr = string.turnStrToLineStr(text,lineLength)
    self._labelString = text
    self:setChildStr(text)
end


function TTFLabelExpand:setShadow( color,pos ,alpha)
    if not pos or (pos[1]==0 and pos[2] ==0) then
        return
    end

     alpha = alpha or 1
     if device.platform  == "ios" or device.platform  =="android" or true  then
--    if  false then
        local c4b = cc.c4b(color.r,color.g,color.b,alpha *255)
        local sz = cc.size(pos[1],-pos[2])
        self.baseLabel:enableShadow(c4b,sz)
        self.baseLabel._shadowInfo = {c4b,sz}
    else
        local ttflabel = display.newTTFLabel(self.params):addto(self)
        ttflabel:setColor(color)
        ttflabel.baseColor = color
        ttflabel:setAnchorPoint(cc.p(0,0))
        ttflabel:setCascadeOpacityEnabled(true)
        ttflabel:setLineBreakWithoutSpace(true)
        ttflabel:opacity(alpha*255)
        if self.params.kerning and self.params.kerning ~=0 then
            label:setAdditionalKerning(self.params.kerning)
        end

        ttflabel:pos(pos[1] + self._fontOffsetX,-pos[2] + self:getOffsetY() )
        table.insert(self.childLabels, ttflabel)
    end
end

-- 初始化默认值
function TTFLabelExpand:initData()
    self.defaultSpeed = 10              --每秒几个字
    self.tagCount = 1
    self.charCount = 1
    self.skip = false
end


function TTFLabelExpand:startPrinter(text,speed)
    -- 初始化默认值
    self:initData()
    self.text = text
    
    self.speed = speed
    -- echo("self.text=",self.text)
    -- 数据格式转换
    self.textCfgList = string.split2Array(self.text)

    local frame = GameVars.GAMEFRAMERATE / self.speed
    if frame < 1 then
        self.delay = 1 / GameVars.GAMEFRAMERATE
    else
        self.delay = frame / GameVars.GAMEFRAMERATE
    end

    self:createText()
end

-- 跳过打印机
function TTFLabelExpand:skipPrinter()
    self.skip = true

    local str = table.concat(self.textCfgList,"",1,#self.textCfgList)
    self:setString(str)
end

-- 创建文本
function TTFLabelExpand:createText()
    if self.charCount > #self.textCfgList or self.skip == true then
        return
    end

    -- local char = self.textCfgList[self.charCount]
    -- self:createElementText(cfg)
    local str = table.concat(self.textCfgList,"",1,self.charCount)
    self:setString(str)

    self.charCount = self.charCount + 1
    self.tagCount = self.tagCount + 1

    self:delayCall(c_func(self.createText, self),self.delay)
end


--获取每行支持的字符数量
function TTFLabelExpand:getLineLength(  )
    local fontSize = self.params.size
    local wid = self.params.dimensions.width
    return  string.countTextLineLength( wid,fontSize )

end


--判断一个文本是不是单行文本
function TTFLabelExpand:checkIsOneLine(  )
    local wid = FuncCommUI.getStringWidth(self._labelString, self.params.size, self.params.font)
    --如果小于文本的宽度 那么表示是 单行文字
    if wid <= self.params.dimensions.width then
        return true
    end
    --否则是多行文字
    return false
end

function TTFLabelExpand:setAlignment(aligment)
    for k,v in pairs(self.childLabels) do
        v:setAlignment(aligment);
    end
end

function TTFLabelExpand:getFontSize()
	return self.params.size
end

function TTFLabelExpand:getFont()
	return self.params.font
end

--根据str 自动修正尺寸,同时适配对齐 返回新的宽高
-- adjustXOffset x坐标修正系数主要是右对齐的文本,右边可能经常会有一字节填充不满,单行的文本没有修正系数
-- 这个值会根据对其方式去乘以修正系数,左对齐系数是adjustXOffset*0,中是adjustXOffset*0.5,右对齐是adjustXOffset*1
--adjustHeight 高度修正. 默认为0
function TTFLabelExpand:setStringByAutoSize( targetStr,adjustHeight,adjustXOffset )
    if not self._initPosX then
        self._initPosX = self:getPositionX()
        self._initWid = self.params.dimensions.width
    end
    local richWidth =  self._initWid
    
    
    local height,lengthnum,wid = FuncCommUI.getStringHeightByFixedWidth(targetStr,self.params.size,self.params.font,richWidth)

    if lengthnum > 1 then
        self:setTextWidth(richWidth )
    else
        adjustXOffset =0
        wid = FuncCommUI.getStringWidth(targetStr,self.params.size,self.params.font )
        self:setTextWidth(wid)
    end
    adjustXOffset = adjustXOffset or 0
    print(targetStr,self._halign,self._initWid,wid,"______aaaa")
    --如果是水平靠右对齐
    -- if self._halign == 1 then
       self:setPositionX(self._initPosX + (self._initWid - wid +adjustXOffset) *self._halign   ) 
    -- end
    adjustHeight =  adjustHeight or 0
    height = adjustHeight + height
    self:setTextHeight(height)
    self:setString(targetStr)
    return wid,height
end

return TTFLabelExpand
