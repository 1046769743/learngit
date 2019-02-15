
local EliteChanllengeModel = class("EliteChanllengeModel", BaseModel)

function EliteChanllengeModel:init(eliteArr)
	EliteChanllengeModel.super.init(self, eliteArr)
    self.elitesChallengeArr = self._data;  -- 记录挑战

end



function EliteChanllengeModel:updateData(data)

	EliteChanllengeModel.super.updateData(self, data);
    
end

function EliteChanllengeModel:getData()
    return self.elitesChallengeArr or {}
end


return EliteChanllengeModel
