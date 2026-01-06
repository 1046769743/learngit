// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { TaskType } from "../../Common/EnumDefine";
import { EventName } from "../../Common/EventName";
import { Tools } from "../../Common/Tools";
import ClientConfig, { ConfigKey, TaskConfig } from "../../Data/ClientConfig";
import { EventCenter } from "../../FrameWork/EventCenter";
import { Log } from "../../FrameWork/Log";
import { StorageManager } from "../../FrameWork/storage/StorageManager";
import RewardMgr from "../Reward/RewardMgr";

const { ccclass, property } = cc._decorator;

@ccclass
export default class TaskMgr {

    private static _instance: TaskMgr;

    static get Instance() {
        if (this._instance) {
            return this._instance;
        }
        this._instance = new TaskMgr();
        return this._instance;
    }


    private readonly KEY_CURRENT_TASK_DATA = "current_task_data_v100";
    private readonly KEY_ACTIVE_LAST_TIME = "active_last_time";
    private readonly KEY_IS_WITHDRAW_TASK_OPEN = "is_withdraw_task_open";
    private readonly KEY_IS_POP_TASK_AUTO_OPEN = "is_pop_task_auto_open";

    private _taskConfigMap: Map<number, TaskConfig> = new Map<number, TaskConfig>();
    private _wordFinishCount: number = 0;
    private _levelFinishCount: number = 0;
    private _wheelFinishCount: number = 0;
    private _adFinishCount: number = 0;
    private _activeDayCount: number = 0;
    private _activeLastTime: number = 0;

    // 提现任务是否开启
    private _isWithdrawTaskOpen: boolean = false;
    // 弹窗是否主动打开过
    private _isPopTaskAutoOpen: boolean = false;

    public init() {
        // let taskConfig = ClientConfig.getConfig(ConfigKey.Task);
        // this._taskConfigMap = new Map<number, TaskConfig>();
        // for (let key in taskConfig) {
        //     this._taskConfigMap.set(parseInt(key), taskConfig[key]);
        // }

        // this._activeLastTime = StorageManager.Instance.getNumber(this.KEY_ACTIVE_LAST_TIME, 0);

        // let taskData = StorageManager.Instance.getJson(this.KEY_CURRENT_TASK_DATA);
        // if (!taskData) {
        //     taskData = {
        //         wordFinishCount: 0,
        //         levelFinishCount: 0,
        //         wheelFinishCount: 0,
        //         adFinishCount: 0,
        //         activeDayCount: 0,
        //     }
        // }
        // this._activeDayCount = taskData.activeDayCount;
        // this._wordFinishCount = taskData.wordFinishCount;
        // this._levelFinishCount = taskData.levelFinishCount;
        // this._wheelFinishCount = taskData.wheelFinishCount;
        // this._adFinishCount = taskData.adFinishCount;

        // this._isWithdrawTaskOpen = StorageManager.Instance.getBoolean(this.KEY_IS_WITHDRAW_TASK_OPEN, false);
        // this._isPopTaskAutoOpen = StorageManager.Instance.getBoolean(this.KEY_IS_POP_TASK_AUTO_OPEN, false);
    }

    public getIsWithdrawTaskOpen(): boolean {
        return this._isWithdrawTaskOpen;
    }

    public setIsWithdrawTaskOpen(isOpen: boolean) {
        if (this._isWithdrawTaskOpen == isOpen) {
            return;
        }
        this._isWithdrawTaskOpen = isOpen;
        StorageManager.Instance.set(this.KEY_IS_WITHDRAW_TASK_OPEN, this._isWithdrawTaskOpen);
        EventCenter.dispatchEvent(EventName.WithdrawTaskOpen);
    }

    public getIsPopTaskAutoOpen(): boolean {
        return this._isPopTaskAutoOpen;
    }

    public setIsPopTaskAutoOpen(isOpen: boolean) {
        this._isPopTaskAutoOpen = isOpen;
        StorageManager.Instance.set(this.KEY_IS_POP_TASK_AUTO_OPEN, this._isPopTaskAutoOpen);
    }

    public getTaskConfig(id: number): TaskConfig {
        return this._taskConfigMap.get(id);
    }

    public getAllTaskCfg(): Map<number, TaskConfig> {
        return this._taskConfigMap;
    }


    public addTaskFinishCount(type: TaskType) {
        return;
        switch (type) {
            case TaskType.LevelFinish:
                this._levelFinishCount++;
                break;
            case TaskType.WordFinish:
                if (RewardMgr.Instance.getIsTrigged777()) {
                    this._wordFinishCount++;
                }
                break;
            case TaskType.WheelFinish:
                this._wheelFinishCount++;
                EventCenter.dispatchEvent(EventName.WheelFinish);
                break;
            case TaskType.AdFinish:
                this._adFinishCount++;
                break;
            case TaskType.ActiveDay:
                if (Tools.isCrossDay(this._activeLastTime, Date.now())) {
                    this._activeDayCount++;
                    this._activeLastTime = Date.now();
                    StorageManager.Instance.set(this.KEY_ACTIVE_LAST_TIME, this._activeLastTime);
                }
                break;
        }
        this.saveData();
    }

    public getCurrentTaskFinishCount(taskId: number): number {
        let taskConfig = this.getTaskConfig(taskId);
        if (!taskConfig) {
            return 0;
        }

        let taskType = taskConfig.TaskType;
        switch (taskType) {
            case TaskType.ActiveDay:
                return this._activeDayCount;
            case TaskType.WordFinish:
                return this._wordFinishCount;
            case TaskType.LevelFinish:
                return this._levelFinishCount;
            case TaskType.WheelFinish:
                return this._wheelFinishCount;
            case TaskType.AdFinish:
                return this._adFinishCount;
            default:
                return 0;
        }
    }

    private saveData() {
        let data = {
            wordFinishCount: this._wordFinishCount,
            levelFinishCount: this._levelFinishCount,
            wheelFinishCount: this._wheelFinishCount,
            adFinishCount: this._adFinishCount,
            activeDayCount: this._activeDayCount,
        }
        StorageManager.Instance.set(this.KEY_CURRENT_TASK_DATA, data);
    }

}
