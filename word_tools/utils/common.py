# -*- coding: utf-8 -*-
import os,sys

def get_question_file_name(lettersArr, wordsArr):
	letters = sorted([x.upper() for x in lettersArr])
	words = sorted([x.upper() for x in wordsArr])
	jsonFileName="{}-{}.json".format(''.join(letters), '_'.join(words))
	return jsonFileName
