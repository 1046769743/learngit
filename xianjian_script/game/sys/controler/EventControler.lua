--
-- Author: Your Name
-- Date: 2014-12-23 10:51:36
--

EventControler = class("EventControler")

--给EventControler注入 事件
EventEx.extend(EventControler)

FightEvent={}
EventEx.extend( FightEvent )
--所有全局侦听 都会采用 EventControler:addEventListener

-- EventControler:addEventListener = EventEx.addEventListener(eventName, listener,obj,tag)
-- EventControler:dispatchEvent = EventEx:dispatchEvent( eventName,params )
-- EventControler:removeEventListener = EventEx:removeEventListener( eventName,listener,obj )
-- EventControler:clearEvent = EventEx:clearEvent( eventName )
-- EventControler:clearOneObjEvent = EventEx:clearOneObjEvent( obj )


-- local a = class("ssas")
-- function a:haha( event )
--     echo(self.name,"__________",event.name)
-- end

-- function a.test(event)
--     echo(event.name,"____________")
-- end

-- local b = a.new()
-- local c = a.new()
-- b.name = "b"
-- c.name = "c"
-- EventControler:addEventListener("TEST", b.haha, b)

-- EventControler:addEventListener("TEST", a.test)

-- EventControler:clearOneObjEvent(b)


-- EventControler:dispatchEvent("TEST")



