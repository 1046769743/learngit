// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { TaskType } from "../../Common/EnumDefine";
import { EventName } from "../../Common/EventName";
import ClientConfig, { ConfigKey, WheelConfig } from "../../Data/ClientConfig";
import { EventCenter } from "../../FrameWork/EventCenter";
import { Log } from "../../FrameWork/Log";
import { PrefabDefine } from "../../FrameWork/PrefabDefine";
import { StorageManager } from "../../FrameWork/storage/StorageManager";
import { UIManager } from "../../FrameWork/UIManager";
import Language, { Country, LanguageType } from "../Language/Language";
import PigMgr from "../Pig/PigMgr";
import TaskMgr from "../TaskModule/TaskMgr";
import UserDataMgr from "../UserData/UserDataMgr";

const { ccclass, property } = cc._decorator;

@ccclass
export default class WheelMgr {

    private static _instance: WheelMgr;

    static get Instance() {
        if (this._instance) {
            return this._instance;
        }
        this._instance = new WheelMgr();
        return this._instance;
    }

    private KEY_WHEEL_ID = "wheel_id";

    private _wheelConfig: Map<number, WheelConfig> = new Map<number, WheelConfig>();

    private _currentWheelID: number = 0;
    private _currentFinishWheelTypeCount: number = 0;

    public init() {
        // let wheelConfig = ClientConfig.getConfig(ConfigKey.Wheel);
        // this._wheelConfig = new Map<number, WheelConfig>();
        // for (let key in wheelConfig) {
        //     this._wheelConfig.set(parseInt(key), wheelConfig[key]);
        // }

        // this._currentWheelID = StorageManager.Instance.getNumber(this.KEY_WHEEL_ID, 1);
        // this._currentFinishWheelTypeCount = StorageManager.Instance.getNumber(this.getKeyFinishWheelTypeCount(), 0);
    }

    public getTargetWordCount() {
        let wheelConfig = this._wheelConfig.get(this._currentWheelID);
        return wheelConfig.Amount;
    }

    public getCurrentFinishWordCount() {
        return this._currentFinishWheelTypeCount;
    }

    public addFinishWheelTypeCount(type: number) {
        return;
        let isWhiteBao = UserDataMgr.Instance.isWhiteBao;
        if (isWhiteBao) {
            return;
        }
        let currentKey = this.getCurrentWheelConfig().GoalType;
        if (currentKey != type) {
            return;
        }
        let language = Language.instance.getCurrentLanguage();
        let country = Language.instance.getCurrentCountry();
        if (language != LanguageType.IN && country != Country.ID) {
            this._currentFinishWheelTypeCount++;
            StorageManager.Instance.set(this.getKeyFinishWheelTypeCount(), this._currentFinishWheelTypeCount);
            EventCenter.dispatchEvent(EventName.UpdateWheelProgress);

            let currentProgress = this.getCurrentFinishWordCount();
            let targetProgress = this.getTargetWordCount();
            if (currentProgress >= targetProgress) {
                UIManager.Instance.open(PrefabDefine.PopWheel);
            }
        }
    }

    public getCurrentWheelConfig() {
        return this._wheelConfig.get(this._currentWheelID);
    }

    // 进行下一轮
    public nextWheel() {
        this._currentWheelID++;
        if (this._currentWheelID > this._wheelConfig.size) {
            this._currentWheelID = this._wheelConfig.size;
        }
        StorageManager.Instance.set(this.KEY_WHEEL_ID, this._currentWheelID);
        this._currentFinishWheelTypeCount = 0;
        StorageManager.Instance.set(this.getKeyFinishWheelTypeCount(), this._currentFinishWheelTypeCount);
        EventCenter.dispatchEvent(EventName.UpdateWheelProgress);
        TaskMgr.Instance.addTaskFinishCount(TaskType.WheelFinish);
        PigMgr.Instance.addTaskProgress(TaskType.WheelFinish);
    }

    public getCurrentWheelID() {
        return this._currentWheelID;
    }

    private getKeyFinishWheelTypeCount() {
        return `finish_wheel_type_count_${this.getCurrentWheelConfig().GoalType}`;
    }

}
