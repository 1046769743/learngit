 Equation=class("Equation")

function Equation:ctor()
	
end
--转化弧度转化为 数学里面的 小的角
function Equation.transToSmallRadian(num)
	local result
	if (num>0 and num<math.pi/2) then
		result=num
	elseif (num>-math.pi and num<-math.pi/2) then
		result=math.pi-math.abs(num)
	elseif (num>-math.pi/2 and num<0) then
		result=num
	elseif (num>math.pi/2 and num<math.pi) then
		result=-(math.pi-num)
	end
	return result
end

-- 弧度转化为 垂线的角
function Equation.transToSmallVerticalRadian(num)
	local result
	result=transToSmallRadian(num)
	if (result>0 and result<math.pi/2) then
		result=-(math.pi/2-result)
	elseif (result>-math.pi and result<-math.pi/2) then
		result=-(math.pi/2-(math.pi-math.abs(result)))
	elseif (result>-math.pi/2 and result<0) then
		result=math.pi/2-math.abs(result)
	elseif (result>math.pi/2 and result<math.pi) then
		result=math.pi/2-(math.pi-result)
	end
	return result
end

--三角形 已知正切值和对边 求斜边的长
function Equation.triangleLength(tan,a)
	local c
	c=a*math.sqrt(tan*tan+1)/tan
	return c
end
--建立一元一次方程 点斜式
function Equation.creat_1_1_a(startP,radian,haveArea)
	if haveArea==nil then haveArea=false end
	local eqObj={}
	eqObj.haveArea=true
	if (radian==math.pi/2) then
		eqObj.typ="plumb"
		eqObj.a=1
		eqObj.b=0
		eqObj.c=-startP.x
	elseif (radian==0) then
		eqObj.typ="level"
		eqObj.a=0
		eqObj.b=1
		eqObj.c=-startP.y
	else
		eqObj.typ="normal"
		eqObj.b=1
		eqObj.a=-math.tan(radian)
		eqObj.c=-eqObj.a*startP.x-startP.y
	end

	eqObj.inArea = function(self,p,...)
		-- body
		return true
	end
	Equation.lineFunc( eqObj )
	return eqObj
end

--赋予一条直线 一些方法
function Equation.lineFunc( eqObj )
	eqObj.getY = Equation.lineXtoY
	eqObj.getX = Equation.lineYtoX

	--计算角的余弦值
	if eqObj.a ==0 then
		eqObj.cos = 1
		eqObj.sin =0
		eqObj.tan = 0
	elseif eqObj.b ==0 then
		eqObj.cos = 0
		eqObj.sin = 1
	else
		eqObj.tan = -eqObj.a/eqObj.b
		eqObj.ang = math.atan(eqObj.tan)
		eqObj.sin = math.sin(eqObj.ang)
		eqObj.cos = math.cos(eqObj.ang)
	end

end



--建立一元一次方程 2点式  ty 已知y 求x  tx 已知x 求y
function Equation.creat_1_1_b(startP,endP,haveArea)
	if haveArea==nil then haveArea=true end
	local eqObj={}
	eqObj.haveArea=haveArea
	if (startP.x==endP.x) then
		eqObj.typ="plumb"
		eqObj.a=1
		eqObj.b=0
		eqObj.c=-endP.x
	elseif (startP.y==endP.y) then
		eqObj.typ="level"
		eqObj.a=0
		eqObj.b=1
		eqObj.c=-endP.y
	else
		eqObj.typ="normal"
		eqObj.b=1
		eqObj.a=-(endP.y-startP.y)/(endP.x-startP.x)
		eqObj.c=-eqObj.a*startP.x-startP.y
	end
	eqObj.startP = startP
	eqObj.endP = endP
	eqObj.inArea =function (self,p )
		-- body
		local inX =false
		if(self.haveArea) then
			if p.x <= self.startP.x and p.x >= self.endP.x then
				--todo
				inX = true
			elseif p.x >=self.startP.x and p.x <=self.endP.x then
					--todo
					inX =true
			end
			local inY =false
			if p.y <=self.startP.y and p.y >=self.endP.y then
				--todo
				inY = true
			elseif p.y>=self.startP.y and p.y <= self.endP.y then
				--todo
				inY =true
			end
			if inX and inY then
				--todo
				return true
			end

			return false
		end
		return true
	end

	Equation.lineFunc( eqObj )

	return eqObj
end


--已知直线方程 x坐标,求y坐标  或者已知y求x
function Equation.lineXtoY(line,x )
	local y
	if line.b ==0 then
		return 0
	end
	if line.a ==0 then
		y = -line.c/line.b
	else
		y = (-line.c - line.a*x ) / line.b
	end
	return y
end

function Equation.lineYtoX(line,y )
	local x
	if line.a==0 then
		return 0
	end
	if line.b ==0 then
		x= -line.c/line.a
	else
		x = (-line.c - line.b*y) / line.a
	end
	return x
end


--已知2直线 求其夹角的正切值
function Equation.lineTangent(eq1,eq2)
	local tan=0
	local k1
	local k2
	if (eq1.b==0 and eq2.a~=0) then
		tan=eq2.b/eq2.a
		if (true) then
			return tan
		end
	end
	if (eq2.b==0 and eq1.a~=0) then
		tan=eq1.b/eq1.a
		if (true) then
			return tan
		end
	else
		k1=-eq1.a/eq1.b
		k2=-eq2.a/eq2.b
		tan=(k2-k1)/(k2*k1+1)
		if (true) then
			return tan
		end
	end
	if (true) then
		return tan
	end
end
--判断2个一元一次方程的交点
function Equation.pointOf(eqObj1,eqObj2)
	local p
	if (eqObj1.a==0 and eqObj2.a==0) then
		return nil
	elseif (eqObj1.typ=="level") then
		p={}
		p.y=-eqObj1.c
		p.x=(-eqObj2.c-eqObj2.b*p.y)/eqObj2.a
	elseif (eqObj2.typ=="level") then
		p={}
		p.y=-eqObj2.c
		p.x=(-eqObj1.c-eqObj1.b*p.y)/eqObj1.a
	elseif (eqObj1.typ~="level" and eqObj2.typ~="level") then
		p={}
		if (eqObj1.typ=="plumb") then
			p.x=-eqObj1.c
			p.y=(-eqObj2.c-eqObj2.a*p.x)/eqObj2.b
		elseif (eqObj2.typ=="plumb") then
			p.x=-eqObj2.c
			p.y=(-eqObj1.c-eqObj1.a*p.x)/eqObj1.b
		else
			p.y=(eqObj2.c/eqObj2.a-eqObj1.c/eqObj1.a)/(eqObj1.b/eqObj1.a-eqObj2.b/eqObj2.a)
			p.x=(-eqObj1.c-eqObj1.b*p.y)/eqObj1.a
		end
	end
	if (p==nil) then
		return nil
	elseif (eqObj1:inArea(p) and eqObj2:inArea(p)) then
		return p
	else
		return nil
	end
	return nil
end

--平面2点间的距离
function Equation.dis(p1,p2)
	local dis= math.sqrt(Equation.disSqure(p1,p2 ))
	return dis
end

--2点间距离的平方
function Equation.disSqure(p1,p2 )
	local dx = p1.x - p2.x
	local dy = p1.y - p2.y
	local dz = 0
	if p1.z and p2.z then
		dz = p1.z -p2.z
	end

	
	return dx*dx+dy*dy +dz*dz
end


--平面2点间的距离2
function Equation.dis2( x1,y1,x2,y2 )
	local dx = x2-x1
	local dy = y2-y1
	return math.sqrt(dx*dx + dy*dy)
end


--2点的角度
function Equation.angle( p1,p2 )
	local dx = p2.x - p1.x
	local dy = p2.y - p1.y
	return math.atan2(dy, dx)
end


--2点之间的点 默认为终点 否则就是按比例取点
function Equation.middle( p1,p2 ,ratio,decimal)
	if not ratio then
		return {x= (p1.x+p2.x)/2, y = (p1.y+p2.y)/2 }
	end

	local x = p1.x + (p2.x-p1.x) * ratio
	local y = p1.y + (p2.y-p1.y) * ratio

	if decimal then
		x= Equation.getNumByDecimal(x, decimal)
		y = Equation.getNumByDecimal(y, decimal)
	end
	
	return {x= x,y=y}


end




--过一点做已知直线的垂线
function Equation.plumbLine(p,eqobj)
	local eq
	if (eqobj.typ=="level") then
		eq=Equation.creat_1_1_a(p,math.pi/2)
	elseif (eqobj.typ=="plumb") then
		eq=Equation.creat_1_1_a(p,0)
	else
		eq={}
		eq.a=eqobj.b
		eq.b=-eqobj.a
		eq.c=eqobj.a*p.y-eqobj.b*p.x
		eq.typ="normal"
		eq.haveArea=false
		eq.inArea = function (self, p,... )
			-- body
			return true
		end
	end
	if (true) then
		return eq
	end
end
--计算点到直线的距离
function Equation.pointLineDistance(p,eqobj,tpy)
	if tpy==nil then tpy=0 end
	local distance
	if (tpy==0) then
		distance=math.abs(eqobj.a*p.x+eqobj.b*p.y+eqobj.c)/math.sqrt(
						eqobj.a*eqobj.a+eqobj.b*eqobj.b)
	elseif (tpy==1) then
		distance=(eqobj.a*p.x+eqobj.b*p.y+eqobj.c)/math.sqrt(
						eqobj.a*eqobj.a+eqobj.b*eqobj.b)
	elseif (tpy==2) then
		distance=-(eqobj.a*p.x+eqobj.b*p.y+eqobj.c)/math.sqrt(
					eqobj.a*eqobj.a+eqobj.b*eqobj.b)
	end
	if (true) then
		return distance
	end
end

--计算一个点关于另外一条直线的对称点
function Equation.getSymmetryPoint(p,eqobj )
	local pointof = Equation.getPlumbPoint(p,eqobj)
	local resultPoint = {x=pointof.x*2 - p.x,y = pointof.y*2 - p.y}
	return resultPoint
end


--修正坐标 到直线的距离 小于半径 然后修正到刚好等于半径
function Equation.adjustPosByLine(p,dis,r,ang,eq)
	local angDis=ang-eq.angle
	local length=(r-dis*eq.type)/math.abs(math.sin(angDis))
	p.x=p.x-length*math.cos(ang)
	p.y=p.y-length*math.sin(ang)
	if (true) then
		return p
	end
end

--过点做目标线段的垂线，判断垂线和目标直线是否有交点 
function Equation.checkPlumbPoint(p,eq)
	local plumbLine=Equation.plumbLine(p,eq)
	if (Equation.pointOf(plumbLine,eq)==nil) then
		if (true) then
			return false
		end
	else return true end 
end

--过点做目标2点所在的线段的垂线，判断垂线和目标直线是否有交点 
function Equation.checkPointByThreePoint(p,lineP1,linep2)
	local line=creat_1_1_b(lineP1,linep2)
	local plumbLine=Equation.plumbLine(p,line)
	if (Equation.pointOf(plumbLine,line)==nil) then
		return false
	else return true end 
end

--点到直线的距离
function Equation.pointLineDistance2(p,lineP1,lineP2)
	local line=creat_1_1_b(lineP1,lineP2)
	if (Equation.checkPlumbPoint(p,line)) then
		if (true) then
			return Equation.pointLineDistance(p,line)
		end
	else
		local dis1=(lineP1.x-p.x)*(lineP1.x-p.x)+(lineP1.y-p.y)*(lineP1.y-p.y)
		local dis2=(lineP2.x-p.x)*(lineP2.x-p.x)+(lineP2.y-p.y)*(lineP2.y-p.y)
		local dis=math.min(dis1,dis2)
		if (true) then
			return math.sqrt(dis)
		end
	end
	if (true) then
		return 0
	end
end

function Equation.symmetryByPAToPB(pa,pb)
	local arr={}
	arr[1]=2*pb[1]-pa[1]
	arr[2]=2*pb[2]-pa[2]
	if (pb[2]~=nil) then
		arr[3]=2*pb[3]-pa[3]
	end
	return arr
end
--过一点 作已知直线垂线， 求出交点
function Equation.getPlumbPoint(p,eq)
	local line=Equation.plumbLine(p,eq)
	line.haveArea=false
	return Equation.pointOf(line,eq)
end
--圆与直线交点的求法					圆心				半径	直线	直线方向的角度 类型 1是 正方向交点 -1 是反方向交点	
function Equation.roundLinePointof(centrePoint,r,eq,ang,type)
	local dis=pointLineDistance(centrePoint,eq)
	local length=math.sqrt(r*r-dis*dis)
	local plumb=Equation.plumbLine(centrePoint,eq)
	local point1=Equation.pointOf(eq,plumb)
	local pointoff={x=0,y=0}
	pointoff.x=point1.x+length*type*math.cos(ang)
	pointoff.y=point1.y+length*type*math.sin(ang)
	if (true) then
		return pointoff
	end
end


--判断一点是否在圆内 
function Equation.checkInCircle( circle,point )
	local dx = point.x - circle.x
	local dy = point.y - circle.y
	if dx*dx+dy*dy <circle.r*circle.r then
		return true
	end
	return false

end




--判断三点的位置关系 中间一点是否在2点之间
function Equation.check3PointPos(p1,p2,p3,type)
	if type==nil then type=0 end
	local xCheck=false
	local yCheck=false
	if (type==0) then
		if (p2.x<=p1.x and p2.x>=p3.x) then
			xCheck=true
		elseif (p2.x<=p3.x and p2.x>=p1.x) then
			xCheck=true
		else
			xCheck=false
		end
		if (p2.y<=p1.y and p2.y>=p3.y) then
			yCheck=true
		elseif (p2.y<=p3.y and p2.y>=p1.y) then
			yCheck=true
		else
			yCheck=false
		end
		if (xCheck and yCheck) then
			if (true) then
				return true
			end
		else return false end 
	else
		if (p2.x<p1.x and p2.x>p3.x) then
			xCheck=true
		elseif (p2.x<p3.x and p2.x>p1.x) then
			xCheck=true
		else
			xCheck=false
		end
		if (p2.y<p1.y and p2.y>p3.y) then
			yCheck=true
		elseif (p2.y<p3.y and p2.y>p1.y) then
			yCheck=true
		else
			yCheck=false
		end
		if (xCheck and yCheck) then
			if (true) then
				return true
			end
		else return false end 
	end
end

--算抛物线方程 参数为 起点 终点 顶点 重力
function Equation.creat_2_2(pa,pb,pc,g)
	local eqObj={}
	eqObj.pa=pa
	eqObj.pb=pb
	eqObj.pc=pc
	if (math.abs(pa.x-pb.x)<=2) then
		pb.x=pb.x+3
		eqObj.pb.x=eqObj.pb.x+3
	end
	eqObj.b=(pb.x*math.sqrt((pa.y-pc.y)/(pb.y-pc.y))+pa.x)/(1+math.sqrt((pa.y-pc.y)/(pb.y-pc.y)))
	eqObj.a=(pa.y-pc.y)/(pa.x-eqObj.b)/(pa.x-eqObj.b)
	eqObj.c=pc.y
	eqObj.pc.x=eqObj.b
	eqObj.yCd = function ( xCd )
		-- body
		return eqObj.a * (xCd - eqObj.b) * (xCd - eqObj.b) + eqObj.c
	end
	eqObj.radian=math.atan(2*eqObj.a*pa.x-2*eqObj.a*eqObj.b)
	eqObj.currentRad = function ( xCd)
		return eqObj.a*(xCd - eqObj.b) * (xCd-eqObj.b) + eqObj.c
		-- body
	end
	eqObj.t1=math.sqrt(2*(pc.y-pa.y)/-g)
	eqObj.t2=math.sqrt(2*(pc.y-pb.y)/-g)
	eqObj.speed=-g*eqObj.t1/math.sin(eqObj.radian)
	if (true) then
		return eqObj
	end

end

--计算速度 根据x距离 x速度和重力 计算y速度和y距离
function Equation.countPlumbSpeedBySVG(sx,vx,g)
	local t=math.abs(sx/vx)
	local vy=-g*t/2
	local sy=-g*t*t/4
	return {vy,sy}
end
--计算z速度和重力加速度,根据起点,终点,和最高点z 
function Equation.countSpeedZBySEH(x1,z1,x2,z2,vx,zhei )
	local dx =x2-x1
	local t = dx/vx --运动事件
	local dz =z2 - z1 --起点和终点的z坐标差
	local dzh1 = zhei - z1 --最高点 和起点坐标z坐标差
	local dzh2 = z2 - zhei --目标点 和最高点 z坐标差

	local g,t1,t2
	local t1 = t/(1+math.sqrt(-dzh2/dzh1 ))
	echo(x1,z1,x2,z2,vx,zhei,"__________aaaaaaaaaaaaaa",dz,dzh1,t,t1)
	local g = -dzh1*2/(t1*t1)
	local vz = -g*t1
	return vz,g
end


--计算z速度和重力加速度,根据起点,终点,重力加速度g,和最高点z 
function Equation.countSpeedXZBySEHG(x1,z1,x2,z2,g,zhei )
	local dzh1 = zhei - z1 --最高点 和起点坐标z坐标差
	local dzh2 = z2 - zhei --目标点 和最高点 z坐标差 
	local t1 = math.sqrt( -dzh1 * 2/g )
	local t2 = math.sqrt(dzh2 * 2/g )
	local vx = (x2 - x1)/(t1 + t2)
	local vz = -g*t1
	return vx,vz
end



function Equation.countPlumbSpeedBySVS(sx,vx,sy)
	local t=math.abs(sx/vx)
	local g=math.abs(sy)*2/(t*t)
	return {-g*t/2,g}
end

--角度旋转 把一个坐标按指定角度旋转 求出旋转后的坐标 true 瞬时间旋转 false 逆时针
function Equation.ratoteFormulation(nx,ny,ang,boo)
	if boo==nil then boo=true end
	local cos=math.cos(ang)
	local sin=math.sin(ang)
	local p
	local newX=cos*nx-sin*ny
	local newY=cos*ny+sin*nx
	local backX=cos*nx+sin*ny
	local backY=cos*ny-sin*nx
	if (boo) then
		p={x=newX,y=newY}
	else
		p={x=backX,y=backY}
	end
	return p
end

--根据距离dx,dy  重力加速度g 时间t 计算初始速度  2维 3维都可以
function Equation.countSpeedByTime(dx,dy,g,time)
	if time==nil then time=0 end
	local obj={}
	obj.xSpeed=dx/time
	obj.ySpeed=(dy-0.5*g*time*time)/time
	obj.angle=math.atan2(obj.ySpeed,obj.xSpeed)
	if (true) then
		return obj
	end
end

--根据距离dx,dy,重力g  计算 速度
function Equation.countSpeedByHeight(dx,dy,g)
	local obj={}
	local time=math.sqrt(-2*dy/g)
	obj.ySpeed=-g*time
	obj.xSpeed=dx/(time*2)
	obj.time=time
	obj.angle=math.atan2(obj.ySpeed,obj.xSpeed)
	return obj
end

--已知位移s 时间t, 加速g 求初速度
function Equation.countVBySTG(s,t,g )
	local v =( s-0.5 * g* t*t ) / t
	return v
end


--获取小数
function Equation.getNumByDecimal( num,decimal )
	if not decimal then
		decimal = 0
	end

	local tempPow = math.pow(10,-decimal)
	local temp = num * tempPow
	temp = math.round(temp)
	return temp / tempPow

end


--随机获取一个数量
function Equation.getRadomFromMinMax(start,endNum,decimal,random)
	if decimal==nil then decimal=0 end
	local dis=endNum-start
	if not random then
		random = math.random()
	end
	
	local k=(endNum-start)/(1-0)
	local result=k*(random-0)+start
	return Equation.getNumByDecimal(result,decimal)
end

--根据起点终点 重力和高度获取 速度
function Equation.getSpeedBySEGH(s,e,g,h)
	local t
	local xSpeed =0
	local ySpeed =0
	local zSpeed =0
	local dx=e[1]-s[1]
	local dy=e[2]-s[2]
	local dz = e[3] - s[3]
	if (dz<h) then
		dz = h
	end
	local halfT =0
	halfT=math.sqrt(-2*h/g)
	zSpeed=-g*halfT
	t=halfT+math.sqrt(-(h-dz)*2/g)
	xSpeed=dx/t
	ySpeed=dy/t
	--echo("speed2222:",xSpeed,ySpeed,zSpeed,dx,dy,dz,halfT,t)
	return {xSpeed,ySpeed,zSpeed}
end
--获取对数
function Equation.log(base,logarithm)
	if (base==1) then
		if (true) then
			return 1
		end
	end
	return math.log(logarithm)/math.log(base)
end



--获取一组数的和
function Equation.sumArr(numsArr,params )
	local total = 0
	local temp
	for i,v in ipairs(numsArr) do
		
		total = total + table.getValue(v,params)
	end
	return total
end


--获取一组数的 平均值
function Equation.avArr(numsArr,params)
	local average= Equation.sumArr(numsArr, params)
	
	average=average/(#numsArr)
	return average
end

--获取一组数的方差
function Equation.varArr(numsArr,params)
	local average=Equation.avArr(numsArr,params)
	local variance=0
	local dis
	local temp

	for i,v in ipairs(numsArr) do
		dis = table.getValue(v,params) -average
		variance=variance+dis*dis
	end

	return variance
end


--平方
function Equation.power2(value )
	return value*value
end




--根据半径范围回去随机的点
function Equation.getRadomPointByRadius(r,r2,a,a2,random1,random2)
	if r==nil then r=200 end
	if r2==nil then r2=0 end
	if a==nil then a=0 end
	if a2==nil then a2=math.pi*2 end
	--需要获取随机半径和角度
	local radomR=Equation.getRadomFromMinMax(r,r2,-2,random1)
	local ang=Equation.getRadomFromMinMax(a,a2,-2,random2)
	local xPos=radomR*math.cos(ang)
	local ypos=radomR*math.sin(ang)
	local obj =  {x=xPos,y=ypos}
	return obj
end



--矩阵乘法
function Equation.multiMatrix(ma1,ma2,whetherQuPi )
	if not whetherQuPi then
		whetherQuPi = true
	end
	
	local resultMa = {}
	
	if type(ma1[1])=="number" then
		ma1 = {ma1}
	end

	local h1 = table.getn(ma1)
	local l1 =table.getn(ma1[1])

	
	if type(ma2[1]) =="number"then
		ma2 = {ma2}

	end

	local h2 = table.getn(ma2)
	local l2 =table.getn(ma2[1])

	local value=0
	for i=1,h1 do
		resultMa[i] = {}
		
		for j=1,l2 do
			value =0
			for k=1,l1 do
				value = value+ ma1[i][k]*ma2[k][j]
			end
			resultMa[i][j] = value
		end

	end

	if whetherQuPi then
		if h1 == 1 then
			resultMa = resultMa[1]
		end
	end
	return resultMa




end


--获取延某条直线走N个单位长度后的点的坐标
function Equation.getLinePosByLength( p1,p2,length,xiaoshu )
	local dx = p2.x - p1.x
	local dy = p2.y - p1.y
	local ang = math.atan2(dy,dx)
	local cos = math.cos(ang) * length
	local sin = math.sin(ang)* length
	local result = {x=p2.x + cos,y=p2.y + sin}
	if xiaoshu then
		result.x = Equation.getNumByDecimal(result.x,xiaoshu)
		result.y = Equation.getNumByDecimal(result.y,xiaoshu)
	end
	
	return result
end


--计算2个 xyzw向量 按照百分比计算
function Equation.countVec4percent( v1,v2,percent )
	local x = (v2.x- v1.x) * percent + v1.x
	local y = (v2.y- v1.y) * percent + v1.y
	local z = (v2.z- v1.z) * percent + v1.z
	local w = (v2.w- v1.w) * percent + v1.w
	return {x=x,y=y,z=z,w=w}
end

--计算2个矩阵的百分比
function Equation.countMatrixPercent(m1,m2,percent )
	local len = #m1
	local resultMatrix = {}
	for i=1,len do
		local v1 = m1[i]
		local v2 = m2[i]
		resultMatrix[i] = (v2-v1) * percent + v1
	end
	return resultMatrix

end


--计算2个向量的和
function Equation.vectorAdd( vec1,vec2 )
	--如果是有z向量的
	local vecResult = {x = vec1.x+vec2.x,y = vec1.y+ vec2.y}
	if vec1.z then
		vecResult.z = vec1.z + vec2.z
	end
	return vecResult
end

--向量乘法
function Equation.vectorMul( vec,nums )
	local vecResult = {x = vec.x*nums,y = vec.y* nums}
	if vecResult.z then
		vecResult.z = vec1.z * nums
	end
	return vecResult
end

--向量减法
function Equation.vectorReduce( vec1,vec2 )
	--如果是有z向量的
	local vecResult = {x = vec1.x-vec2.x,y = vec1.y-vec2.y}
	if vec1.z then
		vecResult.z = vec1.z - vec2.z
	end
	return vecResult
end


--判断一个点是否在多边形内
function Equation.checkPosInPolygon( pos,polygonPointArr )
	
	--水平向右引发一条射线 判断是否与多边形有交点
	local length = #polygonPointArr
	local crossNums  = 0
	local posA
	local posB
	for i=1,length do
		local j = i+1
		if i == length  then
			j = 1
		end
		posA = polygonPointArr[i]
		posB = polygonPointArr[j]
		--如果不是坐标模式的 那么创建一个临时数组
		if not posA.x then
			posA = {x= posA[1],y = posA[2]}
			posB = {x= posB[1],y = posB[2]}
		end

		if (posA.y > pos.y) ~= (posB.y > pos.y) then
			--必须A B 不是 水平的
			if posB.y ~= posA.y then
				if pos.x < ( (posB.x - posA.x) * (pos.y - posA.y ) / (posB.y - posA.y) + posA.x  ) then
					crossNums = crossNums +1
				end
			end
		end
	end

	--奇数返回true 偶数返回false
	return  crossNums %2 == 1

end


local turnPosParams = nil

--[[
	透视坐标模拟转换偏移
	等腰梯形  BCDE , 梯形俩边延长线交点为A
	梯形中轴线是 没有任何偏移的 ,我们需要以A为起点 ,目标点world.x所在的直线. 然后求出真实的x,y
	
]]
function Equation._init3DParams(  )
	if turnPosParams then
		return
	end
	turnPosParams ={}
	turnPosParams.width = GameVars.width
	turnPosParams.maxOffset = 215
	turnPosParams.maxYOffset = 50	
	turnPosParams.secondYOffest = 50
	turnPosParams.mapRect = {
		ld={ x=GameVars.UIOffsetX+-turnPosParams.maxOffset,y = GameVars.UIOffsetY -turnPosParams.maxYOffset },  		--左下 leftDown点E坐标
		lu={ x= GameVars.UIOffsetX,y = GameVars.UIOffsetY+GameVars.gameResHeight  },		--左上  B
		rd={x= GameVars.UIOffsetX+GameVars.gameResWidth  + turnPosParams.maxOffset ,y=GameVars.UIOffsetY- turnPosParams.maxYOffset},			--右下  D
		ru={x= GameVars.UIOffsetX+GameVars.gameResWidth,y= GameVars.UIOffsetY+GameVars.gameResHeight} 			--右上  C
	}

	turnPosParams.pointB = turnPosParams.mapRect.lu
	turnPosParams.pointC = turnPosParams.mapRect.ru
	turnPosParams.pointE = turnPosParams.mapRect.ld
	turnPosParams.pointD = turnPosParams.mapRect.rd


	--计算 线条方程 B(lu),C(ru),E(ld),D(rd) ,BE和DC的交点为A 
	turnPosParams.lineBE = Equation.creat_1_1_b(turnPosParams.pointB,turnPosParams.pointE,false)
	turnPosParams.lineCD = Equation.creat_1_1_b(turnPosParams.pointC,turnPosParams.pointD,false)

	turnPosParams.lineYObj = Equation.creat_1_1_b({x=GameVars.gameResHeight,y=GameVars.gameResHeight},{x=0,y = -turnPosParams.maxYOffset},false)

	turnPosParams.pointA = Equation.pointOf(turnPosParams.lineBE,turnPosParams.lineCD)
	turnPosParams.cosAngle = 1--math.cos(math.pi/9)
	
end

--修正3D坐标 worldPos 是相对屏幕的坐标  返回一个坐标偏移 
function Equation.adjust3Dpos( worldPos )
	Equation._init3DParams()
	local x,y = worldPos.x,worldPos.y
	local targetLine = Equation.creat_1_1_b(turnPosParams.pointA,{x=x,y = turnPosParams.pointB.y})
	local targetY = turnPosParams.lineYObj:getY(worldPos.y)
	local targetPosX = targetLine:getX(worldPos.y)
	local resultPos = {} --self.charNode:convertToNodeSpaceAR(worldPos)

	--y坐标偏移是很复杂的折线   


	resultPos.x =  - (targetPosX - worldPos.x)
	resultPos.y =  - (targetY - y)

	local dy = worldPos.y - GameVars.cy 
	local offsetY =0
	if dy > 0 then
		offsetY = -turnPosParams.secondYOffest * (1-dy/ GameVars.halfResHeight )
	else
		offsetY = -turnPosParams.secondYOffest * (1+dy/ GameVars.halfResHeight )
	end

	resultPos.y = resultPos.y + offsetY


	-- resultPos.x =0
	-- resultPos.y =0
	return resultPos
end