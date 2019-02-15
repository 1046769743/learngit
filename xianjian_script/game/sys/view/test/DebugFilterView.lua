--
-- Author: xd
-- Date: 2016-07-19 19:06:50
--
DebugFilterView = class("DebugFilterView", UIBase)
local keyArr = {
		"mr","mg","mb","ma",
		"or","og","ob","oa",
	}
function DebugFilterView:loadUIComplete(  )
	
	
	local minMaxArr = {

	}

	local defaultPercent = LS:pub():get("debug_filter")
	if not defaultPercent then
		defaultPercent = {100,100,100,100,50,50,50,50}
	else
		defaultPercent = json.decode(defaultPercent)
	end
	if not defaultPercent then
		defaultPercent = {100,100,100,100,50,50,50,50}
	end

	for i,v in ipairs(keyArr) do
		if i > 4 then
			self["slider_"..v]:setMinMax(-255, 255)
			-- self["slider_"..v]:setPercent(50)
		else
			self["slider_"..v]:setMinMax(-100, 100)
			-- self["slider_"..v]:setPercent(50)
			
		end
		self["slider_"..v]:setPercent(defaultPercent[i] or 0)
		self["slider_"..v]:onSliderChange(c_func(self.onSliderChange, self))
		self["slider_"..v].txt_des:setString(v)
	end

	
	local spriteArr = {
        {"test/treaIcon_308.png",74,-253},
        {"test/treaIcon_316.png",458,-253},
        {"test/shui1.png",636,-222},
        {"test/tesaaa.png",370,-294},
        {"test/pic512256.png",8,-454},
        {"test/yuanjian2.png",524,-438}
    }
 
    local nd = display.newNode():addto(self):pos(0,50)
   
    local turnColorTransForm = function (mr,mg,mb,ma,orr,og,ob,oa   )
        local adjr = orr < 0 and 0 or mr
        local adjg  = og < 0 and 0 or og
        local adjb = ob < 0 and 0 or ob
        local adja = oa < 0 and 0 or oa

        local params={
            mul = {n = "u_colorMul",v={x=mr,y=mg,z=mb,w=ma} },
            off = {n = "u_colorOffset",v={x=orr,y=og,z=ob,w=oa} },
            -- adj = {n = "u_rgbJust",v= {x=(1-adjr),y=(1-adjg),z=(1-adjb)} },
            adj = {n = "u_rgbJust",v= {x=1,y=1,z=1} },
            t = FilterTools.filterType_colorTransform,
        }
        return params
    end

    local ftParams = turnColorTransForm(1,          1,      1,      1,    
                                        204/255,204/255,204/255,    0/255)
    

    for i,v in ipairs(spriteArr) do
        local sp = display.newSprite(v[1]):addto(nd):pos(v[2],v[3]):anchor(0,1) 
        
    end
    self._testNode = nd
    -- FilterTools.setViewFilter(self._testNode,ftParams )

    self.btn_resume:setTap(c_func(self.onResumeBtn, self))

    self:onSliderChange()
end

--复位
function DebugFilterView:onResumeBtn(  )
	local defaultPercent = {100,100,100,100,50,50,50,50}
	for i,v in ipairs(keyArr) do
		self["slider_"..v]:setPercent(defaultPercent[i])
	end
end


function DebugFilterView:onSliderChange( per )
	
	local turnColorTranform = function(mr,mg,mb,ma,orr,og,ob,oa  )
		local adjr = orr < 0 and 0 or orr
		local adjg  = og < 0 and 0 or og
		local adjb = ob < 0 and 0 or ob
		local adja = oa < 0 and 0 or oa

		local params={
			mul = {x=mr,y=mg,z=mb,w=ma} ,
			off = {x=orr,y=og,z=ob,w=oa} ,
			-- adj = {n = "u_rgbJust",v= {x=1-adjr,y=1-adjg,z=1-adjb} },
			-- adj = {n = "u_rgbJust",v= {x=1,y=1,z=1} },
			t = FilterTools.filterType_colorTransform,
		}
		return params

	end
	local savePercent = {}

	local params = {}
	
	for i,v in ipairs(keyArr) do
		local per = self["slider_"..v]:getPercent()
		table.insert(savePercent,per )
		per = per*2 -100
		table.insert(params, per/100 )
	end

	-- for i=1,3 do
	-- 	local offset = params[i+4]
	-- 	if params[i] > 0 and offset > 0  then
	-- 		-- params[i] = params[i] * math.pow( (1-offset) ,1 )
	-- 	end
	-- end

	-- dump(params,"___percen2222t")

	LS:pub():set("debug_filter",json.encode(savePercent))


	-- local ftParams = turnColorTranform(unpack(params))
	-- FilterTools.setViewFilter(self._testNode,ftParams )
	FilterTools.setColorTransForm(self._testNode, unpack(params) )
	--local glState_colorTrans = cc.GLProgramState:getOrCreateWithGLProgramName("ShaderColorTransform_flash")
	-- glState_colorTrans:setUniformVec4(ftParams.mul.n,ftParams.mul.v)	
	-- glState_colorTrans:setUniformVec4(ftParams.off.n,ftParams.off.v)
	-- glState_colorTrans:setUniformVec3(ftParams.adj.n,ftParams.adj.v)
	
end

return DebugFilterView