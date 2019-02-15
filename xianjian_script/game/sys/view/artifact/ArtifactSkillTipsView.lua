-- ArtifactSkillTipsView
-- Author: Wk
-- Date: 2017-07-22
-- 单个神器进阶成功系统界面

local ArtifactSkillTipsView = class("ArtifactSkillTipsView", UIBase);

function ArtifactSkillTipsView:ctor(winName,ccId)
    ArtifactSkillTipsView.super.ctor(self, winName);
    self.ccId = ccId
end

function ArtifactSkillTipsView:loadUIComplete()

	self:registClickClose(-1, c_func( function()
        self:press_btn_close()
    end , self))
	self:initData()

end 

function ArtifactSkillTipsView:initData()
	local ccId = self.ccId 
	local info = FuncArtifact.byIdgetCCInfo(ccId) 
	local quality =  ArtifactModel:getCimeliaCombinequality(ccId)
	local name = GameConfig.getLanguage(info.combineName)
	-- 组合技能名称
	local skillName = GameConfig.getLanguage(info.skillName)
	-- 组合技能图标
	local skillIcon = info.skillIcon
	if skillIcon ~= nil then


		local imagename =	FuncRes.iconSkill(skillIcon)
		local sprites = display.newSprite(imagename)
		self.panel_1.mc_skill.currentView.ctn_1:addChild(sprites)

		if quality == 0 then
			FilterTools.setGrayFilter(sprites)
		else
			FilterTools.clearFilter(sprites)
		end
		-- self.panel_zuo.panel_1.ctn_1:addChild(sprites)
	else
		echoError("没有技能资源图片，表里没配，找金钊 技能组合ID",ccId)
	end
	-- 组合技能描述
	-- local combineSkillDes = GameConfig.getLanguage(info.combineSkillDes)
	local colorframe = info.combineColor
	if quality ~= 0 then
		name = name.."+"..quality
		skillName = skillName.."+"..quality
	end
	local des =  GameConfig.getLanguage("#tid_shenqi_016")
	self.panel_1.txt_1:setString(skillName)
	self.panel_1.rich_2:setString(GameConfig.getLanguage("#tid_shenqi_015")..des)


	local skilldata =  FuncArtifact.byIdgetcombineUpInfo(ccId)--组合神器进阶数据
	-- local artifactdata = nil
	local skilltable = nil
	if quality == 0 then  ---未获取的时候
		-- artifactdata = artifactalldata[tostring(1)]   --默认取第一个
		quality = 1
		skilltable = skilldata[tostring(1)]

	else
		-- artifactdata = artifactalldata[tostring(quality)]   --默认取第一个
		skilltable = skilldata[tostring(quality)]
	end

	local data = skilldata[tostring(quality)]  --growEnergy
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


	self:skillAttrTiHuan(skilltable,skilltable.quality)
	

	self:LeftListViewData()
end
--技能属性替换
function ArtifactSkillTipsView:skillAttrTiHuan(itemData,skillLevel)
	if tonumber(skillLevel) == 0 then
		skillLevel = 1
	end
    local des = FuncArtifact.byIdgetCCInfo(itemData.combineId).combineSkillDes
	local skillsArrtStr = FuncPartner.getCommonSkillDesc(itemData,tonumber(skillLevel),des)
	self.panel_1.rich_3:setString(skillsArrtStr)
end

--最左边进阶属性描述
function ArtifactSkillTipsView:LeftListViewData()
	local ccId = self.ccId  --组合技能ID
	local ccListdata = ArtifactModel:getCCAttrlistTable(ccId)


	self.panel_1.panel_kaizi:setVisible(false)
	local createRankItemFunc = function(itemData)
    local baseCell = UIBaseDef:cloneOneView(self.panel_1.panel_kaizi);
        self:cellviewData(baseCell, itemData)
        return baseCell;
    end

    -- local  _scrollParams = {
    --     {
    --         data = ccListdata,
    --         createFunc = createRankItemFunc,
    --         -- updateFunc= updateFunc,
    --         perNums = 1,
    --         offsetX = 10,
    --         offsetY = 15,
    --         widthGap = 0,
    --         heightGap = 0,
    --         itemRect = {x = 0, y = -40, width = 396, height = 40},
    --         perFrame = 1,
    --     }
    -- }    


     local  _scrollParams = {}
    for i=1,#ccListdata do
    	local des = GameConfig.getLanguage(ccListdata[i].skillUpDes)
    	local height,lengthnum = FuncCommUI.getStringHeightByFixedWidth(des,20,nil,220)
    	local pames =   {
            data = {ccListdata[i]},
            createFunc = createRankItemFunc,
            updateFunc= updateFunc,
            perNums = 1,
            offsetX = 15,
            offsetY = 5,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -(height + 5), width = 360, height = height + 5},
            perFrame = 0,
        }
  		table.insert(_scrollParams,pames)
    end








    self.panel_1.scroll_1:hideDragBar()
    self.panel_1.scroll_1:styleFill(_scrollParams);

end
function ArtifactSkillTipsView:cellviewData(baseCell,itemData)
	local ccId = self.ccId 
	local quality =  ArtifactModel:getCimeliaCombinequality(ccId)
	local str = GameConfig.getLanguage(itemData.skillUpDes)
	local namestr =  "等级"..itemData.quality
	-- baseCell:setString(namestr.." "..str)
	baseCell.txt_1:setString(namestr)
	baseCell.txt_2:setString(str)

	if tonumber(quality) >= tonumber(itemData.quality) then
		baseCell.txt_1:setColor(cc.c3b(0x66,0xff,0x00))
		baseCell.txt_2:setColor(cc.c3b(0x66,0xff,0x00))
	else
		baseCell.txt_1:setColor(cc.c3b(0xBF,0x80,0x5c))
		baseCell.txt_2:setColor(cc.c3b(0xBF,0x80,0x5c))
	end

end


function ArtifactSkillTipsView:press_btn_close()
	self:startHide()
end


return ArtifactSkillTipsView;
