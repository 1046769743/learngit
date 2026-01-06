// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { EventName } from "./Common/EventName";
import { Tools } from "./Common/Tools";
import { EventCenter } from "./FrameWork/EventCenter";
import { Log } from "./FrameWork/Log";
import { NativeApi } from "./Platform/Android/NativeApi";

const { ccclass, property } = cc._decorator;

@ccclass
export default class LoadingScene extends cc.Component {

    @property(cc.Sprite)
    progressBar: cc.Sprite = null;

    @property(cc.Node)
    tipNode: cc.Node = null

    @property(cc.Node)
    bgNode: cc.Node = null;

    isloadSceen: boolean = false;
    speed: number = 0.01;
    isEnterGame: boolean = false;

    protected onLoad(): void {
        let screenHeight = cc.winSize.height;
        // 背景图适配
        if (screenHeight > 1600) {
            let bgScale = screenHeight / 1600 + 0.05;
            this.bgNode.scale = bgScale;
        }
    }

    update(dt) {
        if (this.isloadSceen == false) {
            if (this.isEnterGame) {
                this.speed = 0.02;
            }
            this.progressBar.fillRange += this.speed;
            if (this.progressBar.fillRange >= 1.0 && this.isEnterGame) {
                this.isloadSceen = true;
                Log.Debug("zq enterGame end time = " + (new Date().getTime() - Tools.startTime));
                // cc.director.loadScene("MainScene");
                this.node.destroy();
            }
        }
    }

    start() {
        EventCenter.on(EventName.EnterGameUI, this.onEnterGameUI, this);
        Tools.startTime = new Date().getTime();
        Log.Debug("LoadingScene start time = " + Tools.startTime);
        this.tipNode.active = true;
        this.isloadSceen = false;

        NativeApi.instance.enterGame();
    }

    onEnterGameUI() {
        Log.Debug("LoadingScene onEnterGame");
        this.isEnterGame = true;
    }

    onDestroy() {
        EventCenter.off(EventName.EnterGameUI, this.onEnterGameUI, this);
    }
}
