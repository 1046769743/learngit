// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

const { ccclass, property } = cc._decorator;

@ccclass
export default class BasePop extends cc.Component {

    @property(cc.Node)
    bgNode: cc.Node = null;

    @property(cc.Node)
    contentNode: cc.Node = null;

    showEnterAnim() {
        this.contentNode.opacity = 100;
        this.contentNode.scale = 0.5;
        cc.tween(this.contentNode)
            .parallel(
                cc.fadeIn(0.1),
                cc.scaleTo(0.1, 1)
            )
            .start();

        this.bgNode.opacity = 0;
        let bg = this.bgNode.getChildByName("bg");
        if (bg) {
            bg.opacity = 255;
        }
        cc.tween(this.bgNode)
            .to(0.15, { opacity: 204 })
            .start();
    }

    hideCloseAnim(callback: Function = null) {
        console.log("hideCloseAnim");

        cc.tween(this.bgNode)
            .to(0.35, { opacity: 0 }, { easing: 'sineInOut' })
            .start();

        cc.tween(this.contentNode)
            .parallel(
                cc.fadeOut(0.35),
                cc.scaleTo(0.35, 0, 0)
            )
            .call(callback)
            .start();
    }
}
