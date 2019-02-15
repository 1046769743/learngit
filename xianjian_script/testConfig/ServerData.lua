local data = {
    {
      _id         = "1", 
      sec      = "dev",
      avatar     = 101,
      enterBattleFrame = 0,
      level       = 1,      
      state     = 1,
      
      userExt = {
        pulseNode = "1",
    },
            
      states = {
          {
              advId  = 0,
              id    = 1,
              status = 0,
           },
      },
      team    = 1,   

	    formation = {
    		partnerFormation = {
	    		-- ["p1"] = 1,
	    		-- ["p2"] = "5001",
	    		-- ["p3"] = "5003",
	    		-- ["p4"] = "5022",
	    		p1 = {
	    			partner = {
	    				partnerId = "5001",
	    				rid = "test_config",
		    		},
		    		element = {
		    			elementId = 0,
			    	}
		    	},
		    	p2 = {
	    			partner = {
	    				partnerId = "5003",
	    				rid = "test_config",
		    		},
		    		element = {
		    			elementId = 0,
			    	}
		    	},
		    	p3 = {
	    			partner = {
	    				partnerId = "5022",
	    				rid = "test_config",
		    		},
		    		element = {
		    			elementId = 0,
			    	}
		    	},
    		},
		},

    partners = {
      ["5001"] = {
        level=17,
        star=2,
        position=0,
        id=5001,
        skills={["300372"]=1,["300373"]=1},
        souls={["33001"]={["level"]=1,["exp"]=0,["id"]=33001}},
        equips={["20009"]={["level"]=1,["id"]=20009}},
        souls = {["33001"] = {id = "33001",level = 1,exp =0}},
        exp = 1,
        starPoint =0,
        quality = 1,
      },
      ["5003"] = {
        level=17,
        star=2,
        position=2,
        id=5003,
        skills={["300052"]=1,["300053"]=1},
        souls={["33001"]={["level"]=1,["exp"]=0,["id"]=33001}},
        equips={["20009"]={["level"]=1,["id"]=20009}},
        souls = {["33001"] = {id = "33001",level = 1,exp =0}},
        exp = 1,
        starPoint =2,
        quality = 1,
      },
      ["5022"] = {
        level=17,
        star=2,
        position=3,
        id=5022,
        skills={["300042"]=1,["300043"]=1},
        souls={["33001"]={["level"]=1,["exp"]=0,["id"]=33001}},
        equips={["20009"]={["level"]=1,["id"]=20009}},
        souls = {["33001"] = {id = "33001",level = 1,exp =0}},
        exp = 1,
        starPoint =3,
        quality = 1,
      },
    },

      treasures = {
          ["101"] = { -- 悬挂式的还没有 铁盾 
               lastUseTime = 0,
               level       = 1,
               star        = 1,
               state       = 1,
               status      = 1,
          },
      },
        userBattleType = 1,
    },
 }

 return data