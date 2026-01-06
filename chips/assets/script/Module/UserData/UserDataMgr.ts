// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { CollectEffectType, EffectManager } from "../../Common/EffectManager";
import { EventName } from "../../Common/EventName";
import ClientConfig, { ConfigKey } from "../../Data/ClientConfig";
import { EventCenter } from "../../FrameWork/EventCenter";
import { Log } from "../../FrameWork/Log";
import { StorageManager } from "../../FrameWork/storage/StorageManager";
import { TargetNodeKeys } from "../../FrameWork/TargetNodeKeys";
import { UIManager } from "../../FrameWork/UIManager";
import { NativeApi } from "../../Platform/Android/NativeApi";
import { SOUND_NAME, SoundManager } from "../Audio/SoundManager";
import Language, { Country, LanguageType } from "../Language/Language";
import CurrencyManager from "../Currency/CurrencyManager";
import WithdrawMgr from "../Withdraw/WithdrawMgr";
import TaskMgr from "../TaskModule/TaskMgr";
import { UserTag } from "../../Common/EnumDefine";

const { ccclass, property } = cc._decorator;

@ccclass
export default class UserDataMgr {

    private static _instance: UserDataMgr;

    static get Instance() {
        if (this._instance) {
            return this._instance;
        }
        this._instance = new UserDataMgr();
        return this._instance;
    }

    /*  */

    private KEY_MONEY_NUMBER = "moneyNumber";  // 美元数量
    private KEY_TIP_NUMBER = "tipNumber";  // 提示道具的数量
    private KEY_GUIDE_STEP = "guideStep";  // 引导步骤
    private KEY_WITHDRAW_INDEX = "withdrawIndex";  // 提现的index
    private KEY_MY_TARGET_WITHDRAW_MONEY = "myTargetWithdrawMoney";  // 我的提现档位
    private KEY_TOTAL_MONEY_NUMBER = "totalMoneyNumber";  // 用户累计赚取金额
    private KEY_IS_WITHDRAW_TIME_LIMIT_END = "isWithdrawTimeLimitEnd";  // 提现时间限制结束
    private KEY_GOLDEN_CARD_NUMBER = "goldenCardNumber";  // 黄金卡数量


    // 用户ID
    private _userId: string = "";
    // 国家
    private _country: string = "";
    // 语言
    private _language: string = "";
    // 是否是白宝
    private _isWhiteBao: boolean = false;
    // 美元数量
    private _moneyNumber: number = 0;
    // 黄金卡数量
    private _goldenCardNumber: number = 0;
    // 用户累计赚取金额
    private _totalMoneyNumber: number = 0;
    // 提示道具的数量
    private _tipNumber: number = 0;
    // 提现的index
    private _withdrawIndex: number = 0;
    // 我的提现档位
    private _myTargetWithdrawMoney: number = 0;
    // 提现时间限制结束
    private _isWithdrawTimeLimitEnd: boolean = false;
    // 用户标签
    private _userTag: UserTag = UserTag.User100;

    // 引导步骤
    private _guideStep: number = 0;

    public init() {
        try {
            let userConmmonInfo = NativeApi.instance.getCommonParm();
            let userConmmonInfoJson = JSON.parse(userConmmonInfo);
            this._country = userConmmonInfoJson.country;
            this._language = userConmmonInfoJson.language;
            this._userId = userConmmonInfoJson.userId;

            Log.Debug("UserDataMgr init userConmmonInfo = " + userConmmonInfo);

            this._myTargetWithdrawMoney = StorageManager.Instance.getNumber(this.KEY_MY_TARGET_WITHDRAW_MONEY, 0);

            // 如果language不在LanguageType枚举中，则设置为en
            if (!Object.values(LanguageType).includes(this._language as LanguageType)) {
                this._language = LanguageType.EN;
            }

            // 初始化语言和货币管理器
            Language.instance.init(this._language as LanguageType, this._country as Country);
            CurrencyManager.instance.init(this._country as Country);

            this._isWhiteBao = NativeApi.instance.requestIsWhiteBao();
            Log.Debug("UserDataMgr isWhiteBao = " + this._isWhiteBao);

            let globalConfig = ClientConfig.globalConfig;
            this._moneyNumber = StorageManager.Instance.getNumber(this.KEY_MONEY_NUMBER, parseFloat(globalConfig.InitMoneyCount.Value));
            this._totalMoneyNumber = StorageManager.Instance.getNumber(this.KEY_TOTAL_MONEY_NUMBER, 0);
            this._moneyNumber = this._moneyNumber * 1000 / 1000;
            this._totalMoneyNumber = this._totalMoneyNumber * 1000 / 1000;

            this._tipNumber = StorageManager.Instance.getNumber(this.KEY_TIP_NUMBER, parseFloat(globalConfig.InitBulbCount.Value));
            this._withdrawIndex = StorageManager.Instance.getNumber(this.KEY_WITHDRAW_INDEX, 0);
            this._isWithdrawTimeLimitEnd = StorageManager.Instance.getBoolean(this.KEY_IS_WITHDRAW_TIME_LIMIT_END, false);
            this._goldenCardNumber = StorageManager.Instance.getNumber(this.KEY_GOLDEN_CARD_NUMBER, 0);

            this._guideStep = StorageManager.Instance.getNumber(this.KEY_GUIDE_STEP, 1);

            if (this._isWhiteBao) {
                this._moneyNumber = 0;
                this._guideStep = 100;
            }
            this.initUserTag();
            Log.Debug("UserDataMgr init moneyNumber = " + this._moneyNumber + " tipNumber = " + this._tipNumber);
        } catch (error) {
            Log.Error("UserDataMgr init error:", error);
        }
    }

    private initUserTag() {
        if (this._isWithdrawTimeLimitEnd) {
            this._userTag = UserTag.User101;
        } else {
            this._userTag = UserTag.User100;
        }
    }

    public get userTag(): UserTag {
        return this._userTag;
    }

    public get isWithdrawTimeLimitEnd(): boolean {
        return this._isWithdrawTimeLimitEnd;
    }

    public set isWithdrawTimeLimitEnd(value: boolean) {
        this._isWithdrawTimeLimitEnd = value;
        this.initUserTag();
        StorageManager.Instance.set(this.KEY_IS_WITHDRAW_TIME_LIMIT_END, this._isWithdrawTimeLimitEnd);
    }

    public restTargetWithdrawMoney(amount: number) {
        this._myTargetWithdrawMoney = amount;
        EventCenter.dispatchEvent(EventName.RefreshMoneyShow);
        StorageManager.Instance.set(this.KEY_MY_TARGET_WITHDRAW_MONEY, this._myTargetWithdrawMoney);
    }

    public get myTargetWithdrawMoney(): number {
        if (this._myTargetWithdrawMoney <= 0) {
            let withdrawList = WithdrawMgr.Instance.getWithdrawConfigList();
            this._myTargetWithdrawMoney = withdrawList[0];
        }
        return this._myTargetWithdrawMoney;
    }


    public set country(country: string) {
        // 如果 country 不在 Country 枚举中，则不设置
        if (!Object.values(Country).includes(country as Country)) {
            Log.Debug("UserDataMgr set country error, country = " + country);
            return;
        }
        if (this._country == country) {
            return;
        }
        this._country = country;
        Language.instance.init(this._language as LanguageType, this._country as Country);
        CurrencyManager.instance.setCountry(this._country as Country);

        EventCenter.dispatchEvent(EventName.RefreshMoneyShow);
    }

    public set language(language: string) {
        // 如果 language 不在 LanguageType 枚举中，则不设置
        if (!Object.values(LanguageType).includes(language as LanguageType)) {
            Log.Debug("UserDataMgr set language error, language = " + language);
            return;
        }
        if (this._language == language) {
            return;
        }
        this._language = language;
        Language.instance.init(this._language as LanguageType, this._country as Country);

        EventCenter.dispatchEvent(EventName.RefreshMoneyShow);
    }

    public get userId(): string {
        return this._userId;
    }

    public get isWhiteBao(): boolean {
        return this._isWhiteBao;
    }

    public get moneyNumber(): number {
        // 保留两位小数
        this._moneyNumber = Math.round(this._moneyNumber * 100) / 100;
        return this._moneyNumber;
    }

    public get totalMoneyNumber(): number {
        return this._totalMoneyNumber;
    }

    // 当前国家的货币金额
    public get currentBalance(): number {
        return Math.round(this._moneyNumber * CurrencyManager.instance.getExchangeRate() * 100) / 100;
    }

    public get withdrawIndex(): number {
        return this._withdrawIndex;
    }

    // 更新美元数量
    public updateMoneyNumber(value: number) {
        this._moneyNumber = value;
        EventCenter.dispatchEvent(EventName.RefreshMoneyNumber, value);
        this.saveData();
    }

    public addWithdrawIndex() {
        this._withdrawIndex++;
        StorageManager.Instance.set(this.KEY_WITHDRAW_INDEX, this._withdrawIndex);
    }

    // 是否需要显示货币符号
    public getMoneyString(isShowMoneySymbol: boolean = true) {
        return CurrencyManager.instance.formatMoney(this._moneyNumber, isShowMoneySymbol);
    }

    /**
     * 增加金币
     * @param value 
     */
    public addMoneyNumber(value: number, isShowAni: boolean = false) {
        let isWhiteBao = this.isWhiteBao;
        if (isWhiteBao) {
            return;
        }
        if (value <= 0) {
            return;
        }
        this._moneyNumber += value;
        this._totalMoneyNumber += value;
        this.saveData();
        if (isShowAni) {
            let startPos = UIManager.Instance.getTargetNodeWorldPosition(TargetNodeKeys.CENTER_POINT);
            let targetPos = UIManager.Instance.getTargetNodeWorldPosition(TargetNodeKeys.ICON_MONEY);
            SoundManager.Instance.PlaySound(SOUND_NAME.CollectMoney);
            EffectManager.instance.playCollectEffect(CollectEffectType.Money, 10, startPos, targetPos, () => {
                EventCenter.dispatchEvent(EventName.RefreshMoneyNumber, value);
            });
        } else {
            EventCenter.dispatchEvent(EventName.RefreshMoneyNumber, value);
        }
    }

    /**
     * 扣除金币
     * @param value 
     * @returns 
     */
    public subMoneyNumber(value: number) {
        if (value > this._moneyNumber) {
            return false;
        }

        this._moneyNumber -= value;
        this.saveData();
        return true;
    }

    // 黄金卡数量
    public get goldenCardNumber(): number {
        return this._goldenCardNumber;
    }

    public addGoldenCardNumber(value: number, isShowAni: boolean = false) {
        this._goldenCardNumber += value;
        StorageManager.Instance.set(this.KEY_GOLDEN_CARD_NUMBER, this._goldenCardNumber);
        if (isShowAni && value > 0) {
            let startPos = UIManager.Instance.getTargetNodeWorldPosition(TargetNodeKeys.CENTER_POINT);
            let targetPos = UIManager.Instance.getTargetNodeWorldPosition(TargetNodeKeys.ICON_GOLDEN_CARD);
            SoundManager.Instance.PlaySound(SOUND_NAME.CollectMoney);
            EffectManager.instance.playCollectEffect(CollectEffectType.GoldenCard, 10, startPos, targetPos, () => {
                EventCenter.dispatchEvent(EventName.UpdateGoldenCardNumber, value);
            });
        } else {
            EventCenter.dispatchEvent(EventName.UpdateGoldenCardNumber, value);
        }
    }

    public subGoldenCardNumber(value: number) {
        if (value > this._goldenCardNumber) {
            return false;
        }
        this._goldenCardNumber -= value;
        StorageManager.Instance.set(this.KEY_GOLDEN_CARD_NUMBER, this._goldenCardNumber);
        EventCenter.dispatchEvent(EventName.UpdateGoldenCardNumber, value);
    }
    // 提示道具的数量
    public get tipNumber(): number {
        return this._tipNumber;
    }

    public addTipNumber(value: number, isShowAni: boolean = true) {
        this._tipNumber += value;
        if (isShowAni) {
            let startPos = UIManager.Instance.getTargetNodeWorldPosition(TargetNodeKeys.CENTER_POINT);
            let targetPos = UIManager.Instance.getTargetNodeWorldPosition(TargetNodeKeys.ICON_HIT);
            EffectManager.instance.playCollectEffect(CollectEffectType.Bulb, value, startPos, targetPos, () => {
                EventCenter.dispatchEvent(EventName.UpdateTipNumber);
            });
        } else {
            EventCenter.dispatchEvent(EventName.UpdateTipNumber);
        }
        this.saveData();
    }

    public subTipNumber(): boolean {
        if (this._tipNumber <= 0) {
            return false;
        }
        this._tipNumber -= 1;
        this.saveData();
        return true;
    }

    public get guideStep(): number {
        return this._guideStep;
    }

    public set guideStep(value: number) {
        this._guideStep = value;
        StorageManager.Instance.set(this.KEY_GUIDE_STEP, this._guideStep);
    }

    private saveData() {
        StorageManager.Instance.set(this.KEY_MONEY_NUMBER, this._moneyNumber);
        StorageManager.Instance.set(this.KEY_TIP_NUMBER, this._tipNumber);
        StorageManager.Instance.set(this.KEY_TOTAL_MONEY_NUMBER, this._totalMoneyNumber);
    }
}
