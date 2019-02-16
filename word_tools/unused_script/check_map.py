# -*- coding: utf-8 -*-
import json
import os
import sys
import demjson
import hashlib
import random
from data import *

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


def get_grid_hash(grid, row, col):
	gridStr = ''
	for i in range(row):
		for j in range(col):
			gridStr += grid[i][j].lower()

	hlm = hashlib.md5()
	hlm.update(gridStr.encode(encoding='utf-8'))
	hashCode = hlm.hexdigest()
	return hashCode

def check_wrong_words(contentDict, index):
	solutions = contentDict['Solutions']
	newSolutions = []

	for i in range(len(solutions)):
		foundWrongWords = False
		solution = solutions[i]
		coordinates = solution['solution']['coordinates']
		keys = coordinates.keys()
		keys = sorted(keys, key=lambda x:len(x))
		for word in keys:
			if(len(word)<3):
				foundWrongWords = True
				break
		if not foundWrongWords:
			newSolutions.append(solution)
		else:
			print("found wrong solution: {}".format(index))

				
	contentDict['Solutions'] = newSolutions
	return contentDict

def solution_str(solution):
	strContent = "row:{} column:{} area:{}\n".format(solution['row'], solution['column'], solution['row']*solution['column'])
	grid = solution['solution']['grid']
	gridStr = ""
	for row in grid:
		for c in row:
			gridStr += '%s ' % c
		gridStr += '\n'

	strContent += gridStr
	return strContent


def convert_matrix(contentDict):
	solutions = contentDict['Solutions']

	newSolutionDict = {}
	for i in range(len(solutions)):
		solution = solutions[i]
		grid = solution['solution']['grid']
		coordinates = solution['solution']['coordinates']
		row = solution['row']
		col = solution['column']
		if row > col:
			#print(solution_str(solution))
			#print(coordinates)
			# convert grid
			newGrid = []
			for rowIndex in range(col):
				rowContent = []
				for colIndex in range(row):
					rowContent.append(grid[colIndex][rowIndex])
				newGrid.append(rowContent)
			solution['solution']['grid'] = newGrid
			solution['row'] = col
			solution['column'] = row

			#change coordinates
			newCoordinates = {}
			for key, value in coordinates.iteritems():
				newValue = [key, value[2], value[1]]
				if value[3] == 0:
					newValue.append(1)
				else:
					newValue.append(0)
				newCoordinates[key] = newValue
			solution['solution']['coordinates'] = newCoordinates

			newId = get_grid_hash(newGrid, col, row)
			solution['id'] = newId
			newSolutionDict[newId] = solution
			#change hash
			#print(solution_str(solution))
			#print(newCoordinates)

		else:
			newId = get_grid_hash(solution['solution']['grid'], solution['row'], solution['column'])
			newSolutionDict[newId] = solution

	idArray = newSolutionDict.keys()
	def sortKey(key):
		data = newSolutionDict[key]	
		return data['row'] * data['column']

	idArray.sort(key = sortKey)

	newSolutionArr = []
	for hashId in idArray:
		newSolutionArr.append(newSolutionDict[hashId])
	contentDict['Solutions'] = newSolutionArr

	return contentDict

def check_alphabets(contentDict):
	firstSoultion = contentDict['Solutions'][0]
	coordinates = firstSoultion['solution']['coordinates']
	words = coordinates.keys()
	words = sorted(words, key = lambda x:len(x))
	longestWord = words[len(words)-1]

	alphabetsArr = list(longestWord)

	for index in range(len(words)-1):
		word = words[index]
		wordLetters = list(word)
		wordLetterSet = set(wordLetters)
		for letter in wordLetterSet:
			countDelta = wordLetters.count(letter) - alphabetsArr.count(letter)
			if countDelta > 0:
				for i in range(countDelta):
					alphabetsArr.append(letter)

	secureRandom = random.SystemRandom()
	secureRandom.shuffle(alphabetsArr)
	contentDict['Alphabets'] = alphabetsArr
	return contentDict

def check_answer(contentDict, pIndex):
	solutions = contentDict['Solutions']
	answerWords = WordCrossProblemData[pIndex-1][0]
	print('xxxx == ',answerWords)
	lenAnswer = len(set(answerWords))
	rightSolutions = []

	foundWrongSolution = False
	for solution in solutions:
		coordinates = solution['solution']['coordinates']
		keys = coordinates.keys()
		lenSolutionWords = len(set(keys))	
		if lenAnswer != lenSolutionWords:
			foundWrongSolution = True
			print('-------------------------------------')
			print(pIndex, lenAnswer, lenSolutionWords)
		else:
			rightSolutions.append(solution)
	contentDict['Solutions'] = rightSolutions
	return (contentDict, foundWrongSolution)

def check_short_words(contentDict, pIndex):
	solutions = contentDict['Solutions']
	print("check_short_words: {}".format(pIndex))
	for solution in solutions:
		coordinates = solution['solution']['coordinates']
		keys = coordinates.keys()
		keys = sorted(keys, key=lambda x:len(x))
		if len(keys[0]) <= 2:
			print(pIndex, keys[0])
			break

def check_problem(index):
	#print("check_problem {}".format(index))
	fd = open("problem_map{}problem_{}.json".format(os.sep, str(index).zfill(4)))
	contentDict = demjson.decode(fd.read())
	fd.close()

	#contentDict = check_wrong_words(contentDict, index)

	#contentDict = convert_matrix(contentDict)
	#contentDict = check_alphabets(contentDict)

	#check answer
	#contentDict, foundWrongSolution = check_answer(contentDict, index)
	#if foundWrongSolution:
	#    fd = open("problem_map{}problem_{}.json".format(os.sep, str(index).zfill(4)), "wb")
	#    fd.write(json.dumps(contentDict))
	#    fd.close()
	
	#check wrong words
	# check_short_words(contentDict, index)
	check_answer(contentDict, index)


#if len(sys.argv) < 2 :
#    print("please input problem index, start from 1")
#    sys.exit(0)
#index = int(sys.argv[1])
for index in range(1, 5):
	check_problem(index)
