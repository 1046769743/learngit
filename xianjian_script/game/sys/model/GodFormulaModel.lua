local GodFormulaModel = class("GodFormulaModel", BaseModel);

function GodFormulaModel:init(data)
    -- dump(data,"神明上阵init")
    GodFormulaModel.super.init(self, data)
    self.godFormula = data or {}
end

function GodFormulaModel:updateData(data)
    GodFormulaModel.super.updateData(self, data)
    self.godFormula = self._data
end

--通过data 判断神明是否上阵
function  GodFormulaModel:godFormulaById(id)
    for i,v in pairs(self.godFormula) do
        if tonumber(v) == tonumber(id) then
            return true
        end
    end
    return false
end

return GodFormulaModel;





















