// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { Tools } from "../../Common/Tools";
import ClientConfig, { ConfigKey } from "../../Data/ClientConfig";
import { Log } from "../../FrameWork/Log";
import { StorageManager } from "../../FrameWork/storage/StorageManager";
import Language from "../../Module/Language/Language";
import UserDataMgr from "../../Module/UserData/UserDataMgr";

const { ccclass, property } = cc._decorator;

@ccclass
export default class IconMarque extends cc.Component {

    @property(cc.RichText)
    label1: cc.RichText = null;

    @property(cc.RichText)
    label2: cc.RichText = null;

    private _currentLabel: cc.RichText = null;
    private _otherLabel: cc.RichText = null;
    private _marqueeConfig: any = null;
    private _currentIndex: number = 0;

    start() {
        let isWhiteBao = UserDataMgr.Instance.isWhiteBao;
        if (isWhiteBao) {
            this.node.active = false;
            return;
        }

        this._marqueeConfig = ClientConfig.getConfig(ConfigKey.marquee);
        this._currentIndex = StorageManager.Instance.getNumber("marqueeIndex", 0);
        this.label1.node.position = cc.v3(360, 0, 0);
        this.label2.node.position = cc.v3(0, -60, 0);
        this._currentLabel = this.label1;
        this._otherLabel = this.label2;

        this._currentLabel.string = this.getRandomString();
        this._otherLabel.string = this.getRandomString();

        this.label2.node.active = false;

        // this.schedule(() => {
        //     cc.tween(this._currentLabel.node)
        //         .to(0.5, { position: cc.v3(0, 0, 0) })
        //         .start();

        //     cc.tween(this._otherLabel.node)
        //         .call(() => {
        //             this._otherLabel.string = this.getRandomString();
        //         })
        //         .to(0.55, { position: cc.v3(0, 0, 0) })
        //         .call(() => {
        //             let temp = this._currentLabel;
        //             this._currentLabel = this._otherLabel;
        //             this._otherLabel = temp;

        //             this._currentLabel.node.position = cc.v3(0, 0, 0);
        //             this._otherLabel.node.position = cc.v3(0, -60, 0);
        //         })
        //         .start();
        // }, 4);

        let wight = this.label1.node.width * 2;
        Log.Debug('跑马灯宽度: ' + wight);
        this.schedule(() => {
            cc.tween(this.label1.node)
                .to(10, { position: cc.v3(-360 - wight, 0, 0) })
                .call(() => {
                    this._currentLabel.string = this.getRandomString();
                    this._currentLabel.node.position = cc.v3(360, 0, 0);
                })
                .start();
        }, 10.1, cc.macro.REPEAT_FOREVER, 0.1);
    }

    private getRandomString(): string {
        this._currentIndex++;
        // 获取对象中键的数量
        let configLength = Object.keys(this._marqueeConfig).length;
        if (this._currentIndex >= configLength) {
            this._currentIndex = 1;
        }
        StorageManager.Instance.set("marqueeIndex", this._currentIndex);

        let languageIds = this._marqueeConfig[this._currentIndex.toString()].ContentLangugaeID;
        let randomIndex = Math.floor(Math.random() * languageIds.length);
        let languageId = languageIds[randomIndex];
        let des = Language.instance.getDes(languageId);
        let nameStr = this._marqueeConfig[this._currentIndex.toString()].MarqueeEmail;
        return cc.js.formatStr(des, nameStr);
    }
}
