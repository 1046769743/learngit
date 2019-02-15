--[[
	Author: wk
	Date: 2018-04-22
	PlayerTitleAndCrown  --显示在玩家头上的称号和境界
]]

local PlayerTitleAndCrown = class("PlayerTitleAndCrown", UIBase)

	
local nameLaberZorder = 1000;

function PlayerTitleAndCrown:ctor( winName, params)
	PlayerTitleAndCrown.super.ctor(self, winName)
	params = params or {}
	self.params = {
		titleId = params.titleId,
		name = params.name,
		crown = params.crown,
	}



end

function PlayerTitleAndCrown:registerEvent()
	PlayerTitleAndCrown.super.registerEvent()
	-- EventControler:addEventListener(LineUpEvent.PRAISE_LIST_UPDATE_EVENT, self.updateUI, self)
    -- self.btn_close:setTap(c_func(self.press_btn_close, self))
   
end

function PlayerTitleAndCrown:loadUIComplete()
    local playerNamePanel = self.panel_t
    self.oldpositionx = playerNamePanel.mc_touxian:getPositionX()
	self:update(self.params)
end


	
function PlayerTitleAndCrown:update(data)
    -- dump(data,"22222222222222222222")
	local titleId = data.titleId or "" --TitleModel:gettitleids()
	local name = data.name
	local crown = data.crown
	local _ctn  = self.panel_t.ctn_1
    self:addCharTitle(_ctn,titleId)
    local playerNamePanel = self.panel_t
    playerNamePanel.txt_name:setString(name or GameConfig.getLanguage("tid_common_2006"));
    -- self.:addChild(playerNamePanel, nameLaberZorder);
    -- self.oldpositionx = playerNamePanel.mc_touxian:getPositionX()
    playerNamePanel.mc_touxian:showFrame(crown or 1)
    self:TouXianAndNameShiPei(playerNamePanel.mc_touxian,playerNamePanel.txt_name,name)
   
end
--添加称号
function PlayerTitleAndCrown:addCharTitle(_ctn,titleid)
    _ctn:removeAllChildren()
    if titleid and titleid ~= "" then
        if type(titleid) == "table" then
            for k,v in pairs(titleid) do
               titleid = k
            end
        end
        local titlesprite = FuncTitle.bytitleIdgetpng(titleid)
        local titlepng = display.newSprite(titlesprite)
        titlepng:setScale(0.8)
        _ctn:addChild(titlepng)
    end
end

function PlayerTitleAndCrown:TouXianAndNameShiPei(object1,object2,name)
    local width = 0 
    if name == nil then
        name =  "少侠"
    end
    width = FuncCommUI.setRichwidth(name)
    local x = self.oldpositionx
    object1:setPositionX(x-width/2-60)
end



return PlayerTitleAndCrown