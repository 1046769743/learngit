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

	import word_treval_f

	hidden_actions['word_treval_f_s'] = do_nothing
	add_action('word_treval_f_s','--------根据WordScapes题目，生成我们需要的题目数据 如下：--------',do_nothing)

	hidden_actions['gen_all_data_file'] = word_treval_f.gen_all_data_file
	add_action('gen_all_data_file','step1 将1040题按excel表的题目编号合并到一个文件里',word_treval_f.gen_all_data_file)

	hidden_actions['del_all_data'] = word_treval_f.del_all_data
	add_action('del_all_data','step2 删除题目中不相连的单词',word_treval_f.del_all_data)

	hidden_actions['change_alldata_to_travel_type'] = word_treval_f.change_alldata_to_travel_type
	add_action('change_alldata_to_travel_type','step3 转换成 wordTravel 使用的格式的json 文件',word_treval_f.change_alldata_to_travel_type)

	hidden_actions['word_treval_f_addExtra'] = word_treval_f.addExtra
	add_action('word_treval_f_addExtra','step4 添加额外词',word_treval_f.addExtra)

	hidden_actions['gen_word_travel_question_ts'] = word_treval_f.gen_word_travel_question_ts
	add_action('gen_word_travel_question_ts','step5 替换不相连 题目',word_treval_f.gen_word_travel_question_ts)

	hidden_actions['word_treval_f_e'] = do_nothing
	add_action('word_treval_f_e','--------------------------      end      -------------------------',do_nothing)


