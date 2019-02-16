# -*- coding:utf-8 -*-
import fileTool
import hashlib
import json
import itertools
import os,sys
# def changeToWordTravel(data):

word_travel_path = "word_travel/"
#获取竞品 levelGroup 数据
def get_level_group_data(fileName,startLevel):
	filePath = word_travel_path + "Wordscapes_data/" + fileName + ".json"
	fileData = fileTool.readJsonFile(filePath)
	
	levelDataMap = {}
	for x in range(1,len(fileData.keys())+1):
		level = "level_" + "%03d"%x
		levelDataMap[startLevel] = fileData[level]
		startLevel += 1
	return levelDataMap

#将 竞品数据 按level 保存到一张表里
def gen_all_data_file():
	fileData = fileTool.readXlsxFile_Map(word_travel_path+'Wordscapes.xlsx')
	filesNameList = fileData["FILE"]
	levelEndList = fileData["NUM"]
	levelStartList = fileData["LEVEL"]


	allDataList = []
	for x in range(0,len(filesNameList)):
		allDataList.append(get_level_group_data(filesNameList[x],levelStartList[x]))

	allDataMap = {}
	for x in range(0,len(allDataList)):
		allDataMap = dict(allDataMap, **allDataList[x])

	fileTool.saveJsonFile(word_travel_path+"all_word_cross_data.json",allDataMap)

def del_single_word(levelData,level,adddouhao):
	wordsData = levelData["e"]
	delWord = []
	for x in range(len(wordsData)-1,-1,-1):
		wList = wordsData[x].split(",")
		print x,level
		if wList[2].find("B") >= 0:
			delWord.append(wordsData[x])
			wordsData.pop(x)

	levelData["e"] = wordsData
	with open('deleteWord.txt', 'a') as f:
		for line in delWord:
			f.write(line+'\n')

	ddd = {}
	if len(delWord) > 0:
		data1 = {}
		data1["words"] = []
		for line in wordsData:
			wList = line.split(",")
			data1["words"].append(wList[3])
		data1["letters"] = list(levelData["b"])
		ddd[level] = data1


		with open(word_travel_path + 'resetLayoutWord.json', 'a') as f:
			f.write('\n')
			# fd.write("\"{}\" : {},\n".format(str(index+1), json.dumps(data)))
			f.write(json.dumps(ddd, indent=4))
			if adddouhao:
				f.write(',\n')
			
				

	return levelData

def del_all_data():
	fileName = word_travel_path + 'resetLayoutWord.json'
	if(os.path.exists(fileName)):
		os.remove(fileName)
	with open(word_travel_path + 'resetLayoutWord.json', 'a') as f:
			f.write('[')
			


	data = fileTool.readJsonFile(word_travel_path + "all_word_cross_data.json")

	index = 0
	adddouhao = True
	for x in data:
		index += 1
		if index == len(data):
			adddouhao = False
		levelData = del_single_word(data[x],x,adddouhao)
		data[x] = levelData

	with open(word_travel_path + 'resetLayoutWord.json', 'a') as f:
		f.write(']')

	fileTool.saveJsonFile(word_travel_path + "all_word_cross_data_no_single.json",data)

def get_grid_hash(grid, row, col):
	gridStr = ''
	for i in range(row):
		for j in range(col):
			gridStr += grid[i][j].lower()

	hlm = hashlib.md5()
	hlm.update(gridStr.encode(encoding='utf-8'))
	hashCode = hlm.hexdigest()
	return hashCode

def change_to_travel_type(levelData):
	travelData = {}
	travelData["letters"] = list(levelData["b"])
	travelData["grid"] = {}
	travelData["grid"]["column"] = levelData["c"]
	travelData["grid"]["row"] = levelData["d"]

	logList = [["." for col in range(int(levelData["c"]))] for row in range(int(levelData["d"]))]
	coordinates = []
	for x in levelData["e"]:
		letterConfig = x.split(",")
		if letterConfig[2] == "V": #竖
			index = 0
			for i in range(int(letterConfig[1]),int(letterConfig[1])+len(letterConfig[3])):
				logList[i][int(letterConfig[0])] = list(letterConfig[3])[index]
				index += 1
		else:
			index = 0
			for i in range(int(letterConfig[0]),int(letterConfig[0])+len(letterConfig[3])):
				logList[int(letterConfig[1])][i] = list(letterConfig[3])[index]
				index += 1

		travelCol = int(letterConfig[0])
		travelRow = int(letterConfig[1])
		travelType = letterConfig[2]
		travelWord = letterConfig[3]
		coorStr = []
		coorStr.append(travelWord)
		coorStr.append(travelRow)
		coorStr.append(travelCol)
		coorStr.append(travelType)
		coordinates.append(coorStr)

	travelData["grid"]["log"] = logList
	travelData["grid"]["md5"] = get_grid_hash(logList,levelData["d"],levelData["c"])

	travelData["coordinates"] = coordinates

	return travelData
 
def change_alldata_to_travel_type():
	data = fileTool.readJsonFile(word_travel_path + "all_word_cross_data_no_single.json")

	travelData = {}
	for key in data.keys():
		print key
		travelData[key] = change_to_travel_type(data[key])

	# travelData["13"] = change_to_travel_type(data["344"])
	fileTool.saveJsonFile(word_travel_path + "all_word_treval_data_step3.json",travelData)

def getLetterList(letterList,wordSourceMap):
	words = []
	for i in range(3,len(letterList)+1):
		wordList = list(itertools.permutations(letterList,i))
		for x in wordList:
			word = ""
			for y in x:
				word = word + y
			words.append(word)
    #去重操作
	wordsList = []
	for x in words:
		if x not in wordsList:
			#判断是否是 单词
			if wordSourceMap.get(x):
				print x
				wordsList.append(x)

	return wordsList

def getSourceList(sourceName,sheetName):
    ws = load_workbook(sourceName)
    sheets = ws.sheetnames
    bookSheet = ws[sheetName]

    rows = bookSheet.rows
    columns = bookSheet.columns

    return Sheet2List(bookSheet)

def readXlsx():
	wordSourceList = fileTool.readXlsxFile_List(word_travel_path + 'new1203.xlsx',sheetName = "word")
	wordSourceMap = {}
	for i in range(1,len(wordSourceList)):
		wordSource = wordSourceList[i]
		if wordSource[0] is not None:
			wordSourceMap[wordSource[1]] = wordSource[0]

	return wordSourceMap

def addExtra():
	originCrossData = fileTool.readJsonFile(word_travel_path + "all_word_treval_data_step3.json")
	print "read xlsx"
	wordSourceMap = readXlsx()
	print "finish read xlsx"
	inexxx = 1
	for x in originCrossData:
		words = getLetterList(originCrossData[x]["letters"],wordSourceMap)
		coordinates = []
		for word in originCrossData[x]["coordinates"]:
			coordinates.append(word[0])
		print '------------------------%d' % inexxx
		inexxx = inexxx + 1
		#判断是否 是正常单词
		for word in words:
			if word not in coordinates:
				if originCrossData[x].get("extra"):
					if word not in originCrossData[x]["extra"]:
						originCrossData[x]["extra"].append(word)
				else:
					originCrossData[x]["extra"] = []
					originCrossData[x]["extra"].append(word)
	fileTool.saveJsonFile(word_travel_path + "newWordCrossData_step4.json", originCrossData)

def get_question_file_name(lettersArr, wordsArr):
	letters = sorted([x.upper() for x in lettersArr])
	words = sorted([x.upper() for x in wordsArr])
	jsonFileName="{}-{}.json".format(''.join(letters), '_'.join(words))
	return jsonFileName


def get_coordinates_by_level(letters,words):
	questionFileName = get_question_file_name(letters,words)
	fileData = fileTool.readJsonFile("data/result/problem_map/"+questionFileName)
			
	if fileData and len(fileData["Solutions"])>0:
		return fileData["Solutions"][0] 
	else:
		print questionFileName
		return None
			
def check_level_need_change(resetLayoutWordList,level):
	for x in resetLayoutWordList:
		if str(level) in x.keys():
			return x[str(level) ]

	return None

def gen_word_travel_question_ts():
	lll = fileTool.readJsonFile(word_travel_path + "newWordCrossData_step4.json")
	crossDataList = []

	resetLayoutWordList = fileTool.readJsonFile(word_travel_path + "resetLayoutWord.json")

	for x in range(1,1041):
		data = {}
		data["grid"] = {}
		data["grid"]["column"] = lll[str(x)]["grid"]["column"]
		data["grid"]["md5"] = lll[str(x)]["grid"]["md5"]
		data["grid"]["row"] = lll[str(x)]["grid"]["row"]

		changeData = check_level_need_change(resetLayoutWordList,x)

		if changeData:
			coordinates = get_coordinates_by_level(changeData["letters"],changeData["words"])
			if coordinates:
				data["grid"]= coordinates
				cl = []
				for c in coordinates["coordinates"]:
					cl.append(coordinates["coordinates"][c])
				data["grid"]["coordinates"] = cl	
			else:
				data["grid"]["coordinates"] = lll[str(x)]["coordinates"]
		else:
			data["grid"]["coordinates"] = lll[str(x)]["coordinates"]
		data["letters"] = lll[str(x)]["letters"]
		if lll[str(x)].get("extra"):
			data["extra"] = lll[str(x)]["extra"]

		crossDataList.append(data)

	fileTool.write_cross_data_for_list(word_travel_path + "newWordCrossData_step5.ts",crossDataList)
			

		
#step1 将1040题按excel表的题目编号合并到一个文件里
# gen_all_data_file()

#step2 删除题目中不相连的单词
# del_all_data()

#step3 转换成 wordTravel 使用的格式的json 文件
# change_alldata_to_travel_type()

#step4 添加额外词
# addExtra()

#step5 替换不相连 题目
# gen_word_travel_question_ts()







