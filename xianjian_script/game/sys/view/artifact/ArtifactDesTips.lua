-- ArtifactDesTips.lua
--通用道具tip显示
local ArtifactDesTips = class("ArtifactDesTips", InfoTipsBase);



function ArtifactDesTips:ctor(winName)
    ArtifactDesTips.super.ctor(self, winName);
end

function ArtifactDesTips:loadUIComplete()
	self:registerEvent();
end 

function ArtifactDesTips:registerEvent()
	ArtifactDesTips.super.registerEvent();

end


--资源类型字符串
function ArtifactDesTips:setResInfo(artifactId)
	echo("22222222============",artifactId)

	local artifactCCID =  artifactId  --组合ID
	local ccInfo =  FuncArtifact.byIdgetCCInfo(artifactCCID)
	local name = ccInfo.combineName
	local des = ccInfo.origin --"描述策划配置"
	local panel = self.panel_story1
	panel:setOpacity(255)
	panel.txt_1:setString(GameConfig.getLanguage(name))
	panel.txt_2:setString(GameConfig.getLanguage(des))

    
end



function ArtifactDesTips:updateUI()
	
end


return ArtifactDesTips;
