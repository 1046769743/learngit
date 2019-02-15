--[[guan 2015.10.8]]

local GridViewAdapter = class("GridViewAdapter")

function GridViewAdapter:ctor(dataTable)
    self._data = dataTable;
end

function GridViewAdapter:getDataByIndex(index)
	return self._data[index];
end

function GridViewAdapter:getItemNum()
    return table.length(self._data);
end

function GridViewAdapter:delItemByIndex(index)
	table.remove(self._data, index);
	self._gridView:_delItemByIndexUseByAdapter(index);
end

function GridViewAdapter:addItemByIndex(itemData, index)
	table.insert(self._data, index, itemData);
	self._gridView:_addItemByIndexUseByAdapter(itemData, index);
end

function GridViewAdapter:setGridView(gridView)
	self._gridView = gridView;
end

function GridViewAdapter:getGridView()
	return self._gridView;
end

function GridViewAdapter:setUIView(uiView)
	self._uiView = uiView;
end

function GridViewAdapter:getUIView()
	return self._uiView;
end

function GridViewAdapter:updateSingleItem(index, data)
	if self._data[index] == nil then 
		echo("updateSingleItem error! data[index] is nil!");
		echo("index is " .. tostring(index));
	else 
		if data ~= nil then 
			self._data[index] = data;
		end 
		self._gridView:updateSingleItem(index);
	end 
end 

function GridViewAdapter:setSelectIndex(index)
	self._selectIndex = index;
end

function GridViewAdapter:getSelectIndex()
	return self._selectIndex;
end

return GridViewAdapter;













