// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import Language from "../../Module/Language/Language";
import PigMgr, { PigQuestData } from "../../Module/Pig/PigMgr";

const { ccclass, property } = cc._decorator;

@ccclass
export default class ItemPigTask extends cc.Component {
    @property(cc.Label)
    labelDes: cc.Label = null;

    @property(cc.Sprite)
    sprProgress: cc.Sprite = null;

    @property(cc.Label)
    labelProgress: cc.Label = null;

    @property(cc.Label)
    labelHammerCount: cc.Label = null;

    @property(cc.Node)
    nodeComplete: cc.Node = null;

    updateUI(data: PigQuestData) {
        let config = PigMgr.Instance.getQuestConfig(data.questId);
        if (config) {
            let desStr = Language.instance.getDes(config.QuestLanguageid);
            let goalNum = config.Goal;
            desStr = desStr.replace("%s", goalNum.toString());
            this.labelDes.string = desStr;
            this.labelProgress.string = data.progress + "/" + goalNum;
            this.sprProgress.fillRange = data.progress / goalNum;
            this.labelHammerCount.string = config.HammerAmount.toString();

            if (data.progress >= goalNum) {
                this.nodeComplete.active = true;
            } else {
                this.nodeComplete.active = false;
            }
        }
    }
}
