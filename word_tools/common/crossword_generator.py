# -*- coding: utf-8 -*-
#from copy import copy as duplicate
import hashlib
import os
import sys
import random
import re
import time
import string
import copy
import json
import demjson
import logging


def get_grid_hash(grid, row, col):
	gridStr = ''
	for i in range(row):
		for j in range(col):
			gridStr += grid[i][j].lower()

	hlm = hashlib.md5()
	hlm.update(gridStr.encode(encoding='utf-8'))
	hashCode = hlm.hexdigest()
	return hashCode

class CrossWord(object):
	"""The crossword objects represents a crossword"""

	def __init__(self, cols, rows, empty = '_', maxloops = 2000, wordlist=[]):		  
		"""Initialize the crossword. Notice: This will also be used to create
		a copy of the original crossword. For this reason there is some
		wordlist-"magic" in here."""
		
		if len(wordlist) < 2:
			raise WordListError("Need at least 2 entries!")

		if cols =="auto" or rows == "auto":
			if wordlist != [] and isinstance(wordlist[0], str):
				longest = max(wordlist, key=lambda i: len(i))
				average = sum([len(w) for w in wordlist])/len(wordlist)
			#~ elif isinstance(wordlist[0], str):
				#~ longest = max(wordlist, key=lambda i: len(i))
				#~ average = sum(wordlist)/len(wordlist)
			elif wordlist != []:
				#print type(wordlist[0])
				raise WordListError("Wordlist must contain strings or tuples!")
			min_length = len(longest)
			logging.debug("'%s': %i - Average: %i" % (longest, min_length, average))
		
			size = int(((average*len(wordlist)*4)**0.5))
			if len(wordlist) > 75:
				size = int(size*0.8)
			while size <= min_length:
				size += 1
				
		if cols == "auto":
			cols = size
		if rows == "auto":
			rows = size
		logging.debug("Grid size: %ix%i" % (cols, rows))
		
		self.cols = cols
		self.rows = rows
		self.empty = empty
		self.maxloops = maxloops
		self.wordlist = wordlist
		self.placed_words = []
		self.counter = 0
		self.maxCol = 0
		self.maxRow = 0
		self.firstCol = 0
		self.firstRow = 0
		self._setup_grid_and_letters()
		
		self.score = -1

	def solution(self): 
		outStr = ""
		for r in range(self.rows):
			for c in self.grid[r]:
				outStr += '%s ' % c
			outStr += '\n'
		return outStr
		
	def _setup_grid_and_letters(self):
		"""Initialize / clear grid and letters"""
		
		## Create the grid and fill it with empty letters
		self.grid = []
		for i in range(self.cols):
			col = []
			for j in range(self.rows):
				col.append(self.empty)
			self.grid.append(col)
		
		## Create our letter-dict
		self.letters = {}
		for letter in string.lowercase: self.letters[letter]=[]
		## In "double" we'll put those coords which already are used
		# by two words (cross). So we do not check coords, that are already
		# occupied.
		self.letters["double"]=[]
		
		## Sort the wordlist by length. Words with same length will be
		# shuffled in order.
		tmplist = []
		for word in self.wordlist:
			if isinstance(word, Word):
				tmplist.append(Word(word.word))
			else:
				tmplist.append(Word(word))
		random.shuffle(tmplist)
		tmplist.sort(key=lambda i: len(i.word), reverse=True)
		self.wordlist = tmplist
 
	def compute_crossword(self, rounds=2, best_of=3, force_solved=False):
		"""Compute possible crosswords
		
		-- rounds: How often sould be tried to place a word? (Default: 2)
		-- best_of: Creates the given number of crosswords and keeps the 
			crossword with the best score (Default: 3)
		-- force_solved Generate grids until every word from the wordlists
			fits. (Default: False).
		"""
		
		copy = CrossWord(self.cols, self.rows, self.empty, self.maxloops, self.wordlist)
		
		best_score = 0
		count = 0

		solved = False
 
		while (count<=best_of-1 and not force_solved) or (force_solved and not solved):
			self.counter += 1
			logging.debug("Round %i" % count)

			score = 0
			copy.placed_words = []
			copy._setup_grid_and_letters()

			## Try to fit all the words from the wordlist onto the grid
			x = 1
			while x < rounds:
				for word in copy.wordlist:
					if word not in copy.placed_words:
						#~ raw_input()
						word_score = copy._place_word(word)
						score += word_score
				x += 1

			## Check if the copy-crossword is "better" than the original. 
			if (len(copy.placed_words) >= len(self.placed_words) and score >= best_score) or len(copy.placed_words) > len(self.placed_words):
				self.placed_words = copy.placed_words
				self.wordlist = copy.wordlist
				self.grid = copy.grid
				self.letters = copy.letters
				self.cols = copy.cols
				self.rows = copy.rows
				best_score = score
			
			## If all words are on the list the crossword ist "solved"
			if len(copy.placed_words) == len(copy.wordlist):
				solved = True
			else:
				solved = False
				
			count += 1
			
			if force_solved and count >= self.maxloops:
				raise MaxLoopError("Could not solve the crossword within %i tries" % self.maxloops)
		
		self.score = best_score

		maxRow=0
		maxCol=0
		firstRow = -1
		firstCol = 100000
		for r in range(self.rows):
			rowContainLetter = False
			for col, c in enumerate(self.grid[r]):
				if c != self.empty:
					rowContainLetter = True
					if col>=maxCol:
						maxCol = col
					if col < firstCol:
						firstCol = col
			if rowContainLetter:
				if r>=maxRow:
					maxRow = r
				if firstRow <0:
					firstRow = r
		self.maxCol = maxCol
		self.maxRow = maxRow
		self.firstRow = firstRow
		self.firstCol = firstCol

		return best_score
 
	def _get_possible_coords(self, word):
		"""Generates a list of possible coords.
		
		Any cell containing a letter of the world will be saved as a possible hit
		if the word would fit at that position without leaving the grid-bounds.
		Additional checking is done later.
		"""

		coordlist = []
		
		## optimizations
		letters = self.letters
		cols = self.cols
		rows = self.rows
		word_str = word.word
		word_length = len(word_str)
		_get_score = self._get_score
		
		letterpos = -1
		#~ for letterpos, letter in enumerate(word.word): ## Enumerate seems to be slower sometimes
		for letter in word_str:
			letterpos += 1
			
			try:
				coords = letters[letter]
			except KeyError:
				coords = []
			
			for col, row in coords:
				## VERTICAL
				if row - letterpos > 0: 
					if ((row - letterpos) + word_length) <= rows: 
						score = _get_score(col, row - letterpos, 1, word)
						if score:
							coordlist.append((col, row - letterpos, 1, score))
				
				## HORIZONTAL
				if col - letterpos > 0:
					if ((col - letterpos) + word_length) <= cols: 
						score = _get_score(col - letterpos, row, 0, word)
						if score:
							coordlist.append((col - letterpos, row, 0, score))
			
		## The same trick as in the '_randomize_wordlist' methode:
		# The list needs to be sorted (this time by score) but coords
		# with the same score may be shuffled and will lead to 
		# different crosswords each time.
		random.shuffle(coordlist)
		coordlist.sort(key=lambda i: i[3], reverse=True)
		return coordlist
		 
	def _place_word(self, word): 
		"""Put a word onto the grid.
		
		The first word will be put at random coords, the following words
		will be placed by match-score."""
	
		placed = False
		count = 0
		score = 0
 
		if len(self.placed_words) == 0: 
			while not placed and count <= self.maxloops:
				## Place the first word at fixed coords
				vertical, col, row = random.randrange(0, 2), 1, 1
				
				## Place the first word in the middle of the grid
				if vertical:
					col = int(round((self.cols + 1) / 2, 0))
					row = int(round((self.rows + 1) / 2, 0)) - int(round((len(word.word) + 1) / 2, 0))
					if row+len(word.word) > self.rows:
						row = self.rows - len(word.word) + 1
				else:
					col = int(round((self.cols + 1) / 2, 0)) - int(round((len(word.word) + 1) / 2, 0))
					row = int(round((self.rows + 1) / 2, 0))
					if col+len(word.word) > self.cols:
						col = self.cols - len(word.word) + 1

				## Random place the first word
				#~ col = random.randrange(1, self.cols + 1)
				#~ row = random.randrange(1, self.rows + 1)
				
				if self._get_score(col, row, vertical, word): 
					placed = True
					self._write_word(col, row, vertical, word)
					return 0
				count += 1
		else:
			coordlist = self._get_possible_coords(word)
			try: 
				col, row, vertical, fit_score = coordlist[0]
			except IndexError: 
				## If there are no coords, don't place the word and
				## return 0 (score)
				return 0

			score += fit_score
			self._write_word(col, row, vertical, word)
			
		if count >= self.maxloops:
			raise MaxLoopError("Maxloops reached - canceling (Counter: %i, Word: %s)" % (count, word.word))
 
		return score
 
	def _get_score(self, col, row, vertical, word):
		"""Calculate the placement-score of a word for the given coords
		
		Return:
		-- 0 No coord fits
		-- 1 coord fits - but no cross
		-- n n-1 crosses"""
		
		## optimizations
		empty = self.empty
		_is_empty = self._is_empty
		_read_cell = self._read_cell
		grid = self.grid
		#~ def _is_empty(col, row):
			#~ try: 
				#~ return grid[col-1][row-1] == empty
			#~ except IndexError:
				#~ pass
			#~ return False
		
		if col < 1 or row < 1:
			return 0
 
		score = 1
		letterpos = 0
		lastletter = empty
		
		#~ for letterpos, letter in enumerate(word.word):	## Enumerate is much(!) slower
		for letter in word.word:
			letterpos += 1
			
			try:
				active_cell = grid[col-1][row-1]#_read_cell(col, row)
			except IndexError:
				return 0
			
			## Still not ideal, but this prevents the code from placing
			# a word like "nose" over an already placed word like "nosebear"!
			# This is quite a big issue - so this part really should kept.	
			#
			# Another approach would be, to check for each cell if it
			# already contains a letter, which is written in the same
			# direction as our word. e.g.:
			# The active_cell holds an 'e', also our word has an 'e'.
			# If the 'e' of the active_cell belongs to a vertical word 
			# and our word is also going to be placed vertically, a match
			# is not possible as we would overwrite the old world.
			# If the active_cell belongs to a horizontal word, a cross
			# would be possible. The downside of this approach: We'd
			# need an additional dict/list for that info, it would be slower
			if lastletter != empty and active_cell != empty:
				return 0
			lastletter = active_cell
			
			## In words: If the letter of the current cell does not
			# match the current letter of our word, the word doesn't
			# fit!
			if active_cell != empty and active_cell != letter:
			#~ if active_cell != empty and letterpos != matching_letter:	## This will disallow words to be overwritten but it will also disallow multiple matches within one word
				return 0
			elif active_cell == letter:
				score += 1
			
			
			#
			# Check for neighbours
			#
			if vertical:
				## Only check for non-crosses
				if active_cell != letter: 
					# right
					if not _is_empty(col+1, row): 
						return 0
 
					# left
					if not _is_empty(col-1, row): 
						return 0
 
 
				## Only check first and last letter in vertical mode
				# for top/bottom neighbours. 
				if letterpos == 1: 
					if not _is_empty(col, row-1):
						return 0
 
				if letterpos == len(word.word): 
					if not _is_empty(col, row+1): 
						return 0
			else: 
				## Only check for non-crosses
				if active_cell != letter:
					# top
					if not _is_empty(col, row-1): 
						return 0
 
					# bottom
					if not _is_empty(col, row+1): 
						return 0
 
				## In horizontal mode only the first and last letter
				# are not allowed to have horizontal neighours
				if letterpos == 1: 
					if not _is_empty(col-1, row):
						return 0
 
				if letterpos == len(word.word): 
					if not _is_empty(col+1, row):
						return 0

			if vertical: 
				row += 1
			else: 
				col += 1
 
		return score
 
	def _write_word(self, col, row, vertical, word): 
		"""Write a word to the grid and add it to the placed_words list"""
		
		word.col = col
		word.row = row
		word.vertical = vertical
		#~ if word.word in self.placed_words:
			#~ raise Exception("Word '%s' two times in the crossword!!" % word)

		self.placed_words.append(word)

		for letter in word.word:
			#~ self.cells.append((col, row, vertical))
				
			self._write_cell(col, row, letter)
			if vertical:
				row += 1
			else:
				col += 1
		return
 
	def _write_cell(self, col, row, letter):
		"""Set a cell on the grid to a given letter"""
		
		try:
			if not (col, row) in self.letters[letter]:
				self.letters[letter].append((col, row)) 
			else:
				## Remove coords from the list, if they already
				# contain a cross. This way we do less double-checking.
				self.letters[letter].remove((col, row)) 
				self.letters["double"].append((col, row)) 
		except KeyError:
			self.letters[letter] = []
			self.letters[letter].append((col, row))
		
		self.grid[col-1][row-1] = letter
		
	def _read_cell(self, col, row):
		"""Get the content of a cell"""
		
		return self.grid[col-1][row-1]
 
	def _is_empty(self, col, row):
		"""Check if a given cell is empty"""
		
		try:
			return self.grid[col-1][row-1] == self.empty
		except IndexError:
			pass
		return False

	def _number_words(self): 
		"""Orders the words and applies numbers to them
		
		Words starting at the same cell will get the same number (e.g.
		'ask' and 'air' would become 1-across and 1-down.)
		"""
	
		self.placed_words.sort(key=lambda i: (i.col + i.row))
		
		
		across_count, down_count = 1, 1
		
		ignore_num = []
		
		for word in self.placed_words:
			if word.number == None:
				if word.vertical:
					while across_count in ignore_num:
						across_count +=1
					word.number = across_count
					across_count +=1
				else:
					while down_count in ignore_num:
						down_count +=1
					word.number = down_count
					down_count +=1
					
				## Check if any other word starts at the same coords
				# in that case apply the same number to that word
				for word2 in self.placed_words:
					if word2.col == word.col and word2.row == word.row and word2 is not word:
						word2.number = word.number
						ignore_num.append(word.number)

class Word(object):
	def __init__(self, word=None, clue=None):
		self.word = re.sub(r'\s', '', word.lower())
		#self.clue = clue
		self.length = len(word) ## Much faster than asking for len(word)

		self.row = None
		self.col = None
		self.vertical = None
		self.number = None
		
		## Used if the word is a solution-field (colored)
		self.solution = False
		self.solution_char = None
	
	def __len__(self):
		print("Please use len(word.word) to ask for the length of the word - this is much faster")
		return len(self.word)

class WordCrossProblem(object):
	#oldSolutions 是旧解决方案的md5 列表
	def __init__(self, wordList, letters, oldSolutions):
		self.result = {};
		self.wordList = wordList
		self.letters = letters
		self.oldSolutions = oldSolutions

	def solve(self):
		result = self.result
		word_list = self.wordList
		for i in range(20):
			cwd = CrossWord(50, 50, '.', 9999, word_list)
			rounds = 3
			bestof = 10

			cwd.compute_crossword(rounds=rounds, best_of=bestof, force_solved = False)
			row = cwd.maxRow - cwd.firstRow + 1
			col = cwd.maxCol - cwd.firstCol + 1
			if abs(row - col) <=3 and \
				len(cwd.placed_words) > 0 and \
				len(cwd.placed_words) == len(word_list):
				solution = self.gen_solution_dict(cwd)
				if solution != None:
					sid = solution['id']
					if not sid in self.oldSolutions:
						result[sid] = solution
						self.oldSolutions.append(sid)
	def create_word(self, allWords, wordLetters, rowIndex, colIndex, directionFlag):
		if len(wordLetters)>1:
			word = "".join(wordLetters)
			flag="V"
			if directionFlag == 0:
				flag = "H"
			allWords[word.upper()] = [word.upper(), rowIndex, colIndex, flag]

	def get_coordinates(self, solutionGrid, row, col):
		allWords = {}
		for rowIndex in range(row):
			startColIndex = -1
			wordLetters = []
			for colIndex in range(col):
				element = solutionGrid[rowIndex][colIndex]
				if startColIndex >=0 and element == '.':
					self.create_word(allWords, wordLetters, rowIndex, startColIndex, 0)
					startColIndex = -1
					wordLetters = []
					continue
				if element != '.':
					if startColIndex < 0:
						startColIndex = colIndex
					wordLetters.append(element)
			self.create_word(allWords, wordLetters, rowIndex, startColIndex, 0)
		
		for colIndex in range(col):
			startRowIndex = -1
			wordLetters = []
			for rowIndex in range(row):
				element = solutionGrid[rowIndex][colIndex]
				if startRowIndex >=0 and element == '.':
					self.create_word(allWords, wordLetters, startRowIndex, colIndex, 1)
					startRowIndex = -1
					wordLetters = []
					continue
				if element != '.':
					if startRowIndex < 0:
						startRowIndex = rowIndex
					wordLetters.append(element)
			self.create_word(allWords, wordLetters, startRowIndex, colIndex, 1)
		return allWords

	def gen_solution_dict(self, wordSolution):
		maxRow = wordSolution.maxRow
		maxCol = wordSolution.maxCol
		startCol = wordSolution.firstCol
		startRow = wordSolution.firstRow
		data = {}
		grid = wordSolution.grid
		newGrid = []
		gridRow = maxRow - startRow + 1
		gridCol = maxCol - startCol + 1
		if gridRow <= gridCol:
			for rowIndex in range(startRow, maxRow+1):
				rowData = []
				for colIndex in range(startCol, maxCol+1):
					element = grid[rowIndex][colIndex]+''
					rowData.append(element.upper())
				newGrid.append(rowData)
		else:
			for rowIndex in range(startCol, maxCol+1):
				rowData = []
				for colIndex in range(startRow, maxRow+1):
					element = grid[colIndex][rowIndex]+''
					rowData.append(element.upper())
				newGrid.append(rowData)

			tmp = gridRow
			gridRow = gridCol
			gridCol = tmp
		if gridRow > 10 or gridCol > 12:
			return None
		data['row'] = gridRow
		data['column'] = gridCol
		data['id'] = get_grid_hash(newGrid, gridRow, gridCol)
		coordinates = self.get_coordinates(newGrid, gridRow, gridCol)

		keys = coordinates.keys()
		keys.sort()
		keys = sorted(keys, key=lambda x:len(x))

		words = []
		for word in wordSolution.placed_words:
			words.append(word.word.upper())
		words.sort()
		words = sorted(words, key = lambda x:len(x))
		keyStr = "_".join(keys)
		wordStr = "_".join(words)
		if wordStr != keyStr:
			print("{} {}".format(wordStr, keyStr))
			return None

		data['coordinates'] = coordinates
		return data

	def description(self):
		keys = self.result.keys()
		result = self.result

		def sortKey(key):
			oneResult = result[key]	
			return oneResult['row'] * oneResult['column']

		keys.sort(key = sortKey)

		resultDict = {}
		solutions = []
		for key in keys:
			solutionDict = self.result[key]
			solutions.append(solutionDict)

		resultDict['Solutions'] = solutions

		#get needed alphabets list
		words = sorted(self.wordList, key=lambda x:len(x))
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
		resultDict['Alphabets'] = alphabetsArr

		return resultDict

				
	def log(self):
		resultDict = self.description()
		return resultDict

