--[[
	guan 
	2016.9.21
	ColorMatrixFilterPlugin.as to ColorMatrixFilterPlugin.lua
	得到颜色变化矩阵 
	详见 svn下 技术调研/tween/PluginExplorer-v11.swf和ColorMatrixFilterPlugin.as	

eg:
    local params = {
        colorize = "#ff00ff",--nil就是不设置这个参数
        amount = 2.4,

        contrast = 2,

        brightness = 2,
        saturation = 2,
        hue = 300,
        threshold = 200,
    }   

    local matrix = ColorMatrixFilterPlugin:genColorTransForm(params);

    ColorMatrixFilterPlugin:dumpMatrix(matrix);

    local sprite = display.newSprite("asset/test/test123.png");
    self._root:addChild(sprite);

    sprite:setPosition(200, 300);
    sprite:setScale(1);


    local sprite2 = display.newSprite("asset/test/test123.png");
    self._root:addChild(sprite2);

    sprite2:setPosition(600, 300);
    sprite2:setScale(1);

    FilterTools.setColorMatrix(sprite2, matrix);
]]

ColorMatrixFilterPlugin = ColorMatrixFilterPlugin or {}

local _idMatrix = {
	1,0,0,0, 0,
	0,1,0,0, 0,
	0,0,1,0, 0,
	0,0,0,1, 0
};

local _lumR = 0.212671; 
local _lumG = 0.715160; 
local _lumB = 0.072169;

--[[
	params = {
		colorize = "#ff00ff", --nil就是不设置这个参数
		amount = 2.4,
		contrast = 3,
		brightness = 1,
		saturation = 2,
		hue = 200,
		threshold = 100,
	}

	return matrix4*5 --FilterTools.setColorMatrix 可直接使用
]]
function ColorMatrixFilterPlugin:genColorTransForm(params)
	local endMatrix = _idMatrix;
	
	endMatrix = self:setBrightness(endMatrix, params.brightness);
	endMatrix = self:setContrast(endMatrix, params.contrast);
	endMatrix = self:setHue(endMatrix, params.hue);
	endMatrix = self:setSaturation(endMatrix, params.saturation);
	endMatrix = self:setThreshold(endMatrix, params.threshold);
	endMatrix = self:colorize(endMatrix, params.colorize, params.amount);

	return endMatrix;
end

--临时dump矩阵 erewrwer 1234567
function ColorMatrixFilterPlugin:dumpMatrix(matrix)

	for i = 1, 4 do
		echo(			
			-- math.round(matrix[(i - 1) * 5 + 1] * 1000) / 1000 , 
			-- math.round(matrix[(i - 1) * 5 + 2] * 1000) / 1000 ,
			-- math.round(matrix[(i - 1) * 5 + 3] * 1000) / 1000 ,
			-- math.round(matrix[(i - 1) * 5 + 4] * 1000) / 1000 ,
			-- math.round(matrix[(i - 1) * 5 + 5] * 1000) / 1000
			matrix[(i - 1) * 5 + 1], 
			matrix[(i - 1) * 5 + 2],
			matrix[(i - 1) * 5 + 3],
			matrix[(i - 1) * 5 + 4],
			matrix[(i - 1) * 5 + 5]
			);
		echo("\n")
	end
end

-- ============================== 霸道分割线 ============================== --

function ColorMatrixFilterPlugin:colorize(matrixIn, color, amount)
	amount = amount or 1;
	if color == nil then 
		return matrixIn;
	end 

	-- echo("---colorize---");
	local numColor = nil;

	if string.sub(color, 1, 1) == "#" then 
		numColor = string.format("%d", string.gsub(color, "#", "0x"))
	else 
		numColor = "0x" .. color;
	end 

	local c3b = numberToColor(numColor);
	local r = c3b.r / 255;
	local g = c3b.g / 255;
	local b = c3b.b / 255;

	local inv = 1 - amount;
	local temp = 
			{inv + amount * r * _lumR,  amount * r * _lumG,       amount * r * _lumB,       0, 0,
			amount * g * _lumR,         inv + amount * g * _lumG, amount * g * _lumB,       0, 0,
			amount * b * _lumR,         amount * b * _lumG,       inv + amount * b * _lumB, 0, 0,
			0, 				            0, 					      0, 					    1, 0};	

	return self:applyMatrix(temp, matrixIn);
end

function ColorMatrixFilterPlugin:setThreshold(matrixIn, n)
	if n == nil then 
		return matrixIn;
	end

	-- echo("---setThreshold---");

	local temp = 
				{_lumR * 256,  _lumG * 256, _lumB * 256, 0,  -256 * n, 
				_lumR * 256,   _lumG * 256, _lumB * 256, 0,  -256 * n, 
				_lumR * 256,   _lumG * 256, _lumB * 256, 0,  -256 * n, 
				0,                  0,                0,                1,  0}; 

	return self:applyMatrix(temp, matrixIn);
end

function ColorMatrixFilterPlugin:setHue(matrixIn, n)
	if n == nil then 
		return matrixIn;
	end 

	-- echo("---setHue---");

	local n = n * math.pi / 180;
	local c = math.cos(n);
	local s = math.sin(n);
	local temp = {(_lumR + (c * (1 - _lumR))) + (s * (-_lumR)), 
				  (_lumG + (c * (-_lumG))) + (s * (-_lumG)), 
				  (_lumB + (c * (-_lumB))) + (s * (1 - _lumB)), 
				  0, 
				  0, 

				  (_lumR + (c * (-_lumR))) + (s * 0.143), 
				  (_lumG + (c * (1 - _lumG))) + (s * 0.14), 
				  (_lumB + (c * (-_lumB))) + (s * -0.283), 
				  0, 
				  0, 

				  (_lumR + (c * (-_lumR))) + (s * (-(1 - _lumR))), 
				  (_lumG + (c * (-_lumG))) + (s * _lumG), 
				  (_lumB + (c * (1 - _lumB))) + (s * _lumB),
				  0, 
				  0, 

				  0, 0, 0, 1, 0, 
				  0, 0, 0, 0, 1};
	return self:applyMatrix(temp, matrixIn);
end

function ColorMatrixFilterPlugin:setBrightness(matrixIn, n)
	if n == nil then 
		return matrixIn;
	end

	-- echo("---setBrightness---");

	n = (n * 100) - 100;
	return self:applyMatrix(
					   {1,0,0,0,n,
						0,1,0,0,n,
						0,0,1,0,n,
						0,0,0,1,0,
						0,0,0,0,1}, matrixIn);
end

function ColorMatrixFilterPlugin:setSaturation(matrixIn, n)
	if n == nil then 
		return matrixIn;
	end

	-- echo("---setSaturation---");

	local inv = 1 - n;
	local r = inv * _lumR;
	local g = inv * _lumG;
	local b = inv * _lumB;

	local temp = {r + n , g     , b     , 0, 0,
				  r     , g + n , b     , 0, 0,
				  r     , g     , b + n , 0, 0,
				  0     , 0     , 0     , 1, 0};

	return self:applyMatrix(temp, matrixIn);

end



function ColorMatrixFilterPlugin:setContrast(matrixIn, n)
	if n == nil then 
		return matrixIn;
	end

	-- echo("---setContrast---");

	n = n + 0.01;

	local temp =  {n,0,0,0, 128 * (1 - n),
				   0,n,0,0, 128 * (1 - n),
				   0,0,n,0, 128 * (1 - n),
				   0,0,0,1, 0};
	return self:applyMatrix(temp, matrixIn);

end

function ColorMatrixFilterPlugin:applyMatrix(m1, m2)
	local ret = {};
	local i = 1;
	local z = 0;
	local y = nil;
	local x = nil;

	for y = 0, 3 do
		for x = 0, 4 do
			if (x == 4) then
				z = m1[i + 4];
			else 
				z = 0;
			end 

			ret[i + x] = m1[i]     * m2[x + 1]      +
						 m1[i + 1] * m2[x + 1 + 5]  +
						 m1[i + 2] * m2[x + 1 + 10] +
						 m1[i + 3] * m2[x + 1 +15]  +
						 z;
		end
		i = i + 5;
	end
	return ret;
end






































