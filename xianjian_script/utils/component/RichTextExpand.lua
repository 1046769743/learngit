
local RichTextExpand = class("RichTextExpand", function ()
    return display.newNode()
end)
--[[
--富文本 里面的文字默认是左上角,然后不要修改_richText的锚点,通过偏移修正富文本的坐标
--只有单行文本支持水平居中对其 ,高度居中对齐实现原理是  
拿到纯文本的高度 ,和这个rich配置的高度差 进行比较 然后居中.
]]



function RichTextExpand:ctor(cfgs)
    cfgs = cfgs or { }
    local txtCfg = cfgs[UIBaseDef.prop_config]
    txtCfg = txtCfg or { }
    self.txtCfg = txtCfg
    
    self.defaultSpeed = 10
    -- 每秒几个字

    self.ALIGNMENT_TYPE =
    {
        LEFT = 0,
        CENTRE = 0.5,
        RIGHT = 1,
    }

    self.defaultFont = UIBaseDef:turnFontName(txtCfg.fontName)

    self.defaultOpacity = 255
    self.defaultColor = cc.c3b(0, 0, 0)

    if txtCfg.color then
        self.defaultColor = numberToColor(txtCfg.color)
    end


    self.defaultFontSize = txtCfg.fontSize or 24

    local align, valign = UIBaseDef:turnAlignPoint(txtCfg.align, txtCfg.valign)
    -- local align, valign = UIBaseDef:turnAlignPoint("left", "up")

    local wid, hei = cfgs[UIBaseDef.prop_width] or 100, cfgs[UIBaseDef.prop_height] or 100
    hei = math.round(hei)
    if hei % 2 == 1 then
        hei = hei +1
    end


    self._wid = wid
    self._hei = hei
    self._halign = align
    self._valign = valign

    self.speed = self.defaultSpeed

    self._iconSize = nil

    if txtCfg.text then
        self:setString(txtCfg.text)
    end

--    dump(self._richText:getVirtualRendererSize(), "____")
    -- echo(cfgs[UIBaseDef.prop_width],cfgs[UIBaseDef.prop_height],"____尺寸")

    -- self:setContentSize(cc.size(self._wid, self._hei))
 

end

-- --重写获取尺寸
-- function RichTextExpand:getContentSize()
--     return {width = self._wid,height = self._hei }
-- end

--[[
    设置图片尺寸
    {
        width
        height
        scale ->可缺省
    }
]]

function RichTextExpand:setIconSize(iconSize)
    self._iconSize = iconSize
end

-- 初始化富文本 有个子对象是  富文本
function RichTextExpand:initRichText(textCfgList)
    if self._richText then
        self._richText:removeFromParent(true)
        self._richText = nil
    end

    self.textCfgList = textCfgList or self:parseRichText()

    self._richText = ccui.RichText:create()
    self._richText:setCascadeOpacityEnabled(true)
    self._richText:addto(self)
    self._richText:setContentSize(cc.size(self._wid, self._hei))
    self._richText:ignoreContentAdaptWithSize(false)

    self.tagCount = 1
    self.charCount = 1
    self.skip = false


    local offsetX = 0

    --判断是单行还是多行 
    local txtWid = FuncCommUI.getStringWidth(self._onlyChars,self.defaultFontSize)
    local txtHeight,numLines = FuncCommUI.getStringHeightByFixedWidth(self._onlyChars, self.defaultFontSize, nil, self._wid)
    
    self.txtWid = txtWid
    self.txtHeight = txtHeight
    self.numLines = numLines
    
    local xoffset = 0
    local yoffset = 0
    local isMultline = false
    --如果大于自己的宽度了 这里给2像素的偏差
    if numLines > 1 then
        xoffset = 0
        isMultline = true
    else
        xoffset = (self._wid - txtWid) * self._halign
    end

    xoffset = xoffset - self._halign * 2
    yoffset = -(self._hei - txtHeight) * (1-self._valign)
    self._richText:pos(self._wid / 2 + xoffset , -self._hei/2 + yoffset + 2 )
    -- echo(txtWid,self._wid,self._onlyChars,"____ajah",isMultline)
end

function RichTextExpand:setHorizontalAlign(align)
    local halign, valign = UIBaseDef:turnAlignPoint(self:turnAlign(align),self.txtCfg.align)
    self:updateRichPos(halign, valign)
end

function RichTextExpand:setVerticalAlign(align)
    local halign, valign = UIBaseDef:turnAlignPoint(self.txtCfg.align, self:turnAlign(align))
    self:updateRichPos(halign, valign)
end

function RichTextExpand:updateRichPos(halign, valign)
    --判断是单行还是多行 
    local txtWid = self.txtWid
    local txtHeight = self.txtHeight
    local numLines = self.numLines

    local xoffset = 0
    local yoffset = 0
    --如果大于自己的宽度了 这里给2像素的偏差
    if numLines > 1 then
        xoffset = 0
    else
        xoffset = (self._wid - txtWid) * halign
    end

    xoffset = xoffset - halign * 2
    yoffset = -(self._hei - txtHeight) * (1-valign)
    self._richText:pos(self._wid / 2 + xoffset , -self._hei/2 + yoffset + 2 )
end

function RichTextExpand:turnAlign(align)
     local alignStr = nil
    if align == cc.TEXT_ALIGNMENT_LEFT then
        alignStr = "left"
    elseif align == cc.TEXT_ALIGNMENT_CENTER then
        alignStr = "center"
    elseif align == cc.TEXT_ALIGNMENT_RIGHT then
        alignStr = "right"
    end

    return alignStr
end

-- 解析富文本 静态方法
function RichTextExpand:parseRichText(str)
    -- local str = "我是<color = 0000ff>小明<->,多来点钱,<color=0000ff>大名<->钱不够--少给点"
    -- 有图片的 local str =  = "[tupian][kaiwanxiao]我是<color = 0000ff>小明<->,多来点钱,<color=0000ff>大名<->钱不够--少给点"
    str = str or self.text
    local resultObj = {}

    --把换行符单独作为一个特殊的 字符 作为一组
    str = string.gsub(str,"\\n","\n")
    str = string.gsub(str,"\n","<newline=1>\n<->")

    local req = "<(.-)>(.-)(<%->)"
    local pos =0
    
	local length = string.len(str)
	local info1 

    local onlyChar = ""

	local reqFunc = function (  )
		return string.find(str,req,pos )
	end

	for st,sp,p1,p2,p3 in reqFunc do
		info1 = {char= string.sub(str, pos, st - 1)  }
        table.insert(resultObj, info1)
        local info2 = {char = p2 }
        if p1 then
        	p1 = string.gsub(p1, "[%s\n\r\t]+", "")

        	local richTxt = p1
        	local richArr = string.split(p1,",")  --p1.split(",")
        	for k,v in pairs(richArr) do
        		local childArr =string.split(v,"=")
        		info2[childArr[1]] = childArr[2]
        	end
        	table.insert(resultObj, info2)
		end
        pos = sp+1
	end
	
    if pos < string.len(str) then
    	info1 = {char= string.sub(str, pos)  }
    	table.insert(resultObj, info1)
    end

    resultObj = self:parseRichTextSprite(resultObj)
    self._onlyChars = ""
    for i,v in ipairs(resultObj) do
        self._onlyChars = self._onlyChars..v.char
    end
    -- self._onlyChars = onlyChar
    return resultObj,self._onlyChars
end
--解析文字中的图片
function RichTextExpand:parseRichTextSprite(resultObj)
    if resultObj == nil then
        return resultObj
    end
    local newresultObj = {}
    -- 注释的先不去掉  wk
    for i=1,#resultObj do
        -- local str = resultObj[i]
        -- if resultObj[i].color == nil then
            local info = resultObj[i]
            local tables = self:jiexitext(info.char)
            info.char = nil
            for _i=1,#tables do
                local newInfo = tables[_i] 
                for kk,vv in pairs(info) do
                     newInfo[kk]= vv
                end
                -- if resultObj[i].color ~= nil then
                --     tables[_i].color = resultObj[i].color
                -- end
                table.insert(newresultObj,newInfo)

            end
            -- i = i + #tables -1
        -- else
        --     table.insert(newresultObj,resultObj[i])
        -- end
    end
    return newresultObj
end

function RichTextExpand:jiexitext(text)
    local str = text ---"<kaishi1>时间等会三<ksj>sdsad<kaishi2><kaishi3>"
    local newresultObj = {}
    local file = true
    while file do   
        local index = string.find(str,"%[") 
        local indey = string.find(str,"%]") 
        if string.len(str) ~= 0 then
            -- local isDpng string.sub(str,index+1,indey-1)
            -- if string.sub(name,-4,-1) ~= ".png" then

            -- end
            if index ~= nil and indey ~= nil  then
                -- local isDpng string.sub(str,index+1,indey-1)
                -- if string.sub(name,-4,-1) ~= ".png" then
                if index == 1 then
                -- local newstr = string.sub(str,0,index)
                    local newstr = string.sub(str,index+1,indey-1)
                    if string.sub(newstr,-4,-1) == ".png" then
                        local tables = {}
                        tables.name = newstr
                        tables.image = 1
                        tables.char = "哈哈"
                        table.insert(newresultObj,tables)
                        str = string.sub(str,indey+1)
                    elseif string.sub(newstr,-5,-1) == "_line" then
                        local tables = {}
                        tables.char = string.sub(newstr,0,-6)
                        tables.line = true
                        table.insert(newresultObj,tables)
                        str = string.sub(str,indey+1)
                    else
                        local newstr = string.sub(str,0,indey)
                        local tables = {}
                        tables.char = newstr
                        table.insert(newresultObj,tables)
                        str = string.sub(str,indey+1)
                    end
                else
                    local newstr = string.sub(str,0,index-1)
                    local tables = {}
                    tables.char = newstr
                    -- echo("======newstr=========",newstr)
                    -- dump(tables,"000000")
                    table.insert(newresultObj,tables)
                    str = string.sub(str,index)
                end
            else
                local tables = {}
                tables.char = str
                table.insert(newresultObj,tables)
                file = false 
            end
        else
            file = false 
        end
    end
    
    -- echo("======index===indey===========",index,indey)
    -- dump(newresultObj,"11111111111111111")
    return newresultObj
end

-- 将富文本转成打印机格式
function RichTextExpand:content2PrinterFormat(richTxtArr)
    local printerRichCharArr = {}
    for i=1,#richTxtArr do
        local richTxt = richTxtArr[i]
        if richTxt.char then
            local richCharArr = string.split2Array(richTxt.char)
            local color = richTxt.color
            for i=1,#richCharArr do
                local richChar = {}
                
                if richTxt.rich ~= nil then
                    for k,v in pairs(richTxt) do
                        richChar[k] = v
                    end
                end
                richChar.char = richCharArr[i]
                richChar.color = color
                printerRichCharArr[#printerRichCharArr+1] = richChar
            end
        elseif richTxt.image and richTxt.image == 1 then
            printerRichCharArr[#printerRichCharArr+1] = richTxt
        end
    end

    return printerRichCharArr
end




-- 开启打字机
function RichTextExpand:startPrinter(text,speed)
--	self:ignoreContentAdaptWithSize(false)
	
	self.text = text
	self:initRichText()
	self.textCfgList = self:content2PrinterFormat(self.textCfgList)
	self.speed = speed

	local frame = GameVars.GAMEFRAMERATE / self.speed 
	if frame < 1 then
        self.delay = 1 / GameVars.GAMEFRAMERATE
    else
        self.delay = frame / GameVars.GAMEFRAMERATE
    end

	self:createText()
end

--[[
    设置富文本配置列表
    如：
    "self.textCfgList-----------" = {
    1 = {
         "char"  = "提升防御类奇侠5%生命和物防"
         "color" = "8C9695"
     }
    }
]]
function RichTextExpand:setTextCfgList(textCfgList,size)
    self._iconSize = size or self._iconSize
    self:initRichText(textCfgList)

    for i=1,#self.textCfgList do
        local cfg = self.textCfgList[i]
        self:createElementText(cfg)
    end
end

--直接显示
function RichTextExpand:setString(text,size)
	self.text = text
	--self:ignoreContentAdaptWithSize(false)
	-- 保留size为了兼容以前的方法
    self._iconSize = size or self._iconSize
	self:initRichText()

	for i=1,#self.textCfgList do
		local cfg = self.textCfgList[i]
		self:createElementText(cfg)
	end

end


-- 跳过打印机
-- skipNum 跳过几个字 不填则跳过所有
function RichTextExpand:skipPrinter(skipNum)
    local skipNum = skipNum or #self.textCfgList
    local desNum = self.charCount + skipNum

    if desNum >= #self.textCfgList then
        desNum = #self.textCfgList
    	self.skip = true
    end

	for i=self.charCount,desNum do
		local cfg = self.textCfgList[i]
		self:createElementText(cfg)
        
        self.charCount = self.charCount + 1
		self.tagCount = self.tagCount + 1
	end
end

--[[
文本打印完成
]]
function RichTextExpand:registerCompleteFunc(callBack)
    self.__printComplete= callBack
end


-- 创建文本
function RichTextExpand:createText()
	if self.charCount > #self.textCfgList or self.skip == true then
        if self.__printComplete then
            self.__printComplete()
        end
		return
	end

	local cfg = self.textCfgList[self.charCount]
	self:createElementText(cfg)

	self.charCount = self.charCount + 1
	self.tagCount = self.tagCount + 1

	self:delayCall(c_func(self.createText, self),self.delay)
end

-- 创建文本元素
function RichTextExpand:createElementText(cfg)
	local char = cfg.char
	local opacity = tonumber(cfg.opacity) or self.defaultOpacity
	local fontName = cfg.font or self.defaultFont
	local fontSize = cfg.size or self.defaultFontSize
	local color
	if cfg.color then
		color = self:createColor(cfg.color)
	else
		color = self.defaultColor

	end
	-- self:createColor(colorStr)
    self.touchtext = {}
	if char == "\n" then
		self:addNewLine()
    elseif cfg.br then
        self:addBlankLine()
	else
        if cfg.line then
            -- echo("1111111111111111111111111111")
            local richTextEle = self:getRichElementLinkLineNode(self.tagCount,color,opacity,char,fontName,fontSize)
            self:pushBackElement(richTextEle)
        elseif cfg.image ~= nil then 
            local imagename = cfg.name
            if imagename ~= nil then
                local filePath = FuncRes.icon(imagename)
                local sprite = display.newSprite(filePath)
             
                -- if iconsize then
                --     sprite:setScale(iconsize.scale)
                --     sprite:setContentSize(cc.size(iconsize.width,iconsize.height))--self.defaultFontSize+1,self.defaultFontSize+1))
                -- end

                if self._iconSize then
                    local scaleX = 1
                    local scaleY = 1
                    local width = self._iconSize.width or sprite:getContentSize().width
                    local height = self._iconSize.height or sprite:getContentSize().height
                    
                    if self._iconSize.scale then
                        scaleX = self._iconSize.scale
                        scaleY = self._iconSize.scale
                    else
                        if self._iconSize.width then
                            scaleX = width / sprite:getContentSize().width
                        end

                        if self._iconSize.height then
                            scaleY = height / sprite:getContentSize().height
                        end
                    end

                    sprite:setScaleX(scaleX)
                    sprite:setScaleY(scaleY)
                    sprite:setContentSize(cc.size(width, height))
                end

                local richTeximage = self:getRichElementCustomNode(self.tagCount, color, opacity, sprite)
                self:pushBackElement(richTeximage)
            else
                local richTextEle = self:getRichElementText(self.tagCount,color,opacity,"<"..cfg.name..">",fontName,fontSize)
                self:pushBackElement(richTextEle)
            end
        elseif cfg.image == nil then  
            local richTextEle = self:getRichElementText(self.tagCount,color,opacity,char,fontName,fontSize)
            self:pushBackElement(richTextEle)
        end
	end
end
--获取富文本的大小
function RichTextExpand:getVirtualRendererSize()
    return self._richText:getVirtualRendererSize()
end

function RichTextExpand:insertElement( element,zodel )
    self._richText:insertElement(element,zodel) 
end

function RichTextExpand:pushBackElement( element )
	self._richText:pushBackElement(element) 
end

function RichTextExpand:createColor(colorStr)
	local r = string.sub(colorStr,1,2)
	local g = string.sub(colorStr,3,4)
	local b = string.sub(colorStr,5,6)

	local rc = string.format("%d","0x" .. r)
	local gc = string.format("%d","0x" .. g)
	local bc = string.format("%d","0x" .. b)

	-- print("rgb=",rc,gc,bc)
	return cc.c3b(rc,gc,bc)
end

function RichTextExpand:getRichElementText(tag, color, opacity, text, fontName, fontSize)
	local re = ccui.RichElementText:create(tag, color, opacity, text, fontName, fontSize)
	
	return re
end

function RichTextExpand:getRichElementImage(tag, color, opacity, filePath)
	local reimg = ccui.RichElementImage:create(tag, color, opacity, filePath)
	-- reimg:setScale(0.5)
	return reimg
end

function RichTextExpand:getRichElementCustomNode(tag, color, opacity, nd)
	
    local recustom = ccui.RichElementCustomNode:create(tag, color, opacity, nd)
    
    return recustom
end


--获取带下划线的文本
function RichTextExpand:getRichElementLinkLineNode(tag, color, opacity, text, fontName, fontSize)
	local re = display.newTTFLabel({
	    text = text,
	    font = fontName,
	    size = fontSize,
	    color = color,
	    align = cc.TEXT_ALIGNMENT_LEFT,
	    valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
	})
    re:setAnchorPoint(cc.p(0,0))
    re:opacity(opacity)
    --re:pos(pos[1],-pos[2])
    
    local linkre =cc.LayerColor:create(cc.c4b(color.r,color.g,color.b,opacity))
    linkre:setContentSize(cc.size(re:getContentSize().width,1))
    linkre:setAnchorPoint(cc.p(0,1))
    linkre:opacity(opacity)
	
	local node = display.newNode()
	node:addChild(re)
	node:addChild(linkre)
	node:setContentSize(re:getContentSize())

    --[[
    -- 测试代码
    local color = color or cc.c4b(255,0,0,120)
    local layer = cc.LayerColor:create(color)
    node:addChild(layer)
    node:setTouchEnabled(true)
    node:setTouchSwallowEnabled(true)
    layer:setContentSize(re:getContentSize())
    ]]

	local recustom = ccui.RichElementCustomNode:create(tag, color, opacity, node)
	return recustom
end

--[[
    换行
]]
function RichTextExpand:addNewLine()
	local node = display.newNode()
	node:setContentSize(cc.size(self._wid, 0.1))
	local recustom = ccui.RichElementCustomNode:create(0, cc.c3b(0, 0, 0), 255, node)
	self:pushBackElement(recustom)
end

--[[
    创建空白行
]]
function RichTextExpand:addBlankLine()
    local node = display.newNode()
    node:setContentSize(cc.size(self._wid, self._hei))
    local recustom = ccui.RichElementCustomNode:create(0, cc.c3b(0, 0, 0), 255, node)
    self:pushBackElement(recustom)
end

function RichTextExpand:getContainerBox(  )
	return {x=0,y = -self._hei,width = self._wid,height = self._hei}
end

--一定要先设置textWidth 在设置setString
function RichTextExpand:setTextWidth( wid )
    self._wid = wid
end

function RichTextExpand:setTextHeight( hei )
    self._hei = hei
end

--获取尺寸
function RichTextExpand:getFontSize()
    return self.defaultFontSize
end


--根据str 自动修正尺寸,同时适配对齐 返回新的宽高
-- adjustXOffset x坐标修正系数主要是右对齐的文本,右边可能经常会有一字节填充不满,单行的文本没有修正系数
-- 这个值会根据对其方式去乘以修正系数,左对齐系数是adjustXOffset*0,中是adjustXOffset*0.5,右对齐是adjustXOffset*1
--adjustHeight 高度修正. 默认为0
function RichTextExpand:setStringByAutoSize( targetStr,adjustHeight,adjustXOffset )
    if not self._initPosX then
        self._initPosX = self:getPositionX()
        self._initWid = self._wid
    end
    local richWidth =  self._initWid
    
    
    self:setString(targetStr)
    
    
    
    local height,lengthnum,wid = FuncCommUI.getStringHeightByFixedWidth(self._onlyChars,self.defaultFontSize,self.defaultFont,self._initWid)

    if lengthnum > 1 then
        self:setTextWidth(richWidth )
    else
        adjustXOffset =0
        wid = FuncCommUI.getStringWidth(self._onlyChars, self.defaultFontSize,self.defaultFont )
        self:setTextWidth(wid)
    end
    adjustXOffset = adjustXOffset or 0
    --如果是水平靠右对齐
    if self._halign == 1 then
       self:setPositionX(self._initPosX + (self._initWid - wid +adjustXOffset) *self._halign   ) 
    end
    adjustHeight =  adjustHeight or 0
    height = adjustHeight + height
    self:setTextHeight(height)
    self:setString(targetStr)
    return wid,height

end


return RichTextExpand