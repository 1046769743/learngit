--[[
	Author: lichaoye
	Date: 2017-04-13
	查看阵容-装备Tips
]]
local LineUpEquipTipsView = class("LineUpEquipTipsView",InfoTips1Base)

function LineUpEquipTipsView:ctor( winName, equipInfo, position )
	LineUpEquipTipsView.super.ctor(self, winName)
	self._equipInfo = equipInfo
	-- self._pos = position
end

function LineUpEquipTipsView:loadUIComplete()
    self:registerEvent()
    -- self:alignDetailView()
    self:updateUI()
end

function LineUpEquipTipsView:registerEvent()
    LineUpEquipTipsView.super.registerEvent(self)
    self:registClickClose("out")
end

function LineUpEquipTipsView:alignDetailView()
	local _rect = self.panel_1:getContainerBox()
    --判断是否在调整后出现越过边界行为
    --优先限计算面板向下延伸
    local x = self._pos.x
    local y = self._pos.y
    if x + _rect.width > GameVars.width then--X镜像反射
        x = x - _rect.width
    end
    if y - _rect.height <0  then--Y镜像反射
        y = y + _rect.height
    end
    --转换到蒙版中的
    self.panel_1:pos(cc.p(x - GameVars.UIOffsetX,  y - GameVars.height))
end

function LineUpEquipTipsView:updateUI()
	-- 隐藏几个箭头
	self.panel_1.panel_left:visible(false)
	self.panel_1.panel_right:visible(false)
	self.panel_1.panel_up:visible(false)
	self.panel_1.panel_down:visible(false)
	local _equipData = FuncPartner.getEquipmentById(self._equipInfo.id)
	_equipData = _equipData[tostring(self._equipInfo.level)]
	-- 武器名
	local name = FuncPartner.getEquipmentName(tostring(self._equipInfo.id), tostring(self._equipInfo.partnerId))
	self.panel_1.txt_t:setString(GameConfig.getLanguage(name))
	-- 武器描述
	local plusVec = _equipData.subAttr or _equipData.subAttrPlus
	local tempTxt = {}
	
	local index = 1
    for i,v in pairs(plusVec) do
        local _str = FuncPartnerEquipAwake.getDesStaheTable(v)
        -- 判断是否已觉醒
        if self._equipInfo.awake then
            local awakeId = FuncPartner.getAwakeEquipIdByid(self._equipInfo.partnerId, self._equipInfo.id)
            local jxAtt = FuncPartnerEquipAwake.getAwakeAttrValue(awakeId, v.key, v)
            if jxAtt then
                _str = _str.."<color = 00FF00>+"..jxAtt.."<->"
            end
        end
        table.insert(tempTxt, _str.."\n")
        index = index + 1
    end

	if self._equipInfo.awake then
		local awakeAttr = FuncPartnerEquipAwake.getAwakeEquipsAttrById(self._equipInfo.partnerId, self._equipInfo.id)
		dump(awakeAttr, "\n\nawakeAttr===")
		for i,v in pairs(awakeAttr) do
	        local isHas = false
	        for ii,vv in pairs(plusVec) do
	            if tostring(vv.key) == tostring(v.key) then
	                isHas = true
	            end
	        end

	        if isHas == false then
	            if index <= 4 then
	                local awakeId = FuncPartner.getAwakeEquipIdByid(self._equipInfo.partnerId, self._equipInfo.id)
	                local jxAtt = FuncPartnerEquipAwake.getAwakeAttrValue(awakeId,v.key)
	                
	                local name = FuncPartnerEquipAwake.getNameAndValueStaheTable(v)
	                _str = "<color = 00FF00>"..name.."："..jxAtt.."<->"
	                index = index + 1
	                table.insert(tempTxt, _str.."\n")
	            end
	        end
		end
	end
	local des = table.concat(tempTxt, "\n")
	self.panel_1.rich_2:setString(des)
end

return LineUpEquipTipsView