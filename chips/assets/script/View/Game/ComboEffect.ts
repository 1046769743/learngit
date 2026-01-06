import { ObjectPoolManager } from '../../Common/ObjectPoolManager';
import { Log } from '../../FrameWork/Log';
const { ccclass, property } = cc._decorator;

@ccclass
export default class ComboEffect extends cc.Component {
    @property(cc.Node)
    mRoot: cc.Node = null;
    @property(cc.Sprite)
    Sprite1: cc.Sprite = null;
    @property(cc.Sprite)
    Sprite2: cc.Sprite = null;
    @property({ type: [cc.SpriteFrame] })
    NumSprRec: Array<cc.SpriteFrame> = [];
    @property(cc.Animation)
    public ComboAnim: cc.Animation = null;


    ShowUI(pos: cc.Vec3, comboNum: number) {
        pos.x = cc.misc.clampf(pos.x, 50, cc.view.getVisibleSize().width - 160);
        // 在 2.4 中，如果 pos 是世界坐标，需要转换到本地坐标
        if (this.mRoot.parent) {
            let localPos = this.mRoot.parent.convertToNodeSpaceAR(new cc.Vec2(pos.x, pos.y));
            this.mRoot.setPosition(localPos);
        } else {
            this.mRoot.setPosition(pos.x, pos.y);
        }
        this.ShowEffect(comboNum)
    }

    ShowEffect(comboNum: number) {
        return;
        Log.Debug("ShowEffect comboNum: " + comboNum);
        let index = comboNum - 2;
        if (index < 0) {
            index = 0;
        }
        if (index >= this.NumSprRec.length) {
            index = this.NumSprRec.length - 1;
        }
        Log.Debug("ShowEffect index: " + index);
        this.Sprite1.spriteFrame = this.NumSprRec[index]
        this.Sprite2.spriteFrame = this.NumSprRec[index]
        // ComboAnim 将动画重置到初始状态
        // this.ComboAnim.resume();
        // this.ComboAnim.play("ComboEffect");
        // // 播放完后 回收
        // let self = this;
        // this.ComboAnim.on(cc.Animation.EventType.FINISHED, () => {
        //     ObjectPoolManager.instance.putNode(self.node);
        //     self.ComboAnim.off(cc.Animation.EventType.FINISHED);
        // }, this)
    }
}

