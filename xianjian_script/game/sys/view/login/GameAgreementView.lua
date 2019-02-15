
local GameAgreementView = class("GameAgreementView", UIBase)

function GameAgreementView:ctor(winName)
	GameAgreementView.super.ctor(self, winName)
end

function GameAgreementView:loadUIComplete()
	self:initData()
	self:initView()
	self:registEventListeners()
	self:updateUI()
end

function GameAgreementView:registEventListeners()
	self.btn_1:setTap(c_func(self.onConfirmTap,self))
	self:registClickClose("out")
	self.panel_user_agreement.panel_1:setTouchedFunc(c_func(self.onAgreeTap,self))
end

function GameAgreementView:initData()
	self.isAgree = true

	self.contentListData = {}
	local params = self.txt_1.params

	local txtWidth = params.dimensions.width
	local fontSize = params.size
	local fontName = font
	local offset = 1

	local agreementContent = GameConfig.getLanguage("tid_login_1036")
	-- local contentArr = string.split(agreementContent, "\n")

	self.agreementContent = agreementContent
	local strHeight = FuncCommUI.getStringHeightByFixedWidth(agreementContent, fontSize, fontName, txtWidth)
	self.stringHeight = strHeight
	-- for i=1,#contentArr do

	-- 	local curContent = contentArr[i]
	-- 	echo("aaaaaa",string.len(curContent))
	-- 	local curContentArr = FuncCommUI.splitStringByWidth(curContent, fontSize,fontName,txtWidth,offset)

	-- 	for j=1,#curContentArr do
	-- 		self.contentListData[#self.contentListData+1] = curContentArr[j]
	-- 	end
	-- end
end

function GameAgreementView:onAgreeTap()
	self.isAgree = not self.isAgree
	local panelDot = self.panel_user_agreement.panel_dot
	panelDot:setVisible(self.isAgree)
end

function GameAgreementView:initView()
	-- 隐藏关闭按钮
	self.UI_1.btn_1:setVisible(false)
	self.UI_1.txt_1:setString(GameConfig.getLanguage("tid_login_1044"))

	self.scrollList = self.scroll_1
	self.txt_1:setVisible(false)


	local createItemView = function(data)
		local itemView = UIBaseDef:cloneOneView(self.txt_1)
		itemView:setString(data)
		itemView:pos(0,0)
		itemView:setTextHeight(self.stringHeight)
		-- 第一行居中显示
		itemView:setAlignment(cc.TEXT_ALIGNMENT_LEFT)
		return itemView
	end
	--滚动区域的高度比文本高度高50像素
	local expandHeight = 50
	self.listParams = 
	{
		{
			data = {self.agreementContent},
	        createFunc = createItemView,
	        itemRect = {x=0,y=-self.stringHeight -expandHeight,width = 960,height = self.stringHeight+expandHeight},
	        perNums= 1,
	        offsetX = 25,
	        offsetY = 10,
	        widthGap = 0,
	        heightGap = 0,
	        perFrame = 10,
		}
	}
	
end

function GameAgreementView:updateUI()
	self.scrollList:styleFill(self.listParams)
end

function GameAgreementView:onConfirmTap()
	if not self.isAgree then
		WindowControler:showTips(GameConfig.getLanguage("tid_login_1012"))
		return
	end

	self:startHide()
	EventControler:dispatchEvent(LoginEvent.LOGINEVENT_ON_AGREE)
end

return GameAgreementView
