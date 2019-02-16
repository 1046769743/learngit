# -*- coding: utf-8 -*-
#from copy import copy as duplicate
import hashlib
import os
import sys
import random
import re
import math
import time
import string
import copy
import json
import threading
import demjson
import logging

PROBLEM_MAP_PATH = "problem_map"
INPUT_RULE_RESULT_FILE = "rule_result.json"
# INPUT_RULE_RESULT_FILE = "rule_result_20180927_01.json"

def get_solution(filename):
	fd = open(filename, "r")
	content = fd.read()
	contentDict = demjson.decode(content)
	fd.close()
	solutionId = None
	for solution in contentDict['Solutions']:
		delta = abs(solution['row'] - solution['column'])
		if delta <= 2:
			solutionId = solution['id']
			break
	if solutionId == None:
		solutionId = contentDict['Solutions'][0]['id']
	return solutionId


def gen_result_json():
	fd = open("rules.txt", "r")
	ruleContent = fd.read()
	fd.close()
	skipListContent = open("skip_list.txt", "r").read()
	skipList = skipListContent.split("\n")

	findResult  = re.findall(r'(\d+)-(\d+),(\d+)\n', ruleContent)
	secureRandom = random.SystemRandom()
	result = []
	for data in findResult:
		startIndex = int(data[0])
		endIndex = int(data[1])
		problemArray = list(range(startIndex, endIndex+1))
		num = int(data[2])
		problemSet = set()
		while len(problemSet) < num:
			one = secureRandom.choice(problemArray)
			if str(one) not in skipList:
				problemSet.add(one)
		problemList = list(problemSet)
		secureRandom.shuffle(problemList)

		for pIndex in problemList:
			mapfilename = os.path.join("..", PROBLEM_MAP_PATH, "problem_{}.json".format(str(pIndex).zfill(4)))

			solutionId = get_solution(mapfilename)
			print("get_solution ",mapfilename)
			data = {
					"question_id": len(result)+1,
					"origin": pIndex,
					"solution_id": solutionId
					}
			result.append(data)
	print(len(result))
	outputFile = "rule_result.json"
	fd = open(outputFile, "wb")
	fd.write(json.dumps(result))
	fd.close()

def parse_result_to_ts_data():
	resultArr = demjson.decode(open(INPUT_RULE_RESULT_FILE).read())

	filename = "CrossData.ts"
	fd = open(filename, "wb")
	fd.write("const CrossData = {\n")
	for index in range(len(resultArr)):
		data = parse_one_question(resultArr, index, False)
		fd.write("\"{}\" : {},\n".format(str(index+1), json.dumps(data)))

	fd.write("}\nexport {CrossData}")
	fd.close()

def parse_one_question(resultArr, index, oldCrossFormat):
	result = resultArr[index]
	pIndex = result['origin']
	solutionId = result['solution_id']
	print("parse problem {} from origin: {}".format(index+1, pIndex))
	problemDict = demjson.decode(open(os.path.join("..", PROBLEM_MAP_PATH, "problem_{}.json".format(str(pIndex).zfill(4)))).read())

	letters = problemDict['Alphabets']
	solution = None
	for sdata in problemDict["Solutions"]:
		if sdata['id'] == solutionId:
			solution = sdata
			break
	if solution == None:
		print("error-------------{} {}".format(pIndex, solutionId))
	extra = problemDict['ExtraWords']
	rawCoordinates = solution['solution']['coordinates']
	coordinates = []
	for word in rawCoordinates:
		content = rawCoordinates[word]
		coordinates.append(content)
	random.shuffle(letters)
	#print(index+1, stage)
	data = {
			"coordinates": coordinates,
			"grid": {
				"row": solution["row"],
				"column": solution["column"],
				"log": solution['solution']['grid']
				},
			"letters": letters,
			"extra": extra
			}
	if oldCrossFormat:
		stage = int(math.ceil(float(index+1)/10))
		data['stage'] = stage
		data['id'] = int(index+1)
		newCoordinates = []
		for wordData in coordinates:
			wordData.append(0)
			newCoordinates.append(wordData)
		data['coordinates'] = newCoordinates

	return data

def parse_result_to_js_data():
	resultArr = demjson.decode(open(INPUT_RULE_RESULT_FILE).read())

	filename = "WordCrossData.js"
	fd = open(filename, "wb")
	#fd.write("const CrossData = {\n")
	fd.write("module.exports = {\n")
	fd.write("\"plots\" : {\n")

	print('ceshi ==== ',len(resultArr))

	for index in range(len(resultArr)):
		data = parse_one_question(resultArr, index, True)
		fd.write("\"{}\" : {},\n".format(str(index+1), json.dumps(data)))
	fd.write("}\n}\n")
	fd.close()

def update_solution_id():
	resultArr = demjson.decode(open("rule_result.json").read())
	newResultArr = []
	for index in range(len(resultArr)):
		result = resultArr[index]
		pIndex = result['origin']
		solutionId = result['solution_id']
		newResult = {
				"question_id": index+1,
				"origin": pIndex,
				"solution_id" : solutionId
				}
		newResultArr.append(newResult)
	
	open("rule_result.json", "wb").write(json.dumps(newResultArr))

def print_one_question(questionId): #questionId start from 1
	index = questionId - 1
	resultArr = demjson.decode(open(INPUT_RULE_RESULT_FILE).read())
	data = parse_one_question(resultArr, index, True)
	print(json.dumps(data))

def gen_data():
	# gen_result_json()
	# update_solution_id()
	# parse_result_to_ts_data() # wordcross 项目用的数据ts
	parse_result_to_js_data() #老项目word用到的数据格式

gen_data()
#print_one_question(26)
