# -*- coding:utf-8 -*-

import os, time, random
import csv
import json

newRoot = "data/problem_map"

def filter_json(filename):
	jsonContent = open(filename).read()
	rootDict = json.loads(jsonContent)
	
	if rootDict.has_key("ExtraWords"):
		del rootDict['ExtraWords']
	f=open(filename, "wb")
	f.write(json.dumps(rootDict))
	f.close()

for root, dirs, files in os.walk(newRoot, topdown=False):
	for name in files:
		filename = os.path.join(root, name)
		print(filename)
		filter_json(filename)
	for name in dirs:
		print(os.path.join(root, name))
