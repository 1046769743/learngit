
local PartnerSkinFirstShowView = class("PartnerSkinFirstShowView", UIBase);


function PartnerSkinFirstShowView:ctor(winName, params,callBack)
    PartnerSkinFirstShowView.super.ctor(self, winName);
    self._id = params.id;
    self._skin = params.skin
    self.file = params.file
    self.hunFile = params.hunFile

    self.callBack = callBack

    self.isChar = FuncPartner.isChar(self._id)

end

function PartnerSkinFirstShowView:loadUIComplete()
	self:registerEvent();
    self.shareFinish = false

    self.UI_share:opacity(0)
	self.btn_close:opacity(0)
	self.panel_djjx:opacity(0)
	self.UI_share:setVisible(false)
	self.btn_close:setVisible(false)
	self.panel_djjx:setVisible(false)

	self:updateUI()
	self:hideAllItems()
	self:playBaoZhaAnimation()
end 

function PartnerSkinFirstShowView:playBaoZhaAnimation()
	
	local heipingAnim = self:createUIArmature("UI_heiping_01", "UI_heiping_01", self.ctn_ren, false, GameVars.emptyFunc)
	heipingAnim:pos(568, -320) --coverLayer:pos(-GameVars.width / 2,  GameVars.height / 2)
	local baozhaAnim = self:createUIArmature("UI_shenshuchouka", "UI_shenshuchouka_zhuanchang", self.ctn_ren, false, GameVars.emptyFunc)
	baozhaAnim:pos(50, 145)
	baozhaAnim:registerFrameEventCallFunc(70, 1, function()
			self.__bgView:setVisible(true)
    	end)

	baozhaAnim:registerFrameEventCallFunc(90, 1, function()
			self.__bgView:setVisible(true)
    		self:playShowAnimation()
    	end)

end

function PartnerSkinFirstShowView:playShowAnimation()
	local showSpineAnim = self:createUIArmature("UI_chouka_ren", "UI_chouka_ren_zong", self.ctn_ren, false, GameVars.emptyFunc)
	FuncArmature.changeBoneDisplay(showSpineAnim, "node", self.ctn_lihui)

	local showOtherAnim = self:createUIArmature("UI_chouka_ren", "UI_chouka_ren_021", self.ctn_texiao, true, GameVars.emptyFunc)
	FuncArmature.changeBoneDisplay(showOtherAnim, "node01", self.ctn_name)
	FuncArmature.changeBoneDisplay(showOtherAnim, "node02", self.mc_pinji)
	FuncArmature.changeBoneDisplay(showOtherAnim, "node_03", self.mc_di)
	-- FuncArmature.changeBoneDisplay(showOtherAnim, "node06", self.UI_share)
	FuncArmature.changeBoneDisplay(showOtherAnim, "node_text01", self.mc_shuangse1)
	FuncArmature.changeBoneDisplay(showOtherAnim, "node_text02", self.mc_shuangse2)
	FuncArmature.changeBoneDisplay(showOtherAnim, "node_text03", self.mc_shuangse3)
	FuncArmature.changeBoneDisplay(showOtherAnim, "node_text04", self.mc_shuangse4)
	FuncArmature.changeBoneDisplay(showOtherAnim, "node04", self.mc_shidi2)
	FuncArmature.changeBoneDisplay(showOtherAnim, "node05", self.mc_shidi1)
	FuncArmature.changeBoneDisplay(showOtherAnim, "node08", self.panel_wenziyou)
	FuncArmature.changeBoneDisplay(showOtherAnim, "node09", self.mc_shuxing)
	showOtherAnim:startPlay(false, true)

	showOtherAnim:registerFrameEventCallFunc(60, 1, function()
			self.UI_share:setVisible(true)
			self.mc_sharestar:fadeIn(0.5)
    		self.UI_share:fadeIn(0.5)
    	end)

	self:delayCall(function ()
			self.btn_close:setVisible(true)
			-- self.panel_djjx:setVisible(true)
			self.btn_close:fadeIn(0.2)
			-- self.panel_djjx:fadeIn(0.5)
			self:registClickClose(-1, c_func(self.button_close, self))
		end, 80/GameVars.GAMEFRAMERATE)

	self.showOtherAnim = showOtherAnim

	local element1 = showOtherAnim:getBone("element_1")
	local element2 = showOtherAnim:getBone("element_4")
	-- local node_03 = showOtherAnim:getBone("node_03")
	-- FuncCommUI.setViewAlign(self.widthScreenOffset, node_03, UIAlignTypes.LeftTop);
	FuncCommUI.setViewAlign(self.widthScreenOffset, element1, UIAlignTypes.LeftTop);
    FuncCommUI.setViewAlign(self.widthScreenOffset, element2, UIAlignTypes.LeftTop);
    FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_djjx, UIAlignTypes.MiddleBottom);
    
    self:setViewAlign()
end

function PartnerSkinFirstShowView:hideAllItems()
	self.mc_sharestar:opacity(0)
	self.__bgView:setVisible(false)
	self.ctn_name:setVisible(false)
	self.mc_di:setVisible(false)
	-- self.UI_share:setVisible(false)
	-- self.btn_close:setVisible(false)
	self.panel_wenziyou:setVisible(false)
	self.mc_shuangse1:setVisible(false)
	self.mc_shuangse2:setVisible(false)
	self.mc_shuangse3:setVisible(false)
	self.mc_shuangse4:setVisible(false)
	self.mc_shidi1:setVisible(false)
	self.mc_shidi2:setVisible(false)
	self.ctn_lihui:setVisible(false)
	self.mc_shuxing:setVisible(false)
	self.mc_pinji:setVisible(false)

	self.mc_sharestar:pos(20, -180)
	self.mc_pinji:pos(17, 0)
	self.ctn_name:pos(40, -5)
	self.mc_di:pos(0, 0)
	-- self.UI_share:pos(-15, -30)
	self.panel_wenziyou:pos(-60, 40)
	self.mc_shuangse1:pos(-53, -10)
	self.mc_shuangse2:pos(-53, -40)
	self.mc_shuangse3:pos(-52, -10)
	self.mc_shuangse4:pos(-52, -40)
	self.mc_shidi1:pos(-50, 0)
	self.mc_shidi2:pos(-30, 0)
	self.mc_shuxing:pos(20, -30)
end

function PartnerSkinFirstShowView:setViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_pinji, UIAlignTypes.LeftTop);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_shuxing, UIAlignTypes.LeftTop);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_name, UIAlignTypes.LeftTop);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_di, UIAlignTypes.LeftTop);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_logo, UIAlignTypes.LeftBottom);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.UI_share, UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_close, UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_wenziyou, UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_shuangse1, UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_shuangse2, UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_shuangse3, UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_shuangse4, UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_shidi2, UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_shidi1, UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_lihui, UIAlignTypes.MiddleBottom);
    FuncCommUI.setViewAlign(self.widthScreenOffset, self.mc_sharestar, UIAlignTypes.LeftTop); 
end

function PartnerSkinFirstShowView:registerEvent()
	PartnerSkinFirstShowView.super.registerEvent();

    self.btn_close:setTap(c_func(self.button_close,self))
end

function PartnerSkinFirstShowView:shareTap( _type )
	self.shareFinish = true

	self:updateSharePanel()
end




function PartnerSkinFirstShowView:updateUI()
	-- 返回截屏分享node及其相关信息
	local getShareNode = function (  )
		self.__bgView:parent(self._shareNode,-1)

		-- 将特效加到分享中
		self.ctn_ren:parent(self._shareNode)
		self.ctn_texiao:parent(self._shareNode)

		--分享的时候 需要显示logo
		self.panel_logo:visible(true)

		local box = self._shareNode:getContainerBoxToParent()
		local contentInfo = {}
		local width = box.width
		local height = box.height
		
		-- 截屏内容如果包含了全屏背景，需要做如下处理
		contentInfo.offsetX = -(box.x + GameVars.UIOffsetX)
		contentInfo.offsetY = -(box.y + GameVars.UIOffsetY)

		self._shareNode.contentInfo = contentInfo
		self._artSp:gotoAndPlay(1)
		return self._shareNode
	end

	local node = display.newNode():addto(self._root,-1)
    -- self.ctn_lihui:parent(node)
	self.panel_logo:parent(node)
	self._shareNode = node

	self.UI_share:setShareCallBack(getShareNode,c_func(self.shareTap,self) )
	-- 时装立绘
    local artSp = nil 
    if self.isChar then
        artSp = FuncGarment.getGarmentLihui(self._skin, self._id, "dynamic")
    else
        artSp = FuncPartner.getPartnerLiHuiByIdAndSkin(self._id)
    end
    self.ctn_lihui:removeAllChildren()

    local posOffset = FuncPartnerSkinShow.getFirstShowPos(self._id)
    -- artSp:pos(posOffset[1],posOffset[2])
    self._artSp = artSp
    self.ctn_lihui:addChild(artSp)

    -- 品质
    local quility = 1
    if self._skin then
		local dataSkin = FuncPartnerSkin.getPartnerSkinById( self._skin )
		if dataSkin then
			quility = dataSkin.quality
		end

		local bg =FuncPartner.getPartnerBgById(self._id, self._skin )
		self:changeBg(bg,true)
    end
    
    self.mc_pinji:showFrame(quility)
    self.mc_di:showFrame(quility)


    -- name
	local path = FuncRes.partnerName(self._id,quility)
	local nameIcon = display.newSprite(path)
	self.ctn_name:removeAllChildren()
	self.ctn_name:addChild(nameIcon)
    -- 奇侠类型
	local partnerData = FuncPartner.getPartnerById(self._id)
	self.mc_shuxing:showFrame(partnerData.type)
	self.mc_sharestar:showFrame(partnerData.initStar)

	-- 诗
	local _data = FuncPartnerSkinShow.getDataByParIdAndType( self._id,tostring(quility) ) or {}

	local offSetX = 0
	local offSetY = 0
	if _data.pos then
		offSetX = _data.pos[1]
		offSetY = _data.pos[2]
	end

	-- self.ctn_lihui:setPositionY(-640 + offSetY)
    self.ctn_lihui:setPositionX(618 + offSetX)


	local bg = _data.bg
	if bg then
		self:changeBg(bg,true)
	end
	local str1 = GameConfig.getLanguage(_data.poem1)
	local str2 = GameConfig.getLanguage(_data.poem2 or _data.poem1)
	local str3 = GameConfig.getLanguage(_data.poem3 or _data.poem1)
	local str4 = GameConfig.getLanguage(_data.poem4 or _data.poem1)
	-- str = "剩女就看  电视剧了\n看过就流口\n水副经理开始速度快的国际\n法第六季卡即可拉伸了空间"

	if quility == 1 then
		self.mc_shuangse1:showFrame(2)
		self.mc_shuangse2:showFrame(2)
		self.mc_shuangse3:showFrame(2)
		self.mc_shuangse4:showFrame(2)
		self.mc_shidi2:showFrame(2)
		self.mc_shidi1:showFrame(2)
		self.panel_wenziyou.mc_wenzidi:showFrame(2)
		self.panel_wenziyou.mc_shuuangse:showFrame(2)
	else
		self.mc_shuangse1:showFrame(1)
		self.mc_shuangse2:showFrame(1)
		self.mc_shuangse3:showFrame(1)
		self.mc_shuangse4:showFrame(1)
		self.mc_shidi2:showFrame(1)
		self.mc_shidi1:showFrame(1)
		self.panel_wenziyou.mc_wenzidi:showFrame(1)
		self.panel_wenziyou.mc_shuuangse:showFrame(1)
	end

	self.mc_shuangse1.currentView.txt_1:setString(str1)
	self.mc_shuangse2.currentView.txt_1:setString(str2)
	self.mc_shuangse3.currentView.txt_1:setString(str3)
	self.mc_shuangse4.currentView.txt_1:setString(str4)

	local params = {
        str = str1,
        -- num = 1000 ,-- 每列几个字
        space = 2, -- 列间距几个" "
        txt = self.mc_shuangse1.currentView.txt_1, -- txt实例
    }
    FuncCommUI.setVerTicalTXT( params )

    params = {
        str = str2,
        -- num = 1000 ,-- 每列几个字
        space = 2, -- 列间距几个" "
        txt = self.mc_shuangse2.currentView.txt_1, -- txt实例
    }
    FuncCommUI.setVerTicalTXT( params )

    params = {
        str = str3,
        -- num = 1000 ,-- 每列几个字
        space = 2, -- 列间距几个" "
        txt = self.mc_shuangse3.currentView.txt_1, -- txt实例
    }
    FuncCommUI.setVerTicalTXT( params )

    params = {
        str = str4,
        -- num = 1000 ,-- 每列几个字
        space = 2, -- 列间距几个" "
        txt = self.mc_shuangse4.currentView.txt_1, -- txt实例
    }
    FuncCommUI.setVerTicalTXT( params )
    
    local charaCteristic = GameConfig.getLanguage(FuncPartner.getDescribe(self._id))
    charaCteristic = string.gsub(charaCteristic, ",", " ")
    charaCteristic = string.gsub(charaCteristic, "，", " ")
    params = {
        str = charaCteristic,
        num = 1000, -- 每列几个字
        space = 0, -- 列间距几个" "
        txt =self.panel_wenziyou.mc_shuuangse.currentView.txt_1, -- txt实例
    }
    FuncCommUI.setVerTicalTXT( params )
	
	-- FuncCommUI.setVerTicalTXT( param )
	self.panel_wenziyou.btn_play:visible(false)
	-- self.panel_wenben.panel_shijv.mc_shidi:visible(false)


	self:updateSharePanel()

end

function PartnerSkinFirstShowView:updateSharePanel()
	if self.shareFinish then
		self.panel_logo:visible(false)
		self.UI_share:visible(true)
		self.UI_share:pressGlobalClick()
	else
		self.panel_logo:visible(false)
		self.UI_share:visible(false)
	end
end


function PartnerSkinFirstShowView:button_close()
	-- if self.callBack then
	-- 	echo("奇侠 首次 分享=====")
	-- 	self.callBack()
	-- end

	local callBack = self.callBack
	self.callBack  = nil

	EventControler:dispatchEvent(NewLotteryEvent.RESUME_REWARD_ITEMS)
	if self.file ~= nil then
		-- if self.file then
		-- 	EventControler:dispatchEvent(NewLotteryEvent.RESUME_REWARD_ITEMS)
		-- end
	else
		if self.hunFile ~= nil then
			--魂匣调用
			-- WindowControler:showWindow("NewLotteryJieGuoCradView",{1,self.reward},true)

		end
	end
	self:startHide()
	if callBack then
		echo("奇侠 首次 分享=====")
		callBack()
	end
end

return PartnerSkinFirstShowView;
