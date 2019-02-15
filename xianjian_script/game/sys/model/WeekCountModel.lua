-- WeekCountModel
-- 周 次数 model


local WeekCountModel = class("WeekCountModel", BaseModel)

function WeekCountModel:init(d)
	WeekCountModel.super.init(self, d)
	self.data = d
	dump(self.data,"每周的记录次数======")
end



function WeekCountModel:updateData(data)
	WeekCountModel.super.updateData(self, data)

	dump(self.data,"更新每周的记录次数======")
	
end













return WeekCountModel












