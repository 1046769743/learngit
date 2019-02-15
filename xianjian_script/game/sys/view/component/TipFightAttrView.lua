local TipFightAttrView = class("TipFightAttrView", UIBase);

--[[
    self.scale9_tips,
    self.txt_1,
    self.txt_2,
]]

function TipFightAttrView:ctor(winName)
    TipFightAttrView.super.ctor(self, winName);
end

function TipFightAttrView:loadUIComplete()
	self:registerEvent();
end 

function TipFightAttrView:registerEvent()
	TipFightAttrView.super.registerEvent();

end

function TipFightAttrView:setRewardInfo(attrStr)
	if attrStr == nil then
		return
	end

	local attrArr = string.split(attrStr,",")
	local attrId = attrArr[1]
	local attrValue = attrArr[2]

	local attrName = FuncChar.getAttrNameById(attrId)
	attrName = GameConfig.getLanguageWithSwap("tid_char_1004",attrName)
	
	local attrValueStr = GameConfig.getLanguageWithSwap("tid_char_1003",attrValue) 

	self.txt_1:setString(attrName)
	self.txt_2:setString(attrValueStr)
end

function TipFightAttrView:updateUI()
	
end


return TipFightAttrView;
