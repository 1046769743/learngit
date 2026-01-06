import { ChipSlotStatus, ChipSlotType, ChipType, GameDifficultyMode } from '../../Common/EnumDefine';
import { GameUI } from '../../View/Game/GameUI';
import { NativeApi } from '../../Platform/Android/NativeApi';
import { EventName } from '../../Common/EventName';
import { Tools } from '../../Common/Tools';
import { ChipSlot } from './ChipSlot';
import HomeUI from '../../View/Home/HomeUI';
import { Log } from '../../FrameWork/Log';
import { Chip } from './Chip';
import { EventCenter } from '../../FrameWork/EventCenter';
const { ccclass, property } = cc._decorator;

export class GameMgr {
    public static readonly TAG: string = "GameMgr"
    public static readonly Slot_Max_Num: number = 12;
    public static readonly Slot_Chips_Max_Num: number = 10;
    public static readonly Max_Chips_Id: number = 300;
    public static readonly Unit_Chips_Num: number = 10;
    public static readonly Temp_Slot_Max_Num: number = 2; //临时槽位数量

    // 创建单例
    private static _instance: GameMgr;
    static get Instance() {
        if (this._instance) {
            return this._instance;
        }

        this._instance = new GameMgr();
        return this._instance;
    }

    private mChipsSlotList: ChipSlot[] = [];
    private mCurTargetProgress: number = 50;
    private mCurProgress: number = 10;

    // 配置-----------------
    // 存档开关和存档进度 只会在110关失败
    private mGameConfigJson: any = null;
    private mSlotConfig: any = null;
    private mProgressSwitch: boolean = true;
    private mProgressValueList: number[] = [30, 50, 80]; //chip5，改成多档位配置
    // 洗牌按钮出现配置
    private mShuffEmptyNum: number = 6;
    // 110关可以洗牌次数
    private mShuffCount: number = 3;
    // 游戏内引导次数
    private mGameGuideCount: number = 3;
    // 游戏内引导间隔
    private mGameGuideInterval: number = 5;

    public HistoryRedPacket: number = -1;
    public RedPacketChange: number = 0;
    public HistoryGameCash: number = -1;
    public GameCashChange: number = 0;

    public HomeUI: HomeUI = null;
    public GameUI: GameUI = null;

    public awardConfigJson: any = null;
    gameStatusData: GameStatusData = null;

    usedShuffCount: number = 0; //使用洗牌道具次数
    usedGameGuideCount: number = 0;
    usedRemovePropCount: number = 0; //使用移除道具次数

    isInitOk = false;

    //chip5新增gameConfig配置
    public shuffleStartLimitChipsLevel: number = -1; ///洗牌开始限制筹码数
    public shuffleLimitCount: number = -1; //洗牌限制次数
    public removePropStartLimitChipsLevel: number = -1;//移除道具开始限制筹码数
    public removePropLimitCount: number = -1;//移除道具限制次数 
    public removeSmallChipConfig: Map<number, number> = new Map<number, number>(); //移除筹码配置
    public propPreWithdrawlUsageCount: number; //提现前道具的使用次数
    public isFinalDealGuideShow: boolean = false;

    InitData(data: GameStatusData) {
        Log.Debug(GameMgr.TAG + " GameMgr InitData");

        this.gameStatusData = data;
        this.usedShuffCount = this.gameStatusData.game_data["usedShuffCount"] ?? 0;
        this.usedGameGuideCount = this.gameStatusData.game_data["usedGameGuideCount"] ?? 0;
        this.usedRemovePropCount = this.gameStatusData.game_data["usedRemovePropCount"] ?? 0;

        this.mCurTargetProgress = this.gameStatusData.game_data["targetProgress"] ?? 50;

        this.mCurProgress = this.gameStatusData.game_data["curProgress"] ?? 10;

        Log.Debug("初始化数据 this.mCurTargetProgress = " + this.mCurTargetProgress + " this.mCurProgress = " + this.mCurProgress + " this.usedShuffCount = " + this.usedShuffCount);

        this.mGameConfigJson = this.gameStatusData.game_config_json;
        this.mProgressSwitch = this.mGameConfigJson["game_progress_switch"];
        this.mProgressValueList = this.mGameConfigJson["game_progress_value_list"];
        this.mShuffEmptyNum = this.mGameConfigJson["shuffle_empty_num"];
        this.mShuffCount = this.mGameConfigJson["shuffe_num_110"];
        this.mGameGuideCount = this.mGameConfigJson["game_guide_count"];
        this.mGameGuideInterval = this.mGameConfigJson["game_guide_interval"];
        this.awardConfigJson = this.mGameConfigJson["chips_progress_reward_config"];
        this.mSlotConfig = this.mGameConfigJson["unlock_slot_config"];

        //chip5新增
        this.shuffleStartLimitChipsLevel = this.mGameConfigJson["shuffle_start_limit_chips_level"];
        this.shuffleLimitCount = this.mGameConfigJson["shuffle_limit_count"];
        this.removePropStartLimitChipsLevel = this.mGameConfigJson["remove_prop_start_limit_chips_level"];
        this.removePropLimitCount = this.mGameConfigJson["remove_prop_limit_count"];
        this.propPreWithdrawlUsageCount = this.mGameConfigJson["prop_pre_withdrawal_usage_count"];

        let removeChipCfg = this.mGameConfigJson["remove_small_chip_config"];
        this.removeSmallChipConfig.clear();
        for (var key in removeChipCfg) {
            Log.Debug(`GameMgr, removeChipCfg=====: key:${key},  value:  ${removeChipCfg[key]}`);
            this.removeSmallChipConfig.set(Number(key), removeChipCfg[key] as number);
        }

        // if (sys.os === sys.OS.ANDROID && sys.isNative) {
        //     if (this.gameStatusData.game_guide_steps < 1) {
        //         this.gameStatusData.game_guide_steps = 1;
        //     }
        // }

        let num = this.gameStatusData.red_packet_value;

        if (this.HistoryRedPacket > 0 && this.HistoryRedPacket != num) {
            this.RedPacketChange = num - this.HistoryRedPacket;
        } else {
            this.RedPacketChange = 0;
        }

        this.HistoryRedPacket = num;

        num = this.gameStatusData.game_diamond_value
        if (this.HistoryGameCash > 0 && this.HistoryGameCash != num) {
            this.GameCashChange = num - this.HistoryGameCash;
        } else {
            this.GameCashChange = 0;
        }
        this.HistoryGameCash = num;

        // 根据存档还原游戏数据集
        if (this.gameStatusData.game_data && this.gameStatusData.game_data.chipsSlotList != null && this.gameStatusData.game_data.chipsSlotList.length > 0) {
            this.mChipsSlotList = [];
            for (let i = 0; i < this.gameStatusData.game_data.chipsSlotList.length; i++) {
                const element = this.gameStatusData.game_data.chipsSlotList[i];
                var slot = new ChipSlot();
                var chipsList = [];
                for (let j = 0; j < element.ChipsList.length; j++) {
                    const element1 = element.ChipsList[j];
                    var chip = new Chip();
                    chip.Init(element1.Id, element1.Type, element1.ChipsSlotId);
                    chipsList.push(chip);
                }

                slot.Init(element.SlotId, element.SlotType, element.SlotSatus, chipsList, this);
                this.mChipsSlotList.push(slot);
            }
        } else {
            this.mChipsSlotList = [];
            // 引导数据
            for (let i = 0; i < GameMgr.Slot_Max_Num; i++) {
                var slot = new ChipSlot();
                let slotConfig = this.getSlotConfigById(i);
                let slotType = slotConfig.unlock_type as ChipSlotType;
                let isUnlock = this.mCurProgress >= slotConfig.unlock_value ? ChipSlotStatus.Unlock : ChipSlotStatus.Lock;
                isUnlock = slotType == ChipSlotType.Temporary ? ChipSlotStatus.Lock : isUnlock;
                slot.Init(i, slotType, isUnlock, [], this);

                if (i < 5) {
                    if (i == 0 || i == 2) {
                        for (let j = 0; j < 5; j++) {
                            var chip = new Chip();
                            chip.Init(10, ChipType.Fixed, 0);
                            slot.Push(chip);
                        }
                    }
                }

                this.mChipsSlotList.push(slot);
            }
        }

        this.setCurProgress(this.mCurProgress);
        this.isInitOk = true;
    }

    private getSlotConfigById(id: number) {
        if (this.mSlotConfig == null) {
            return null;
        }

        let cfg = null;
        for (let key in this.mSlotConfig) {
            if (id == Number(key)) {
                cfg = this.mSlotConfig[key];
                break;
            }
        }

        if (cfg == null) {
            Log.Error(GameMgr.TAG + " getSlotConfigById 未找到对应配置: " + id);
        }

        return cfg;
    }

    public GetRewardConfig(): any {
        for (let key in this.awardConfigJson) {
            Log.Debug(GameMgr.TAG + " 对应配置: " + key);
        }
        return this.awardConfigJson;
    }
    public SaveData() {
        var gameData = {};
        var chipsSlotList = [];

        for (let i = 0; i < this.mChipsSlotList.length; i++) {
            const element = this.mChipsSlotList[i];
            chipsSlotList.push(element.getData());
        }

        gameData["usedShuffCount"] = this.usedShuffCount;
        gameData["chipsSlotList"] = chipsSlotList;
        gameData["targetProgress"] = this.mCurTargetProgress;
        gameData["curProgress"] = this.mCurProgress;
        gameData["usedGameGuideCount"] = this.usedGameGuideCount;
        gameData["usedRemovePropCount"] = this.usedRemovePropCount;

    }

    /**
     * 返回游戏配置数据
     * @returns 
     */
    public getConfigData(): GameConfigData {
        return this.gameStatusData.game_config_json;
    }

    public GetChipsSlotList() {
        return this.mChipsSlotList;
    }

    public GetCurTargetProgress(): number {
        return this.mCurTargetProgress;
    }

    public GetCurProgress() {
        return this.mCurProgress;
    }

    /**
     * 获取筹码填充率
     */
    public getChipFillRate(): number {
        let chipCount = 0;
        let allChipsCount = 0;

        for (let i = 0; i < this.mChipsSlotList.length; i++) {
            let curSlot = this.mChipsSlotList[i];
            if (curSlot.SlotSatus != ChipSlotStatus.Unlock) {
                continue;
            }

            chipCount += curSlot.ChipsList.length;
            allChipsCount += GameMgr.Slot_Chips_Max_Num;
        }

        return chipCount / allChipsCount;
    }

    /**
     * 获取所有棋子所包括的颜色总和
     */
    public getAllChipColorCount(): number {
        let colorsId = new Map<number, number>();
        for (let i = 0; i < this.mChipsSlotList.length; i++) {
            let curSlot = this.mChipsSlotList[i];

            if (curSlot.SlotSatus != ChipSlotStatus.Unlock) {
                continue;
            }

            for (let j = 0; j < curSlot.ChipsList.length; j++) {
                let curChip = curSlot.ChipsList[j];

                let chipId = curChip.Id;

                if (colorsId.has(chipId)) {
                    continue;
                }

                colorsId.set(chipId, 0);
            }
        }

        return colorsId.size;
    }

    // 获取剩余洗牌道具使用次数次数
    public getRemainShuffleTimes(): number {

        if (this.gameStatusData.is_new_user_welfare_received) {
            let curProgress = this.GetCurProgress();
            Log.Debug(GameMgr.TAG + `getRemainShuffleTimes, 当前进度：${curProgress},  useShuffleCount: ${this.usedShuffCount}`);
            if (curProgress <= this.shuffleStartLimitChipsLevel) {
                return -1;
            }

            return Math.max(this.shuffleLimitCount - this.usedShuffCount, 0);
        }

        return Math.max(0, this.propPreWithdrawlUsageCount - this.usedShuffCount);
    }

    //获取剩余移除道具使用次数
    public getRemainRemoveTimes() {
        let curProgress = this.GetCurProgress();

        Log.Debug(GameMgr.TAG + `getRemainRemoveTimes, 当前进度：${curProgress},  usedRemoveCount: ${this.usedRemovePropCount}, isNewUserReceived: ${this.gameStatusData.is_new_user_welfare_received}`);
        if (this.gameStatusData.is_new_user_welfare_received) {

            if (curProgress <= this.removePropStartLimitChipsLevel) {
                return -1;
            }

            return Math.max(this.removePropLimitCount - this.usedRemovePropCount, 0);
        }

        return Math.max(0, this.propPreWithdrawlUsageCount - this.usedRemovePropCount);
    }

    /**
     * 删除值为value以下的chip
     * @param value 
     */
    public removeChipUnderValue(value: number) {
        for (let i = this.mChipsSlotList.length - 1; i >= 0; i--) {
            let curSlot = this.mChipsSlotList[i];
            let slotChips = curSlot.ChipsList;

            for (let j = slotChips.length - 1; j >= 0; j--) {
                let curChip = slotChips[j];

                if (curChip.Id < value) {
                    curSlot.ChipsList.splice(j, 1);
                }
            }
        }

        this.SaveData();
    }

    // 使用一次洗牌
    public UseShuffle() {

        Log.Debug(GameMgr.TAG + "   UseShuffle:   curProgress:  " + this.mCurProgress + "limit:   " + this.shuffleStartLimitChipsLevel);

        if (this.gameStatusData.is_new_user_welfare_received) {
            if (this.mCurProgress > this.shuffleStartLimitChipsLevel) {
                this.usedShuffCount++;
            }
        } else {
            if (this.propPreWithdrawlUsageCount != -1) {
                this.usedShuffCount++;
            }
        }

        this.SaveData();
    }

    /**
     * 移除道具数据更改
     * @param isAuto 是否是合成新数字触发的自动移除，如果是true，那就不减移除道具次数，反之，才去减
     */
    public UseRemoveProp(isAuto: boolean) {

        if (this.gameStatusData.is_new_user_welfare_received) {
            if (this.mCurProgress > this.removePropStartLimitChipsLevel && !isAuto) {
                this.usedRemovePropCount++;
            }
        } else {
            if (this.propPreWithdrawlUsageCount != -1 && !isAuto) {
                this.usedRemovePropCount++;
            }
        }


        this.SaveData();
    }

    dealColorList: number[] = [];

    public setCurProgress(progress: number) {
        this.mCurProgress = progress;
        this.mCurTargetProgress = this.mCurProgress + GameMgr.Unit_Chips_Num;
        this.updateDealColorList();
    }

    public updateDealColorList() {
        let dealColorConfig = this.getDealColorConfig();
        Log.Debug("ChipSlotMgr 发牌逻辑 updateDealColorList this.mCurTargetProgress = " + this.mCurTargetProgress);
        Log.Debug("ChipSlotMgr 发牌逻辑 updateDealColorList dealColorConfig = " + JSON.stringify(dealColorConfig));
        this.dealColorList = Tools.getWeightList(dealColorConfig);
    }

    // 当前棋盘空格子数 注意 不包含临时槽位
    public GetEmptyChipsNum() {
        var num = 0;
        for (let i = 0; i < this.mChipsSlotList.length; i++) {
            const element = this.mChipsSlotList[i];
            if (element.IsUnLock() && element.SlotType != ChipSlotType.Temporary) {
                num += element.GetEmptyNum();
            }
        }

        return num;
    }

    // 洗牌按钮的出现配置
    public GetShuffEmptyNum() {
        return this.mShuffEmptyNum;
    }

    // 游戏内引导间隔
    public GetGameGuideInterval() {
        return this.mGameGuideInterval;
    }

    // 剩余引导次数
    public GetRemainGameGuideCount() {
        return this.mGameGuideCount - this.usedGameGuideCount;
    }

    // 使用引导次数
    public UseGameGuideCount() {
        this.usedGameGuideCount++;
        this.SaveData();
    }

    // 重置游戏
    public ResartGame() {
        this.usedShuffCount = 0;
        this.usedRemovePropCount = 0;
        // 判断是否要保存游戏进度
        if (this.mProgressSwitch) {
            let curProgress = this.GetCurProgress();
            Log.Debug(GameMgr.TAG + " ResartGame 重置游戏 this.mProgressValueList: " + this.mProgressValueList + " this.mCurProgress: " + this.mCurProgress);
            for (let i = 0; i < this.mProgressValueList.length; i++) {
                if (curProgress < this.mProgressValueList[i]) {
                    if (i == 0) {
                        this.mCurProgress = 10;
                        this.mCurTargetProgress = 30;
                        this.updateDealColorList();
                    }
                    else {
                        this.setCurProgress(this.mProgressValueList[i - 1]);
                    }
                    break;
                } else if (i == this.mProgressValueList.length - 1) {
                    this.setCurProgress(this.mProgressValueList[i]);
                }
            }
            Log.Debug(GameMgr.TAG + " ResartGame 重置游戏完成后的 this.mCurProgress: " + this.mCurProgress);
        } else {
            this.mCurProgress = 10;
            this.mCurTargetProgress = 30;
            this.updateDealColorList();
        }

        // 重置棋盘
        let isDiamondUnlock = this.GetChipSlotById(11).IsUnLock();
        this.mChipsSlotList = [];
        for (let i = 0; i < GameMgr.Slot_Max_Num; i++) {
            // 前5个是普通解锁插槽
            var slot = new ChipSlot();
            let slotConfig = this.getSlotConfigById(i);
            let slotType = slotConfig.unlock_type as ChipSlotType;
            let isUnlock = this.mCurProgress >= slotConfig.unlock_value ? ChipSlotStatus.Unlock : ChipSlotStatus.Lock;
            slot.Init(i, slotType, isUnlock, [], this);
            this.mChipsSlotList.push(slot);
        }

        this.DealChips();

        let ComboGroup = cc.find("Canvas/UILayer/HomeUI/GameUI")
        if (ComboGroup) {
            let gameUI = ComboGroup.getComponent(GameUI);
            gameUI.gameOver();
            gameUI.InitView();
        }
        EventCenter.dispatchEvent(EventName.GameOverRefesh);
    }

    // 尝试重置游戏 当用户目标达到120时，强制重置
    public TryResartGame() {
        if (this.mCurProgress >= GameMgr.Max_Chips_Id) {
            this.ResartGame();
        }
    }

    // 找一个未解锁的临时槽位
    public GetLockTempSlotId() {
        for (let i = 0; i < this.mChipsSlotList.length; i++) {
            const element = this.mChipsSlotList[i];
            if (element.SlotType == ChipSlotType.Temporary && element.SlotSatus == ChipSlotStatus.Lock) {
                return element.SlotId;
            }
        }

        return -1;
    }

    // 获取已解锁临时槽位数量
    public GetUnlockTempSlotNum() {
        let num = 0;
        for (let i = 0; i < this.mChipsSlotList.length; i++) {
            const element = this.mChipsSlotList[i];
            if (element.SlotType == ChipSlotType.Temporary && element.SlotSatus == ChipSlotStatus.Unlock) {
                num++;
            }
        }

        return num;
    }

    /**
     * 判断是否可以解锁槽位
     */
    public canUnlockSlot(slotId: number): boolean {
        let slot = this.GetChipSlotById(slotId);

        return slot.SlotSatus == ChipSlotStatus.CanUnLock;
    }

    /**
     * 获取一解锁的槽位数量（不区分槽位类型）
     */
    public getUnlockSlotNum() {
        let num = 0;
        for (let i = 0; i < this.mChipsSlotList.length; i++) {
            const element = this.mChipsSlotList[i];
            if (element.SlotSatus == ChipSlotStatus.Unlock) {
                num++;
            }
        }

        return num;
    }

    // 判断游戏是否over
    public isGameOver() {
        Log.Debug(GameMgr.TAG + " isGameOver ======================= ")
        // 判断当前是否有空格子
        let emptyNum = 0;
        for (let i = 0; i < this.mChipsSlotList.length; i++) {
            const element = this.mChipsSlotList[i];
            if (element.SlotType != ChipSlotType.Temporary && element.SlotSatus == ChipSlotStatus.Unlock) {
                emptyNum += element.GetEmptyNum();
            }
        }
        Log.Debug(GameMgr.TAG + " isGameOver 当前空格子数: " + emptyNum);

        if (emptyNum > 0) {
            return [false, "no"];
        }

        // 当前剩余洗牌数

        //let remainShuffleNum = this.getRemainShuffleTimes();
        // Log.Debug(GameMgr.TAG + " isGameOver 当前剩余洗牌数: " + remainShuffleNum);

        // if (remainShuffleNum == -1) {
        //     return [false, "no"];
        // }

        // if (remainShuffleNum > 0) {
        //     return [false, "no"];
        // }

        // let remainRemoveTimes = this.getRemainRemoveTimes();
        // Log.Debug(GameMgr.TAG + " isGameOver 当前剩余移除道具数量: " + remainRemoveTimes);

        // if (remainRemoveTimes == -1) {
        //     return [false, "no"];
        // }

        // if (remainRemoveTimes > 0) {
        //     return [false, "no"];
        // }

        // 判断是否有可以合并的筹码
        let canMerge = false;
        // 场上有已解锁的临时槽位
        let hasUnLockTempSlot = false;
        let tempUnlockSlot = []
        for (let i = 0; i < this.mChipsSlotList.length; i++) {
            const element = this.mChipsSlotList[i];
            if (element.SlotSatus == ChipSlotStatus.Unlock) {
                if (element.CanMerge()) {
                    canMerge = true;
                    break;
                }
            }

            if (element.SlotType == ChipSlotType.Temporary && element.SlotSatus == ChipSlotStatus.Unlock) {
                hasUnLockTempSlot = true;
                tempUnlockSlot.push(element);
            }
        }
        Log.Debug(GameMgr.TAG + " isGameOver 是否有可以合并的筹码: " + canMerge);
        if (canMerge) {
            return [false, "no"];
        }

        Log.Debug(GameMgr.TAG + " isGameOver 是否有已解锁的临时槽位: " + hasUnLockTempSlot);
        // 场上没有临时槽位，场上其他槽位无剩余空格位，且剩余洗牌次数为0时，通关失败。 
        if (!hasUnLockTempSlot && emptyNum == 0) {
            return [true, "showTemp"];
        }

        // 场上存在临时槽位，场上其他槽位没有剩余空格，剩余洗牌次数为0，且场上筹码无法挪动至临时槽位时，通关失败。
        if (hasUnLockTempSlot && emptyNum == 0) {
            for (let i = 0; i < this.mChipsSlotList.length; i++) {
                const element = this.mChipsSlotList[i];
                // 判断场上其他槽位是否可以移动到临时槽位中
                if (element.SlotType != ChipSlotType.Temporary && element.SlotSatus == ChipSlotStatus.Unlock) {
                    for (let j = 0; j < tempUnlockSlot.length; j++) {
                        if (this.CanMoveChip(element.SlotId, tempUnlockSlot[j].SlotId)) {
                            return [false, "no"];
                        }
                    }
                }
            }

            if (tempUnlockSlot.length == 1) {
                return [true, "showTemp"];
            } else if (tempUnlockSlot.length == 2) {
                // 判断两个临时槽位是否可以移动，并空出一个空位
                let temp1 = tempUnlockSlot[0];
                let temp2 = tempUnlockSlot[1];
                if (temp1.GetLastChipId() == temp2.GetLastChipId() && temp1.GetEmptyNum() + temp2.GetEmptyNum() <= GameMgr.Slot_Chips_Max_Num) {
                    return [false, "no"];
                }
                return [true, "gameOver"];
            }
        }

        return false;
    }

    // 获取chipSlot 通过id
    public GetChipSlotById(id: number) {
        return this.mChipsSlotList.find((element) => {
            return element.SlotId == id;
        });
    }

    // 统计当前棋盘上最大筹码的数量和ID
    public GetMaxChipIdAndNum() {
        let maxId = -1;
        let maxNum = 0;
        for (let i = 0; i < this.mChipsSlotList.length; i++) {
            const element = this.mChipsSlotList[i];
            if (element.IsUnLock()) {
                let chipList = element.ChipsList;
                for (let j = 0; j < chipList.length; j++) {
                    const element1 = chipList[j];
                    if (element1.Id > maxId) {
                        maxId = element1.Id;
                        maxNum = 1;
                    } else if (element1.Id == maxId) {
                        maxNum++;
                    }
                }
            }
        }
        return [maxId, maxNum];
    }

    //#region  发牌逻辑
    public CanDealChips() {
        // 判断是否有空格子
        let num = 0;
        for (let i = 0; i < this.mChipsSlotList.length; i++) {
            const element = this.mChipsSlotList[i];
            if (element.IsUnLock() && element.SlotType != ChipSlotType.Temporary) {
                num += element.GetEmptyNum();
            }
        }

        return num > 0;
    }

    private readonly MixDealNum: number = 4; // 每次最少发牌的数量
    // 发牌
    public DealChips() {
        Log.Debug(GameMgr.TAG + " 发牌逻辑 DealChips ======================= ");

        this.PrintSlotChipsNum();

        //#region ------------- 开始取对应配置 -------------
        // 当前进度
        var curTargetProgress = this.mCurTargetProgress;
        var targetConfig = null;
        var config = this.gameStatusData.game_config_json.deal_config;

        Log.Debug(GameMgr.TAG + " 发牌逻辑 DealChips config ======================= " + JSON.stringify(config));

        for (let key in config) {
            if (curTargetProgress == Number(key)) {
                Log.Debug(GameMgr.TAG + " 发牌逻辑 当前进度: " + curTargetProgress + " 对应配置: " + key);
                targetConfig = config[key];
            }
        }

        // 当前目标进度-10的筹码数量
        let nextTargetItemId = curTargetProgress - 10;
        let nextTargetItemCount = 0;
        for (let i = 0; i < this.mChipsSlotList.length; i++) {
            const element = this.mChipsSlotList[i];
            for (let j = 0; j < element.ChipsList.length; j++) {
                const element1 = element.ChipsList[j];
                if (element1.Id == nextTargetItemId) {
                    nextTargetItemCount++;
                }
            }
        }

        Log.Debug(GameMgr.TAG + " 发牌逻辑 当前目标进度: " + curTargetProgress + " 当前目标进度-10的筹码数量: " + nextTargetItemCount);
        nextTargetItemCount = Math.min(nextTargetItemCount, 10);
        Log.Debug(GameMgr.TAG + " 发牌逻辑 当前目标进度: " + curTargetProgress + " 当前目标进度-10的筹码使用的数量: " + nextTargetItemCount);

        var dealConfig;
        for (let key in targetConfig) {
            let keys = key.split("-");
            let min = Number(keys[0]) == 0 ? -1 : Number(keys[0]);
            if (nextTargetItemCount > min && nextTargetItemCount <= Number(keys[1])) {
                dealConfig = targetConfig[key];
                Log.Debug(GameMgr.TAG + " 发牌逻辑  对应配置: " + key);
            }
        }

        if (dealConfig == null) {
            Log.Debug(GameMgr.TAG + " 发牌逻辑  没有对应配置");
            return null;
        }

        //#endregion ------------- 成功取对应配置 -------------

        //#region  ------------- 开始确定总发牌数量 -------------
        // 计算发牌槽位的数量和总的空位数量
        var tupleEmpty = this.GetHasEmptySlotAndEmptyNum();
        var hasEmptySlotList = tupleEmpty[0] as ChipSlot[];
        var emptyNum: number = tupleEmpty[1] as number;
        var hasEmptySlotNum = hasEmptySlotList.length;
        Log.Debug(GameMgr.TAG + " 发牌逻辑 当前总空格子数: " + emptyNum + " 当前有空格子的槽位数: " + hasEmptySlotNum);

        if (emptyNum == 0) {
            return null;
        }

        var chips_num_map = dealConfig["chips_num"];
        var randomNum = Math.random();
        Log.Debug(GameMgr.TAG + " 随机一个[0,1)之间的数: " + randomNum)
        Log.Debug(GameMgr.TAG + " chips_num_map: " + JSON.stringify(chips_num_map))

        var randomKey = -1;
        for (var key in chips_num_map) {
            Log.Debug(GameMgr.TAG + " 发牌逻辑 ceshisssss 当前空格数: " + key + " 对应的百分比: " + chips_num_map[key]);
            if (randomNum < chips_num_map[key]) {
                randomKey = Number(key);
                break;
            }
        }
        if (randomKey == -1) {
            randomKey = 0.5;
            Log.Debug(GameMgr.TAG + " 发牌逻辑 没有在配置中找到对应的空格数的百分比  强制设置为: " + randomKey);
        }

        Log.Debug(GameMgr.TAG + " 发牌逻辑 获取到当前空格数的百分比: " + randomKey);

        // 总发牌数量
        let num = randomKey * emptyNum;
        // 向上或向下取整
        let random = Math.random();
        if (random < 0.5) {
            num = Math.ceil(num);
        } else {
            num = Math.floor(num);
        }

        let dealChipNum = num;
        if (hasEmptySlotNum == 1) {
            dealChipNum = Math.max(num, 4); // 最少发4个
        } else {
            dealChipNum = Math.max(num, 1); // 最少发1个
        }

        dealChipNum = Math.max(dealChipNum, hasEmptySlotList.length - 1);
        dealChipNum = Math.min(dealChipNum, emptyNum); // 最多发空位数量

        Log.Debug(GameMgr.TAG + " 发牌逻辑 总发牌数量: " + dealChipNum);
        //#endregion ------------- 成功确定总发牌数量 -------------

        //#region  ------------- 开始确定发牌的槽位列表 -------------
        Log.Debug(GameMgr.TAG + "发牌逻辑  -------------开始确定发牌的槽位列表--------------")
        let no_deal_card_trenth = dealConfig["no_deal_card_trenth"];
        let canRemoveSlotList: ChipSlot[] = [];
        for (let i = 0; i < hasEmptySlotList.length; i++) {
            const element = hasEmptySlotList[i];
            let residueNum = emptyNum - element.GetEmptyNum();

            Log.Debug(GameMgr.TAG + " 发牌逻辑 槽位ID: " + element.SlotId + " 总空格数-该槽位空格数=剩余空位数量: " + residueNum + " 发牌总数量: " + dealChipNum);
            if (residueNum >= dealChipNum && element.GetEmptyNum() < GameMgr.Slot_Chips_Max_Num) {
                Log.Debug(GameMgr.TAG + " 发牌逻辑 槽位ID: " + element.SlotId + " 该槽位可以移除");
                canRemoveSlotList.push(element);
            } else {
                Log.Debug(GameMgr.TAG + " 发牌逻辑 槽位ID: " + element.SlotId + " 该槽位空格数: " + element.GetEmptyNum() + " (10表示空槽,则不能移除)")
                Log.Debug(GameMgr.TAG + " 发牌逻辑 槽位ID: " + element.SlotId + " 剩余空位数量: " + residueNum + " （如果小于发牌总量则不能移除）")
                Log.Debug(GameMgr.TAG + " 发牌逻辑 槽位ID: " + element.SlotId + " 该槽位不可以移除");

            }

        }


        Log.Debug(GameMgr.TAG + " 发牌逻辑 可以移除的槽位数量: " + canRemoveSlotList.length);
        for (let i = 0; i < canRemoveSlotList.length; i++) {
            Log.Debug(GameMgr.TAG + " 发牌逻辑 可以移除的槽位ID: " + canRemoveSlotList[i].SlotId + " lastChipId:" + canRemoveSlotList[i].GetLastChipId());
        }

        Log.Debug(GameMgr.TAG + " 发牌逻辑 移除槽位策略: " + no_deal_card_trenth);

        let removeSlotId = -1;
        if (canRemoveSlotList.length > 1) {
            let lastMaxId = -1;
            let lastMinId = 10000;
            for (let i = 0; i < canRemoveSlotList.length; i++) {
                const element = canRemoveSlotList[i];
                if (element.GetLastChipId() > lastMaxId) {
                    lastMaxId = element.GetLastChipId();
                }

                if (element.GetLastChipId() < lastMinId) {
                    lastMinId = element.GetLastChipId();
                }
            }

            Log.Debug(GameMgr.TAG + " 发牌逻辑 aaaaaaaaaaaaa 移除槽位策略: " + no_deal_card_trenth + " 最大值: " + lastMaxId + " 最小值: " + lastMinId);
            // 有多个空位的情况
            if (no_deal_card_trenth == "big") {
                // 不发牌的槽位最后一个值最大
                let lastMaxSlotList: number[] = [];
                for (let i = 0; i < canRemoveSlotList.length; i++) {
                    const element = canRemoveSlotList[i];
                    if (element.GetLastChipId() == lastMaxId && element.GetLastChipId() != 0) {
                        lastMaxSlotList.push(element.SlotId);
                    }
                }

                // 随机一个槽位
                if (lastMaxSlotList.length == 0) {
                    Log.Debug(GameMgr.TAG + " 发牌逻辑 移除槽位策略: " + no_deal_card_trenth + " 不可能走到该分支, 出现该打印的话直接提jira");

                    let randomIndex = Math.floor(Math.random() * canRemoveSlotList.length);
                    removeSlotId = canRemoveSlotList[randomIndex].SlotId;
                } else {
                    let randomIndex = Math.floor(Math.random() * lastMaxSlotList.length);
                    removeSlotId = lastMaxSlotList[randomIndex];
                    Log.Debug(GameMgr.TAG + " 发牌逻辑 移除槽位策略: " + no_deal_card_trenth + " 随机一个槽位: " + removeSlotId);

                }

                Log.Debug(GameMgr.TAG + " 发牌逻辑 移除槽位策略: " + no_deal_card_trenth + " 移除槽位ID: " + removeSlotId);

            } else {
                let lastMinSlotList: number[] = [];
                for (let i = 0; i < canRemoveSlotList.length; i++) {
                    const element = canRemoveSlotList[i];
                    if (element.GetLastChipId() == lastMinId && element.GetLastChipId() != 0) {
                        lastMinSlotList.push(element.SlotId);
                    }
                }

                // 随机一个槽位
                if (lastMinSlotList.length == 0) {
                    Log.Debug(GameMgr.TAG + " 发牌逻辑 移除槽位策略: " + no_deal_card_trenth + " 不可能走到该分支, 出现该打印的话直接提jira");
                    let randomIndex = Math.floor(Math.random() * canRemoveSlotList.length);
                    removeSlotId = canRemoveSlotList[randomIndex].SlotId;
                } else {
                    let randomIndex = Math.floor(Math.random() * lastMinSlotList.length);
                    removeSlotId = lastMinSlotList[randomIndex];
                    Log.Debug(GameMgr.TAG + " 发牌逻辑 移除槽位策略: " + no_deal_card_trenth + " 随机一个槽位: " + removeSlotId);

                }
            }
            Log.Debug(GameMgr.TAG + " 发牌逻辑 移除槽位策略: " + no_deal_card_trenth + " 移除槽位ID: " + removeSlotId);
        }

        if (canRemoveSlotList.length == 1) {
            removeSlotId = canRemoveSlotList[0].SlotId;
        }

        if (canRemoveSlotList.length == 0 && hasEmptySlotList.length > 1) {
            // 没有可以移除的槽位
            Log.Debug(GameMgr.TAG + " 发牌逻辑 没有可以移除的槽位, 此时需要注意看下槽位是否都是空的");
        }

        let dealSlotList: ChipSlot[] = [];
        for (let i = 0; i < hasEmptySlotList.length; i++) {
            const element = hasEmptySlotList[i];
            if (element.SlotId != removeSlotId) {
                dealSlotList.push(element);
            }
        }

        Log.Debug(GameMgr.TAG + " 发牌逻辑 最终发牌的槽位数量: " + dealSlotList.length);
        for (let i = 0; i < dealSlotList.length; i++) {
            const element = dealSlotList[i];
            Log.Debug(GameMgr.TAG + " 发牌逻辑 最终发牌的槽位ID: " + element.SlotId);
        }

        //#endregion ------------- 成功确定发牌的槽位列表 -------------

        //#region ------------- 开始确定每个槽位发牌数量 -------------
        Log.Debug(GameMgr.TAG + " 发牌逻辑 -------------开始确定每个槽位发牌数量--------------");
        // 每个槽位的平均发牌数
        let avgNum = Math.floor(dealChipNum / dealSlotList.length);
        Log.Debug(GameMgr.TAG + " 发牌逻辑 平均发牌数量(向下取整): " + avgNum);
        // 随机对avgNum进行加减2
        let dealSlotNumMap = new Map<number, number>();
        let tempNum = 0;
        for (let i = 0; i < dealSlotList.length; i++) {
            const element = dealSlotList[i];
            let num = Math.max((Math.random() * 4) - 2 + avgNum, 1);
            num = Math.min(num, element.GetEmptyNum());
            num = Math.ceil(num);

            tempNum += num;
            dealSlotNumMap.set(element.SlotId, num);

            Log.Debug(GameMgr.TAG + " 发牌逻辑 初步确定每个槽位发牌数: " + num + " 槽位ID: " + element.SlotId);
        }

        Log.Debug(GameMgr.TAG + " 发牌逻辑 初步确定每个槽位发牌数量总数: " + tempNum + " 规定总发牌数量: " + dealChipNum);

        // 剩余的发牌数量
        let residueNum = dealChipNum - tempNum;
        if (residueNum > 0) {
            Log.Debug(GameMgr.TAG + " 发牌逻辑 目前少发牌数: " + residueNum);
            // 随机槽位发剩余的牌
            while (residueNum > 0) {
                let randomIndex = Math.floor(Math.random() * dealSlotList.length);
                let slot = dealSlotList[randomIndex];
                let num = dealSlotNumMap.get(slot.SlotId);

                // 判断是否可以发牌
                if (slot.GetEmptyNum() - num > 0) {
                    num++;
                    dealSlotNumMap.set(slot.SlotId, num);
                    residueNum--;
                    Log.Debug(GameMgr.TAG + " 发牌逻辑 补发牌的槽位ID: " + slot.SlotId + " 补发牌后数量: " + num);
                }
            }
        } else if (residueNum < 0) {
            // 随机槽位减去剩余的牌
            Log.Debug(GameMgr.TAG + " 发牌逻辑 目前多发牌数: " + -residueNum);
            while (residueNum < 0) {
                let randomIndex = Math.floor(Math.random() * dealSlotList.length);
                let slot = dealSlotList[randomIndex];
                let num = dealSlotNumMap.get(slot.SlotId);

                // 判断是否可以发牌
                if (num > 1) {
                    num--;
                    dealSlotNumMap.set(slot.SlotId, num);
                    residueNum++;
                    Log.Debug(GameMgr.TAG + " 发牌逻辑 移除发牌的槽位ID: " + slot.SlotId + " 移除发牌后数量: " + num);
                }
            }
        }
        // 打印每个槽位发牌数量
        Log.Debug(GameMgr.TAG + " 发牌逻辑 最终确定每个槽位发牌数量");
        for (let [key, value] of Array.from(dealSlotNumMap.entries())) {
            Log.Debug(GameMgr.TAG + " 发牌逻辑 槽位ID: " + key + " 该槽位发牌数量: " + value);
        }


        //#endregion ------------- 成功确定每个槽位发牌数量 -------------

        //#region ------------- 开始确定每个槽位发牌的颜色 -------------
        Log.Debug(GameMgr.TAG + " 发牌逻辑 发牌的颜色 -------------开始确定每个槽位发牌的颜色-------------===========================-");
        var dealChipMap = new Map<number, Chip[]>();
        for (let [key, value] of Array.from(dealSlotNumMap.entries())) {
            // 随机发牌策略
            let strategyConfig = dealConfig["strategy"];
            let strategy;
            let randomNum = Math.random();
            Log.Debug(GameMgr.TAG + " 发牌逻辑 发牌的颜色 随机一个[0,1)之间的数: " + randomNum + " 槽位ID: " + key + " ++++++++++++++++++++++++++++++ ")
            Log.Debug(GameMgr.TAG + " 发牌逻辑 发牌的颜色 strategy: " + JSON.stringify(strategyConfig))
            for (let k in strategyConfig) {
                let v = strategyConfig[k];
                if (randomNum < v) {
                    strategy = k;
                    break;
                }
            }
            Log.Debug(GameMgr.TAG + " 发牌逻辑 发牌的颜色 获取到当前的武器策略: " + strategy);

            let slot = this.GetChipSlotById(key);
            // 根据发牌策略获取发牌颜色
            let tuple = this.GetDealChipByStrategy(strategy, value, key);
            let colorNumMap = tuple[0];
            let colorList = tuple[1] as number[];

            dealChipMap.set(key, []);
            for (let i = 0; i < colorList.length; i++) {

                let color = colorList[i];
                let num = colorNumMap.get(color);

                for (let j = 0; j < num; j++) {
                    if (slot.GetEmptyNum() > 0) {
                        var chip = new Chip();
                        chip.Init(color, ChipType.Fixed, key);
                        dealChipMap.get(key).push(chip);
                        slot.Push(chip);
                    }
                }
            }
        }

        Log.Debug(GameMgr.TAG + " 发牌逻辑 最终确定每个槽位发牌的颜色---------");
        for (let [key, value] of Array.from(dealChipMap.entries())) {
            Log.Debug(GameMgr.TAG + " 发牌逻辑 发牌的颜色 -------槽位ID: " + key + " 发牌数量: " + value.length);
            for (let i = 0; i < value.length; i++) {
                const element = value[i];
                Log.Debug(GameMgr.TAG + " 发牌逻辑 发牌的颜色 ++++++++槽位ID: " + key + " 发牌颜色: " + element.Id);
            }
        }
        this.GetMaxChipIdAndNum();
        this.SaveData();

        return dealChipMap;

        //#endregion ------------- 开始确定每个槽位发牌的颜色 -------------


    }

    public GuideDealChips() {
        Log.Debug(GameMgr.TAG + " 引导发牌逻辑 DealChips ======================= ");
        var dealChipMap = new Map<number, Chip[]>();

        let slot1Id = 0;
        var slot1 = this.GetChipSlotById(slot1Id);
        dealChipMap.set(slot1Id, []);
        for (let i = 0; i < 3; i++) {
            if (slot1.GetEmptyNum() > 0) {
                var chip = new Chip();
                chip.Init(20, ChipType.Fixed, i);
                dealChipMap.get(slot1Id).push(chip);
                slot1.Push(chip);
            }
        }

        let slot2Id = 1;
        let slot2 = this.GetChipSlotById(slot2Id);
        dealChipMap.set(slot2Id, []);
        for (let i = 0; i < 5; i++) {
            if (slot2.GetEmptyNum() > 0) {
                var chip = new Chip();
                chip.Init(20, ChipType.Fixed, i);
                dealChipMap.get(slot2Id).push(chip);
                slot2.Push(chip);
            }
        }

        Log.Debug(GameMgr.TAG + " 引导发牌逻辑 最终确定每个槽位发牌的颜色---------");
        for (let [key, value] of Array.from(dealChipMap.entries())) {
            Log.Debug(GameMgr.TAG + " 引导发牌逻辑 -------槽位ID: " + key + " 发牌数量: " + value.length);
            for (let i = 0; i < value.length; i++) {
                const element = value[i];
                Log.Debug(GameMgr.TAG + " 引导发牌逻辑 ++++++++槽位ID: " + key + " 发牌颜色: " + element.Id);
            }
        }

        this.SaveData();

        return dealChipMap;
    }

    // 根据发牌策略获取发牌颜色
    public GetDealChipByStrategy(strategy: string, dealNum: number, slotId: number) {
        Log.Debug(GameMgr.TAG + " 发牌逻辑 发牌的颜色 根据发牌策略获取发牌颜色 strategy: " + strategy + " dealNum: " + dealNum + " slotId: " + slotId);
        var needNextStrategy = false;
        var tuple;
        if (strategy == "no_match_color_3") {
            Log.Debug(GameMgr.TAG + " 发牌逻辑 发牌的颜色 根据发牌策略获取发牌颜色 no_match_color_3");
            // 随机发牌策略
            if (dealNum < 3) {
                needNextStrategy = true;
                Log.Debug(GameMgr.TAG + " 发牌逻辑 发牌的颜色 该槽位发牌数量小于3, 选择武器策略no_match_color_2");
            } else {
                needNextStrategy = false;
                tuple = this.NoMatchStrategy(dealNum, slotId, 3);
            }
        }

        if (strategy == "no_match_color_2" || needNextStrategy) {
            Log.Debug(GameMgr.TAG + " 发牌逻辑 发牌的颜色 根据发牌策略获取发牌颜色 no_match_color_2");
            if (dealNum < 2) {
                needNextStrategy = true;
                Log.Debug(GameMgr.TAG + " 发牌逻辑 发牌的颜色 该槽位发牌数量小于3, 选择武器策略no_match_color_1");

            } else {
                needNextStrategy = false;
                tuple = this.NoMatchStrategy(dealNum, slotId, 2);
            }
        }

        if (strategy == "no_match_color_1" || needNextStrategy) {
            Log.Debug(GameMgr.TAG + " 发牌逻辑 发牌的颜色 根据发牌策略获取发牌颜色 no_match_color_1");
            if (dealNum < 1) {
                needNextStrategy = true;
                Log.Debug(GameMgr.TAG + " 发牌逻辑 发牌的颜色 该槽位发牌数小于1,不可能发生, 有打印,提jira");

            } else {
                needNextStrategy = false;
                tuple = this.NoMatchStrategy(dealNum, slotId, 1);
            }
        }

        if (strategy == "match" || needNextStrategy) {
            Log.Debug(GameMgr.TAG + " 发牌逻辑 发牌的颜色 根据发牌策略获取发牌颜色 match");
            // 随机发牌策略
            tuple = this.MatchStrategy(dealNum, slotId);
        }
        var slot = this.GetChipSlotById(slotId);
        var lastChipId = slot.GetLastChipId();
        Log.Debug(GameMgr.TAG + " 发牌逻辑 发牌的颜色 根据发牌策略获取发牌颜色end strategy: " + strategy + " dealNum: " + dealNum + " slotId: " + slotId + " lastChipId:" + lastChipId);
        Log.Debug(GameMgr.TAG + " 发牌逻辑 发牌的颜色 根据发牌策略获取发牌颜色end tuple : " + tuple)
        let colorNumMap = tuple[0] as Map<number, number>;
        // 打印colorNumMap
        for (let [key, value] of Array.from(colorNumMap.entries())) {
            Log.Debug(GameMgr.TAG + " 发牌逻辑 发牌的颜色 根据发牌策略获取发牌颜色end colorNumMap key: " + key + " value: " + value);
        }

        return tuple;
    }

    private MatchStrategy(dealNum: number, slotId: number) {
        var colorNumMap = new Map<number, number>();
        var slot = this.GetChipSlotById(slotId);
        var lastChipId = slot.GetLastChipId();
        Log.Debug(GameMgr.TAG + " 发牌逻辑  发牌的颜色 MatchStrategy  dealNum: " + dealNum + " slotId: " + slotId + " slotlastId: " + lastChipId);

        if (!this.checkColorIdInDealColorConfig(lastChipId)) {
            return this.NoMatchStrategy(dealNum, slotId, 1);
        } else {
            if (lastChipId == 0) {
                lastChipId = this.GetRandomDealChipColor(0);
                Log.Debug(GameMgr.TAG + " 发牌逻辑 发牌的颜色  触发Match空槽位发牌策略  随机出的颜色值： " + lastChipId);

            }
            colorNumMap.set(lastChipId, dealNum);
            return [colorNumMap, [lastChipId]];
        }
    }

    private NoMatchStrategy(dealNum: number, slotId: number, noMatchNum: number) {
        Log.Debug(GameMgr.TAG + " 发牌逻辑 发牌的颜色  NoMatchStrategy  dealNum: " + dealNum + " slotId: " + slotId + " noMatchNum: " + noMatchNum);
        var colorNumMap = new Map<number, number>();
        var slot = this.GetChipSlotById(slotId);
        var lastChipId = slot.GetLastChipId();

        var colorList: number[] = [];
        var tempChipId = lastChipId;
        for (let i = 0; i < noMatchNum; i++) {
            var randomColor = this.GetRandomDealChipColor(tempChipId);
            tempChipId = randomColor;
            colorList.push(randomColor);
        }

        Log.Debug(GameMgr.TAG + " 发牌逻辑 发牌的颜色 NoMatchStrategy  随机发牌颜色: " + colorList + " slotID = " + slotId);

        // 确定每个颜色的数量
        var arg = Math.floor(dealNum / noMatchNum);
        var residueNum = dealNum % noMatchNum;

        for (let i = 0; i < colorList.length; i++) {
            let element = colorList[i];
            Log.Debug(GameMgr.TAG + " 发牌逻辑 发牌的颜色 NoMatchStrategy  colorNumMap  key:" + element + " num = " + arg);
            colorNumMap.set(element, arg);
        }

        // 将剩余的数量随机分配给3个颜色
        while (residueNum > 0) {
            var temp = colorList[Math.floor(Math.random() * colorList.length)];
            var num = colorNumMap.get(temp);
            num++;
            colorNumMap.set(temp, num);
            residueNum--;
        }

        // 打印
        for (let [key, value] of Array.from(colorNumMap.entries())) {
            Log.Debug(GameMgr.TAG + " 发牌逻辑 发牌的颜色 NoMatchStrategy  colorNumMap  key:" + key + " value = " + value);
        }

        return [colorNumMap, colorList];
    }

    // 获取随机发牌颜色
    public GetRandomDealChipColor(chipid: number) {
        // 随机一个不是chipid的颜色
        let newList = this.dealColorList.filter(item => item != chipid);
        if (newList.length == 0) {
            Log.Debug(GameMgr.TAG + " 发牌逻辑 发牌的颜色  随机一个不是chipid的颜色  没有找到对应的颜色  chipid: " + chipid);
            Log.Debug(GameMgr.TAG + " 发牌逻辑 需要查看当前发牌配置和发牌颜色配置");
            return chipid;
        }
        var random = Math.floor(Math.random() * newList.length);
        var randomColorId = this.dealColorList[random];

        Log.Debug(GameMgr.TAG + " 发牌逻辑 发牌的颜色 随机发牌颜色=========================: " + randomColorId);
        return randomColorId;
    }

    public getDealColorConfig() {
        let colorConfig = this.mGameConfigJson.deal_color_config;
        let configStr = "10:20;20:20;30:20";
        for (let key in colorConfig) {
            if (this.mCurTargetProgress == Number(key)) {
                configStr = colorConfig[key];
                break;
            }
        }
        Log.Debug(GameMgr.TAG + " 发牌逻辑 获取发牌颜色配置: " + configStr);
        return configStr;
    }

    public checkColorIdInDealColorConfig(colorId: number) {
        let dealColorConfig = this.getDealColorConfig();
        let colorIdList = dealColorConfig.split(";");
        for (let i = 0; i < colorIdList.length; i++) {
            let temp = colorIdList[i].split(":");
            if (Number(temp[0]) == colorId) {
                return true;
            }
        }

        return false;
    }

    // 计算当前有空格子槽位和空格子数量
    public GetHasEmptySlotAndEmptyNum() {
        var emptyNum = 0;
        var emptySlotList: ChipSlot[] = [];
        for (let i = 0; i < this.mChipsSlotList.length; i++) {
            const element = this.mChipsSlotList[i];
            if (element.SlotSatus == ChipSlotStatus.Unlock &&
                element.SlotType != ChipSlotType.Temporary &&
                element.GetEmptyNum() > 0) {
                emptySlotList.push(element);
                emptyNum += element.GetEmptyNum();
            }
        }

        return [emptySlotList, emptyNum];
    }

    //#endregion

    //#region  移动逻辑
    // 判断是否可以移动chip
    public CanMoveChip(from: number, to: number) {
        var fromSlot = this.GetChipSlotById(from);
        var toSlot = this.GetChipSlotById(to);
        if (fromSlot == null || toSlot == null) {
            return false;
        }
        var fromId = fromSlot.GetCanMoveArray()[1];
        return toSlot.CanPush(fromId);
    }

    // 移动chip
    public MoveChip(from: number, to: number) {
        var fromSlot = this.GetChipSlotById(from);
        var toSlot = this.GetChipSlotById(to);
        if (fromSlot == null || toSlot == null) {
            return false;
        }

        var tuple = toSlot.CanPushChipsIdAndCount();
        var id = tuple[0];
        var count = tuple[1];
        var chipsList = fromSlot.PopList(count);

        toSlot.PushList(chipsList);

        if (fromSlot.SlotType == ChipSlotType.Temporary && fromSlot.GetEmptyNum() == GameMgr.Slot_Chips_Max_Num) {
            fromSlot.SlotSatus = ChipSlotStatus.Lock;
        }

        this.SaveData();

        return chipsList;
    }

    //#endregion

    //#region  合成逻辑
    // 判断是否可以合成
    public CanMergeChip(slotId: number) {
        var slot = this.GetChipSlotById(slotId);
        if (slot == null) {
            return false;
        }

        return slot.CanMerge();
    }

    // 判断场上是否有可以合成的槽位
    public CanMergeSlot() {
        for (let i = 0; i < this.mChipsSlotList.length; i++) {
            const element = this.mChipsSlotList[i];
            if (this.CanMergeChip(element.SlotId)) {
                return true;
            }
        }

        return false;
    }

    public CheckCanAutoMerge() {
        if (this.gameStatusData.auto_merge_chips_switch) {
            if (this.CanMergeSlot()) {
                Log.Debug(GameMgr.TAG + " CheckCanAutoMerge 有可以合成的槽位");
                return true;
            }
            Log.Debug(GameMgr.TAG + " CheckCanAutoMerge 没有可以合成的槽位");
        }
        return false;
    }

    // 打印每个槽位当前的棋子数量
    public PrintSlotChipsNum() {
        for (let i = 0; i < this.mChipsSlotList.length; i++) {
            const element = this.mChipsSlotList[i];
            Log.Debug(GameMgr.TAG + "打印每个槽位当前的棋子数量 slotId: " + element.SlotId + " chipsNum: " + element.ChipsList.length + " 解锁状态 :" + element.SlotSatus + " 槽位类型: " + element.SlotType);
        }
    }

    // 合成

    public unlockSlotId = -1;
    public Merge() {
        this.PrintSlotChipsNum();
        var mergeChipMap: Map<number, Chip[]> = new Map<number, Chip[]>();
        Log.Debug(GameMgr.TAG + " Merge 开始合成 ======================= ");
        let red_packet_reward = 0;
        let rewardMap = {};
        let tempMerge = false;
        let otherMerge = false;
        for (let i = 0; i < this.mChipsSlotList.length; i++) {
            const element = this.mChipsSlotList[i];
            if (element.SlotSatus == ChipSlotStatus.Lock) {
                continue;
            }
            Log.Debug(GameMgr.TAG + " Merge 合成 slotId: " + element.SlotId + " num = " + element.ChipsList.length);
            if (element.CanMerge()) {
                var newId = element.Merge();
                // 是否更新目标进度
                Log.Debug(GameMgr.TAG + " Merge 合成 newId: " + newId + " mCurProgress: " + this.mCurProgress);
                if (newId > this.mCurProgress) {
                    this.mCurProgress = newId;
                    this.setCurProgress(newId);
                    this.TryChangeTargerProgress();
                    this.unlockSlotId = this.TryUnlockSlot();
                }

                if (element.SlotType == ChipSlotType.Temporary) {
                    tempMerge = true;
                } else {
                    otherMerge = true;
                }
                mergeChipMap.set(element.SlotId, element.ChipsList);
                red_packet_reward += this.GetMergerReward(newId);
                if (rewardMap[newId] == null) {
                    rewardMap[newId] = 1;
                } else {
                    rewardMap[newId] += 1;
                }
            }
        }

        this.GetMaxChipIdAndNum();
        this.SaveData();
        return mergeChipMap;
    }

    // 临时插槽合成之后需要找到一个永久或session槽位将临时槽位的棋子移动过去
    public MoveTempSlotChip(slotId: number) {
        let moveToSlotId = -1;
        var slot = this.GetChipSlotById(slotId);
        if (slot.SlotType == ChipSlotType.Temporary) {
            Log.Debug(GameMgr.TAG + " MoveTempSlotChip 临时插槽合成之后需要找到一个永久或session槽位将临时槽位的棋子移动过去 slotId: " + slotId);
            for (let i = 0; i < this.mChipsSlotList.length; i++) {
                const element = this.mChipsSlotList[i];
                if (element.SlotSatus != ChipSlotStatus.Unlock) {
                    continue;
                }

                if (element.SlotType == ChipSlotType.Temporary) {
                    continue;
                }
                Log.Debug(GameMgr.TAG + " MoveTempSlotChip=======  i: " + i + " SlotSatus: " + element.SlotSatus + " SlotType: " + element.SlotType)

                Log.Debug(GameMgr.TAG + " MoveTempSlotChip  i: " + i + " GetLastChipId: " + slot.GetLastChipId());
                if (element.GetEmptyNum() >= 2) {
                    moveToSlotId = element.SlotId;
                    break;
                }
            }
        }

        Log.Debug(GameMgr.TAG + " MoveTempSlotChip 临时插槽合成之后需要找到一个永久或session槽位将临时槽位的棋子移动过去 slotId: " + slotId + " moveToSlotId: " + moveToSlotId);
        return moveToSlotId;
    }

    // 计算合成奖励
    public GetMergerReward(chipId: number): number {
        var reward = 0;
        //chip5_k加入
        let chipAfter5_reward_config = this.gameStatusData.game_config_json.after5_compo_reward;
        let hasNew = false;

        let historyMax = NativeApi.instance.getHistoryMaxChipNum();

        if ((chipAfter5_reward_config != null) && historyMax >= 50) {
            for (let key in chipAfter5_reward_config) {
                if (chipId == Number(key)) {
                    reward = chipAfter5_reward_config[key] as number;
                    hasNew = true;
                    break;
                }
            }
        }

        if (hasNew) {
            Log.Debug(`[GameMgr]  GetMergetReward  has new config:   chipId: ${chipId},  reward:  ${reward}`);
            return reward;
        }

        //旧有的
        let chips_reward_config = this.gameStatusData.game_config_json.chips_reward_config;
        for (let key in chips_reward_config) {
            if (chipId == Number(key)) {
                reward = chips_reward_config[key];
                break;
            }
        }
        Log.Debug(`[GameMgr]  GetMergetReward  old config:   chipId: ${chipId},  reward:  ${reward}`);
        return reward;
    }

    //#endregion

    //#region  洗牌
    // 判断是否可以出现洗牌功能
    private shuffEmptyNum: number = 6; //
    public CanShuffleBtnShow() {
        // 场上所有空位数量
        var emptyNum = 0;
        for (let i = 0; i < this.mChipsSlotList.length; i++) {
            const element = this.mChipsSlotList[i];
            if (element.SlotSatus == ChipSlotStatus.Unlock) {
                emptyNum += element.GetEmptyNum();
            }
        }

        return this.shuffEmptyNum >= emptyNum;
    }

    // 洗牌
    public Shuffle() {
        // 洗牌将场上除临时槽位以外的所有筹码，按种类每个栏中分入1种筹码。
        // 特殊情况：每种筹码最多保留10个。如果场上棋子种类多余栏位数，则去除最小的种类。【棋子数-栏位数=n，则去除n种最小的棋子】
        // 临时槽位中的棋子不参与洗牌。
        var slotNum = 0;
        var chipMap = new Map<number, Chip[]>();
        for (let i = 0; i < this.mChipsSlotList.length; i++) {
            const element = this.mChipsSlotList[i];
            if (element.SlotSatus == ChipSlotStatus.Unlock && element.SlotType != ChipSlotType.Temporary) {
                var chipList = element.ChipsList;
                for (let j = 0; j < chipList.length; j++) {
                    const element1 = chipList[j];
                    if (chipMap.has(element1.Id)) {
                        if (chipMap.get(element1.Id).length < GameMgr.Slot_Chips_Max_Num) {
                            chipMap.get(element1.Id).push(element1);
                        }
                    } else {
                        chipMap.set(element1.Id, [element1]);
                    }
                }
                slotNum++;
            }
        }

        Log.Debug("洗牌前 棋盘上有的筹码种类数量  chipTypeNum: " + chipMap.size + " 当前解锁的槽位数量: " + slotNum);
        // 【棋子数-栏位数=n，则去除n种最小的棋子】
        let deleteList: number[] = []
        while (chipMap.size > slotNum) {
            var minId = -1;
            var maxId = -1;
            for (let [key, value] of Array.from(chipMap.entries())) {
                if (minId == -1) {
                    minId = key;
                } else {
                    if (minId > key) {
                        minId = key;
                    }
                }

                if (maxId == -1) {
                    maxId = key;
                } else {
                    if (maxId < key) {
                        maxId = key;
                    }
                }
            }


            Log.Debug("洗牌前  需要删除一个最小的筹码类型 chipId: " + minId);
            chipMap.delete(minId);
            deleteList.push(minId);
        }

        Log.Debug("洗牌前  开始洗牌 chipTypeNum :" + chipMap.size);
        for (let i = 0; i < this.mChipsSlotList.length; i++) {
            let slot = this.mChipsSlotList[i];
            if (slot.SlotType != ChipSlotType.Temporary) {
                this.mChipsSlotList[i].ChipsList = []
            }
        }

        for (let [key, value] of Array.from(chipMap.entries())) {
            Log.Debug("洗牌后 chipmap  key: " + key + " value: " + value.length);
            for (let i = 0; i < this.mChipsSlotList.length; i++) {
                let slot = this.mChipsSlotList[i];
                if (slot.IsUnLock() && slot.SlotType != ChipSlotType.Temporary && slot.GetEmptyNum() == GameMgr.Slot_Chips_Max_Num) {
                    slot.ChipsList = value;
                    break;
                }
            }

        }

        for (let i = 0; i < this.mChipsSlotList.length; i++) {
            let slot = this.mChipsSlotList[i];
            Log.Debug("洗牌后 mChipsSlotList 数据  插槽ID: " + slot.SlotId + " 插槽筹码数量: " + slot.ChipsList.length + "筹码id: " + slot.ChipsList[0]?.Id);
        }

        this.UseShuffle();
        this.SaveData();

        return deleteList;

    }

    //#endregion 解锁槽位

    //#region 

    private getSlotUnlockProgress(slotId: number) {
        let cfg = this.getSlotConfigById(slotId);
        if (cfg != null) {
            return cfg.unlock_value;
        }
        return 100000;
    }
    //  解锁插槽 每次合成之后尝试解锁
    public TryUnlockSlot(): number {
        for (let i = 0; i < GameMgr.Slot_Max_Num; i++) {
            var element = this.mChipsSlotList[i];
            if (element.SlotSatus == ChipSlotStatus.Lock) {
                var unlockProgress = this.getSlotUnlockProgress(i);
                if (this.mCurProgress >= unlockProgress) {
                    element.SlotSatus = ChipSlotStatus.CanUnLock;

                    this.SaveData();
                    Log.Debug(GameMgr.TAG + " 解锁插槽 槽位ID: " + element.SlotId + " 解锁进度: " + unlockProgress);
                    return element.SlotId;
                }
            }
        }
        return -1;
    }

    // 获取解锁下一槽位的进度
    public GetNextUnlockSlotProgress() {
        for (let i = 5; i < 9; i++) {
            var element = this.mChipsSlotList[i];
            if (element.SlotSatus == ChipSlotStatus.Lock) {
                var unlockProgress = this.getSlotUnlockProgress(i);
                return unlockProgress;
            }
        }

        return 0;
    }

    public TryChangeTargerProgress() {

        if (this.mCurTargetProgress <= this.mCurProgress + 10) {
            this.mCurTargetProgress = this.mCurProgress + 10;

            // 已经合成了最大chipID则重新开始游戏
            if (this.mCurTargetProgress < GameMgr.Max_Chips_Id + 10) {
                EventCenter.dispatchEvent(EventName.RefreshProgress);
                this.SaveData();
            }
        }

    }

    // 解锁永久槽位
    public UnlockPermanentSlot() {
        var element = this.mChipsSlotList[11];
        element.SlotSatus = ChipSlotStatus.Unlock;

        let ComboGroup = cc.find("Canvas/UILayer/HomeUI/GameUI")
        ComboGroup.getComponent(GameUI).unlockSlot(11);
        this.SaveData();
        Log.Debug(GameMgr.TAG + " 解锁永久槽位 槽位ID: " + element.SlotId);
    }

    // 解锁临时槽位
    public UnlockTemporarySlot(slotId: number) {
        if (slotId < 9 || slotId > 10) {
            Log.Debug(GameMgr.TAG + " 解锁临时槽位 槽位ID: " + slotId + " 不是临时槽位");
            return;
        }
        var element = this.mChipsSlotList[slotId];
        element.SlotSatus = ChipSlotStatus.Unlock;
        let ComboGroup = cc.find("Canvas/UILayer/HomeUI/GameUI")
        ComboGroup.getComponent(GameUI).unlockSlot(slotId);
        this.SaveData();
        Log.Debug(GameMgr.TAG + " 解锁临时槽位 槽位ID: " + element.SlotId);
    }

    public RefreshCurrencyData: RefreshCurrencyValue = { red_packet_value: 0, game_diamond_value: 0, show_delta: true };
    public isShowAdd = false;
    public OnRefreshCurrencyValueEvent(data: RefreshCurrencyValue) {
        this.RefreshCurrencyData = data;
        this.isShowAdd = this.RefreshCurrencyData.show_delta;
        let num = this.RefreshCurrencyData.red_packet_value;
        if (this.HistoryRedPacket > 0 && this.HistoryRedPacket != num) {
            this.RedPacketChange = num - this.HistoryRedPacket;
        } else {
            this.RedPacketChange = 0;
        }

        this.HistoryRedPacket = num;


        num = this.RefreshCurrencyData.game_diamond_value;
        if (this.HistoryGameCash > 0 && this.HistoryGameCash != num) {
            this.GameCashChange = num - this.HistoryGameCash;
        } else {
            this.GameCashChange = 0;
        }
        this.HistoryGameCash = num;
        Log.Debug(`[CHECK] OnRefreshCurrencyValueEvent coin input : ${this.RefreshCurrencyData.red_packet_value}, change : ${this.RedPacketChange}, history_coin : ${this.HistoryRedPacket}`);

        if (this.HistoryGameCash > 0) {
            EventCenter.dispatchEvent(EventName.UpdateCoinInfo);
        } else {
            EventCenter.dispatchEvent(EventName.UpdateCoinInfo);
        }

        if (this.HistoryRedPacket >= 0) {
            EventCenter.dispatchEvent(EventName.UpdateRedInfo);
        }

    }

    //#endregion

    /**
     * 领取新人福利金
     */
    public receiveNewUserWelfare() {
        this.gameStatusData.is_new_user_welfare_received = true;
        this.usedShuffCount = 0;
        this.usedRemovePropCount = 0;
    }
}

