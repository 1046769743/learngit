# -*- coding: utf-8 -*-
import os,sys,inspect
import threading
import random
import re
import time
import string
import copy
import json

currentdir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
parentdir = os.path.dirname(currentdir)
commondir = os.path.join(parentdir, "common")
sys.path.insert(0, commondir) 

from crossword_generator import *
from common import *

OUTPUT_JSON_MAP_PATH = os.path.abspath("../data/result/problem_map")

def solve_one(questionInfo, qid):
	jsonFileName = get_question_file_name(questionInfo['letters'], questionInfo['words'])
	jsonFile = os.path.join(OUTPUT_JSON_MAP_PATH, jsonFileName)
	solutions = []
	oldSolutions = None
	if os.path.exists(jsonFile):
		oldQuestionResult = json.loads(open(jsonFile).read())
		oldSolutions = oldQuestionResult['Solutions']
		for info in oldSolutions:
			solutions.append(info['id'])
	
	solutionMap = {}
	if not oldSolutions == None:
		for info in oldSolutions:
			solutionMap[info['id']] = info

	problem = WordCrossProblem(questionInfo['words'], questionInfo['letters'], solutions)
	problem.solve()
	result = problem.log()

	newSolutions = result['Solutions']
	for info in newSolutions:
		solutionMap[info['id']] = info

	def comp_solution_area_func(a, b):
		va = int(solutionMap[a]['row']) * int(solutionMap[a]['column'])
		vb = int(solutionMap[b]['row']) * int(solutionMap[b]['column'])
		return va - vb
	keys = sorted(solutionMap, cmp = comp_solution_area_func)
	finalSolutions = []
	for sid in keys:
		finalSolutions.append(solutionMap[sid])
	result['Solutions'] = finalSolutions
	quesionOk = False
	if len(finalSolutions) > 0: 
		quesionOk = True
	f = open(jsonFile, "wb")
	f.write(json.dumps(result))
	f.close()
	return quesionOk

def solve_puzzle():
	questionDict = json.loads(open("questions.json").read())
	questionIds = sorted(questionDict.keys(), key=lambda x: int(x))

	if True:
	   qid = "48"
	   info = questionDict[qid]
	   count = 1
	   while solve_one(info, qid) == False:
	       count = count+1
	       print(count)
	       pass
	   return
	# while True:
	# 	threads = []
	# 	while len(threads) < 2: # 每次开两个线程
	# 		qid = questionIds.pop(0)
	# 		if qid != None:
	# 			#print('solve_puestion', qid)
	# 			info = questionDict[qid]
	# 			t = threading.Thread(target = solve_one, args = (info, qid, ))
	# 			t.start()
	# 			threads.append(t)
	# 		else:
	# 			break
	# 	for t in threads:
	# 		t.join()
	# 	if len(questionIds) <= 0:
	# 		print('all problem solved')
	# 		break

solve_puzzle()
