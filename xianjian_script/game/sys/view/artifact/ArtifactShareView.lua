-- ArtifactShareView
-- Author: Wk
-- Date: 2018-6-11
-- 神器分享界面
local ArtifactShareView = class("ArtifactShareView", UIBase);

function ArtifactShareView:ctor(winName,data)
    ArtifactShareView.super.ctor(self, winName);
    self.allData = data
end

function ArtifactShareView:loadUIComplete()
	self:registerEvent()
	self:initData()
end 

function ArtifactShareView:registerEvent()

	self.panel_di.btn_close:setTouchedFunc(c_func(self.press_btn_close, self,nil,node,quality),nil,true);
	self:registClickClose("out")

end

function ArtifactShareView:initData()
	self:addspine()
	self:initLeftUI()
end


function ArtifactShareView:addspine()
	local ccid =  self.allData.id
	local ccInfo =  FuncArtifact.byIdgetCCInfo(ccid)
	local iconname = ccInfo.spine
	local npcAnimName = iconname
    local npcAnimLabel = "stand"
    local  spritename = ViewSpine.new(npcAnimName,nil,nil,nil);
    self.ctn_1:removeAllChildren()
    spritename:playLabel(npcAnimLabel);
	self.ctn_1:addChild(spritename) 
	local infoData = FuncArtifact.byIdgetCCInfo(ccid)
	self.mc_1:showFrame(infoData.combineColor-1)
	local name =   infoData.combineName
	self.mc_1:getViewByFrame(infoData.combineColor-1).txt_1:setString(GameConfig.getLanguage(name).."+".. self.allData.quality)
end




--初始化左边列表
function ArtifactShareView:initLeftUI()
	self.panel_zuo.panel_1:setVisible(false)
	self.panel_zuo.panel_jjsx:setVisible(false)
	self.panel_zuo.panel_2:setVisible(false)
	self.panel_zuo.panel_down:setVisible(false)

	local createLeftItemFunc1 = function(itemData)
    	local baseCell = UIBaseDef:cloneOneView(self.panel_zuo.panel_1);
        self:cellLeftviewData1(baseCell, itemData)
        return baseCell;
    end
    local createLeftItemFunc2 = function(itemData)
    	local baseCell = UIBaseDef:cloneOneView(self.panel_zuo.panel_jjsx);
        self:cellLeftviewData2(baseCell, itemData)
        return baseCell;
    end
    local createLeftItemFunc3 = function(itemData)
    	local baseCell = UIBaseDef:cloneOneView(self.panel_zuo.panel_2);
        self:cellLeftviewData3(baseCell, itemData)
        return baseCell;
    end
     self.panel_zuo.panel_ewtx:setVisible(false)	
    local createLeftItemFunc4 = function(itemData)
    	local baseCell = UIBaseDef:cloneOneView(self.panel_zuo.panel_ewtx);
        self:cellLeftviewData4(baseCell, itemData)
        return baseCell;
    end




	local attrList =  ArtifactModel:getSingleInitAttrByData(self.allData)
	local attrList2 = ArtifactModel:getSingleInitAttrByData(self.allData,true)

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
	local attrListArt = ArtifactModel:getCCAttrlistTable(self.allData.id)
	local quality = self.allData.quality
	local newliset = {}
	for i=1,#attrListArt do
		if quality >= attrListArt[i].quality then
			table.insert(newliset,attrListArt[i])
		end
	end


    local  _scrollParams = {
        {
            data = {1},
            createFunc = createLeftItemFunc1,
            -- updateFunc= updateFunc,
            perNums = 1,
            offsetX = 0,
            offsetY = 5,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -270, width = 320, height = 270},
            perFrame = 0,
        },
        {
            data = attrList,
            createFunc = createLeftItemFunc2,
            -- updateFunc= updateFunc,
            perNums = 1,
            offsetX = 55,
            offsetY = 10,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -40, width = 150, height = 23},
            perFrame = 0,
        },
        {
            data = {1},
            createFunc = createLeftItemFunc3,
            -- updateFunc= updateFunc,
            perNums = 1,
            offsetX = 5,
            offsetY = 10,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -40, width = 294, height = 40},
            perFrame = 0,
        },
        -- {
        --     data = newliset,
        --     createFunc = createLeftItemFunc4,
        --     -- updateFunc= updateFunc,
        --     perNums = 1,
        --     offsetX = 0,
        --     offsetY = 5,
        --     widthGap = 0,
        --     heightGap = 0,
        --     itemRect = {x = 0, y = -60, width = 263, height = 60},
        --     perFrame = 0,
        -- }
    }    

    for i=1,#newliset do
    	local des = GameConfig.getLanguage(newliset[i].skillUpDes)
    	local height,lengthnum = FuncCommUI.getStringHeightByFixedWidth(des,20,nil,220)
    	local pames =   {
            data = {newliset[i]},
            createFunc = createLeftItemFunc4,
            -- updateFunc= updateFunc,
            perNums = 1,
            offsetX = -10,
            offsetY = 10,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -(height+5), width = 155, height = height+5},
            perFrame = 0,
        }
  		table.insert(_scrollParams,pames)
    end



    self.panel_zuo.scroll_1:cancleCacheView();
    self.panel_zuo.scroll_1:styleFill(_scrollParams);
    

end

function ArtifactShareView:cellLeftviewData1(cell)
	local ccid = ccid
	local itemData = self.allData
	-- local isok,_type,itemname = ArtifactModel:ByCCIDgetAdvanced(self.seleCellId)
	-- self.mc_btn:getViewByFrame(1).btn_1:getUpPanel().panel_red:setVisible(isok)
	local quality = itemData.quality or 1 
	local artifactId = itemData.id


	local artifactalldata = FuncArtifact.byIdgetCCInfo(artifactId)--组合神器数据
	local skilldata =  FuncArtifact.byIdgetcombineUpInfo(artifactId)--组合神器进阶数据
	-- local artifactdata = nil
	local skilltable =  skilldata[tostring(quality)]


	local artifactname = GameConfig.getLanguage(artifactalldata.combineName)  --组合名称
	local skillname = GameConfig.getLanguage(artifactalldata.skillName)  --组合技能名称
	local skillicon = artifactalldata.skillIcon  --组合技能图标
	local skilldes = artifactalldata.combineSkillDes  --组合技能描述
	artifactname = artifactname.."+"..quality

	--单个组合总战力
	local powernumber =  ArtifactModel:getShareDataPower(itemData)
	echo("========战力=========",powernumber)
	cell.panel_power.UI_number:setPower(powernumber or 1000)


	local colorframe = artifactalldata.combineColor
	-- self.panel_zuo.mc_name:showFrame(colorframe)
	local artifactalldata = FuncArtifact.byIdgetCCInfo(artifactId)
	local name = artifactalldata.combineName
	local  stname = GameConfig.getLanguage(name)
	if quality ~= 0 then
		stname = stname.."+"..quality
	end


	local data = skilltable
	local kind = data.kind
	local _quility = quality
	if kind == 4 then
		for i=1,tonumber(quality) do
			local growEnergy = skilldata[tostring(i)].growEnergy
			if growEnergy ~= nil then
				_quility = i
			end
		end
		if data.growEnergy == nil then
			skilltable = skilldata[tostring(_quility)]
		end
	end

	self:skillAttrTiHuan(cell,skilltable,skilltable.quality)

	cell.txt_name:setString(skillname)
	-- cell.panel_1.txt_name:setString("等级"..quality)

	cell.panel_1.ctn_1:removeAllChildren()
	if skillicon ~= nil then
		local imagename =	FuncRes.iconSkill(skillicon)
		local sprites = display.newSprite(imagename)
		cell.panel_1.ctn_1:addChild(sprites)
	end

end



function ArtifactShareView:cellLeftviewData4(baseCell, itemData )
	local quality = self.allData.quality or 1  ---ArtifactModel:getCimeliaCombinequality(itemData.ccid)
	local des = GameConfig.getLanguage(itemData.skillUpDes)
	local namestr =  "等级"..itemData.quality
	local _str = des--attrname.."+"..valuer.."("..des..")"
	-- local color = "<color=8C9695>"
	-- if quality >= itemData.quality then 
		-- Frame = 1
		-- baseCell:showFrame(Frame)
	local color = "<color=008c0d>"
	-- elseif itemData.quality == (quality + 1) then  --下一个阶级显示黄色
		-- Frame  = 2
		-- baseCell:showFrame(Frame)
		-- color = "<color=89674B>"
	-- end
	-- baseCell.panel_ewtx.rich_1:setString(color..namestr.."<->")
	-- baseCell.panel_ewtx.rich_2:setString(color.._str.."<->")

	baseCell.rich_1:setString(color..namestr.."<->")
	baseCell.rich_2:setString(color.._str.."<->")


end



function ArtifactShareView:cellLeftviewData3(baseCell, itemData)
	local attrListArt = ArtifactModel:getCCAttrlistTable(self.allData.id)
	local quality = self.allData.quality
	local newliset = {}
	for i=1,#attrListArt do
		if quality >= attrListArt[i].quality then
			table.insert(newliset,attrListArt[i])
		end
	end
	if table.length(newliset) == 0 then
		baseCell.txt_ewtx2:setVisible(true)
	else
		baseCell.txt_ewtx2:setVisible(false)
	end
end




--技能属性替换
function ArtifactShareView:skillAttrTiHuan(cell,itemData,skillLevel)
	if tonumber(skillLevel) == 0 then
		skillLevel = 1
	end
    local des = FuncArtifact.byIdgetCCInfo(itemData.combineId).combineSkillDes
	local skillsArrtStr = FuncPartner.getCommonSkillDesc(itemData,tonumber(skillLevel),des)
	cell.rich_12:setString(skillsArrtStr)
end




function ArtifactShareView:cellLeftviewData2(baseCell,itemData)

	local des = ArtifactModel:getDesStaheTable(itemData,false)
	-- dump(des,"cellLeftviewData==========   ")
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
	baseCell.panel_tubiao:setVisible(false)  --:setString("<color=008c0d>"..str2.."<->")
 	baseCell.rich_3:setVisible(false)
end



function ArtifactShareView:press_btn_close()
	
	self:startHide()
end


return ArtifactShareView;
