-- Author: Wk
-- Date: 2017-07-22
-- 神器抽卡界面

local ArtifactDrawCardView = class("ArtifactDrawCardView", UIBase);

function ArtifactDrawCardView:ctor(winName)
    ArtifactDrawCardView.super.ctor(self, winName);
end

function ArtifactDrawCardView:loadUIComplete()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back, UIAlignTypes.RightTop)
 	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_ziyuan, UIAlignTypes.RightTop)
   	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_shop, UIAlignTypes.Right)
   	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_lh, UIAlignTypes.Right)
   	FuncCommUI.setViewAlign(self.widthScreenOffset,self.txt_1, UIAlignTypes.Right)
   	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_title, UIAlignTypes.LeftTop)
   	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_guize, UIAlignTypes.LeftTop)
   	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_jinzhi, UIAlignTypes.MiddleBottom)
   	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_yulan, UIAlignTypes.Right)
   	self.btn_guize:setVisible(false)
   	self.UI_1:setVisible(false)
   	self.panel_jinzhi.panel_djjx:setVisible(false)

   	local flaName = {
		[1] = "UI_shenqi_chouka_a",
		[2] = "UI_shenqi_chouka_b",
		[3] = "UI_shenqi_chouka_d",
	}
	
	for i=1,#flaName do
		self:delayCall(function ()
			self:insterArmatureTexture(flaName[i])
		end,i/GameVars.GAMEFRAMERATE)
	end

	
	self:createFunc()
end 

function ArtifactDrawCardView:createFunc()
	self.btn_back:setTouchedFunc(c_func(self.clickButtonBack, self),nil,true);
   	self.btn_shop:setTouchedFunc(c_func(self.goToInShop, self));
   	self.btn_lh:setTouchedFunc(c_func(self.DecomPositionCallBack, self));
   	-- self.btn_guize:setTouchedFunc(c_func(self.getRulesView, self));
   	
   	self.btn_yulan:setTouchedFunc(c_func(self.buttonpreview, self));
	self:registerEvent()
	self:initData()
	self:shopIsOpen()
end


function ArtifactDrawCardView:shopIsOpen()
	local isopen = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.SHOP_9)
	self.btn_shop:setVisible(true)
	if isopen == false then
		self.btn_shop:setVisible(false)
	end
end
function ArtifactDrawCardView:goToInShop()
	echo("跳转到商店")
	local shoptype = FuncShop.SHOP_TYPES.ARTIFACT_SHOP

	WindowControler:showWindow("ShopView",shoptype)
end
--分解按钮调用
function ArtifactDrawCardView:DecomPositionCallBack()
	echo("-----------分解按钮调用---------")
	WindowControler:showWindow("ArtifactDecomposeView");
	
end
function ArtifactDrawCardView:getRulesView()
	echo("跳转到规则界面")
end
function ArtifactDrawCardView:registerEvent()
	EventControler:addEventListener(ArtifactEvent.ACTEVENT_CHOUKA_CALLBACK, self.initData, self)
	-- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
	EventControler:addEventListener(ArtifactEvent.ACTEVENT_CHOUKA_BACK_IN_UI, self.setButtonisShow, self)
	
	EventControler:addEventListener(ArtifactEvent.CLOSE_TO_UI, self.refeshUI, self)

	EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE, self.initData, self)

	self:addEffectTOMain()
end



function ArtifactDrawCardView:initData()
	-- self.ctn_1



	local BuyItems = FuncArtifact.todayBuyItems() - ArtifactModel:getBuyItems()
	self.panel_1.rich_1:setString(FuncArtifact.buyChouakaStrQ..BuyItems..FuncArtifact.buyChouakaStrH)
	self.panel_1:setVisible(false)

	local mustGetGood = FuncArtifact.getBuyitemsGetGoods() - ArtifactModel:getBuyItems()
	local ys = math.fmod(UserExtModel:cimeliaTotalTimes(),20)  --整数
	local num = FuncArtifact.getBuyitemsGetGoods() - ys
	local _str = string.format(GameConfig.getLanguage("#tid_shenqi_018"),tostring(num)) 
	self.panel_jinzhi.rich_1:setString(_str)

	-- if ArtifactModel:getBuyItems() >= tonumber(FuncArtifact.todayBuyItems()) then
	-- 	self.panel_jinzhi:setVisible(false)
	-- end
	-- local freeitems =  FuncArtifact.cLotteryFreeTime()
	local rmboneitems = FuncArtifact.getCConsumeNumber()   ---一次花费
	
	self.panel_chou1.btn_1:setTap(c_func(self.BuyOneCallBack, self));


	local rmbFiveitems = FuncArtifact.cLotteryGoldConsume()   --五次花费
	local Itemnum =  ArtifactModel:getChouKaItemNum()   ---抽卡道具数量
	local frame = 1
	local num = rmbFiveitems
	local str = ""
	frame = 2
	num = Itemnum
	str = "/5"
	-- if Itemnum >= 5 then

	-- else
		
	-- end

	self.panel_chou2.mc_kz:showFrame(frame)
	self.panel_chou2.mc_kz:getViewByFrame(frame).txt_1:setString(" "..num..str)

	-- self.panel_chou2.txt_1:setString(rmbFiveitems)

	self.panel_chou2.btn_1:setTap(c_func(self.BuyFiveCallBack, self));
	self.panel_chou2.btn_1:getUpPanel().panel_red:setVisible(false)


	local freeitems = CountModel:getArtifactCount() -- FuncArtifact.cLotteryFreeTime() - CountModel:getArtifactCount()  --免费
	if freeitems == 0 then
		self.panel_chou1.mc_kz:showFrame(1)
		self.panel_chou1.mc_kz:getViewByFrame(1).txt_1:setString(GameConfig.getLanguage("#tid_shenqi_007"))
		self.panel_chou1.btn_1:getUpPanel().panel_red:setVisible(true)
	else
		local frames = 1
		local nums = rmboneitems
		frames = 2
		nums = Itemnum
		str = "/1"
		-- if Itemnum > 0 then
			
		-- end
		self.panel_chou1.mc_kz:showFrame(frames)
		self.panel_chou1.mc_kz:getViewByFrame(frames).txt_1:setString(" "..nums..str)
		self.panel_chou1.btn_1:getUpPanel().panel_red:setVisible(false)
	end
	self:RefreshResour()
end
--资源栏数据处理
function ArtifactDrawCardView:RefreshResour()
	local Itemnum =  ArtifactModel:getChouKaItemNum()   ---抽卡道具数量
	self.panel_ziyuan.panel_ui.txt_lingshi:setString(Itemnum)
	self.panel_ziyuan.panel_ui:setTouchedFunc(c_func(self.toDoGitVie, self),nil,true);
	-- self.panel_ziyuan.UI_bao:setVisible(false)
end
function ArtifactDrawCardView:toDoGitVie()
	WindowControler:showWindow("GetWayListView","3010")
end

--添加抽卡界面特效
function ArtifactDrawCardView:addEffectTOMain()

	local _ctn_1 = self.ctn_1
	local _ctn_2 = self.ctn_2
	self:addTaiEffEct(_ctn_1)
	self:addSpineFu(_ctn_1,1)
	self:addLightEffect(_ctn_1)

	self:addTaiEffEct(_ctn_2)
	self:addSpineFu(_ctn_2,5)
	self:addLightEffect(_ctn_2)
end

--加底盘
function ArtifactDrawCardView:addTaiEffEct(_ctn)
	
	local flaName = "UI_shenqi_chouka_c"
	local armatureName = "UI_shenqi_chouka_c_changtai_xia"
	local aim = self:createUIArmature(flaName, armatureName ,_ctn, true ,function ()
	end )
	aim:setPositionY(-80)
end

--加光束
function ArtifactDrawCardView:addLightEffect(_ctn)
	local flaName = "UI_shenqi_chouka_c" 
	local armatureName = "UI_shenqi_chouka_c_changtai_shang"
	local aim = self:createUIArmature(flaName, armatureName ,_ctn, true ,function ()
	end )
	aim:setPositionY(-80)
end


--加符
function ArtifactDrawCardView:addSpineFu(_ctn,_type)
	local npcAnimName = "UI_shenqi_chouka"
    local npcAnimLabel = nil
    if _type == 1 then
    	npcAnimLabel = "UI_shenqi_chouka_danchou"
    else
    	npcAnimLabel = "UI_shenqi_chouka_wulianchou"
    end

    local  spritename = ViewSpine.new(npcAnimName,nil,nil,nil);
    spritename:playLabel(npcAnimLabel);
	_ctn:addChild(spritename)  --宝物图片
	spritename:setPositionY(40)
end



---一次抽卡
function ArtifactDrawCardView:BuyOneCallBack()
	ArtifactModel.goodcardnum = 0
	local count =  CountModel:getArtifactCount()
	local itemcount = ArtifactModel:ChouKaItemsNumber()
	local choukaType = nil
	if count == 0 then
		choukaType = FuncArtifact.CHOUKATYPES.CHOUKA_FREE
	else
		if itemcount < 1 then
			WindowControler:showWindow("GetWayListView","3010")
			return
		end
		-- 	choukaType = FuncArtifact.CHOUKATYPES.CHOUKA_ITEM
		-- else
		-- 	choukaType = FuncArtifact.CHOUKATYPES.CHOUKA_RMB
		-- end
		choukaType = FuncArtifact.CHOUKATYPES.CHOUKA_ITEM
	end

	-- local isOk = ArtifactModel:judgeFile(FuncArtifact.ChouKaItems.CHOUKA_ONE) --self:judgeFile(FuncArtifact.ChouKaItems.CHOUKA_ONE)
	-- if isOk == false then 
	-- 	return
	-- end

	local function _callback(_param)
		-- dump(_param.result,"一抽卡结果",10)
		-- echo("抽卡类型:"..FuncArtifact.CHOUKATYPES.CHOUKA_ITEM)
		if (_param.result ~= nil) then
			FuncArtifact.playArtifactChouKaSound()
			local rewards = _param.result.data.rewards
			ArtifactModel:setRewardData(rewards)
			-- self:ToJieGuoView()
			-- self:initcardUI(1,rewards)
			self:addZaKai(self.ctn_1,1,rewards)
			self:initData()

		else
			if _param.error ~= nil then
				local error_code = _param.error.code 
				local tip = GameConfig.getErrorLanguage("#error"..error_code)
				WindowControler:showTips(tip)
			end
   		end
    end
	echo("购买一次")

	ArtifactModel:setchoukaType(1)
	local params = {}
	params.times = FuncArtifact.ChouKaItems.CHOUKA_ONE
	params.type = choukaType
	ArtifactModel:setTouchType(1)
	ArtifactServer:LotteryBuyOneAndFive(params, _callback)
end



function ArtifactDrawCardView:ToJieGuoView()
	EventControler:dispatchEvent(ArtifactEvent.ACTEVENT_CHOUKA_CALLBACK)
		self.panel_chou1:setVisible(false)
	self.panel_chou2:setVisible(false)
	WindowControler:showWindow("NewLotteryJieGuoView","artifact")
end
function ArtifactDrawCardView:setButtonisShow()
	self.panel_chou1:setVisible(true)
	self.panel_chou2:setVisible(true)
	self.panel_jinzhi.panel_djjx:setVisible(false)
end

--5抽卡
function ArtifactDrawCardView:BuyFiveCallBack()
	ArtifactModel.goodcardnum = 0
	-- local isOk = ArtifactModel:judgeFile(FuncArtifact.ChouKaItems.CHOUKA_FIVES) --self:judgeFile(FuncArtifact.ChouKaItems.CHOUKA_FIVES)
	-- if isOk == false then 
	-- 	return
	-- end
	local choukaType = nil
	local itemcount = ArtifactModel:ChouKaItemsNumber()
	if itemcount < 5 then
		WindowControler:showWindow("GetWayListView","3010")
		return
	end
	-- 	choukaType =  FuncArtifact.CHOUKATYPES.CHOUKA_ITEM
	-- else
	-- 	choukaType = FuncArtifact.CHOUKATYPES.CHOUKA_RMB
	-- end
	choukaType =  FuncArtifact.CHOUKATYPES.CHOUKA_ITEM
	ArtifactModel:setchoukaType(5)
	echo("购买五次")
	
	local function _callback(_param)
		-- dump(_param.result,"五抽卡结果",10)
		-- echo("抽卡类型:"..FuncArtifact.CHOUKATYPES.CHOUKA_ITEM)
		if (_param.result ~= nil) then
			FuncArtifact.playArtifactChouKaSound()
			local rewards = _param.result.data.rewards
			 ArtifactModel:setRewardData(rewards)
			-- self:ToJieGuoView()
			

			self:addZaKai(self.ctn_2,5,rewards)
			self:initData()

			-- self:initcardUI(5,rewards)
		else
			if _param.error ~= nil then
				local error_code = _param.error.code 
				local tip = GameConfig.getErrorLanguage("#error"..error_code)
				echo("抽卡类型:"..FuncArtifact.CHOUKATYPES.CHOUKA_ITEM.."错误码:".._param.error.code )
				WindowControler:showTips(tip)
			end
   		end
    end
	local params = {}
	params.times = FuncArtifact.ChouKaItems.CHOUKA_FIVES  --五次
	params.type = choukaType
	ArtifactModel:setTouchType(FuncArtifact.ChouKaItems.CHOUKA_FIVES)
	ArtifactServer:LotteryBuyOneAndFive(params, _callback)
end


function ArtifactDrawCardView:sethides(hides)
	local alphaOut = 0
	if hides then
		self.UI_1:setVisible(false)
		self.panel_jinzhi.panel_djjx:setVisible(false)
		alphaOut = 255
		self.btn_shop:setVisible(hides)
		self.btn_lh:setVisible(hides)
		self.txt_1:setVisible(hides)
		self.btn_yulan:setVisible(hides)
		self.panel_chou2:setVisible(hides)
		self.panel_chou1:setVisible(hides)
		self.panel_bg:setVisible(hides)
		self.ctn_1:setVisible(hides)
		self.ctn_2:setVisible(hides)
		self.panel_title:setVisible(hides)
		self.panel_ziyuan:setVisible(hides)
		self.UI_backhome:setVisible(hides)
		self.panel_title:setVisible(hides)
		-- self.btn_guize:setVisible(hides)
		self.btn_back:setVisible(hides)
		self.panel_1.rich_1:setPositionX(0)
		local BuyItems = FuncArtifact.todayBuyItems() - ArtifactModel:getBuyItems()
		self.panel_1.rich_1:setString(FuncArtifact.buyChouakaStrQ..BuyItems..FuncArtifact.buyChouakaStrH)
		self.panel_1.rich_1:runAction(act.fadeto(0.1,alphaOut))
	end
	
	self.btn_shop:runAction(act.fadeto(1.0,alphaOut))
	self.btn_lh:runAction(act.fadeto(1.0,alphaOut))
	self.txt_1:runAction(act.fadeto(1.0,alphaOut))
	self.btn_yulan:runAction(act.fadeto(1.0,alphaOut))
	self.panel_chou2:runAction(act.fadeto(1.0,alphaOut))
	self.panel_chou1:runAction(act.fadeto(1.0,alphaOut))
	self.panel_bg:runAction(act.fadeto(1.0,alphaOut))
	self.ctn_1:runAction(act.fadeto(1.0,alphaOut))
	self.ctn_2:runAction(act.fadeto(1.0,alphaOut))
	self.panel_title:runAction(act.fadeto(1.0,alphaOut))
	self.UI_backhome:runAction(act.fadeto(1.0,alphaOut))
	self.btn_back:runAction(act.fadeto(1.0,alphaOut))
	self.panel_ziyuan:runAction(act.sequence(act.fadeto(1.0,alphaOut),act.callfunc(function ()
		
		self.btn_shop:setVisible(hides)
		self.btn_lh:setVisible(hides)
		self.txt_1:setVisible(hides)
		self.btn_yulan:setVisible(hides)
		self.panel_chou2:setVisible(hides)
		self.panel_chou1:setVisible(hides)
		self.panel_bg:setVisible(hides)
		self.ctn_1:setVisible(hides)
		self.ctn_2:setVisible(hides)
		self.panel_title:setVisible(hides)
		self.panel_ziyuan:setVisible(hides)
		self.UI_backhome:setVisible(hides)
		self.panel_title:setVisible(hides)
		self.panel_jinzhi.panel_djjx:setVisible(false)
		-- self.btn_guize:setVisible(hides)
		self.btn_back:setVisible(hides)
	end),act.callfunc(function ()   ---,act.delaytime(1.0)   去掉延迟点击的事件 --wk 
		if not hides then
			self:resumeUIClick()
		end
	end)))
	-- self.btn_back:runAction(act.fadeto(1.0,alphaOut)

end

function ArtifactDrawCardView:refeshUI()

	self.btn_back:setTouchedFunc(c_func(self.clickButtonBack, self),nil,true);
	self.panel_1.rich_1:runAction(act.fadeto(0.1,0))
	self:sethides(true)

end


function ArtifactDrawCardView:setBtnTouchEnable(_e)
	-- self.btn_shop:setTouchEnabled(_e)
	-- self.btn_yulan:setTouchEnabled(_e)
	self.panel_chou2:setTouchEnabled(_e)
	self.panel_chou1:setTouchEnabled(_e)
end


--预览
function ArtifactDrawCardView:buttonpreview()
	WindowControler:showWindow("ArtifactPreviewView")

end

function ArtifactDrawCardView:addZaKai(_ctn,_type,rewards)
	local flaName = "UI_shenqi_chouka_c" 
	local armatureName = "UI_shenqi_chouka_c_zhakai"
	local parmes = 14
	-- self:setBtnTouchEnable(false)
	self:disabledUIClick()
	local aim = self:createUIArmature(flaName, armatureName ,_ctn, false ,function ()
			
	end )
	aim:registerFrameEventCallFunc(parmes,1,function ()
		self:initcardUI(_type,rewards)
	end)
	-- self:delayCall(function ()
	-- 	self:initcardUI(_type,rewards)
	-- end,0.55)
	aim:setPositionY(50)
	aim:setScale(0.7)
	aim:startPlay(false, true )
	self.panel_1.rich_1:runAction(act.fadeto(0.1,0))
	EventControler:dispatchEvent(ArtifactEvent.ACTEVENT_CHOUKA_CALLBACK)

end

function ArtifactDrawCardView:initcardUI(_type,reward)
	self:sethides(false)
	
	-- WindowControler:showWindow("ArtifactLCMainCardView",_type,reward)
	self:LCMainCardView(_type,reward)
end


function ArtifactDrawCardView:LCMainCardView(_type,reward)

	local num = FuncArtifact.cLotteryCimeliaCoin()*tonumber(_type)
	self.panel_1.rich_1:setString(FuncArtifact.shenqiJinhuaEtr..num,{scale = 0.4,width = 30,height = 25,})
	self.panel_1.rich_1:setPositionX(100)
	self.panel_1.rich_1:runAction(act.fadeto(0.1,255))
	local function _callback()
		self:showAnyStr()
	end
	self.btn_back:setTouchedFunc(c_func(self.touchUIIsShow, self),nil,true);
	self:registClickClose(-1, c_func( function()
        self:touchUIIsShow()
    end , self))
    self.UI_1:setVisible(true)
	self.UI_1:initData(_type,reward,_callback)--c_func(self.setUITouchEnabled, self)

end

function ArtifactDrawCardView:setUITouchEnabled()

end

--显示任意文本
function ArtifactDrawCardView:showAnyStr()
	local num =  ArtifactModel:getGoodCardNum()
	-- echo("=====num========",num)
	if num == 0 then
		if self.UI_1:isVisible() then
			self.panel_jinzhi.panel_djjx:setVisible(true)
		else
			self.panel_jinzhi.panel_djjx:setVisible(false)
		end
	end
end



--点击卡牌外面选择是否还有卡牌未领取
function ArtifactDrawCardView:touchUIIsShow()
	local num =  ArtifactModel:getGoodCardNum()
	if num ~= 0 then
		WindowControler:showTips(GameConfig.getLanguage("#tid_shenqi_008"))
	else
		self:refeshUI()
	end
end



function ArtifactDrawCardView:clickButtonBack()
	self:startHide()
end


return ArtifactDrawCardView;
