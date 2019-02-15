
-- 配置字段说明
-- did: 预留给服务器用的索引,前端不用管
-- hid: 英雄的 ID.  下面包含了目前所有的英雄,如果需要哪个英雄上阵,只需要解注释就行了
-- level: 英雄的等级
-- skills: 英雄技能的等级,目前由于英雄只设计了2个技能所有只有前2个有用.
-- star: 英雄的星级
-- stage: 英雄的品阶


-- attr 为英雄的二级属性:是通过英雄基本数据计算出来的. 但是怪物除外,怪物的二级属性直接赋值,不通过计算.
-- atk:攻击力
-- hp: 血量
-- def:物理防御
-- mdef:魔抗
-- dod: 闪避
-- hit: 命中

--initMana[int]     manaLimit[int]    manaRecover[int]  hp[int]     atk[int]    def[int]    crit[int]   resist[int] dodge[int]  hit[int]    critRate[int]


local campDatas = {
    -- 无法宝，最远程。 目前主角就用的 1017
        {
          _id = "test", hid = "102",armature = "char_1",lv = 1, energy=0,maxenergy=5,manaR=1,hp =100,maxhp =100,atk =20,def = 1,crit = 1,resist = 1,hit=10,dodge=0,critR=0,
          treasure = {
                {hid="101",state = 1,star = 1,strengthen = 1},
                {hid="102",state = 1,star = 1,strengthen = 1},
                {hid="103",state = 2,star = 1,strengthen = 1},
                {hid="104",state = 3,star = 1,strengthen = 1},
                {hid="105",state = 3,star = 1,strengthen = 1},
              }, 
        },

    	-- 前排，近战法宝
    -- 	{
    --   		hid = "1015",armature = "char_1",lv = 1, energy=0,maxenergy=5,manaR=1,hp =2000,maxhp =2000,atk =20,def = 1,crit = 1,resist = 1,hit=10,dodge=0,critR=0,
    -- 		treasure =	{
    -- 						{hid="102",state = 1,star = 1,strengthen = 2},
    --             {hid="101",state = 1,star = 1,strengthen = 2},
    --             {hid="103",state = 2,star = 1,strengthen = 2},
    -- 					}, 
    -- 	},     

    -- 	{
    --   		hid = "1015",armature = "char_1",lv = 1, energy=0,maxenergy=5,manaR=1,hp =2000,maxhp =2000,atk =20,def = 1,crit = 1,resist = 1,hit=10,dodge=0,critR=0,
    -- 		treasure =	{
    -- 						{hid="102",state = 1,star = 1,strengthen = 2},
    --             {hid="101",state = 1,star = 1,strengthen = 2},
    --             {hid="103",state = 2,star = 1,strengthen = 2},
    -- 					}, 
    -- 	},

    -- 	-- 中排，远程法宝
		  -- {
    --   		hid = "1016",armature = "char_1",lv = 1, energy=0,maxenergy=5,manaR=1,hp =2000,maxhp =2000,atk =20,def = 1,crit = 1,resist = 1,hit=10,dodge=0,critR=0,
    -- 		treasure =	{
    -- 						{hid="103",state = 2,star = 1,strengthen = 2},
    --             {hid="101",state = 1,star = 1,strengthen = 2},
    --             {hid="102",state = 1,star = 1,strengthen = 2},
    -- 					}, 
    -- 	},     

    -- 	{
    --   		hid = "1016",armature = "char_1",lv = 1, energy=0,maxenergy=5,manaR=1,hp =2000,maxhp =2000,atk =20,def = 1,crit = 1,resist = 1,hit=10,dodge=0,critR=0,
    -- 		treasure =	{
    -- 						{hid="103",state = 2,star = 1,strengthen = 2},
    --             {hid="101",state = 1,star = 1,strengthen = 2},
    --             {hid="102",state = 1,star = 1,strengthen = 2},
    -- 					}, 
    -- 	},
  }


return campDatas


