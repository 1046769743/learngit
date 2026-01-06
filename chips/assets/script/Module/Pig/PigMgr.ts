// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { RewardType, TaskType, UserTag } from "../../Common/EnumDefine";
import { EventName } from "../../Common/EventName";
import { Tools } from "../../Common/Tools";
import ClientConfig, { ConfigKey, DailyQuestConfig, QuestConfig } from "../../Data/ClientConfig";
import { EventCenter } from "../../FrameWork/EventCenter";
import { Log } from "../../FrameWork/Log";
import { StorageManager } from "../../FrameWork/storage/StorageManager";
import { GameMgr } from "../Game/GameMgr";
import RewardMgr from "../Reward/RewardMgr";
import UserDataMgr from "../UserData/UserDataMgr";

const { ccclass, property } = cc._decorator;

export class PigQuestData {
    public questId: number;
    public questType: TaskType;
    public progress: number;
    public goal: number;
    public isCompleted: boolean = false;
}

@ccclass
export default class PigMgr {

    private static _instance: PigMgr;

    static get Instance() {
        if (this._instance) {
            return this._instance;
        }
        this._instance = new PigMgr();
        return this._instance;
    }

    private readonly TAG: string = "PigMgr";

    private readonly KEY_DATA = "pig_data";
    private readonly KEY_LAST_UPDATE_TIME = "pig_last_update_time";
    private readonly KEY_CONTINUOUS_MISS_GOLDEN_CARD_COUNT = "continuous_miss_golden_card_count";

    private _dailyQuestDataList: PigQuestData[] = [];
    private _needShowFirstIndex: number = -1;
    private _needShowTaskList: PigQuestData[] = [];
    private _lastUpdateTime: number = 0;
    private _hammerCount: number = 0;
    private _targetHammerCount: number = 0;
    private _collectedReward: boolean = false;
    // 101用户连续几次未开出金卡
    private _continuousMissGoldenCardCount: number = 0;

    public init() {
        Log.Debug(this.TAG + " init");
        // 判断是否跨天
        this._lastUpdateTime = StorageManager.Instance.getNumber(this.KEY_LAST_UPDATE_TIME, 0);
        this._continuousMissGoldenCardCount = StorageManager.Instance.getNumber(this.KEY_CONTINUOUS_MISS_GOLDEN_CARD_COUNT, 0);
        let nowTime = Date.now();
        if (Tools.isCrossDay(this._lastUpdateTime, nowTime)) {
            Log.Debug(this.TAG + " init 跨天了");
            this._lastUpdateTime = nowTime;
            StorageManager.Instance.set(this.KEY_LAST_UPDATE_TIME, this._lastUpdateTime);
            this.reset();
            this.initDailyQuestDataList();
        } else {
            let data = StorageManager.Instance.getJson(this.KEY_DATA, null);
            if (data && data.dailyQuestDataList && data.dailyQuestDataList.length > 0) {
                this._dailyQuestDataList = data.dailyQuestDataList;
                this._needShowFirstIndex = data.needShowFirstIndex;
                this._collectedReward = data.collectedReward;
                this._hammerCount = data.hammerCount;
                this._targetHammerCount = data.targetHammerCount;
            } else {
                this.reset();
                this.initDailyQuestDataList();
            }
        }
        this.updateNeedShowTaskList(this._needShowFirstIndex);
        this.saveData();
    }

    public isCrossDay() {
        this._lastUpdateTime = StorageManager.Instance.getNumber(this.KEY_LAST_UPDATE_TIME, 0);
        let nowTime = Date.now();
        if (Tools.isCrossDay(this._lastUpdateTime, nowTime)) {
            this._lastUpdateTime = nowTime;
            StorageManager.Instance.set(this.KEY_LAST_UPDATE_TIME, this._lastUpdateTime);
            this.reset();
            this.initDailyQuestDataList();
            this.updateNeedShowTaskList(this._needShowFirstIndex);
            this.saveData();
        }
    }

    private reset() {
        this._dailyQuestDataList = [];
        this._needShowFirstIndex = -1;
        this._needShowTaskList = [];
        this._collectedReward = false;
        this._hammerCount = 0;
        this._targetHammerCount = 0;
        this.saveData();
    }

    private initDailyQuestDataList() {
        Log.Debug(this.TAG + " initDailyQuestDataList");
        // 根据当前用户累计money，获取每日任务
        let userMoney = UserDataMgr.Instance.totalMoneyNumber;
        // 根据用户累计money，获取每日任务
        let questIdList: number[] = [];
        let dailyQuestConfig = ClientConfig.getConfig(ConfigKey.DailyQuest);
        for (let key in dailyQuestConfig) {
            let dailyQuestData = dailyQuestConfig[key] as DailyQuestConfig;
            if (dailyQuestData.UserDollar >= userMoney) {
                questIdList = dailyQuestData.QuestID;
                break;
            }
        }

        Log.Debug("PigMgr initDailyQuestDataList questIdList: " + JSON.stringify(questIdList));
        this._targetHammerCount = 0;
        for (let questId of questIdList) {
            let dailyQuestData = this.getQuestConfig(questId);
            this._targetHammerCount += dailyQuestData.HammerAmount;
            this._dailyQuestDataList.push({
                questId: questId,
                questType: dailyQuestData.QuestType,
                progress: 0,
                goal: dailyQuestData.Goal,
                isCompleted: false
            });
        }

        Log.Debug(this.TAG + " initDailyQuestDataList this._dailyQuestDataList: " + JSON.stringify(this._dailyQuestDataList));
    }

    public getTargetHammerCount(): number {
        return this._targetHammerCount;
    }

    public getHammerCount(): number {
        return this._hammerCount;
    }

    public getCollectedReward(): boolean {
        return this._collectedReward;
    }

    public setCollectedReward(collectedReward: boolean) {
        this._collectedReward = collectedReward;
        EventCenter.dispatchEvent(EventName.PigRedDotRefresh);
        this.saveData();
    }

    public resetContinuousMissGoldenCardCount() {
        if (UserDataMgr.Instance.userTag !== UserTag.User101) {
            return;
        }
        this._continuousMissGoldenCardCount = 0;
        StorageManager.Instance.set(this.KEY_CONTINUOUS_MISS_GOLDEN_CARD_COUNT, this._continuousMissGoldenCardCount);
    }

    public getContinuousMissGoldenCardCount(): number {
        return this._continuousMissGoldenCardCount;
    }

    public addContinuousMissGoldenCardCount() {
        if (UserDataMgr.Instance.userTag !== UserTag.User101) {
            return;
        }
        this._continuousMissGoldenCardCount++;
        StorageManager.Instance.set(this.KEY_CONTINUOUS_MISS_GOLDEN_CARD_COUNT, this._continuousMissGoldenCardCount);
    }

    public getReward(): { type: RewardType, value: number }[] {
        Log.Debug(this.TAG + " getReward ");
        let isForceGoldenCard = false;
        let maxGoldCardCount = parseInt(ClientConfig.globalConfig.GoldenCardAmount.Value);
        let totalGoldCardCount = UserDataMgr.Instance.goldenCardNumber;
        if (UserDataMgr.Instance.userTag === UserTag.User101 && totalGoldCardCount < maxGoldCardCount) {
            let cfg = parseInt(ClientConfig.globalConfig.GoldSpinCardMin.Value);
            isForceGoldenCard = this._continuousMissGoldenCardCount >= cfg;
            Log.Debug(this.TAG + " getReward isForceGoldenCard: " + isForceGoldenCard);
            Log.Debug(this.TAG + " getReward totalGoldCardCount: " + totalGoldCardCount);
            Log.Debug(this.TAG + " getReward maxGoldCardCount: " + maxGoldCardCount);
            Log.Debug(this.TAG + " getReward :PiggyQuestCardMin " + cfg);
            Log.Debug(this.TAG + " getReward continuousMissGoldenCardCount: " + this._continuousMissGoldenCardCount);
        }

        let rewards = RewardMgr.Instance.getPigRewardConfig(isForceGoldenCard);
        Log.Debug(this.TAG + " getReward rewards: " + JSON.stringify(rewards));
        return rewards;
    }

    /*
     * 更新需要显示的任务列表
     * 1. 每次最多显示两条任务
     * 2. 当前两条任务全部完成，才能获取后续任务
     */
    private updateNeedShowTaskList(firstIndex: number = -1) {
        let needShowTaskList: PigQuestData[] = [];

        if (!this._dailyQuestDataList || this._dailyQuestDataList.length === 0) {
            Log.Debug("PigMgr updateNeedShowTaskList: dailyQuestDataList is empty");
            return;
        }

        // 找到第一个未完成的任务索引   
        let firstUncompletedIndex = firstIndex;
        if (firstUncompletedIndex === -1) {
            for (let i = 0; i < this._dailyQuestDataList.length; i++) {
                let quest = this._dailyQuestDataList[i];
                if (quest.progress < quest.goal) {
                    firstUncompletedIndex = i;
                    break;
                }
            }
        }

        // 如果所有任务都完成了，返回空列表
        if (firstUncompletedIndex === -1) {
            Log.Debug("PigMgr updateNeedShowTaskList: all tasks are completed");
            return;
        }

        // 从第一个未完成的任务开始，最多取2条
        for (let i = firstUncompletedIndex; i < this._dailyQuestDataList.length && needShowTaskList.length < 2; i++) {
            needShowTaskList.push(this._dailyQuestDataList[i]);
        }
        this._needShowFirstIndex = firstUncompletedIndex;
        this._needShowTaskList = needShowTaskList;
    }

    // 功能是否开启
    public isFeatureOpen(): boolean {
        if (UserDataMgr.Instance.isWhiteBao) {
            return false;
        }
        let openLevel = ClientConfig.globalConfig.PiggyQuestBegin.Value;
        openLevel = parseInt(openLevel);
        let currentLevel = GameMgr.Instance.GetCurProgress();
        return currentLevel >= openLevel;
    }

    public getNeedShowTaskList(): PigQuestData[] {
        return this._needShowTaskList;
    }

    // 判断显示任务是否全部完成
    public isShowTaskAllCompleted(): boolean {
        let allCompleted = true;
        for (let quest of this._needShowTaskList) {
            if (quest.progress < quest.goal) {
                allCompleted = false;
                break;
            }
        }
        return allCompleted;
    }

    // 判断任务是否全部完成
    public isTaskAllCompleted(): boolean {
        let allCompleted = true;
        for (let quest of this._dailyQuestDataList) {
            if (quest.progress < quest.goal) {
                allCompleted = false;
                break;
            }
        }
        return allCompleted;
    }

    public addTaskProgress(type: TaskType) {
        if (!this.isFeatureOpen()) {
            return;
        }

        let isChange = false;
        let needShowTaskList = this._needShowTaskList;
        for (let quest of needShowTaskList) {
            if (quest.questType === type) {
                quest.progress++;
                if (quest.progress < 0) {
                    quest.progress = 0;
                }
                if (quest.progress > quest.goal) {
                    quest.progress = quest.goal;
                }
                if (quest.progress == quest.goal && !quest.isCompleted) {
                    quest.isCompleted = true;
                    let questConfig = this.getQuestConfig(quest.questId);
                    if (questConfig && questConfig.HammerAmount > 0) {
                        this._hammerCount += questConfig.HammerAmount;
                        EventCenter.dispatchEvent(EventName.CompletePigTask, questConfig.HammerAmount);
                    }

                }
                isChange = true;
            }
        }

        if (!isChange) {
            return;
        }

        // 判断任务是否全部完成
        if (!this.isTaskAllCompleted() && this.isShowTaskAllCompleted()) {
            this.updateNeedShowTaskList();
        }

        this.saveData();
    }

    public getQuestConfig(questId: number): QuestConfig {
        let questConfig = ClientConfig.getConfig(ConfigKey.Quest);
        for (let key in questConfig) {
            let questData = questConfig[key] as QuestConfig;
            if (questData.QuestID === questId) {
                return questData;
            }
        }
        return null;
    }

    private saveData() {
        let data = {
            dailyQuestDataList: this._dailyQuestDataList,
            needShowFirstIndex: this._needShowFirstIndex,
            collectedReward: this._collectedReward,
            hammerCount: this._hammerCount,
            targetHammerCount: this._targetHammerCount,
        };
        StorageManager.Instance.set(this.KEY_DATA, data);
        Log.Debug("PigMgr saveData: " + JSON.stringify(data));
    }
}
