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
from data import *

WordCrossProblemData

cross_data = {} 

dataArr = []
dumplicatedArr = []

for i in range(len(WordCrossProblemData)):
	data = WordCrossProblemData[i][0]
	extra = WordCrossProblemData[i][1]
	data.sort()
	data = sorted(data, key=lambda x:len(x))
	dataStr = "_".join(data)
	dataArr.append(dataStr)
	if dataArr.count(dataStr) > 1:
		indices = [i for i, x in enumerate(dataArr) if x == dataStr]
		print(indices)
		print("dumplicate: {} {}".format(i, data))
		dumplicatedArr.append(dataStr)
print("total dumplicate num:{}".format(len(dumplicatedArr)))
#print(dumplicatedArr)
