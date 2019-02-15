local PowerComponent = class("PowerComponent", UIBase);

--[[
    self.mc_shuzi,
]]

function PowerComponent:ctor(winName)
    PowerComponent.super.ctor(self, winName);
end

function PowerComponent:loadUIComplete()
	self:registerEvent();
    --初始的坐标偏移是13
    self.initOffset = 13
    --数字1的 一半偏移是 7
    self.numeOneOffset = 7;
    --每一个数字的平均宽度是30
    self.perWidth = 25
    self:setNumOneOffsetAndPerWidth(25,7)
end 

--设置数字1的偏移 默认是遇到1 1后面的所有人都向左偏移多少像素
function PowerComponent:setNumOneOffsetAndPerWidth( perWidth,numOneOffset )
    self.perWidth = perWidth
    self.numeOneOffset = numOneOffset
end


function PowerComponent:registerEvent()
	PowerComponent.super.registerEvent();

end

function PowerComponent:setPower(num)
    local powerValueTable = number.split(num);
    self:setPowerNum(powerValueTable);
end

function PowerComponent:setPowerNum(nums)
    local len = table.length(nums);

    --不能高于6
    if len > 6 then 
        return
    end 
    self.mc_shuzi:showFrame(len);

    local offsetx = 0

    for k, v in ipairs(nums) do
        local mcs = self.mc_shuzi:getCurFrameView();
        local childMc = mcs["mc_" .. tostring(k)]
        childMc:showFrame(v + 1);
        --如果是数字1
        if v == 1 then
            offsetx = offsetx - self.numeOneOffset 
        end
        local xpos = (k-1) * self.perWidth + offsetx + self.initOffset
        local childCtn = mcs["ctn_" .. tostring(k)]
        if v == 1 then
            offsetx = offsetx - self.numeOneOffset 
        end
        childMc:setPositionX(xpos)
        childCtn:setPositionX(xpos)



    end
end


function PowerComponent:updateUI()
	
end


return PowerComponent;
