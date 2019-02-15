-- Author: Wk
-- Date: 2017-07-22
-- 单个神器进阶系统界面

local ArtifactSingleView = class("ArtifactSingleView", UIBase);

function ArtifactSingleView:ctor(winName,cimeliaId)
    ArtifactSingleView.super.ctor(self, winName);
    self.cimeliaId = cimeliaId
 
end

function ArtifactSingleView:loadUIComplete()

	-- panel_1
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back, UIAlignTypes.RightTop)
 -- 	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_ziyuan, UIAlignTypes.RightTop)
 --   	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_1, UIAlignTypes.Right)
 --   	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_title, UIAlignTypes.LeftTop)
 --   	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_zuo, UIAlignTypes.Left)

--[[
		local cimeliadata = FuncArtifact.byIdgetsingleInfo(itemData.id)
	local icon = cimeliadata.icon
		-- local artifactid =  cimeliadata.itemId
	local sprite = display.newSprite(FuncRes.iconEnemyTreasure( icon ))
	sprite:setScale(0.4)
	baseCell.panel_1.ctn_2:addChild(sprite)
	baseCell.panel_1.mc_kuang2:showFrame(color)
	baseCell.panel_1.mc_kuang:showFrame(color)
]]

	self.cellitem = {}
	self:registClickClose("out")
	self.panel_di.btn_close:setTouchedFunc(c_func(self.clickButtonBack, self),nil,true);
	self.mc_11:getViewByFrame(1).btn_1:setTouchedFunc(c_func(self.advancedButton, self),nil,true);
	self:registerEvent()
	self:initData()
	self:AdvancedButtonRedShow()




end 
function ArtifactSingleView:AdvancedButtonRedShow()
	echo("=======self.cimeliaId==========",self.cimeliaId)
	local isok,_type,name = ArtifactModel:getSingleAdvancedRed(self.cimeliaId)
	self.mc_11:getViewByFrame(1).btn_1:getUpPanel().panel_red:setVisible(isok)
end

function ArtifactSingleView:registerEvent()

	EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE, self.reFreshUI, self)
	EventControler:addEventListener(ShopEvent.SHOPEVENT_BUY_ITEM_END, self.reFreshUI, self)
	-- EventControler:addEventListener(ArtifactEvent.ACTEVENT_SINGLE_ADVANCED, self.updateUI, self)
end
function ArtifactSingleView:reFreshUI()
	self:initData()
	self:AdvancedButtonRedShow()
end
--进阶按钮
function ArtifactSingleView:advancedButton()
	-- self.cimeliaId
	-- echo("单个进阶按钮")


	local isok,_type,name,level,itemid = ArtifactModel:getSingleAdvancedRed(self.cimeliaId)
	if isok == false then
		if _type == FuncArtifact.errorType.NOT_ITEM_NUMBER then
			local name = GameConfig.getLanguage(name)
			local _str = GameConfig.getLanguage("#tid_shenqi_020")
			WindowControler:showTips("<color=da611a>"..name.."<->".._str)
			echo("=========itemid========",itemid)
			WindowControler:showWindow("GetWayListView",itemid)
			return 
		elseif _type ==FuncArtifact.errorType.MEET_CONDITIONS then
			WindowControler:showTips(GameConfig.getLanguage("#tid_shenqi_005"))
			return 
		elseif _type ==FuncArtifact.errorType.PLAYERLEVEL then
			WindowControler:showTips(GameConfig.getLanguage("#tid_shenqi_014")..level)
			return 
		end
	end
	local function _callback(_param)
		-- dump(_param.result,"单个进阶结果",10)
		-- FuncArtifact.playSArtifactActiveSound()
		if (_param.result ~= nil) then
			local cimeliaGroups = _param.result.data.dirtyList.u.cimeliaGroups

			local function callBack()
				self:addeffect()
			end

			self:disabledUIClick()
			WindowControler:showWindow("ArtifactSingleSuccess",self.cimeliaId,callBack);
			self:middleView(self.cimeliaId,true)
			self:AdvancedButtonRedShow()
			local alllist = self.panel_1.scroll_1:getAllView()
			local isshow= ArtifactModel:getSingleAdvancedRed(self.cimeliaId)
			local inde = self:getListIndex()
			alllist[inde].panel_red:setVisible(isshow)
			for k,v in pairs(cimeliaGroups) do
				if v.cimelias ~= nil then
					for _k,_v in pairs(v.cimelias) do
						-- alllist[inde].panel_c.txt_1:setString("+".._v.quality)
						local artifactdata = FuncArtifact.byIdgetsingleInfo(_k)
						local color = artifactdata.color
						alllist[inde].panel_c.mc_2:showFrame(color)
						alllist[inde].panel_c.mc_2:getViewByFrame(color).txt_1:setString("+".._v.quality)
					end
				end
			end
		
		else
			if _param.error ~= nil then
				local error_code = _param.error.code 
				local tip = GameConfig.getErrorLanguage("#error"..error_code)
				WindowControler:showTips(tip)
			end
   		end
    end
	local params = {}
	params.cimeliaId = tostring(self.cimeliaId)
	ArtifactServer:SingleAdvanced(params, _callback)
end

function ArtifactSingleView:addeffect()
	local cimeliaId = self.cimeliaId
	local orderpreview,nextattr,allnextattr = ArtifactModel:getSingleAdvancedAttribute(cimeliaId)
	for i=1,#orderpreview do
		local alllist = self.panel_zuo.scroll_1:getAllView()
		if alllist[i] then 
			local aim = self:createUIArmature("UI_shenqi_jiemian", "UI_shenqi_jiemian_fankui" ,alllist[i], false ,function ()
				self:resumeUIClick()
				EventControler:dispatchEvent(ArtifactEvent.ACTEVENT_SINGLE_ADVANCED)
				self:middleView(self.cimeliaId,true)
			end )
			aim:setPosition(cc.p(130,-10))
		end
	end

	local max = 1
    for i=1,#allnextattr do
    	if allnextattr[i].quality == (self.cimeliaquality + 1) then
    		local alllist = self.panel_zuo.scroll_1:getAllView()
    		local view = self.panel_zuo.scroll_2:getAllView()
    		-- echo("========view========",view)
    		if view[i] then
    			local aim = self:createUIArmature("UI_shenqi_jiemian", "UI_shenqi_jiemian_fankui" ,view[i], false ,function ()
    				self:resumeUIClick()
    				EventControler:dispatchEvent(ArtifactEvent.ACTEVENT_SINGLE_ADVANCED)
					self:middleView(self.cimeliaId,true)
				end )
				aim:setPosition(cc.p(130,-25))
    		end
    	end
    end
    -- 
	
end





function ArtifactSingleView:getListIndex()
	-- dump(self.contain,"1111111111111111")
	-- echo("================",self.cimeliaId)
	for i=1,#self.contain do
		if tonumber(self.cimeliaId) == tonumber(self.contain[i]) then
			return i
		end
	end
end


function ArtifactSingleView:initData()
	local itemdata = FuncArtifact.byIdgetsingleInfo(self.cimeliaId)
	local groupID = itemdata.group
	local artifactdata = FuncArtifact.byIdgetCCInfo(groupID)
	self.contain = artifactdata.contain

	-- self.panel_1.panel_1.UI_u:setVisible(false)
	-- self.panel_1.panel_1.panel_c:setVisible(false)
	self.panel_1.panel_1:setVisible(false)
	-- dump(contain,"右边列表数据")


    local createRankItemFunc = function(itemData)
    	local baseCell = UIBaseDef:cloneOneView(self.panel_1.panel_1);
        self:cellviewData(baseCell, itemData)
        return baseCell;
    end
    local updateFunc = function (itemData,view)
    	self:cellviewData(view, itemData)
	end

    local  _scrollParams = {
        {
            data = self.contain,
            createFunc = createRankItemFunc,
            updateFunc= updateFunc,
            perNums = 1,
            offsetX = 60,
            offsetY = 0,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -60, width = 130, height = 115},
            perFrame = 0,
        }
    } 
    -- self.scroll_1:cancleCacheView();
    self.panel_1.scroll_1:styleFill(_scrollParams);
    local itemsindes = self:getListIndex()
    self.panel_1.scroll_1:gotoTargetPos(tonumber(itemsindes),1);
    self:middleView(self.cimeliaId)
    self.panel_1.scroll_1:hideDragBar()
    
end

function ArtifactSingleView:cellviewData( _Cell,itemData )
	_Cell.panel_red:setVisible(false)
	local ckuan = _Cell.panel_c
	local baseCell = _Cell.panel_1
	local artifactId = tonumber(itemData)
	local artifactdata = FuncArtifact.byIdgetsingleInfo(artifactId)
	local icon = artifactdata.icon
	local singleID = artifactdata.itemId
	
	local color = artifactdata.color
	-- local cimeliadata = FuncArtifact.byIdgetsingleInfo(itemData.id)
	-- local icon = cimeliadata.icon
	local sprite = display.newSprite(FuncRes.iconCimelia( icon ))
	sprite:setScale(0.6)
	baseCell.ctn_2:addChild(sprite)
	baseCell.mc_kuang2:showFrame(color)
	baseCell.mc_kuang:showFrame(color)





	-- local number = 0--ItemsModel:getItemNumById(artifactId)
	-- local types = 1
	-- local itemdata = types..","..singleID..","..number
	-- baseCell:setResItemData({reward = itemdata})
	-- baseCell:showResItemName(false)
 --    baseCell:showResItemNum(false)

    local quality = ArtifactModel:getalldataquality(artifactdata.group,artifactId)
	-- echo("=======11111111=========",artifactId,quality)
	if quality ~= 0 then
		FilterTools.clearFilter(_Cell)
		_Cell:setTouchedFunc(c_func(self.middleView, self,artifactId))
		ckuan:setVisible(true)
		ckuan.mc_2:showFrame(color)
		ckuan.mc_2:getViewByFrame(color).txt_1:setString("+"..quality)
		ckuan.mc_kuang:showFrame(artifactdata.color)
	else
		-- echo("22222222222222222222222")
		FilterTools.setGrayFilter(_Cell)
		_Cell:setTouchedFunc(c_func(self.notActiveButton, self,itemData))
		ckuan:setVisible(false)
	end
	local isshow= ArtifactModel:getSingleAdvancedRed(artifactId)
	if quality >= 1 then
		_Cell.panel_red:setVisible(isshow)
	end
	_Cell.panel_xuan:setVisible(false)
	self.cellitem[artifactId] = _Cell
	if tonumber(artifactId) == 	tonumber(self.cimeliaId) then
		_Cell.panel_xuan:setVisible(true)
		-- self:addSelectIcon(artifactId)
		-- self:middleView(self.cimeliaId)
	end

	
end



--添加选中状态
function ArtifactSingleView:addSelectIcon(artifactId)
	for k,v in pairs(self.cellitem) do
		if tonumber(k) == tonumber(artifactId) then
			v.panel_xuan:setVisible(true)
		else
			-- echo("==========1111111111111111111======",k,artifactId)
			v.panel_xuan:setVisible(false)
		end
	end
end

function ArtifactSingleView:notActiveButton(itemData)
	local id =  tonumber(itemData)
	WindowControler:showWindow("GetWayListView",id)
	-- WindowControler:showTips("您还没有激活该神器")
end

function ArtifactSingleView:middleView(artifactId,file)


	-- echo("=====================",artifactId)
	if type(file) == "table" then
		if artifactId == self.cimeliaId then
			return 
		end
	end
	self.cimeliaId = artifactId 
	local artifactdata = FuncArtifact.byIdgetsingleInfo(artifactId)
	self.cimeliaquality = ArtifactModel:getalldataquality(artifactdata.group,artifactId)
	local name = GameConfig.getLanguage(artifactdata.name)  --神器名称 
	
	local icon = artifactdata.icon
	local colorFrame = artifactdata.color
	--添加图片
	self.ctn_1:removeAllChildren()
	local iconpanth = FuncRes.iconCimelia(icon)
	local spritename = display.newSprite(iconpanth)
	self.ctn_1:addChild(spritename)  --宝物图片
	-- self.ctn_1:setTouchedFunc(c_func(self.getItemPath, self,artifactdata.itemId))  --单个神器获取路径
	if self.cimeliaquality ~= 0 then
		name = name.."+"..self.cimeliaquality
		FilterTools.clearFilter(spritename)
		self.mc_11:getViewByFrame(1).btn_1:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_shenqi_003"))
		-- self.panel_c:setVisible(true)
		-- self.panel_c.txt_1:setString("+"..self.cimeliaquality)
		-- self.panel_c.mc_kuang:showFrame(colorFrame)
	else
		FilterTools.setGrayFilter(spritename)
		self.mc_11:getViewByFrame(1).btn_1:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_shenqi_004"))
		-- self.panel_c:setVisible(false)
	end
	---名称
	
	self.mc_name:showFrame(colorFrame)
	self.mc_name:getViewByFrame(colorFrame).txt_1:setString(name)

	for i=1,2 do
		self["UI_"..i]:setVisible(false)
	end
	--所需道具
	local cimeliaUpdata = FuncArtifact.byIdgetCUInfo(artifactId)
	if cimeliaUpdata ~= nil then
		local qcimeliaD = cimeliaUpdata[tostring(self.cimeliaquality+1)]
		self.mc_11:showFrame(1) --:setVisible(true)
		if qcimeliaD ~= nil then
			local cost = qcimeliaD.cost
			local itemTOfF = true  ---道具是否足够
			for i=1,#cost do
				local tables = string.split(cost[i], ",");
				local types =  tables[1]
				local itemid = tonumber(tables[2])
				local neednumbers = tonumber(tables[3])---消耗数量
				if types == FuncDataResource.RES_TYPE.ITEM then
					local iteminfo = FuncItem.getItemData(itemid)  --道具详情
					local havenumber = ItemsModel:getItemNumById(itemid)
					if havenumber >= neednumbers then

					else
						itemTOfF = false

					end
					local numbers = havenumber.."/"..neednumbers
					local itemdata = types..","..itemid..",".."0"
					self["UI_"..i]:setVisible(true)
					self["txt_goodsshuliang"..i]:setVisible(true)
					self["UI_"..i]:setResItemData({reward = itemdata})
					self["UI_"..i]:showResItemName(true,true,nil,true)
				    self["UI_"..i]:showResItemNum(false)
				    self["txt_goodsshuliang"..i]:setString(numbers)
				    local names = FuncItem.getItemName(itemid)
				    self["UI_"..i]:showResItemNameWithQuality()
				    self["UI_"..i].panelInfo.mc_zi.currentView.txt_1:setString(names)
				    -- self["UI_"..i].panelInfo.txt_goodsshuliang:setString(numbers)
				    self["UI_"..i]:setTouchedFunc(c_func(self.getItemPath, self,itemid))
				end

			end

		else
			for i=1,2 do
				self["UI_"..i]:setVisible(false)
				self["txt_goodsshuliang"..i]:setVisible(false)
				-- self.btn_1:setVisible(false)
				self.mc_11:showFrame(2)
			end
		end
		self:LeftViewData()
	else
		echoError("表里没配数据 单个神器ID",self.cimeliaId)
	end

	local button = self.mc_11:getViewByFrame(1).btn_1
	FilterTools.clearFilter(button)
	local isok,_type,name,level = ArtifactModel:getSingleAdvancedRed(self.cimeliaId)
	if isok == false then
		if _type == FuncArtifact.errorType.NOT_ITEM_NUMBER then
			FilterTools.setGrayFilter(button)
		elseif _type ==FuncArtifact.errorType.MEET_CONDITIONS then
		elseif _type ==FuncArtifact.errorType.PLAYERLEVEL then
		end
	end

	self:AdvancedButtonRedShow()
	self:addSelectIcon(artifactId)
end



--获取道具路径
function ArtifactSingleView:getItemPath(itemid)
	WindowControler:showWindow("GetWayListView",itemid)
end
function ArtifactSingleView:LeftViewData()
	local cimeliaId = self.cimeliaId
	local artifactdata = FuncArtifact.byIdgetsingleInfo(cimeliaId)
	local quality = ArtifactModel:getalldataquality(artifactdata.group,cimeliaId)
	local cimeliaUpdata = FuncArtifact.byIdgetCUInfo(cimeliaId)
	-- local qcimeliaD = cimeliaUpdata[tostring(quality+1)]

	local orderpreview,nextattr,allnextattr = ArtifactModel:getSingleAdvancedAttribute(cimeliaId)  --  进阶预览数据

	-- dump(orderpreview,"进阶预览数据",6)
	-- dump(nextattr,"进下一阶数据",6)
	-- dump(allnextattr,"进阶属性数据",6)

	-- allnextattr = { [1] = { quality = 1,attr = {key = 2,value  = 100,mode = 1} ,des = "#tid_cimelia_501"},
	-- 				[2] = { quality = 4,attr = {key = 3,value = 150,mode = 1} ,des = "#tid_cimelia_502"},
	-- 				[3] = { quality = 6,attr = {key = 9,value = 20,mode = 1} ,des = "#tid_cimelia_503"},
	-- }

	-- self.panel_zuo.panel_txt1:setVisible(false)
	self.panel_zuo.panel_z1:setVisible(false)
	-- self.panel_zuo.panel_1:setVisible(false)
	-- self.panel_zuo.panel_txt2:setVisible(false)
	self.panel_zuo.mc_1:setVisible(false)




    local createRankItemFuncTwo = function(itemData)
    	local baseCell = UIBaseDef:cloneOneView(self.panel_zuo.panel_z1);
        self:setDesviewDataTwo(baseCell, itemData)
        return baseCell;
    end
    local updateCellFunc_1 = function(itemData,baseCell)
        self:setDesviewDataTwo(baseCell, itemData)
    end

    local  _scrollParam_1 = {
        {
            data = orderpreview,
            createFunc = createRankItemFuncTwo,
            updateCellFunc= updateCellFunc_1,
            perNums = 1,
            offsetX = -10,
            offsetY = 5,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -30, width = 230, height = 30},
            perFrame = 0,
        },

    }
    self.panel_zuo.scroll_1:refreshCellView( 1 )
    -- self.panel_zuo.scroll_1:cancleCacheView();
    self.panel_zuo.scroll_1:styleFill(_scrollParam_1);
    self.panel_zuo.scroll_1:hideDragBar()



    local createRankItemFuncFive = function(itemData)
    	local baseCell = UIBaseDef:cloneOneView(self.panel_zuo.mc_1);
        self:setDesviewDataFore(baseCell, itemData)
        return baseCell;
    end

    local updateCellFunc_2 = function(itemData,baseCell)
        self:setDesviewDataFore(baseCell, itemData)
    end
    

    local _scrollParams_2 = {}
    for i=1,#allnextattr do
		local attr = allnextattr[i].attr[1]
		local attrname = ArtifactModel:getDesStaheTable(attr[1],false)
		local des = GameConfig.getLanguage(allnextattr[i].des)
		local _str = attrname..des
		local width,height = FuncChat.getStrWandH(_str,210)
    	local pamses  ={
	            data = {allnextattr[i]},
	            createFunc = createRankItemFuncFive,
	            updateCellFunc= updateCellFunc_2,
	            perNums = 1,
	            offsetX = 0,
	            offsetY = 5,
	            widthGap = 0,
	            heightGap = 0,
	            itemRect = {x = 0, y = -height, width = 250, height = height},
	            perFrame = 0,
	    }
	    table.insert(_scrollParams_2,pamses)
    end
   	self.panel_zuo.scroll_2:cancleCacheView();
    self.panel_zuo.scroll_2:styleFill(_scrollParams_2);
    self.panel_zuo.scroll_2:hideDragBar()

    -- dump(allnextattr,'11111111111111111')
    -- for k,v in pairs(allnextattr) do
    local max = 1
    for i=1,#allnextattr do
    	if allnextattr[i].quality <= (self.cimeliaquality + 1) then
    		max = i
    	end
    end
    self.panel_zuo.scroll_2:gotoTargetPos(1, max ,1)

end

function ArtifactSingleView:setDesviewDataOne(baseCell, itemData)
	-- body
end
-- 进阶预览数据
function ArtifactSingleView:setDesviewDataTwo(baseCell, itemData)
	--[[
		itemData = {[1] = {key = 1,value = 2,mode = 3},
				[2] = {key = 1,value = 2,mode = 3}
		}
		or
		itemData = {[1] = {key = 1,value = 2,mode = 3}}
		}
	]]
	-- dump(itemData,"111111111111111111111")
	local attrname = ArtifactModel:getDesStaheTable(itemData[1],false)
	local curren = itemData[1].value
	local nextvaluer = itemData[2]
	baseCell.txt_1:setString(attrname.." ")

	local valuer = FuncArtifact.getFormatFightAttrValue(itemData[1].key,curren)
	if itemData[1].mode ==2 then
		baseCell.txt_2:setString((curren/100).."%")
	elseif itemData[1].mode == 3 then
		baseCell.txt_2:setString(valuer)
	end
	if  nextvaluer ~= nil then
		local valuers = FuncArtifact.getFormatFightAttrValue(itemData[2].key,itemData[2].value)
		-- local valuer = itemData[2].value
		if itemData[2].mode == 2 then
			baseCell.txt_3:setString((itemData[2].value/100).."%")
		else
			baseCell.txt_3:setString(valuers)
		end
	else
		baseCell.txt_3:setString("")
		baseCell.panel_jiantou:setVisible(false)
		-- echoError("下一阶的属性添加表里没配，找金钊 单个神器ID",self.cimeliaId)
	end

end
-- 进下一阶数据
function ArtifactSingleView:setDesviewDataThree(baseCell, itemData)
	--[[
		allnextattr = {
			[1] = { quality = 1,attr = {} ,des = "#tid1001"},
			[4] = { quality = 4,attr = {} ,des = "#tid1001"},
		}
	]]
	-- local attr = itemData.attr
	-- local attrname = ArtifactModel:getDesStaheTable(attr[1],false)
	-- local valuer = attr.value
	local des = GameConfig.getLanguage(itemData.des)
	-- local _str = attrname.."+"..valuer.."("..des..")"
	baseCell.txt_2:setString("     "..des)

end
-- 进阶属性数据
function ArtifactSingleView:setDesviewDataFore(baseCell, itemData)
	-- dump(itemData,"0000000",6)
	--[[
		allnextattr = {
			[1] = { quality = 1,attr = {} ,des = "#tid1001"},
			[4] = { quality = 4,attr = {} ,des = "#tid1001"},
		}
	]]
	-- self.cimeliaquality --当前品质界面
	--如果大于当前阶级 ，那就是获得了该属性  显示绿色
	local attr = itemData.attr[1]
	local attrname = ArtifactModel:getDesStaheTable(attr[1],false)
	local valuer = attr.value
	local des = GameConfig.getLanguage(itemData.des)
	local namestr =  "等级"..itemData.quality
	local _str = attrname..des
	local Frame = 1
	if self.cimeliaquality >= itemData.quality then 
		Frame = 1
		baseCell:showFrame(Frame)
	elseif itemData.quality == (self.cimeliaquality + 1) then  --下一个阶级显示黄色
		Frame  = 2
		baseCell:showFrame(Frame)
	else  --显示灰色
		Frame = 3
		baseCell:showFrame(Frame)
	end
	baseCell:getViewByFrame(Frame).txt_1:setString(namestr)
	baseCell:getViewByFrame(Frame).txt_2:setString(" ".._str)

end



function ArtifactSingleView:clickButtonBack()
	ArtifactModel:sendHomeviewRed()
	self:startHide()
end


return ArtifactSingleView;
