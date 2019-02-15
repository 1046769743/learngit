
local LuaTest = {}

function LuaTest.test()
	-- LuaTest.testTableInsert()
    LuaTest.testLocal()
    -- LuaTest.testFunction()
    -- LuaTest.testString()
end

-- string&table char
function LuaTest.testString()
    local count = 10000
    local t1 = os.clock()
    local str = ""
    for i=1,count do
        str = str .. i
    end
    local t2 = os.clock()
    local interval1 = t2 - t1
    print("1-time=",interval1)

    -- ===========================
    local strTab = {}
    for i=1,count do
        strTab[#strTab+1] = i
    end
    str = table.concat(strTab,"",1,#strTab)
    local t3 = os.clock()
    local interval2 = t3 - t2
    print("2-time=",interval2,"ratio=",1 / (interval2 / interval1))
end

-- function call 
function LuaTest.testFunction()
    local count = 10000
    local t1 = os.clock()
    for i=1,count do
        local value = LuaTest.getValue()
    end
    local t2 = os.clock()
    local interval1 = t2 - t1
    print("1-time=",interval1)

    -- ===========================
    local value = LuaTest.getValue()
    for i=1,count do
        
    end
    local t3 = os.clock()
    local interval2 = t3 - t2
    print("2-time=",interval2,"ratio=",1 / (interval2 / interval1))
end

function LuaTest.getValue()
    return 1
end

-- local variable 
function LuaTest.testLocal()
    local count = 100000
    local t1 = os.clock()

    a = 1
    b = 1
    for i=1,count do
        a = a + b
    end
    local t2 = os.clock()
    local interval1 = t2 - t1
    print("1-time=",interval1)

    -- ===========================
    local a=1
    local b=1
    for i=1,count do
        a = a + b
    end

    local t3 = os.clock()
    local interval2 = t3 - t2
    print("2-time=",interval2,"ratio=",1 / (interval2 / interval1))
end

-- table insert 
function LuaTest.testTableInsert()
	print("testTableInsert")
	local count = 100000
	local tab = {}
    local t1 = os.clock()
    for i=1,count do
        table.insert(tab,i)
        -- tab[#tab+1] = i
    end
    local t2 = os.clock()
    local interval1 = t2 - t1
    print("1-time=",interval1)

    -- ===========================
    for i=1,count do
        tab[#tab+1] = i
    end
    local t3 = os.clock()
    local interval2 = t3 - t2
    print("2-time=",interval2,"ratio=",1 / (interval2 / interval1))
end


function LuaTest:test_1()
    local tab = {1,3,4}
    local a,b = next(tab)
    print("a,b=",a,b)
    print("#tab=",#tab,next(tab))
    -- print("next(tab)=",next(tab))
end

return LuaTest