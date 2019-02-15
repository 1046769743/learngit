-- Author: Wk
-- Date: 2017-07-22
-- 神器系统主界面

local ArtifactMainView = class("ArtifactMainView", UIBase);

local BG_IMAGES = {
	[2]="artifacts_bg_zhujiemianlv.png",
	[3]="artifacts_bg_zhujiemianlan.png",
	[4]="artifacts_bg_zhujiemianzi.png",
	[5]="artifacts_bg_zhujiemiancheng.png",
}
function ArtifactMainView:ctor(winName,ccid)
    ArtifactMainView.super.ctor(self, winName);
    local itemData = ArtifactModel:getAllData()
    local ccids = tostring(itemData[1].id)
    if ccid  ~= nil then
    	ccids = ArtifactModel:ByartifactIdGetType(ccid)
    else
    	local oldSelectId = ArtifactModel:getselectArID()
    	if oldSelectId ~= nil  then
    		ccids = oldSelectId 
    	end
    end


    self.seleCellId =  ccids

end

function ArtifactMainView:loadUIComplete()
	self.panel_num1_x  = self.panel_num1:getPositionX()
	self.panel_num2_x  = self.panel_num2:getPositionX()
   	self.cellitem = {}
	self.oldAbility = ArtifactModel:getAllDataPower()
	self:registerEvent()
	
	self:initData()
	self:btn_chouRedShow()
	self:buttonRedShow()
	-- self:addQuestAndChat()
	self:showShareButton()
	self:setShareButton()
	self:initEnterAni()

	self:addButton()

   self:setCellViewAlign()

   self:showArtifactInfoTips()

end 

function ArtifactMainView:setCellViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_top.btn_back, UIAlignTypes.RightTop)
 	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_top.panel_ziyuan, UIAlignTypes.RightTop)
   	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_1, UIAlignTypes.Right)
   	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_top.panel_title, UIAlignTypes.LeftTop)
   	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_zuo, UIAlignTypes.Left)
   	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_1.panel_zongpower, UIAlignTypes.RightTop)
   	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_1.btn_guize, UIAlignTypes.RightTop)

   	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_zuo.mc_btn, UIAlignTypes.Right)
   	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_fen, UIAlignTypes.Left)
   	FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_story, UIAlignTypes.Right)
-- panel_story
   	FuncCommUI.setScale9Align(self.widthScreenOffset,self.panel_1.scale9_1,UIAlignTypes.Right,0,1)
   	FuncCommUI.setScrollAlign(self.widthScreenOffset,self.panel_1.scroll_1,UIAlignTypes.Right,0,1)
end


-- --添加聊天和目标按钮
-- function ArtifactMainView:addQuestAndChat()
--     local arrData = {
--         systemView = FuncCommon.SYSTEM_NAME.CIMELIA,--系统
--         view = self,---界面
--     }
--     QuestAndChatControler:createInitUI(arrData)
-- end



function ArtifactMainView:buttonRedShow()
	local isok,_type,itemname = ArtifactModel:ByCCIDgetAdvanced(self.seleCellId)
	self.mc_btn:getViewByFrame(1).btn_1:getUpPanel().panel_red:setVisible(isok)
end
function ArtifactMainView:addButton()
	self.panel_top.btn_back:setTouchedFunc(c_func(self.clickButtonBack, self),nil,true);
	self.btn_chou:setTap(c_func(self.ThatCardCallBack, self));
	self.btn_chou:getUpPanel().txt_name:setString(GameConfig.getLanguage("#tid_shenqi_009"))
	self.panel_1.panel_zongpower:setTouchedFunc(c_func(self.ShowShuXingTip, self),nil,true);
	self.panel_1.btn_guize:setVisible(false)
	-- self.btn_guize:setTouchedFunc(c_func(self.ShowShuXingTip, self),nil,true);
	-- self.panel_story:setTouchedFunc(c_func(self.sgowArtifactInfoTips, self),nil,true);
	
end

function ArtifactMainView:showArtifactInfoTips()
	-- echo("111111============",self.seleCellId)
	FuncCommUI.regesitShowResView(self.mc_story,
        nil, nil, self.seleCellId, true, true,nil,true);

end

function ArtifactMainView:showTipPower()
	WindowControler:showTips(FuncArtifact.titleStr)
end

function ArtifactMainView:RefreshAbility()
	if  self.oldAbility ~= nil then
		local newAbility = ArtifactModel:getAllDataPower()
        if self.oldAbility ~= newAbility then
            FuncCommUI.showPowerChangeArmature(self.oldAbility , newAbility );
            self.oldAbility = newAbility
        end
    end
end

function ArtifactMainView:registerEvent()
	-- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
	EventControler:addEventListener(ArtifactEvent.ACTEVENT_SINGLE_ADVANCED, self.RefreshUI, self)
	EventControler:addEventListener(ArtifactEvent.ACTEVENT_COMBINATION_ADVANCED, self.chouKaReFresh, self)
	EventControler:addEventListener(ArtifactEvent.ACTEVENT_CHOUKA_CALLBACK, self.chouKaReFresh, self)
	EventControler:addEventListener(ShopEvent.SHOPEVENT_BUY_ITEM_END, self.chouKaReFresh, self)
	EventControler:addEventListener(ArtifactEvent.DECOMPOSE_REFRESH_UI, self.chouKaReFresh, self)
	EventControler:addEventListener(ArtifactEvent.ACTEVENT_CHOUKA_BACK_IN_UI, self.btn_chouRedShow, self)
	
	EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE, self.chouKaReFresh, self)


end
function ArtifactMainView:chouKaReFresh()
	if not self.addEffectArrRefresh then
		self:initData()
		self:RefreshUI()
	end
	self.addEffectArrRefresh = false
end

function ArtifactMainView:RefreshUI()
	local alldata = ArtifactModel:getAllData()
	local itemData = nil
	for i=1,#alldata do
		if alldata[i].id == self.seleCellId then
			itemData = alldata[i]
		end
	end
	self:theMiddleDataView(itemData,true)
	-- self:initData()
	self:RightListResShow(itemData)
	self:refreshRightRedShow()
	self:sumAttrNumber()
	
	self:btn_chouRedShow()
	self:RefreshAbility()
	self:buttonRedShow()
	self:showShareButton()
	
	

end

function ArtifactMainView:initEnterAni( )
	if  self._isHasPlayAni then
		return
		
	end
	self._isHasPlayAni = true
	--播放开场动画
	local arr = {6,4,3,5}
	local frame = self.mc_1.currentFrame
	local nums = arr[frame]
	local armatureName = "UI_shenqi_jiemian_main"
	local startAni = self:createUIArmature("UI_shenqi_jiemian", armatureName, self.ctn_bg, false, GameVars.emptyFunc)
	
	startAni:setAllChildAniPlayOnce()
	startAni:pos(GameVars.gameResWidth /2,-GameVars.gameResHeight/2)
	self.mc_btn:pos(-88,34)
	self.panel_top:pos(16,0)
	self.panel_zuo:pos(-170,265)
	self.panel_1:pos(0,0)
	self.btn_chou:pos(0,0)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_chou, UIAlignTypes.Left)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,startAni:getBone("qishen"), UIAlignTypes.Left)
	FuncArmature.changeBoneDisplay( startAni:getBoneDisplay("anniu"),"layer1",self.mc_btn )
	FuncArmature.changeBoneDisplay( startAni:getBoneDisplay("up"),"layer1",self.panel_top )
	FuncArmature.changeBoneDisplay( startAni:getBoneDisplay("left"),"layer1",self.panel_zuo )
	FuncArmature.changeBoneDisplay( startAni:getBoneDisplay("right"),"layer1",self.panel_1 )
	FuncArmature.changeBoneDisplay( startAni:getBoneDisplay("qishen"),"layer1",self.btn_chou )

	local tempFunc = function ( ani )
		ani:play()
		ani:visible(true)
	end

	for i=1,nums do
		self:replaceChildAni(self.mc_1.currentView["panel_kuang"..i],self.mc_1.currentView,-47,50,i*1/GameVars.GAMEFRAMERATE )
	end


	if self.panel_num1:isVisible() then
		self.panel_num1:opacity(0)
		self.panel_num1:fadeTo(3,255)
		self.panel_num2:opacity(0)
		self.panel_num2:fadeTo(1,255)
	end
	self.mc_story:opacity(0)
	self.mc_story:fadeTo(2,255)
end

--替换一个子部件动画
function ArtifactMainView:replaceChildAni(targetView, parentCtn,offsetX,offsetY,delay )
	local tempFunc = function ( ani )
		ani:play()
		ani:visible(true)
	end
	local childAni = self:createUIArmature("UI_shenqi_jiemian", "UI_shenqi_jiemian_pingzi", parentCtn, false, GameVars.emptyFunc)
	local x,y = targetView:getPosition()
	childAni:pos(x-offsetX,y-offsetY)
	targetView:pos(offsetX,offsetY)
	childAni:visible(false)
	childAni:stop()
	FuncArmature.changeBoneDisplay( childAni,"layer1",targetView )
	childAni:delayCall(c_func(tempFunc,childAni), delay )
end


function ArtifactMainView:showShareButton()
	local artifactId = self.seleCellId
	local  data  = ArtifactModel:byIdgetData(artifactId)
	if data.quality ~= 0 then
		self.panel_zuo.btn_1:setVisible(true)
	else
		self.panel_zuo.btn_1:setVisible(false)
	end
end
function ArtifactMainView:setShareButton()
	self.panel_zuo.btn_1:setTouchedFunc(c_func(self.sendShareToWorld, self),nil,true);
end
function ArtifactMainView:sendShareToWorld()

	local isSendCD = ChatModel:sendTreasureShareToWorldCD()
	if not isSendCD then
		WindowControler:showTips(GameConfig.getLanguage("#tid_treature_share_03"))
		return 
	end

	ChatModel.worldTreasureChatCD = TimeControler:getServerTime()
	local artifactId = self.seleCellId
	local  data  = ArtifactModel:byIdgetData(artifactId)
	dump(data,"神器数据结构 ========")

	local function callback(event)
        if event.result then

            WindowControler:showTips(GameConfig.getLanguage("#tid_treature_share_02"))
        end
    end


    local pamses = {
        type = 2,  --神器分享类型
        content = json.encode(data),
    }

    ChatServer:sendChatWorldShare(pamses,callback)

end

function ArtifactMainView:refreshRightRedShow()
	local alldata = ArtifactModel:getAllData()
	for i=1,#alldata do
		local itemData = alldata[i]
		local artifactId = itemData.id
		local singlered = ArtifactModel:ByCCIDgetAdvancedRedShow(artifactId)
		local isShowRed = ArtifactModel:ByCCIDgetAdvanced(artifactId)
		local alllist = self.panel_1.scroll_1:getAllView()
		if alllist[i] then
			alllist[i].panel_red:setVisible(isShowRed or singlered)
		end
	end
end


--抽奖红点显示
function ArtifactMainView:btn_chouRedShow()
	local freecount = CountModel:getArtifactCount()
	local items = ArtifactModel:DrawCardItems()
	self.btn_chou:getUpPanel().panel_red:setVisible(false)
	if freecount == 0 then
		self.btn_chou:getUpPanel().panel_red:setVisible(true)
	end
end

function ArtifactMainView:initData()
	-- self:middleLayerImage()
	-- self.x1 = self["panel_num1"]:getPositionX()

	self.panel_1.panel_1:setVisible(false)
	self.alldata = ArtifactModel:getAllData()
    local createRankItemFunc = function(itemData)
    	local baseCell = UIBaseDef:cloneOneView(self.panel_1.panel_1);
        self:cellviewData(baseCell, itemData)
        return baseCell;
    end
     local updateCellFunc = function (itemData,view)
    	self:cellviewData(view, itemData)
	end

    local  _scrollParams = {
        {
            data = self.alldata,
            createFunc = createRankItemFunc,
            -- updateCellFunc = updateCellFunc,
            perNums = 1,
            offsetX = 60,
            offsetY = 60,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -120, width = 120, height = 120},
            perFrame = 0,
        }
    }    
    self.panel_1.scroll_1:cancleCacheView();
    -- self.panel_1.scroll_1:refreshCellView( 1 )
    self.panel_1.scroll_1:styleFill(_scrollParams);
    self.panel_1.scroll_1:hideDragBar()
    for k,v in pairs(self.alldata) do
    	if tonumber(v.id) == tonumber(self.seleCellId) then
    		local itemData = v
    		self:theMiddleDataView(itemData)
    	end
    end

    -- self.panel_1.btn_guize:setTouchedFunc(c_func(self.ShowShuXingTip, self, ccid),nil,true);
    self:sumAttrNumber()
    self:buttonRedShow()

end


--总战力
function ArtifactMainView:sumAttrNumber()
	local sumattr = ArtifactModel:getAllDataPower()

	echo("=======神器 特效 =总战力=========",sumattr)
	self.panel_1.panel_zongpower.UI_number:setPower(sumattr)

	EventControler:dispatchEvent(UserEvent.USEREVENT_PLAYER_POWER_CHANGE);
end

--最右边的列表
function ArtifactMainView:cellviewData(baseCell,itemData)
	-- echo("--- 22222 ----")
	-- dump(itemData)
	baseCell.btn_1:setVisible(false)
	baseCell.panel_red:setVisible(false)
	local quality = itemData.quality 
	local artifactId = itemData.id
	local artifactalldata = FuncArtifact.byIdgetCCInfo(artifactId)
	local CCInfo =  FuncArtifact.byIdgetCCInfo(artifactId)
	local colortframe = CCInfo.combineColor
	local artifactdata = nil
	baseCell.panel_suo:setVisible(false)

	if quality == 0 then  ---未获取的时候
		-- baseCell.panel_suo:setVisible(true)
		artifactdata = artifactalldata[tostring(1)]   --默认取第一个
		FilterTools.setGrayFilter(baseCell.mc_kuang)
		baseCell.panel_c:setVisible(false)
	else
		-- baseCell.panel_suo:setVisible(false)
		artifactdata = artifactalldata[tostring(quality)]   --默认取第一个
		FilterTools.clearFilter(baseCell.mc_kuang)
		baseCell.panel_c:setVisible(true)
		baseCell.panel_c.mc_2:showFrame(colortframe)
		baseCell.panel_c.mc_2:getViewByFrame(colortframe).txt_1:setString("+"..quality)
		-- baseCell.panel_c.txt_1:setString("+"..quality)
		baseCell.panel_c.mc_kuang:showFrame(colortframe)
	end
	local singlered = ArtifactModel:ByCCIDgetAdvancedRedShow(artifactId)
	local isShowRed = ArtifactModel:ByCCIDgetAdvanced(artifactId)
	baseCell.panel_red:setVisible(singlered or isShowRed)


	
 	local ctn = baseCell.ctn_2
 	FuncArtifact.addChildToCtn(ctn,artifactId,quality)
 	baseCell.mc_1:showFrame(colortframe-1)
 	-- if quality == 0 then
 	-- 	quality = 1
 	-- end
 -- 	baseCell.panel_kuang.mc_kuang2:showFrame(colortframe)
	-- baseCell.panel_kuang.mc_kuang:showFrame(colortframe)
	baseCell.panel_xuan:setVisible(false)
 	if self.seleCellId == tostring(artifactId) then
 	-- 	self:theMiddleDataView(itemData)
 		baseCell.panel_xuan:setVisible(true)
 	end

 	self.cellitem[itemData.id] = baseCell

	baseCell:setTouchedFunc(c_func(self.theMiddleDataView, self,itemData),nil,true);

	-- self:numView()

end
--中间显示列表
--[[ = {
		id = 101,
		quality = 0,
		cimelias = {
			"1001" = {
				id = 1001,
				quality = 1,
			},
			"1002" = {
				id = 1002,
				quality = 7,
			},
		},]]
-- function ArtifactMainView:()
	
-- end



function ArtifactMainView:theMiddleDataView(itemData,file,isfresh)
	-- dump(itemData,"1111111111111111")
	-- echo("========file111=========",file)
	if type(file) == "table" then
		if self.seleCellId == itemData.id then
			return 
		end
	end
	
	local CCInfo =  FuncArtifact.byIdgetCCInfo(itemData.id)
	local colortype = CCInfo.combineColor
	self:initBg(colortype)
	self.mc_story:showFrame(colortype -1 )
	self.seleCellId = itemData.id
	ArtifactModel:setselectArID(self.seleCellId)

	-- echo("==========0000000000============",self.seleCellId)
	local quality = itemData.quality
	local artifactId = itemData.id
	local artifactalldata = FuncArtifact.byIdgetcombineUpInfo(artifactId)--byIdgetCCInfo
	local ccinfo = FuncArtifact.byIdgetCCInfo(artifactId)
	local cimelias = itemData.cimelias or {}
	local artifactdata = nil
	-- 中间添加图片例会
 	local spineSpine = self:middleLayerImage()
 	local spnode = display.newNode():pos(0,0):anchor(0.5,0.5)
    spnode:size(220,220)
    self.ctn_1:addChild(spnode)
	if quality == 0 then  ---未获取的时候  中间的图片
		artifactdata = artifactalldata[tostring(1)]   --默认取第一个
		-- spnode:setTouchedFunc(c_func(self.ActivationButton, self,itemData),nil,true);
		-- FilterTools.setGrayFilter(spnode)
	else
		-- spnode:setTouchedFunc(c_func(self.AdvancedButtonCallBack, self,quality),nil,true);
		artifactdata = artifactalldata[tostring(quality)]   --默认取第一个
		-- FilterTools.clearFilter(spnode)
	end
	-- dump(artifactdata,"1111111111111")
	local contain_table = ccinfo.contain   --多少个宝物以
	-- for i=1,10 do  --设置6个位置为setvisibla(false)
	-- end
	-- local  ccinfo.combineColor
	local frames = 1
	local numbers = #contain_table
	if numbers == 6 then
		self.mc_1:showFrame(1)
		frames = 1
	elseif numbers == 4 then
		self.mc_1:showFrame(2)
		frames = 2
	elseif numbers == 5 then
		self.mc_1:showFrame(4)
		frames = 4
	else
		self.mc_1:showFrame(3)
		frames = 3
	end
-- dump(contain_table,"1111111111111")
	local addbgQ = self.mc_1:getViewByFrame(frames)
	for i=1,#contain_table do
		local commui =  self.mc_1:getViewByFrame(frames)["panel_kuang"..i]
		local cimeliaid = contain_table[i]
		local cimeliadata = FuncArtifact.byIdgetsingleInfo(cimeliaid)
		local name = GameConfig.getLanguage(cimeliadata.name)
		local icon = cimeliadata.icon
		-- local artifactid =  cimeliadata.itemId
		commui.ctn_1:removeAllChildren()
		local sprite = display.newSprite(FuncRes.iconCimelia( icon ))
		sprite:setScale(0.45)
		commui.ctn_1:addChild(sprite)
		local color = cimeliadata.color
		commui.mc_2:showFrame(color-1)
		
		commui.mc_1:showFrame(color-1)
		-- echo("============i===",i)
		commui.panel_red:setVisible(false)
		local artifactid =  cimeliadata.itemId

		local number = ItemsModel:getItemNumById(artifactid)
		-- local types = 1
		-- local itemdata = types..","..artifactid..","..number
		-- commui:setResItemData({reward = itemdata})
		-- commui:showResItemName(true)
	 --    -- 显示数量
	 --    commui:showResItemNum(false)
	 --    commui:showResItemNameWithQuality()
	    -- echo("========name==========",name)
	    -- commui:setTouchedFunc(function ()end,nil,true);
	    if cimelias[tostring(cimeliaid)] ~= nil then
			local _quality = cimelias[tostring(cimeliaid)].quality
			-- commui.panelInfo.mc_zi.currentView.txt_1:setString(name.."+"..quality)

			local txt_1 = commui.mc_2:getViewByFrame(color-1).txt_1

			FilterTools.clearFilter(sprite)
			FilterTools.clearFilter(txt_1)

			commui.panel_lv:setVisible(false)
			commui.mc_1:setTouchedFunc(c_func(self.ToDoInAdvancedView, self,cimeliaid),nil,true);
			local isshow,_type,names = ArtifactModel:getSingleAdvancedRed(cimeliaid)
			-- commui:showResItemRedPoint(isshow)
			commui.panel_red:setVisible(isshow)
			commui.panel_1:setVisible(true)
			commui.panel_1.mc_2:showFrame(color)
			commui.panel_1.mc_2:getViewByFrame(color).txt_1:setString("+".._quality)
			txt_1:setString(name)--.."+"..quality)
			-- addbgQ["panel_"..i].mc_kuang:showFrame(cimeliadata.color)
		else
			local txt_1 = commui.mc_2:getViewByFrame(color-1).txt_1
			FilterTools.setGrayFilter(sprite)
			FilterTools.setGrayFilter(txt_1)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             

			if number > 0 then
				commui.panel_lv:setVisible(true)
				commui.panel_lv:setTouchedFunc(c_func(self.addImageActivation, self,itemData,cimeliaid,commui.ctn_1),nil,true);
				-- commui.panelInfo.mc_zi.currentView.txt_1:setString(name)
			else
				commui.panel_lv:setVisible(false)
				-- commui.panelInfo.mc_zi.currentView.txt_1:setString(name)
				commui.mc_1:setTouchedFunc(c_func(self.getWayListView, self,cimeliadata.itemId),nil,true);
			end
			txt_1:setString(name)
			commui.panel_1:setVisible(false)
		end
		-- commui:setTouchedFunc(c_func(self.ToDoInAdvancedView, self,cimeliaid),nil,true);
	end

	-- dump(artifactdata,"2222222222222222222222")
	local colorframe = ccinfo.combineColor
	local name = ccinfo.combineName
	local  stname = GameConfig.getLanguage(name)
	if quality ~= 0 then
		stname = stname.."+"..quality
	end
	self.mc_name:showFrame(colorframe)
	self.mc_name:getViewByFrame(colorframe).txt_1:setString(stname)
	-- self.panel_story1:setVisible(false)
 	-- self.panel_story:setVisible(false)
 	if not isfresh then
		self:TheLeftView(itemData)
	end
	self:getSelectcell(itemData)
	self:showShareButton()
end

function ArtifactMainView:getSelectcell(itemData)
	-- dump(itemData,"333333333333333")
	for k,v in pairs(self.cellitem) do
		if v.panel_xuan then
			if k == itemData.id then
				v.panel_xuan:setVisible(true)
			else
				v.panel_xuan:setVisible(false)
			end
		end
	end
end



function ArtifactMainView:middleLayerImage()
	local spine = FuncArtifact.addChildMiddle(self.ctn_1,self.seleCellId)
	return spine
end
function ArtifactMainView:addImageActivation(itemData,cimeliaid,_ctn)

	-- dump(itemData,"22222222222222222")
	local isok,_type,name = ArtifactModel:getSingleAdvancedRed(cimeliaid)
	if isok == false then
		if _type == FuncArtifact.errorType.NOT_ITEM_NUMBER then
			local name = GameConfig.getLanguage(name)
			local _str = GameConfig.getLanguage("#tid_shenqi_020")
			WindowControler:showTips("<color=da611a>"..name.."<->".._str)
			return 
		elseif _type == FuncArtifact.errorType.MEET_CONDITIONS then
			WindowControler:showTips(GameConfig.getLanguage("#tid_shenqi_005"))
			return 
		end
	end
	local orderpreview,nextattr,allnextattr = ArtifactModel:getSingleAdvancedAttribute(cimeliaid) 
	self:disabledUIClick()
	local function _callback(_param)
		dump(_param.result,"单个进阶结果",10)
		if (_param.result ~= nil) then
			self:theMiddleDataView(itemData,true)
			local function endcallback()
				local function callBack()
					-- self:addArrEffectOne(itemData)
					self.addEffectArr =  true
					-- self:theMiddleDataView(itemData,true)
					self:RightListResShow(itemData)
					self:buttonRedShow()
					self:sumAttrNumber()
					self:showShareButton()
					self:resumeUIClick()

				end
				ArtifactModel:showNumberEff(self.ctn_num,orderpreview,nextattr,callBack)
			end
			self.addEffectArrRefresh =  true
			self:addSingleEffect(_ctn,endcallback)
		else
			if _param.error ~= nil then
				local error_code = _param.error.code 
				local tip = GameConfig.getErrorLanguage("#error"..error_code)
				WindowControler:showTips(tip)
			end
			self:resumeUIClick()
   		end
    end
	local params = {}
	params.cimeliaId = tostring(cimeliaid)
	ArtifactServer:SingleAdvanced(params, _callback)

end

---添加属性特效1
function ArtifactMainView:addArrEffectOne(itemData)
	local scroll_2 = self.panel_zuo.panel_down.scroll_1
	local effect = scroll_2:getChildByName("saoguang")
	if not effect then
		effect = self:createUIArmature("UI_tishitexiao", "UI_tishitexiao_saoguang" ,scroll_2, false ,function ()
			self:theMiddleDataView(itemData,true)
			self:RightListResShow(itemData)
			self:buttonRedShow()
			self:sumAttrNumber()
			self:RefreshAbility()
			self:showShareButton()
			self:resumeUIClick()
			effect:setVisible(false)
		end )
		effect:setName("saoguang")
		effect:setScaleY(10)
		effect:setScaleX(1.25)
		effect:setPosition(cc.p(175,55))
	end
	effect:setVisible(true)
	effect:startPlay(false, true )
end


--添加单个激活消耗特效
function ArtifactMainView:addSingleEffect(_ctn,_callback)
	FuncArtifact.playSArtifactActiveSound()
	local flaName = "UI_shenqi_jinjie"
	local armatureName = "UI_shenqi_jinjie_xiaohao"
	local ctn = _ctn
	local aim = self:createUIArmature(flaName, armatureName ,ctn, false ,function ()
		
	end )
	aim:registerFrameEventCallFunc(15,1,function ()
		if _callback ~= nil then
			_callback()
		end
	end)
	-- aim:setScale(0.82)
	aim:startPlay(false, true )  --子动画停止
end




function ArtifactMainView:getItemDataIndex(itemData)
	for i=1,#self.alldata do
		if itemData.id == self.alldata[i].id then
			return i
		end
	end
end
function ArtifactMainView:RightListResShow(itemData)
	-- dump(itemData,"进阶道具")
	local alllist = self.panel_1.scroll_1:getAllView()
	local index = self:getItemDataIndex(itemData) 
	local isShowRed,_type = ArtifactModel:ByCCIDgetAdvancedRedShow(itemData.id)
	local isok,_type,itemname = ArtifactModel:ByCCIDgetAdvanced(self.seleCellId)
	echo("======isShowRed======",isShowRed,_type)
	-- local isok,_type,name = ArtifactModel:getSingleAdvancedRed(itemData.id)
	if alllist[index] then
		alllist[index].panel_red:setVisible(isShowRed or isok)
	end
end

--最左边的视图结构
function ArtifactMainView:TheLeftView(itemData,isRefresh)

	local armatureName = {
		[2] = "UI_shenqi_chouka_d_lvse",
		[3] = "UI_shenqi_chouka_d_lanse",
		[4] = "UI_shenqi_chouka_d_huangse",
		[5] = "UI_shenqi_chouka_d_zise",
	}
	-- self.panel_zuo.btn_1:getUpPanel().panel_red:setVisible(false)
	local isok,_type,itemname = ArtifactModel:ByCCIDgetAdvanced(self.seleCellId)
	self.mc_btn:getViewByFrame(1).btn_1:getUpPanel().panel_red:setVisible(isok)
	local quality = itemData.quality 
	local artifactId = itemData.id
	local artifactalldata = FuncArtifact.byIdgetCCInfo(artifactId)--组合神器数据
	local skilldata =  FuncArtifact.byIdgetcombineUpInfo(artifactId)--组合神器进阶数据
	-- local artifactdata = nil
	local skilltable = nil
	if quality == 0 then  ---未获取的时候
		-- artifactdata = artifactalldata[tostring(1)]   --默认取第一个
		skilltable = skilldata[tostring(1)]
	else
		-- artifactdata = artifactalldata[tostring(quality)]   --默认取第一个
		skilltable = skilldata[tostring(quality)]
	end
	local artifactname = GameConfig.getLanguage(artifactalldata.combineName)  --组合名称
	local skillname = GameConfig.getLanguage(artifactalldata.skillName)  --组合技能名称
	local skillicon = artifactalldata.skillIcon  --组合技能图标
	local skilldes = artifactalldata.combineSkillDes  --组合技能描述
	if quality ~= 0 then
		artifactname = artifactname.."+"..quality
		-- skillname = skillname.."+"..quality
	end
	--单个组合总战力
	local powernumber = ArtifactModel:getSinglePower(artifactId)
	-- echo("========战力=========",powernumber)
	self.panel_zuo.panel_power.UI_number:setPower(powernumber)
	local colorframe = artifactalldata.combineColor
	self.panel_zuo.mc_name:showFrame(colorframe)
	local artifactalldata = FuncArtifact.byIdgetCCInfo(artifactId)
	local name = artifactalldata.combineName
	local  stname = GameConfig.getLanguage(name)
	if quality ~= 0 then
		stname = stname.."+"..quality
	end
	self.panel_zuo.mc_name:getViewByFrame(colorframe).txt_1:setString(stname)
	self.panel_zuo.mc_level:setVisible(false)

	local data = skilltable
	local kind = data.kind
	local _quility = quality


	self:skillAttrTiHuan(skilltable,skilltable.quality)
	-- self.panel_zuo.panel_1.txt_name:setString(skillname)
	self.panel_zuo.txt_name:setString(skillname)
	self.panel_zuo.panel_1.txt_name:setString("等级"..quality)
	self.panel_zuo.panel_1.ctn_1:removeAllChildren()
	if skillicon ~= nil then

		local imagename =	FuncRes.iconSkill(skillicon)
		local sprites = display.newSprite(imagename)
		self.panel_zuo.panel_1.ctn_1:addChild(sprites)
		if quality == 0 then
			FilterTools.setGrayFilter(sprites)
			self.panel_zuo.panel_1.txt_name:setVisible(false)
		else
			FilterTools.clearFilter(sprites)
			self.panel_zuo.panel_1.txt_name:setVisible(true)
		end
		-- sprites:setTouchedFunc(c_func(self.showSkillTips, self,artifactId),nil,true);
	else
		echoError("没有技能资源图片，表里没配，找金钊 技能组合所在ID",artifactId)
	end
	self.panel_zuo.panel_1:setTouchedFunc(c_func(self.ShowSkillInfoTip, self,artifactId),nil,true);
	

	local highnum = self.panel_zuo.rich_12.numLines
	if highnum == 3 then
		-- 设置滑块根据文字行数显示
		self.panel_zuo.panel_down:setPositionY(-218.95)
	else
		self.panel_zuo.panel_down:setPositionY(-238.95)
	end

	-- echo("神器的品质为:"..skilltable.quality)
	-- dump(artifactalldata,"当前神器数据:")
	self.mc_btn:showFrame(1)
	self.mc_btn:getViewByFrame(1).btn_1:setVisible(true)
	self.mc_btn.currentView.btn_1:getUpPanel().mc_1:showFrame(artifactalldata.combineColor-1)

	if quality >= FuncArtifact.Fullorder then
		self.mc_btn:showFrame(2)
		-- self.panel_zuo.btn_1:setVisible(false)
		-- self.panel_zuo.btn_1:getUpPanel().txt_1:setString("已满阶")
		-- self.panel_zuo.btn_1:setTap(c_func(self.AdvancedButtonCallBack, self,quality));
	else
		echo("========colorframe====11111====",colorframe,quality)
		local button = self.mc_btn:getViewByFrame(1).btn_1
		local _effect = button:getChildByName("shenqi_shaoguan")--armatureName[colorframe])
		if not _effect then
			local startAni = self:createUIArmature("UI_shenqi_chouka_d", armatureName[colorframe], button, true, GameVars.emptyFunc)
			startAni:setPosition(cc.p(85,-40))
			startAni:setName("shenqi_shaoguan")
			startAni:getBoneDisplay("layer6"):setVisible(false)
		end

		if quality == 0 then  ---激活

			button:setTap(c_func(self.ActivationButton, self,itemData));
			-- local children = button:getChildren()
			-- children:setVisible(false)
			local ccId = self.seleCellId
			local isok,_type,itemname = ArtifactModel:ByCCIDgetAdvanced(ccId)
			if isok == false then
				if _type == FuncArtifact.errorType.NOT_CONDITIONS then
					-- FilterTools.setGrayFilter(button)
					button:getUpPanel().mc_1:showFrame(colorframe-1)
				end

				local _effect1 = button:getChildByName("shenqi_shaoguan")
				if _effect1 then
					_effect1:setVisible(false)
				end

			else
				-- FilterTools.clearFilter(button)
				button:getUpPanel().mc_1:showFrame(colorframe+3)
				local _effect2 = button:getChildByName("shenqi_shaoguan")
				if _effect2 then
					_effect2:setVisible(true)
				end
			end

			button:getUpPanel().mc_1.currentView.txt_1:setString(GameConfig.getLanguage("#tid_shenqi_004"))

		else   ---进阶

			button:getUpPanel().mc_1:showFrame(colorframe+3)
			local isok,_type,itemname = ArtifactModel:ByCCIDgetAdvanced(self.seleCellId)
			if isok == false then
				if _type == FuncArtifact.errorType.NOT_CONDITIONS then
					button:getUpPanel().mc_1:showFrame(colorframe+3)
				elseif _type == FuncArtifact.errorType.NOT_ITEM_NUMBER then 
					button:getUpPanel().mc_1:showFrame(colorframe+3)
				end
				local _effect3 = button:getChildByName("shenqi_shaoguan")
				if _effect3 then
					_effect3:setVisible(false)
				end
				button:setTap(c_func(self.showNotDoneTip, self,quality));
			else
				local _effect4 = button:getChildByName("shenqi_shaoguan")
				if  _effect4 then
					_effect4:setVisible(true)
				end
				button:setTap(c_func(self.AdvancedButtonCallBack, self,quality));
			end
			button:getUpPanel().mc_1.currentView.txt_1:setString(GameConfig.getLanguage("#tid_shenqi_003"))
		end
	end


	if not isRefresh then
		self:AllAttrList(itemData)
	end
	self:numView()


end
--技能属性替换
function ArtifactMainView:skillAttrTiHuan(itemData,skillLevel)
	if tonumber(skillLevel) == 0 then
		skillLevel = 1
	end
    local des = FuncArtifact.byIdgetCCInfo(itemData.combineId).combineSkillDes
	local skillsArrtStr = FuncPartner.getCommonSkillDesc(itemData,tonumber(skillLevel),des)
	self.panel_zuo.rich_12:setString(skillsArrtStr)
end

function ArtifactMainView:ActivationButton(itemData)
	local ccId = self.seleCellId
	local oldpower = ArtifactModel:getSinglePower(ccId)
	ArtifactModel:setoldPower(oldpower)
	-- WindowControler:showWindow("ArtifactCombinSuccess",ccId)
	local isok,_type,itemname = ArtifactModel:ByCCIDgetAdvanced(ccId)
	if isok == false then
		if _type == FuncArtifact.errorType.NOT_CONDITIONS then
			WindowControler:showTips(GameConfig.getLanguage("#tid_shenqi_010"))
		elseif _type == FuncArtifact.errorType.NOT_ITEM_NUMBER then 
			echo("进阶道具不足")
			-- local name = GameConfig.getLanguage(itemname)
			-- WindowControler:showTips("进阶道具<color=da611a>"..name.."<->不足")
		end

		self:addEachEffect()
		return 
	end

	local function callBack(_param)
		-- dump(_param.result,"组合进阶结果",10)
		if (_param.result ~= nil) then
			local function callfun()

				self:addSkillEffect(itemData)
			end
			self:addActiveEffect(callfun)
		else
			if _param.error ~= nil then
				local error_code = _param.error.code 
				local tip = GameConfig.getErrorLanguage("#error"..error_code)
				WindowControler:showTips(tip)
			end
   		end
    end
	local params = {}
	params.groupId = tostring(ccId)
	ArtifactServer:CombinationAdvanced(params, callBack)

end

function ArtifactMainView:addSkillEffect(itemData)
	
	local ctn = self.panel_zuo.panel_1.ctn_1
	local aim = self:createUIArmature("UI_tishitexiao", "UI_tishitexiao_shan01" ,ctn, false ,function ()
		self:initData()
		self:theMiddleDataView(itemData,true)
		self:TheLeftView(itemData,true)
		self:RefreshAbility()
	end )

end





ArtifactMainView.AdvancedType = {
	[3] = {"UI_shenqi_jinjie_a",3},
	[4] = {"UI_shenqi_jinjie_b",2},
	[5] = {"UI_shenqi_jinjie_d",4},
	[6] = {"UI_shenqi_jinjie_c",1},
}

--添加激活整件法宝特效
function ArtifactMainView:addActiveEffect(_callback)
	FuncArtifact.playCCArtifactActiveSound()
	local artifactId = self.seleCellId
	local ccinfo = FuncArtifact.byIdgetCCInfo(artifactId)
	local contain_table = ccinfo.contain   --多少个宝物以
	local num = #contain_table
	-- if num == 5 then
	-- 	-- WindowControler:showTips(GameConfig.getLanguage("#tid_shenqi_011"))
	-- 	self:RefreshAbility()
	-- 	if _callback then
	-- 		_callback()
	-- 	end
	-- 	return 
	-- end
	local frame = ArtifactMainView.AdvancedType[num][2]
	for i=1,num do
		local commui =  self.mc_1:getViewByFrame(frame)["panel_kuang"..i]
		local _ctn = commui.ctn_1
		self:addSingleEffect(_ctn)
	end
	local flaName = "UI_shenqi_jinjie"
	local armatureName = ArtifactMainView.AdvancedType[num][1]
	local aim = self:createUIArmature(flaName, armatureName ,self.ctn_1, false ,function ()

	end )

	aim:registerFrameEventCallFunc(13,1,function ()
		local zaims = self:createUIArmature(flaName, "UI_shenqi_jinjie_zhakai" ,self, false ,function ()
			-- self:RefreshAbility()
		end )
		local  x = self.ctn_1:getPositionX()
		local  y = self.ctn_1:getPositionY()
		zaims:setPosition(cc.p(x,y))
		zaims:registerFrameEventCallFunc(15,1,function ()
			-- WindowControler:showTips(GameConfig.getLanguage("#tid_shenqi_011"))
			WindowControler:showWindow("ArtifactActivationSuccess",artifactId,_callback)
			-- if _callback then
			-- 	_callback()
			-- end
		end)
		zaims:startPlay(false, true )  --子动画停止
	end)
	aim:startPlay(false, true )  --子动画停止

end




function ArtifactMainView:AllAttrList(itemData)
	local ccid = itemData.id
	-- local contain = FuncArtifact.byIdgetCCInfo(ccid).contain
	-- for i=1,#contain do
	-- 	local artifactId = contain[i]
	-- 	local  ArtifactModel:getSingleInitAttr(artifactId)
	-- end


	self.panel_zuo.panel_down.panel_jjsx:setVisible(false)
	local attrList =  ArtifactModel:getSingleInitAttr(ccid)
	local attrList2 =  ArtifactModel:getSingleInitAttr(ccid,true)

	for i=1,#attrList do
		attrList[i].nextValue = attrList[i].value
		for j=1,#attrList2 do
			if attrList2[j] then
				if attrList[i].key == attrList2[j].key then
					attrList[i].nextValue = attrList2[j].value
					break
				end
			end
		end
	end
	self.arrtEffecTable = {}
	self.allAttrList = attrList
	local createLeftItemFunc = function(itemData,index)
    	local baseCell = UIBaseDef:cloneOneView(self.panel_zuo.panel_down.panel_jjsx);
        self:cellLeftviewData(baseCell, itemData,index)
        return baseCell;
    end

    local  _scrollParams = {
        {
            data = attrList,
            createFunc = createLeftItemFunc,
            -- updateFunc= updateFunc,
            perNums = 1,
            offsetX = 50,
            offsetY = 10,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -40, width = 150, height = 23},
            perFrame = 0,
        }
    }    
    self.index = 1
    self.panel_zuo.panel_down.scroll_1:styleFill(_scrollParams);
    self.panel_zuo.panel_down.scroll_1:cancleCacheView();
    self.panel_zuo.panel_down.scroll_1:hideDragBar() 
    
    if #attrList == 0 then
    	self.panel_zuo.panel_down.txt_1:setVisible(true)
    	self.panel_zuo.panel_down.txt_1:setString(GameConfig.getLanguage("#tid_ranklist_003"))
    else
    	self.panel_zuo.panel_down.txt_1:setVisible(false)
    	if not self.addEffectArr then
    		self.panel_zuo.panel_down.scroll_1:gotoTargetPos(#attrList, 1 ,2)
    	else
    		self.panel_zuo.panel_down.scroll_1:gotoTargetPos(1, 0 ,2)
    	end
    end

    self.panel_zuo.panel_down.panel_ewtx:setVisible(false)	
    local ccListdata = ArtifactModel:getCCAttrlistTable(ccid)

    local createLeftItemFunc2 = function(itemData)
    	local baseCell = UIBaseDef:cloneOneView(self.panel_zuo.panel_down.panel_ewtx);
        self:cellLeftviewData2(baseCell, itemData)
        return baseCell;
    end


    local  _scrollParams2 = {}
    for i=1,#ccListdata do
    	local des = GameConfig.getLanguage(ccListdata[i].skillUpDes)
    	local height,lengthnum = FuncCommUI.getStringHeightByFixedWidth(des,20,nil,220)
    	local pames =   {
            data = {ccListdata[i]},
            createFunc = createLeftItemFunc2,
            -- updateFunc= updateFunc,
            perNums = 1,
            offsetX = 0,
            offsetY = 10,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -(height+5), width = 155, height = height+5},
            perFrame = 0,
        }
  		table.insert(_scrollParams2,pames)
    end

    self.panel_zuo.panel_down.scroll_2:cancleCacheView();
    self.panel_zuo.panel_down.scroll_2:styleFill(_scrollParams2);
    self.panel_zuo.panel_down.scroll_2:hideDragBar()

    -- self.panel_1.btn_guize:setTouchedFunc(c_func(self.ShowShuXingTip, self, ccid),nil,true);

    local max = 1
	for i=1,#ccListdata do
		local quality = ArtifactModel:getCimeliaCombinequality(ccid)
		-- echo("=====quality==========",quality,ccListdata[i].quality)
		if quality <  ccListdata[i].quality then
			max = i
			break
		end
    end
	self.panel_zuo.panel_down.scroll_2:gotoTargetPos(1, max ,1)

end




function ArtifactMainView:cellLeftviewData(baseCell,itemData,index)
	--[[
	{
		key"   = 2
		"mode"  = 1
		"value" = 100
		"nextValue" = 200
	}
	]]

	local des = ArtifactModel:getDesStaheTable(itemData,false)

	baseCell:setVisible(true)
	baseCell.rich_1:setString(des)
	local str = itemData.value
	local str2 = itemData.nextValue
    if itemData.mode == 2 or itemData.mode == 3 then   ---百分比
	    local desvalue = itemData.value/100
	    str = desvalue.."%"
	    if itemData.nextValue then
		    local desvalue2 = itemData.nextValue/100
		    str2 = desvalue2.."%"
		end
	end
	baseCell.rich_2:setString("<color=008c0d>"..str.."<->")
	baseCell.rich_3:setString("<color=008c0d>"..str2.."<->")

	if self.addEffectArr  then
		self.arrtEffecTable[index] = baseCell
		baseCell:setVisible(false)
		if index == #self.allAttrList then
			self.addEffectArr = false
			self:playarrtEffect(1)
		end
	end

end



function ArtifactMainView:playarrtEffect(index)
	if self.arrtEffecTable  then
		local baseCell = self.arrtEffecTable[index]
		if baseCell then
			baseCell:setVisible(true)
			local effect = baseCell:getChildByName("jiemian_fankui")
			if not effect then
				effect = self:createUIArmature("UI_shenqi_jiemian", "UI_shenqi_jiemian_fankui" ,baseCell, false ,function ()
					
				end )
				effect:setName("jiemian_fankui")
			end
			effect:registerFrameEventCallFunc(7,1,function ()
				self:playarrtEffect(index + 1)
				self.panel_zuo.panel_down.scroll_1:gotoTargetPos(index, 1 ,0,0.4)
			end)
			effect:setPosition(cc.p(140,-15))
			effect:setVisible(true)
			effect:startPlay(false, true )
		else
			self:RefreshAbility()
		end
	else

	end
end




function ArtifactMainView:cellLeftviewData2( baseCell, itemData )

	local quality = ArtifactModel:getCimeliaCombinequality(itemData.ccid)
	local des = GameConfig.getLanguage(itemData.skillUpDes)
	local namestr =  "等级"..itemData.quality
	local _str = des--attrname.."+"..valuer.."("..des..")"
	local color = "<color=8C9695>"
	if quality >= itemData.quality then 
		-- Frame = 1
		-- baseCell:showFrame(Frame)
		color = "<color=008c0d>"
	-- elseif itemData.quality == (quality + 1) then  --下一个阶级显示黄色
		-- Frame  = 2
		-- baseCell:showFrame(Frame)
		-- color = "<color=89674B>"
	end
	baseCell.rich_1:setString(color..namestr.."<->")
	baseCell.rich_2:setString(color.._str.."<->")
end

function ArtifactMainView:getWayListView(itemid)
	WindowControler:showWindow("GetWayListView",itemid)
end
--抽卡按钮调用
function ArtifactMainView:ThatCardCallBack()
	echo("----------抽卡界面调用----------")
	WindowControler:showWindow("ArtifactDrawCardView");
end

--点击技能弹tips
function ArtifactMainView:ShowSkillInfoTip(cimeliaid)
	echo("------------点击技能弹tips-------")
	WindowControler:showWindow("ArtifactSkillTipsView",cimeliaid)
	
end
--属性说明界面
function ArtifactMainView:ShowShuXingTip( data )
	echo("------------点击问号弹tips-------")
	WindowControler:showWindow("ArtifactReasureView",data)
end
--进阶按钮回调
function ArtifactMainView:AdvancedButtonCallBack(quality)
	echo("----------进阶按钮回调--------")
	-- if quality >= FuncArtifact.Fullorder then
	-- 	WindowControler:showTips("已经是满阶")
	-- else
		-- WindowControler:showWindow("ArtifactCombinationView",self.seleCellId);
	-- end

	local ccId = self.seleCellId

	echo("=============组合进阶按钮===========",ccId)
	local newquality =  ArtifactModel:getCimeliaCombinequality(ccId)
	if newquality >= FuncArtifact.Fullorder then
		WindowControler:showTips(GameConfig.getLanguage("#tid_shenqi_005"))
		return 
	end
	
	local oldpower = ArtifactModel:getSinglePower(ccId)
	ArtifactModel:setoldPower(oldpower)
	-- WindowControler:showWindow("ArtifactCombinSuccess",ccId)
	local isok,_type,itemname,itemid  = ArtifactModel:ByCCIDgetAdvanced(self.seleCellId)
	if isok == false then
		if _type == FuncArtifact.errorType.NOT_CONDITIONS then
			local ccId = self.seleCellId  --组合技能ID
			local newquality =  ArtifactModel:getCimeliaCombinequality(ccId)
			local ccInfo = FuncArtifact.byIdgetcombineUpInfo(ccId)
			local conditionDes = GameConfig.getLanguage(ccInfo[tostring(newquality+1)].conditionDes)
			WindowControler:showTips(conditionDes)
		elseif _type == FuncArtifact.errorType.NOT_ITEM_NUMBER then 
			local name = GameConfig.getLanguage(itemname)
			local _str = string.format(GameConfig.getLanguage("#tid_shenqi_017"),name)
			WindowControler:showTips(_str)
			echo("==========itemid========",itemid)
			WindowControler:showWindow("GetWayListView",itemid)
		end
		return 
	end

	local function callBack(_param)
		-- dump(_param.result,"组合进阶结果",10)
		if (_param.result ~= nil) then
			-- local rewards = _param.result.data.dirtyList.rewards
			-- FuncArtifact.playCCArtifactActiveSound()
			-- self:AdvancedButtonRedShow()
			local function callBack()
				self:RefreshAbility()
				self:addArrEffectTwo()
				-- self:initData()
			end

			WindowControler:showWindow("ArtifactCombinSuccess",ccId,callBack)
		else
			if _param.error ~= nil then
				local error_code = _param.error.code 
				local tip = GameConfig.getErrorLanguage("#error"..error_code)
				WindowControler:showTips(tip)
			end
   		end
    end
	local params = {}
	params.groupId = tostring(ccId)
	ArtifactServer:CombinationAdvanced(params, callBack)
end


--添加属性特效
function ArtifactMainView:addArrEffectTwo()

	local scroll_2 = self.panel_zuo.panel_down.scroll_2
	local ccId = self.seleCellId
	local ccListdata = ArtifactModel:getCCAttrlistTable(ccId)
	local dataView =  scroll_2:getAllView()
	local quality = ArtifactModel:getCimeliaCombinequality(ccId)
	for i=1,#ccListdata do
		if quality == (ccListdata[i].quality) then 
			-- echoError("====1111111========",ccListdata[i].quality,quality,i)
			if dataView[i] then
				local aim = self:createUIArmature("UI_tishitexiao", "UI_tishitexiao_shan02" ,dataView[i], false ,function ()
					-- echoError("====2222222222222========")
					self:initData()
				end )
				aim:setPosition(cc.p(130,-10))
			end
		end
	end

end





--跳转到单个进阶界面
function ArtifactMainView:ToDoInAdvancedView(cimeliaid)
	echo("--------跳转到单个进阶界面----------",cimeliaid)
	WindowControler:showWindow("ArtifactSingleView",cimeliaid);
end

--进阶条件不够时弹出tip
function ArtifactMainView:showNotDoneTip()

	local isok,_type,itemname,itemid  = ArtifactModel:ByCCIDgetAdvanced(self.seleCellId)
	if isok == false then
		if _type == FuncArtifact.errorType.NOT_CONDITIONS then
			local ccId = self.seleCellId  --组合技能ID
			local newquality =  ArtifactModel:getCimeliaCombinequality(ccId)
			local ccInfo = FuncArtifact.byIdgetcombineUpInfo(ccId)
			local conditionDes = GameConfig.getLanguage(ccInfo[tostring(newquality+1)].conditionDes)
			WindowControler:showTips(conditionDes)
		elseif _type == FuncArtifact.errorType.NOT_ITEM_NUMBER then 
			local name = GameConfig.getLanguage(itemname)
			local _str = string.format(GameConfig.getLanguage("#tid_shenqi_017"),name)
			WindowControler:showTips(_str)
			echo("==========itemid========",itemid)
			WindowControler:showWindow("GetWayListView",itemid)
		end
	end
	self:addEachEffect()

	-- local ccId = self.seleCellId
	-- local newquality =  ArtifactModel:getCimeliaCombinequality(ccId)
	-- local ccInfo = FuncArtifact.byIdgetcombineUpInfo(ccId)
	-- local conditionDes = GameConfig.getLanguage(ccInfo[tostring(newquality+1)].conditionDes)
	-- WindowControler:showTips(conditionDes)
end


--下方进阶道具展示
function ArtifactMainView:numView()
	local ccId = self.seleCellId  --组合技能ID
	local newquality =  ArtifactModel:getCimeliaCombinequality(ccId)
	local info = FuncArtifact.byIdgetCCInfo(ccId)
	local name = GameConfig.getLanguage(info.combineName)
	local quality = newquality
	if quality>= FuncArtifact.Fullorder then 
		self.panel_num1:setVisible(false)
		self.panel_num2:setVisible(false)
	end
	-- for i=1,2 do
	-- 	self["UI_"..(i+4)]:setVisible(false)
	-- 	self["txt_goodsshuliang"..i]:setVisible(false)
	-- end

	if quality ~= 0 then
		name = name.."+"..quality
		-- self.panel_c:setVisible(true)
		-- self.panel_c.txt_1:setString("+"..quality)
		if quality >= FuncArtifact.Fullorder then
			quality = quality - 1
		end
	end
	local ccInfo = FuncArtifact.byIdgetcombineUpInfo(ccId)
	if newquality < FuncArtifact.Fullorder then  --满阶
		-- dump(ccInfo,"1111111111111111111")
		-- echo("神器品级:"..quality)

		if quality == 0 then
			self.panel_num1:setVisible(false)
			self.panel_num2:setVisible(false)
			return
		end
		self.mc_btn:showFrame(1)    --setVisible(true)
		if ccInfo[tostring(quality+1)] ~= nil then
			local cost = ccInfo[tostring(quality+1)].cost
			-- dump(cost,"222222222222222")
			for i=1,#cost do
				local itemTOfF = true  ---道具是否足够
				local costtable = string.split(cost[i], ",");
				local types =  costtable[1]
				local itemid = tonumber(costtable[2])
				local neednumbers = tonumber(costtable[3])---消耗数量
				if types == FuncDataResource.RES_TYPE.ITEM then
					-- local iteminfo = FuncItem.getItemData(itemid)  --道具详情
					local havenumber = ItemsModel:getItemNumById(itemid)
					-- if havenumber >= neednumbers then

					-- else
					-- 	itemTOfF = false

					-- end
					local numbers = havenumber.."/"..neednumbers
					self["panel_num"..i]:setVisible(true)
				    self["panel_num"..i]["txt_goodsshuliang"..i]:setVisible(true)
				    self["panel_num"..i]["txt_goodsshuliang"..i]:setString(numbers)
				end
			end
			-- echo("zuobiao"..self["panel_num1"]:getPositionX())
			if #cost == 1 then
				self["panel_num1"]:setPositionX(self.panel_num1_x + 80)
				self.panel_num2:setVisible(false)
			else
				self["panel_num1"]:setPositionX(self.panel_num1_x)
			end
			if quality ~= 0 then
				self.mc_btn:getViewByFrame(1).btn_1:getUpPanel().mc_1.currentView.txt_1:setString(GameConfig.getLanguage("#tid_shenqi_003"))
			else
				self.mc_btn:getViewByFrame(1).btn_1:getUpPanel().mc_1.currentView.txt_1:setString(GameConfig.getLanguage("#tid_shenqi_004"))
			end
			
		end
	else
		-- self.btn_1:setVisible(false)
		self.mc_btn:showFrame(2)
	end
	-- local button = self.mc_btn:getViewByFrame(1).btn_1
	-- FilterTools.clearFilter(button)
	-- button:setTouchedFunc(c_func(self.AdvancedButtonCallBack, self,ccId));
	-- local isok,_type,itemname = ArtifactModel:ByCCIDgetAdvanced(self.cimeliaCombineId)
	-- if isok == false then
	-- 	if _type == FuncArtifact.errorType.NOT_CONDITIONS then
	-- 		FilterTools.setGrayFilter(button)
	-- 	elseif _type == FuncArtifact.errorType.NOT_ITEM_NUMBER then 
	-- 		FilterTools.setGrayFilter(button)
	-- 	end
	-- end
end



function ArtifactMainView:initBg(colortype)

	local bgImage = BG_IMAGES[colortype]
  	self:changeBg(bgImage)
end


function ArtifactMainView:addEachEffect()
	 
	local ccinfo = FuncArtifact.byIdgetCCInfo(self.seleCellId)
	contain_table = ccinfo.contain
	local numbers = #contain_table
	if numbers == 6 then
		frames = 1
	elseif numbers == 4 then
		frames = 2
	elseif numbers == 5 then
		frames = 4
	else
		frames = 3
	end
	local posArr = {}

	local ccinfo = FuncArtifact.byIdgetcombineUpInfo(self.seleCellId)  --组合神器进阶数据表
	local ccquality = ArtifactModel:getCimeliaCombinequality(self.seleCellId)  --组合品质
	local singleCCData = ccinfo[tostring(ccquality+1)]
	if not singleCCData then  --但数据不存在时，直接ruturn
		return 
	end
	local condition =  singleCCData.condition  --进阶条件

	for i=1,#contain_table do
		local conditioninfo = condition[i]
		local artifactid = conditioninfo.cimelia  ---宝物ID
		local artifactquality = conditioninfo.quality
		local groupId = FuncArtifact.byIdgetsingleInfo(artifactid).group
		local currentquality = ArtifactModel:getalldataquality(groupId,artifactid)
		if currentquality < artifactquality then
			table.insert(posArr,i)
		end
	end

	-- dump(posArr,"=============第几个位置的数据")
	-- echo("frames==============",frames)

	for i,v in ipairs(posArr) do
		local commui =  self.mc_1:getViewByFrame(frames)["panel_kuang"..v]
		commui.ctn_eff:removeAllChildren()
		local startAni = self:createUIArmature("UI_shenqi_chouka_d","UI_shenqi_chouka_d_xiaoshenqitishi", commui.ctn_eff, true, function() end)
		startAni:setAllChildAniPlayOnce()
	end



end



function ArtifactMainView:clickButtonBack()
	ArtifactModel:sendHomeviewRed()
	EventControler:dispatchEvent(ArtifactEvent.ACTEVENT_COMBINATION_ADVANCED)
	self:startHide()
end


return ArtifactMainView;
 