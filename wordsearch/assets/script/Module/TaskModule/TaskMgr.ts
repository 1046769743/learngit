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

    // 已完成的单词数量
    private KEY_COMPLETED_WORD_COUNT = "completed_word_count";
    private _completedWordCount: number = 0;

    public init() {
        this._completedWordCount = StorageManager.Instance.getNumber(this.KEY_COMPLETED_WORD_COUNT, 0);
    }

    public addTaskFinishCount(type: TaskType) {
        switch (type) {
            case TaskType.LevelFinish:
                break;
            case TaskType.WordFinish:
                this._completedWordCount++;
                EventCenter.dispatchEvent(EventName.UpdateCompletedWordCount, this._completedWordCount);
                break;
            case TaskType.WheelFinish:
                break;
            case TaskType.AdFinish:
                break;
            case TaskType.ActiveDay:

                break;
        }
        this.saveData();
    }

    public getCompletedWordCount(): number {
        return this._completedWordCount;
    }

    private saveData() {
        StorageManager.Instance.set(this.KEY_COMPLETED_WORD_COUNT, this._completedWordCount);
    }

}
