import { EventCenter } from '../FrameWork/EventCenter';
import { EventName } from './EventName';
import { Log } from '../FrameWork/Log';
const { ccclass, property } = cc._decorator;

@ccclass
export class TouchNode extends cc.Component {
    onLoad() {
        this.node.on(cc.Node.EventType.MOUSE_DOWN, this.dontBeSwallowed, this);
        this.node.on(cc.Node.EventType.MOUSE_MOVE, this.dontBeSwallowed, this);
        this.node.on(cc.Node.EventType.MOUSE_UP, this.dontBeSwallowed, this);
        this.node.on(cc.Node.EventType.TOUCH_START, this.dontBeSwallowed, this);
        this.node.on(cc.Node.EventType.TOUCH_MOVE, this.dontBeSwallowed, this);
        this.node.on(cc.Node.EventType.TOUCH_END, this.dontBeSwallowed, this);
        this.node.on(cc.Node.EventType.TOUCH_CANCEL, this.dontBeSwallowed, this);


        // 在2.4版本中，设置节点不吞噬触摸事件，让事件可以透传下去
        if ((this.node as any)._touchListener) {
            (this.node as any)._touchListener.setSwallowTouches(false);
        }
    }

    onDestroy() {
        this.node.off(cc.Node.EventType.MOUSE_DOWN, this.dontBeSwallowed, this);
        this.node.off(cc.Node.EventType.MOUSE_MOVE, this.dontBeSwallowed, this);
        this.node.off(cc.Node.EventType.MOUSE_UP, this.dontBeSwallowed, this);
        this.node.off(cc.Node.EventType.TOUCH_START, this.dontBeSwallowed, this);
        this.node.off(cc.Node.EventType.TOUCH_MOVE, this.dontBeSwallowed, this);
        this.node.off(cc.Node.EventType.TOUCH_END, this.dontBeSwallowed, this);
        this.node.off(cc.Node.EventType.TOUCH_CANCEL, this.dontBeSwallowed, this);

    }

    dontBeSwallowed(event: cc.Event.EventMouse | cc.Event.EventTouch) {
        // 检查是否是鼠标事件
        if (event instanceof cc.Event.EventMouse) {
            if (event.getButton() == 0) {
                EventCenter.dispatchEvent(EventName.ScreenClick, event);
                return;
            }
        }

        // 检查是否是触摸事件
        if (event instanceof cc.Event.EventTouch) {
            EventCenter.dispatchEvent(EventName.ScreenClick, event);
            return;
        }
    }
}

