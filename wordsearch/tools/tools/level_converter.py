#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Level表专用转换器
将Excel中的Level表转换为特殊格式的JSON数组
"""

import os
import codecs
import json


def FloatToString(aFloat):
    """将浮点数转换为字符串，去除不必要的.0后缀"""
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


def get_cell_value(sheet, row, col, file_path):
    """获取单元格值（兼容xlsx和xls）"""
    ext = os.path.splitext(file_path)[1].lower()
    
    if ext == '.xlsx':
        cell = sheet.cell(row=row+1, column=col+1)  # openpyxl使用1基索引
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


def convert_wordgroup_to_2d_array(word_string, xaxis, yaxis):
    """
    将WordGroup字符串根据Xaxis和Yaxis转换为二维数组
    
    Args:
        word_string: 字符串，如 "ZUIHKSDCBIAIWAPP"
        xaxis: X轴大小（行数）
        yaxis: Y轴大小（列数）
    
    Returns:
        二维数组，如 [["Z","U","I","H"], ["K","S","D","C"], ...]
    """
    word_string = word_string.replace(" ", "").replace("\n", "")
    word_array = []
    index = 0
    
    for x in range(xaxis):
        row = []
        for y in range(yaxis):
            if index < len(word_string):
                row.append(word_string[index])
                index += 1
            else:
                row.append("A")  # 如果字符串不够长，填充空字符串
                # 注意：这里无法获取Level id，因为是在convert_wordgroup_to_2d_array函数内部
        word_array.insert(0, row)
    
    return word_array


def table2json_level(table, jsonfilename, fileDir, file_path):
    """
    专门处理level表的函数，生成数组格式的JSON
    
    特点：
    1. 输出格式为数组 [...] 而不是对象 {...}
    2. WordGroup字段根据Xaxis和Yaxis转换为二维数组
    3. 按Level字段排序
    """
    hang, lie = get_sheet_dimensions(table, file_path)
    
    # 找到关键列的索引
    xaxis_col = -1
    yaxis_col = -1
    wordgroup_col = -1
    level_col = -1
    
    # 扫描第一行（字段名）找到对应列
    for c in range(0, lie):
        field_name = get_cell_value(table, 0, c, file_path)
        if field_name == "Xaxis":
            xaxis_col = c
        elif field_name == "Yaxis":
            yaxis_col = c
        elif field_name == "WordGroup":
            wordgroup_col = c
        elif field_name == "Level":
            level_col = c
    
    # 收集所有level数据
    level_data = []
    
    # 从第3行开始读取数据（0行字段名，1行类型，2行注释）
    for r in range(3, hang):
        level_obj = {}
        skip_row = True  # 用于判断该行是否有有效数据
        level_id = None  # 用于存储Level id，方便错误日志使用
        essential_fields_status = {}  # 记录必需字段的状态：字段名 -> (是否为空, 是否有错误, 错误信息)
        essential_fields = ["Xaxis", "Yaxis", "WordGroup", "Goal"]  # 必需字段列表
        field_errors = {}  # 记录字段转换错误：字段名 -> 错误信息
        
        # 读取所有字段
        for c in range(0, lie):
            field_name = get_cell_value(table, 0, c, file_path)
            field_type = get_cell_value(table, 1, c, file_path)
            cell_value = get_cell_value(table, r, c, file_path)
            
            # 检查字段名是否为空
            if field_name is None or str(field_name).strip() == "":
                # 字段名为空，跳过该列
                continue
            
            # 检查类型是否为空
            if field_type is None or str(field_type).strip() == "":
                # 类型为空，跳过该列
                continue
            
            # 跳过none类型字段
            if field_type == "none":
                continue
            
            # 检查是否是必需字段，记录其状态（即使为空也要记录）
            is_essential = field_name in essential_fields
            is_empty = (cell_value is None) or (isinstance(cell_value, str) and cell_value.strip() == "")
            
            if is_essential:
                essential_fields_status[field_name] = (is_empty, False, None)  # (是否为空, 是否有错误, 错误信息)
            
            # 跳过空值（但Level字段和必需字段除外，必需字段需要记录状态）
            if cell_value is None:
                if not is_essential:  # 非必需字段为空则跳过
                    continue
            if isinstance(cell_value, str) and cell_value.strip() == "":
                if not is_essential:  # 非必需字段为空则跳过
                    continue
            
            # 如果是Level字段，保存level_id
            if c == level_col:
                try:
                    if type(cell_value) == float:
                        level_id = int(FloatToString(cell_value))
                    else:
                        level_id = int(cell_value)
                except:
                    level_id = str(cell_value)
            
            skip_row = False  # 有有效数据
            
            # 特殊处理WordGroup字段
            if c == wordgroup_col and xaxis_col >= 0 and yaxis_col >= 0:
                try:
                    # 检查Xaxis和Yaxis是否有效
                    xaxis_value = get_cell_value(table, r, xaxis_col, file_path)
                    yaxis_value = get_cell_value(table, r, yaxis_col, file_path)
                    
                    # 检查Xaxis
                    xaxis = None
                    try:
                        xaxis = int(xaxis_value)
                    except:
                        field_errors["Xaxis"] = "Xaxis值 '%s' 无法转换为整数" % xaxis_value
                    
                    # 检查Yaxis
                    yaxis = None
                    try:
                        yaxis = int(yaxis_value)
                    except:
                        field_errors["Yaxis"] = "Yaxis值 '%s' 无法转换为整数" % yaxis_value
                    
                    # 如果Xaxis或Yaxis转换失败，不处理WordGroup，直接记录错误
                    if "Xaxis" in field_errors or "Yaxis" in field_errors:
                        field_errors["WordGroup"] = "无法处理WordGroup，因为Xaxis或Yaxis转换失败"
                    else:
                        # Xaxis和Yaxis都有效，继续处理WordGroup
                        word_string = str(cell_value).replace(" ", "").replace("\n", "")
                        
                        # 验证：x*y 是否等于 WordGroup的长度
                        expected_length = xaxis * yaxis
                        actual_length = len(word_string)
                        
                        if expected_length != actual_length:
                            error_msg = "Xaxis(%d) * Yaxis(%d) = %d，但WordGroup长度为 %d" % (
                                xaxis, yaxis, expected_length, actual_length
                            )
                            field_errors["WordGroup"] = error_msg
                            raise ValueError(error_msg)
                        
                        # 转换为二维数组
                        word_array = convert_wordgroup_to_2d_array(word_string, xaxis, yaxis)
                        level_obj[field_name] = word_array
                except Exception as e:
                    # 如果转换失败，记录错误
                    if "WordGroup" not in field_errors:
                        field_errors["WordGroup"] = "转换失败: %s" % str(e)
            else:
                # 处理其他字段
                if field_type == "number" or field_type == "num":
                    # 数字类型
                    if is_essential and field_name in ["Xaxis", "Yaxis"]:
                        # 必需字段Xaxis和Yaxis必须能转换为整数
                        try:
                            if type(cell_value) == float:
                                value_str = FloatToString(cell_value)
                                level_obj[field_name] = int(float(value_str))
                            else:
                                level_obj[field_name] = int(cell_value)
                        except Exception as e:
                            field_errors[field_name] = "值 '%s' 无法转换为整数: %s" % (cell_value, str(e))
                            # 不添加到level_obj，让后续检查发现缺失
                    else:
                        # 非必需字段，转换失败时使用默认值
                        if type(cell_value) == float:
                            value_str = FloatToString(cell_value)
                            # 尝试转换为整数
                            try:
                                level_obj[field_name] = int(float(value_str))
                            except:
                                level_obj[field_name] = value_str
                        else:
                            try:
                                level_obj[field_name] = int(cell_value)
                            except:
                                level_obj[field_name] = str(cell_value)
                            
                elif field_type == "array1string":
                    # 一维字符串数组
                    str_value = str(cell_value).replace("\"", "").replace("\n", "")
                    level_obj[field_name] = str_value.split("|")
                    
                elif field_type == "array1":
                    # 一维数字数组
                    str_value = str(cell_value).replace("\n", "")
                    try:
                        level_obj[field_name] = [int(x) if x.strip().isdigit() else x 
                                                for x in str_value.split("|")]
                    except:
                        level_obj[field_name] = str_value.split("|")
                        
                elif field_type == "string":
                    # 字符串类型
                    level_obj[field_name] = str(cell_value)
                else:
                    # 默认字符串类型
                    level_obj[field_name] = str(cell_value)
        
        # 如果该行有有效数据，检查数据完整性
        if not skip_row and level_obj:
            # 确保level_id已设置（如果之前没设置，尝试从level_obj中获取）
            if level_id is None and "Level" in level_obj:
                try:
                    level_id = int(level_obj["Level"])
                except:
                    level_id = level_obj["Level"]
            
            # 检查必需字段是否为空、缺失或出错
            missing_or_empty_fields = []
            error_messages = []
            
            for field_name in essential_fields:
                if field_name in field_errors:
                    # 字段转换出错
                    error_messages.append("%s: %s" % (field_name, field_errors[field_name]))
                    missing_or_empty_fields.append(field_name)
                elif field_name not in essential_fields_status:
                    # 字段在表中不存在
                    missing_or_empty_fields.append(field_name)
                else:
                    is_empty, _, _ = essential_fields_status[field_name]
                    if is_empty:
                        # 字段存在但为空
                        missing_or_empty_fields.append(field_name)
                    elif field_name not in level_obj:
                        # 字段存在且不为空，但没有成功添加到level_obj（可能是转换失败）
                        missing_or_empty_fields.append(field_name)
            
            # 如果有必需字段为空、缺失或出错，报错并跳过该行
            if missing_or_empty_fields or error_messages:
                level_str = "Level %s" % level_id if level_id is not None else "未知Level"
                error_parts = []
                if missing_or_empty_fields:
                    error_parts.append("必需字段为空或缺失: %s" % ", ".join(missing_or_empty_fields))
                if error_messages:
                    error_parts.append("字段错误: %s" % "; ".join(error_messages))
                print("错误 Level %s 第%d行数据不完整：%s" % (
                    level_id if level_id is not None else "未知", 
                    r+1, 
                    " | ".join(error_parts)
                ))
                # 不添加到结果中，跳过这行
                continue
            
            # 检查是否只有Level字段（虽然必需字段不为空，但可能只有Level字段）
            if len(level_obj) == 1 and "Level" in level_obj:
                print("错误 Level %s 第%d行数据不完整：表里没有配置数据，只有Level字段，缺少必需字段（如Xaxis、Yaxis、WordGroup等）" % (level_id if level_id is not None else "未知", r+1))
                # 不添加到结果中，跳过这行
                continue
            
            level_data.append(level_obj)
    
    # 按Level字段排序
    try:
        level_data.sort(key=lambda x: int(x.get("Level", 0)))
    except Exception as e:
        print("警告：Level字段排序失败，保持原有顺序: %s" % str(e))
    
    # 写入JSON文件 - 自定义格式化以优化WordGroup显示
    output_path = os.path.join(fileDir, jsonfilename)
    with codecs.open(output_path, "w", "utf-8") as f:
        f.write("[\n")
        
        for level_idx, level_obj in enumerate(level_data):
            f.write("  {\n")
            
            keys = list(level_obj.keys())
            for field_idx, field_name in enumerate(keys):
                field_value = level_obj[field_name]
                
                # 写入字段名
                f.write('    "%s": ' % field_name)
                
                # 特殊处理WordGroup字段 - 紧凑格式
                if field_name == "WordGroup" and isinstance(field_value, list):
                    f.write("[\n")
                    for row_idx, row in enumerate(field_value):
                        # 每行数组在同一行显示
                        row_str = json.dumps(row, ensure_ascii=False)
                        if row_idx < len(field_value) - 1:
                            f.write("      %s,\n" % row_str)
                        else:
                            f.write("      %s\n" % row_str)
                    f.write("    ]")
                else:
                    # 其他字段正常输出
                    if isinstance(field_value, list):
                        # 数组类型保持紧凑
                        value_str = json.dumps(field_value, ensure_ascii=False)
                        f.write(value_str)
                    elif isinstance(field_value, (int, float)):
                        # 数字类型
                        f.write(str(field_value))
                    else:
                        # 字符串类型
                        f.write(json.dumps(field_value, ensure_ascii=False))
                
                # 添加逗号
                if field_idx < len(keys) - 1:
                    f.write(",\n")
                else:
                    f.write("\n")
            
            # 关卡对象结束
            if level_idx < len(level_data) - 1:
                f.write("  },\n")
            else:
                f.write("  }\n")
        
        f.write("]")
    
    print("转换完成表（Level专用处理）: %s" % jsonfilename)
    print("  - 共转换 %d 条关卡数据" % len(level_data))
    
    return


if __name__ == "__main__":
    print("这是Level表转换器模块，请从主转换脚本调用。")

