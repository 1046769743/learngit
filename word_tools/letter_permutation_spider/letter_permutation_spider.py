# -*- coding:utf-8 -*-

from bs4 import BeautifulSoup
from lxml import html
import xml
import requests
import os, time, random
import csv
import json

letter_permutation_spilder_path = "./letter_permutation_spider/"

def get_request_data(letterStr):
	print ''
	url = "https://www.wordhelp.com/scrabble/anagrams-of/%s/?" % letterStr
	f = requests.get(url)                 #Get该网页从而获取该html内容
	soup = BeautifulSoup(f.content, "lxml")  #用lxml解析器解析该网页的内容, 好像f.text也是返回的html
	# print soup
	dataList = []
	for m in soup.find_all('table',class_ = "table table-striped res-table"):
		
		for n in m.find_all('tr'):
			data = {}
			for o in n.find_all('td',width = 140):
				for p in o.find_all('a'):
					# print p.get_text()
					data["word"] = p.get_text()
			for o1 in n.find_all('td',width = 60):
				for p1 in o1.find_all('strong'):
					data["point"] = p1.get_text()
					data["pointNum"] = int(p1.get_text()[:1])
			for o2 in n.find_all('td',class_ = "def" ):
				data["def"] = o2.get_text()
			if len(data.keys()) > 0:
				dataList.append(data)
	resultDict = { "letters": letterStr, "words": dataList }
	json_str = json.dumps(resultDict, indent=4)

	fileName = "data/result/letters_words_json/%s.json"%letterStr
	with open(fileName,"w") as json_file:
		json_file.write(json_str)	

def getLettersList():
	fileData = open(letter_permutation_spilder_path+'letters.txt', "r").read()
	skipList = fileData.split()
	# print skipList
	return skipList

# 先不用csv
def saveToCsv(mapData):
	fileName = letter_permutation_spilder_path + 'testtt.csv'
	if(os.path.exists(fileName)):
		os.remove(fileName)
	# os.mknod(fileName) 
	out = open(fileName,'a')
	csv_write = csv.writer(out,dialect='excel')
	for key in mapData.keys():
		data = [key,mapData[key]]
		csv_write.writerow(data)


def run():
	letters = getLettersList()
	for x in xrange(0,len(letters)):
		letterKey = letters[x][::2]
		print '--%d----------- %s' % (x, letterKey)
		get_request_data(letterKey)
		time.sleep(random.random()*2)

# getLettersList()


