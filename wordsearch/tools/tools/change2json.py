#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import codecs
import shutil
import xlrd  # http://pypi.python.org/pypi/xlrd
import openpyxl  # http://pypi.python.org/pypi/openpyxl
from level_converter import table2json_level  # 导入Level表专用转换器
 
 
def open_excel_file(file_path):
    """根据文件扩展名选择合适的方法打开Excel文件"""
    ext = os.path.splitext(file_path)[1].lower()
    
    if ext == '.xlsx':
        # 使用 openpyxl 处理 .xlsx 文件
        workbook = openpyxl.load_workbook(file_path)
        return workbook
    else:
        # 使用 xlrd 处理 .xls 文件
        return xlrd.open_workbook(file_path)

def get_sheet_names(workbook, file_path):
    """获取工作表名称列表"""
    ext = os.path.splitext(file_path)[1].lower()
    
    if ext == '.xlsx':
        return workbook.sheetnames
    else:
        return workbook.sheet_names()

def get_sheet_by_name(workbook, sheet_name, file_path):
    """根据名称获取工作表"""
    ext = os.path.splitext(file_path)[1].lower()
    
    if ext == '.xlsx':
        return workbook[sheet_name]
    else:
        return workbook.sheet_by_name(sheet_name)

def get_cell_value(sheet, row, col, file_path):
    """获取单元格值"""
    ext = os.path.splitext(file_path)[1].lower()
    
    if ext == '.xlsx':
        cell = sheet.cell(row=row+1, column=col+1)  # openpyxl 使用1基索引
        return cell.value
    else:
        return sheet.cell_value(row, col)

def get_sheet_dimensions(sheet, file_path):
    """获取工作表维度"""
    ext = os.path.splitext(file_path)[1].lower()
    
    if ext == '.xlsx':
        return sheet.max_row, sheet.max_column
    else:
        return sheet.nrows, sheet.ncols


def FloatToString(aFloat):
    if type(aFloat) != float:
        return ""
    strTemp = str(aFloat)
    strList = strTemp.split(".")
    if len(strList) == 1:
        return strTemp
    else:
        if strList[1] == "0":
            return strList[0]
        else:
            return strTemp
 
 
def table2json(table, jsonfilename, fileDir, file_path):
    hang, lie = get_sheet_dimensions(table, file_path)
    
    # 第一步：先收集所有有效的行号
    valid_rows = []
    for r in range(3, hang):
        # 检查第一列（作为key的列）是否为空，如果为空则跳过整行
        first_col_value = get_cell_value(table, r, 0, file_path)
        if first_col_value is None or str(first_col_value).strip() == "":
            # 第一列为空，跳过这一行
            continue
        valid_rows.append(r)
    
    # 第二步：写入JSON文件
    f = codecs.open(os.path.join(fileDir, jsonfilename), "w", "utf-8")
    #json文件开始括号
    f.write(u"{\n")
    
    # 遍历所有有效的行
    for idx, r in enumerate(valid_rows):
        # 收集这一行的所有有效字段
        row_fields = []  # 存储 (field_name, field_value) 元组
        row_key = None  # 存储行的key（第一列的值）
        
        for c in range(0, lie):
            # 获取第1行的字段名（关键字）和第2行的类型定义
            FieldName = get_cell_value(table, 0, c, file_path)  # 第1行是字段名（0基索引）
            ValueType = get_cell_value(table, 1, c, file_path)  # 第2行是类型定义（0基索引）
            
            # 检查字段名是否为空
            if FieldName is None or str(FieldName).strip() == "":
                # 字段名为空，跳过该列
                continue
            
            # 检查类型是否为空
            if ValueType is None or str(ValueType).strip() == "":
                # 类型为空，跳过该列
                continue
            
            if ValueType == "none":
                # none 类型：不生成字段
                continue
            
            # 获取一个单元格的值
            CellObj = get_cell_value(table, r, c, file_path)
            strCellValue = str(CellObj)
            
            # 如果是第一列，保存为key
            if c == 0:
                if type(CellObj) == float:
                    row_key = FloatToString(CellObj)
                else:
                    row_key = strCellValue
                # 确保键有引号
                if not row_key.startswith('"'):
                    row_key = u'\"' + row_key + u'\"'

            # 数据为空则跳过
            if strCellValue == "" or strCellValue == "None":
                continue

            # 根据数据类型处理值
            if ValueType == "number" or ValueType == "num":
                # 数字类型：直接输出数字，不加引号
                if type(CellObj) == float:
                    strCellValue = FloatToString(CellObj)
                else:
                    strCellValue = str(CellObj)
                
            elif ValueType == "string" or ValueType == "str":
                # 字符串类型：加引号
                strCellValue = strCellValue.replace(u"\"", u"")
                strCellValue = strCellValue.replace(u"\n", u"")
                strCellValue = u'\"'+strCellValue+u'\"'
                
            elif ValueType == "array1string":
                # 一维数组 字符串内容
                strCellValue = strCellValue.replace(u"\"", u"")
                strCellValue = strCellValue.replace(u"\n", u"")
                strCellValue = u'[\"' + strCellValue.replace(u"|", u"\",\"") + "\"]"

            elif ValueType == "array1" or ValueType == "array1number" or ValueType == "array1num":
                # 一维数组 数字
                strCellValue = strCellValue.replace(u"\n", u"")
                strCellValue = u'[' + strCellValue.replace(u"|", u",") + "]"

            elif ValueType == "array2string":
                # 二维数组 字符串内容
                strCellValue = strCellValue.replace(u"\"", u"")
                strCellValue = strCellValue.replace(u"\n", u"")
                strCellValue = u'[[\"' + strCellValue.replace(u"#", u"\",\"") + "\"]]"
                strCellValue = strCellValue.replace(u"|", u"\"],[\"")

            elif ValueType == "array2" or ValueType == "array2number" or ValueType == "array2num":
                # 二维数组 数字
                strCellValue = strCellValue.replace(u"\n", u"")
                strCellValue = u'[[' + strCellValue.replace(u"#", u",") + "]]"
                strCellValue = strCellValue.replace(u"|", u"],[")
                
            else:
                # 其它类型一律转成字符串
                strCellValue = strCellValue.replace(u"\"", u"")
                strCellValue = strCellValue.replace(u"\n", u"")
                strCellValue = u'\"'+strCellValue+u'\"'

            # 添加到字段列表（排除空字符串）
            if strCellValue != "\"\"":
                row_fields.append((str(FieldName), strCellValue))
        
        # 写入这一行的数据
        if row_key and row_fields:
            f.write(u'  ' + row_key + ': {')
            # 写入所有字段
            for field_idx, (field_name, field_value) in enumerate(row_fields):
                f.write(u'\"' + field_name + u'\":' + field_value)
                # 只有不是最后一个字段时才添加逗号
                if field_idx < len(row_fields) - 1:
                    f.write(u', ')
            f.write(u'}')

        # 每一个对象后面要加,（只有不是最后一个时才加）
        if idx < len(valid_rows) - 1:
            f.write(u",")
        # 换行
        f.write(u"\n")

    # 文件生成最后所有的数据要用反括号包起来
    f.write(u"}")
    # 关闭文件
    f.close()
    print("转换完成表 ", jsonfilename)
    return
 
 
# 取当前目录
curPath = os.path.dirname(__file__)
# 取上层目录的config文件夹路径
configPath = os.path.join(os.path.dirname(curPath), 'config')
# 取绝对路径目录
# curPath = "D:\\test"
print('当前操作路径: %s' % curPath)
print('配置文件路径: %s' % configPath)

# 在config同级目录下创建一个文件夹jsonOut
jsonDir = os.path.join(os.path.dirname(configPath), 'jsonOut')
# 判断文件夹是否存在决定建不建文件夹
isExists = os.path.exists(jsonDir)
if not isExists:
    os.makedirs(jsonDir)
else:
    # 如果文件夹已存在，先清空其中的所有文件
    print('清空jsonOut目录: %s' % jsonDir)
    for filename in os.listdir(jsonDir):
        file_path = os.path.join(jsonDir, filename)
        try:
            if os.path.isfile(file_path):
                os.remove(file_path)
                print('  删除文件: %s' % filename)
            elif os.path.isdir(file_path):
                shutil.rmtree(file_path)
                print('  删除目录: %s' % filename)
        except Exception as e:
            print('  删除 %s 时出错: %s' % (filename, e))

# 遍历config目录查询出所有的excel表
# fileNameList = os.listdir(configsPath)
fileNameList = os.listdir(configPath)
print(fileNameList)


for a in fileNameList:
    # 排除不需要的文件
    if a.startswith('.~') or a == '.DS_Store' or a.startswith('~$'):
        print("跳过文件：%s" % a)
        continue
    
    print("获得文件：%s"%(a))
    # 这里只能读取xlsx的表 如果是其他的表请加入判断
    extName = os.path.splitext(a)
    # 剔除缓存的表（额外检查）
    if(extName[0].find("~") >= 0 or extName[0].find("$") >= 0):
        print("跳过缓存文件：%s" % a)
        continue
    # 只有这三种格式的才转 其他的不管
    if(extName[1] == '.xlsx' or extName[1] == ".csv" or extName[1] == ".xls"):
        file_path = os.path.join(configPath, a)
        data = open_excel_file(file_path)
        # 使用Excel文件名（小写）作为JSON文件名
        json_filename = extName[0].lower() + '.json'
        
        # print("读取sheet名字：%s"%(get_sheet_names(data, file_path)))
        for sheetName in get_sheet_names(data, file_path):
            
            if(sheetName.find("_NO") >= 0):
                # _NO标记不生成的表
                continue
            
            # 对level表进行特殊处理：只读取sheetname == "level"的工作表
            if extName[0].lower() == 'level':
                if sheetName.lower() != 'level':
                    # level表只读取名为"level"的工作表，其他跳过
                    print("跳过工作表：%s (level表只读取名为'level'的工作表)" % sheetName)
                    continue
            
            table = get_sheet_by_name(data, sheetName, file_path)
            # print("读取sheet获得table：%s"%(table))

            # 使用Excel文件名（小写）作为JSON文件名，不使用工作表名
            # 对level表进行特殊处理
            if extName[0].lower() == 'level':
                table2json_level(table, json_filename, jsonDir, file_path)
            else:
                table2json(table, json_filename, jsonDir, file_path)

print("所有的表转换完成")

# 拷贝jsonOut中的json文件到assets/resources/config目录
def copy_json_files():
    """将jsonOut目录中的json文件拷贝到assets/resources/config目录"""
    # 获取项目根目录路径 - 从tools/tools/向上两级到项目根目录
    project_root = os.path.dirname(os.path.dirname(curPath))
    target_config_path = os.path.join(project_root, 'assets', 'resources', 'config')
    
    print('目标config目录: %s' % target_config_path)
    
    # 确保目标目录存在
    if not os.path.exists(target_config_path):
        os.makedirs(target_config_path)
        print('创建目标目录: %s' % target_config_path)
    
    # 获取jsonOut目录中的所有json文件
    json_files = [f for f in os.listdir(jsonDir) if f.endswith('.json')]
    
    if not json_files:
        print('jsonOut目录中没有找到json文件')
        return
    
    print('找到 %d 个json文件需要拷贝' % len(json_files))
    
    # 拷贝每个json文件
    for json_file in json_files:
        source_path = os.path.join(jsonDir, json_file)
        target_path = os.path.join(target_config_path, json_file)
        
        try:
            shutil.copy2(source_path, target_path)
            print('成功拷贝: %s' % json_file)
        except Exception as e:
            print('拷贝文件 %s 时出错: %s' % (json_file, e))
    
    print('所有json文件拷贝完成')

# 执行文件拷贝
copy_json_files()