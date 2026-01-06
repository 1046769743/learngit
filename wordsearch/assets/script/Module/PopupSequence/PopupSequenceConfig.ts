// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html

import { Log } from "../../FrameWork/Log";
import { PrefabDefine } from "../../FrameWork/PrefabDefine";
import DailyLoginMgr from "../DailyLogin/DailyLoginMgr";
import { GameMgr } from "../Game/GameMgr";
import PigMgr from "../Pig/PigMgr";
import WithdrawMgr from "../Withdraw/WithdrawMgr";
import { PopupSequenceItem } from "./PopupSequenceMgr";

const { ccclass } = cc._decorator;

/**
 * 弹窗序列场景类型
 */
export enum PopupSequenceType {
    FirstLogin = "FirstLogin", // 每日首次登录
    BeforeStartGame = "BeforeStartGame", // 游戏开始前
    // 可以在这里添加更多场景类型
}

/**
 * 弹窗序列配置管理器
 * 负责管理各种场景下的弹窗序列配置
 */
@ccclass
export default class PopupSequenceConfig {
    private static _instance: PopupSequenceConfig = null;

    public static get Instance(): PopupSequenceConfig {
        if (this._instance) {
            return this._instance;
        }
        this._instance = new PopupSequenceConfig();
        return this._instance;
    }

    /**
     * 获取指定场景的弹窗序列配置
     * @param sequenceType 弹窗序列场景类型
     * @returns 弹窗序列配置列表
     */
    public getSequenceConfig(sequenceType: PopupSequenceType): PopupSequenceItem[] {
        switch (sequenceType) {
            case PopupSequenceType.FirstLogin:
                return this.getFirstLoginSequence();
            case PopupSequenceType.BeforeStartGame:
                return this.getGameStartSequence();
            default:
                Log.Error(`PopupSequenceConfig: 未知的弹窗序列类型 ${sequenceType}`);
                return [];
        }
    }

    /**
     * 获取每日首次登录的弹窗序列配置
     */
    private getFirstLoginSequence(): PopupSequenceItem[] {

        return [

            {
                popupName: PrefabDefine.PopGameWin,
                shouldShow: () => {
                    // 判断当前是否过关
                    let passLevel = GameMgr.Instance.isAllWordsFound();
                    return passLevel;
                },
                onBeforeShow: () => {
                    Log.Debug("PopupSequence: 准备显示奖励弹窗");
                },
                onAfterClose: () => {
                    Log.Debug("PopupSequence: 奖励弹窗已关闭");
                }
            },
            {
                popupName: PrefabDefine.PopDailyLogin,
                shouldShow: () => {
                    // 检查是否需要显示每日登录弹窗
                    return DailyLoginMgr.Instance.shouldShowPopupOnFirstLogin();
                },
                onBeforeShow: () => {
                    Log.Debug("PopupSequence: 准备显示每日登录弹窗");
                },
                onAfterClose: () => {
                    DailyLoginMgr.Instance.markPopupShown();
                    Log.Debug("PopupSequence: 每日登录弹窗已关闭");
                }
            },

            {
                popupName: PrefabDefine.PopPig,
                shouldShow: () => {
                    // 检查是否需要显示任务弹窗
                    return false;
                },
                onBeforeShow: () => {
                    Log.Debug("PopupSequence: 准备显示任务弹窗");
                },
                onAfterClose: () => {
                    Log.Debug("PopupSequence: 任务弹窗已关闭");
                }
            },

            {
                popupName: PrefabDefine.PopWithdraw,
                shouldShow: () => {
                    let isShow = WithdrawMgr.Instance.shouldShowPopupOnFirstLogin();
                    Log.Debug("PopupSequence: 提现弹窗是否显示: " + isShow);
                    return isShow;
                },
                onBeforeShow: () => {
                    Log.Debug("PopupSequence: 准备显示提现弹窗");
                },
                onAfterClose: () => {
                    Log.Debug("PopupSequence: 提现弹窗已关闭");
                }
            },
        ];
    }

    // 游戏开始前弹窗
    private getGameStartSequence(): PopupSequenceItem[] {
        return [
            {
                popupName: PrefabDefine.PopDailyLogin,
                shouldShow: () => {
                    // 检查是否需要显示每日登录弹窗
                    return DailyLoginMgr.Instance.shouldShowPopupOnFirstLogin();
                },
                onBeforeShow: () => {
                    Log.Debug("PopupSequence: 准备显示每日登录弹窗");
                },
                onAfterClose: () => {
                    DailyLoginMgr.Instance.markPopupShown();
                    Log.Debug("PopupSequence: 每日登录弹窗已关闭");
                }
            }
        ];
    }

    // 转盘完成弹窗
    public getLuckWheelSequence(): PopupSequenceItem[] {
        return [
            {
                popupName: PrefabDefine.PopLuckWheel,
                shouldShow: () => {
                    return true;
                },
                onBeforeShow: () => {
                    Log.Debug("PopupSequence: 准备显示转盘完成弹窗");
                },
                onAfterClose: () => {
                    Log.Debug("PopupSequence: 转盘完成弹窗已关闭");
                }
            }
        ];
    }

    // 关卡结算
    public getLevelFinishSequence(): PopupSequenceItem[] {
        return [
            {
                popupName: PrefabDefine.PopGameWin,
                shouldShow: () => {
                    return true;
                },
                onBeforeShow: () => {
                    Log.Debug("PopupSequence: 准备显示关卡结算弹窗");
                },
                onAfterClose: () => {
                    Log.Debug("PopupSequence: 关卡结算弹窗已关闭");
                }
            }
        ];
    }
}

