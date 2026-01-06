// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

const { ccclass, property } = cc._decorator;

@ccclass
export default class ItemGuaGuaKa extends cc.Component {

    @property({ type: cc.Mask, tooltip: "遮罩" })
    mask: cc.Mask = null;
    @property({ type: cc.Node, tooltip: "纯灰色图片" })
    cover: cc.Node = null;

    start() {
        this.begin();
    }

    /**开始 */
    public begin() {
        //设置线段
        let graphics: cc.Graphics = (this.mask as any)._graphics;
        graphics.lineWidth = 60;
        graphics.lineCap = cc.Graphics.LineCap.ROUND;
        graphics.lineJoin = cc.Graphics.LineJoin.ROUND;
        graphics.strokeColor = cc.color(255, 255, 255, 255);

        //触摸事件
        this.cover.on(cc.Node.EventType.TOUCH_START, this.onTouchStart, this);
        this.cover.on(cc.Node.EventType.TOUCH_MOVE, this.onTouchMove, this);
    }

    /**停止 */
    public stop() {
        this.cover.off(cc.Node.EventType.TOUCH_START, this.onTouchStart, this);
        this.cover.off(cc.Node.EventType.TOUCH_MOVE, this.onTouchMove, this);
    }

    /**重置 */
    public reset() {
        let graphics: cc.Graphics = (this.mask as any)._graphics;
        graphics.clear();
    }

    /**触摸开始 */
    private onTouchStart(e: cc.Event.EventTouch) {
        //记录触摸起始点，将触摸点世界坐标转成cover本地坐标
        let pos = this.cover.convertToNodeSpaceAR(e.getLocation());
        //将画线起点移动到触摸起始点
        let graphics: cc.Graphics = (this.mask as any)._graphics;
        graphics.moveTo(pos.x, pos.y);
    }

    /**触摸移动 */
    private onTouchMove(e: cc.Event.EventTouch) {
        //将触摸点世界坐标转成cover本地坐标
        let pos = this.cover.convertToNodeSpaceAR(e.getLocation());
        //画线
        let graphics: cc.Graphics = (this.mask as any)._graphics;
        graphics.lineTo(pos.x, pos.y);
        graphics.stroke();
    }
}
