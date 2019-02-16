# -*- coding:utf-8 -*-

import os
import sys

actions={'keys':[],'values':{}}
hidden_actions = {}

def do_nothing(config):
	pass

def add_action(key, name, callback):
	actions['keys'].append(key)
	actions['values'][key] = {'name':name,'callback':callback}
	
if sys.platform=='darwin':	

	import word.gen_word

	hidden_actions['nohave2_new'] = word.gen_word.genNewWord
	add_action('nohave2_new','去掉屏蔽词和两个单词的原始数据文件,并生成新的文件',word.gen_word.genNewWord)

	hidden_actions['genCipinWord'] = word.gen_word.genCipinWord
	add_action('genCipinWord','生成词频表 并且根据词频分类 word_**w.xlsx',word.gen_word.genCipinWord)

	hidden_actions['analyticWordScape'] = word.gen_word.analyticWordScape
	add_action('analyticWordScape','竞品分析 -- wordcross',word.gen_word.analyticWordScape)