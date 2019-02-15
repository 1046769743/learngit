--guan
--2017.5.16

local WrongClickTips = class("WrongClickTips", UIBase);


function WrongClickTips:ctor(winName)
    WrongClickTips.super.ctor(self, winName);
end

function WrongClickTips:loadUIComplete()
	self:registerEvent();
end 

function WrongClickTips:registerEvent()
	WrongClickTips.super.registerEvent();

end

function WrongClickTips:updateUI()
	
end

function WrongClickTips:setContent( str )
	self.panel_npcAndWord.panel_word.rich_1:setString(str)
end

return WrongClickTips;




