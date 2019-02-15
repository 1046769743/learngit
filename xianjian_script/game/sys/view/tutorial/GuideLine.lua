--guan
--2017.5.16
-- 美术为了效果，每个位置作死了一个动画，这里先这样写，之后需要写成配置方式的
local GuideLine = class("GuideLine", UIBase);

local trans = {
	[1] = "UI_qiangzhitishi_tishihuanren01",
	[2] = "UI_qiangzhitishi_tishihuanren03",
	[3] = "UI_qiangzhitishi_tishihuanren04",
	[4] = "UI_qiangzhitishi_tishihuanren06",
	[5] = "UI_qiangzhitishi_tishihuanren05",
}
function GuideLine:ctor(winName)
    GuideLine.super.ctor(self, winName);
    self._aniCache = {}
end

function GuideLine:loadUIComplete()
	self:registerEvent();
	self._root:setVisible(false)
end 

function GuideLine:registerEvent()
	GuideLine.super.registerEvent();

end

function GuideLine:setLineRotation( rtype )
	if not rtype then return end
	if not trans[rtype] then return end

	if not self._aniCache[rtype] then
		local ani = self:createUIArmature("UI_qiangzhitishi",trans[rtype], self, true)
		self._aniCache[rtype] = ani
	end

	for k,ani in pairs(self._aniCache) do
		ani:visible(rtype == k)
	end
end


function GuideLine:updateUI()
	
end

return GuideLine;




