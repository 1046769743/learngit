# crossword_gen
  这个工具必须的输入是questions.json 
  questions.json 每一项必须下面的格式:
  ```
	"344": {
		"letters": ["O", "R", "A", "B", "A", "D"],
		"words": ["BOAR", "ROAD", "BARD", "BOARD", "BROAD", "ABOARD", "ABROAD"]
	},
  ```

  "344" 是唯一id，这个只是在questions.json这个文件中有用。 跟data/result/problem_map 中的摆放结果文件名没有任何关系。

  letters 是这道题的字母
  words 是这些字母组成的 单词

  crossword_gen.py 会进行多线程并行计算，直到questions.json 中的所有题目都算完
