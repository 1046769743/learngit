
local RichTextPrinter = class("RichTextPrinter", function (  )
    return display.newNode()
end)

function RichTextPrinter:ctor()
	echo("RichTextPrinter ctor")
end

-- 初始化默认值
function RichTextPrinter:initData()
	self.defaultSpeed = 10     			--每秒几个字
	self.defaultFont = GameVars.fontName
	self.defaultFontSize = 25
	self.defaultOpacity = 255
	
	self.speed = self.defaultSpeed
	self.tagCount = 1
	self.charCount = 1
	self.skip = false
end

-- 创建富文本打字机
function RichTextPrinter:initRichTextPrinter(textCfgList,x,y,width,height,speed)
	self.richText =  RichTextExpand.new()
	self.richText:ignoreContentAdaptWithSize(false)
	self.richText:setContentSize(cc.size(width, height))
	self.richText:pos(x,y)
	self:addChild(self.richText)

	-- 初始化默认值
	self:initData()

	self.textCfgList = textCfgList
	self.speed = speed

	local frame = GameVars.GAMEFRAMERATE / self.speed 
	if frame < 1 then
		self.delay = 1
	else
		self.delay = frame
	end

	self:createText()
end

function RichTextPrinter:createText()
	if self.charCount > #self.textCfgList or self.skip == true then
		return
	end

	local cfg = self.textCfgList[self.charCount]
	self:createElementText(cfg)

	self.charCount = self.charCount + 1
	self.tagCount = self.tagCount + 1

	self:delayCall(c_func(self.createText, self),2/GameVars.GAMEFRAMERATE )
end

-- 创建文本元素
function RichTextPrinter:createElementText(cfg)
	local char = cfg.char
	local color = cfg.color
	local opacity = cfg.opacity or self.defaultOpacity
	local fontName = cfg.font or self.defaultFont
	local fontSize = cfg.fontSize or self.defaultFontSize
	if char == "\n" then
		echo("test....")
		self.richText:addNewLine()
	else
		local richTextEle = self.richText:getRichElementText(self.tagCount,color,opacity,char,fontName,fontSize)
   		self.richText:pushBackElement(richTextEle)
	end
end

-- 跳过逐个打字
function RichTextPrinter:skipPrint()
	self.skip = true

	for i=self.charCount,#self.textCfgList do
		local cfg = self.textCfgList[i]
		self:createElementText(cfg)
		self.tagCount = self.tagCount + 1
	end
end

return RichTextPrinter


