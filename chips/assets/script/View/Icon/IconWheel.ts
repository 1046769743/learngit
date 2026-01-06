// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { EventName } from "../../Common/EventName";
import { EventCenter } from "../../FrameWork/EventCenter";
import { Log } from "../../FrameWork/Log";
import { PrefabDefine } from "../../FrameWork/PrefabDefine";
import { TargetNodeKeys } from "../../FrameWork/TargetNodeKeys";
import { UIManager } from "../../FrameWork/UIManager";
import Language, { Country, LanguageType } from "../../Module/Language/Language";
import UserDataMgr from "../../Module/UserData/UserDataMgr";
import WheelMgr from "../../Module/Wheel/WheelMgr";

const { ccclass, property } = cc._decorator;

@ccclass
export default class IconWheel extends cc.Component {
    @property(cc.Node)
    nodeIcon: cc.Node = null;

    @property(cc.Label)
    labelProgress: cc.Label = null;

    @property(cc.Sprite)
    spriteProgress: cc.Sprite = null;

    start() {
        this.node.active = false;
        return;
        let isWhiteBao = UserDataMgr.Instance.isWhiteBao;
        if (isWhiteBao) {
            this.node.active = false;
            return;
        }

        UIManager.Instance.registerTargetNode(TargetNodeKeys.ICON_SLOT, this.nodeIcon);
        let language = Language.instance.getCurrentLanguage();
        let country = Language.instance.getCurrentCountry();
        if (language == LanguageType.IN || country == Country.ID) {
            this.node.active = false;
        } else {
            EventCenter.on(EventName.UpdateWheelProgress, this.updateProgress, this);
            this.updateProgress();
        }

        this.node.active = false;
    }

    updateProgress() {
        return;
        let currentProgress = WheelMgr.Instance.getCurrentFinishWordCount();
        let targetProgress = WheelMgr.Instance.getTargetWordCount();
        this.labelProgress.string = `${currentProgress}/${targetProgress}`;
        this.spriteProgress.fillRange = currentProgress / targetProgress;
    }

    onDestroy() {
        EventCenter.off(EventName.UpdateWheelProgress, this.updateProgress, this);
    }

}
