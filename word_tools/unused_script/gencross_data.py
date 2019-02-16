import os
import sys
import random
import re
import time
import string
import copy
import json
import demjson
import threading
import logging

def gen_data():
	solutionMapPath = "problem_map"
	startIndex = 1
	endIndex = 1950
	allResult = {}
	filename = "CrossData.ts"
	fd = open(filename, "wb")
	fd.write("const CrossData = {\n")
	for index in range(startIndex, endIndex+1):
		problemDict = demjson.decode(open(solutionMapPath + os.sep + "problem_{}.json".format(str(index).zfill(4))).read())
		letters = problemDict['Alphabets']
		solution = problemDict['Solutions'][0]
		extra = problemDict['ExtraWords']

		rawCoordinates = solution['solution']['coordinates']
		coordinates = []
		for word in rawCoordinates:
			content = rawCoordinates[word]
			coordinates.append(content)
		random.shuffle(letters)
		result = {
				"coordinates": coordinates,
				"grid": {
					"row": solution["row"],
					"column": solution["column"],
					"log": solution['solution']['grid']
					},
				"letters": letters,
				"extra": extra
				}
		allResult[str(index)] = result
		fd.write("\"{}\" : {},\n".format(str(index), json.dumps(result)))

		print("parse problem {}".format(index))
	fd.write("}\nexport {CrossData}")

gen_data()
