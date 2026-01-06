// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { PrefabDefine } from "../../FrameWork/PrefabDefine";
import { UIManager } from "../../FrameWork/UIManager";
import { GameMgr } from "../../Module/Game/GameMgr";
import UserDataMgr from "../../Module/UserData/UserDataMgr";
import { ReceiveEventManager } from "../../Platform/Android/ReceiveEventManager";

const { ccclass, property } = cc._decorator;

@ccclass
export default class PopDebug extends cc.Component {

    @property(cc.Button)
    btnClose: cc.Button = null;

    // 跳转关卡
    @property(cc.Button)
    btnJumpLevel: cc.Button = null;
    @property(cc.EditBox)
    editBoxLevel: cc.EditBox = null;

    // 切换国家
    @property(cc.Button)
    btnSwitchCountry: cc.Button = null;
    @property(cc.EditBox)
    editBoxCountry: cc.EditBox = null;

    // 切换语言
    @property(cc.Button)
    btnSwitchLanguage: cc.Button = null;
    @property(cc.EditBox)
    editBoxLanguage: cc.EditBox = null;

    // 添加道具数量
    @property(cc.Button)
    btnAddProp: cc.Button = null;
    @property(cc.EditBox)
    editBoxAddProp: cc.EditBox = null;

    // 添加美元
    @property(cc.Button)
    btnAddMoney: cc.Button = null;
    @property(cc.EditBox)
    editBoxAddMoney: cc.EditBox = null;

    // 提现倒计时到期
    @property(cc.Button)
    btnWithdrawTimeLimitEnd: cc.Button = null;

    // 添加金卡
    @property(cc.Button)
    btnAddGoldenCard: cc.Button = null;
    @property(cc.EditBox)
    editBoxAddGoldenCard: cc.EditBox = null;

    start() {
        this.btnClose.node.on('click', this.onClose, this);
        this.btnJumpLevel.node.on('click', this.onJumpLevel, this);
        this.btnSwitchCountry.node.on('click', this.onSwitchCountry, this);
        this.btnSwitchLanguage.node.on('click', this.onSwitchLanguage, this);
        this.btnAddProp.node.on('click', this.onAddProp, this);
        this.btnAddMoney.node.on('click', this.onAddMoney, this);
        this.btnWithdrawTimeLimitEnd.node.on('click', this.onWithdrawTimeLimitEnd, this);
        this.btnAddGoldenCard.node.on('click', this.onAddGoldenCard, this);
    }

    onClose() {
        UIManager.Instance.close(PrefabDefine.PopDebug);
    }

    onJumpLevel() {
        let levelId = parseInt(this.editBoxLevel.string);
        GameMgr.Instance.startTestLevel(levelId);
    }

    onSwitchCountry() {
        let country = this.editBoxCountry.string;
        UserDataMgr.Instance.country = country;
    }

    onSwitchLanguage() {
        let language = this.editBoxLanguage.string;
        UserDataMgr.Instance.language = language;
    }

    onAddProp() {
        let prop = parseInt(this.editBoxAddProp.string);
        UserDataMgr.Instance.addTipNumber(prop, true);
    }

    onAddMoney() {
        let money = parseInt(this.editBoxAddMoney.string);
        UserDataMgr.Instance.addMoneyNumber(money, true);
    }

    onWithdrawTimeLimitEnd() {
        ReceiveEventManager.withdrawTimeLimitEnd();
    }

    onAddGoldenCard() {
        let goldenCard = parseInt(this.editBoxAddGoldenCard.string);
        UserDataMgr.Instance.addGoldenCardNumber(goldenCard, true);
    }
}
