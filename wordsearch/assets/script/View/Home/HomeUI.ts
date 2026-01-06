// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import DlgBtn from "../../Common/DlgBtn";
import { CollectEffectType, CollectMultipleEffect, EffectManager } from "../../Common/EffectManager";
import { TaskType } from "../../Common/EnumDefine";
import { EventName } from "../../Common/EventName";
import { EventCenter } from "../../FrameWork/EventCenter";
import { Log } from "../../FrameWork/Log";
import { PrefabDefine } from "../../FrameWork/PrefabDefine";
import ResourceManager from "../../FrameWork/ResourceManager";
import { TargetNodeKeys } from "../../FrameWork/TargetNodeKeys";
import { UIManager } from "../../FrameWork/UIManager";
import { SOUND_NAME, SoundManager } from "../../Module/Audio/SoundManager";
import { GameMgr } from "../../Module/Game/GameMgr";
import LuckWheelMgr from "../../Module/LuckWheel/LuckWheelMgr";
import PopupSequenceConfig, { PopupSequenceType } from "../../Module/PopupSequence/PopupSequenceConfig";
import PopupSequenceMgr from "../../Module/PopupSequence/PopupSequenceMgr";
import TaskMgr from "../../Module/TaskModule/TaskMgr";
import UserDataMgr from "../../Module/UserData/UserDataMgr";
import { NativeApi } from "../../Platform/Android/NativeApi";
import { ReceiveEventManager } from "../../Platform/Android/ReceiveEventManager";

const { ccclass, property } = cc._decorator;

@ccclass
export default class HomeUI extends cc.Component {
    @property(cc.Node)
    gameRoot: cc.Node = null;

    @property(DlgBtn)
    btnSetting: DlgBtn = null;

    @property(cc.Sprite)
    sprBg: cc.Sprite = null;

    @property(cc.Node)
    nodeTop: cc.Node = null;

    @property(cc.Node)
    nodeMarquee: cc.Node = null;

    // 背景图数量
    private readonly BG_COUNT = 12;
    // 每几关切换一次背景
    private readonly LEVEL_PER_BG = 10;

    start() {
        this.onAdaptation();
        // EventCenter.on(EventName.LevelFinish, this.onLevelFinish, this);

        // 监听键盘事件
        cc.systemEvent.on(cc.SystemEvent.EventType.KEY_DOWN, this.onKeyDown, this);

        cc.resources.load("Prefab/UI/GameUI", cc.Prefab, (err, prefab) => {
            if (err) {
                return;
            }
            let gameNode = cc.instantiate(prefab);
            this.gameRoot.addChild(gameNode);
        });

        if (this.btnSetting) {
            // 注册到 DlgBtn 的点击回调
            this.btnSetting.addClickCallback(this.onSetting, this);
        } else {
            console.warn("[HomeUI] btnSetting 未正确设置，请检查编辑器中的属性绑定");
        }
        SoundManager.Instance.PlayMusic(SOUND_NAME.BgMusic);
        UIManager.Instance.registerTargetNode(TargetNodeKeys.CENTER_POINT, this.node);


        // this.changeBg();
        // 进入homeUI，活跃+1
        TaskMgr.Instance.addTaskFinishCount(TaskType.ActiveDay);

        // 检查并显示每日首次登录的弹窗序列
        this.checkAndShowFirstLoginPopups();
    }

    /**
     * 检查并显示每日首次登录的弹窗序列
     */
    private checkAndShowFirstLoginPopups(): void {
        const popupSequence = PopupSequenceConfig.Instance.getSequenceConfig(PopupSequenceType.FirstLogin);
        if (popupSequence && popupSequence.length > 0) {
            PopupSequenceMgr.Instance.showSequence(popupSequence);
        }
    }

    onSetting() {
        console.log("[HomeUI] onSetting 方法被调用");
        Log.Debug("zq onSetting ----------------------- time = " + (new Date().getTime()));
        SoundManager.Instance.PlaySound(SOUND_NAME.BtnClick);
        UIManager.Instance.open(PrefabDefine.PopSetting);
    }

    private onLevelFinish() {
        // this.changeBg();
    }

    changeBg() {
        let level = GameMgr.Instance.getCurrentLevel();

        // 根据关卡数切换背景，在背景图中循环
        let index = Math.floor((level - 1) / this.LEVEL_PER_BG) % this.BG_COUNT + 1;

        let bgPath = "Image/bg_" + index;

        ResourceManager.loadRes(bgPath, cc.SpriteFrame, (frame: cc.SpriteFrame) => {
            this.sprBg.spriteFrame = frame;
        });
    }

    onDestroy() {
        UIManager.Instance.unregisterTargetNode(TargetNodeKeys.CENTER_POINT);
        UIManager.Instance.unregisterTargetNode(TargetNodeKeys.GUIDE_WITHDRAW);
        // EventCenter.off(EventName.LevelFinish, this.changeBg, this);
    }

    // 适配方案
    private onAdaptation() {
        // 设计分辨率
        let designWidth = 720;
        let designHeight = 1280;
        let screenWidth = cc.winSize.width;
        let screenHeight = cc.winSize.height;

        let scale = screenWidth / designWidth;
        let height = designHeight * scale;
        if (screenHeight > height) {
            let topOffsetY = (screenHeight - height) / 6;
            this.nodeTop.getComponent(cc.Widget).top += topOffsetY;

            if (screenHeight / screenWidth >= 2) {
                this.nodeMarquee.active = true;
            } else {
                this.nodeMarquee.active = false;
            }
        }

        // 背景图适配
        if (screenHeight > 1600) {
            let bgScale = screenHeight / 1600 + 0.05;
            this.sprBg.node.scale = bgScale;
        }

        if (UserDataMgr.Instance.isWhiteBao) {
            let gameRootOffsetY = (screenHeight - height);
            this.gameRoot.getComponent(cc.Widget).top = -gameRootOffsetY - 100;
        }
    }

    private onKeyDown(event: cc.Event.EventKeyboard) {
        if (NativeApi.instance.getDebugBuild()) {
            switch (event.keyCode) {
                case cc.macro.KEY.a:
                    UIManager.Instance.open(PrefabDefine.PopPigAnim);
                    break;

                case cc.macro.KEY.b:
                    EventCenter.dispatchEvent(EventName.CompletePigTask, 50);
                    break;

                case cc.macro.KEY.c:
                    UIManager.Instance.open(PrefabDefine.PopWithdraw);
                    break;

                case cc.macro.KEY.d:
                    LuckWheelMgr.Instance.addFinishLuckWheelTypeCount(TaskType.WordFinish);
                    break;

                case cc.macro.KEY.e:
                    // UIManager.Instance.open(PrefabDefine.PopCashOut);
                    UserDataMgr.Instance.addGoldenCardNumber(2);
                    break;

                case cc.macro.KEY.f:
                    ReceiveEventManager.withdrawSuccess("100");
                    break;
            }
        }
    }
}
