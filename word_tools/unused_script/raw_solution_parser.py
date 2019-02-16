# -*- coding: utf-8 -*-
import os
import sys
import random
import re
import time
import string
import copy
import json
import threading
import logging

def parse_problem(problemId):
	fd = open("problem_map_txt"+os.sep+"problem_"+str(problemId).zfill(4)+".txt", "r")
	resultStr = fd.read()
	indexAlpha = resultStr.find("Alphabets")
	indexExtra = resultStr.find("ExtraWords")
	resultDict = {}
	resultDict["ExtraWords"] = parse_extras(resultStr[indexExtra:-1])
	resultDict["Solutions"] = parse_solution(resultStr[0:indexAlpha])
	resultDict["Alphabets"] = parse_alphabets(resultDict['Solutions'])
	#print resultDict

	fd.close()

	json_filename = "problem_map" + os.sep + "problem_" +str(problemId).zfill(4) + ".json"
	open(json_filename, "wb").write(json.dumps(resultDict))

def parse_alphabets(solutions):
	coordinates = solutions[0]['solution']['coordinates']
	keys = coordinates.keys()
	keys = sorted(keys, key=lambda x:len(x))
	longest = keys[len(keys)-1]
	return list(longest.upper())


def parse_extras(extraStr):
	strContent = extraStr[extraStr.find(":")+1:]
	strContent =str.replace(strContent, " ", "", 100)
	extraWords = strContent.split(',')
	#print(extraWords)
	return extraWords

def parse_solution(solutionContent):
	#pattern = re.compile(r'(solution: [a-zA-Z0-9]+)=+\n[\.a-z\n]+row: \d* col:\d*\n')
	pattern = re.compile(r'(solution: [a-zA-Z0-9]+=+)\n([a-z\. \n]+)\n(row: \d* col:\d*)\n')
	matchResult = pattern.findall(solutionContent)
	def get_solution_id(strContent):
		searchResult = re.search(r'solution: ([a-zA-Z0-9]+).*', strContent)
		if searchResult != None:
			return searchResult.group(1)
	def get_row_col(gridInfoStr):
		#searchResult = re.findall(r'row:\([0-9]*)col:([0-9]*)', gridInfoStr)
		searchResult = re.findall(r'row: ([0-9]*) col:([0-9]*)', gridInfoStr)
		if searchResult != None:
			return [int(searchResult[0][0]), int(searchResult[0][1])]

	def get_solution_map(strContent, row, column):
		#print('---------')
		#print(strContent)
		rows = re.split(r'\n', strContent)
		rowList = []
		firstRowIndex = -1
		firstColumnIndex = 100000
		for row_index in range(len(rows)):
			rowStr = rows[row_index]
			rowArr = re.split(r' ', rowStr)
			rowArr = rowArr[:-1]
			foundAlphabetInRow = False
			for element_index in range(len(rowArr)):
				element = rowArr[element_index]
				if element != '.':
					foundAlphabetInRow = True
					if firstRowIndex < 0:
						firstRowIndex = row_index
					if element_index < firstColumnIndex:
						firstColumnIndex = element_index
			rowList.append(rowArr)

		grid = []
		for rowIndex in range(firstRowIndex, firstRowIndex+row): 
			rowContent = rowList[rowIndex]
			rowContent = rowContent[firstColumnIndex:firstColumnIndex+column]
			newRowContent = []
			for letter in rowContent:
				newRowContent.append(letter.upper())
			grid.append(newRowContent)
		return grid

	def create_word(allWords, wordLetters, rowIndex, colIndex, directionFlag):
		if len(wordLetters)>1:
			word = "".join(wordLetters)
			allWords[word.upper()] = [word.upper(), rowIndex, colIndex, directionFlag]

	def get_coordinates(solutionGrid, row, col):
		allWords = {}
		for rowIndex in range(row):
			startColIndex = -1
			wordLetters = []
			for colIndex in range(col):
				element = solutionGrid[rowIndex][colIndex]
				if startColIndex >=0 and element == '.':
					create_word(allWords, wordLetters, rowIndex, startColIndex, 0)
					startColIndex = -1
					wordLetters = []
					continue
				if element != '.':
					if startColIndex < 0:
						startColIndex = colIndex
					wordLetters.append(element)
			create_word(allWords, wordLetters, rowIndex, startColIndex, 0)
		
		for colIndex in range(col):
			startRowIndex = -1
			wordLetters = []
			for rowIndex in range(row):
				element = solutionGrid[rowIndex][colIndex]
				if startRowIndex >=0 and element == '.':
					create_word(allWords, wordLetters, startRowIndex, colIndex, 1)
					startRowIndex = -1
					wordLetters = []
					continue
				if element != '.':
					if startRowIndex < 0:
						startRowIndex = rowIndex
					wordLetters.append(element)
			create_word(allWords, wordLetters, startRowIndex, colIndex, 1)
		return allWords


	solutions = []
	if matchResult != None:
		for result in matchResult:
			solutionDict = {}

			solutionIdStr = result[0]
			solutionStr = result[1]
			gridInfoStr = result[2]

			solutionId = get_solution_id(solutionIdStr)
			solutionDict['id'] = solutionId

			gridInfo = get_row_col(gridInfoStr)
			row = gridInfo[0]
			column = gridInfo[1]
			solutionDict['row'] = row
			solutionDict['column'] = column

			solutionMap = get_solution_map(solutionStr, row, column)
			coordinates = get_coordinates(solutionMap, row, column)
			solutionDict['solution'] = {'grid':solutionMap, 'coordinates':coordinates}


			#print(solutionDict)
			solutions.append(solutionDict)

	return solutions

if not os.path.exists("problem_map_text"):
	print("problem_map_text not exits. programe terminated")
	sys.exit(0)

for index in range(1, 1951):
	print("parse_problem {}".format(index))
	parse_problem(index)	
