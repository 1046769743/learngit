# 文件夹说明
## letter_permutation_spider 文件夹
	爬虫: 抓取字母序列可以组成的有意义的单词
## data 文件夹
	计算数据和中间结果集
### problem map
	计算单词如何在二维矩阵中的摆放

	文件名规则: 字母组合-单词1_单词2_单词3_单词4.json

	单词1 2 3 4 是字母组合组成的二维矩阵中的单词


# tool.py 使用说明
## cd tool.py 文件目录下  执行python tool.py  会出现如下选项

==============================
actions:
	1 : 根据letters.txt抓包
	2 : 去掉屏蔽词和两个单词的原始数据文件,并生成新的文件
	3 : 生成词频表 并且根据词频分类 word_**w.xlsx
	4 : 竞品分析 -- wordcross
	5 : --------根据WordScapes题目，生成我们需要的题目数据 如下：--------
	6 : step1 将1040题按excel表的题目编号合并到一个文件里
	7 : step2 删除题目中不相连的单词
	8 : step3 转换成 wordTravel 使用的格式的json 文件
	9 : step4 添加额外词
	10 : step5 替换不相连 题目
	11 : --------------------------      end      -------------------------
	q : quit
select: 


说明：
1.根据letters.txt抓包 
	功能:根据letters.txt中所给的字母组合从 https://www.wordhelp.com 上抓取可用的单词信息
	数据源：letter_permutation_spider/letters.txt 目前是 词频表生成的
	输出文件：data/result/letters_words_json 中的所有文件

2.去掉屏蔽词和两个单词的原始数据文件,并生成新的文件 nohave2_new.xlsx
	功能:生成 不包含<=2字母个数 去掉pingbici_1.txt文件中单词  重置 pingbici_2.txt文件中单词词频的新文件 
	数据源： gen_word/word/cipinbiao.xlsx pm给的初始文件
	        pingbici_1.txt 必须要去掉的脏词
	        pingbici_2.txt 可以存在但是词频要调高 目前调的是 99999
	输出文件：gen_word/word/nohave_2_spip1_reset_spkip2_new.xlsx

3.生成词频表 并且根据词频分类 word_**w.xlsx
	功能：跟第2步生成的文件 生成不重复的字母序列的数组 然后对每一个字母序列重新打散排列出新的字母组合
		 例如：字母组合 abcd  重新排列：abc abd acd acb adb adc bcd bca abcd acbd ....所有>2 的组合
		 将新组合中的每一个单词 在第2步生成的文件中查找 如果存在 取它的词频 根据pm给的答案词和额外词的词频数值将其进行分类
		 如果没有 认定不是单词 跳过
		 最终生成包括 字母组合 字母个数 答案词 和 额外词的表

		 注意：由于需要对字母序列进行重新排列组合会产生大量的单词 因此此步骤 耗时较长 约为 30分钟左右
	数据源：第2步生成的文件 gen_word/word/nohave_2_spip1_reset_spkip2_new.xlsx
		   pm给的答案词和额外词分类词频的 数值
	输出文件：gen_word/word/word_**w.xlsx  **是pm给的分类词频值

4.竞品分析 -- wordcross
	功能:生成竞品题目的分析数据表供pm参考
	数据源: gen_word/CompetingGoodsAnalysis/wordscape/wordgroup_all 竞品题目数据
	输出文件：gen_word/CompetingGoodsAnalysis/wordscape/wordscape_all_analytic.xlsx
			文件中 各个字段的意思：
			json 文件名   level 等级  letters 本关有几个字母  words 本关答案词有几个
			longest_words 本关最长的单词有几个   avg_letters 本关的平均单词数

5-11：根据WordScapes题目，生成我们需要的题目数据
	6 : step1 将1040题按excel表的题目编号合并到一个文件里
	功能：竞品数据 按level 保存到一张表里 只执行一次即可
	数据源：word_treval/Wordscapes.xlsx 
	输出文件：word_treval/all_word_cross_data.json

	7 : step2 删除题目中不相连的单词
	功能：删除题目中不相连的单词
	数据源：word_treval/all_word_cross_data.json
	输出文件：word_treval/all_word_cross_data_no_single.json
	        word_treval/resetLayoutWord.json 记录需要重新计算图形的题目

	8 : step3 转换成 wordTravel 使用的格式的json 文件
	功能：将wordscape的题目格式 转换成 wordtravel 使用的格式
	数据源：word_treval/all_word_cross_data_no_single.json
	输出文件：word_treval/all_word_treval_data_step3.json

	9 : step4 添加额外词
	功能：将数据中添加需要的额外词
	数据源：word_treval/all_word_treval_data_step3.json
	输出文件：word_treval/newWordCrossData_step4.json

	10 : step5 替换不相连 题目
	功能：替换数据中不相连的题目
	数据源：word_treval/newWordCrossData_step4.json
		   word_treval/resetLayoutWord.json
	输出文件：word_treval/newWordCrossData_step5.json 最终word_treval使用的数据


