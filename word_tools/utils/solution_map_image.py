# -*- coding: utf-8 -*-
import hashlib
import os
import sys
import random
import re
import time
import string
import copy
import json
import threading
import demjson
import logging
import shutil
from data import *
from PIL import Image, ImageDraw, ImageFont

def draw_problem_maps(index):
	fd = open("problem_map{}problem_{}.json".format(os.sep, str(index).zfill(4)))
	contentDict = demjson.decode(fd.read())
	solutions = contentDict['Solutions']
	for i in range(len(solutions)):
		if i >= 8: 
			break
		solution = solutions[i]
		solutionData = solution['solution']
		grid = solutionData['grid']
		row = solution['row']
		col = solution['column']
		#print(row, col)
		do_draw(grid, row, col, index, solution['id'], i)

def do_draw(grid, maxRow, maxCol, problemIndex, solutionId, solutionIndex):
	ppb = 60
	font = ImageFont.truetype("/Users/qiang.zhang/Desktop/work/App_WordCross_JS/assets/resources/font/AlteHaasGroteskBold.ttf", int(ppb))
	width = 720
	height = 600
	backgroundImage = Image.open("background.png")
	cropX = 10
	cropY = 350
	backgroundImage = backgroundImage.crop((cropX, cropY, cropX+width, cropY+height))
	img = Image.new("RGBA", (width, height), (255, 255, 255, 255))
	img.paste(backgroundImage, (0, 0), backgroundImage)
	draw = ImageDraw.ImageDraw(img)
	letterWidth = 60
	offsetX = (width - letterWidth * (maxCol))/2
	offsetY = (height - letterWidth * (maxRow))/2
	letterBgImage = Image.open("letter_bg.png")
	for rowIndex in range(len(grid)):
		row = grid[rowIndex]
		for colIndex in range(len(row)):
			letter = row[colIndex]
			if not letter == ".":
				coordX = colIndex*letterWidth + offsetX
				coordY = rowIndex*letterWidth + offsetY
				img.paste(letterBgImage, (coordX-2, coordY+6,), letterBgImage)
				draw.text([coordX, coordY], letter, fill = (0, 0, 0), font = font)
	letterBgImage = letterBgImage.resize((50, 50))
	p_path = "problem_images{}problem_{}".format(os.sep, str(problemIndex).zfill(4))
	if not os.path.exists(p_path):
		os.mkdir(p_path)
	filename = "{}{}{}.png".format(p_path, os.sep, solutionId)
	img.save(filename, "PNG")

	if solutionIndex == 0:
		shutil.copy(filename, "problem_images{}problem_{}_{}.png".format(os.sep, str(problemIndex).zfill(4), solutionId))

def draw_map(index):
	draw_problem_maps(index)

#从1开始的index
startIndex = int(sys.argv[1])
toIndex = int(sys.argv[2])
print(sys.argv[1:], startIndex, toIndex)
threads = []

for index in range(startIndex, toIndex+1):
	t = threading.Thread(target = draw_map, args=(index, ))
	t.setDaemon(True)
	t.start()
	threads.append(t)

for t in threads:
	t.join()

