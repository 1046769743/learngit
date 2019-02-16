# -*- coding: utf-8 -*-

import json
import os
import sys
import demjson

MAP_PATH = "problem_map"

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

def print_problem_solution(index):
	print("{}{}problem_{}.json".format(MAP_PATH, os.sep, str(index).zfill(4)))
	fd = open("{}{}problem_{}.json".format(MAP_PATH, os.sep, str(index).zfill(4)))
	contentDict = demjson.decode(fd.read())
	solutions = contentDict['Solutions']
	for i in range(len(solutions)-1, -1, -1):
		solution = solutions[i]
		print("-------------", solution['id'])
		print(solution_str(solution))
		#print(solution['solution']['coordinates'])
	#for solution in solutions:


if len(sys.argv) < 2 :
	print("please input problem index, start from 1")
	sys.exit(0)
index = int(sys.argv[1])
print_problem_solution(index)
