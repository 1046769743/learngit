
-- 服务器数据
-- hid 代表是静态数据库  did 代表实例

local VirtualServData = {


	--[[
	id             
	name       玩家名称        
	vip        VIP级别       
	lv     玩家级别        
	exp        玩家经验        
	money      用户银币数量      
	gold       钻石数     

	]]
	UserData = {
		gongfanum = 15,
		lv = 5,
		name = "我是主角",
		money = 555,
		gold = 666,

	},
	HeroData = {
		["1"] = {
			hid = "1011",
			lv = 100,	-- 等级
			xp = 1,	-- 经验
			star = 1, 	-- 星级
			stage = 2, -- 境界
			spells = {5,0,0,0,20}, -- 五个功法等级		
			treasure = {
				leftTrsuNum = 20,
				ditails ={
						["1"] = {	stage = 5, -- 法宝阶段
							level = 0, -- 法宝等级
							disNum = {0,0}, -- 分配的数目
							--disNum = {idx = 8,step = 2}
							costMoney = 150, -- 分配潜力点用的金币总量
							potential = 13-- 潜力值
						},
						["2"] = {	stage = 1, -- 法宝阶段 0表示没有开启
							level = 0, -- 法宝等级
							disNum = {0,0}, -- 分配的数目
							costMoney = 150, -- 分配潜力点用的金币总量
							potential = 13-- 潜力值
						},
						["3"] = {	stage = 0, -- 法宝阶段
							level = 0, -- 法宝等级
							disNum = {0,0}, -- 分配的数目
							costMoney = 150, -- 分配潜力点用的金币总量
							potential = 13-- 潜力值
						},
						["4"] = {	stage = 0, -- 法宝阶段
							level = 0, -- 法宝等级
							disNum = {0,0}, -- 分配的数目
							costMoney = 150, -- 分配潜力点用的金币总量
							potential = 13-- 潜力值
						},
					},
				},		
			elixirs = 
				{
					stage = 1, -- 仙肴的境界
					-- 吃的仙肴ID
					order = {
    				    ["1"] = {1},
    				    -- ["2"] = {1},
    				    -- ["3"] = {1,2},
    				    -- ["4"] = {1,2},
    				    -- ["5"] = {1,2,3},
					}
				}
		},
		["2"] = {
			hid = "1012",
			lv = 50,	-- 等级
			xp = 1,	-- 经验
			star = 3, 	-- 星级
			stage = 5, -- 境界
			spells = {5,5,0,0,0}, -- 留个功法等级			
			treasure = {
				leftTrsuNum = 20,
				ditails ={
						["1"] = {	stage = 3, -- 法宝阶段
							level = 6, -- 法宝等级
							disNum = {2,2}, -- 分配的数目
							costMoney = 150, -- 分配潜力点用的金币总量
							potential = 13-- 潜力值
						},
						["2"] = {	stage = 1, -- 法宝阶段
							level = 6, -- 法宝等级
							disNum = {2,2}, -- 分配的数目
							costMoney = 150, -- 分配潜力点用的金币总量
							potential = 13-- 潜力值
						},
						["3"] = {	stage = 1, -- 法宝阶段
							level = 6, -- 法宝等级
							disNum = {2,2}, -- 分配的数目
							costMoney = 150, -- 分配潜力点用的金币总量
							potential = 13-- 潜力值
						},
						["4"] = {	stage = 1, -- 法宝阶段
							level = 6, -- 法宝等级
							disNum = {2,2}, -- 分配的数目
							costMoney = 150, -- 分配潜力点用的金币总量
							potential = 13-- 潜力值
						},
					},
				},		
			elixirs = 
				{
					stage = 2, -- 仙肴的境界
                    -- 吃的仙肴ID
                    order = {
                          ["1"] = {1},
                          ["2"] = {1},
                    }
				}
		},
		["3"] = {
			hid = "1016",
			lv = 70,	-- 等级
			xp = 1,	-- 经验
			star = 1, 	-- 星级
			stage = 1, -- 境界
			spells = {4,4,4,0,0}, -- 留个功法等级			
			treasure = {
				leftTrsuNum = 20,
				ditails ={
						["1"] = {	stage = 1, -- 法宝阶段
							level = 6, -- 法宝等级
							disNum = {2,2}, -- 分配的数目
							costMoney = 150, -- 分配潜力点用的金币总量
							potential = 13-- 潜力值
						},
						["2"] = {	stage = 1, -- 法宝阶段
							level = 6, -- 法宝等级
							disNum = {2,2}, -- 分配的数目
							costMoney = 150, -- 分配潜力点用的金币总量
							potential = 13-- 潜力值
						},
						["3"] = {	stage = 1, -- 法宝阶段
							level = 6, -- 法宝等级
							disNum = {2,2}, -- 分配的数目
							costMoney = 150, -- 分配潜力点用的金币总量
							potential = 13-- 潜力值
						},
						["4"] = {	stage = 1, -- 法宝阶段
							level = 6, -- 法宝等级
							disNum = {2,2}, -- 分配的数目
							costMoney = 150, -- 分配潜力点用的金币总量
							potential = 13-- 潜力值
						},
					},
				},		
			elixirs = 
				{
					stage = 5, -- 仙肴的境界
                    -- 吃的仙肴ID
                    order = {
                          ["1"] = {1},
                          ["2"] = {1},
                          ["3"] = {1,2},
                          ["4"] = {1,2},
                          ["5"] = {1,2,3},
                    }
				}
		},
		["4"] = {
			hid = "1014",
			lv = 20,	-- 等级
			xp = 1,	-- 经验
			star = 1, 	-- 星级
			stage = 2, -- 境界
			spells = {3,3,3,3,0}, -- 留个功法等级			
			treasure = {
				leftTrsuNum = 20,
				ditails ={
						["1"] = {	stage = 1, -- 法宝阶段
							level = 6, -- 法宝等级
							disNum = {2,2}, -- 分配的数目
							costMoney = 150, -- 分配潜力点用的金币总量
							potential = 13-- 潜力值
						},
						["2"] = {	stage = 1, -- 法宝阶段
							level = 6, -- 法宝等级
							disNum = {2,2}, -- 分配的数目
							costMoney = 150, -- 分配潜力点用的金币总量
							potential = 13-- 潜力值
						},
						["3"] = {	stage = 1, -- 法宝阶段
							level = 6, -- 法宝等级
							disNum = {2,2}, -- 分配的数目
							costMoney = 150, -- 分配潜力点用的金币总量
							potential = 13-- 潜力值
						},
						["4"] = {	stage = 1, -- 法宝阶段
							level = 6, -- 法宝等级
							disNum = {2,2}, -- 分配的数目
							costMoney = 150, -- 分配潜力点用的金币总量
							potential = 13-- 潜力值
						},
					},
				},		
			elixirs = 
				{
					stage = 3, -- 仙肴的境界
                    -- 吃的仙肴ID
                    order = {
                          ["1"] = {1},
                          ["2"] = {1},
                          ["3"] = {1,2},
                    }
				}
		},
		["5"] = {
			hid = "1015",
			lv = 33,	-- 等级
			xp = 1,	-- 经验
			star = 1, 	-- 星级
			stage = 3, -- 境界
			spells = {6,5,4,3,2}, -- 留个功法等级			
			treasure = {
				leftTrsuNum = 20,
				ditails ={
						["1"] = {	stage = 1, -- 法宝阶段
							level = 6, -- 法宝等级
							disNum = {2,2}, -- 分配的数目
							costMoney = 150, -- 分配潜力点用的金币总量
							potential = 13-- 潜力值
						},
						["2"] = {	stage = 1, -- 法宝阶段
							level = 6, -- 法宝等级
							disNum = {2,2}, -- 分配的数目
							costMoney = 150, -- 分配潜力点用的金币总量
							potential = 13-- 潜力值
						},
						["3"] = {	stage = 1, -- 法宝阶段
							level = 6, -- 法宝等级
							disNum = {2,2}, -- 分配的数目
							costMoney = 150, -- 分配潜力点用的金币总量
							potential = 13-- 潜力值
						},
						["4"] = {	stage = 1, -- 法宝阶段
							level = 6, -- 法宝等级
							disNum = {2,2}, -- 分配的数目
							costMoney = 150, -- 分配潜力点用的金币总量
							potential = 13-- 潜力值
						},
					},
				},		
			elixirs = 
				{
					stage = 6, -- 仙肴的境界
                    -- 吃的仙肴ID
                    order = {
                          ["1"] = {1},
                          ["2"] = {1},
                          ["3"] = {1,2},
                          ["4"] = {1,2},
                          ["5"] = {1,2,3},
                          ["6"] = {1,2,3,4},
                    }
				}
		},
	},
	ItemData = {
		
		[1] =
		{
			id = 1,
			hid = "1001",
			type = 2,
			nums = 1,
		},
		[2] =
		{
			id = 2,
			hid = "1002",
			type = 2,
			nums = 2,
		},
		[3] =
		{
			id = 3,
			hid = "1003",
			type = 2,
			nums = 3,
		},
		[4] =
		{
			id = 4,
			hid = "1004",
			type = 2,
			nums = 4,
		},
		[5] =
		{
			id = 5,
			hid = "1005",
			type = 2,
			nums = 5,
		},
		[6] =
		{
			id = 6,
			hid = "1006",
			type = 2,
			nums = 6,
		},
		[7] =
		{
			id = 7,
			hid = "2002",
			type = 1,
			nums = 7,
		},
		[8] =
		{
			id = 8,
			hid = "2003",
			type = 1,
			nums = 8,
		},
		[9] =
		{
			id = 9,
			hid = "2004",
			type = 1,
			nums = 9,
		},
		[10] =
		{
			id = 10,
			hid = "2005",
			type = 1,
			nums = 10,
		},
		[11] =
		{
			id = 11,
			hid = "2016",
			type = 1,
			nums = 11,
		},
		[12] =
		{
			id = 12,
			hid = "2017",
			type = 1,
			nums = 12,
		},
		[13] =
		{
			id = 13,
			hid = "2018",
			type = 1,
			nums = 13,
		},
		[14] =
		{
			id = 14,
			hid = "2019",
			type = 1,
			nums = 14,
		},
		[15] =
		{
			id = 15,
			hid = "2020",
			type = 1,
			nums = 15,
		},
		[16] =
		{
			id = 16,
			hid = "3001",
			type = 3,
			nums = 16,
		},
		[17] =
		{
			id = 17,
			hid = "3002",
			type = 3,
			nums = 17,
		},
		[18] =
		{
			id = 18,
			hid = "3021",
			type = 3,
			nums = 18,
		},
		[19] =
		{
			id = 19,
			hid = "3022",
			type = 3,
			nums = 19,
		},
		[20] =
		{
			id = 20,
			hid = "3062",
			type = 3,
			nums = 20,
		},
		[21] =
		{
			id = 21,
			hid = "4001",
			type = 99,
			nums = 21,
		},
		[22] =
		{
			id = 22,
			hid = "4005",
			type = 99,
			nums = 22,
		},
		[23] =
		{
			id = 23,
			hid = "4007",
			type = 99,
			nums = 23,
		},
		[24] =
		{
			id = 24,
			hid = "4009",
			type = 99,
			nums = 24,
		},
		[25] =
		{
			id = 25,
			hid = "4020",
			type = 99,
			nums = 25,
		},
		[26] =
		{
			id = 26,
			hid = "4021",
			type = 99,
			nums = 26,
		},
		[27] =
		{
			id = 27,
			hid = "4022",
			type = 99,
			nums = 27,
		},
		[28] =
		{
			id = 28,
			hid = "4023",
			type = 99,
			nums = 28,
		},
		[29] =
		{
			id = 29,
			hid = "4024",
			type = 99,
			nums = 29,
		},
		[30] =
		{
			id = 30,
			hid = "4025",
			type = 99,
			nums = 30,
		},
	},
	PlayerData = {
		userid = 101,
		name = "笑傲江湖",
		lv = 61,
		xp = 888888,
		stage = 1,
		linggen = {5,4,3,2,0,0}, -- 各灵根等级【以及五行归元的等级】{金,水,木,火,土,合一}  灵根起始值1级
		bigspells = {[1]={["id"]="1001",["stage"]=6,["canjuan"]=5},[2]={["id"]="2001",["stage"]=0,["canjuan"]=3},[3]={["id"]="3001",["stage"]=0,["canjuan"]=0}}, -- 三个大功法等级【分别记录每一个功法的等级】
		smallspells = {
			[1]={
				--[1002]=9,[1003]=8,[1004]=7,[1005]=6,[1006]=5,[1007]=4,[1008]=3,[1009]=2,[1010]=1
				[1]={["id"]="1002",["stage"]=6},
				[2]={["id"]="1003",["stage"]=5},
				[3]={["id"]="1004",["stage"]=4},
				[4]={["id"]="1005",["stage"]=3},
				[5]={["id"]="1006",["stage"]=2},
				[6]={["id"]="1007",["stage"]=1},
				[7]={["id"]="1008",["stage"]=1},
				[8]={["id"]="1009",["stage"]=1},
				[9]={["id"]="1010",["stage"]=1}
			},
			[2]={
				--[2002]=9,[2003]=8,[2004]=7,[2005]=6,[2006]=5,[2007]=4,[2008]=3,[2009]=2,[2010]=1
				[1]={["id"]="2002",["stage"]=6},
				[2]={["id"]="2003",["stage"]=5},
				[3]={["id"]="2004",["stage"]=4},
				[4]={["id"]="2005",["stage"]=3},
				[5]={["id"]="2006",["stage"]=2},
				[6]={["id"]="2007",["stage"]=1},
				[7]={["id"]="2008",["stage"]=1},
				[8]={["id"]="2009",["stage"]=1},
				[9]={["id"]="2010",["stage"]=1}
			},
			[3]={
				--[3002]=9,[3003]=8,[3004]=7,[3005]=6,[3006]=5,[3007]=4,[3008]=3,[3009]=2,[3010]=1
				[1]={["id"]="3002",["stage"]=6},
				[2]={["id"]="3003",["stage"]=5},
				[3]={["id"]="3004",["stage"]=4},
				[4]={["id"]="3005",["stage"]=3},
				[5]={["id"]="3006",["stage"]=2},
				[6]={["id"]="3007",["stage"]=1},
				[7]={["id"]="3008",["stage"]=1},
				[8]={["id"]="3009",["stage"]=1},
				[9]={["id"]="3010",["stage"]=1}
			}
		}, --对应小功法等级
		lingbao = {
			[1]={["id"]="1",["stage"]=5,["canjuan"]=5},
			[2]={["id"]="2",["stage"]=3,["canjuan"]=0},
			[3]={["id"]="3",["stage"]=2,["canjuan"]=6},
			[4]={["id"]="4",["stage"]=0,["canjuan"]=6},
			[5]={["id"]="5",["stage"]=0,["canjuan"]=6},
		}, -- 通天灵宝的等级【和其碎片的数量】
	}

}

return VirtualServData