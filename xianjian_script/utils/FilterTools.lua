
--
-- Author: xd
-- Date: 2014-01-17 18:33:13
--

FilterTools= FilterTools and FilterTools or  {}

--目前有这2种滤镜效果  越大 表示 滤镜优先级越高 目前  colorMatrix优先级高,主要用来置灰,如果置灰的时候 是不实现闪光的
FilterTools.filterType_colorTransform  = 1
FilterTools.filterType_colorMatrix  = 10

local colorFlag = {"r","g","b","a"}

local function changeNumBetweenMaxMin(num, min, max)
	if num > max then 
		return max;
	end 

	if num < min then
		return min;
	end 

	return num;
end

--2个colorMatirx 混合作用
function FilterTools.mulColorMatirx( params1,params2 )
	local params={
		mul = { },
		off = { },
		t = FilterTools.filterType_colorMatrix,
	}
	local m1 = params1.mul
	local off1 = params1.off
	local m2 = params2.mul
	local off2 = params2.off

	local off = { 	x=off1.x + off2.x,
					y=off1.y + off2.y,
					z=off1.z + off2.z,
					w=off1.w + off2.w,
	}
	--[[
		--数组对应的矩阵顺序
		1   5   9   13
		2   6   10  14
		3   7   11  15
		4   8   12  16
	]]
	local m = {}
	m[1]  = m1[1] * m2[1]  + m1[5] * m2[2] + m1[9]   * m2[3]  + m1[13] * m2[4];
    m[2]  = m1[2] * m2[1]  + m1[6] * m2[2] + m1[10]  * m2[3]  + m1[14] * m2[4];
    m[3]  = m1[3] * m2[1]  + m1[7] * m2[2] + m1[11]  * m2[3]  + m1[15] * m2[4];
    m[4]  = m1[4] * m2[1]  + m1[8] * m2[2] + m1[12]  * m2[3]  + m1[16] * m2[4];
    
    m[5]  = m1[1] * m2[5]  + m1[5] * m2[6] + m1[9]   * m2[7]  + m1[13] * m2[8];
    m[6]  = m1[2] * m2[5]  + m1[6] * m2[6] + m1[10]  * m2[7]  + m1[14] * m2[8];
    m[7]  = m1[3] * m2[5]  + m1[7] * m2[6] + m1[11]  * m2[7]  + m1[15] * m2[8];
    m[8]  = m1[4] * m2[5]  + m1[8] * m2[6] + m1[12]  * m2[7]  + m1[16] * m2[8];
    
    m[9]  = m1[1] * m2[9]  + m1[5] * m2[10] + m1[9]   * m2[11] + m1[13] * m2[12];
    m[10] = m1[2] * m2[9]  + m1[6] * m2[10] + m1[10]  * m2[11] + m1[14] * m2[12];
    m[11] = m1[3] * m2[9]  + m1[7] * m2[10] + m1[11]  * m2[11] + m1[15] * m2[12];
    m[12] = m1[4] * m2[9]  + m1[8] * m2[10] + m1[12]  * m2[11] + m1[16] * m2[12];
    
    m[13] = m1[1] * m2[13] + m1[5] * m2[14] + m1[9]  * m2[15] + m1[13] * m2[16];
    m[14] = m1[2] * m2[13] + m1[6] * m2[14] + m1[10] * m2[15] + m1[14] * m2[16];
    m[15] = m1[3] * m2[13] + m1[7] * m2[14] + m1[11] * m2[15] + m1[15] * m2[16];
    m[16] = m1[4] * m2[13] + m1[8] * m2[14] + m1[12] * m2[15] + m1[16] * m2[16];
    params.mul = m
    params.off = off
    return params
end


--转化数组为colorMatrixFilter
--[[
	off 不是 是 -1 到 1 matrix 中计算出的值 / 255

	mul 不是0到1…… matrix 中计算出是啥就是啥
]]
function FilterTools.turnMatrixArr(matrixArr )
	local params={
		mul = { },
		off = { },
		t = FilterTools.filterType_colorMatrix,
	}

	-- params.off.x = changeNumBetweenMaxMin( matrixArr[5] / 255, -1, 1 );
	-- params.off.y = changeNumBetweenMaxMin( matrixArr[10] / 255, -1, 1 );
	-- params.off.z = changeNumBetweenMaxMin( matrixArr[15] / 255, -1, 1 ); 
	-- params.off.w = changeNumBetweenMaxMin( matrixArr[20] / 255, -1, 1 ); 

	params.off.x =  matrixArr[5]  / 255
	params.off.y =  matrixArr[10] / 255
	params.off.z =  matrixArr[15] / 255
	params.off.w =  matrixArr[20] / 255

	for i=1,4 do
		
		for j=1,4 do
			params.mul[(j-1)*4 + i] =  
			  -- changeNumBetweenMaxMin( matrixArr[(i-1) * 5 + j] , 0, 1 );
			  matrixArr[(i-1) * 5 + j]
		end
	end

	--[[
		0   4   8   12
		1   5   9   13
		2   6   10  14
		3   7   11  15
	]]

	-- dump(params,"__marix")
	
	return params
end

function FilterTools.turnColorTranform(mr,mg,mb,ma,orr,og,ob,oa  )
	if oa ~= 0	 then
		echoError("__这个色调的oa偏移不为0")
		oa =0
	end
	local params={
		mul = {x=mr,y=mg,z=mb,w=ma },
		off = {x=orr,y=og,z=ob,w=oa },
		t = FilterTools.filterType_colorTransform,
	}
	return params

end


--目前定义多种4种闪光效果
local flashType = {
	colorFlash = 1, 		--颜色闪烁,比如 打击效果闪红光
	colorTween = 4, 		--渐变改变颜色 tweenColorTo
	alphaFlash = 2, 		--透明度闪烁
	alphaTween = 3, 		--透明度渐变
}


--目前定义的颜色 有  red,btnlight,oldFt,old(表示销毁shader)
--红光效果
-- FilterTools.colorTransform_red =  FilterTools.turnColorTranform(1,1,1,1,150/255,0,0,0)  --( {u_r = {1,100/255},u_g = {1,0 },u_b = {1,0}, u_a = {1,0	},	shaderName="colorTransform_red" ,frag = "Shaders/example_rgba.fsh"	} )
FilterTools.colorTransform_red =  FilterTools.turnColorTranform(1,0.3,0.3,1,0,0,0,0)  --( {u_r = {1,100/255},u_g = {1,0 },u_b = {1,0}, u_a = {1,0	},	shaderName="colorTransform_red" ,frag = "Shaders/example_rgba.fsh"	} )

--按钮按下的发光颜色
FilterTools.colorTransform_btnlight = FilterTools.turnColorTranform(1,1,1,1,27/255,27/255,27/255,0)

--立绘变暗效果
FilterTools.colorTransform_lowLight = FilterTools.turnColorTranform(0.6,0.6,0.6,1,0,0,0,0)

--立绘变暗效果2
FilterTools.colorTransform_lowLight2 = FilterTools.turnColorTranform(0.3,0.3,0.3,1,0,0,0,0)

--立绘变暗效果5
FilterTools.colorTransform_lowLight5 = FilterTools.turnColorTranform(0.1,0.1,0.1,1,0,0,0,0)

--立绘变黑效果
FilterTools.colorTransform_lowLight3 = FilterTools.turnColorTranform(0.0,0.0,0.0,1,0,0,0,0)

--PVE关卡变暗效果
FilterTools.colorTransform_pveRaidLight = FilterTools.turnColorTranform(0.4,0.4,0.4,1,0,0,0,0)

--六界地标高亮效果
FilterTools.colorTransform_spaceHighLight = FilterTools.turnColorTranform(0.9,0.9,0.9,1,0.4,0.4,0.4,0)

--六界通用点击高亮效果
FilterTools.colorTransform_worldHighLight = FilterTools.turnColorTranform(0.9,0.9,0.9,1,0.4,0.4,0.4,0)

--天赋节点变暗效果
FilterTools.colorTransform_talentPointLight = FilterTools.turnColorTranform(0.6,0.6,0.6,1,0,0,0,0)

--原色 但是带滤镜
FilterTools.colorTransform_oldFt =  FilterTools.turnColorTranform(1,1,1,1,0,0,0,0)

--原色
FilterTools.colorTransform_old = nil  --json.encode( {u_r = {1,0},u_g = {1,0 },u_b = {1,0}, u_a = {1,0	},	shaderName="colorTransform_old" ,frag = "Shaders/example_rgba.fsh"	} )


--灰色滤镜
FilterTools.colorMatrix_gray =  FilterTools.turnMatrixArr({ 0.3086,0.6094,0.0820,0,0,
													 0.3086,0.6094,0.0820,0,0,
													 0.3086,0.6094,0.0820,0,0,
													 0,		0,	   0,     1,0})

--灰色滤镜 针对伙伴升品置灰效果2
FilterTools.colorMatrix_gray2 =  FilterTools.turnMatrixArr({ 0.4202,0.3204,0.1594,0,33.35,0.2161,0.6627,0.0212,0,33.35,0.11,0.4836,0.3064,0,33.35,0,0,0,1,0})

--单位矩阵 初始matrix矩阵
FilterTools.colorMatrix_old = FilterTools.turnMatrixArr({ 1,0,0,0,0,
													 	  0,1,0,0,0,
														  0,0,1,0,0,
														  0,0,0,1,0})


--初始化几种特殊效果
--冰矩阵
FilterTools.colorMatrix_ice = FilterTools.turnMatrixArr( 
	ColorMatrixFilterPlugin:genColorTransForm( {
												colorize = "#78eefe",
												brightness = 2.5,
											}) 
														)

--傀儡矩阵
FilterTools.colorMatrix_kuilei = FilterTools.turnMatrixArr( 
	ColorMatrixFilterPlugin:genColorTransForm( {
												colorize = "#cc66ff",
												amount = 1,
												brightness = 2,
											}) 
														)

--火矩阵
FilterTools.colorMatrix_fire = FilterTools.turnMatrixArr( {	
		1,0,0,0,0,
		0,0.6,0,0,0,
		0,0,0.6,0,0,
		0,0,0,1,0
	}	 )

-- 火神场景，蓝色效果
FilterTools.colorMatrix_huoshen_changjing_blue = FilterTools.turnMatrixArr({
	-0.6085,3.9574,-1.0489,
	0,-54.95,0.6636,0.9324,
	0.7039,0,-54.95,2.0098,1.8876,
	-1.5974,0,-54.95,0,
	0,0,1,0
})

-- 火神场景，地裂蓝色效果
FilterTools.colorMatrix_huoshen_dilie_blue = FilterTools.turnMatrixArr({
	-0.4921,1.5907,-0.0986,0,
	0,0.3817,0.4035,0.2148,
	0,0,0.6224,1.2206,
	-0.843,0,0,0,
	0,0,1,0
})

-- 波纹特效缓存key
FilterTools.wave_effect_cache_key = "wave_effect_cache_key"

-- 安卓机需要reset的列表
FilterTools._GLProgramsNeedsReload = {
	[FilterTools.wave_effect_cache_key] = {"Shaders/normal_vert.vsh","Shaders/waveEffect.fsh"},
}
--初始化 传入一个

--设置图片颜色
function FilterTools.setFlashColor(view, colorName,priority )
	colorName = colorName or "old"
	colorName = "colorTransform_" .. colorName
	
	local ftParams =  FilterTools[colorName] 
	FilterTools.setViewFilter(view,ftParams,priority )

end



--转化颜色为 gray颜色
function FilterTools.turnGrayColor( c4b )
	local grayParams = FilterTools.colorMatrix_gray
	local matMul = FilterTools.colorMatrix_gray.mul
	local vecoff = FilterTools.colorMatrix_gray.off
	local turnColor = {r =c4b.r/255,g = c4b.g/255, b= c4b.b/255,a = c4b.a or 1 }
    local turnR =   turnColor.r  * matMul[1] + 
                    turnColor.g * matMul[5] + 
                    turnColor.b * matMul[9] + 
                    turnColor.a * matMul[13] +  
                    vecoff.x

    local turnG =   turnColor.r  * matMul[2] + 
                    turnColor.g * matMul[6] + 
                    turnColor.b * matMul[10] + 
                    turnColor.a * matMul[14] +  
                    vecoff.y

    local turnB =   turnColor.r  * matMul[3] + 
                    turnColor.g * matMul[7] + 
                    turnColor.b * matMul[11] + 
                    turnColor.a * matMul[15] +  
                    vecoff.z

    return cc.c4b(turnR*255,turnG *255,turnB * 255,255)
end

--转化 颜色 ,根据ftParams 
function FilterTools.turnFilterColor(c4b, ftParams )
	-- 如果没有滤镜效果 说明是还原
	if not ftParams then
		return c4b
	end
	c4b.a = c4b.a or 255
	local newColor = {}
	--如果是 colorTransform
	local mulVec
	local mulMat
	local offVec
	if ftParams.t ==FilterTools.filterType_colorTransform then
		mulVec = ftParams.mul
		offVec = ftParams.off
		newColor.r = c4b.r * mulVec.x + offVec.x * 255
		newColor.g = c4b.g * mulVec.y + offVec.y * 255
		newColor.b = c4b.b * mulVec.z + offVec.z * 255
		newColor.a = c4b.a * mulVec.w + offVec.w * 255

	--如果是colorMatrix
	elseif ftParams.t ==FilterTools.filterType_colorMatrix then
		mulMat = ftParams.mul
		offVec = ftParams.off
		newColor.r = c4b.r * mulMat[1] + c4b.g * mulMat[5] + c4b.b * mulMat[9] + c4b.a *mulMat[13] + offVec.x* 255
		newColor.g = c4b.r * mulMat[2] + c4b.g * mulMat[6] + c4b.b * mulMat[10] + c4b.a *mulMat[14] + offVec.y* 255
		newColor.b = c4b.r * mulMat[3] + c4b.g * mulMat[7] + c4b.b * mulMat[11] + c4b.a *mulMat[15] + offVec.z* 255
		newColor.a = c4b.r * mulMat[4] + c4b.g * mulMat[8] + c4b.b * mulMat[12] + c4b.a *mulMat[16] + offVec.w* 255
	end
	newColor.r = newColor.r >255 and 255 or newColor.r 
	newColor.g = newColor.g >255 and 255 or newColor.g 
	newColor.b = newColor.b >255 and 255 or newColor.b
	newColor.a = newColor.a >255 and 255 or newColor.a
	return newColor

end



--设置colorTransform  所有数值取值范围 rm  是0到1,   rf  是 -1到1
function FilterTools.setColorTransForm(view,rm,gm,bm,am, rf,gf,bf,af,priority )
	rm = rm or 1 
	gm = gm or 1
	bm = bm or 1
	am = am or 1
	rf = rf or 0 
	gf = gf or 0 
	bf = bf or 0
	af = af or 0
	priority = priority or 0
	--判断是否是原色
	if rm ==1 and gm == 1 and bm  ==1 and am ==1 and rf ==0 and gf ==0 and bf ==0 and af ==0 then
		FilterTools.clearFilter(view, priority)
	else
		local ftParams = FilterTools.turnColorTranform(rm,gm,bm,am, rf,gf,bf,af)
		-- dump(ftParams,"____ftParams")
		FilterTools.setViewFilter( view, ftParams, priority )
	end
	
end



--设置 matrix 设置颜色矩阵,  传入的数值数组 完全和flash面板保持一直
function FilterTools.setColorMatrix( view,matrixArr,priority )

	local params= FilterTools.turnMatrixArr(matrixArr)
	priority = priority or 0
	FilterTools.setViewFilter( view, params,priority )

end

--设置图片置灰 priority 优先级 默认是1 越大表示越不容易被覆盖
function FilterTools.setGrayFilter( view ,priority )
	priority = priority or 0 
	FilterTools.setViewFilter( view, FilterTools.colorMatrix_gray,priority )
end




--直接设置滤镜效果
function FilterTools.setViewFilter( view,ftParams ,priority)

	FilterTools._setViewFilter(view,ftParams ,priority )

	--cc.ExpandFuncs:setNodeShader(view,ft)
end


function FilterTools._setViewGLState( view,ftParams )
	if not ftParams then
		pc.PCUtils:resumeNodeShader(view)
	elseif ftParams.t ==FilterTools.filterType_colorMatrix then
		pc.PCUtils:setNodeColorMatrix(view,ftParams.mul,ftParams.off)
	--如果是colortransform
	elseif ftParams.t ==FilterTools.filterType_colorTransform then
		pc.PCUtils:setNodeColorTransform(view,ftParams.mul,ftParams.off)
	else
		dump(ftParams)
		echoError("错误的glstate")
		return
	end

end

--
function FilterTools._setViewFilter(view,ftParams,priority )
	if not view then
		return
	end

	priority = priority or 0

	--如果view已经有优先级了 那么需要优先级比较
	if view.__filterPriority and view.__filterPriority > priority then
		return
	end

	if ftParams then
		view.__filterType = ftParams.t
		view.__filterPriority = priority
	else
		--如果是消除
		view.__filterType = nil
		view.__filterPriority = -999
	end

	if view.__cname =="TTFLabelExpand" then
		-- if ftParams and ftParams.t == FilterTools.filterType_colorMatrix then
		-- 	view:resumeOrGray(false)
		-- else
		-- 	view:resumeOrGray(true)
		-- end
		view:setLabelFtParams( ftParams )
		return
	end

	local luaType =  tolua.type(view)
	
	if  luaType == "pc.Skin"  or luaType == "pc.PCSkeletonAnimation"  or luaType == "cc.Sprite" or luaType == "cc.Scale9Sprite" or luaType == "ccui.Scale9Sprite"  then
		FilterTools._setViewGLState( view,ftParams )
	end
	
	local childArr = view:getChildren()

	if #childArr== 0 then
	 	return
	end
	
	for i,v in ipairs(childArr) do
		--如果是骨骼动画
		if tolua.type(v) == "pc.Bone"  then

			--如果是遮罩 那么不设置滤镜
			if not v:isMaskBone() then
				local targetName = v:getName()

				local arr = v:getDisplayManager():getDecorativeDisplayList()
	            for i=1,#arr do
	                local childBoneDisplay =   arr[i]:getDisplay()
	                FilterTools._setViewFilter(childBoneDisplay,ftParams,priority )
	            end
			end

			-- if not string.find(targetName,"blend_") then
			-- 	FilterTools._setViewFilter(v:getDisplayRenderNode(),ftParams )
			-- end
		else
			FilterTools._setViewFilter(v,ftParams,priority )
		end
	end

end


--清除viewFilter clearFilter  
function FilterTools.clearFilter( view ,priority )
	if not view then
		return
	end
	priority= priority or 9999
	local luaType =  tolua.type(view)

	if not view.__filterType then
		return
	end
	FilterTools.clearViewFlash( view )
	FilterTools.setViewFilter( view ,nil,priority)
	
end


-- 闪光函数管理--------	
FilterTools.flashInfoArr = {}

--让某个对象从一种颜色缓动到另外一种颜色
--tweenFrame 缓动的总帧数 -1表示 永久缓动 
-- fromColor  取 FilterTools.colorTransform_red 定义的字符串 最后一个数字 
--red 表示FilterTools.colorTransform_red
--loopCount 循环次数 默认是1 就是播放1次 否则会默认循环 知道tweenFrame结束 
--perLoopFrame  一次循环的帧数 如果不填 表示不循环,如果填写 表示按照这个间隔循环
--isResume 结束后时候清空colortransform sader,
function FilterTools.flash_easeBetween(view,tweenFrame,perLoopFrame,fromColor,toColor,isResume, callFunc )
	--清除闪光数组
	tweenFrame = tweenFrame == -1 and 9999999999 or tweenFrame
	FilterTools.clearViewFlash( view )

	local fromParams
	local toParams
	if type(fromColor) == "string" then
		fromParams = FilterTools["colorTransform_"..fromColor]
		toParams = FilterTools["colorTransform_"..toColor]
	else
		fromParams = fromColor
		toParams = toColor
	end
	if not fromParams then
		echpWarn("fromColor错误 ",fromColor)
	end

	local info = {
		view = view,
		type = flashType.colorTween,
		time = tweenFrame,
		--如果是-1的 表示 是永久循环的 那么给他设置一个很大的时间
		initTime = tweenFrame,
		perLoopFrame = perLoopFrame or tweenFrame,
		fromParams = fromParams,
		toParams = toParams,
		callFunc = callFunc,
	}
	if isResume then
		--还原的时候只清除  colorTransform 而不清除置灰
		info.resumeFunc = c_func(FilterTools.clearFilter,view,-10)
	end
	FilterTools.filterToView(info)
	table.insert(FilterTools.flashInfoArr,1,info)
end


--让某个对象闪光 主要针对图片 设置其colorTransform
function FilterTools.flash_colorTransform(view,flashTime, interval, color ,callFunc,callParams )
	
	color = color or "red"
	if not FilterTools["colorTransform_"..color] then
		echo(debug.traceback("没有找到这个颜色的colorTransform:"..tostring(color)))
		color = "red"
	end
	FilterTools.clearViewFlash( view )
	local info = {
		view = view,
		--类型 1 表示 普通闪烁 ,以后还会扩展 各种缓动渐变  
		type = flashType.colorFlash,
		time = flashTime or 5, 	--闪光时间  
		interval = interval or 4, 	--闪光间隔
		color = color,
		callFunc = callFunc,
		callParams = callParams,
		resumeFunc = c_func(FilterTools.clearFilter,view,-10)
	}

	--目标颜色时间 
	info.targetTime = 1
	--原色颜色时间
	info.resumeTime = info.interval +1

	--每次创建闪光的时候 都是往前面放
	table.insert(FilterTools.flashInfoArr,1,info)

end


--透明度在2个值之间闪烁   										toAlpha , 0-1,默认0
function FilterTools.flash_alpha_wave(view,flashTime, interval,  toAlpha,callFunc,callParams  )

	--还原函数
	local opacity =view:getOpacity()

	FilterTools.clearViewFlash( view )

	local info = {
		view = view,
		--类型 2  透明度在2个值之间闪烁
		type = flashType.alphaFlash,
		time = flashTime or 10, 	--闪光时间  
		interval = interval or 2, 	--闪光间隔
		fromAlpha = opacity,
		toAlpha = toAlpha * 255 or 0,
		callFunc = callFunc,
		callParams = callParams,
		resumeFunc = c_func(view.opacity,view,opacity)
	}
	--每次创建闪光的时候 都是往前面放
	table.insert(FilterTools.flashInfoArr,1,info)
end


--透明度渐变闪烁 , 逐渐下降闪烁
function FilterTools.flash_alpha_degress(view,flashTime, interval, zhenfu, callFunc,callParams  )

	--还原函数
	local opacity =view:getOpacity()
	FilterTools.clearViewFlash( view )
	
	local info = {
		view = view,
		--类型 3 表示 逐渐下降闪烁 
		type = flashType.alphaTween,
		time = flashTime or 10, 	--闪光时间  
		lastTime =  flashTime or 40, --持续时间 默认40帧
		interval = interval or 1, 	--闪光间隔
		zhenfu = zhenfu*255 or 25,
		alpha = opacity ,			--当前的透明度
		
		callFunc = callFunc,
		callParams = callParams,
		resumeFunc = c_func(view.opacity,view,opacity)
	}
	-- echo(opacity,"----targewtOpacity,zhenfu:",info.zhenfu)
	--每次创建闪光的时候 都是往前面放
	table.insert(FilterTools.flashInfoArr,1,info)
end





--刷新函数
function FilterTools.updateFrame(  )
	--倒着刷新
	local info
	for i=#FilterTools.flashInfoArr,1,-1 do
		info = FilterTools.flashInfoArr[i]

		--如果view已经被回收了  那么删除
		if tolua.isnull(info.view) then
			table.remove(FilterTools.flashInfoArr, i)
		else
			FilterTools.filterToView( info )

			-- 如果闪光时间到了 那么删除
			if info.time  <=0 then
				--结束之后 做还原函数
				if info.resumeFunc then
					info.resumeFunc()
				end
				table.remove(FilterTools.flashInfoArr, i)
				if info.callFunc then
					if info.callParams then
						info.callFunc(unpack(info.callParams))
					else
						info.callFunc()
					end
				end

				
			else
				info.time = info.time -1
			end

		end
		
	end
end


-- 给view附上 filter
function FilterTools.filterToView( info )
	local view = info.view
	if info.type ==flashType.colorFlash then
		if info.time % (info.interval *2) == info.targetTime then
			FilterTools.setFlashColor(view,info.color,-10)
		elseif info.time % (info.interval *2) == info.resumeTime then
			FilterTools.clearFilter(view,-10)
		end


	elseif info.type ==flashType.alphaFlash then
		--透明度 2个值之间闪烁
		if info.time  % (info.interval *2) <= info.interval -1 then
			view:opacity(info.fromAlpha)
		else
			view:opacity(info.toAlpha)
		end
	elseif info.type ==flashType.alphaTween then
		--透明度逐渐下降闪烁
		if info.time  % (info.interval *2) <= info.interval -1 then

			view:opacity(info.time/info.lastTime * info.alpha + info.zhenfu)
		else
			view:opacity(info.time/info.lastTime* info.alpha - info.zhenfu)
		end
	elseif info.type ==flashType.colorTween then

		--[[

		local info = {
			view = view,
			type = flashType.colorTween,
			time = tweenFrame,
			--如果是-1的 表示 是永久循环的 那么给他设置一个很大的时间
			initTime = tweenFrame,
			perLoopFrame = perLoopFrame or tweenFrame
			fromParams = FilterTools["colorTransform_"..fromColor],
			toParams = FilterTools["colorTransform_"..toColor],
			callFunc = callFunc,
		}
		]]

		--tcolortrans 渐变
		local costFrame = info.initTime-info.time
		local perLoopFrame = info.perLoopFrame
		--判断奇偶 来决定 来回 颜色
		local loopTime = math.floor(costFrame/ perLoopFrame)
		local leftFrame = costFrame % perLoopFrame


		local percent
		--如果是2的倍数 那么是正向渐变
		if loopTime % 2==0 then
			percent =leftFrame /  perLoopFrame
		else
			percent =1- leftFrame /  perLoopFrame
		end

		local fromParams = info.fromParams
		local toParams = info.toParams

		local targetParams 
		--判断类型
		if fromParams.t == FilterTools.filterType_colorTransform then
			targetParams= {
				mul = Equation.countVec4percent( fromParams.mul,toParams.mul,percent ),
				off = Equation.countVec4percent( fromParams.off,toParams.off,percent ),
				t = fromParams.t
			}
		elseif fromParams.t == FilterTools.filterType_colorMatrix   then
			targetParams= {
				mul = Equation.countMatrixPercent( fromParams.mul,toParams.mul,percent ),
				off = Equation.countVec4percent( fromParams.off,toParams.off,percent ),
				t = fromParams.t
			}
		end

		

		-- echo(percent,loopTime,"_____aaa")
		FilterTools.setViewFilter(view,targetParams,-10)

	end

end
--[[
	nodeParams = {
		node = node, -- 要施加效果的node(含子节点)
		-- 下几个参数同 PCNode2Sprite::spriteCreate
		w = number,
		h = number,
		offX = number,
		offY = number,
	}
	posParams = {
		type = number, 1 pos为相对位置，坐标; 2 pos为(0-1)间的uv坐标
		pos = cc.p,
	}

	return tSp 应用了水波特效的sprite，遮挡或替换原节点
]]
function FilterTools.setWaterWave( nodeParams, posParams )
	-- 画出应用节点
	local tSp = pc.PCNode2Sprite:getInstance():spriteCreate(
		nodeParams.node,
		nodeParams.w,
		nodeParams.h,
		nodeParams.offX,
		nodeParams.offY
	)

	local glpCache = cc.GLProgramCache:getInstance()
	local glprogram = glpCache:getGLProgram(FilterTools.wave_effect_cache_key)
	-- 如果没有加入缓存
	if not glprogram then
		local vsh,fsh = unpack(FilterTools._GLProgramsNeedsReload[FilterTools.wave_effect_cache_key])
		glprogram = cc.GLProgram:createWithFilenames(vsh, fsh)
		glpCache:addGLProgram(glprogram, FilterTools.wave_effect_cache_key)
	end

	local uv = nil
	if posParams.type == 1 then
		local tSize = tSp:getContentSize()
		uv = cc.p(posParams.pos.x/tSize.width,posParams.pos.y/tSize.height)
	else
		uv = posParams.pos
	end
	-- 转换一下
	uv.y = 1 - uv.y

	local glstate = cc.GLProgramState:getOrCreateWithGLProgram(glprogram)
	glstate:setUniformVec2("u_center", uv)

	tSp:setGLProgramState(glstate)

	return tSp
end
-- 截屏方法
function FilterTools.jieping( nodeParams )
	local tSp = pc.PCNode2Sprite:getInstance():spriteCreate(
		nodeParams.node,
		nodeParams.w,
		nodeParams.h,
		nodeParams.offX,
		nodeParams.offY
	)
	return tSp
end

--清除一个view对应的flash
function FilterTools.clearViewFlash( view )
	for i=#FilterTools.flashInfoArr ,1,-1 do
		local info = FilterTools.flashInfoArr[i]
		if info.view == view then
			table.remove(FilterTools.flashInfoArr,i)
		end
	end
end

--清除所有的 效果
function FilterTools.clear(  )
	FilterTools.flashInfoArr = {}
end
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
scheduler.scheduleUpdateGlobal(FilterTools.updateFrame)