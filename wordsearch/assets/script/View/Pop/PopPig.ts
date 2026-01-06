// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import DlgBtn from "../../Common/DlgBtn";
import { EventName } from "../../Common/EventName";
import ClientConfig, { ConfigKey } from "../../Data/ClientConfig";
import { EventCenter } from "../../FrameWork/EventCenter";
import { Log } from "../../FrameWork/Log";
import { PrefabDefine } from "../../FrameWork/PrefabDefine";
import { StorageManager } from "../../FrameWork/storage/StorageManager";
import { TargetNodeKeys } from "../../FrameWork/TargetNodeKeys";
import { UIManager } from "../../FrameWork/UIManager";
import { SOUND_NAME, SoundManager } from "../../Module/Audio/SoundManager";
import CurrencyManager from "../../Module/Currency/CurrencyManager";
import { GuideMgr, GuideType } from "../../Module/Guide/GuideMgr";
import Language from "../../Module/Language/Language";
import PigMgr from "../../Module/Pig/PigMgr";
import TaskMgr from "../../Module/TaskModule/TaskMgr";
import UserDataMgr from "../../Module/UserData/UserDataMgr";
import ItemPigTask from "../Item/ItemPigTask";
import ItemTask from "../Item/ItemTask";
import BasePop from "./BasePop";

const { ccclass, property } = cc._decorator;

@ccclass
export default class PopPig extends BasePop {

    @property(DlgBtn)
    btnClose: DlgBtn = null;

    @property(DlgBtn)
    btnPig: DlgBtn = null;

    @property(cc.Node)
    nodePig: cc.Node = null;

    @property(cc.Node)
    nodePigOpne: cc.Node = null;

    @property(cc.RichText)
    labDes: cc.RichText = null;

    @property(cc.Node)
    nodeQipao: cc.Node = null;

    @property(cc.Label)
    labQipao: cc.Label = null;

    @property(cc.Node)
    nodeHand: cc.Node = null;

    @property(cc.Node)
    nodeProgress: cc.Node = null;

    @property(cc.Sprite)
    sprProgress: cc.Sprite = null;

    @property(cc.Label)
    labProgress: cc.Label = null;

    @property([ItemPigTask])
    itemPigTasks: ItemPigTask[] = [];

    @property(cc.Node)
    nodeGuide1: cc.Node = null;
    @property(cc.Node)
    nodeGuide2: cc.Node = null;


    private readonly KEY_POP_PIG_GUIDE_1 = "key_pop_pig_guide_1";

    start() {
        this.btnClose.addClickCallback(this.onClose, this);
        this.btnPig.addClickCallback(this.onPigClick, this);

        UIManager.Instance.registerTargetNode(TargetNodeKeys.POP_PIG_1, this.nodeGuide1);
        UIManager.Instance.registerTargetNode(TargetNodeKeys.POP_PIG_2, this.nodeGuide2);

        // 是否全部完成
        let isAllCompleted = PigMgr.Instance.isTaskAllCompleted();
        if (isAllCompleted) {
            this.btnPig.interactable = true;
        } else {
            this.btnPig.interactable = false;
        }

        PigMgr.Instance.isCrossDay();
        this.initUI();
        // 尝试显示引导
        this.scheduleOnce(() => {
            this.tryShowGuide();
        }, 0.3);
    }

    initUI() {
        let des = Language.instance.getDes("68");
        des = "<b><outline color=#000000 width=2>" + des + "</outline></b>";

        Log.Debug("zq des = " + des);
        let s = "<outline color=#B55A01 width=2><size=48><color=#FFEF0F>$100</color></size></outline>";
        des = des.replace("$100", s);
        Log.Debug("zq des = " + des);

        this.labDes.string = des;

        let targetHammerCount = PigMgr.Instance.getTargetHammerCount();
        let hammerCount = PigMgr.Instance.getHammerCount();
        this.labProgress.string = hammerCount + "/" + targetHammerCount;
        this.sprProgress.fillRange = hammerCount / targetHammerCount;

        // 判断是否完成今日所以任务
        let isAllCompleted = PigMgr.Instance.isTaskAllCompleted();
        let isCollectedReward = PigMgr.Instance.getCollectedReward();
        if (isAllCompleted) {
            if (isCollectedReward) {
                this.nodePig.active = false;
                this.nodePigOpne.active = true;
                this.nodeQipao.active = false;
                this.nodeHand.active = false;
            } else {
                this.labQipao.string = Language.instance.getDes("69");
                this.nodePig.active = true;
                this.nodePigOpne.active = false;
                this.nodeQipao.active = true;
                this.nodeHand.active = true;
            }
        } else {
            this.nodeQipao.active = false;
            this.nodeHand.active = false;
            this.nodePig.active = true;
            this.nodePigOpne.active = false;
        }

        // 需要显示的任务
        for (let i = 0; i < this.itemPigTasks.length; i++) {
            if (this.itemPigTasks[i]) {
                this.itemPigTasks[i].node.active = false;
            }
        }

        let needShowTaskList = PigMgr.Instance.getNeedShowTaskList();
        for (let i = 0; i < needShowTaskList.length; i++) {
            if (this.itemPigTasks[i]) {
                this.itemPigTasks[i].node.active = true;
                this.itemPigTasks[i].updateUI(needShowTaskList[i]);
            }
        }
    }

    private tryShowGuide() {
        let isFinishGuide1 = StorageManager.Instance.getBoolean(this.KEY_POP_PIG_GUIDE_1, false);
        if (isFinishGuide1) {
            return;
        }

        GuideMgr.Instance.changeStep(GuideType.NewUser, 2002);
        StorageManager.Instance.set(this.KEY_POP_PIG_GUIDE_1, true);
    }

    private onClose() {
        Log.Debug("PopPig onClose");
        UIManager.Instance.close(PrefabDefine.PopPig);
    }

    private onPigClick() {
        Log.Debug("PopPig onPigClick");

        let collectedReward = PigMgr.Instance.getCollectedReward();
        if (collectedReward) {
            UIManager.Instance.showToast("", "已领取奖励");
            return;
        }
        this.onClose();
        UIManager.Instance.open(PrefabDefine.PopPigAnim);
    }

    onDestroy() {
        UIManager.Instance.unregisterTargetNode(TargetNodeKeys.POP_PIG_1);
        UIManager.Instance.unregisterTargetNode(TargetNodeKeys.POP_PIG_2);
    }

    showEnterAnim() {
        this.contentNode.opacity = 100;
        cc.tween(this.contentNode)
            .to(0.25, { opacity: 255 })
            .start();

        this.bgNode.opacity = 0;
        cc.tween(this.bgNode)
            .to(0.25, { opacity: 255 })
            .start();

        let bg = this.bgNode.getChildByName("bg");
        if (bg) {
            bg.opacity = 204;
        }
    }

}
