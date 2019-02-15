-- ArtifactSingleSuccess
-- Author: Wk
-- Date: 2017-07-22
-- 单个神器进阶成功系统界面

local ArtifactSingleSuccess = class("ArtifactSingleSuccess", UIBase);



function ArtifactSingleSuccess:ctor(winName,cimeliaId,callBack)
    ArtifactSingleSuccess.super.ctor(self, winName);
    self.cimeliaId = cimeliaId
    self.callBack = callBack
    echo("=============单个神器ID===========",cimeliaId)
end

function ArtifactSingleSuccess:loadUIComplete()
	-- local size = self.panel_sp:getContainerBox()
	-- self.panel_sp:setScaleX(GameVars.width/size.width)
	self:registerEvent()
	self:addBgEfftet()

	self:ishaid(false)
	self.panel_sp:setVisible(false)
	self.txt_2:setVisible(false)
	self:delayCall(function ()
		self:ishaid(true)
		self:initData()
		self:bgEffectexchange()
	end,0.4)
	local a_black = FuncRes.a_black(1136*4,640*4)

	self.ctn_blackbg:addChild(a_black)
end 

function ArtifactSingleSuccess:registerEvent()
	-- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)


end
function ArtifactSingleSuccess:ishaid(_file)
	self.panel_kuang1:setVisible(_file)
	self.panel_1:setVisible(_file)
	self.panel_kuang2:setVisible(_file)

	self.panel_zhalisuoqu:setVisible(_file)
	self.panel_number1:setVisible(_file)
	self.scroll_1:setVisible(_file)

	self.panel_z1:setVisible(_file)
	self.rich_1:setVisible(_file)

end

function ArtifactSingleSuccess:initData()
	local cimeliaId = self.cimeliaId
	--单个神器详情
	local info = FuncArtifact.byIdgetsingleInfo(cimeliaId)
	local colorFrame = info.color
	local name = GameConfig.getLanguage(info.name)
	local groupId = info.group
	local quality = ArtifactModel:getalldataquality(groupId,cimeliaId)
	local nextname = name
	if quality ~= 0 then
		if quality - 1 ~= 0 then
			name = name.."+"..(quality-1)
		end
	end
	self.rich_1:setVisible(false)
	local infotable = FuncArtifact.byIdgetCUInfo(cimeliaId)
	local lvAbilityinfo = infotable[tostring(quality-1)]
	-- local lvAbility = 0
	-- if lvAbilityinfo ~= nil then
	-- 	lvAbility = lvAbilityinfo.addAbility   ---当前战力
	-- end
	-- local nextlvAbility = infotable[tostring(quality)].addAbility  ---进阶下一阶的战力


	local artifactdata = FuncArtifact.byIdgetsingleInfo(cimeliaId)
	-- local singleID = artifactdata.itemId
	-- local itemdata = "1,"..singleID..",".."0"
	-- self.UI_1:setResItemData({reward = itemdata})
	-- self.UI_1:showResItemName(true)
 --    self.UI_1:showResItemNum(false)
 --    self.UI_2:setResItemData({reward = itemdata})
 --    self.UI_2:showResItemName(true)
 --    self.UI_2:showResItemNum(false)
 --    self.UI_1:showResItemNameWithQuality()
 --    self.UI_2:showResItemNameWithQuality()
	local icon = artifactdata.icon
	local color = artifactdata.color
		-- local artifactid =  cimeliadata.itemId
	local sprite1 = display.newSprite(FuncRes.iconCimelia( icon ))
	sprite1:setScale(0.6)
	local panel_kuang_1 = self.panel_kuang1
	panel_kuang_1.ctn_2:addChild(sprite1)
	panel_kuang_1.mc_kuang2:showFrame(color)
	panel_kuang_1.mc_kuang:showFrame(color)
	panel_kuang_1.mc_name:showFrame(color)
	panel_kuang_1.mc_name:getViewByFrame(color).txt_1:setString(name)
	-- local panel_kuang_2 = self.panel_kuang2
	local sprite2 = display.newSprite(FuncRes.iconCimelia( icon ))
	sprite2:setScale(0.6)
	self.panel_kuang2.ctn_2:addChild(sprite2)
	self.panel_kuang2.mc_kuang2:showFrame(color)
	self.panel_kuang2.mc_kuang:showFrame(color)
	self.panel_kuang2.mc_name:showFrame(color)
	self.panel_kuang2.mc_name:getViewByFrame(color).txt_1:setString(nextname.."+"..quality)

    -- self.UI_1.panelInfo.mc_zi.currentView.txt_1:setString(name)
    -- self.UI_2.panelInfo.mc_zi.currentView.txt_1:setString(nextname.."+"..quality)

    local  lvAbility,nextlvAbility = ArtifactModel:getIdBySingleAbility(cimeliaId)
    self.panel_number1:setVisible(true)
    self.panel_number1:setVisible(true)
    self.panel_zhalisuoqu:setVisible(true)
    if tonumber(lvAbility) == tonumber(nextlvAbility) then
    	self.panel_zhalisuoqu:setVisible(false)
    	self.panel_number1:setVisible(false)
    	self.panel_number1:setVisible(false)
    end
	self.panel_number1.UI_1:setPower(lvAbility)
	self.panel_number1.UI_2:setPower(nextlvAbility)

	---属性
	local orderpreview,nextattr,allnextattr = ArtifactModel:getSingleAdvancedAttribute(cimeliaId,true)	
	-- dump(orderpreview,"1111111111",6)
	-- dump(nextattr,"222222",6)
	-- dump(allnextattr,"333333",6)

	self.panel_z1.txt_1:setVisible(false)
	self.panel_z1.txt_2:setVisible(false)
	self.panel_z1.txt_3:setVisible(false)
	self.panel_z1.panel_tu:setVisible(false)




	local createRankItemFuncTwo = function(itemData)
    local baseCell = UIBaseDef:cloneOneView(self.panel_z1);
        self:setDesviewDataTwo(baseCell, itemData)
        return baseCell;
    end
 	local  _scrollParams = {
 		{
            data = orderpreview,
            createFunc = createRankItemFuncTwo,
            -- updateFunc= updateFunc,
            perNums = 1,
            offsetX = 170,
            offsetY = 5,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -30, width = 390, height = 35},
            perFrame = 5,
        }
    }    
    -- self.scroll_1:cancleCacheView();
    self:delayCall(function ()
		self.scroll_1:styleFill(_scrollParams);
    	self.scroll_1:hideDragBar()
	end,1.0)

    

end
function ArtifactSingleSuccess:setDesviewDataTwo( baseCell,itemData )
	-- dump(itemData,"111111111111111")
	baseCell.panel_tu:setVisible(false)
	local attrname = ArtifactModel:getDesStaheTable(itemData[1],false)
	local curren = itemData[2].value
	local nextvaluer = itemData[1].value
	baseCell.txt_1:setString(attrname)
	baseCell.txt_2:setString((curren/100).."%")
	baseCell.txt_3:setString((nextvaluer/100).."%")

	local  lockAni  = self:createUIArmature("UI_shenqi_jinjie","UI_shenqi_jinjie_xianshixinxi", baseCell, false, function ()
	end)
	lockAni:setPosition(cc.p(-240/2,-40))
	FuncArmature.changeBoneDisplay(lockAni,"node1", baseCell.txt_1)
	FuncArmature.changeBoneDisplay(lockAni,"node2", baseCell.txt_2)
	FuncArmature.changeBoneDisplay(lockAni,"node3", baseCell.txt_3)
	-- FuncArmature.changeBoneDisplay(lockAni,"a1", baseCell.panel_tu)
	baseCell.txt_1:setPosition(cc.p(-20/2,-20/2))
	baseCell.txt_2:setPosition(cc.p(-20/2,-20/2))
	baseCell.txt_3:setPosition(cc.p(-20/2,-20/2))
	baseCell.panel_tu:setPosition(cc.p(-20,6))

end

function ArtifactSingleSuccess:addBgEfftet()
	local _bgctn = self.ctn_bg
	local _type = FuncCommUI.EFFEC_TTITLE.ADVANCED
	FuncArtifact.playArtifactActiveSound()
	FuncCommUI.addCommonBgEffect(_bgctn,_type)

end

---背景特效替换
function ArtifactSingleSuccess:bgEffectexchange()
	self.panel_number1.panel_1:setVisible(false)
	self.panel_zhalisuoqu:setVisible(false)
	self.panel_1:setVisible(false)

	local  lockAni  = self:createUIArmature("UI_shenqi_jinjie","UI_shenqi_jinjie_xiaoshenqi", self.ctn_ef2, false, function ()
		
		self:registClickClose(0, c_func( function()
	        self:press_btn_close()
	    end , self))
	end)
	FuncArmature.changeBoneDisplay(lockAni,"node1", self.panel_kuang1)
	FuncArmature.changeBoneDisplay(lockAni,"node2", self.panel_kuang2)
	-- FuncArmature.changeBoneDisplay(lockAni,"layer2", self.panel_1)
	lockAni:getBone("guangyin_copy"):setVisible(false)
	-- self.panel_1:setPosition(cc.p(-60/2,44/2))
	self.panel_kuang1:setPosition(cc.p(99/2,-99/2))
	self.panel_kuang2:setPosition(cc.p(99/2,-99/2))


	local cimeliaId = self.cimeliaId
	local  lvAbility,nextlvAbility = ArtifactModel:getIdBySingleAbility(cimeliaId)
	if tonumber(lvAbility) ~= tonumber(nextlvAbility) then
		-- self.panel_zhalisuoqu:setVisible(true)
		lockAni:getBone("guangyin_copy"):setVisible(true)
		-- FuncArmature.changeBoneDisplay(lockAni,"jt", self.panel_number1.panel_1)
		-- FuncArmature.changeBoneDisplay(lockAni,"shentong", self.panel_zhalisuoqu)
    	FuncArmature.changeBoneDisplay(lockAni,"node3", self.panel_number1.UI_1)
		FuncArmature.changeBoneDisplay(lockAni,"node4", self.panel_number1.UI_2)
		lockAni:getBone("shentong"):setVisible(true)
	else
		lockAni:getBone("shentong"):setVisible(false)
		-- lockAni:getBone("jt"):setVisible(false)
	end
	self.panel_number1.UI_1:setPosition(cc.p(30/2-20,-25/2))
	self.panel_number1.UI_2:setPosition(cc.p(-30,-25/2))

end


function ArtifactSingleSuccess:press_btn_close()
	if self.callBack then
		self.callBack()
	end
	self:startHide()
end


return ArtifactSingleSuccess;
