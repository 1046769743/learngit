--//跑马灯
--//2016-6-14 16:32:42
--//小花熊
FuncLamp=FuncLamp or {};
local  lampTable=nil;
FuncLamp.id_type = {
	[8] = "lottery",
	[9] = "pvp",
	[10] = "pvp",
	[11] = "tower",
	[12] = "guild",
	[13] = "crossPeak",
}


function FuncLamp.init()
     lampTable=Tool:configRequire("lantern.Lantern");
end
function FuncLamp.getLamp()
    return  lampTable;
end