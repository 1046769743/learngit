-- Author: Wk
-- Date: 2017-07-22
-- 神器分解系统界面
local ArtifactDecomposeView = class("ArtifactDecomposeView", UIBase);
local itemsize = 90
local itemMoveItem = 5
local offset = 75 --偏移量

function ArtifactDecomposeView:ctor(winName)
    ArtifactDecomposeView.super.ctor(self, winName);
    self.reduceitem = {} --分解的道具
    self.leftitem = {}

end

function ArtifactDecomposeView:loadUIComplete()
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back, UIAlignTypes.RightTop)
 	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_ziyuan, UIAlignTypes.RightTop)
   	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_shop, UIAlignTypes.Right)
   	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_title, UIAlignTypes.LeftTop)
   	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_guize, UIAlignTypes.LeftTop)
   	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_zheng, UIAlignTypes.Right)
   		
   	self.btn_close:setTouchedFunc(c_func(self.clickButtonBack, self),nil,true);
   	self:registClickClose("out")
   	-- self.btn_back:setTouchedFunc(c_func(self.clickButtonBack, self),nil,true);
   	self.btn_shop:setTap(c_func(self.goToInShop, self));
   	-- self.btn_guize:setTap(c_func(self.getRulesView, self));
   	-- self.btn_1:setTap(c_func(self.decompositionCallBack, self));
   
   	self.panel_kuang:setVisible(false)
   	
   	self:addNodeLeftView()
	self:registerEvent()
	self:initData()
	self:shopIsOpen()
	self:addEffectBg()
end 
	

function ArtifactDecomposeView:addEffectBg()
	local _ctn = self.ctn_te
	local flaName = "UI_shenqi_fenjie_beijing"
	local armatureName = "UI_shenqi_fenjie_beijing_beijing"
	local aim = self:createUIArmature(flaName, armatureName ,_ctn, true ,function ()
	end )
end

function ArtifactDecomposeView:shopIsOpen()
	local isopen = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.SHOP_9)
	self.btn_shop:setVisible(true)
	if isopen == false then
		self.btn_shop:setVisible(false)
	end
end
--在左侧加一个node节点
function ArtifactDecomposeView:addNodeLeftView()
	self.addnode = display.newNode()
	self.addnode:setPosition(cc.p(0.5,0.5))
	self.addnode:addTo(self.ctn_1)
end

function ArtifactDecomposeView:registerEvent()
	-- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
end

function ArtifactDecomposeView:initData()
	self.allArtifact = ArtifactModel:getbackpackArtifactItem()
	-- dump(allArtifact,"背包中神器道具的数量",6)
	self.allArtifact = self:getsorting(self.allArtifact)
	-- dump(self.allArtifact,"背包中神器道具的数量",6)
	-- self.panel_zheng.panel_1.UI_1:setVisible(false)
	self.panel_zheng.panel_1:setVisible(false)
	FilterTools.setGrayFilter(self.btn_1)
	self.btn_1:setTap(c_func(self.PutTheAshButton, self));

	self.panel_kede.txt_2:setString(0)
	local str = "已选择了<color=00ff00>0<-> 件"
	self.rich_1:setString(str)
	local createRankItemFunc = function(itemData)
    	local baseCell = UIBaseDef:cloneOneView(self.panel_zheng.panel_1);
        self:cellviewData(baseCell, itemData)
        return baseCell;
    end
     local updateFunc = function (itemData,baseCell)
    	self:cellviewData(baseCell, itemData)
	end

    local  _scrollParams = {
        {
            data = self.allArtifact,
            createFunc = createRankItemFunc,
            updateFunc= updateFunc,
            perNums = 6,
            offsetX = 45,
            offsetY = 45,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -90, width = 100, height = 90},
            perFrame = 0,
        }
    }    

    self.panel_zheng.scroll_1:styleFill(_scrollParams);
    self.panel_zheng.scroll_1:hideDragBar()

end

function ArtifactDecomposeView:cellviewData(baseCell,itemData)

	-- dump(itemData,"111111111111111")
	-- local commui = baseCell.UI_1
	baseCell.btn_1:setVisible(false)

	-- local cimeliaid = contain_table[i]
	-- local cimeliadata = FuncArtifact.byIdgetsingleInfo(cimeliaid)
	-- local name = cimeliadata.name
	
	baseCell.panel_c:setVisible(true)  

	local artifactdata = FuncArtifact.byIdgetsingleInfo(itemData.id)
	local quality = ArtifactModel:getalldataquality(artifactdata.group,itemData.id)
	local color = artifactdata.color
	-- if quality ~= 0 then
	-- 	baseCell.panel_c:setVisible(true)  
	-- 	baseCell.panel_c.mc_2:showFrame(color)
	-- 	baseCell.panel_c.mc_2:getViewByFrame(color).txt_1:setVisible(false)
	-- 	-- baseCell.panel_c.mc_2:getViewByFrame(color).txt_1:setString("+"..quality)
	-- else
		baseCell.panel_c:setVisible(false)  
	-- end
	-- baseCell.panel_c.mc_kuang:showFrame(color)


	local cimeliadata = FuncArtifact.byIdgetsingleInfo(itemData.id)
	local icon = cimeliadata.icon
		-- local artifactid =  cimeliadata.itemId
	local sprite = display.newSprite(FuncRes.iconCimelia( icon ))
	sprite:setScale(0.6)
	baseCell.panel_1.ctn_2:addChild(sprite)
	baseCell.panel_1.mc_kuang2:showFrame(color)
	baseCell.panel_1.mc_kuang:showFrame(color)


	-- local artifactid =  cimeliadata.itemId
	local number = itemData.number--ItemsModel:getItemNumById(artifactid)
	-- local types = 1
	-- local itemdata = types..","..artifactid..","..number
	-- -- echo("======11111========",itemdata)

	-- commui:setResItemData({reward = itemdata})
	-- commui:showResItemName(false)
 --    commui:showResItemNum(true)

 	baseCell.txt_num:setString(number)
    if number ~= 0 then
   	 	baseCell:setTouchedFunc(c_func(self.AddItemToLeftView, self,itemData,baseCell),nil,true);
   	else
   		baseCell:setTouchedFunc(c_func(self.AddItemToLeftViewIsfull, self,itemData),nil,true);
   	end

end
function ArtifactDecomposeView:AddItemToLeftViewIsfull()
	echo("添加已满")
end

--添加
function ArtifactDecomposeView:AddItemToLeftView(itemdata,baseCell)
	-- dump(itemdata,"22222222222")
	if self.reduceitem then
		-- dump(self.reduceitem,"33333333333")
		if table.length(self.reduceitem) >= 20 then
			local isok = false
			for k,v in pairs(self.reduceitem) do
				if v.id == itemdata.id then
					isok = true
				end
			end
			if not isok then
				WindowControler:showTips(GameConfig.getLanguage("#tid_cimelia_tips_01"));
				return 
			end
		end	
	end


	local  itemindex = self:getDataIndex(itemdata)
	local allViewArr = self.panel_zheng.scroll_1:getAllView()
	local cellData = allViewArr[itemindex]
	if cellData ~= nil then
		-- local itemnumber = cellData.UI_1.panelInfo.txt_goodsshuliang:getText()
		-- local _index = self:getDataIndex(itemdata)
		local itemnumber = self.allArtifact[itemindex].number
		if tonumber(itemnumber) ~= 0 then
			self:disabledUIClick()
			-- cellData.UI_1.panelInfo.txt_goodsshuliang:setString(tonumber(itemnumber) - 1)
			cellData.txt_num:setString(tonumber(itemnumber)-1)
			self.allArtifact[itemindex].number = self.allArtifact[itemindex].number - 1
			cellData.btn_1:setVisible(true)
			cellData.btn_1:setTouchedFunc(c_func(self.reduceButtonCallBack, self,itemdata),nil,true);
			local insertitem = {}
			insertitem.id = itemdata.id
			insertitem.number = 1
			if #self.reduceitem == 0 then
				table.insert(self.reduceitem,insertitem)
			else
				local isserve = false
				for i=1,#self.reduceitem do
					if tonumber(self.reduceitem[i].id) == tonumber(itemdata.id) then
						self.reduceitem[i].number = self.reduceitem[i].number + 1
						isserve = true
					end
				end
				if isserve == false then
					table.insert(self.reduceitem,insertitem)
				end
			end
			self:createCellView(baseCell,itemdata)
			--[[  注释：调用不显示移动动画
				self:resumeUIClick()
				self:leftViewData()
				local x,y,callback =self:setLeftItemPos(self.reduceitem,itemData)
				if callback then
					callback()
				end
			--]]
		end
	end

	-- dump(self.reduceitem,"添加道具",6)
	
	

end

--单独创建一个item
function ArtifactDecomposeView:createCellView(baseCell,itemData)
	self.newitem =  UIBaseDef:cloneOneView(baseCell.panel_1) --self.panel_zheng.panel_1.panel_1)
	local artifactdata = FuncArtifact.byIdgetsingleInfo(itemData.id)
	local color = artifactdata.color
	local cimeliadata = FuncArtifact.byIdgetsingleInfo(itemData.id)
	local icon = cimeliadata.icon
	local sprite = display.newSprite(FuncRes.iconCimelia( icon ))
	sprite:setScale(0.6)
	self.newitem.ctn_2:addChild(sprite)
	self.newitem.mc_kuang2:showFrame(color)
	self.newitem.mc_kuang:showFrame(color)
	local pos =  baseCell:convertLocalToNodeLocalPos(self)   --转化为self坐标
	-- local worldpos = self:convertToWorldSpaceAR(cc.p(pos.x,pos.y))  
	self.newitem:setPosition(cc.p(pos.x,pos.y))
	self:addChild(self.newitem)
	self:leftViewData()
	local  inde_x = 0
	for k,v in pairs(self.reduceitem) do
		if v.number ~= 0 then
			inde_x = inde_x + 1
		end
	end
	echo("======inde_x========",inde_x)
	local x,y,callback = self:setLeftItemPos(inde_x,itemData)
	local viewdata  = self.leftitem[itemData.id]
	local viewx = x
	local viewy = y
	echo("=========viewx==============",viewx,viewy)
	if viewdata then
		if viewdata.number ~= 0 then
			viewx = viewdata.view:getPositionX()
			viewy = viewdata.view:getPositionY()
		end
	end
	local  turnPos = self.addnode:convertLocalToNodeLocalPos(self,cc.p(viewx,viewy))
	echo("=========viewy======",viewx,viewy)
    local index = 1
    for k,v in pairs(self.leftitem) do
    	if v.number ~= 0 then
    		index = index + 1
    	end
    end
    local pianyix = 0
    if index >= 2 then
    	local itemnubers = self:getitemNum()
    	local posoffset = self:ByNumberGetoffset(itemnubers)
		local movex = posoffset *(index-1) + itemsize
		pianyix = -(movex/2)+40
	end
	local call = function (  )
		local anim = self:createUIArmature("UI_shenqi_fenjie","UI_shenqi_fenjie_shanguang",self.newitem, false,function ()
			if self.newitem ~= nil then
				self.newitem:removeFromParent()
			end
			self:resumeUIClick( )
			callback()
		end)
		anim:setScale(1.4)
		FuncArmature.setArmaturePlaySpeed( anim ,8)

    end

    
    local moveTime = 0.2
    local act_moveto = act.moveto(moveTime, turnPos.x, turnPos.y)
    local act_call = cc.CallFunc:create(call)
    local act_scalto = act.scaleto(moveTime,0.7)

    local seq = act.sequence(act.spawn(act_scalto,act_moveto),act_call)
    self.newitem:runAction(seq)


end

function ArtifactDecomposeView:getDataIndex(itemdata)
	for i=1,#self.allArtifact do
		if tonumber(self.allArtifact[i].id) == tonumber(itemdata.id) then
			return i
		end
	end
	return 1
end
function ArtifactDecomposeView:getReduceItemIndex(itemdata)
	-- dump(itemdata,"1111111111")
	-- dump(self.reduceitem,"减少的道具11",6)
	if #self.reduceitem ~= 0 then
		for i=1,#self.reduceitem do
			if self.reduceitem[i] ~= nil then
				if tonumber(self.reduceitem[i].id) == tonumber(itemdata.id) then
					return i
				end
			end
		end
	end
	return 1
end

--减少
function ArtifactDecomposeView:reduceButtonCallBack(itemdata)
	local  itemindex = self:getDataIndex(itemdata)
	local allViewArr = self.panel_zheng.scroll_1:getAllView()
	local cellData = allViewArr[itemindex]

	if cellData ~= nil then
		local itemnumber = self.allArtifact[itemindex].number
		-- if tonumber(itemnumber) ~= 0 then
			local _index = self:getReduceItemIndex(itemdata)
			-- cellData.UI_1.panelInfo.txt_goodsshuliang:setString(tonumber(itemnumber) + 1)
			cellData.txt_num:setString(tonumber(itemnumber) + 1)
			self.allArtifact[itemindex].number = self.allArtifact[itemindex].number + 1
			if self.reduceitem[_index] ~= nil then
				self.reduceitem[_index].number = self.reduceitem[_index].number - 1
				if self.reduceitem[_index].number == 0 then
					cellData.btn_1:setVisible(false)
				else
					cellData.btn_1:setVisible(true)
				end
			end
		-- end
	end
	-- dump(self.reduceitem,"减少的道具222",6)
	self:leftViewData()
	local x,y,caback =  self:setLeftItemPos(1)
	caback()
	
end

function ArtifactDecomposeView:leftViewData()
	-- dump(self.reduceitem,"添加道具",6)
	local reduceitemdata = self.reduceitem
	local sumnumner = 0
	self.getNumber = 0
	for i=1,#self.reduceitem do
		if self.reduceitem[i] ~= nil then
			if self.reduceitem[i].number ~= 0 then
				sumnumner = sumnumner + self.reduceitem[i].number
				local artifactInfo = FuncArtifact.byIdgetsingleInfo(self.reduceitem[i].id)
				self.getNumber = self.getNumber + self.reduceitem[i].number*artifactInfo.resolveNum
			end
		end
	end
	-- echo("==========sumnumner=====",sumnumner)

	local str = "已选择了<color=00ff00>"..sumnumner.."<-> 件"

	self.rich_1:setString(str)
	self.panel_kede.txt_2:setString(self.getNumber)
	if sumnumner ~= 0 then
		FilterTools.clearFilter(self.btn_1)
		self.btn_1:setTap(c_func(self.decompositionCallBack, self));
	else
		FilterTools.setGrayFilter(self.btn_1)
		self.btn_1:setTap(c_func(self.PutTheAshButton, self));
	end

end
function ArtifactDecomposeView:PutTheAshButton()
	WindowControler:showTips(GameConfig.getLanguage("#tid_shenqi_006"));
end

function ArtifactDecomposeView:getitemNum()
	local itemnubers = 0
	local reduceitemdata = self.reduceitem

	for i=1,#reduceitemdata do
		if reduceitemdata[i].number > 0 then
			itemnubers = itemnubers + 1
		end
	end
	local newtag = 1
	for i=1,100 do
		for k,v in pairs(self.leftitem) do
			if i == v.tag then
				v.tag = newtag
				newtag = newtag + 1
			end
		end
	end
	return itemnubers
end
--设置左边道具的位置
function ArtifactDecomposeView:setLeftItemPos(itemnum,itemdata)

	-- self.reduceitem
	-- self.UI_1
	

	

	local callbackfun  = function ()
		local  reduceitemdata = self.reduceitem
		local itemnubers = self:getitemNum()
		local posoffsets = self:ByNumberGetoffset(itemnubers)
		
		for i=1,#reduceitemdata do
			local id = tonumber(reduceitemdata[i].id)
			if self.leftitem[id] == nil  then
				if reduceitemdata[i].number > 0 then
					self.leftitem[id] = {}
					self.leftitem[id].tag = itemnubers
					self.leftitem[id].view = UIBaseDef:cloneOneView(self.panel_kuang);
					self:setItemUIData(self.leftitem[id].view,reduceitemdata[i])
					self.leftitem[id].view:setAnchorPoint(cc.p(0.5,0.5))
					local num = reduceitemdata[i].number
					self.leftitem[id].view.txt_num:setString(num)
					-- self.leftitem[id].view:setTouchedFunc(c_func(self.reduceButtonCallBack, self,reduceitemdata[i]),nil,true);
					self.addnode:addChild(self.leftitem[id].view,-1-itemnubers)
					if itemnubers <= itemMoveItem then
						self.leftitem[id].view:setPosition(cc.p((itemnubers-1)*posoffsets,0))
					else 
						self:addNodeagainPos(itemnubers)  ---重新设置坐标
					end
				end
			else
				if reduceitemdata[i].number > 0 then
					self:setItemUIData(self.leftitem[id].view,reduceitemdata[i])
				else

					self.leftitem[id].view:removeFromParent()
					self.leftitem[id] = nil
					self.addnode:setPositionX(0)
					self:addNodeagainPos(itemnubers)  ---重新设置坐标
				end
			end
		end
		local length = table.length(self.leftitem)
		local movex = posoffsets *(length-1) + itemsize
		self.addnode:setPositionX(-(movex/2)+40)
	end


	local itemnubers = self:getitemNum()
	local moveoffset = self:ByNumberGetoffset(itemnum)
	local numindex = 1
	local index = 1
	local newtable = {} 
	if itemdata then
		for i=1,#self.reduceitem do
			if tonumber(self.reduceitem[i].id) == tonumber(itemdata.id) then
				if self.reduceitem[i].number > 1 then
					itemnum = i
				end
			end
		end
	end



	if itemnum == 7 then
		moveoffset = offset
	elseif itemnum == 11 then
		moveoffset = offset/2
	elseif itemnum == 16 then
		moveoffset = offset/3
	end 


	return (itemnum-1)*moveoffset,0,callbackfun
end
function ArtifactDecomposeView:getsorting(alldata)
    local partner_table_sort = function (a,b)
        -- 不知道为什么会传入两个相同的
        local itemData1 =  FuncItem.getItemData(a.id)
        local itemData2 =  FuncItem.getItemData(b.id)
        if tonumber(itemData1.quality) > tonumber(itemData2.quality) then
            return true
        else
        	return false
        end
    end

    table.sort(alldata,partner_table_sort)
    return alldata
end
function ArtifactDecomposeView:addNodeagainPos(itemnubers)
	local posoffset = self:ByNumberGetoffset(itemnubers)
	local _index = 1

	-- self.leftitem = self:getsorting(self.leftitem)
	-- dump(self.leftitem,"11111111111111111")
	-- dump(self.allArtifact,"222222222222222222222222")
	for i=1,#self.allArtifact do
		for k,v in pairs(self.leftitem) do
			if i == v.tag then
				v.view:setPosition(cc.p((_index-1)*posoffset,0))
				v.view:zorder(-_index)  --:zorder(zorder)
				_index = _index + 1
			end
		end
	end
	-- for k,v in pairs(self.leftitem) do
	-- 	v:setPosition(cc.p((_index-1)*posoffset,55))
	-- 	_index = _index + 1
	-- end
end
function ArtifactDecomposeView:ByNumberGetoffset(itemNum)
	-- local itemNum = 0--#reduceitemdata   ---分解多少个神器

	local posoffset = 0
	if itemNum <= 6 then
		posoffset = offset   ---单个固定偏移量
	elseif itemNum <= 10 then
		posoffset = offset/2
	elseif itemNum <= 15 then
		posoffset = offset/3
	else
		posoffset = offset/5
	end
	return posoffset

end
function ArtifactDecomposeView:setItemUIData(uiview,data)
		
	local cimeliadata = FuncArtifact.byIdgetsingleInfo(data.id)
	local artifactid =  cimeliadata.itemId
	local number = data.number--ItemsModel:getItemNumById(artifactid)

	local icon = cimeliadata.icon
		-- local artifactid =  cimeliadata.itemId
	local color = cimeliadata.color
	local sprite = display.newSprite(FuncRes.iconCimelia( icon ))
	sprite:setScale(0.6)
	uiview.ctn_2:removeAllChildren()
	uiview.ctn_2:addChild(sprite)
	uiview.mc_kuang2:showFrame(color)
	uiview.mc_kuang:showFrame(color)
	uiview.txt_num:setString(number)





	-- local types = 1
	-- local itemdata = types..","..artifactid..","..number
	-- -- echo("======11111========",itemdata)
	-- uiview:setResItemData({reward = itemdata})
	-- uiview:showResItemName(false)
 --    uiview:showResItemNum(true)

end


function ArtifactDecomposeView:fenjieEffect(reward)
	local _ctn = self.ctn_te
	local flaName = "UI_shenqi_fenjie"
	local armatureName = "UI_shenqi_fenjie_fenjie"
	local aim = self:createUIArmature(flaName, armatureName ,_ctn, false ,function ()
		self:resumeUIClick()
		WindowControler:showWindow("ArtifactDecomposeSuccess",reward);
		EventControler:dispatchEvent(ArtifactEvent.DECOMPOSE_REFRESH_UI)
		self:initData()
	end )

end


--分解
function ArtifactDecomposeView:decompositionCallBack()
	-- echo("分解按钮")
	-- local reward = {}
	-- reward.id = 29
	-- reward.number = 100
	-- WindowControler:showWindow("ArtifactDecomposeSuccess",reward);
	-- self.reduceitem
	-- if 1 then
	-- 	self:moveToXia()
	-- 	return 
	-- end

	-- dump(self.reduceitem,"分解的宝物")

	local function _callback(_param)
		dump(_param.result,"分解的宝物结果",10)
		if (_param.result ~= nil) then
			FuncArtifact.playArtifactFenJieSound()
			local reward = {
				id = 29,
				number = self.getNumber,
			}
			self:moveToXia(reward)
			
		else
			if _param.error ~= nil then
				local error_code = _param.error.code 
				local tip = GameConfig.getErrorLanguage("#error"..error_code)
				WindowControler:showTips(tip)
			end
   		end
    end

	local decompose = {}
	for i=1,#self.reduceitem do
		local id = tostring(self.reduceitem[i].id)
		if self.reduceitem[i].number ~= 0 then
			decompose[id] = self.reduceitem[i].number 
		end
	end
	-- dump(decompose,"分解的宝物结构")
	local params = {}
	params.decompose = decompose
	ArtifactServer:decompositionSever(params, _callback)
	
end

--向下移动
function ArtifactDecomposeView:moveToXia(reward)

	local end_x = nil
	for k,v in pairs(self.leftitem) do
		local x = v.view:getPositionX()
		if end_x == nil then
			end_x = x
		else
			if x > end_x then
				end_x = x
			end
		end
	end
	for k,v in pairs(self.leftitem) do
		local function func()
			self:disabledUIClick()
			self.addnode:removeAllChildren()
			self.leftitem = {}
			self.reduceitem = {}
			self:fenjieEffect(reward)
			self.addnode:setPosition(cc.p(0,0))
			self.addnode:setScale(1.0)
		end
		local act_call = act.callfunc(func)
		local act_moveto = act.moveto(0.3, end_x/2,-60)
		local  act_scalto = act.scaleto(0.3,0.2)
		local seq = act.sequence(act.spawn(act_scalto,act_moveto),act_call)
		v.view:runAction(seq)
	end



end
function ArtifactDecomposeView:goToInShop()
	echo("跳转到商店")
	local shoptype = FuncShop.SHOP_TYPES.ARTIFACT_SHOP
	WindowControler:showWindow("ShopView",shoptype)
end
function ArtifactDecomposeView:getRulesView()
	echo("跳转到规则界面")
end

function ArtifactDecomposeView:clickButtonBack()
	self:startHide()
end


return ArtifactDecomposeView;
