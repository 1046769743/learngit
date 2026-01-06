interface GameStatusData {
    user_name: string;//用户名字
    head_image_url: string;//用户头像
    user_level: number;//用户等级
    red_packet_value: number;//红包余额
    game_diamond_value: number;//钻石余额
    game_data: any;//棋盘数据（string）
    float_box_interval: number;//悬浮宝箱出现间隔（秒）
    float_box_duration: number;//炫富宝箱出现持续时间
    game_config_json: GameConfigData;//游戏配置透传congfig
    game_guide_steps: number;//当前引导步骤ID（正在进行）;
    // show_home_progress: boolean;
    is_new_user_welfare_received: boolean; //是否已经灵雎新人冲关复利
    show_playlet_enter: boolean; //短剧入口是否显示;
    auto_merge_chips_switch: boolean; //自动合成筹码开关
}

// 游戏配置透传
interface GameConfigData {
    chips_reward_config: any; //筹码奖励配置
    chips_progress_reward_config: any;//筹码进度奖励配置
    deal_config: any; // 发牌配置
    deal_color_config: any; // 发牌颜色配置
    remove_small_chip_config: any; //移除筹码配置
    unlock_slot_config: any; //解锁槽位配置
    after5_compo_reward: any; //合成5级之后1-4级的红包奖励值 如果为空（即pm没配置）走旧的
    prop_icon_switch: boolean; //自动合成下的样式开关
    wd_config_high: Array<number>; // 新人福利前的提现目标显示
    wd_config_real: Array<number>; // 新人福利后的提现目标显示
}

interface SlotConfig {
    slot_id: number;//槽位id
    unlock_type: number;//解锁类型 1:临时槽位 2:钻石槽位
    unlock_value: number;//解锁值

}

//刷新用户详情
interface RefreshUserInfo {
    user_level: number;//用户等级
}

interface UseShuffleCardStatus {
    status: boolean;//true代表成功 false 代表失败
}

interface UnlockChipBoxStatus {
    type: number;//解锁槽位类型 1:临时槽位 2:钻石槽位
    status: boolean;//true 解锁成功 false 解锁失败
    slotId: number;//槽位id
}

interface RefreshCurrencyValue {
    red_packet_value: number;//红包余额
    game_diamond_value: number;//钻石余额
    show_delta: boolean;//是否展示 +xxx元动画
}

interface ShowChipUpgradeDialog {
    current_max_chip_num: number;//当前最大筹码号
    reward_value: number;//合成该筹码可得多少钱 例 0.22
}

interface SysGuide {
    id: string;//引导id
    type: number;//引导类型
    step: number;//引导步骤
    is_save: boolean;//是否保存
    tips: string;//提示
    sound: string;//音效
}

