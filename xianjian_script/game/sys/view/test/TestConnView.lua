local TestConnView = class("TestConnView", UIBase);

--[[
    self.btn_back,
    self.panel_md.rect_1,
    self.panel_md.txt_sys,
    self.panel_mt.mc_ts,
    self.panel_mt.rect_1,
    self.panel_mt.rect_2,
    self.panel_mt.rect_bg,
    self.panel_mt.txt_ms,
    self.rect_bg,
    self.rect_md,
    self.rect_mt,
    self.scroll_md,
    self.scroll_mt,
]]

local descripStr = ' \
                说明  \
数组的配置方式:            \
标准的json格式           \
[1,2,3 ]纯数组格式        \
{\"a\":1,\"b\":2,\"c\":3,\"d\":\"ee\"}    key value表结构     \
'
  


--接口数据 这个是 测试接口数据
local interFaceDatas = nil
--这个是系统命令
local interFaceSysDatas = nil 


--缓存输入的数据
local cacheInputDatas = {}

TestConnView.interFaceDatas = nil


--获取当前的调试模式
function TestConnView:getCacheDebugMode(  )
    if not cacheInputDatas["debugModel"] then
        return 2
    end
    return cacheInputDatas["debugModel"]
end

--设置调试模式
function TestConnView:setCacheDebugMode( t )
    cacheInputDatas["debugModel"] = t
    LS:pub():set(StorageCode.debugInputData, json.encode( cacheInputDatas) )
end


--获取缓存的输入数据  op 和index
function TestConnView:getCacheInputDatas(op,index  )
    if not cacheInputDatas[tostring(op) ]  then
        return ""
    end
    return cacheInputDatas[tostring(op)][index] or ""
end


--获取缓存的数据
function TestConnView:getCacheData( key,defValue )
    if not cacheInputDatas[key] then
        cacheInputDatas[key] = defValue
    end
    return cacheInputDatas[key] 

end

--获取缓存的methodIndex
function TestConnView:getCacheMethodIndex( model )
    
    return cacheInputDatas["modelIndex_"..model]

end

--设置modelIndex
function TestConnView:setCacheMethodIndex(model,index  )
    cacheInputDatas["modelIndex_"..model]  = index
end


--缓存每个操作使用次数
function TestConnView:setCacheHandleTime(model,index )
    model = tostring(model) 
    index = tostring(index)
    if not cacheInputDatas["handlTime"] then
        cacheInputDatas["handlTime"] = {}
    end

    local obj = cacheInputDatas["handlTime"]
    if not obj[model] then
        obj[model] = {}
    end
    if not obj[model][index] then
        obj[model][index] = 0
    end
    obj[model][index] = obj[model][index] +1

end

--获取每个操作使用次数
function TestConnView:getCacheHandleTime( model,index )
    model = tostring(model)
    index = tostring(index)
    if not cacheInputDatas["handlTime"] then
        cacheInputDatas["handlTime"] = {}
    end

    local obj = cacheInputDatas["handlTime"]
    if not obj[model] then
        obj[model] = {}
    end
    if not obj[model][index] then
        obj[model][index] = 0
    end
    return obj[model][index]
end




function TestConnView:ctor(winName)
    TestConnView.super.ctor(self, winName);

    local cacheStr = LS:pub():get(StorageCode.debugInputData) 
    if cacheStr then
         cacheInputDatas = json.decode( cacheStr )
         cacheInputDatas = cacheInputDatas or {}
    else
        cacheInputDatas = {}
    end 



end

--请求系统返回
function TestConnView:requestSysBack( result )
    interFaceSysDatas = result.result.data.oplist



    self:showDebugMode(self:getCacheDebugMode())

    local gmBtnFunc = function (  )
        if self:getCacheDebugMode() ==1 then
            self:showDebugMode(2)
        else
            self:showDebugMode(1)
        end
        echo("showDebugMode",self:getCacheDebugMode())
    end

    self.mc_gm:showFrame(self:getCacheDebugMode())

    self.mc_gm:setTouchedFunc(gmBtnFunc)


    local clickFunc = function (view  )
        if view:visible() == true then
            view:visible(false)
        else
            view:visible(true)
        end
    end

    self.panel_bz.txt_1:setString(descripStr)

    local closeBangzhu = function (  )
        self.panel_bz:visible(false)
    end

    self.panel_bz.btn_back:setTap(closeBangzhu)

    

    


    local showBangzhu = function (  )
        self.panel_bz:visible(true)
    end

    --显示帮助
    self.btn_bz:setTap(showBangzhu)

    


    self.panel_md:setTouchedFunc(c_func(clickFunc, self.panel_gmd))
    self.panel_mt:setTouchedFunc(c_func(clickFunc, self.panel_gmt))


    

end

function TestConnView:requestBack( result )
    --如果没有返回结果的
    if not result.result then
        return
    end
    interFaceDatas = result.result.data.oplist

    Server:sendRequest({}, MethodCode.test_getJsonDesc2_100103, c_func(self.requestSysBack, self))


end


function TestConnView:loadUIComplete()
	self:registerEvent();


    Server:sendRequest({}, MethodCode.test_getJsonDesc_100105, c_func(self.requestBack, self))

    -- self.panel_md:visible(false)
    -- self.panel_mt:visible(false)

    --隐藏详细列表条
    self.panel_xx.panel_ms:visible(false)
    

    --隐藏2个list
    self:pressClickBlank()

    --隐藏帮助
    self.panel_bz:visible(false)
    self.panel_bz:setTouchEnabled(true)
    self.panel_bz:setTouchSwallowEnabled(true)

    self.panel_grxx:visible(false)
    self.panel_grxx:setTouchEnabled(true)
    self.panel_grxx:setTouchSwallowEnabled(true)

    --显示详细界面
    self:showXiangxiView()


    --显示详细
    local showXiangxi = function (  )
        echo("显示ixiangxi---")
        self.panel_grxx:visible(true)
    end

    local closeXiangxiView = function (  )
        self.panel_grxx:visible(false)
    end
    self.txt_info:setTouchedFunc(showXiangxi)
    --关闭详细界面
    self.panel_grxx.btn_back:setTap(closeXiangxiView)

end 

--显示哪一种命令模式
function TestConnView:showDebugMode( t )
    --如果是测试命令
    self.debugType = t
    if t ==1 then
        self.interFaceDatas = interFaceSysDatas
    else
        self.interFaceDatas = interFaceDatas
    end
    self.mc_gm:showFrame(t)
    self:setCacheDebugMode(t)


    --创建模块函数
    local createModelFunc = function ( modelData,cellIndex )
        local view = UIBaseDef:cloneOneView(self.panel_md)
        local titleStr = "[" ..modelData.label .."]"

        if modelData.desc then
            -- print( modelData.desc,"__ modelData.desc")
            view.txt_sys:setString(titleStr..modelData.desc)
            
        else
            view.txt_sys:setString(titleStr .."(没有描述)")
        end
        view._itemData = modelData
        view:setTouchedFunc(c_func(self.showModel, self, modelData,cellIndex) )
        return view
    end

    local modelData = {}
    local testData = nil
    for k,v in pairs(self.interFaceDatas) do
        if v.label =="Test" then
            testData = v
        else
            table.insert(modelData, v)
        end
        
    end

    table.sortAsc(modelData,"label")

    if testData then
        table.insert(modelData, 1,testData)
    end
    

    local modelIndex = self:getCacheData("defaultModelIndex", 1)
    --显示第一个数据
    self:showModel(modelData[modelIndex] or modelData[1],modelIndex)
    --创建userModel
    local params = {
        {
            data = modelData,
            createFunc = createModelFunc,
            itemRect = self.panel_md:getContainerBox(), --{x=0,y=-46,width = 142,height = 46},
            perNums= 1,
            offsetX =2,
            offsetY = 2,
            widthGap =10,
            heightGap =5,
            perFrame = 5
        },
    }

    self.panel_gmd.scroll_md:styleFill(params)


end



--显示哪一个模块
function TestConnView:showModel( modelData,modelIndex )
    
    --滑动中不执行
    if self.panel_gmd.scroll_md:isMoving() then
        return
    end


    cacheInputDatas.defaultModelIndex = modelIndex or 1
    LS:pub():set(StorageCode.debugInputData, json.encode( cacheInputDatas) )
    --隐藏列表
    self:pressClickBlank()

    --
    local view = self.panel_md

    local titleStr = "[" ..modelData.label .."]"

    if modelData.desc then
        -- print(modelData.desc,"_bbb_modelData.desc")
        view.txt_sys:setString(titleStr..modelData.desc)
        
    else
        view.txt_sys:setString(titleStr .."(没有描述)")
    end


    self._currentModel = modelData
    self._currentModelIndex = modelIndex

    --更新下 方法列表


    local ops = modelData.ops


   

    --把ops 进行排序
    local sortFunc = function (op1,op2  )
        local time1 = self:getCacheHandleTime(modelIndex,op1.op)
        local time2 = self:getCacheHandleTime(modelIndex,op2.op)
        if time1 > time2 then
            return true
        elseif time1 ==time2 then
            return tonumber(op1.op) <= tonumber(op2.op)
               
        else
            return false

        end
       
    end

    table.sort( ops, sortFunc )

    local createFunc = function ( itemData,cellIndex )
        local view = UIBaseDef:cloneOneView(self.panel_mt)
        local paramLength = #itemData.params

        --更新view描述
        local str = "[" .. itemData.op .."]"  ..  itemData.action.."\n" ..(itemData.desc or "没有描述" )
        view.txt_sys:setString(str)
        view:setTouchedFunc(c_func(self.chooseMethod,self,itemData) )
        return view
    end


    --选择某个方法

    local methodId= self:getCacheMethodIndex(cacheInputDatas.defaultModelIndex)

    local targetIndex 
    local firstIndex 
    for k,v in pairs(ops) do
        if v.op ==methodId  then
           targetIndex = k
        end
        if not firstIndex then
            firstIndex = k
        end
    end
    if not targetIndex  then
        targetIndex = firstIndex
    end
    if targetIndex then
        self:chooseMethod(ops[targetIndex]  ,ops[targetIndex].op)
    else

    end
    

    local params = {
        {
            data = ops,
            createFunc = createFunc,
            itemRect = self.panel_mt:getContainerBox(), --{x=0,y=-46,width = 492,height = 46},
            perNums= 1,
            offsetX =10,
            offsetY = 2,
            widthGap =10,
            heightGap =10,
            perFrame = 5

        },
    }

    self.panel_gmt.scroll_mt:styleFill(params)

end


--点击空白地方
function TestConnView:pressClickBlank(  )
    --隐藏2个列表
    self.panel_gmd:visible(false)
    self.panel_gmt:visible(false)
end






--选择一个方法
function TestConnView:chooseMethod( itemData,index )
    

    --滑动中不执行
    if self.panel_gmt.scroll_mt:isMoving() then
        return
    end

    TestConnView:setCacheMethodIndex(cacheInputDatas.defaultModelIndex, itemData.op)
    
    LS:pub():set(StorageCode.debugInputData, json.encode( cacheInputDatas) )
    self:pressClickBlank()
    local view = self.panel_mt
    local paramLength = #itemData.params

    --更新view描述
    local str = "[" .. itemData.op .."]"  ..  itemData.action.."\n" .. (itemData.desc or "没有描述" )
    view.txt_sys:setString(str)

    --显示详细信息
    self:showDetialView(itemData)

end

--显示详细信息
function TestConnView:showDetialView( methodData )
    
    self._currentMethod = methodData
    local data = methodData.params

    local createFunc = function ( paramsData )
        local view = UIBaseDef:cloneOneView(self.panel_xx.panel_ms)
        view.txt_mc:setString(paramsData.name)
        view.txt_lx:setString(paramsData.type)
        view.txt_ms:setString(paramsData.desc)
        view._itemData = paramsData
        view.input_cs.scrollView = self.panel_xx.scroll_xy

        view.input_cs:setText(self:getCacheInputDatas(self._currentMethod.op, table.indexof(data, paramsData  )))

        return view
    end


    local params = {
        {
            data = data,
            createFunc = createFunc,
            itemRect = {x=0,y=-37,width = 849,height = 37},
            perNums= 1,
            offsetX = 0,
            offsetY = 2,
            widthGap =0,
            heightGap =5,
            perFrame = 5

        },
    }

    self.panel_xx.scroll_xy:styleFill(params)


end



--显示错误
function TestConnView:showErrorInfo( str )
    self.panel_xx.txt_cw:setString(str)
end






function TestConnView:registerEvent()
	TestConnView.super.registerEvent();
    self.btn_back:setTap(c_func(self.press_btn_back, self));

    self.btn_tj:setTap(c_func(self.press_btn_tj, self))

end


--提交信息
function TestConnView:press_btn_tj(  )
    --检查参数
    local views = self.panel_xx.scroll_xy:getAllView()

    local errorStr = ""

    local sendParams  ={}

    if not LoginControler:isLogin() then
        self:showErrorInfo("请先登入")
        return
    end
    local methodCode = self._currentMethod.op
    local cacheParams
    if not cacheInputDatas[tostring(methodCode)]  then
        cacheInputDatas[tostring(methodCode)] = {}

    end
    cacheParams =cacheInputDatas[tostring(methodCode)]



    --判断是否有空参数或者不合法
    for i,v in ipairs(views) do
        local params = v._itemData
        local inputStr = v.input_cs:getText()

        

        local t = params.type

        if inputStr ~= "" then
            cacheParams[i] = inputStr
            if t =="int" then
                if not tonumber(inputStr) then 
                    errorStr = errorStr .. params.name .." 格式错误,应该为int\n"
                else
                     sendParams[params.name] = toint(inputStr)
                end
               
            elseif t =="Array" then
                --如果是数组 数组格式 
                local arr = json.decode(inputStr)
                if not arr then
                    errorStr = errorStr .. params.name .." 格式错误,应该为数组格式\n"
                else
                    sendParams[ params.name] = arr
                end
            else

                if inputStr =="" then
                    errorStr = errorStr.. params.name .." 请输入参数\n"
                end

                sendParams[ params.name] = inputStr
            end

        else
            --todo
        end


    end

    if errorStr ~= "" then
        self:showErrorInfo(errorStr)
        return
    end


    self:setCacheHandleTime(self._currentModelIndex, methodCode)

    LS:pub():set(StorageCode.debugInputData, json.encode( cacheInputDatas) )

    


    local callBack = function ( result )
        if result.error then
            self:showErrorInfo("错误码:"..result.error.code.."_错误信息:"..result.error.message) 

        else

            local str =string.gsub(json.encode( result.result ),"\"","")

            str = string.gsub(str,",",", ")
            str = string.gsub(str,":",": ")
            str = string.sub(str, 1,1000)
            self.panel_xx.txt_fh:setString(str  )
            self:checkBaoxiang(result)
            self:checkChouKa(result)
            self:checkShenqi(result)
        end

    end
    
    echo("methodCode",methodCode)
    Server:sendRequest(sendParams, methodCode, callBack, nil, nil, true)

end


--显示详细信息
function TestConnView:showXiangxiView( ... )
    local modelData = UserModel:data()
    self.panel_grxx.panel_md:visible(false)

    local mtScroll = self.panel_grxx.scroll_mt
    self.panel_grxx.txt_mt:parent(mtScroll.scrollNode)
    --初始设置scrollNodeRect为基础大小
    mtScroll:setScrollNodeRect(table.copy(mtScroll.viewRect_ ))

    local userData = {}

    local eazyData = {}

    table.sortAsc(eazyData,1)

    --先存入简单数据
    table.insert(userData, {"base",eazyData })

    --把所有的 单字符项 列为一组 复杂的字符项列为一组 
    for k,v in pairs(modelData) do

        --如果是复杂对象
        if type(v) == "table" then

            local tempArr = {}
            --在把v进行转化
            for kk,vv in pairs(v) do
                table.insert(tempArr, {kk,vv})
            end
            table.sortAsc(tempArr,1)
            table.insert(userData, {k,tempArr })

        else
            table.insert(eazyData, {k,v })
        end
    end

    local sortFunc = function ( t1,t2 )
        return t1[1]<= t2[1]
    end

    table.sort(userData,sortFunc)



    local createFunc = function (itemData  )
        local view = UIBaseDef:cloneOneView(self.panel_grxx.panel_md)
        view.txt_md:setString(itemData[1])
        view.itemData = itemData
        view:setTouchedFunc(c_func(self.showModelData,self,itemData[2]) )
        return view
    end


    local params = {
        {


            data = userData,
            createFunc = createFunc,
            itemRect = self.panel_grxx.panel_md:getContainerBox(), --{x=0,y=-46,width = 142,height = 46},
            perNums= 1,
            offsetX =2,
            offsetY = 2,
            widthGap =10,
            heightGap =5,
            perFrame = 5
        }

    }

    self.panel_grxx.scroll_md:styleFill(params)
    --初始化显示基础信息
    self:showModelData(eazyData)


end


--展示某个模块数据
function TestConnView:showModelData( dataArr )
    local resultStr= ""
    local lineNums = 0

    local txtView = self.panel_grxx.txt_mt
    txtView:pos(0,0)
    local lineLength = txtView:getLineLength()
    for i,v in ipairs(dataArr) do
        local key = v[1]
        local data = v[2]
        --在把数据json格式化
        local tempStr = key ..":".. json.encode(data)
        tempStr = string.gsub(tempStr,",",", ")
        tempStr = string.gsub(tempStr,":",": ")
        --计算长度
        local tempArr = string.turnStrToLineGroup(tempStr,lineLength)
        --算行数
        lineNums = lineNums + #tempArr
        resultStr = resultStr..tempStr .."\n"
    end


    local allView = self.panel_grxx.scroll_md:getAllView()
    for i,v in ipairs(allView) do
        if v.itemData[2] == dataArr then
            v.mc_1:showFrame(2)
        else
            v.mc_1:showFrame(1)
        end
    end



    local height = (lineNums+1) * 20
    --设置文本高度
    txtView:setTextHeight(height)

    txtView:setString(resultStr)
    self.panel_grxx.scroll_mt:setScrollNodeRect( cc.rect( 0,-height,txtView:getContentSize().width,height ) )

end


--返回按钮
function TestConnView:press_btn_back()
    self:startHide()
end


function TestConnView:updateUI()
	
end

--导出神器csv
function TestConnView:checkShenqi( callBackData )
    if callBackData.method ~= 5306 then
        return
    end
    local data = { callBackData.result.data.reward}
    
    local csvString = self:coverData(data)
    self:exportDatas("logs/shenqi.csv",csvString)
end


--导出神器csv
function TestConnView:checkChouKa( callBackData )
    if callBackData.method ~= 101404 then
        return
    end
    local data = { callBackData.result.data.reward}
    
    local csvString = self:coverData(data)
    self:exportDatas("logs/chouka.csv",csvString)
end

--导出神器csv
function TestConnView:checkBaoxiang( callBackData )
    if callBackData.method ~= 100510 then
        return
    end

    local data = callBackData.result.data
    
    local csvString = self:coverData(data)
    self:exportDatas("logs/baoxiang.csv",csvString)

end

function TestConnView:coverData( data )
    local csvString = ""
    -- 记录 每个对象出现的次数
    local statisticsArr = {}

    local sortFunc = function (a,b  )
        return a[2] > b[2]
    end

    for i,v in ipairs(data) do
        local tempArr = {}
        statisticsArr[i] = tempArr

        local tempObj = {}
        for ii,vv in ipairs(v) do
            if type(vv)=="table" then
                vv= table.concat(vv,",")
            end
            if not tempObj[vv] then
                 tempObj[vv] = 0
            end
             tempObj[vv] =  tempObj[vv] +1

            -- csvString = csvString.."\""..vv.."\""..","
        end
        for kk,vv in pairs(tempObj) do
            table.insert(tempArr, {kk,vv })
        end
        table.sort( tempArr, sortFunc )
        for ii,vv in ipairs(v) do
            if type(vv) == "table" then
                vv = table.concat(vv,",")
            end
            csvString = csvString.."\"\'"..vv.."\""..","
        end
        csvString = csvString .."\n"
        for ii,vv in ipairs(tempArr) do
            csvString = csvString.."\"\'"..vv[1].."\""..","
        end
        csvString = csvString .."\n"
        for ii,vv in ipairs(tempArr) do
            csvString = csvString.."\""..vv[2].."\""..","
        end
        csvString = csvString .."\n"
    end 
    return  csvString
end


--导出数据
function TestConnView:exportDatas( fileName,message )

    if device.platform == "mac" then
        fileName = AppHelper:getResourcesRoot() .. "/".. fileName
    end

    local targetFile = io.open(fileName,"a")
    if targetFile == nil then
        return
    end

    targetFile:write(message.."\n")
    targetFile:close()

end



return TestConnView;
