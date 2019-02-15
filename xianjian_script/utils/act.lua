--act动作的封装扩展
local act = {}


function act.sequence(...)
	local args = {...}
	
	return cc.Sequence:create(args)
end
function act.spawn(...)
	local args = {...}
	return cc.Spawn:create(args)
end
function act._repeat(action,times)
	times = times or 0
	if times==0 then return cc.RepeatForever:create(action)
	else return cc.Repeat:create(action,times) end
end
function act.delaytime(time)
	return cc.DelayTime:create(time)
end
function act.callfunc(func)
	return cc.CallFunc:create(func)
end

function act.moveto(time, x, y)
    return cc.MoveTo:create(time, cc.p(x, y))
end
function act.moveby(time, x, y)
    return cc.MoveBy:create(time, cc.p(x, y))
end
--scaleto(dur,x) --scaleto(dur,x,y)
function act.scaleto(...)
	return cc.ScaleTo:create(...)
end
function act.scaleby(...)
    return cc.ScaleBy:create(...)
end
function act.rotateto(time, r)
	return cc.RotateTo:create(time,r)
end
function act.rotateby(time, r)
	return cc.RotateBy:create(time,r)
end

function act.fadein(time)
	return cc.FadeIn:create(time)
end
function act.fadeout(time)
	return cc.FadeOut:create(time)
end


function act.fadeto( time,opacity )
	return cc.FadeTo:create(time,opacity)
end

function act.expout(action)
	return cc.EaseExponentialOut:create(action)
end
function act.expin(action)
	return cc.EaseExponentialIn:create(action)
end
function act.sinout(action)
	return cc.EaseSineOut:create(action)
end

function act.bounceout(action)
	return cc.EaseBounceOut:create(action)
end
function act.bouncein(action)
	return cc.EaseBounceIn:create(action)
end

function act.easebackout(action)
	return cc.EaseBackOut:create(action)
end


return act
