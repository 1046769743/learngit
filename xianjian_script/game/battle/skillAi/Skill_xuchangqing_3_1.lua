--[[
	Author:李朝野
	Date: 2017.08.09
	Modify: 2018.03.16
]]

--[[
	徐长卿大招扩充1（联动被动）

	技能描述：
	攻击敌方全体，并给己方气血比例最低奇侠增加护盾，每一枚符文提高一定护盾吸收量；

	脚本处理部分：
	根据当前符文量提升护盾吸收量

	参数：
	buffId 护盾buffId
	rate 每个符文对应的value
]]
local Skill_xuchangqing_3 = require("game.battle.skillAi.Skill_xuchangqing_3")
local Skill_xuchangqing_3_1 = class("Skill_xuchangqing_3_1", Skill_xuchangqing_3)


function Skill_xuchangqing_3_1:ctor(...)
	Skill_xuchangqing_3_1.super.ctor(self,...)
end

return Skill_xuchangqing_3_1