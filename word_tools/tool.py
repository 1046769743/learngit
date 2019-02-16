# -*- coding: utf-8 -*-

import os
import sys
import getopt
import letter_permutation_spider
import gen_word
import word_travel


optlist,action_indexes = getopt.getopt(sys.argv[1:],'d',[])

element_action_values = [letter_permutation_spider.actions['values'],gen_word.actions['values'],word_travel.actions['values']]
element_hidden_actions = [letter_permutation_spider.hidden_actions,gen_word.hidden_actions,word_travel.hidden_actions]

def mergeDict(dataArry):
    data_dict = {}
    for data in dataArry:
        for key,value in data.items():
            data_dict[key] = value

    return data_dict

action_keys = letter_permutation_spider.actions['keys'] + gen_word.actions['keys'] + word_travel.actions['keys']
action_values = mergeDict(element_action_values)
hidden_actions = mergeDict(element_hidden_actions)


if len(action_indexes) and hidden_actions.has_key(action_indexes[0]):
    actions.hidden_actions[action_indexes[0]]()
    sys.exit(0)

while True:
    print ""
    print "="*30
    print "actions:"
    for i in range(0,len(action_keys)):
        action =action_values[action_keys[i]]
        print "\t",i+1,":",action['name'].decode('utf-8')
    print "\tq : quit"
    action_index = raw_input("select: ")

    print "\n action [%s]\n"%action_index
    if action_index.isdigit():
        action_index = int(action_index) - 1
        if action_index>=0 and action_index < len(action_keys):
            callback = action_values[action_keys[action_index]]['callback']
            print("start---------------")
            callback()
            print("end---------------")
    elif action_index=='q':
        sys.exit(0)
    else:
        if action_values.has_key(action_index):
            action_values[action_index]['callback']()

