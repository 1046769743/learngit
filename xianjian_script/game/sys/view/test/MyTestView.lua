local MyTestView = class("MyTestView", UIBase);

--[[
    self.UI_MyTest,
    self.txt_goodsshuliang,
]]

function MyTestView:ctor(winName)
    MyTestView.super.ctor(self, winName);
end

function MyTestView:loadUIComplete()
	self:registerEvent();

	self.richTxtArr = {
        {content="小明",rich={color="FF0000",font="",size=14}},
        {content="充值"},
        {content="10000",rich={color="FF0000",font="",size=14}},
        {content="仙玉"}
    }

	self.printTextArr = {
		{char="玩",color="255,255,255",font=GameVars.fontName,size=25},
		{char="家",color="255,255,255",font=GameVars.fontName,size=25},
		{char="小",color="255,255,255",font=GameVars.fontName,size=25},
		{char="明",color="255,255,255",font=GameVars.fontName,size=25},
		{char="充",color="255,255,255",font=GameVars.fontName,size=25},
		{char="1000000",color="255,0,0",font=GameVars.fontName,size=25},

		{char="玩",color="255,255,255",font=GameVars.fontName,size=25},
		{char="家",color="255,255,255",font=GameVars.fontName,size=25},
		{char="\n",color="255,255,255",font=GameVars.fontName,size=25},

		{char="小",color="255,255,255",font=GameVars.fontName,size=25},
		{char="明",color="255,255,255",font=GameVars.fontName,size=25},
		{char="充",color="255,255,255",font=GameVars.fontName,size=25},
		{char="1000000",color="255,0,0",font=GameVars.fontName,size=25},
		{char="元",color="255,255,255",font=GameVars.fontName,size=25},
	}

	self.defaultFont =  GameVars.fontName
	self.defaultFontSize = 25
	self.defaultOpacity = 255

	self:updateUI()
end 

function MyTestView:registerEvent()
	MyTestView.super.registerEvent();

	self.btn_back:setTap(c_func(self.press_btn_back, self));
	self.btn_skip:setTap(c_func(self.press_btn_skip, self));
end

function MyTestView:updateUI()
	-- self:createPrintCharText()

	-- 富文本实现1
	-- self.printer = RichTextPrinter.new()
	-- self.printer:initRichTextPrinter(self.printTextArr,300,-300,450,300,10)
	-- self:addChild(self.printer)

	-- 富文本实现2
	-- self.printer = RichTextExpand.new()
	-- self:addChild(self.printer)
	-- self.printer:startPrinter(self.printTextArr, 10)
	-- self.printer:pos(300,-300)

	-- 富文本实现2
	local content = "<color=0000FF,size=24>小明<->充值<color=00FF00,size=24>10000<->仙玉"
	self.richText = RichTextExpand.new()
	self.richText:setContentSize(cc.size(450, 300))
	self:addChild(self.richText)
	self.richText:setText(content)
	self.richText:startPrinter(10)
	self.richText:pos(300,-300)

	-- 普通文本实现
	self.txt_test:setText("玩家小明充值10000仙玉\n;玩家小明充值10000仙玉;")
	self.txt_test:startPrinter(10)
end

function MyTestView:press_btn_back()
	self:startHide()
end

function MyTestView:press_btn_skip()
	echo("跳过")

	-- self:skip()
	-- self.printer:skipPrint()
	self.richText:skipPrinter()
	self.txt_test:skipPrinter()
end

function MyTestView:createPrintCharText()
	local richText =  RichTextExpand.new():pos(300,-300)
	richText:ignoreContentAdaptWithSize(false)
	richText:setContentSize(cc.size(450, 300))
    self:addChild(richText)

    self.richText = richText

    local tagCount = 1
    local charCount = 1

    self.createCharText = function()
    	if charCount > #self.printTextArr or self.skip == true then
    		return
    	end
    	local cfg = self.printTextArr[charCount]
    	self:createElementText(richText,tagCount,cfg)
    	tagCount = tagCount + 1
    	charCount = charCount + 1
    	WindowControler:globalDelayCall( self.createCharText,10/GameVars.GAMEFRAMERATE )


    	self.tagCount = tagCount
    	self.charCount = charCount
	end

	self.createCharText()
end

function MyTestView:skip()
	self.skip = true

	local tagCount = self.tagCount
	local charCount = self.charCount

	for i=charCount,#self.printTextArr do
		local cfg = self.printTextArr[i]
		self:createElementText(self.richText,tagCount,cfg)
	end
end

-- 创建文本元素
function MyTestView:createElementText(richText,tag,cfg)
	local char = cfg.char
	local color = cfg.color
	local opacity = cfg.opacity or 255
	local fontName = cfg.font or GameVars.fontName
	local fontSize = cfg.fontSize or 20

	local richTextEle = richText:getRichElementText(tag,color,opacity,char,fontName,fontSize)
   	richText:pushBackElement(richTextEle)
end

-- ====================
function MyTestView:createPrintCharText_1()
	local richText =  RichTextExpand.new():pos(300,-200)
	richText:ignoreContentAdaptWithSize(false)
	richText:setContentSize(cc.size(400, 300))
	
    self:addChild(richText)

    local tagCount = 1
    local createCharText = function(char)
    	local color = cc.c3b(tagCount * 5, tagCount * 10, tagCount * 10)
    	local re1 = richText:getRichElementText(tagCount,color, 255,char, GameVars.fontName, 25)
    	richText:pushBackElement(re1)
    	tagCount = tagCount + 1
	end

	self.tempStr = {
		"雾","霾","了","来","修","仙","中","国","人","来"
		,"修","仙","雾","霾","了","来","修","仙","中","国","人","来","修","仙"
	}
	
	for i=1,#self.tempStr do
		local char = self.tempStr[i]
		WindowControler:globalDelayCall(createCharText,char,(3+i*4)/GameVars.GAMEFRAMERATE  )
	end
end

return MyTestView;
