-- local _data = {
-- 	battleId = 1203,
-- 	battleLabel = "22",
-- 	battleParams = {
-- 		robotId = 6,
-- 		selectCardList = {
-- 			team1 = {
-- 				{cardId = "340054",cardType = 1},{cardId = "340214",cardType = 1},
-- 				{cardId = "340344",cardType = 1},{cardId = "340444",cardType = 1},
-- 				{cardId = "340514",cardType = 1},{cardId = "340094",cardType = 1},
-- 			},
-- 			team2 = {
-- 				{cardId = "340164",cardType = 1},{cardId = "340314",cardType = 1},
-- 				{cardId = "340124",cardType = 1},{cardId = "340074",cardType = 1},
-- 				{cardId = "404",cardType = 2},{cardId = "401",cardType = 2},
-- 			},
-- 		},
-- 		playType = 2,
-- 		battleMode = 2,
-- 	},
-- 	battleUsers = {
-- 		{rid = 6,team=2,userBattleType = 2},
-- 		{
-- 			crossPeak = {currSegment = 1,losingStreak = 0,score = 1000,winningStreak = 0},
-- 			userExt = {garmentId = ""},
-- 			team = 1,
-- 			avatar = 104,
-- 			rid = 1,
-- 			userBattleType = 1,
-- 		},
-- 	},
-- 	userRid = 1,
-- }

local _data = {
	battleId = 1203,
	battleLabel = "22",
	randomSeed = 14088432,
	battleParams = {
		robotId = 1001,
		playType = 2,
		battleMode = 1,
	},
	battleUsers = {
		{rid = 1001,team=1,userBattleType = 2},
		{
			crossPeak = {currSegment = 1,losingStreak = 0,score = 1000,winningStreak = 0,},
			userExt = {garmentId = ""},
			team = 2,
			avatar = 104,
			rid = 1,
			userBattleType = 1,
			star = 1,
			quality = 1,
			formation = {
				treasureFormation = {p1="404",p2 = 0},
				partnerFormation={
					p1={partner={partnerId="216016",rid=1,teamFlag = 1},element={elementId="0"}},
					p2={partner={partnerId="1",rid=1},element={elementId="0"}},
					p3={partner={partnerId="0",rid=1},element={elementId="0"}},
					p4={partner={partnerId="0",rid=1},element={elementId="0"}},
					p5={partner={partnerId="5033",rid=1},element={elementId="0"}},
					p6={partner={partnerId="5005",rid=1},element={elementId="0"}},
				},
				bench = {["1"]="5003",["2"] = "5011",["3"] = "5015"},
			},
			partners = {["5005"] = {id = "5005",star = 1,quality = 1 ,skin=""},
				["5033"] = {id = "5033",star = 1,quality = 1 ,skin=""},
				["5003"] = {id = "5003",star = 1,quality = 1 ,skin=""},
				["5011"] = {id = "5011",star = 1,quality = 1 ,skin=""},
				["5015"] = {id = "5015",star = 1,quality = 1 ,skin=""},
				},
			treasures = {["404"] = {id=404,star = 1,awaken = 0,starPoint = 0}},
			fivesouls = {["1"]=1,["2"]=2,["3"]=3,["4"]=4,["5"]=5,},

		},
	},
	userRid = 1,
}
return _data