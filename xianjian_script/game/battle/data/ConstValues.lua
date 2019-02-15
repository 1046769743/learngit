Fight = Fight or {}
--===========================================================================================
--                     战斗系统常量、枚举
--===========================================================================================
Fight.gameStep={
    load = 1,
    wait = 2,
    prepare =3,
    surprised = 4,
    move = 5,
    meet = 6,
    battle = 7,
    result = 8,
}

-- 战斗模式
Fight.gameMode_pve = 1
Fight.gameMode_gve = 2
Fight.gameMode_pvp = 3
Fight.gameMode_gvg = 4

-- 回合模式
Fight.roundModel_normal = 1 -- 两阵营交替攻击（每方每个人一次攻击机会）
Fight.roundModel_semiautomated = 2 -- 两阵营交替攻击（自动释放小技能手动释放大招）
Fight.roundModel_switch = 3 -- 两阵营单人交替攻击（自动释放小技能手动释放大招）


Fight.cameraWay = -1
Fight.doubleGameSpeed = 1.5     --双倍游戏速度
Fight.thirdGameSpeed = 2        --三倍游戏速度

-- 战斗结果
Fight.result_none = 0       --还没出结果
Fight.result_win = 1        --胜利 
Fight.result_lose = 2       --失败
Fight.result_tied = 3       -- 平局(暂时没用到)
Fight.result_handOut = 4       -- 主动退出

-- 胜利条件
Fight.levelWin_killAll =  1     -- 全部击杀
Fight.levelWin_timeLimit = 2    -- 达到规定时间
Fight.levelWin_killSpec = 3     -- 杀死特定的怪物

Fight.enterSpeed = 20       --入场速度

Fight.moveType_g = 2 -- 重力加速度
-- 角度计算
Fight.radian_angle = 180/math.pi

---------------- 位置相关 ------------------
--x轴的缩放系数
Fight.screenScaleX = 1 
-- 打击点的位置
Fight.hit_position = 1/2

Fight.attackKeepDistance = 100  --攻击保持距离

Fight.drop_distance = 100 -- 掉落距离
Fight.initYpos_1 = 340      --第一条线的位置
Fight.initYpos_2 = 500      --第二条线的位置
Fight.initYpos_3 = 420          -- 中间线
Fight.initYpos1Scale = 0.96  --在最里面的人的scale 是0.8
--计算视图的斜率
Fight.initScaleSlope = (Fight.initYpos_2 - Fight.initYpos_1 ) /(1-Fight.initYpos1Scale)

Fight.wholeScale = 1.0    --整体的缩放

Fight.position_xdistance = 125  --站位  x的间隔
Fight.position_middleDistance = 150     --第一个人离中线距离
--当屏幕宽度小于1024的时候  这个offset变成50 尽量让出边的距离少些
Fight.position_offset = 60

--排队离中线的位置
Fight.position_queneDistance = 180
Fight.zorder_front = 200    --最上层的zorder 偏移
Fight.zorder_blackScreen = 800  --黑屏图层
Fight.zorder_blackChar = 1200       --黑屏时人物的zorder
Fight.zorder_health = 20            --角色血条相对角色的层级(血条加在角色身上)
Fight.zorder_formation = -100 --布阵特效的zorder
---------------- 位置相关 ------------------
 
-- 玩家状态
Fight.state_show_yuyin = 1 -- 语音
Fight.state_show_zhengchang = 2 --正常
Fight.state_show_jingyin = 3 --静音
Fight.state_show_zidong = 4 -- 自动
Fight.state_show_lixian = 5 -- 离线(暂离)
Fight.state_show_yongli = 6 --永离

-- 一个阵营最多的人数
Fight.maxCampNums = 6 
--最大40回合
Fight.maxRound = 40
--试炼 金币试炼的最大回合数
Fight.trialCoinMaxCoin = 10
-- 仙界对决最大回合数
Fight.crosspeakMaxRound = 20
--===========================================================================================
--                     frame时间相关 
--===========================================================================================
--初始化动画播放速度
Fight.armaturePlayerSpeed = GameVars.ARMATURERATE/60 
Fight.armatureUpdateScale = 1/ GameVars.ARMATURERATE  
--帧率时间
Fight.frame_time = Fight.armatureUpdateScale

Fight.moveMinSpeed = 30
Fight.moveFrame = 15

Fight.attackSignFrame = 15  --第一次集火等待时间
--自动战斗帧数 回合前是 20秒 回合中是10秒
Fight.autoFightFrame1 = 30* GameVars.GAMEFRAMERATE 
Fight.autoFightFrame2 = 30* GameVars.GAMEFRAMERATE 
-- 回合前布阵时间
Fight.beforeRoundFrame = 30* GameVars.GAMEFRAMERATE
-- 回合后等待玩家放技能时间
Fight.afterRoundFrame = 24 --3*GameVars.GAMEFRAMERATE

Fight.combHandleFrame = 2 * GameVars.GAMEFRAMERATE   --连击操作时间

-- 巅峰竞技场回合前换人时间
Fight.crossPeakChangeFrame = 20* GameVars.GAMEFRAMERATE
-- 巅峰竞技场布阵时间
Fight.crossPeakSkillFrame = 20* GameVars.GAMEFRAMERATE
-- 巅峰竞技场站前准备时间
Fight.crossPeakSureFrame = 8 * GameVars.GAMEFRAMERATE
-- 巅峰竞技场掉线后布阵及准备时间
Fight.crossPeakLineOffFrame = 2 * GameVars.GAMEFRAMERATE
-- 仙界对决bp选伙伴、法宝时间间隔
Fight.crossPeakbpFrame = 8 * GameVars.GAMEFRAMERATE
-- 战前上下人阶段
Fight.crossPeakBeforeChangeFrame = 20 * GameVars.GAMEFRAMERATE
-- 机器人bp时间
Fight.crossPeakRobotBPFrame = 3 * GameVars.GAMEFRAMERATE
-- 共闯秘境神力选择时间
Fight.spiritPowerFrame = 99 * GameVars.GAMEFRAMERATE
-- 切换回合时间
Fight.roundSwitchFrame = 15
-- 切换下一波的时间
Fight.waveSwitchFrame = 10
 --杀敌后的延时帧
Fight.killEnemyFrame= 30
-- 入场间隔
Fight.enterInterval = 20
-- 六界意识夺宝玩法怪物移动时间间隔
Fight.monsterMoveFrame = 50

-- 车轮战刷怪时间
Fight.monsterRefreshFrame = 50

-- 击飞的死亡延时时间
Fight.dieDelayFrame = 2 * GameVars.GAMEFRAMERATE 
--===========================================================================================
--                     战斗内常量、枚举 
--===========================================================================================
Fight.camp_1 = 1 -- 阵容1
Fight.camp_2 = 2 -- 阵容2

Fight.pvp_init_hp_add = 50 -- 竞技场初始化血量增益

Fight.crosspeak_init_hp_add = 80 -- 巅峰竞技场初始化血量增益

-- 子弹类型
Fight.bulletType_forward = 0 -- 正向（攻击者到受击者）
Fight.bulletType_backward = 1 -- 反向（受击者到攻击者）

-- 死亡效果
Fight.diedType_disappear = 0    --直接死亡
Fight.diedType_alpha = 1        --透明度闪现下降死亡 
Fight.diedType_alphades = 2     --透明度下降死亡
Fight.diedType_delayalphades = 3     --加了延迟的透明度下降死亡（击飞的方式倒地的要躺一会..）
--出场方式
Fight.enterType_stand = 0   --原地出现（不播入场动作）
Fight.enterType_runIn = 1  --跑进来
Fight.enterType_inAction = 2 -- 原地播入场动作
Fight.enterType_summon = 3  --召唤
Fight.enterType_gate = 4 --传送门出来

--虚弱状态的血量百分比
Fight.weekHpPercent = 0.3
--最多技能数量是 8 个 1-3
Fight.maxSkillNums = 8

-- 技能index（普攻、小技能、大招）
Fight.skillIndex_normal = 1
Fight.skillIndex_small = 2
Fight.skillIndex_max = 3
Fight.skillIndex_passive = 4
Fight.skillIndex_artifact = 20 -- 神器技能的index，自定义
Fight.skillIndex_spirit = 21 -- 神力技能的index，自定义

-- 神器技能使用类型分类
Fight.atSkill_applyType_auto = 0 -- 调用自动释放类型
Fight.atSkill_applyType_manual = 1 -- 玩家手动使用

-- 人物类型职业1攻 2防 3辅 4小怪 5boss  6中立 、7 障碍物 (不显示血条)
Fight.profession_atk = 1
Fight.profession_def = 2
Fight.profession_sup = 3
Fight.profession_monster = 4
Fight.profession_boss = 5
Fight.profession_neutral = 6
Fight.profession_obstacle = 7
-- 自定义的职业类型，表中不存在！！！ --
Fight.profession_lattice = 100
-- 自定义的职业类型，表中不存在！！！ --

-- 定义男女
Fight.sex_male = 1
Fight.sex_female = 2

Fight.talkTip_time = 60 --默认停留时间
-- 敌方角色弹对话气泡时机tip
Fight.talkTip_beforeRound = 1 --回合开始前
Fight.talkTip_afterRound = 2 --回合结束时
Fight.talkTip_beforeSkill = 3 --技能开始前
Fight.talkTip_afterSkill = 4 --技能结束后
Fight.talkTip_enterEnd = 5 --入场结束后
Fight.talkTip_onDied = 6 --死亡时
Fight.talkTip_OnTipEnd = 7 --剧情播放完
Fight.talkTip_onKill = 8 --击杀某对象
Fight.talkTip_onHp = 9 --血量变化

-- 攻击类型
Fight.atkType_wu = 1
Fight.atkType_fa = 2
Fight.atkType_pure = 3 --纯粹伤害，用于处理某些特殊伤害，此接口不开放给策划***

------------- 怒气相关 ---------------
Fight.energy_entire = "entire"
Fight.energy_piece = "piece"
Fight.energy_rate = "rate"

-- 巅峰竞技场首回合后攻击方加怒气点数
Fight.energy_add_by_crosspeak = 1
-- energyCost_type
Fight.energyC_normal = 0 -- 怒气消耗类型（普通）
Fight.energyC_reduce = 1 -- 怒气消耗类型 (被减少 )
Fight.energyC_add = 2 -- 怒气消耗类 (被增加 )

Fight.maxEntireEnergy = 10 -- 最大整怒气点数
Fight.maxPieceEnergy = 5 -- 最大散怒气点数
Fight.maxP2E_Rate = 3 -- 最大怒气转换率

Fight.energyExtreme = 9 --角色最大怒气点数

Fight.waveEnergyResume = 0 -- 进入下一波恢复能量
Fight.hpToEnergyRatio = 1.2 -- 一管血对应的恢复怒气比例
Fight.initialEnergy_pvp = 0 -- pvp初始怒气值
Fight.initialEnergy_pve = 0 -- pve初始怒气值

Fight.beHitedEnergyDefault = 0 -- 受击增长的固定怒气值

Fight.beHitedEnergy = {
	[Fight.profession_atk] = 0,
	[Fight.profession_def] = 0,
	[Fight.profession_sup] = 0,
}

-- Fight.killEnergyResume = 1 -- 拿人头 奖励怒气

-- Fight.bossHpAiEnergyResume = 1 -- boss打掉一管血获得的怒气值

-- Fight.firstRoundPVPEnergy = 3 -- pvp首回合怒气
-- Fight.firstRoundPVEEnergy = 0 -- pve首回合怒气
-- Fight.roundEnergy = 1-- 每回合开始的怒气
-- Fight.roundEnergyDiff = 1-- 每回合怒气公差
-- Fight.roundEnergyMax = 5-- 每回合恢复怒气最大值

Fight.changeEleEnergyCost = 1-- 换灵怒气消耗
Fight.changeEleMaxTimes = 1-- 可换灵次数

-- 通用分人按流程走的内容 --
-- 流程枚举
Fight.p_roundStart = 1 -- 回合前
Fight.p_roundEnd = 2 -- 回合后
-- 一定要注意不要用错    PR process
Fight.process_relive = "PRRelive" -- 回合前复活
Fight.process_treasure = "PRTreasure" -- 回合前换法宝
Fight.process_myRoundStart = "PRMyRoundStart" -- 回合前技能事件
Fight.process_enemyRoundStart = "PREnemyRoundStart" -- 敌方回合前事件

-- 回合后 PRE process_end
Fight.process_end_treasure = "PRETreasure" -- 回合后法宝（变身）
Fight.process_end_myRoundEnd = "PREMyRoundEnd" -- 我方回合后
Fight.process_end_enemyRoundEnd = "PREEnemyRoundEnd" -- 敌方回合后
-- 通用分人按流程走的内容 --

Fight.artifact_roundStart = 1
Fight.artifact_roundEnd = 2
------------- 怒气相关 ---------------

--正常英雄是在线的
Fight.lineState_lineOn = "1"
Fight.lineState_lineOff = "0"
-- 类型
Fight.modelType_heroes = 1 -- 英雄
Fight.modelType_missle = 2 -- 子弹
Fight.modelType_effect =3  -- 特效
Fight.modelType_shade = 4 -- 影子
Fight.modelType_piece = 5 -- 残片
Fight.modelType_treasure = 6 -- 法宝
Fight.modelType_drop = 7 -- 掉落
Fight.modelType_artifact = 8 -- 神器

-- 战斗人的类型
Fight.people_type_common = 1    -- 玩家
Fight.people_type_robot = 2     -- 机器人(策划配置数据) 智能AI
Fight.people_type_system = 3    -- 被邀请的玩家
Fight.people_type_watcher = 5   -- 观看玩家

Fight.people_type_summon = 10   -- 召唤物
Fight.people_type_monster = 11  -- 小怪
Fight.people_type_boss = 12     -- boss
Fight.people_type_npc = 13      -- npc

-- 战斗时机
Fight.chance_justNow = 0            --立即执行 
Fight.chance_roundStart = 1         --1表示我方回合前
Fight.chance_atkStart = 2           --2表示我攻击前
Fight.chance_atkend = 3             --3表示我攻击后
Fight.chance_roundEnd = 4           --4表示我方回合后
Fight.chance_toStart = 5            --5表示敌方回合前,
Fight.chance_defStart = 6           --6表示我受击时,
Fight.chance_toEnd = 7              --7表示敌方回合后,
Fight.chance_propChange = 8         --8代表属性变化时判定, 
Fight.chance_onDied = 9             --9表示按照角色选择枚举死亡时判定
Fight.chance_onKillEnemy = 11       --11表示当杀死敌人时判定,只对击杀着
Fight.chance_onCheckAttack = 12     --当进行攻击判定时
Fight.chance_onHeroWillDied = 13    --当有英雄将要死亡时 {camp,chance,defender,damage}
Fight.chance_onOneBeUseBuff = 14    --14当有人被作用buff时
Fight.chance_onHeroRealWillDied = 15 --15英雄真正要死亡时

--文字表现对应的帧数
Fight.wenzi_nuqi = 12           --怒气文字特效帧数
Fight.wenzi_jisha = 21          --击杀文字特效帧数
Fight.wenzi_juejijihuo = 22          --绝技激活文字特效帧数
Fight.wenzi_gedang = 28          --格挡文字特效帧数
Fight.wenzi_lunkong = 29        --轮空
Fight.wenzi_zhugong = 30        --助攻文字特效帧数
Fight.wenzi_shiwu = 31          --技能失误
Fight.wenzi_noAction = 32          --无法行动
Fight.wenzi_jishanuqi = 33          --击杀怒气
Fight.wenzi_zhugongnuqi = 34          --助攻怒气
Fight.wenzi_nuqijijihuo= 35         --怒气仙术激活
Fight.wenzi_chongzhigongji = 37         --重置行动
Fight.wenzi_jianglinuqi = 38         --奖励怒气
Fight.wenzi_random1 = 44             -- 随机目标敌方
Fight.wenzi_random2 = 50             -- 随机目标我方
Fight.wenzi_fabaojihuo = 46         --激活法宝
Fight.wenzi_dikang = 68         --抵抗
Fight.wenzi_mianyi = 69         -- 对于buff的免疫


--===========================================================================================
--                     action定义
--===========================================================================================
--记录人物运动状态
Fight.state_stand= "stand"
Fight.state_move= "move"
Fight.state_jump= "jump"

Fight.actions = {
    action_stand = "stand",
    action_stand2 = "stand2",   --防守状态的站立

    action_standWeek = "standWeek" ,        --虚弱战力

    action_stand2Start = "stand2Start" ,    --防守站立开始

    action_readyStart = "readyStart", --攻击准备开始
    action_readyLoop = "readyLoop", --攻击准备循环

    action_standSkillStart = "standSkillStart",     --大招待机
    action_standSkillLoop = "standSkillLoop",     --大招待机循环

    action_run = "run",
    action_race2 = "race2",
    action_race3 = "race3" ,
    action_attack1= "attack1",
    action_attack2= "attack2",
    action_attack3= "attack3",
    action_attack4= "attack4",  --针对特殊技做的表演 
    action_blow1= "blow1",
    action_blow2= "blow2",
    action_blow3= "blow3",
    action_win= "win",
    action_die= "die",
    action_hit= "hit",
    action_hitedWeek= "hitedWeek",  --虚弱受击
    action_walk= "walk",
    action_treaOver = "treaOver",
    action_treaOn = "treaOn",       --法宝上身
    action_treaOn2 = "treaOn2",        --小技能上身
    action_treaOn3 = "treaOn3",         --大招上身
    action_giveOutBS = "giveOutBS",     --祭出B开始
    action_giveOutBM = "giveOutBM",     --祭出B循环
    action_giveOutBE = "giveOutBE",     --祭出B结束

    action_inAction = "inAction",     --登场

    action_original = "original" ,      --素颜法宝恢复
    action_block = "block",             --格挡
    action_relive = "relive",           --复活

    action_powerup = "powerup" ,        --击杀播放powerup

    action_uncontrol = "uncontrol" ,    --晕眩播放这个动作

    action_specialStand = "specialStand", --特殊站立循环
}
--===========================================================================================
--                     treasure法宝
--===========================================================================================

Fight.treasureKind_base = 1 --默认法宝
Fight.treasureKind_attack = 2 --A攻击法宝
Fight.treasureKind_defense = 3 --防御类法宝

Fight.treasureLabel_a = "a"
Fight.treasureLabel_b = "b"
--===========================================================================================
--                     skill 
--===========================================================================================

Fight.skill_type_attack = 1 -- 直接攻击
Fight.skill_type_missle = 2 -- 释放子弹
Fight.skill_type_summon = 3 -- 释放召唤物

Fight.skill_appear_normal = 1       --出现在x方向能 打到的第一个目标面前
Fight.skill_appear_normalEx = 8     --出现在x方向能 打到的第一个目标所在行（与1的区别在于面对大体型怪物时位置不同）
Fight.skill_appear_ymiddle = 2       --出现在x方向能 打到的第一个目标面前,y方向是中间
Fight.skill_appear_myFirst = 3       --出现在我方x方向能能选到的第一个人面签
Fight.skill_appear_toMiddle = 4     --出现在相对敌方屏幕中心
Fight.skill_appear_myMiddle = 5     --出现在相对我方屏幕中心
Fight.skill_appear_myplace = 6     --原地施法
Fight.skill_appear_myyMiddle = 7     --出现在我方能选中的第一个目标面前,y方向是中间
--===========================================================================================
--                     missle 
--===========================================================================================

-- 移动方式
Fight.missle_moveType_budong = 1 -- 不动
Fight.missle_moveType_zhixian = 2 -- 直线运动
Fight.missle_moveType_paowuxian = 3 -- 抛物线
Fight.missle_moveType_xie = 4 -- 斜着运动打击
Fight.missle_moveType_yanchang = 5 -- 子弹延长打击
Fight.missle_moveType_frame = 6 -- 按固定帧直线运动到目标点

-- 出现方式
Fight.missle_appearType_shoot = 1 -- 以发射者来计算坐标
Fight.missle_appearType_jin = 2 -- 最近的一个
Fight.missle_appearType_chooseMid = 3 --创建在 选中敌人的最中间
Fight.missle_appearType_middleX = 5 -- X轴的中间
Fight.missle_appearType_specEnemy = 6 -- 特定敌人身边


-- 扩散方式
Fight.diffusion_youce = 1  -- 向右边扩散
Fight.diffusion_zuoce = 2  -- 向左边扩散
Fight.diffusion_liangce = 3 -- 向两边扩散
--===========================================================================================
--                     attack 
--===========================================================================================

Fight.valueChangeType_num = 1    --数值改变方式  1是按照数值修改, 2是按照比例修改
Fight.valueChangeType_ratio = 2  -- 按比例修改
Fight.valueChangeType_attr = 3  -- 按属性修改

-- value类型 定义一些属性 目前战斗过程中主要会改变的属性就是 生命和能量 所以在这里单独定义下
Fight.value_health = "hp"           --生命
Fight.value_maxhp = "maxhp"            --最大生命
Fight.value_maxtreahp = "maxtreahp"            --最大治疗上限,初始值等于生命上限
Fight.value_inenergy = "inenergy"       --初始怒气
Fight.value_energy = "energy"           --能量 
Fight.value_maxenergy = "maxenergy"           --最大能量 

Fight.value_atk = "atk"                         --攻击

Fight.value_phydef = "def"                   --物防
Fight.value_magdef = "magdef"                   --法防
Fight.value_crit = "crit"                       --暴击
Fight.value_resist = "resist"         --抗暴
Fight.value_critR = "critR"         --暴击强度

Fight.value_block = "block"       --格挡率
Fight.value_wreck = "wreck"         --破击率
Fight.value_blockR = "blockR"       --格挡强度
Fight.value_injury = "injury"       --伤害率
Fight.value_avoid = "avoid"         --免伤率

Fight.value_limitR = "limitR"       --控制率
Fight.value_guard = "guard"         --免控率
Fight.value_suckR = "suckR"         --吸血
Fight.value_thorns = "thorns"       --反伤
Fight.value_cureR = "cureR"         --治疗率

Fight.value_curegetR = "curegetR"   --反治疗

Fight.value_buffHit = "buffHit"     --buff命中
Fight.value_buffResist = "buffResist" --buff抵抗

Fight.value_buffBleeding = "bleeding" -- 流血伤害提升
Fight.value_buffBurn = "burn" -- 灼烧伤害提升



--连击伤害系数
Fight.combDmgRatio = {
    -- 1, 1.1, 1.2, 1.3, 1.4, 1.6
    1, 1, 1, 1, 1, 1
}


Fight.useWay_selfCamp = 1
Fight.useWay_enemyCamp = 2

Fight.myWay = 1
Fight.enemyWay = -1


--战斗伤害相关   3种打击结果 
Fight.damageResult_none = -1           --没有结果
Fight.damageResult_normal = 1         --普通命中 
Fight.damageResult_shanbi =  2        --闪避
Fight.damageResult_baoji =  3         --暴击
Fight.damageResult_gedang =  4         --格挡
Fight.damageResult_baojigedang =  5         --同时暴击和格挡

--挨打类型
Fight.hitType_shanghai = 1  -- 伤害
Fight.hitType_baoji = 2 --暴击
Fight.hitType_gedang = 3 --格挡
Fight.hitType_shanbi = 4 -- 闪避
Fight.hitType_mianyi = 5 -- 免疫
Fight.hitType_xingyun = 6 -- 幸运
Fight.hitType_zhiliao = 7 -- 治疗
Fight.hitType_jiafali = 8 -- 加法力
Fight.hitType_jianfali = 9 --减法力
Fight.hitType_weinengbaoji = 10 -- 减威能暴击
Fight.hitType_weinengputong = 11 -- 减威能普通
Fight.hitType_jiaweineng = 12  --  加威能
Fight.hitType_skillShanghai = 13  --  技能伤害

Fight.hitType_miss = 20     -- 闪避
--===========================================================================================
--                     bufff 
--===========================================================================================
--buff  所有的非二级属性buff 全部从50以上开始 
Fight.buffType_HOT = 1 -- HOT
Fight.buffType_DOT = 2 --DOT(扩展中毒，如果扩展参数1填了值，则被驱散时会将其作为buff添加到受体身上)
Fight.buffType_xuanyun = 3 -- 眩晕
Fight.buffType_bati = 4 -- 霸体
Fight.buffType_mianyidmg = 5 -- 伤害免疫
Fight.buffType_gongji = 6 -- 攻击
Fight.buffType_fangyu = 7 -- 防御（物防）
Fight.buffType_chenmo = 8 -- 沉默
Fight.buffType_nuqipiece = 9 -- 怒气（小）
Fight.buffType_mianshang = 10 -- 免伤伤害
Fight.buffType_shanghai = 11 -- 增加伤害
Fight.buffType_baoji = 12 --暴击
Fight.buffType_mianbao = 13 -- 免暴
Fight.buffType_shanbi = 14 -- 闪避
Fight.buffType_mingzhong = 15 -- 命中
Fight.buffType_baobei = 16 -- 暴倍
Fight.buffType_xixue = 17 --吸血
Fight.buffType_fantan = 18 --反弹
Fight.buffType_nuqi = 19        --怒气（大）
Fight.buffType_zhiliao = 20     --治疗效果
Fight.buffType_beizhiliao = 21   --被治疗效果
Fight.buffType_gedang = 22  --格挡
Fight.buffType_gedangqiangdu = 23 --格挡强度
Fight.buffType_poji = 24       --破击
Fight.buffType_bingdong = 25 -- 冰冻
Fight.buffType_kongzhi = 26         --控制率
Fight.buffType_miankong = 27        --免控
Fight.buffType_mabi =  28       --麻痹
Fight.buffType_relive = 30  --复活
Fight.buffType_hudun = 31  --生命护盾
Fight.buffType_maxtreahp = 32   --修改生命上限buff 修改的是治疗上限
-- 经过确认这个buff与后续涉及不符不会应用，删除。
-- Fight.buffType_noSmallSkill = 33        --不能放小技能
Fight.buffType_nocureR = 34             --不能被治疗
-- Fight.buffType_ewaiDmg = 35             --额外伤害的buff  立即执行（废弃）
Fight.buffType_maxhp = 35 --  修改生命上限buff 修改的是真正的生命上限
Fight.buffType_shufu = 36   -- 束缚
Fight.buffType_dikangjiannu = 37   -- 抵抗减怒
Fight.buffType_mianyijianyi = 38 -- 免疫减益buff
Fight.buffType_zhongshang = 39 -- 重伤（受到伤害时，会受到目标自身生命百分比的额外伤害，扩展参数填1是当前生命值,填2是最大生命值）
Fight.buffType_certainBbaoji = 40 -- 强制被暴击（中此buff受到攻击百分百被暴击,value伤害效果万分比）
Fight.buffType_hunluan = 41 -- 混乱（有一定概率攻击己方,value概率）
Fight.buffType_kuilei = 42 -- 傀儡buff（标记为傀儡，攻击不会获得怒气，不能被攻击，buff消失人物移除）
Fight.buffType_zhuoshao = 43 -- 灼烧buff
Fight.buffType_trialAddChoose = 44 -- 试炼中额外对任意N个单位造成等量伤害
Fight.buffType_fengnu = 45 -- 封怒（防止敌人从任何途径获得怒气）
Fight.buffType_liuxue = 46 -- 流血
Fight.buffType_sleep = 47 -- 睡眠
Fight.buffType_wanghun = 48 -- 忘魂（狐妖女特殊buff，掉血并标记）
Fight.buffType_sureBaoji = 49 -- 必暴击
Fight.buffType_jianhen = 50 -- 剑痕（剑圣造成，标记用，没有实际效果）
Fight.buffType_chuangshang = 51 -- 创伤（吸收治疗量，类似于护盾）扩展行为同护盾
Fight.buffType_hpExDmg = 52 -- 根据血量附加伤害（需要扩展参数）
Fight.buffType_bingtai = 53 -- 冰台：抵抗一次岩浆伤害(目前在试炼中低档boss的一次灼烧buff伤害)
Fight.buffType_jinghua_hao = 54 -- 解除单体一切负面状态(试炼中用到)
Fight.buffType_sign = 55 -- 标记 （火神试炼，无伤害，是一个坏buff）
Fight.buffType_kezhi = 56 -- 克制（攻击某一类型的人时（profession）造成的伤害有加成）
Fight.buffType_energyCostUnchange = 57 -- 怒气消耗不增长
Fight.buffType_energyNoCost = 58 -- 怒气消耗免费（buff存在期间，释放大招免费）
Fight.buffType_energyCost = 59 -- 怒气消耗buff（放怒气时会提升/降低消耗的怒气量）
Fight.buffType_atkEnergyResume = 60 -- 改变出手怒气回复值（小怒气piece）
Fight.buffType_bingfu = 61 -- 冰符（如果在一回合内未释放怒气技能，则在下一回合时必定被冰冻）
Fight.buffType_fafang = 62 -- 防御（法防）
Fight.buffType_dikangzengyi = 63 -- 抵抗增益（此buff存在期间增益buff无法施加）
Fight.buffType_dingshen = 64 -- 纯表现用的buff，buff存在期间角色无法被击飞
Fight.buffType_yuner = 65 -- 蕴儿李忆如特殊buff（做标记与表现）
Fight.buffType_tag_gangzhan = 66 -- 罡斩标记（谢沧行buff存在回合有角色阵亡则获得怒气）
Fight.buffType_zhongchuang = 67 -- 重创，强化持续掉血类型buff的伤害，作用于最终值（流血、灼烧、中毒、忘魂需要类型为每回合结算）
Fight.buffType_atkcarrier = 68 -- 携带攻击包的buff（expand里携带攻击包，buff的作用时机1.攻击者最后一个伤害攻击包对受击者2.受击者死亡时对攻击者+atkId,时机;攻击包;）
Fight.buffType_huoshangjiaoyou = 69 -- 火上浇油buff（火神试炼特殊buff）
Fight.buffType_wumian = 70 -- 物理免疫buff
Fight.buffType_famian = 71 -- 法术免疫buff
Fight.buffType_zlhudun = 72 -- 治疗护盾（吸收部分伤害量并将其转化为气血恢复）
Fight.buffType_bomb = 73 -- 炸弹buff（扩展参数1为触发伤害值,参数2为伤害的攻击包Id需要带选敌）
Fight.buffType_bingfeng = 74 -- 冰封(六界玩法使用,第一次被攻击中会破)
Fight.buffType_tag_hanlingsha = 75 -- 韩菱纱标记负面（做标记用）
Fight.buffType_tag_yuntianhe = 76 -- 云天河标记负面（做标记用）
Fight.buffType_tag_wangpengxu = 77 -- 王蓬絮标记（花粉），增益
Fight.buffType_eNxixue = 78 -- 增强吸血（增强攻击包的吸血效果）value为增强的比例，与作用类型无关
Fight.buffType_huhun = 79 -- 虎魂（王小虎的特殊buff，带有此buff的多受到一定量的反伤）value为增强的比例，与作用类型无关
Fight.buffType_klchong = 80 -- 傀儡虫（傀儡虫存在时如果目标被击杀则召唤为紫萱的傀儡）
Fight.buffType_tag_lingbo = 81 -- 凌波标记（视为debuff）
Fight.buffType_tag_tangxuejian = 82 -- 唐雪见标记（中性）
Fight.buffType_xingsuo = 83 -- 如果使用怒气仙术则进入眩晕（value为眩晕buffId）
Fight.buffType_bihu = 84 -- 受到攻击时，概率将伤害降低至1点（value配成概率,当庇护为进阶版时，expand的第一个参数为额外回血的攻击包）
Fight.buffType_tag_daofu = 85 -- 天师道袍的标记(减益)
--[[
灵泉杖buff(如果目标连续受到两次水属性仙术攻击，则被冰冻;中间受到其他伤害则buff消失;进阶版,如果被中断则目标获得寒冰状态)    
value 触发时需要满足的连续次数
扩展参数1为冰冻buff的Id
扩展参数2位升级版后的寒冬状态buff
]]
Fight.buffType_lingquan = 86
Fight.buffType_hanbing = 87 -- 寒冰(和灼烧一样，只是多一种枚举区分)
Fight.buffType_tag_mubei = 88 -- 僵尸的墓碑buff,不可选中,不算活人（中性）,通常应该配成不可清除
Fight.buffType_yanbo = 89 -- 炎波神力buff(在其回合开始前损失当前回合受到的xx%伤害)/紫苑,value为伤害万分比。
Fight.buffType_mianyiputong = 90 -- 免疫普攻仙术buff
Fight.buffType_tag_common = 91 -- 通用标记（此类型，不为某个人单独使用，为中性，便利效率较低）
Fight.buffType_tag_xienian = 92 -- 邪剑仙邪念标记（中性）
Fight.buffType_tag_yaoneng = 93 -- 天妖皇妖能标记（增益）
Fight.buffType_purify = 94 -- 净化、驱散（扩展参数expandP填法:1.驱散减益效果;2.驱散增益效果;3.指定类型buff；当类型为3时后面的参数均为bufftype）

-- 掉血buff枚举(DOT类buff比较多，在这里加个枚举表，以便做判断)
Fight._BUFF_DOT = {
    [Fight.buffType_DOT] = true,
    [Fight.buffType_zhuoshao] = true,
    [Fight.buffType_liuxue] = true,
    [Fight.buffType_wanghun] = true,
    [Fight.buffType_hanbing] = true,
}

--buff 映射的人物属性表 
Fight.buffMapAttrType  = {
    [Fight.buffType_gongji] = "atk",            -- 攻击
    [Fight.buffType_fangyu] = "def",            -- 防御（物防）
    [Fight.buffType_fafang] = "magdef",            -- 防御（法防）

    [Fight.buffType_mianshang] = "avoid",       --免伤率
    [Fight.buffType_shanghai] = "injury",        -- 伤害率
    
    [Fight.buffType_gedang] = "block",               -- 格挡率
    [Fight.buffType_gedangqiangdu] = "blockR",               -- 格挡率

    [Fight.buffType_poji] = "wreck",                 -- 破击率

    [Fight.buffType_maxtreahp] = "maxtreahp" ,     --修改生命上限buff（治疗上限）
    [Fight.buffType_maxhp] = "maxhp" ,     --修改生命上限buff（真正的生命上限）

    [Fight.buffType_baoji] = "crit",            -- 暴击
    [Fight.buffType_mianbao] = "resist",        -- 抗暴
    [Fight.buffType_shanbi] = "dodge",          --闪避
    [Fight.buffType_mingzhong] = "hit",         -- 命中
    [Fight.buffType_baobei] = "critR",          -- 暴倍

    [Fight.buffType_xixue] = "vampire",         -- 吸血
    [Fight.buffType_fantan] = "thorns",        -- 反弹
    [Fight.buffType_kongzhi] = "limitR",        -- 控制率
    [Fight.buffType_miankong] = "guard",        -- 免控率

    [Fight.buffType_zhiliao] = "cureR" ,         --治疗率
    [Fight.buffType_beizhiliao] = "curegetR" ,         --反治疗率

}

--buff对应飘字帧数表
Fight.buffMapFlowWordHao = {
    [Fight.buffType_baoji ] = 1 ,           --暴击率
    [Fight.buffType_baobei] = 2 ,           --暴击伤害    
    [Fight.buffType_beizhiliao] = 3,          --被治疗效果
    [Fight.buffType_fangyu] = 4,          --防御（物防）
    [Fight.buffType_fafang] = 4,          --防御（法防）
    [Fight.buffType_gedang] = 5,          --格挡效果
    [Fight.buffType_gedangqiangdu] = 6,          --格挡强度
    [Fight.buffType_HOT] = 7 ,              --hot
    [Fight.buffType_mianbao] = 8 ,              --抗暴
    [Fight.buffType_kongzhi] = 9 ,          --控制率
    [Fight.buffType_miankong] = 10 ,          --免控
    [Fight.buffType_mianshang] = 11 ,          --免伤
    [Fight.buffType_nuqi] = 12 ,          --怒气变化
    [Fight.buffType_poji] = 14 ,          --破击
    [Fight.buffType_shanghai] = 15 ,          --伤害率
    [Fight.buffType_gongji] = 16 ,          --攻击力
    [Fight.buffType_zhiliao] = 17 ,          --治疗
    [Fight.buffType_hudun] = 58 ,          --生命护盾
    [Fight.buffType_kuilei] = 36,           --傀儡
    [Fight.buffType_jinghua_hao] = 47,         --驱散
    [Fight.buffType_purify] = 47,           --净化、驱散
    [Fight.buffType_bingtai] = 48,         --免疫灼烧
    [Fight.buffType_trialAddChoose] = 49,         --溅射攻击
    [Fight.buffType_energyCost] = 51,         --怒气消耗减少
    [Fight.buffType_mianyidmg] = 57,        -- 免疫伤害
    [Fight.buffType_wumian] = 59,           -- 物免
    [Fight.buffType_famian] = 60,           -- 法免
    [Fight.buffType_mianyiputong] = 59,     -- 免疫普通仙术
    [Fight.buffType_bingfu] = 61,            --气血上限
    [Fight.buffType_tag_mubei] = 62,          -- 复活
    [Fight.buffType_mianyiputong] = 63,        --免疫仙术
    [Fight.buffType_bihu] = 64,                  --庇护
    [Fight.buffType_tag_gangzhan] = 67,         --罡斩
}
--坏buff对应的帧数
Fight.buffMapFlowWordHuai = {
    [Fight.buffType_xuanyun] = 18 ,           --晕眩
    [Fight.buffType_bingdong] = 19 ,           --冰冻
    [Fight.buffType_chenmo] = 23 ,           --沉默
    [Fight.buffType_mabi] = 26 ,            --麻痹
    [Fight.buffType_zhuoshao] = 27 ,            --灼烧
    [Fight.buffType_liuxue] = 52,         --流血
    [Fight.buffType_hunluan] = 53,         --混乱
    [Fight.buffType_wanghun] = 54,         --忘魂
    [Fight.buffType_DOT] = 55,         --中毒
    [Fight.buffType_shufu] = 56,         --束缚
    [Fight.buffType_hanbing] = 65,      --寒冻
    [Fight.buffType_xingsuo] = 66,      --邢锁
}
--人物属性对应的buff属性表,
Fight.attrMapBuffType = {
}

for k,v in pairs(Fight.buffMapAttrType) do
    Fight.attrMapBuffType[v] = k
end

-- buff的类型
Fight.buffKind_hao = 1 -- 正面buff
Fight.buffKind_huai = 2 -- 负面buff
Fight.buffKind_aura = 3  -- 光环
Fight.buffKind_aurahuai = 4  -- 光环
Fight.buffKind_neutral = 5 -- 中性buff

-- 叠加的相同ID的情况替换
Fight.buffMulty_all = 0 --0是并存
Fight.buffMulty_replace = 1 --1是覆盖
Fight.buffMulty_max = 2 --2是存留剩余回合数比较大的
Fight.buffMulty_refresRound = 3 --3是把原buff的回合数刷新为较大的


Fight.buffRunType_now =  1 --立刻作用
Fight.buffRunType_round =  2 --回合前作用
Fight.buffRunType_nRound=3 --n回合后生效


Fight.filterStyle_fire = 1  --灼烧滤镜效果
Fight.filterStyle_ice = 2  --冰冻滤镜效果
Fight.filterStyle_big = 3  --人物变大
Fight.filterStyle_small = 4  --人物变小
Fight.filterStyle_hide = 5      --隐藏
Fight.filterStyle_kuilei = 6      --隐藏

-- 特殊buff记次时机枚举
Fight.useBuffByAttack = { -- 攻击时（在攻击完成后做-1）
    Fight.buffType_gongji,
    Fight.buffType_shanghai,
    Fight.buffType_baoji,
    Fight.buffType_baobei,
    Fight.buffType_poji,
    Fight.buffType_sureBaoji,
    Fight.buffType_kezhi,
    Fight.buffType_hpExDmg,
}

Fight.useBuffByBeHited = { -- 被击时（在final时做-1）
    Fight.buffType_fangyu,
    Fight.buffType_mianshang,
    Fight.buffType_mianbao,
    Fight.buffType_fantan,
    Fight.buffType_gedang,
    Fight.buffType_gedangqiangdu,
    Fight.buffType_zhongshang,
    Fight.buffType_certainBbaoji,
    Fight.buffType_fafang,
}
--===========================================================================================
--                     操作相关
--===========================================================================================
--这个是战斗中逻辑
Fight.operationType_giveSkill = 1
Fight.operationType_giveTreasure = 2
Fight.operationType_skip = 3            --跳过本回合
Fight.operationType_BigSkill = 4 --指定释放大招（主角giveTreasure，伙伴giveSkill）
Fight.operationType_endRound = 5 --缓存insertHandle里面定义的类型  结束回合
Fight.operationType_artifactSKill = 6 -- 手动释放的神器技能




--[[
通用战斗操作协议格式:
{
    rid: 角色id       代表这个操作是谁发起的
    index:操作序号      唯一性.合连续性
    info:每种操作特殊的信息内容
    wave:  当前第几波
    round: 当前第几回合
    type: 操作类型   就是下面定义的handleType
}
 
]] 

--{camp, index, type, params,timely} （操作为点击攻击时此参数有效，标记是否是在其他人小技能出手时的出手）
Fight.handleType_battle = 1         --战斗里面点击操作
-- {auto },自动1 非自动0
Fight.handleType_auto = 2         --自动战斗操作
--{state } 1 上线  0下线
Fight.handleType_state = 3         --上线下线操作
-- {rid,pos,posRid[换位置角色rid],camp}
Fight.handleType_changePos = 4         --换位操作
-- 暂时废弃
Fight.handleType_overTime = 5       --操作超时
--{htype=hType,rid = heroRid,bId=buff的唯一id,bType = buffType,buffId=buffId}
Fight.handleType_buff = 6           --试炼战斗中buff拖拽至角色身上操作
--{finish(1表示结束),camp(阵营1或者2) }
Fight.handleType_bzFinish = 7           --战斗中布阵完成操作
--{camp,nextState[4换人阶段，2布阵阶段],canCtrl[0不能控制1,可以控制]}
-- Fight.handleType_endRound = 8           --战斗中 时间到了结束回合
Fight.handleType_startRound = 8         --回合开始[用于校验进入布阵阶段还是换人阶段]
--发送换灵操作  {element ,  round ,pos , camp    }
Fight.handleType_changeElement = 9  --换灵操作（使用更换五行阵位）
-- {change,camp} change默认0，超时1
Fight.handleType_changeFinish = 10         --巅峰竞技场换人完成操作
-- {rid,pos,hid,camp,ctype} ctype:0下阵  1上阵
Fight.handleType_changeHero = 11         --巅峰竞技场换人操作
-- {camp} 结束的阵营
Fight.handleType_endRound = 12 -- 战中 回合结束
-- {change,camp} change默认0，超时1
-- Fight.handleType_sureBattle = 12         --巅峰竞技场确认对战操作（已废弃）
Fight.handleType_battle_small = 14         -- 小技能(逻辑同Fight.handleType_battle)
-- {camp}
Fight.handleType_battle_bzStart = 15              -- 布阵开始
-- {camp}
Fight.handleType_battle_changeStart = 16              -- 换人开始
-- {team,leftFormationCount}
Fight.handleType_enterBeforeChange = 17         --仙界对决战前进入选人操作
-- {rid,partnerId,posNum}
Fight.handleType_beforeChange = 18 --仙界对决战前上下阵操作
-- {rid,type[0下阵1主角],posSource原位置,posTarget,posRid[换位置角色rid]}
Fight.handleType_beforeChangePos = 19 --仙界对决战前换位操作
-- {}
Fight.handleType_beforeChangeSure = 20 --仙界对决战前上下阵完成
-- {}
Fight.handleType_enterSelectCard = 21         --仙界对决战前进入选人操作
-- {teamId,selectList{cardId,cardType,teamId}}
Fight.handleType_selectCard = 22         --仙界对决战前选人选择
-- {team}
Fight.handleType_giveUp = 23         --仙界对决战中认输
-- {rid,setAuthFlag[0委托，1非委托]}
Fight.handleType_autoFlag = 24        --仙界对决战中托管

-- 共闯秘境神力相关操作
-- 战前加载完成
Fight.handleType_guildBossReady = 107
-- {rid,sid}
Fight.handleType_recommendSpirit = 108 -- 推荐神力
-- {rid,sid,pos,endPos} 换位置的神力需要endPos
Fight.handleType_useSpirit = 109 -- 使用神力

Fight.handleType_endSpiritRound = 110 -- 神力阶段结束
-- {rid}服务器推送
Fight.handleType_enterSpiritRound = 115 -- 神力阶段开始
-- {rid}服务器推送
Fight.handleType_formationInBattleBegin = 116 -- 战中布阵开始(神力结束后进入这个阶段)
-- {rid}
Fight.handleType_guildBossQuit = 120 --主动退出

-- 这几个操作是在GuildBoss.xmind里面定义的，与括号后操作一致
Fight.handleType_formationInBattle = 111 --战中设置阵型(4)
Fight.handleType_formationFinish = 112 -- 战中设置阵型结束(7)
Fight.handleType_handClick = 113 --释放技能(1或者14)
Fight.handleType_battleBegin = 117 -- 战斗回合开始 （7）


Fight.trial_buffHand = 1    --试炼中开始拖拽
Fight.trial_buffOff = 2     --试炼中取消拖拽
Fight.trial_buffUse = 3     --试炼中拖拽至某个角色身上并使用buff

-- 头像状态
Fight.icon_normal = 1   --常态(没任何状态)
Fight.icon_canClick = 2 --可点击(能放大招)
Fight.icon_unClick = 3 --不可点击(眩晕、束缚等)
Fight.icon_isClick = 4 --已经点击（等待释放大招）
Fight.icon_clickEnd = 5 --大招释放结束
Fight.icon_crossPeak = 6 -- 仙界对决不可点击状态(敌方回合、上下阵阶段不是新角色)


Fight.change_down = 0 --巅峰竞技场下阵
Fight.change_up = 1 --巅峰竞技场上阵

-- 普攻出手顺序
Fight.aiOrder = {1,3,5,2,4,6}


Fight.battle_tower_touxiBuffHid = 600000 --锁妖塔偷袭战中怪物入场开始时的睡眠状态buffId
Fight.battle_icePve_buffHid = 900000 --冰封玩法对应的buffId

-- 战斗星级判定枚举
Fight.star_live_hero = 1 -- 有角色存活
Fight.star_live_count = 2 -- 伙伴存活个数
Fight.star_live_all = 3 -- 无角色死亡
Fight.star_round_count = 4 -- 回合数
Fight.star_boss_hp = 5 -- boss剩余血量
Fight.star_hero_hp = 6 -- 我方伙伴剩余总血量




--===========================================================================================
--                     序章参数
--============================================================================================
Fight.xvzhangParams = {
    --主角出现位置
    zhujueShowPos = 5,
    --主角出现在3号位，把徐长卿换到3号位
    -- zhujuePos = {1,3},
    xuzhang = "10000",          --序章关卡id

    -- zhujueHid = "100015",       --序章刷新主角hid
    -- zhujuenvHid = "100016",     --序章刷新女主角hid

    trial = "3099",             -- 试炼需要引导的关卡
    pvp = "103",                -- 登仙台

    -- weakGuideLevels = {"10202","10203", "10204", "10206"},       

    -- 这个本来应该根据条件触发，结果后来又改成固定回合，如果之后又要固定人就改成配表
    -- weakGuideLevels = { -- key有弱引导的关卡,value检查触发的回合
    --     ["10202"] = 3,
    --     ["10203"] = 3,
    --     ["10204"] = 5,
    --     ["10206"] = 5,
    -- },

    level1_1 = "10101",         -- 主线1-1
    level1_2 = "10102",         -- 主线1-2
    ------------ 赵灵儿特殊入场 ------------
    level_spzhaolinger = "10207",
    zhaolingerHid = "102073",
    zhaolingerPlot = "10207",
    zhaolingerIn_wave = 2, 
    zhaolingerIn_round = 1,
    ------------ 龙幽特殊入场 ------------
    level_splongyou = "10208",
    longyouHid_303 = "102081",
    longyouPlot = "10208",
    longyouIn_wave = 1,
    longyouIn_round = 5,
    ------------ 主线10201换李逍遥 ------------
    level_splixiaoyao = "10201",
    lixiaoyaoHid = "102012",
}

--===========================================================================================
--                     五行阵位相关 
--===========================================================================================
Fight.element_non = 0 -- 无属性
Fight.element_wind = 1  -- 风
Fight.element_thunder = 2   -- 雷
Fight.element_water = 3 -- 水
Fight.element_fire = 4  -- 火
Fight.element_soil = 5  -- 土

Fight.element_reduce_rate = 0 -- 固定减伤率
Fight.element_ex_lv = 1 -- 阵位提升的技能等级

-- 五行防御效果对应的特效名
Fight.elementDefEff = {
    [Fight.element_wind] = "UI_zhandou_zhenwei_fdh",
    [Fight.element_thunder] = "UI_zhandou_zhenwei_ldh",
    [Fight.element_water] = "UI_zhandou_zhenwei_sdh",
    [Fight.element_fire] = "UI_zhandou_zhenwei_hdh",
    [Fight.element_soil] = "UI_zhandou_zhenwei_tdh",
}

Fight.wenzi_elementDef = {
	[Fight.element_wind] = 39,		--风系抵抗
	[Fight.element_thunder] = 40,		--雷系抵抗
	[Fight.element_water] = 41,		--水系抵抗
	[Fight.element_fire] = 42,		--火系抵抗
	[Fight.element_soil] = 43,		--土系抵抗
}

-- ========================== 关卡玩法类型===========
Fight.levelType_refresh = 1 --车轮战
Fight.levelType_gate = 2 --传送门
Fight.levelType_Answer = 3 --答题模式

-- 答题模式相关字符串解析
Fight.answer_add = "+"
Fight.answer_mul = "*"
Fight.answer_equal = "="
Fight.answer_sub = "-"
-- 对应的mc的帧数
Fight.answer_frame = {
    [Fight.answer_add] = 1,
    [Fight.answer_mul] = 2,
    [Fight.answer_equal] = 3,
    [Fight.answer_sub] = 4,
}
Fight.answer_wrong = 0 --答题失败
Fight.answer_right = 1 --答题正确
--===========================================================================================
--                      调试相关
--===========================================================================================
Fight.low_fps = false -- true false
-- 是否显示大招倒计时按钮
Fight.is_show_button = false

-- 是否进行数据统计
Fight.game_statistic = false -- 表示数据统计包含进入战斗人员信息和操作信息
if not DEBUG_SERVICES  then
    if device.platform == "ios" or device.platform == "android" then
        Fight.game_statistic = false
    end
end

Fight.use_operate_info = true -- 表示根据文件复盘战斗情况
Fight.statistic_file = "log____log1" -- 记录战斗操作信息的文件


--是否是 模拟播放  比如 纯粹计算战斗ai的时候 那么就设置为 true
Fight.isDummy = false -- false true
Fight.dummyUpdata = 1/GameVars.GAMEFRAMERATE

Fight.only_one_enemy_hid = "10001"
Fight.enemy_low_hp = false      --敌人低血量
Fight.all_high_hp = false       --高血量
Fight.escape_damage = 0 -- 无敌（不掉血）0不开，1我方，2敌方，3双方
Fight.default_level_id = "103"
Fight.allways_lose = false

Fight.no_dialog = false         --没有剧情对话
Fight.test_jitui_hid = "29300071"  --29300071  10026

Fight.debugFullEnergy = false        --无限能量

--是否是固定的随机种子 false 表示随机种子是随机的 ,true 表示是固定随机种子 
Fight.fixRandomSeed = false

Fight.isOpenFightLogs = true   --是否开启战斗日志

Fight.debug_battleSpeed = 1       --调试战斗加速

--是否隐藏大招满怒效果
Fight.isHideSkillStand = true  

Fight.check_battleSpeed = 1 -- 检查校验战斗加速,越大代表开加速器越快



-- 战斗结算失败后类型跳转
Fight.jump_to_Partner_Level = 1 --伙伴升级
Fight.jump_to_Partner_Practice = 2-- 伙伴修炼
Fight.jump_to_Partner_Quality = 3 --伙伴升品
Fight.jump_to_Partner_Star = 4 --伙伴升星
Fight.jump_to_Char = 5 --跳转至主角
Fight.jump_to_Treasure = 6 --法宝界面
Fight.jump_info = {
    [Fight.jump_to_Partner_Level] = {viewName = "PartnerView",idx=FuncPartner.PartnerIndex.PARTNER_SHENGJI},
    [Fight.jump_to_Partner_Practice] = {viewName = "PartnerView",idx=FuncPartner.PartnerIndex.PARTNER_SKILL},
    [Fight.jump_to_Partner_Quality] = {viewName = "PartnerView",idx=FuncPartner.PartnerIndex.PARTNER_QUALILITY},
    [Fight.jump_to_Partner_Star] = {viewName = "PartnerView",idx=FuncPartner.PartnerIndex.PARTNER_UPSTAR},
    [Fight.jump_to_Char] = {viewName = "PartnerView",idx=FuncPartner.PartnerIndex.PARTNER_QUALILITY},
    [Fight.jump_to_Treasure] = {viewName = "TreasureMainView"},
}

-- 试炼模式
Fight.not_trail = 0 --不是试炼
Fight.trail_shanshen = 1 --山神
Fight.trail_huoshen = 2 --火神
Fight.trail_daobaozhe = 3 --盗宝者

-- 试炼掉落相关
Fight.drop_buff = 1 --掉落buff
Fight.drop_treasure = 2 --掉落法宝(废弃)

-- 主角法宝类型
Fight.treaType_base = "base"
Fight.treaType_normal = "normal"

-- 战斗暂停点击类型
Fight.pause_restart = 1 --暂停界面重新开始
Fight.pause_quit = 2 --暂停界面点退出

-- 雇佣兵类型
Fight.teamFlag_robot = 1 --机器人
Fight.teamFlag_user = 2 --真实玩家数据

-- 玩家数据
Fight.battle_type_user = 1 --真实玩家数据
Fight.battle_type_robot = 2 --机器人

-- 仙界对决bp卡类型
Fight.battle_card_hero = 1 --角色
Fight.battle_card_treasure = 2 --神器

-- 神器kind类型枚举
Fight.artifact_kind1 = 1
Fight.artifact_kind2 = 2
Fight.artifact_kind3 = 3
Fight.artifact_kind4 = 4
Fight.artifact_kind5 = 5

-- 布阵上下高度范畴
Fight.buzhen_min = 280
Fight.buzhen_max = 570

-- 与服务器状态一直
Fight.battleState_none = 0 --初始化状态(本地初始化状态[也可以说是追进度状态],服务器没有此状态)
Fight.battleState_ready = 1 --战斗准备
Fight.battleState_formation = 2 --战斗布阵
Fight.battleState_battle = 3 --战斗
Fight.battleState_changePerson = 4 --战斗中换人
Fight.battleState_end = 5 --战斗结束
Fight.battleState_selectPerson = 6 --仙界对决战前选人
Fight.battleState_formationBefore = 7 --仙界对决战前上阵
Fight.battleState_wait = 8 -- 等待状态，不可追进度状态[回合结束切换状态、神器释放技能状态、回合开始状态]
Fight.battleState_spirit = 9 -- 共闯秘境神力阶段
Fight.battleState_switch = 10 -- 切换等待[回合快结束的时候是有一个3秒等待才会结束(不显示倒计时)]



-- 最大选人上下阵回合数
Fight.crosspeak_changeNum = 2 --现在仙界对决只有2回合,与下面Fight.crosspeak_num 内{1、2} {2、1} 一致
-- 仙界对决战前布阵最大人数(根据上阵人数处理)
Fight.crosspeak_num = {
    [3]={[Fight.camp_1]={1,2},[Fight.camp_2]={2,1}},
    [4]={[Fight.camp_1]={2,2},[Fight.camp_2]={2,2}},
}
-- 仙界对决玩法类型
Fight.crosspeak_normal = 1 --标准玩法
Fight.crosspeak_obstacle = 2 --调皮的仙人掌
Fight.crosspeak_energy = 3 --怒气回复*2

Fight.crosspeak_mode_normal = 1 --自选卡模式
Fight.crosspeak_mode_bp = 2 --bp模式

Fight.bzState_buzhen = 2 -- 布阵阶段
Fight.bzState_change = 4 -- 换人阶段

Fight.partner_notUp = 0 --奇侠未上阵
Fight.partner_isUp = 1 --奇侠已经上阵

-- 共闯秘境相关枚举
Fight.spiritPower_normal = 0 --未推荐
Fight.spiritPower_recomend = 1 --推荐的神力

-- 神力技能使用方式
Fight.spiritType_drag = 1 --拖拽
Fight.spiritType_click = 2 --点击

-- 刷怪方式
Fight.refresh_sequence = "1" --顺序刷怪
Fight.refresh_random = "2" --随机刷怪
Fight.refresh_wave = "3" --整波死亡后刷怪

-- 阵容枚举
Fight.formation_arr = {"p1","p2","p3","p4","p5","p6"}

-- miniBattle序列类型枚举
Fight.miniProcess_attack = 1 -- 攻击
Fight.miniProcess_switch = 2 -- 切回合
Fight.miniProcess_wait = 3 -- 等待时间

-- 根据跳转类型返回对应弹出界面信息
function Fight:getJumpInfoByType( jType )
    if not jType then return nil end
    return Fight.jump_info[jType]
end


function Fight:getElementString( t )
    return self.elementStrObj[t]
end
BattleDebug = function ( ... )
    if DEBUG  and DEBUG > 0 then
        echo(...)   
    end
end



return Fight