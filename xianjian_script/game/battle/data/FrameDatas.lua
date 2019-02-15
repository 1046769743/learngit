--
-- Author: XD
-- Date: 2014-07-11 10:18:18
--




--[[

	说明
	--			
	label = { { readyFrame,finishFrame }   , 	{ frameEvent		}		}
	aida = {  {-1(-1表示最后一帧,哪一帧),-1 }			}

	frameEvent = {
		{ 类型1表示单针事件,事件帧数, 事件函数数组  }
	}

]]


-- 	{		{  1, {-1},{	{"addEffect",	{ "800002"	}},	{"addEffect",	{ "800001"	}},		} 		}	

FrameDatas = {
	
	--公共帧数据
    common  = {

        idle    = {     {1,1}       },
        stand   = {     {1,1}       },
        stand2Start = {     {1,1}   ,{
                                        --防守开始完毕进入防守待机
                                        { 1,      {-1},{  {"justFrame",{ Fight.actions.action_stand2   }  }        }  },
                                    },

                     },



        walk    = {     {1,1}       },
        run     = {     {1,1}       },

        -- 2017.6.29 为了不在动作结束后一定执行complete
        -- attack1 = {     {1,1}   ,{
        --                             --攻击完毕要复位
        --                             { 1,      {-1},{  {"onSkillActionComplete"  }        }  },
        --                         },

        --          },

        -- attack2 = {     {1,1}   ,{
        --                             --攻击完毕要复位
        --                             { 1,      {-1},{  {"onSkillActionComplete" }        }  },
        --                         },

        --          },
        -- attack3 = {     {1,1}   ,{
        --                             --攻击完毕要复位
        --                             { 1,      {-1},{  {"onSkillActionComplete"  }        }  },
        --                         },

        --          },
        -- attack4 = {     {1,1}   ,{
        --                             --攻击完毕要复位
        --                             { 1,      {-1},{  {"onSkillActionComplete"  }        }  },
        --                         },

        --          },
        readyStart = {     {-1,-1}   ,{
                                        --准备完毕进入循环阶段
                                        { 1,      {-1},{  {"justFrame",{ Fight.actions.action_readyLoop   }  }        }  },
                                    },

                     },

        standSkillStart = {     {-1,-1}   ,{
                                        --准备完毕进入循环阶段
                                        { 1,      {-1},{  {"justFrame",{ Fight.actions.action_standSkillLoop   }  }        }  },
                                    },

                     },

        powerup = {     {1,1}   ,{
                                    --攻击完毕要复位
                                    { 1,      {-1},{  {"movetoInitPos" ,{1} }        }  },
                                },

                 },
        
       
        -- 被击退开始
        blow1 = {    {-1,-1},   {
                                    { 1,      {-1},{  {"enterBlowMiddle"}        }  },
                                },
                    }, 
        -- 被击退中
        blow2 = {    {-1,-1}, },  
        blow3 = {    {-1,-1},   {
                                        { 1,      {-1},{  {"onBlowUp"}        }  },
                                        { 1,      {3},{  {"initStand"}        }  },
                                },
                    }, 

       
        hit = {    {-1,-1},   {
                                    { 1,      {-1},{  {"onBlowUp"}        }  },
                            },
                }, 
        -- 虚弱受击与普通受击一样需要检查
        hitedWeek = {    {-1,-1},   {
                                    { 1,      {-1},{  {"onBlowUp"}        }  },
                            },
                },
        -- 格挡受击需要检查
        block = {   {-1,-1}, {
                                { 1,    {-1}, { {"onBlowUp"} }},
                            },
                },
        -- 祭出A法宝
        -- giveOutA =   {   {-1,-1},    {
        --                                 { 1,      {-1},{  {"treaGiveOutActionEnd"}              }  },
        --                             },
        --             },

        --复活
        relive = {    {-1,-1}      },

        treaOn = {    {-1,-1}      },
        treaOn2 = {    {-1,-1}      },
        treaOn3 = {    {-1,-1}      },
        --祭出开始后 跳转到 循环
        giveOutBS = {  {-1,-1} ,   {
                                        { 1,      {-1},{  {"justFrame",{"giveOutBM"}    }              }  },
                                    }, 

                    },

        
        -- 法宝崩溃后切换素颜法宝
        treaOver =  {   {-1,-1},    },

        -- 死亡                    
        die =  {   {-1,-1} ,      {
                                        { 1, {3}, {  {"jumpStopFrame"}                                               }   },     
                                        -- { 1, {-1}, { {"alreadyDead"} ,{"stopFrame"}                                  }   },  
                                        { 1, {-1}, { {"alreadyDead"}                                  }   },  
                                    },   
                    },

        },
}


-- 召唤物
local summonViewFrames = {
    ["baixingzhi_niao"] = {
            actionFrames = {
                standby2 = 22,
                dead = 28,
                attack = 21,
            },
            viewType = 1 ,
        },
}


function FrameDatas.getSummonViewData(armature)
	local data = summonViewFrames[armature]
    if not armature then
        error("summon view data is nil ___")
    end
    if not data.image then
    	--local split = string.split(armature,"_")
        --data.image = split[1]
        data.image = armature
    end
	return data
end

--获取视图的帧数据  armature 是动画的名字
function FrameDatas.getViewData(isSpine, armature)
    local data =  nil
    if isSpine then
        data = FuncArmature.getSpineArmatureFrameData( armature )
    else
        data = FuncArmature.getFlashArmatureFrameData( armature )
    end
    if not data then
        echoError("找战斗策划", armature,"没有出现在SpineAniConfig.lua里面",isSpine)
        return {}
    end
    if not data.image then
        data.image = armature
    end
	return data
end


function FrameDatas.getActionExpandData( armature)
    local data = actionsExpand[armature]
    if not armature then
        error("dsadsad")
    end
    if not data.image then
        data.image = armature
    end
    return data
end


function FrameDatas.getFrameData( id )
	return FrameDatas[id] or {}
end

function FrameDatas.getCommonActionData( label )
    
    --local len = string.len(label)
    --local serch = string.sub(label,1,len-2)
    local serch = label
	local data = FrameDatas.common[serch]
	if not data then
		return {   {-1,-1} 		}
	end
	return data
end


function FrameDatas.getActionFrameLength(armature,action)
    local arr = FrameDatas.fameLength[armature]
    for k,v in pairs(arr) do
        if action == k then
            return v
        end
    end
end