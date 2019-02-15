--guan
--2016.7.11

local PowerRolling = class("PowerRolling", UIBase);

--[[
    self.UI_1.mc_shuzi,
]]

function PowerRolling:ctor(winName, prePower, curPower)
    PowerRolling.super.ctor(self, winName);
    --之前的power
    self._prePower = prePower;
    --现在的power
    self._curPower = curPower;
end

function PowerRolling:loadUIComplete()
	self:registerEvent();
    if(self._prePower~=nil)then
	     self:setPower(self._prePower);
    end
    self.animT = {}
end 

function PowerRolling:resetPower( prePower, curPower )
    --之前的power
    self._prePower = prePower;
    --现在的power
    self._curPower = curPower;
    if(self._prePower~=nil)then
         self:setPower(self._prePower);
    end
end

function PowerRolling:registerEvent()
	PowerRolling.super.registerEvent();
end

function PowerRolling:setPowerNum(nums)
    local len = table.length(nums);

    --不能高于6
    if len > 6 then 
        return
    end 
    self.UI_1.mc_shuzi:showFrame(len);

    for k, v in pairs(nums) do
        local mcs = self.UI_1.mc_shuzi:getCurFrameView();
        mcs["mc_" .. tostring(k)]:showFrame(v + 1);
    end

end

--设置威能 isWithAnimation 是否动画跳过去
function PowerRolling:setPower(power, isWithAnimation)
    local powerValueTable = number.split(power);

    if isWithAnimation ~= true then 
        self:setPowerNum(powerValueTable);
    else 
        self:setPowerWithAni(self);
    end 

    self._beforePowerNum = power;
end

--动画
function PowerRolling:setPowerWithAni()
    local prePowerArray = number.split(self._prePower);
    local curPowerArray = number.split(self._curPower);

    local preLen = table.length(prePowerArray);
    local curLen = table.length(curPowerArray);

    --不能高于6
    if curLen > 6 then 
        return
    end 

    if not self.animT[curLen] then
        self.animT[curLen] = {}
    end
    local animCurLenT = self.animT[curLen]

    --战力下降如何是好？？
    if self._curPower < self._prePower then 
        return ;
    end 

    self.UI_1.mc_shuzi:showFrame(curLen);
    local mcs = self.UI_1.mc_shuzi:getCurFrameView();

    --搞到新的位数上
    if preLen ~= curLen then 
        local mcIndex = 0;
        for i = 1, curLen - preLen do
            mcIndex = mcIndex + 1;
            mcs["mc_" .. tostring(mcIndex)]:visible(false);
        end

        for i = 1, preLen do
            mcIndex = mcIndex + 1;
            local num = prePowerArray[i];
            mcs["mc_" .. tostring(mcIndex)]:showFrame(num + 1);
        end
    end 

    local diffDigitCount = number.diffDigitCount(self._prePower, self._curPower)
    for i = 1, diffDigitCount do
        self:delayCall(function ( ... )
            local ctn = mcs["ctn_" .. tostring(curLen - i + 1)];
            local changeMc = mcs["mc_" .. tostring(curLen - i + 1)];

            if not animCurLenT[i] then
                animCurLenT[i] = self:createUIArmature("UI_zhanlibianhua", "UI_zhanlibianhua_zhanli5", 
                    ctn, false, GameVars.emptyFunc);
                animCurLenT[i]:setScale(1.0);
            end
            animCurLenT[i]:startPlay(false,true)
            changeMc:setScale(1.3)
            changeMc:setPosition(0, 0);
            FuncArmature.changeBoneDisplay(animCurLenT[i], "c", changeMc);
            changeMc:showFrame(curPowerArray[curLen - i + 1] + 1);
        end, 1/30 * (i - 1) * 4);
    end 
end

--开始滚！
function PowerRolling:startRolling()
	self:setPower(self._curPower, true);
end

return PowerRolling;
