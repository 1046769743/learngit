--
-- Author: xd
-- Date: 2018-03-28 18:42:29
--

local OptionsModel = class("OptionsModel", BaseModel)


--设置 map表
OptionsModel.optionsMap = {
	vworld = 5,
	vguild = 6,
	vteam = 7,
	vlove = 8, --vprivate = 8,
	vexplore = 10, 		-- 仙盟探索
}


--发送设置变化的事件
function OptionsModel:updateData(data )
	OptionsModel.super.updateData(self,data)
	EventControler:dispatchEvent(OptionsEvent.OPTIONSEVENT_CHANGE,data)
end

--获取某一个开关设置 默认为0
function OptionsModel:getOneOption( id )
	id = tostring(id)
	return self:data()[id] 
end



return OptionsModel