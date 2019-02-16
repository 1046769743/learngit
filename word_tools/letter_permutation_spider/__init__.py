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

	import letter_permutation_spider
	hidden_actions['zhua_bao'] = letter_permutation_spider.run
	add_action('zhua_bao','根据letters.txt抓包',letter_permutation_spider.run)

	