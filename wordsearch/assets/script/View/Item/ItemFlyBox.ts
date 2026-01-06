// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { EventName } from "../../Common/EventName";
import { EventCenter } from "../../FrameWork/EventCenter";
import { PrefabDefine } from "../../FrameWork/PrefabDefine";
import { UIManager } from "../../FrameWork/UIManager";
import AdMgr, { AdType, ModuleType } from "../../Module/AdModel/AdMgr";
import { GameMgr } from "../../Module/Game/GameMgr";
import UserDataMgr from "../../Module/UserData/UserDataMgr";
import { NativeApi } from "../../Platform/Android/NativeApi";

const { ccclass, property } = cc._decorator;

@ccclass
export default class ItemFlyBox extends cc.Component {

    @property(cc.Button)
    button: cc.Button = null;

    private isFlyBoxOpen: boolean = false;
    private flyDistance: number = 0;
    private isFlying: boolean = false;
    private flyboxTween: cc.Tween = null;

    onLoad() {
        this.button.node.on("click", this.onButtonClick, this);
        EventCenter.on(EventName.LevelFinish, this.onLevelFinish, this);
    }

    start() {
        this.isOpen();
        this.node.active = this.isFlyBoxOpen;
    }

    update(dt: number) {
        if (this.isFlyBoxOpen && !this.isFlying) {
            // 每隔10秒飞行一次
            this.flyDistance += dt;
            if (this.flyDistance >= 8) {
                this.flyDistance = 0;
                this.startFly();
            }
        }
    }

    private startFly() {
        this.isFlying = true;
        let screenSize = cc.winSize;

        // 随机选择一种飞行轨迹（0-3）
        const trajectoryType = Math.floor(Math.random() * 4);
        let startPos: cc.Vec3;
        let pos1: cc.Vec3;
        let pos2: cc.Vec3;
        let pos3: cc.Vec3;
        let endPos: cc.Vec3;

        switch (trajectoryType) {
            case 0: // 轨迹1: 左下飞入，左上飞出（原有轨迹）
                startPos = cc.v3(-screenSize.width / 2 - 140, -screenSize.height / 2 + 100, 0);
                pos1 = cc.v3(screenSize.width / 2 - 70, -screenSize.height / 4, 0);
                pos2 = cc.v3(-screenSize.width / 2 + 70, 0, 0);
                pos3 = cc.v3(screenSize.width / 2 - 70, screenSize.height / 4 - 100, 0);
                endPos = cc.v3(-screenSize.width / 2 - 140, screenSize.height / 2 - 100, 0);
                break;

            case 1: // 轨迹2: 左上飞入，左下飞出
                startPos = cc.v3(-screenSize.width / 2 - 140, screenSize.height / 2 - 100, 0);
                pos1 = cc.v3(screenSize.width / 2 - 70, screenSize.height / 4 - 100, 0);
                pos2 = cc.v3(-screenSize.width / 2 + 70, 0, 0);
                pos3 = cc.v3(screenSize.width / 2 - 70, -screenSize.height / 4, 0);
                endPos = cc.v3(-screenSize.width / 2 - 140, -screenSize.height / 2 + 100, 0);
                break;

            case 2: // 轨迹3: 右上飞入，右下飞出
                startPos = cc.v3(screenSize.width / 2 + 140, screenSize.height / 2 - 100, 0);
                pos1 = cc.v3(-screenSize.width / 2 + 70, screenSize.height / 4 - 100, 0);
                pos2 = cc.v3(screenSize.width / 2 - 70, 0, 0);
                pos3 = cc.v3(-screenSize.width / 2 + 70, -screenSize.height / 4, 0);
                endPos = cc.v3(screenSize.width / 2 + 140, -screenSize.height / 2 + 100, 0);
                break;

            case 3: // 轨迹4: 右下飞入，右上飞出
                startPos = cc.v3(screenSize.width / 2 + 140, -screenSize.height / 2 + 100, 0);
                pos1 = cc.v3(-screenSize.width / 2 + 70, -screenSize.height / 4, 0);
                pos2 = cc.v3(screenSize.width / 2 - 70, 0, 0);
                pos3 = cc.v3(-screenSize.width / 2 + 70, screenSize.height / 4 - 100, 0);
                endPos = cc.v3(screenSize.width / 2 + 140, screenSize.height / 2 - 100, 0);
                break;

            default:
                // 默认使用轨迹1
                startPos = cc.v3(-screenSize.width / 2 - 140, -screenSize.height / 2 + 100, 0);
                pos1 = cc.v3(screenSize.width / 2 - 70, -screenSize.height / 4, 0);
                pos2 = cc.v3(-screenSize.width / 2 + 70, 0, 0);
                pos3 = cc.v3(screenSize.width / 2 - 70, screenSize.height / 4 - 100, 0);
                endPos = cc.v3(-screenSize.width / 2 - 140, screenSize.height / 2 - 100, 0);
                break;
        }

        this.node.setPosition(startPos);
        if (this.flyboxTween) {
            this.flyboxTween.stop();
        }
        this.flyboxTween = cc.tween(this.node)
            .to(4, { position: pos1 })
            .to(4, { position: pos2 })
            .to(4, { position: pos3 })
            .to(4, { position: endPos })
            .call(() => {
                this.hideFlyBox();
            })
            .start();
    }

    private isOpen(): boolean {
        if (UserDataMgr.Instance.isWhiteBao) {
            return false;
        }

        if (this.isFlyBoxOpen) {
            return true;
        }
        let currentLevel = GameMgr.Instance.getCurrentLevel();
        if (currentLevel >= 2) {
            this.isFlyBoxOpen = true;
        }
        return this.isFlyBoxOpen;
    }

    onLevelFinish() {
        this.isOpen();
        this.node.active = this.isFlyBoxOpen;
    }

    onButtonClick() {
        UIManager.Instance.open(PrefabDefine.PopFlyBox);
        NativeApi.instance.buryPoint("WordChestButtonClick");
        this.hideFlyBox();
    }

    private hideFlyBox() {
        if (this.flyboxTween) {
            this.flyboxTween.stop();
        }
        this.flyboxTween = null;
        this.isFlying = false;
        this.node.setPosition(cc.v3(-1000, -1000, 0));
        this.flyDistance = 0;
    }
}
